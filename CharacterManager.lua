-- CharacterManager
-- This module is responsible for managing character abilities and appearance.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local CharacterManager = {}

-- RemoteEvents for abilities
local placeWallEvent = Instance.new("RemoteEvent")
placeWallEvent.Name = "PlaceWallEvent"
placeWallEvent.Parent = ReplicatedStorage

local fireRocketEvent = Instance.new("RemoteEvent")
fireRocketEvent.Name = "FireRocketEvent"
fireRocketEvent.Parent = ReplicatedStorage

-- Server-side handler for placing a wall
placeWallEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart
    local wallPosition = rootPart.CFrame * CFrame.new(0, 0, -5)

    local wall = Instance.new("Part")
    wall.Size = Vector3.new(12, 8, 1)
    wall.CFrame = wallPosition
    wall.Anchored = true
    wall.BrickColor = BrickColor.new("Bright blue")
    wall.Material = Enum.Material.ForceField
    wall.Parent = game.Workspace

    -- Wall lasts for 10 seconds
    Debris:AddItem(wall, 10)
end)

-- Server-side handler for firing a rocket
fireRocketEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart

    local rocket = Instance.new("Part")
    rocket.Size = Vector3.new(1, 1, 3)
    rocket.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
    rocket.BrickColor = BrickColor.new("Red")
    rocket.Material = Enum.Material.Neon
    rocket.Parent = game.Workspace

    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocity.Velocity = rootPart.CFrame.LookVector * 100
    velocity.Parent = rocket

    -- Rocket lasts for 5 seconds
    Debris:AddItem(rocket, 5)

    rocket.Touched:Connect(function(hit)
        local hitModel = hit:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChild("Humanoid") then
            local hitPlayer = game.Players:GetPlayerFromCharacter(hitModel)
            if hitPlayer and hitPlayer:GetAttribute("Role") == "Killer" then
                local humanoid = hitModel.Humanoid
                local originalSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = 0

                -- Stun effect
                local stunEffect = Instance.new("ParticleEmitter")
                stunEffect.Parent = hitModel.Head
                stunEffect.Rate = 50
                -- Configure stun particles here

                wait(5)

                humanoid.WalkSpeed = originalSpeed
                stunEffect:Destroy()
                rocket:Destroy()
            end
        end
    end)
end)

-- Function to set up a survivor's abilities
function CharacterManager.equipSurvivor(player, characterName)
    print(player.Name .. " is being equipped as survivor: " .. characterName)

    player.CharacterAdded:Connect(function(character)
        -- This LocalScript will handle player input for abilities
        local abilityScript = Instance.new("LocalScript")
        abilityScript.Name = "SurvivorAbilityHandler"
        abilityScript.Parent = character

        abilityScript.Source = [[
            local UserInputService = game:GetService("UserInputService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")

            local placeWallEvent = ReplicatedStorage:WaitForChild("PlaceWallEvent")
            local fireRocketEvent = ReplicatedStorage:WaitForChild("FireRocketEvent")

            UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent then return end

                -- Press 'Q' to place a wall
                if input.KeyCode == Enum.KeyCode.Q then
                    placeWallEvent:FireServer()
                end

                -- Press 'E' to fire a rocket
                if input.KeyCode == Enum.KeyCode.E then
                    fireRocketEvent:FireServer()
                end
            end)
        ]]
    end)
end

-- RemoteEvents for killer abilities
local teleportEvent = Instance.new("RemoteEvent")
teleportEvent.Name = "TeleportEvent"
teleportEvent.Parent = ReplicatedStorage

local grabThrowEvent = Instance.new("RemoteEvent")
grabThrowEvent.Name = "GrabThrowEvent"
grabThrowEvent.Parent = ReplicatedStorage

local throwSwordEvent = Instance.new("RemoteEvent")
throwSwordEvent.Name = "ThrowSwordEvent"
throwSwordEvent.Parent = ReplicatedStorage

-- Server-side handler for teleporting
teleportEvent.OnServerEvent:Connect(function(player, targetPosition)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Basic validation to prevent teleporting too far
    local distance = (character.HumanoidRootPart.Position - targetPosition).Magnitude
    if distance > 100 then return end -- Max teleport distance of 100 studs

    character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
end)

-- Server-side handler for grabbing/throwing
local heldSurvivors = {}
grabThrowEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- If currently holding a survivor, throw them
    if heldSurvivors[player] then
        local survivorCharacter = heldSurvivors[player]
        if survivorCharacter and survivorCharacter.PrimaryPart then
            survivorCharacter.PrimaryPart:FindFirstChildOfClass("WeldConstraint"):Destroy()
            survivorCharacter.Humanoid.PlatformStand = false

            local throwVelocity = Instance.new("BodyVelocity")
            throwVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            throwVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 50 + Vector3.new(0, 20, 0)
            throwVelocity.Parent = survivorCharacter.PrimaryPart
            Debris:AddItem(throwVelocity, 0.5)
        end
        heldSurvivors[player] = nil
        return
    end

    -- If not holding anyone, try to grab someone
    local rootPart = character.HumanoidRootPart
    local grabRange = 10
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer:GetAttribute("Role") == "Survivor" and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local survivorCharacter = otherPlayer.Character
            local distance = (rootPart.Position - survivorCharacter.HumanoidRootPart.Position).Magnitude
            if distance < grabRange then
                heldSurvivors[player] = survivorCharacter
                survivorCharacter.Humanoid.PlatformStand = true

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = rootPart
                weld.Part1 = survivorCharacter.HumanoidRootPart
                weld.Parent = rootPart
                break
            end
        end
    end
end)

-- Server-side handler for throwing a sword
throwSwordEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart

    local sword = Instance.new("Part")
    sword.Size = Vector3.new(1, 1, 5)
    sword.CFrame = rootPart.CFrame * CFrame.new(0, 0, -4)
    sword.BrickColor = BrickColor.new("Black")
    sword.Material = Enum.Material.Metal
    sword.CanCollide = false
    sword.Parent = game.Workspace

    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocity.Velocity = rootPart.CFrame.LookVector * 150
    velocity.Parent = sword

    Debris:AddItem(sword, 3)

    sword.Touched:Connect(function(hit)
        local hitModel = hit:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel:FindFirstChild("Humanoid") then
            local hitPlayer = game.Players:GetPlayerFromCharacter(hitModel)
            if hitPlayer and hitPlayer:GetAttribute("Role") == "Survivor" then
                hitPlayer:SetAttribute("IsMarked", true)

                -- Visual effect for marking
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.Parent = hitModel

                Debris:AddItem(highlight, 15) -- Mark lasts 15 seconds
                wait(15)
                hitPlayer:SetAttribute("IsMarked", false)

                sword:Destroy()
            end
        end
    end)
end)

-- Function to set up a killer's abilities
function CharacterManager.equipKiller(player, characterName)
    print(player.Name .. " is being equipped as killer: " .. characterName)

    -- Change appearance to 1x1x1x1
    player.CharacterAdded:Connect(function(character)
        character.Humanoid.DisplayName = "1x1x1x1"
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.BrickColor = BrickColor.new("Black")
            end
        end

        -- This LocalScript will handle player input for abilities
        local abilityScript = Instance.new("LocalScript")
        abilityScript.Name = "KillerAbilityHandler"
        abilityScript.Parent = character

        abilityScript.Source = [[
            local UserInputService = game:GetService("UserInputService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")

            local teleportEvent = ReplicatedStorage:WaitForChild("TeleportEvent")
            local grabThrowEvent = ReplicatedStorage:WaitForChild("GrabThrowEvent")
            local throwSwordEvent = ReplicatedStorage:WaitForChild("ThrowSwordEvent")

            local mouse = Players.LocalPlayer:GetMouse()

            UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent then return end

                -- Press 'Q' to teleport
                if input.KeyCode == Enum.KeyCode.Q then
                    teleportEvent:FireServer(mouse.Hit.p)
                end

                -- Press 'E' to grab or throw
                if input.KeyCode == Enum.KeyCode.E then
                    grabThrowEvent:FireServer()
                end

                -- Press 'F' to throw a sword
                if input.KeyCode == Enum.KeyCode.F then
                    throwSwordEvent:FireServer()
                end
            end)
        ]]
    end)
end

return CharacterManager
