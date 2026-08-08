-- Find anything blue in CoreGui → turn it green

local CoreGui = game:GetService("CoreGui")

local GREEN = Color3.fromRGB(0, 170, 80) -- Roblox Play green

local function isBlue(color)
	local r, g, b = color.R, color.G, color.B
	return b > 0.4 and b > r + 0.1 and b > g + 0.1
end

local function process(inst)
	if inst:IsA("GuiObject") then
		-- BackgroundColor3
		if isBlue(inst.BackgroundColor3) then
			inst.BackgroundColor3 = GREEN
			print("Changed BackgroundColor3:", inst:GetFullName())
		end

		-- ImageColor3
		if (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and isBlue(inst.ImageColor3) then
			inst.ImageColor3 = GREEN
			print("Changed ImageColor3:", inst:GetFullName())
		end

		-- Remove gradient if it exists so the new color shows
		local gradient = inst:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient:Destroy()
		end
	end

	for _, child in ipairs(inst:GetChildren()) do
		process(child)
	end
end

process(CoreGui)
print("Done — all blue elements turned green")
