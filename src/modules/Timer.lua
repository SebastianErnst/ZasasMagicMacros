Timer = {}
Timer.__index = Timer

function Timer:new(key, duration)    
    local _key = key
    local _duration = duration

    local public = {}

    function public:start(callback)
        Timers.active[_key] = {
            remaining = _duration,
            callback  = callback,
        }
    end

    function public:cancel()
        Timers.active[_key] = nil
    end

    function public:isRunning()
        return Timers.active[_key] ~= nil
    end

    function public:getTimeLeft()
        local t = Timers.active[_key]
        if t then return t.remaining end
        return 0
    end

    return public
end