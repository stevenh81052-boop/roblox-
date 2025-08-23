-- Game Logic Script
-- This script manages the game state, including player spawning, win/loss conditions, and UI messages.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Configuration
local INTERMISSION_DURATION = 5

-- Teams
local survivors = {}
local killers = {}

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

    -- Check if all survivors have escaped
    local allSurvivorsEscaped = true
    for _, survivor in ipairs(survivors) do
        if survivor.Character and survivor.Character:FindFirstChild("Humanoid") and survivor.Character.Humanoid.Health > 0 then
            allSurvivorsEscaped = false
            break
        end
    end

    if allSurvivorsEscaped then
        showMessage("The survivors have won!", INTERMISSION_DURATION)
        -- Restart game
    end
end

-- Function to handle player death
local function onPlayerDied(player)
    showMessage(player.Name .. " was caught!", INTERMISSION_DURATION)

    -- Check if all survivors are dead
    local allSurvivorsDead = true
    for _, survivor in ipairs(survivors) do
        if survivor.Character and survivor.Character:FindFirstChild("Humanoid") and survivor.Character.Humanoid.Health > 0 then
            allSurvivorsDead = false
            break
        end
    end

    if allSurvivorsDead then
        showMessage("The killer has won!", INTERMISSION_DURATION)
        -- Restart game
    end
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
-- This is a server script, so we can't create a LocalScript directly.
-- The user will have to create a LocalScript in StarterPlayer.StarterPlayerScripts
-- and paste the content of the `localScript` variable into it.
-- I will add this to the README.md file.

-- Handle role selection events
local survivorEvent = ReplicatedStorage:WaitForChild("SurvivorChosen")
local killerEvent = ReplicatedStorage:WaitForChild("KillerChosen")

local Survivor = require(game.ServerScriptService.Survivor)

survivorEvent.OnServerEvent:Connect(function(player)
    print(player.Name .. " is a Survivor")
    table.insert(survivors, player)
    Survivor.createAbilities(player)
end)

local Killer = require(game.ServerScriptService.Killer)

killerEvent.OnServerEvent:Connect(function(player)
    print(player.Name .. " is the Killer")
    table.insert(killers, player)
    Killer.createAbilities(player)
    player.CharacterAdded:Connect(function(character)
        local isKillerTag = Instance.new("ObjectValue")
        isKillerTag.Name = "IsKiller"
        isKillerTag.Parent = character
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, p in ipairs(survivors) do
        if p == player then
            table.remove(survivors, i)
            break
        end
    end
    for i, p in ipairs(killers) do
        if p == player then
            table.remove(killers, i)
            break
        end
    end
end)

print("Game logic script loaded.")
