-- LocalScript / Executor script

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SAVE_FILE = "CoreGuiConfig.json"

--// Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreGuiEditor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

--// Main Frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0.55, 0, 0.7, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(204, 127, 0)
mainStroke.Thickness = 2
mainStroke.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.BorderSizePixel = 0
title.Text = "CoreGui Editor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Left side: Instance List
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "InstanceList"
listFrame.Size = UDim2.new(0.42, -10, 1, -90)
listFrame.Position = UDim2.new(0, 10, 0, 46)
listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.Parent = main

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = listFrame

-- Right side: Properties
local propFrame = Instance.new("Frame")
propFrame.Name = "Properties"
propFrame.Size = UDim2.new(0.55, -15, 1, -90)
propFrame.Position = UDim2.new(0.45, 5, 0, 46)
propFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
propFrame.BorderSizePixel = 0
propFrame.Parent = main

local propCorner = Instance.new("UICorner")
propCorner.CornerRadius = UDim.new(0, 6)
propCorner.Parent = propFrame

local propTitle = Instance.new("TextLabel")
propTitle.Size = UDim2.new(1, 0, 0, 30)
propTitle.BackgroundTransparency = 1
propTitle.Text = "Select an instance"
propTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
propTitle.Font = Enum.Font.Gotham
propTitle.TextSize = 14
propTitle.Parent = propFrame

-- Buttons
local function createButton(text, pos, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.22, 0, 0, 32)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn
	return btn
end

local saveBtn = createButton("Save", UDim2.new(0.05, 0, 1, -42), Color3.fromRGB(40, 120, 40))
local loadBtn = createButton("Load", UDim2.new(0.29, 0, 1, -42), Color3.fromRGB(40, 80, 140))
local refreshBtn = createButton("Refresh", UDim2.new(0.53, 0, 1, -42), Color3.fromRGB(120, 80, 30))
local closeBtn = createButton("Close", UDim2.new(0.77, 0, 1, -42), Color3.fromRGB(140, 40, 40))

--// State
local selectedInstance = nil
local propertyBoxes = {}

-- Clear property editors
local function clearProperties()
	for _, box in pairs(propertyBoxes) do
		box:Destroy()
	end
	propertyBoxes = {}
	propTitle.Text = "Select an instance"
end

-- Create a property editor row
local function addProperty(name, value, onChange)
	local y = 40 + (#propertyBoxes * 36)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, -8, 0, 28)
	label.Position = UDim2.new(0, 8, 0, y)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = propFrame
	table.insert(propertyBoxes, label)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.55, -8, 0, 28)
	box.Position = UDim2.new(0.42, 0, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.BorderSizePixel = 0
	box.Text = tostring(value)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = propFrame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 4)
	boxCorner.Parent = box

	box.FocusLost:Connect(function(enter)
		if enter or true then
			onChange(box.Text)
		end
	end)

	table.insert(propertyBoxes, box)
end

-- Show properties of selected instance
local function showProperties(inst)
	clearProperties()
	selectedInstance = inst
	propTitle.Text = inst:GetFullName()

	-- Enabled
	if inst:IsA("ScreenGui") or inst:IsA("GuiObject") or inst:IsA("LayerCollector") then
		pcall(function()
			addProperty("Enabled", inst.Enabled, function(val)
				local v = val:lower()
				inst.Enabled = (v == "true" or v == "1")
			end)
		end)
	end

	-- Visible
	if inst:IsA("GuiObject") then
		pcall(function()
			addProperty("Visible", inst.Visible, function(val)
				local v = val:lower()
				inst.Visible = (v == "true" or v == "1")
			end)
		end)
	end

	-- BackgroundTransparency
	if inst:IsA("GuiObject") then
		pcall(function()
			addProperty("BackgroundTransparency", inst.BackgroundTransparency, function(val)
				local num = tonumber(val)
				if num then inst.BackgroundTransparency = math.clamp(num, 0, 1) end
			end)
		end)
	end

	-- BackgroundColor3 (simple RGB string)
	if inst:IsA("GuiObject") then
		pcall(function()
			local c = inst.BackgroundColor3
			addProperty("BackgroundColor3", string.format("%.0f,%.0f,%.0f", c.R*255, c.G*255, c.B*255), function(val)
				local r, g, b = val:match("(%d+),(%d+),(%d+)")
				if r and g and b then
					inst.BackgroundColor3 = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
				end
			end)
		end)
	end
end

-- Populate the instance list
local function refreshList()
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local count = 0
	for _, child in ipairs(CoreGui:GetChildren()) do
		count += 1
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.BorderSizePixel = 0
		btn.Text = child.Name .. "  (" .. child.ClassName .. ")"
		btn.TextColor3 = Color3.fromRGB(230, 230, 230)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = listFrame

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 4)
		c.Parent = btn

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 8)
		pad.Parent = btn

		btn.MouseButton1Click:Connect(function()
			showProperties(child)
		end)
	end

	listFrame.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

-- Save current CoreGui state
local function saveConfig()
	local data = {}

	for _, child in ipairs(CoreGui:GetChildren()) do
		local entry = {
			Name = child.Name,
			ClassName = child.ClassName
		}

		pcall(function()
			if child:IsA("ScreenGui") or child:IsA("LayerCollector") then
				entry.Enabled = child.Enabled
			end
			if child:IsA("GuiObject") then
				entry.Visible = child.Visible
				entry.BackgroundTransparency = child.BackgroundTransparency
				local c = child.BackgroundColor3
				entry.BackgroundColor3 = {R = c.R, G = c.G, B = c.B}
			end
		end)

		table.insert(data, entry)
	end

	local json = HttpService:JSONEncode(data)
	writefile(SAVE_FILE, json)
	print("CoreGui config saved to", SAVE_FILE)
end

-- Load and apply config
local function loadConfig()
	if not isfile(SAVE_FILE) then
		warn("No save file found:", SAVE_FILE)
		return
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(SAVE_FILE))
	end)

	if not success or type(data) ~= "table" then
		warn("Failed to load config")
		return
	end

	for _, entry in ipairs(data) do
		local inst = CoreGui:FindFirstChild(entry.Name)
		if inst then
			pcall(function()
				if entry.Enabled ~= nil and (inst:IsA("ScreenGui") or inst:IsA("LayerCollector")) then
					inst.Enabled = entry.Enabled
				end
				if entry.Visible ~= nil and inst:IsA("GuiObject") then
					inst.Visible = entry.Visible
				end
				if entry.BackgroundTransparency ~= nil and inst:IsA("GuiObject") then
					inst.BackgroundTransparency = entry.BackgroundTransparency
				end
				if entry.BackgroundColor3 and inst:IsA("GuiObject") then
					local c = entry.BackgroundColor3
					inst.BackgroundColor3 = Color3.new(c.R, c.G, c.B)
				end
			end)
		end
	end

	print("CoreGui config loaded")
	refreshList()
end

-- Button connections
saveBtn.MouseButton1Click:Connect(saveConfig)
loadBtn.MouseButton1Click:Connect(loadConfig)
refreshBtn.MouseButton1Click:Connect(refreshList)
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Make main frame draggable
do
	local dragging, dragInput, dragStart, startPos

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

	main.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Init
refreshList()
print("CoreGui Editor loaded")
