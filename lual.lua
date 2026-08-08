-- Put this inside a LocalScript placed directly under StarterGui
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create the Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoolTextScreenGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Create a sleek TextBox Container (For Input)
local inputContainer = Instance.new("Frame")
inputContainer.Name = "InputContainer"
inputContainer.Size = UDim2.new(0, 400, 0, 50)
inputContainer.Position = UDim2.new(0.5, -200, 0.4, -25)
inputContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
inputContainer.BackgroundTransparency = 0.2
inputContainer.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = inputContainer

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(204, 127, 0)
uiStroke.Thickness = 2
uiStroke.Parent = inputContainer

local textBox = Instance.new("TextBox")
textBox.Name = "UserMessageInput"
textBox.Size = UDim2.new(1, -20, 1, -10)
textBox.Position = UDim2.new(0, 10, 0, 5)
textBox.BackgroundTransparency = 1
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextSize = 18
textBox.Font = Enum.Font.GothamMedium
textBox.PlaceholderText = "Type a cool message and press Enter..."
textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
textBox.ClearTextOnFocus = true
textBox.Parent = inputContainer

-- 3. Create the Animated Display Frame (For Output)
local displayFrame = Instance.new("Frame")
displayFrame.Name = "DisplayFrame"
displayFrame.Size = UDim2.new(0, 500, 0, 80)
displayFrame.Position = UDim2.new(0.5, -250, 0.2, -40)
displayFrame.BackgroundTransparency = 1 -- Controlled by Tweens
displayFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
displayFrame.Visible = false
displayFrame.Parent = screenGui

local displayCorner = Instance.new("UICorner")
displayCorner.CornerRadius = UDim.new(0, 12)
displayCorner.Parent = displayFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorGradient.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(204, 127, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 0))
})
uiGradient.Parent = displayFrame

local textLabel = Instance.new("TextLabel")
textLabel.Name = "FadeTextLabel"
textLabel.Size = UDim2.new(1, -40, 1, -20)
textLabel.Position = UDim2.new(0, 20, 0, 10)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextScaled = true
textLabel.TextTransparency = 1
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.Parent = textLabel
textLabel.Parent = displayFrame

-- 4. Animation Settings
local tweenInfoIn = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- 5. Function to play the cinematic display sequence
local function displayCustomMessage(messageText)
	textLabel.Text = messageText
	displayFrame.Visible = true
	
	-- Setup structural presets before entry animation
	displayFrame.Size = UDim2.new(0, 500, 0, 0)         -- Squished vertically
	displayFrame.BackgroundTransparency = 1            -- Invisible
	textLabel.TextTransparency = 1                     -- Invisible
	
	-- Construct entry animations
	local frameIn = TweenService:Create(displayFrame, tweenInfoIn, {
		Size = UDim2.new(0, 500, 0, 80), 
		BackgroundTransparency = 0.3
	})
	local textIn = TweenService:Create(textLabel, tweenInfoIn, {TextTransparency = 0})
	
	-- Run entry sequence
	frameIn:Play()
	task.wait(0.1) -- Slight delay for staggered text look
	textIn:Play()
	textIn.Completed:Wait()
	
	-- Stay visible for 10 seconds
	task.wait(10)
	
	-- Construct exit animations
	local frameOut = TweenService:Create(displayFrame, tweenInfoOut, {
		Size = UDim2.new(0, 500, 0, 0), 
		BackgroundTransparency = 1
	})
	local textOut = TweenService:Create(textLabel, tweenInfoOut, {TextTransparency = 1})
	
	-- Run exit sequence
	textOut:Play()
	task.wait(0.1)
	frameOut:Play()
	frameOut.Completed:Wait()
	
	-- Cleanup states
	displayFrame.Visible = false
	inputContainer.Visible = true -- Bring back input box for next round
end

-- 6. Connect User input trigger
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed and textBox.Text ~= "" then
		local userInput = textBox.Text
		inputContainer.Visible = false -- Hide input bar while reading
		
		task.spawn(function()
			displayCustomMessage(userInput)
		end)
	end
end)
