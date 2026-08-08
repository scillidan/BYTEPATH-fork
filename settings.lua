local bitser = require 'libraries/bitser/bitser'

local settings = {}

settings.file = 'settings.dat'
settings.binds = {}
settings.defaults = {}

function settings.setDefaultBinds(binds)
    settings.defaults = {}
    for action, keys in pairs(binds) do
        if type(keys) == 'table' then
            settings.defaults[action] = fn.clone(keys)
        else
            settings.defaults[action] = {keys}
        end
    end
    if not settings.loaded then
        settings.binds = {}
        for action, keys in pairs(settings.defaults) do
            settings.binds[action] = fn.clone(keys)
        end
    end
end

function settings.load()
    if love.filesystem.getInfo(settings.file) then
        local ok, data = pcall(bitser.loadLoveFile, settings.file)
        if ok and type(data) == 'table' and data.binds then
            settings.binds = data.binds
            settings.loaded = true
            for action, keys in pairs(settings.defaults) do
                if not settings.binds[action] then
                    settings.binds[action] = fn.clone(keys)
                end
            end
            return
        end
    end
    settings.binds = {}
    for action, keys in pairs(settings.defaults) do
        settings.binds[action] = fn.clone(keys)
    end
    settings.loaded = true
end

function settings.save()
    local data = {binds = settings.binds}
    pcall(bitser.dumpLoveFile, settings.file, data)
end

function settings.rebind(action, keys)
    if type(keys) == 'table' then
        settings.binds[action] = fn.clone(keys)
    else
        settings.binds[action] = {keys}
    end
    settings.save()
end

function settings.reset(action)
    if settings.defaults[action] then
        settings.binds[action] = fn.clone(settings.defaults[action])
        settings.save()
    end
end

function settings.resetAll()
    for action, keys in pairs(settings.defaults) do
        settings.binds[action] = fn.clone(keys)
    end
    settings.save()
end

function settings.getBinds(action)
    return settings.binds[action] or settings.defaults[action] or {}
end

return settings
