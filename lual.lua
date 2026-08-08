-- Solara V3 Optimized Topbar Hider
local CoreGui = game:GetService("CoreGui")

local success, err = pcall(function()
    -- 5-second max wait prevents Solara from infinitely yielding
    local topBar = CoreGui:WaitForChild("TopBarApp", 5) 
    
    if topBar then
        topBar.Enabled = false
    else
        warn("Solara Error: TopBarApp could not be found within time limit.")
    end
end)

if not success then
    print("Execution failed: " .. tostring(err))
end
