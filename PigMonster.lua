-- Pig Monster AI Script
-- This script controls the pig monster's AI, making it chase the player.

-- Services
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Configuration
local PIG_SPEED = 12
local PIG_DAMAGE = 100

-- Create the pig model
local pig = Instance.new("Model")
pig.Name = "Pig"
pig.Parent = Workspace

local head = Instance.new("Part")
head.Name = "Head"
head.Size = Vector3.new(4, 4, 4)
head.Position = Vector3.new(0, 2, 0)
head.BrickColor = BrickColor.new("Pink")
head.Parent = pig

local body = Instance.new("Part")
body.Name = "Body"
body.Size = Vector3.new(8, 4, 4)
body.Position = Vector3.new(-2, 2, 0)
body.BrickColor = BrickColor.new("Pink")
body.Parent = pig

local humanoid = Instance.new("Humanoid")
humanoid.Name = "Humanoid"
humanoid.Health = 100
humanoid.MaxHealth = 100
humanoid.WalkSpeed = PIG_SPEED
humanoid.Parent = pig

pig:SetPrimaryPartCFrame(CFrame.new(Vector3.new(15, 5, 15)))

-- Add sound effects
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://134262287" -- Oink sound
sound.Looped = true
sound.Parent = head

-- Pathfinding logic
local function getClosestPlayer()
    local closestPlayer, closestDistance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (pig.PrimaryPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    return closestPlayer
end

local function chasePlayer(player)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(pig.PrimaryPart.Position, player.Character.HumanoidRootPart.Position)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in pairs(waypoints) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
        end
    end
end

-- Kill player on touch
pig.PrimaryPart.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:TakeDamage(PIG_DAMAGE)
    end
end)

-- Main loop
while wait(1) do
    local player = getClosestPlayer()
    if player then
        chasePlayer(player)
        if not sound.IsPlaying then
            sound:Play()
        end
    else
        if sound.IsPlaying then
            sound:Stop()
        end
    end
end
