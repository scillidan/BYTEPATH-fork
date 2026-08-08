local Touch = {}
Touch.__index = Touch

function Touch:new()
    local self = setmetatable({}, Touch)
    self.active = false
    self.joystick = {
        touchId = nil,
        baseX = 0, baseY = 0,
        knobX = 0, knobY = 0,
        radius = 50,
        knobRadius = 20,
        deadzone = 0.15
    }
    self.moveX = 0
    self.moveY = 0
    self.buttons = {}
    self.screenW = love.graphics.getWidth()
    self.screenH = love.graphics.getHeight()
    return self
end

function Touch:update()
    self.screenW = love.graphics.getWidth()
    self.screenH = love.graphics.getHeight()
end

function Touch:touchpressed(id, x, y)
    if not self.active then return end
    local js = self.joystick
    if x < self.screenW / 3 and y > self.screenH / 2 then
        js.active = true
        js.touchId = id
        js.baseX = x
        js.baseY = y
        js.knobX = x
        js.knobY = y
        return
    end
    for _, btn in ipairs(self.buttons) do
        local dx = x - btn.x
        local dy = y - btn.y
        if (dx*dx + dy*dy) <= (btn.radius * btn.radius * 1.44) then
            btn.active = true
            btn.touchId = id
            if btn.onPress then btn.onPress() end
            return
        end
    end
end

function Touch:touchmoved(id, x, y)
    if not self.active then return end
    local js = self.joystick
    if js.touchId == id then
        local dx = x - js.baseX
        local dy = y - js.baseY
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > js.radius then
            dx = dx / dist * js.radius
            dy = dy / dist * js.radius
            dist = js.radius
        end
        js.knobX = js.baseX + dx
        js.knobY = js.baseY + dy
        local nd = dist / js.radius
        if nd < js.deadzone then
            self.moveX = 0
            self.moveY = 0
        else
            local scale = (nd - js.deadzone) / (1 - js.deadzone)
            self.moveX = (dx / dist) * scale
            self.moveY = (dy / dist) * scale
        end
    end
end

function Touch:touchreleased(id, x, y)
    if not self.active then return end
    local js = self.joystick
    if js.touchId == id then
        js.active = false
        js.touchId = nil
        self.moveX = 0
        self.moveY = 0
        return
    end
    for _, btn in ipairs(self.buttons) do
        if btn.touchId == id then
            btn.active = false
            btn.touchId = nil
            if btn.onRelease then btn.onRelease() end
            return
        end
    end
end

function Touch:addButton(label, x, y, radius, onPress, onRelease)
    table.insert(self.buttons, {
        label = label,
        x = x, y = y,
        radius = radius or 30,
        active = false,
        touchId = nil,
        onPress = onPress,
        onRelease = onRelease
    })
end

function Touch:draw()
    if not self.active then return end
    local js = self.joystick
    if js.active then
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.circle("fill", js.baseX, js.baseY, js.radius)
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.circle("line", js.baseX, js.baseY, js.radius)
        love.graphics.setColor(0.4, 0.7, 1, 0.7)
        love.graphics.circle("fill", js.knobX, js.knobY, js.knobRadius)
    end
    for _, btn in ipairs(self.buttons) do
        local alpha = btn.active and 0.8 or 0.4
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle("fill", btn.x, btn.y, btn.radius)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.circle("line", btn.x, btn.y, btn.radius)
        love.graphics.setColor(0, 0, 0, 0.9)
        local font = love.graphics.getFont()
        local tw = font:getWidth(btn.label)
        local th = font:getHeight()
        love.graphics.print(btn.label, btn.x - tw/2, btn.y - th/2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Touch:activate()
    self.active = true
end

function Touch:deactivate()
    self.active = false
    self.moveX = 0
    self.moveY = 0
    self.joystick.active = false
    self.joystick.touchId = nil
    for _, btn in ipairs(self.buttons) do
        btn.active = false
        btn.touchId = nil
    end
end

return Touch
