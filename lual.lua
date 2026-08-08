-- Put this inside a LocalScript placed directly under StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoolTextScreenGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- 2. Input Container (classic dark panel)
local inputContainer = Instance.new("Frame")
inputContainer.Name = "InputContainer"
inputContainer.Size = UDim2.new(0, 420, 0, 52)
inputContainer.Position = UDim2.new(0.5, -210, 0.42, -26)
inputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inputContainer.BorderSizePixel = 0
inputContainer.Parent = screenGui

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputContainer

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(204, 127, 0)
inputStroke.Thickness = 2
inputStroke.Parent = inputContainer

local textBox = Instance.new("TextBox")
textBox.Name = "UserMessageInput"
textBox.Size = UDim2.new(1, -24, 1, -12)
textBox.Position = UDim2.new(0, 12, 0, 6)
textBox.BackgroundTransparency = 1
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextSize = 18
textBox.Font = Enum.Font.Gotham
textBox.PlaceholderText = "Type a cool message and press Enter..."
textBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
textBox.ClearTextOnFocus = true
textBox.Text = ""
textBox.Parent = inputContainer

-- 3. Display Frame (the message that pops up)
local displayFrame = Instance.new("Frame")
displayFrame.Name = "DisplayFrame"
displayFrame.Size = UDim2.new(0, 520, 0, 90)
displayFrame.Position = UDim2.new(0.5, -260, 0.18, -45)
displayFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
displayFrame.BackgroundTransparency = 1
displayFrame.BorderSizePixel = 0
displayFrame.Visible = false
displayFrame.Parent = screenGui

local displayCorner = Instance.new("UICorner")
displayCorner.CornerRadius = UDim.new(0, 10)
displayCorner.Parent = displayFrame

local displayStroke = Instance.new("UIStroke")
displayStroke.Color = Color3.fromRGB(204, 127, 0)
displayStroke.Thickness = 2.5
displayStroke.Transparency = 1
displayStroke.Parent = displayFrame

-- Classic orange gradient (2018 style)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(204, 127, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 60, 0))
})
uiGradient.Rotation = 90
uiGradient.Parent = displayFrame

local textLabel = Instance.new("TextLabel")
textLabel.Name = "FadeTextLabel"
textLabel.Size = UDim2.new(1, -40, 1, -24)
textLabel.Position = UDim2.new(0, 20, 0, 12)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 28
textLabel.TextScaled = true
textLabel.TextWrapped = true
textLabel.TextTransparency = 1
textLabel.Parent = displayFrame

-- 4. Animation settings
local tweenInfoIn = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoOut = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local isShowing = false

-- 5. Display function
local function displayCustomMessage(messageText)
	if isShowing then return end
	isShowing = true

	textLabel.Text = messageText
	displayFrame.Visible = true

	-- Start collapsed
	displayFrame.Size = UDim2.new(0, 520, 0, 0)
	displayFrame.BackgroundTransparency = 1
	displayStroke.Transparency = 1
	textLabel.TextTransparency = 1

	-- Entry
	local frameIn = TweenService:Create(displayFrame, tweenInfoIn, {
		Size = UDim2.new(0, 520, 0, 90),
		BackgroundTransparency = 0.15
	})
	local strokeIn = TweenService:Create(displayStroke, tweenInfoIn, {
		Transparency = 0
	})
	local textIn = TweenService:Create(textLabel, tweenInfoIn, {
		TextTransparency = 0
	})

	frameIn:Play()
	strokeIn:Play()
	task.wait(0.08)
	textIn:Play()
	textIn.Completed:Wait()

	-- Hold for 10 seconds
	task.wait(10)

	-- Exit
	local textOut = TweenService:Create(textLabel, tweenInfoOut, {
		TextTransparency = 1
	})
	local strokeOut = TweenService:Create(displayStroke, tweenInfoOut, {
		Transparency = 1
	})
	local frameOut = TweenService:Create(displayFrame, tweenInfoOut, {
		Size = UDim2.new(0, 520, 0, 0),
		BackgroundTransparency = 1
	})

	textOut:Play()
	task.wait(0.08)
	strokeOut:Play()
	frameOut:Play()
	frameOut.Completed:Wait()

	displayFrame.Visible = false
	inputContainer.Visible = true
	isShowing = false
end

-- 6. Input trigger
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed and textBox.Text ~= "" and not isShowing then
		local userInput = textBox.Text
		textBox.Text = ""
		inputContainer.Visible = false

		task.spawn(function()
			displayCustomMessage(userInput)
		end)
	end
end)
