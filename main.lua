Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'
Vector = require 'libraries/hump/vector-light'
draft = require('libraries/draft/draft')()
bitser = require 'libraries/bitser/bitser'
Math = require 'libraries/mlib/mlib'
Grid = require 'libraries/grid/grid'
Cam = require 'libraries/STALKER-X/Camera'
Tim = require 'libraries/chrono/Timer'
binser = require 'libraries/binser/binser'
HC = require 'libraries/HC'
ffi = require('ffi')
settings = require 'settings'

-- require 'enet'
require 'libraries/sound'
require 'libraries/utf8'
require 'GameObject'
require 'utils'
require 'globals'
require 'tree'

function love.load()
    time = 0
    start_time = os.time()
    start_date = os.date("*t")
    trailer_mode = true

    love.filesystem.setIdentity('BYTEPATH')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')
    love.graphics.setBackgroundColor(background_color)
    love.keyboard.setKeyRepeat(false)

    loadFonts('resources/fonts')
    loadGraphics('resources/graphics')
    loadShaders('resources/shaders')
    shaders.distort:send('scanlines', 0.5)
    shaders.distort:send('rgb_offset', 0.2)
    shaders.distort:send('horizontal_fuzz', 0.5)
    shaders.grayscale:send('grayscale_amount', 0.0)
    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)
    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)

    timer = Timer()
    input = Input()
    camera = Camera()
    sound()

    local Touch = require 'libraries/touch_controls'
    touch = Touch:new()
    if isHandheldDevice() then
        touch = nil
    end

    --[[
    input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)
    ]]--

    --[[
    input:bind('f2', function() gotoRoom('Stage') end)
    input:bind('f3', function()
        if current_room then
            current_room:destroy()
            current_room = nil
        end
    end)
    ]]--

    input:bind('left', 'left')
    input:bind('right', 'right')
    input:bind('up', 'up')
    input:bind('down', 'down')
    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('w', 'up')
    input:bind('s', 'down')
    input:bind('mouse1', 'left_click')
    input:bind('wheelup', 'zoom_in')
    input:bind('wheeldown', 'zoom_out')
    input:bind('return', 'return')
    input:bind('backspace', 'backspace')
    input:bind('escape', 'escape')
    input:bind('dpleft', 'left')
    input:bind('dpright', 'right')
    input:bind('dpup', 'up')
    input:bind('dpdown', 'down')
    input:bind('fright', 'up')
    input:bind('fdown', 'down')
    input:bind('fleft', 'return')
    input:bind('select', 'escape')
    input:bind('start', 'return')
    input:bind('tab', 'tab')

    settings.setDefaultBinds({
        left = {'left', 'a', 'dpleft'},
        right = {'right', 'd', 'dpright'},
        up = {'up', 'w', 'dpup', 'fright'},
        down = {'down', 's', 'dpdown', 'fdown'},
        left_click = {'mouse1'},
        ['return'] = {'return', 'fleft', 'start'},
        backspace = {'backspace'},
        escape = {'escape', 'select'},
        tab = {'tab'},
    })
    settings.load()

    load()

    -- Any Raspberry Pi / ARM Linux handheld (GPi CASE 2, PocketTerm, ...) should
    -- always launch into a fullscreen window covering the whole desktop, otherwise
    -- the game window can end up smaller than the panel and show the desktop
    -- background (often white) as bars around the 16:9 game area.
    if isHandheldDevice() then
        resizeFullscreen()
    elseif first_run_ever then resizeFullscreen()
    else resize(sx, sy, fullscreen) end

    -- Small diagnostic: report the real window/desktop sizes so handheld display
    -- problems can be diagnosed from the save directory (window_debug.txt).
    local w_, h_ = love.window.getMode()
    local dw_, dh_ = love.window.getDesktopDimensions()
    local _, _, mode_flags = love.window.getMode()
    love.filesystem.write('window_debug.txt',
        'window: ' .. w_ .. 'x' .. h_ .. '  desktop: ' .. dw_ .. 'x' .. dh_
        .. '  fullscreen: ' .. tostring(mode_flags.fullscreen) .. '\n')

    current_room = nil
    timer:after(0.5, function() gotoRoom('Console') end)

    slow_amount = 1
    fps = 60
    disable_expensive_shaders = false
    pre_disable_expensive_shaders = false
    disable_expensive_shaders_time = 0

    playRandomSong()

    update_times = {}
    update_index = 1
    draw_times = {}
    draw_index = 1

    --[[
    timer:every(1, function()
        local update_sum = 0
        for _, time in ipairs(update_times) do update_sum = update_sum + time end
        local update_time = update_sum/#update_times
        update_times = {}
        update_index = 1

        local draw_sum = 0
        for _, time in ipairs(draw_times) do draw_sum = draw_sum + time end
        local draw_time = draw_sum/#draw_times
        draw_times = {}
        draw_index = 1

        print('update: ' .. 1000*update_time, 'draw: ' .. 1000*draw_time, 'total: ' .. 1000*(update_time + draw_time))
    end)
    ]]--
end

function love.update(dt)
    local start_time = os.clock()

    time = time + dt
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    soundUpdate(dt*slow_amount)
    if touch then touch:update() end
    if current_room then current_room:update(dt*slow_amount) end

    -- Disable expensive shaders if FPS remains below 10 for 1 seconds
    fps = love.timer.getFPS()
    if fps < 10 and not pre_disable_expensive_shaders then 
        pre_disable_expensive_shaders = true 
        disable_expensive_shaders_time = love.timer.getTime()
    end
    if fps > 10 and pre_disable_expensive_shaders then pre_disable_expensive_shaders = false end
    if love.timer.getTime() - disable_expensive_shaders_time > 3 and pre_disable_expensive_shaders then 
        disable_expensive_shaders = true 
        pre_disable_expensive_shaders = false
    end

    update_times[update_index] = os.clock() - start_time
    update_index = update_index + 1
end

function love.draw()
    local start_time = os.clock()

    if current_room then current_room:draw() end

    if flash_frames then
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(background_color)
        if isDisplayRotated() then
            love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        else
            local ox, oy, s = getLetterboxOffset()
            love.graphics.rectangle('fill', ox, oy, gw*s, gh*s)
        end
        love.graphics.setColor(1, 1, 1)
    end

    draw_times[draw_index] = os.clock() - start_time
    draw_index = draw_index + 1

    if touch then touch:draw() end
end

function love.keypressed(key)
    if current_room and current_room.keypressed then current_room:keypressed(key) end
end

function love.textinput(t)
    if current_room and current_room.textinput then current_room:textinput(t) end
end

function love.focus(f)
    if not f then
        if current_room and current_room:is(Stage) and not current_room.paused then
            current_room:pause()
        end
    end
end

function love.quit()
    save()
end

function resize(x, y, fs)
    local y = y or x
    fullscreen = fs
    love.window.setMode(x*gw, y*gh, {display = display, fullscreen = fs, borderless = fs, resizable = true})
    sx, sy = x, y
end

function love.resize(w, h)
    local new_sx, new_sy = math.floor(w/gw), math.floor(h/gh)
    if new_sx < 1 then new_sx = 1 end
    if new_sy < 1 then new_sy = 1 end
    sx, sy = new_sx, new_sy
    if sx == 0 then sx = 1 end
    if sy == 0 then sy = 1 end
end

function isDisplayRotated()
    if not (touch and touch.active) then return false end
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    return h > w
end

function getLetterboxOffset()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    if isDisplayRotated() then w, h = h, w end
    local scale = math.min(w/gw, h/gh)
    local offset_x = math.floor((w - gw*scale)/2)
    local offset_y = math.floor((h - gh*scale)/2)
    return offset_x, offset_y, scale
end

function drawGameCanvas(canvas)
    local ox, oy, s = getLetterboxOffset()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    -- The distort shader samples the bound texture and ignores the vertex color,
    -- so a solid-color rectangle drawn through it renders WHITE (default texture
    -- is white). Draw the letterbox background without the shader and re-apply it
    -- only for the game canvas, like SNKRX does.
    local shader = love.graphics.getShader()
    love.graphics.setShader()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(shader)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    if isDisplayRotated() then
        love.graphics.draw(canvas, w/2 + s*gh/2, h/2 - s*gw/2, math.pi/2, s, s)
    else
        love.graphics.draw(canvas, ox, oy, 0, s, s)
    end
    love.graphics.setBlendMode('alpha')
end

function isHandheldDevice()
    if love.system.getOS() ~= "Linux" then return false end
    local ok, ffi = pcall(require, 'ffi')
    if not ok then return false end
    return ffi.arch == "arm" or ffi.arch == "arm64"
end

function resizeFullscreen()
    fullscreen = true
    local w, h = love.window.getDesktopDimensions()
    -- Same fullscreen setup as SNKRX (desktop fullscreen + borderless), so the
    -- window always covers the whole panel instead of leaving desktop edges.
    love.window.setMode(w, h, {display = display, vsync = 1, fullscreen = true, borderless = true, resizable = false, x = 0, y = 0})
    local _, _, flags = love.window.getMode()
    if not flags.fullscreen then
        -- Fullscreen was not honoured (e.g. bare framebuffer / no window manager).
        -- Fall back to a borderless window that still covers the whole desktop so
        -- no desktop edges (white bars) show around the game.
        love.window.setMode(w, h, {display = display, vsync = 1, fullscreen = false, borderless = true, resizable = false, x = 0, y = 0})
    end
    sx, sy = w/gw, h/gh
end

function changeToDisplay(n)
    display = n
    resize(getScaleBasedOnDisplay())
end

function getScaleBasedOnDisplay()
    local w, h = love.window.getDesktopDimensions(display)
    local sw, sh = math.floor(w/gw), math.floor(h/gh)
    if sw == sh then return math.min(sw, sh) - 1
    else return math.min(sw, sh) end
end



-- Effects --
function flash(frames)
    flash_frames = frames
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function frameStop(duration, object_types)
    if current_room then current_room.area:frameStop(duration, object_types) end
end



-- Save/Load --
function save()
    local transient_save_data = {}
    local permanent_save_data = {}

    permanent_save_data.id = id
    permanent_save_data.loop = loop
    permanent_save_data.sx = sx
    permanent_save_data.sy = sy
    permanent_save_data.high_score = high_score
    permanent_save_data.main_volume = main_volume
    permanent_save_data.sfx_volume = sfx_volume
    permanent_save_data.music_volume = music_volume
    permanent_save_data.screen_shake = screen_shake
    permanent_save_data.distortion = distortion
    permanent_save_data.glitch = glitch
    permanent_save_data.muted = muted
    permanent_save_data.fullscreen = fullscreen
    permanent_save_data.display = display
    permanent_save_data.achievements = achievements

    transient_save_data.skill_points = skill_points
    transient_save_data.bought_node_indexes = bought_node_indexes
    transient_save_data.run = run
    transient_save_data.classes = classes
    transient_save_data.rank = rank
    transient_save_data.device = device
    transient_save_data.unlocked_devices = unlocked_devices
    transient_save_data.display = display
    transient_save_data.keys = keys
    transient_save_data.found_keys = found_keys
    transient_save_data.max_tree_nodes = max_tree_nodes
    transient_save_data.spent_sp = spent_sp

    bitser.dumpLoveFile('permanent_save', permanent_save_data)
    bitser.dumpLoveFile('transient_save', transient_save_data)
end

function load()
    local loadPermanentVariables = function(save_data)
        id = save_data.id
        loop = save_data.loop
        sx = save_data.sx
        sy = save_data.sy
        high_score = save_data.high_score
        main_volume = save_data.main_volume
        sfx_volume = save_data.sfx_volume
        music_volume = save_data.music_volume
        screen_shake = save_data.screen_shake
        distortion = save_data.distortion
        glitch = save_data.glitch
        muted = save_data.muted
        fullscreen = save_data.fullscreen
        display = save_data.display
        achievements = save_data.achievements
    end

    local loadTransientVariables = function(save_data)
        skill_points = save_data.skill_points
        bought_node_indexes = save_data.bought_node_indexes
        run = save_data.run
        classes = save_data.classes
        rank = save_data.rank
        device = save_data.device
        unlocked_devices = save_data.unlocked_devices
        keys = save_data.keys
        found_keys = save_data.found_keys
        max_tree_nodes = save_data.max_tree_nodes
        spent_sp = save_data.spent_sp
    end

    local localLoad = function()
        if love.filesystem.getInfo('permanent_save') ~= nil then
            local save_data = bitser.loadLoveFile('permanent_save')
            loadPermanentVariables(save_data)
        end
        if love.filesystem.getInfo('transient_save') ~= nil then
            local save_data = bitser.loadLoveFile('transient_save')
            loadTransientVariables(save_data)
        else first_run_ever = true end
    end

    localLoad()
end

function removeSave()
    love.filesystem.remove('transient_save')
end

-- Room --
function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
    if touch and touch.active then
        touch:setMode(room_type == 'Stage' and 'game' or 'menu')
        touch:bindVirtual()
    end
end

-- Load --
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file, "file") ~= nil then
            table.insert(file_list, file)
        elseif love.filesystem.getInfo(file, "directory") ~= nil then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function loadFonts(path)
    fonts = {}
    local font_paths = {}
    recursiveEnumerate(path, font_paths)
    for i = 8, 16, 1 do
        for _, font_path in pairs(font_paths) do
            local last_forward_slash_index = font_path:find("/[^/]*$")
            local font_name = font_path:sub(last_forward_slash_index+1, -5)
            local font = love.graphics.newFont(font_path, i)
            font:setFilter('nearest', 'nearest')
            fonts[font_name .. '_' .. i] = font
        end
    end
end

function loadGraphics(path)
    assets = {}
    local asset_paths = {}
    recursiveEnumerate(path, asset_paths)
    for _, asset_path in pairs(asset_paths) do
        local last_forward_slash_index = asset_path:find("/[^/]*$")
        local asset_name = asset_path:sub(last_forward_slash_index+1, -5)
        local image = love.graphics.newImage(asset_path, {mipmaps = true})
        assets[asset_name] = image
    end
end

function loadShaders(path)
    shaders = {}
    local shader_paths = {}
    recursiveEnumerate(path, shader_paths)
    for _, shader_path in pairs(shader_paths) do
        local last_forward_slash_index = shader_path:find("/[^/]*$")
        local shader_name = shader_path:sub(last_forward_slash_index+1, -6)
        local shader = love.graphics.newShader(shader_path)
        shaders[shader_name] = shader
    end
end



-- Memory --
function count_all(f)
    local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(0, 0, 0, 1)
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if touch then touch:touchpressed(id, x, y) end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if touch then touch:touchmoved(id, x, y) end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if touch then touch:touchreleased(id, x, y) end
end
