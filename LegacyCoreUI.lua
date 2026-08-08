-- Full CoreGui UICorner + Backpack Color Matcher
-- No transparency changes

local CoreGui = game:GetService("CoreGui")

local function getBrighterColor(color, amount)
	amount = amount or 0.18
	return Color3.new(
		math.clamp(color.R + amount, 0, 1),
		math.clamp(color.G + amount, 0, 1),
		math.clamp(color.B + amount, 0, 1)
	)
end

local function addOrSetCorner(inst, radius)
	if not inst:IsA("GuiObject") then return end

	local corner = inst:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = inst
	end
	corner.CornerRadius = UDim.new(0, radius)
end

local function styleInstance(inst, targetColor)
	if not inst:IsA("GuiObject") then return end

	-- Apply brighter backpack color
	pcall(function()
		inst.BackgroundColor3 = targetColor
	end)

	-- Force UICorner 8
	addOrSetCorner(inst, 8)
end

local function process(inst, targetColor)
	styleInstance(inst, targetColor)

	for _, child in ipairs(inst:GetChildren()) do
		process(child, targetColor)
	end
end

-- ======================
-- GET BACKPACK COLOR
-- ======================
local backpackColor = Color3.fromRGB(99, 95, 98) -- fallback
local backpack = CoreGui:FindFirstChild("Backpack", true)
	or (CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui:FindFirstChild("Backpack", true))

if backpack and backpack:IsA("GuiObject") then
	backpackColor = backpack.BackgroundColor3
	print("Found Backpack color:", backpackColor)
else
	warn("Backpack not found, using fallback color")
end

local brighterColor = getBrighterColor(backpackColor, 0.18)
print("Using brighter color:", brighterColor)

-- ======================
-- APPLY TO ENTIRE COREGUI
-- ======================
process(CoreGui, brighterColor)

print("✅ Finished — UICorner 8 + brighter Backpack color applied to entire CoreGui")
