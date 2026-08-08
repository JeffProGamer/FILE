--[[
	HUGE CoreGui Styler
	- Turns every blue element into Roblox Play Green
	- Handles UIGradients dynamically (converts blue keys → green)
	- Forces UICorner radius 8 on the entire CoreGui
	- Applies brighter Backpack color to everything else
	- Special handling for Resume / Play / Continue buttons
	- Deep recursive scan
	- Safe pcalls everywhere
]]

local CoreGui = game:GetService("CoreGui")

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------
local PLAY_GREEN = Color3.fromRGB(0, 170, 80)
local FALLBACK_GRAY = Color3.fromRGB(99, 95, 98)

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function isBlue(color)
	if typeof(color) ~= "Color3" then return false end
	local r, g, b = color.R, color.G, color.B
	return b > 0.38 and b > r + 0.12 and b > g + 0.12
end

local function getBrighter(color, amount)
	amount = amount or 0.16
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
	corner.CornerRadius = UDim.new(0, radius or 8)
end

local function forceColor(inst, color)
	pcall(function()
		if inst:IsA("GuiObject") then
			inst.BackgroundColor3 = color
		end
		if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
			inst.ImageColor3 = color
		end
	end)
end

----------------------------------------------------------------
-- UIGradient HANDLER (dynamic)
----------------------------------------------------------------
local function convertGradient(gradient)
	if not gradient or not gradient:IsA("UIGradient") then return end

	local success, keypoints = pcall(function()
		return gradient.Color.Keypoints
	end)
	if not success or not keypoints then return end

	local newKeypoints = {}
	local changed = false

	for _, kp in ipairs(keypoints) do
		local color = kp.Value
		if isBlue(color) then
			-- Convert blue → green while trying to keep relative brightness
			local brightness = math.clamp((color.R + color.G + color.B) / 3, 0.2, 1)
			local newColor = Color3.new(
				math.clamp(PLAY_GREEN.R * brightness * 1.6, 0, 1),
				math.clamp(PLAY_GREEN.G * brightness * 1.6, 0, 1),
				math.clamp(PLAY_GREEN.B * brightness * 1.6, 0, 1)
			)
			table.insert(newKeypoints, ColorSequenceKeypoint.new(kp.Time, newColor))
			changed = true
		else
			table.insert(newKeypoints, kp)
		end
	end

	if changed then
		pcall(function()
			gradient.Color = ColorSequence.new(newKeypoints)
		end)
		print("Converted UIGradient →", gradient:GetFullName())
	end
end

----------------------------------------------------------------
-- GET REAL BACKPACK COLOR
----------------------------------------------------------------
local backpackColor = FALLBACK_GRAY

local function findBackpack()
	local bp = CoreGui:FindFirstChild("Backpack", true)
	if bp and bp:IsA("GuiObject") then return bp end

	local robloxGui = CoreGui:FindFirstChild("RobloxGui")
	if robloxGui then
		bp = robloxGui:FindFirstChild("Backpack", true)
		if bp and bp:IsA("GuiObject") then return bp end
	end
	return nil
end

local backpack = findBackpack()
if backpack then
	backpackColor = backpack.BackgroundColor3
	print("Found Backpack color:", backpackColor)
else
	print("Backpack not found — using fallback gray")
end

local OLD_COLOR = getBrighter(backpackColor, 0.15)

----------------------------------------------------------------
-- MAIN PROCESSOR
----------------------------------------------------------------
local processed = 0
local blueConverted = 0
local cornersAdded = 0

local function process(inst)
	if not inst then return end

	-- Handle UIGradient first
	if inst:IsA("UIGradient") then
		convertGradient(inst)
	end

	if inst:IsA("GuiObject") then
		processed += 1
		local name = string.lower(inst.Name)

		-- 1. Special case: Resume / Play / Continue buttons → green
		if name:find("resume") or name:find("play") or name:find("continue") then
			forceColor(inst, PLAY_GREEN)
			blueConverted += 1
			print("Forced green on named button:", inst:GetFullName())

		-- 2. Anything that is currently blue → green
		elseif isBlue(inst.BackgroundColor3) then
			forceColor(inst, PLAY_GREEN)
			blueConverted += 1
			print("Blue Background → green:", inst:GetFullName())

		elseif (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and isBlue(inst.ImageColor3) then
			forceColor(inst, PLAY_GREEN)
			blueConverted += 1
			print("Blue ImageColor → green:", inst:GetFullName())

		-- 3. Everything else → old Backpack color
		else
			forceColor(inst, OLD_COLOR)
		end

		-- Always force UICorner 8
		addOrSetCorner(inst, 8)
		cornersAdded += 1
	end

	-- Recurse
	for _, child in ipairs(inst:GetChildren()) do
		process(child)
	end
end

----------------------------------------------------------------
-- RUN
----------------------------------------------------------------
print("========================================")
print("Starting huge CoreGui styler...")
print("========================================")

process(CoreGui)

print("========================================")
print("Finished!")
print("Total GuiObjects processed:", processed)
print("Blue elements converted to green:", blueConverted)
print("UICorners forced to 8:", cornersAdded)
print("========================================")
