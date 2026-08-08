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
-- Change blue Resume button → Roblox Play Button Green

local CoreGui = game:GetService("CoreGui")

local PLAY_GREEN = Color3.fromRGB(0, 170, 80) -- Classic Roblox Play green

local function forceGreen(inst)
	pcall(function()
		if inst:IsA("GuiObject") then
			inst.BackgroundColor3 = PLAY_GREEN
		end
		if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
			inst.ImageColor3 = PLAY_GREEN
		end
		if inst:IsA("TextButton") or inst:IsA("TextLabel") then
			inst.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		-- Remove gradient so the color actually shows
		local gradient = inst:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient:Destroy()
		end
	end)
end

local function process(inst)
	local name = inst.Name:lower()

	if name:find("resume") or name:find("play") or name:find("continue") then
		forceGreen(inst)
		print("✅ Changed to Play green:", inst:GetFullName())
	end

	-- Also catch remaining blue buttons
	if inst:IsA("GuiObject") then
		local c = inst.BackgroundColor3
		if c.B > 0.45 and c.B > c.R + 0.15 and c.B > c.G + 0.15 then
			forceGreen(inst)
			print("✅ Changed blue button to green:", inst:GetFullName())
		end
	end

	for _, child in ipairs(inst:GetChildren()) do
		process(child)
	end
end

process(CoreGui)
print("Done — Resume button is now Roblox Play green")

print("✅ Finished — UICorner 8 + brighter Backpack color applied to entire CoreGui")
