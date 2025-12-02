Timers = {}
Timers.frame  = CreateFrame("Frame")
Timers.active = {}

Timers.frame:SetScript("OnUpdate", function()
    local elapsed = arg1

    for key, timer in pairs(Timers.active) do
        timer.remaining = timer.remaining - elapsed
        if timer.remaining <= 0 then
            Timers.active[key] = nil
            if timer.callback then timer.callback() end
        end
    end
end)