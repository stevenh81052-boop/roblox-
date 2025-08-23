-- This script creates the role selection menu.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- This script should be placed in StarterPlayer.StarterPlayerScripts

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoleSelectionGui"
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a frame to hold the buttons
local frame = Instance.new("Frame")
frame.Name = "RoleSelectionFrame"
frame.Size = UDim2.new(0.5, 0, 0.5, 0)
frame.Position = UDim2.new(0.25, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Create the "Survivors" button
local survivorButton = Instance.new("TextButton")
survivorButton.Name = "SurvivorButton"
survivorButton.Size = UDim2.new(0.4, 0, 0.8, 0)
survivorButton.Position = UDim2.new(0.05, 0, 0.1, 0)
survivorButton.Text = "Survivors"
survivorButton.FontSize = Enum.FontSize.Size32
survivorButton.TextColor3 = Color3.new(1, 1, 1)
survivorButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
survivorButton.Parent = frame

-- Create the "Killer" button
local killerButton = Instance.new("TextButton")
killerButton.Name = "KillerButton"
killerButton.Size = UDim2.new(0.4, 0, 0.8, 0)
killerButton.Position = UDim2.new(0.55, 0, 0.1, 0)
killerButton.Text = "Killer"
killerButton.FontSize = Enum.FontSize.Size32
killerButton.TextColor3 = Color3.new(1, 1, 1)
killerButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
killerButton.Parent = frame

-- Create RemoteEvents for role selection
local survivorEvent = Instance.new("RemoteEvent")
survivorEvent.Name = "SurvivorChosen"
survivorEvent.Parent = ReplicatedStorage

local killerEvent = Instance.new("RemoteEvent")
killerEvent.Name = "KillerChosen"
killerEvent.Parent = ReplicatedStorage

-- Function to handle survivor button click
local function onSurvivorClicked()
    survivorEvent:FireServer()
    screenGui:Destroy()
end

-- Function to handle killer button click
local function onKillerClicked()
    killerEvent:FireServer()
    screenGui:Destroy()
end

-- Connect the button clicks to the functions
survivorButton.MouseButton1Click:Connect(onSurvivorClicked)
killerButton.MouseButton1Click:Connect(onKillerClicked)

print("Role selection UI created.")
