-- Game Logic Script
-- This script manages the game state, including role selection, round management, and win conditions.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local CharacterManager = require(ServerScriptService:WaitForChild("CharacterManager"))
local Menu = require(ServerScriptService:WaitForChild("Menu"))

-- Configuration
local INTERMISSION_DURATION = 10
local MIN_PLAYERS_TO_START = 2

-- Game State
local gameInProgress = false
local survivors = {}
local killer = nil
local escapedSurvivors = {}

-- Function to show a message to all players
local function showMessage(message, duration)
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = "ShowMessageEvent"
    remoteEvent.Parent = ReplicatedStorage

    remoteEvent:FireAllClients(message, duration)

    wait(duration)
    remoteEvent:Destroy()
end

-- Function to handle player death
local function checkWinConditions()
    if not gameInProgress then return end

    -- Killer wins if all survivors are eliminated (none escaped, none left)
    if #survivors == 0 and #escapedSurvivors == 0 then
        showMessage("The Killer wins! All survivors have been eliminated.", INTERMISSION_DURATION)
        gameInProgress = false
    -- Survivors win if all remaining survivors have escaped
    elseif #survivors == 0 and #escapedSurvivors > 0 then
        showMessage("The Survivors win! They have escaped the maze.", INTERMISSION_DURATION)
        gameInProgress = false
    end
end

local function onPlayerDied(player)
    local foundSurvivor = table.find(survivors, player)
    if foundSurvivor then
        table.remove(survivors, foundSurvivor)
        showMessage(player.Name .. " has been eliminated!", 3)
        checkWinConditions()
    end
end

-- Function to start a new round
local function startRound()
    gameInProgress = true
    survivors = {}
    killer = nil
    escapedSurvivors = {}

    local playerList = Players:GetPlayers()
    if #playerList < MIN_PLAYERS_TO_START then
        showMessage("Not enough players to start.", INTERMISSION_DURATION)
        gameInProgress = false
        return
    end

    -- Assign roles
    local randomPlayerIndex = math.random(1, #playerList)
    killer = playerList[randomPlayerIndex]

    for _, player in ipairs(playerList) do
        if player == killer then
            player:SetAttribute("Role", "Killer")
            CharacterManager.equipKiller(player, "1x1x1x1")
            showMessage(player.Name .. " is the Killer!", 3)
        else
            table.insert(survivors, player)
            player:SetAttribute("Role", "Survivor")
            CharacterManager.equipSurvivor(player, "Rig")
        end
        player:LoadCharacter()
        -- Create the UI after the character is loaded to ensure attributes are set
        task.wait(1) -- Give a brief moment for character to load
        Menu.createRoleUI(player)
    end
end

-- Connect to player added and character added events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            onPlayerDied(player)
        end)
    end)

    if not gameInProgress then
        startRound()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player == killer then
        showMessage("The Killer has left. The survivors win!", INTERMISSION_DURATION)
        gameInProgress = false
        -- End round logic here
    elseif table.find(survivors, player) then
        onPlayerDied(player)
    end
end)

-- Handle survivor escape
local goal = game.Workspace:WaitForChild("Goal")
goal.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if player and table.find(survivors, player) then
        -- Remove from active survivors
        table.remove(survivors, table.find(survivors, player))
        -- Add to escaped list
        table.insert(escapedSurvivors, player)

        showMessage(player.Name .. " has escaped!", 3)
        player:LoadCharacter() -- Respawn them in a lobby area, for example

        checkWinConditions()
    end
end)

-- Main game loop
while true do
    if not gameInProgress and #Players:GetPlayers() >= MIN_PLAYERS_TO_START then
        showMessage("A new round will begin shortly...", INTERMISSION_DURATION)
        wait(INTERMISSION_DURATION)
        startRound()
    end
    wait(1)
end

-- LocalScript for UI messages (to be placed in StarterPlayerScripts)
-- This part remains the same as it's a good way to handle UI.
-- The user should ensure this LocalScript is in place as per the README.
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

print("Game logic script for DBD-style game loaded.")
