
-- This script makes a model named "skecthfab_scene" follow the nearest player.

local physicsService = game:GetService("PhysicsService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local monster = workspace:WaitForChild("skecthfab_scene")
local monsterPrimaryPart = monster.PrimaryPart

-- Create a collision group for the monster
local monsterCollisionGroup = "Monster"
physicsService:CreateCollisionGroup(monsterCollisionGroup)

-- The monster should only collide with the Default group (where the Baseplate is)
physicsService:CollisionGroupSetCollidable(monsterCollisionGroup, "Default", true)
physicsService:CollisionGroupSetCollidable(monsterCollisionGroup, monsterCollisionGroup, false)

-- Set the collision group for all parts of the monster model
for _, part in ipairs(monster:GetDescendants()) do
    if part:IsA("BasePart") then
        physicsService:SetPartCollisionGroup(part, monsterCollisionGroup)
    end
end

-- Create a BodyPosition to move the monster
local bodyPosition = Instance.new("BodyPosition")
bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyPosition.P = 5000
bodyPosition.Parent = monsterPrimaryPart

local growthTimer = 0
runService.Heartbeat:Connect(function(deltaTime)
    local nearestPlayer, nearestDistance = nil, math.huge

    -- Find the nearest player
    for _, player in ipairs(players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (monsterPrimaryPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestPlayer = player
                nearestDistance = distance
            end
        end
    end

    -- Move the monster towards the nearest player
    if nearestPlayer then
        bodyPosition.Position = nearestPlayer.Character.HumanoidRootPart.Position
    end

    -- Make the monster grow slowly
    growthTimer = growthTimer + deltaTime
    if growthTimer >= 1 then
        growthTimer = growthTimer - 1
        monsterPrimaryPart.Size = monsterPrimaryPart.Size + Vector3.new(0.1, 0.1, 0.1)
    end
end)
