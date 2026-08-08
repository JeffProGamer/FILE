-- CoreGui Editor (Advanced)
-- Supports ScreenGui + GuiObject properties like a real editor

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SAVE_FILE = "CoreGuiConfig.json"

--// UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreGuiEditor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0.62, 0, 0.78, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(204, 127, 0)
stroke.Thickness = 2
stroke.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
title.BorderSizePixel = 0
title.Text = "CoreGui Editor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Left List
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(0.38, -12, 1, -100)
listFrame.Position = UDim2.new(0, 10, 0, 48)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 5
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.Parent = main
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = listFrame

-- Right Properties
local propFrame = Instance.new("ScrollingFrame")
propFrame.Size = UDim2.new(0.59, -18, 1, -100)
propFrame.Position = UDim2.new(0.4, 6, 0, 48)
propFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
propFrame.BorderSizePixel = 0
propFrame.ScrollBarThickness = 5
propFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
propFrame.Parent = main
Instance.new("UICorner", propFrame).CornerRadius = UDim.new(0, 6)

local propLayout = Instance.new("UIListLayout")
propLayout.Padding = UDim.new(0, 6)
propLayout.Parent = propFrame

local propTitle = Instance.new("TextLabel")
propTitle.Size = UDim2.new(1, -10, 0, 28)
propTitle.BackgroundTransparency = 1
propTitle.Text = "Select an instance"
propTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
propTitle.Font = Enum.Font.Gotham
propTitle.TextSize = 14
propTitle.TextXAlignment = Enum.TextXAlignment.Left
propTitle.Parent = propFrame

-- Buttons
local function makeBtn(text, xScale, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.2, 0, 0, 34)
	b.Position = UDim2.new(xScale, 0, 1, -46)
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Parent = main
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local saveBtn = makeBtn("Save", 0.04, Color3.fromRGB(35, 130, 45))
local loadBtn = makeBtn("Load", 0.27, Color3.fromRGB(35, 90, 160))
local refreshBtn = makeBtn("Refresh", 0.5, Color3.fromRGB(140, 90, 30))
local closeBtn = makeBtn("Close", 0.73, Color3.fromRGB(150, 40, 40))

--// Helpers
local selected = nil
local propObjects = {}

local function clearProps()
	for _, v in ipairs(propObjects) do
		v:Destroy()
	end
	propObjects = {}
	propTitle.Text = "Select an instance"
	propFrame.CanvasSize = UDim2.new(0, 0, 0, 40)
end

local function addProp(name, currentValue, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -12, 0, 32)
	row.BackgroundTransparency = 1
	row.Parent = propFrame
	table.insert(propObjects, row)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.38, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	box.BorderSizePixel = 0
	box.Text = tostring(currentValue)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	box.FocusLost:Connect(function()
		callback(box.Text)
	end)
end

local function colorToString(c)
	return string.format("%.0f, %.0f, %.0f", c.R*255, c.G*255, c.B*255)
end

local function stringToColor(str)
	local r, g, b = str:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
	if r then return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
end

local function udim2ToString(u)
	return string.format("%.3f, %d, %.3f, %d", u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset)
end

local function stringToUDim2(str)
	local xs, xo, ys, yo = str:match("([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)")
	if xs then
		return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
	end
end

local function vector2ToString(v)
	return string.format("%.3f, %.3f", v.X, v.Y)
end

local function stringToVector2(str)
	local x, y = str:match("([%d%.%-]+)%s*,%s*([%d%.%-]+)")
	if x then return Vector2.new(tonumber(x), tonumber(y)) end
end

-- Show all useful properties
local function showProperties(inst)
	clearProps()
	selected = inst
	propTitle.Text = inst:GetFullName()

	-- ===== ScreenGui / LayerCollector =====
	if inst:IsA("ScreenGui") or inst:IsA("LayerCollector") then
		pcall(function()
			addProp("Enabled", inst.Enabled, function(v)
				inst.Enabled = (v:lower() == "true" or v == "1")
			end)
			addProp("DisplayOrder", inst.DisplayOrder, function(v)
				local n = tonumber(v)
				if n then inst.DisplayOrder = n end
			end)
			addProp("IgnoreGuiInset", inst.IgnoreGuiInset, function(v)
				inst.IgnoreGuiInset = (v:lower() == "true" or v == "1")
			end)
			addProp("ResetOnSpawn", inst.ResetOnSpawn, function(v)
				inst.ResetOnSpawn = (v:lower() == "true" or v == "1")
			end)
			addProp("ZIndexBehavior", tostring(inst.ZIndexBehavior), function(v)
				local ok, enum = pcall(function() return Enum.ZIndexBehavior[v] end)
				if ok and enum then inst.ZIndexBehavior = enum end
			end)
		end)
	end

	-- ===== GuiObject =====
	if inst:IsA("GuiObject") then
		pcall(function()
			addProp("Visible", inst.Visible, function(v)
				inst.Visible = (v:lower() == "true" or v == "1")
			end)
			addProp("Position", udim2ToString(inst.Position), function(v)
				local u = stringToUDim2(v)
				if u then inst.Position = u end
			end)
			addProp("Size", udim2ToString(inst.Size), function(v)
				local u = stringToUDim2(v)
				if u then inst.Size = u end
			end)
			addProp("AnchorPoint", vector2ToString(inst.AnchorPoint), function(v)
				local vec = stringToVector2(v)
				if vec then inst.AnchorPoint = vec end
			end)
			addProp("BackgroundColor3", colorToString(inst.BackgroundColor3), function(v)
				local c = stringToColor(v)
				if c then inst.BackgroundColor3 = c end
			end)
			addProp("BackgroundTransparency", inst.BackgroundTransparency, function(v)
				local n = tonumber(v)
				if n then inst.BackgroundTransparency = math.clamp(n, 0, 1) end
			end)
			addProp("BorderSizePixel", inst.BorderSizePixel, function(v)
				local n = tonumber(v)
				if n then inst.BorderSizePixel = n end
			end)
			addProp("BorderColor3", colorToString(inst.BorderColor3), function(v)
				local c = stringToColor(v)
				if c then inst.BorderColor3 = c end
			end)
			addProp("Rotation", inst.Rotation, function(v)
				local n = tonumber(v)
				if n then inst.Rotation = n end
			end)
			addProp("ZIndex", inst.ZIndex, function(v)
				local n = tonumber(v)
				if n then inst.ZIndex = n end
			end)
			addProp("ClipsDescendants", inst.ClipsDescendants, function(v)
				inst.ClipsDescendants = (v:lower() == "true" or v == "1")
			end)
			addProp("Active", inst.Active, function(v)
				inst.Active = (v:lower() == "true" or v == "1")
			end)
		end)
	end

	-- ===== Text Objects =====
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		pcall(function()
			addProp("Text", inst.Text, function(v) inst.Text = v end)
			addProp("TextColor3", colorToString(inst.TextColor3), function(v)
				local c = stringToColor(v)
				if c then inst.TextColor3 = c end
			end)
			addProp("TextSize", inst.TextSize, function(v)
				local n = tonumber(v)
				if n then inst.TextSize = n end
			end)
			addProp("Font", tostring(inst.Font):gsub("Enum.Font.", ""), function(v)
				local ok, f = pcall(function() return Enum.Font[v] end)
				if ok and f then inst.Font = f end
			end)
			addProp("TextTransparency", inst.TextTransparency, function(v)
				local n = tonumber(v)
				if n then inst.TextTransparency = math.clamp(n, 0, 1) end
			end)
			addProp("TextXAlignment", tostring(inst.TextXAlignment):gsub("Enum.TextXAlignment.", ""), function(v)
				local ok, e = pcall(function() return Enum.TextXAlignment[v] end)
				if ok and e then inst.TextXAlignment = e end
			end)
			addProp("TextYAlignment", tostring(inst.TextYAlignment):gsub("Enum.TextYAlignment.", ""), function(v)
				local ok, e = pcall(function() return Enum.TextYAlignment[v] end)
				if ok and e then inst.TextYAlignment = e end
			end)
			addProp("TextWrapped", inst.TextWrapped, function(v)
				inst.TextWrapped = (v:lower() == "true" or v == "1")
			end)
			addProp("TextScaled", inst.TextScaled, function(v)
				inst.TextScaled = (v:lower() == "true" or v == "1")
			end)
		end)
	end

	-- Update canvas size
	task.wait()
	propFrame.CanvasSize = UDim2.new(0, 0, 0, propLayout.AbsoluteContentSize.Y + 20)
end

-- List population (shows hierarchy with indentation)
local function addToList(inst, depth)
	depth = depth or 0
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 26)
	btn.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	btn.BorderSizePixel = 0
	btn.Text = string.rep("  ", depth) .. inst.Name .. "  [" .. inst.ClassName .. "]"
	btn.TextColor3 = Color3.fromRGB(225, 225, 225)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = listFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	btn.MouseButton1Click:Connect(function()
		showProperties(inst)
	end)

	for _, child in ipairs(inst:GetChildren()) do
		if child:IsA("GuiObject") or child:IsA("ScreenGui") or child:IsA("Folder") or child:IsA("Frame") then
			addToList(child, depth + 1)
		end
	end
end

local function refreshList()
	for _, c in ipairs(listFrame:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end

	for _, child in ipairs(CoreGui:GetChildren()) do
		addToList(child, 0)
	end

	task.wait()
	listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Save / Load (saves more properties)
local function saveConfig()
	local data = {}

	local function serialize(inst)
		local entry = {
			Name = inst.Name,
			ClassName = inst.ClassName,
			Path = inst:GetFullName()
		}

		pcall(function()
			if inst:IsA("ScreenGui") or inst:IsA("LayerCollector") then
				entry.Enabled = inst.Enabled
				entry.DisplayOrder = inst.DisplayOrder
				entry.IgnoreGuiInset = inst.IgnoreGuiInset
				entry.ResetOnSpawn = inst.ResetOnSpawn
			end
			if inst:IsA("GuiObject") then
				entry.Visible = inst.Visible
				entry.Position = {inst.Position.X.Scale, inst.Position.X.Offset, inst.Position.Y.Scale, inst.Position.Y.Offset}
				entry.Size = {inst.Size.X.Scale, inst.Size.X.Offset, inst.Size.Y.Scale, inst.Size.Y.Offset}
				entry.AnchorPoint = {inst.AnchorPoint.X, inst.AnchorPoint.Y}
				entry.BackgroundColor3 = {inst.BackgroundColor3.R, inst.BackgroundColor3.G, inst.BackgroundColor3.B}
				entry.BackgroundTransparency = inst.BackgroundTransparency
				entry.BorderSizePixel = inst.BorderSizePixel
				entry.Rotation = inst.Rotation
				entry.ZIndex = inst.ZIndex
				entry.ClipsDescendants = inst.ClipsDescendants
				entry.Active = inst.Active
			end
			if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
				entry.Text = inst.Text
				entry.TextColor3 = {inst.TextColor3.R, inst.TextColor3.G, inst.TextColor3.B}
				entry.TextSize = inst.TextSize
				entry.TextTransparency = inst.TextTransparency
				entry.TextWrapped = inst.TextWrapped
				entry.TextScaled = inst.TextScaled
			end
		end)

		table.insert(data, entry)

		for _, child in ipairs(inst:GetChildren()) do
			if child:IsA("GuiObject") or child:IsA("ScreenGui") then
				serialize(child)
			end
		end
	end

	for _, child in ipairs(CoreGui:GetChildren()) do
		serialize(child)
	end

	writefile(SAVE_FILE, HttpService:JSONEncode(data))
	print("✅ Saved CoreGui config")
end

local function loadConfig()
	if not isfile(SAVE_FILE) then
		warn("No save file found")
		return
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(SAVE_FILE))
	end)
	if not ok or type(data) ~= "table" then return end

	for _, entry in ipairs(data) do
		-- Try to find by name first (top level) or full path
		local inst = CoreGui:FindFirstChild(entry.Name)
		if not inst then
			-- very simple path fallback
			local parts = string.split(entry.Path or "", ".")
			inst = CoreGui
			for i = 2, #parts do
				inst = inst and inst:FindFirstChild(parts[i])
			end
		end

		if inst then
			pcall(function()
				if entry.Enabled ~= nil then inst.Enabled = entry.Enabled end
				if entry.Visible ~= nil then inst.Visible = entry.Visible end
				if entry.DisplayOrder ~= nil then inst.DisplayOrder = entry.DisplayOrder end
				if entry.IgnoreGuiInset ~= nil then inst.IgnoreGuiInset = entry.IgnoreGuiInset end
				if entry.BackgroundTransparency ~= nil then inst.BackgroundTransparency = entry.BackgroundTransparency end
				if entry.BorderSizePixel ~= nil then inst.BorderSizePixel = entry.BorderSizePixel end
				if entry.Rotation ~= nil then inst.Rotation = entry.Rotation end
				if entry.ZIndex ~= nil then inst.ZIndex = entry.ZIndex end
				if entry.ClipsDescendants ~= nil then inst.ClipsDescendants = entry.ClipsDescendants end
				if entry.Active ~= nil then inst.Active = entry.Active end
				if entry.Text ~= nil then inst.Text = entry.Text end
				if entry.TextSize ~= nil then inst.TextSize = entry.TextSize end
				if entry.TextTransparency ~= nil then inst.TextTransparency = entry.TextTransparency end
				if entry.TextWrapped ~= nil then inst.TextWrapped = entry.TextWrapped end
				if entry.TextScaled ~= nil then inst.TextScaled = entry.TextScaled end

				if entry.Position then
					inst.Position = UDim2.new(entry.Position[1], entry.Position[2], entry.Position[3], entry.Position[4])
				end
				if entry.Size then
					inst.Size = UDim2.new(entry.Size[1], entry.Size[2], entry.Size[3], entry.Size[4])
				end
				if entry.AnchorPoint then
					inst.AnchorPoint = Vector2.new(entry.AnchorPoint[1], entry.AnchorPoint[2])
				end
				if entry.BackgroundColor3 then
					inst.BackgroundColor3 = Color3.new(entry.BackgroundColor3[1], entry.BackgroundColor3[2], entry.BackgroundColor3[3])
				end
				if entry.TextColor3 then
					inst.TextColor3 = Color3.new(entry.TextColor3[1], entry.TextColor3[2], entry.TextColor3[3])
				end
			end)
		end
	end

	print("✅ Loaded CoreGui config")
	refreshList()
end

-- Connections
saveBtn.MouseButton1Click:Connect(saveConfig)
loadBtn.MouseButton1Click:Connect(loadConfig)
refreshBtn.MouseButton1Click:Connect(refreshList)
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Dragging
do
	local dragging, dragInput, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

refreshList()
print("CoreGui Editor (Advanced) loaded")
