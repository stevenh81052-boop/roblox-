-- Game Logic Script
-- This script manages the game state, including player spawning, win/loss conditions, and UI messages.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Configuration
local INTERMISSION_DURATION = 5

-- Find the goal part
local goal = Workspace:WaitForChild("Goal")

-- Function to show a message to all players
local function showMessage(message, duration)
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "ShowMessageEvent"
    remoteEvent.Parent = ReplicatedStorage

    remoteEvent:FireAllClients(message, duration)

    wait(duration)
    remoteEvent:Destroy()
end

-- Function to handle player win
local function onPlayerWin(player)
    showMessage(player.Name .. " has escaped!", INTERMISSION_DURATION)
    player:LoadCharacter()
end

-- Function to handle player death
local function onPlayerDied(player)
    showMessage(player.Name .. " was caught by the pig!", INTERMISSION_DURATION)
end

-- Connect to the goal part's Touched event
goal.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        onPlayerWin(player)
    end
end)

-- Connect to player added and character added events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            onPlayerDied(player)
        end)
    end)
end)

-- LocalScript to be placed in StarterPlayerScripts to handle the UI
local localScript = [[
-- LocalScript for UI
-- This script should be placed in StarterPlayer.StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function showMessage(message, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MessageGui"
    screenGui.Parent = game.Players.LocalPlayer.PlayerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 100)
    textLabel.Position = UDim2.new(0, 0, 0.5, -50)
    textLabel.Text = message
    textLabel.FontSize = Enum.FontSize.Size48
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.Parent = screenGui

    wait(duration)
    screenGui:Destroy()
end

local remoteEvent = ReplicatedStorage:WaitForChild("ShowMessageEvent")
remoteEvent.OnClientEvent:Connect(showMessage)
]]

-- This is a server script, so we can't create a LocalScript directly.
-- The user will have to create a LocalScript in StarterPlayer.StarterPlayerScripts
-- and paste the content of the `localScript` variable into it.
-- I will add this to the README.md file.

print("Game logic script loaded.")
