-- Modern → Legacy UI Converter for CoreGui
-- Makes modern CoreGui look like old Roblox (Legacy style)

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Create the converter UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LegacyConverter"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 220)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
main.BorderSizePixel = 1
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.Active = true
main.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.BorderSizePixel = 1
title.BorderColor3 = Color3.fromRGB(0, 0, 0)
title.Text = "Modern → Legacy Converter"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = main

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 70)
info.Position = UDim2.new(0, 10, 0, 45)
info.BackgroundTransparency = 1
info.Text = "This will force CoreGui elements into the old Legacy Roblox style (classic fonts, borders, colors, no rounded corners)."
info.TextColor3 = Color3.fromRGB(220, 220, 220)
info.Font = Enum.Font.SourceSans
info.TextSize = 15
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = main

local convertBtn = Instance.new("TextButton")
convertBtn.Size = UDim2.new(0.8, 0, 0, 36)
convertBtn.Position = UDim2.new(0.1, 0, 0, 125)
convertBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
convertBtn.BorderSizePixel = 1
convertBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
convertBtn.Text = "Convert CoreGui to Legacy"
convertBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
convertBtn.Font = Enum.Font.SourceSansBold
convertBtn.TextSize = 16
convertBtn.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.8, 0, 0, 32)
closeBtn.Position = UDim2.new(0.1, 0, 0, 170)
closeBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
closeBtn.BorderSizePixel = 1
closeBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 15
closeBtn.Parent = main

--// Legacy style applicator
local function applyLegacyStyle(inst)
	-- Remove modern effects
	for _, child in ipairs(inst:GetChildren()) do
		if child:IsA("UICorner") or child:IsA("UIStroke") or child:IsA("UIGradient") or child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	-- ScreenGui / LayerCollector
	if inst:IsA("ScreenGui") or inst:IsA("LayerCollector") then
		pcall(function()
			inst.IgnoreGuiInset = false
		end)
	end

	-- GuiObject base
	if inst:IsA("GuiObject") then
		pcall(function()
			inst.BorderSizePixel = 1
			inst.BorderColor3 = Color3.fromRGB(0, 0, 0)

			-- Classic background colors
			if inst:IsA("Frame") or inst:IsA("ScrollingFrame") then
				if inst.BackgroundTransparency < 1 then
					inst.BackgroundColor3 = Color3.fromRGB(99, 95, 98) -- classic gray
				end
			end
		end)
	end

	-- Text objects → classic fonts + colors
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		pcall(function()
			inst.Font = Enum.Font.SourceSans
			if inst:IsA("TextButton") then
				inst.Font = Enum.Font.SourceSansBold
			end
			inst.TextSize = math.clamp(inst.TextSize, 14, 24)
			inst.TextColor3 = Color3.fromRGB(255, 255, 255)
			inst.TextStrokeTransparency = 1
			inst.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- old blue button color
			if inst:IsA("TextLabel") then
				inst.BackgroundTransparency = 1
			end
		end)
	end

	-- Image objects
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		pcall(function()
			inst.BorderSizePixel = 1
			inst.BorderColor3 = Color3.fromRGB(0, 0, 0)
		end)
	end
end

local function convertAll()
	local count = 0

	local function scan(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ScreenGui") or child:IsA("GuiObject") or child:IsA("Folder") then
				applyLegacyStyle(child)
				count += 1
				scan(child)
			end
		end
	end

	scan(CoreGui)
	print("✅ Converted", count, "instances to Legacy style")
	convertBtn.Text = "Converted!"
	task.wait(1.5)
	convertBtn.Text = "Convert CoreGui to Legacy"
end

-- Connections
convertBtn.MouseButton1Click:Connect(convertAll)
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Simple drag
do
	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

print("Legacy Converter loaded")
