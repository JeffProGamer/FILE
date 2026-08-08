-- One-bit Full CoreGui Legacy Style Script
-- Old Backpack color + UICorner 8 + Resume → Play Green

local CoreGui = game:GetService("CoreGui")

-- Colors
local PLAY_GREEN = Color3.fromRGB(0, 170, 80)

local function getBrighterColor(color, amount)
	amount = amount or 0.15
	return Color3.new(
		math.clamp(color.R + amount, 0, 1),
		math.clamp(color.G + amount, 0, 1),
		math.clamp(color.B + amount, 0, 1)
	)
end

local function addOrSetCorner(inst)
	if not inst:IsA("GuiObject") then return end
	local corner = inst:FindFirstChildOfClass("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Parent = inst
	end
	corner.CornerRadius = UDim.new(0, 8)
end

local function forceColor(inst, color)
	pcall(function()
		if inst:IsA("GuiObject") then
			inst.BackgroundColor3 = color
		end
		if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
			inst.ImageColor3 = color
		end
		-- Remove gradient so color actually shows
		local gradient = inst:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient:Destroy()
		end
	end)
end

-- Get real Backpack color
local backpackColor = Color3.fromRGB(99, 95, 98) -- fallback
local backpack = CoreGui:FindFirstChild("Backpack", true)
if not backpack then
	local robloxGui = CoreGui:FindFirstChild("RobloxGui")
	if robloxGui then
		backpack = robloxGui:FindFirstChild("Backpack", true)
	end
end

if backpack and backpack:IsA("GuiObject") then
	backpackColor = backpack.BackgroundColor3
	print("Using Backpack color:", backpackColor)
end

local oldColor = getBrighterColor(backpackColor, 0.15)

-- Main processor
local function process(inst)
	if inst:IsA("GuiObject") then
		local name = inst.Name:lower()

		-- Special case: Resume / Play / Continue → green
		if name:find("resume") or name:find("play") or name:find("continue") then
			forceColor(inst, PLAY_GREEN)
		else
			-- Everything else → old Backpack color
			forceColor(inst, oldColor)
		end

		-- Always add UICorner 8
		addOrSetCorner(inst)
	end

	for _, child in ipairs(inst:GetChildren()) do
		process(child)
	end
end

-- Run on entire CoreGui
process(CoreGui)

print("✅ Done — Whole CoreGui set to old color + UICorner 8 + Resume is green")
