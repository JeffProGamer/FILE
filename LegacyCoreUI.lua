-- Legacy Corner Fixer (Hotbar + Backpack + DevConsole only)
-- Only adds/sets UICorner to 8px — never touches Position or Size

local CoreGui = game:GetService("CoreGui")

local function addOrSetCorner(inst, radius)
	if not inst or not inst:IsA("GuiObject") then return end

	local corner = inst:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = inst
	end
	corner.CornerRadius = UDim.new(0, radius)
end

local function process(inst)
	if not inst then return end

	-- Only touch GuiObjects
	if inst:IsA("GuiObject") then
		addOrSetCorner(inst, 8)
	end

	-- Recurse into children
	for _, child in ipairs(inst:GetChildren()) do
		process(child)
	end
end

-- ======================
-- TARGETS
-- ======================

-- 1. Developer Console (the true legacy piece)
local devConsole = CoreGui:FindFirstChild("DevConsoleMaster")
	or CoreGui:FindFirstChild("DevConsole")
	or CoreGui:FindFirstChild("DeveloperConsole")

if devConsole then
	process(devConsole)
	print("✅ Applied UICorner 8 to Developer Console")
else
	warn("DevConsole not found")
end

-- 2. Backpack + Hotbar (common locations)
local function findAndProcess(name)
	local obj = CoreGui:FindFirstChild(name, true) -- deep search
	if obj then
		process(obj)
		print("✅ Applied UICorner 8 to", name)
	end
end

findAndProcess("Backpack")
findAndProcess("Hotbar")
findAndProcess("HotbarContainer")
findAndProcess("BackpackGui")
findAndProcess("HotbarGui")

-- Also check under RobloxGui (most common place)
local robloxGui = CoreGui:FindFirstChild("RobloxGui")
if robloxGui then
	findAndProcess("Backpack")
	findAndProcess("Hotbar")
	
	-- Extra common names used over the years
	for _, name in ipairs({"HotbarFrame", "BackpackFrame", "Inventory", "Toolbelt"}) do
		local obj = robloxGui:FindFirstChild(name, true)
		if obj then
			process(obj)
			print("✅ Applied UICorner 8 to", name)
		end
	end
end

print("Legacy Corner Fix finished — only UICorners were changed")
