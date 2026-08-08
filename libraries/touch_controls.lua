local Touch = {}
Touch.__index = Touch

local VIRTUAL_BINDS = {
    vleft = 'left',
    vright = 'right',
    vup = 'up',
    vdown = 'down',
    vreturn = 'return',
    vescape = 'escape',
    vbackspace = 'backspace',
    vtab = 'tab',
}

function Touch:new()
    local self = setmetatable({}, Touch)
    self.active = false
    self.mode = 'menu'
    self.buttons = {}
    self.screenW = love.graphics.getWidth()
    self.screenH = love.graphics.getHeight()
    return self
end

function Touch:activate()
    self.active = true
    self:layout()
end

function Touch:deactivate()
    self.active = false
    for _, btn in ipairs(self.buttons) do
        btn.active = false
        btn.touchId = nil
        if btn.vkey then input.state[btn.vkey] = false end
    end
end

function Touch:setMode(mode)
    if self.mode == mode then return end
    self.mode = mode
    self:layout()
end

function Touch:addButton(label, x, y, radius, vkey)
    table.insert(self.buttons, {
        label = label,
        x = x, y = y,
        radius = radius,
        vkey = vkey,
        active = false,
        touchId = nil,
    })
end

function Touch:layout()
    self.buttons = {}
    if not self.active then return end

    local sw, sh = self.screenW, self.screenH
    local r = math.floor(sh*0.075)
    local pad = math.floor(sh*0.03)

    self:addButton('ESC', sw - pad - r, pad + r, r, 'vescape')

    if self.mode == 'game' then
        local cy = sh - pad - r
        self:addButton('<', pad + r, cy, r, 'vleft')
        self:addButton('>', pad + r + math.floor(r*2.4), cy, r, 'vright')
        self:addButton('^', sw - pad - math.floor(r*1.5), sh - pad - math.floor(r*1.5), math.floor(r*1.5), 'vup')
    else
        local cx = pad + 3*r
        local cy = sh - pad - 3*r
        self:addButton('^', cx, cy - 2*r, r, 'vup')
        self:addButton('v', cx, cy + 2*r, r, 'vdown')
        self:addButton('<', cx - 2*r, cy, r, 'vleft')
        self:addButton('>', cx + 2*r, cy, r, 'vright')
        self:addButton('OK', sw - pad - math.floor(r*1.5), sh - pad - math.floor(r*1.5), math.floor(r*1.5), 'vreturn')
    end
end

function Touch:bindVirtual()
    for vkey, action in pairs(VIRTUAL_BINDS) do
        input:bind(vkey, action)
    end
end
function Touch:update()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    if w ~= self.screenW or h ~= self.screenH then
        self.screenW, self.screenH = w, h
        self:layout()
    end
end

function Touch:touchpressed(id, x, y)
    if not self.active then return end
    for _, btn in ipairs(self.buttons) do
        local dx = x - btn.x
        local dy = y - btn.y
        if (dx*dx + dy*dy) <= (btn.radius*btn.radius*1.44) then
            btn.active = true
            btn.touchId = id
            if btn.vkey then input.state[btn.vkey] = true end
            return
        end
    end
end

function Touch:touchmoved(id, x, y)
    if not self.active then return end
end

function Touch:touchreleased(id, x, y)
    if not self.active then return end
    for _, btn in ipairs(self.buttons) do
        if btn.touchId == id then
            btn.active = false
            btn.touchId = nil
            if btn.vkey then input.state[btn.vkey] = false end
            return
        end
    end
end

function Touch:draw()
    if not self.active then return end
    local font = love.graphics.getFont()
    for _, btn in ipairs(self.buttons) do
        local alpha = btn.active and 0.6 or 0.25
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle('fill', btn.x, btn.y, btn.radius)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.circle('line', btn.x, btn.y, btn.radius)
        local s = btn.radius*0.7/font:getHeight()
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.print(btn.label, btn.x, btn.y, 0, s, s, font:getWidth(btn.label)/2, font:getHeight()/2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Touch
