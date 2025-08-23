-- SurvivorControls.lua
-- This LocalScript handles survivor-specific controls and UI.

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Wait for the event to be created by the server
local placeWallEvent = ReplicatedStorage:WaitForChild("PlaceWallEvent")

-- Create the Ability UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SurvivorAbilityGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local wallAbilityFrame = Instance.new("Frame")
wallAbilityFrame.Name = "WallAbilityFrame"
wallAbilityFrame.Size = UDim2.new(0, 80, 0, 100)
wallAbilityFrame.Position = UDim2.new(0.5, -40, 1, -120) -- Bottom center of the screen
wallAbilityFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
wallAbilityFrame.BackgroundTransparency = 0.5
wallAbilityFrame.BorderSizePixel = 0
wallAbilityFrame.Parent = screenGui

local wallAbilityIcon = Instance.new("TextLabel")
wallAbilityIcon.Name = "Icon"
wallAbilityIcon.Size = UDim2.new(1, 0, 0.7, 0)
wallAbilityIcon.Text = "WALL"
wallAbilityIcon.TextColor3 = Color3.new(0.5, 0.8, 1)
wallAbilityIcon.BackgroundColor3 = Color3.new(0, 0, 0)
wallAbilityIcon.BackgroundTransparency = 0.3
wallAbilityIcon.Parent = wallAbilityFrame

local wallAbilityKey = Instance.new("TextLabel")
wallAbilityKey.Name = "Key"
wallAbilityKey.Size = UDim2.new(1, 0, 0.3, 0)
wallAbilityKey.Position = UDim2.new(0, 0, 0.7, 0)
wallAbilityKey.Text = "[E]"
wallAbilityKey.TextColor3 = Color3.new(1, 1, 1)
wallAbilityKey.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
wallAbilityKey.BackgroundTransparency = 0.3
wallAbilityKey.Parent = wallAbilityFrame


-- Handle Input
local function onInputBegan(input, gameProcessedEvent)
    -- Ignore input if the user is typing in chat
    if gameProcessedEvent then
        return
    end

    if input.KeyCode == Enum.KeyCode.E then
        -- Fire the remote event to the server
        placeWallEvent:FireServer()
    end
end

-- Connect the function to the InputBegan event
UserInputService.InputBegan:Connect(onInputBegan)

print("Survivor controls loaded.")
