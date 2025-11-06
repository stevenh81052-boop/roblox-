-- PathMover.lua
-- This script manages the movement of skecthfab_scene and the spawning of skecthfab_modle.

local tweenService = game:GetService("TweenService")
local serverStorage = game:GetService("ServerStorage")

-- --- Configuration ---
-- The main model that will move along the path
local mainModel = workspace:WaitForChild("skecthfab_scene")
-- The template model to be spawned
local spawnModelTemplate = serverStorage:WaitForChild("skecthfab_modle")
-- The part marking the start of the path
local startPoint = workspace:WaitForChild("Start")
-- The part marking the end of the path
local endPoint = workspace:WaitForChild("End")
-- How long it should take to get from Start to End (in seconds)
local moveDuration = 10
-- How often a new model should be spawned (in seconds)
local spawnInterval = 5
-- How far behind the main model the new model should spawn
local spawnOffset = Vector3.new(0, 0, 10) -- Spawns 10 studs behind

-- --- Script ---

-- Ensure the model has a PrimaryPart, which is required for movement.
if not mainModel.PrimaryPart then
    warn("WARNING: The model 'skecthfab_scene' does not have a PrimaryPart set. Movement will not work.")
    return
end

-- Teleport the model to the start point initially.
mainModel:SetPrimaryPartCFrame(startPoint.CFrame)

-- TweenInfo defines the properties of the movement (speed, style, etc.)
local tweenInfo = TweenInfo.new(
    moveDuration,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

-- This function will handle the movement loop.
local function moveAlongPath()
    local goal = {CFrame = endPoint.CFrame}
    local moveTween = tweenService:Create(mainModel.PrimaryPart, tweenInfo, goal)

    moveTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            mainModel:SetPrimaryPartCFrame(startPoint.CFrame)
            moveAlongPath()
        end
    end)

    moveTween:Play()
end

-- This function will handle spawning the models.
local function spawnModels()
    while true do
        wait(spawnInterval)

        -- Clone the template model
        local newSpawn = spawnModelTemplate:Clone()

        -- Position it behind the main model
        local spawnCFrame = mainModel:GetPrimaryPartCFrame() * CFrame.new(spawnOffset)
        newSpawn:SetPrimaryPartCFrame(spawnCFrame)

        -- Parent the new model to the workspace to make it visible
        newSpawn.Parent = workspace
    end
end

-- Start the movement and the spawner.
-- spawn is used to run the spawner in a new thread, so it doesn't block the movement.
spawn(spawnModels)
moveAlongPath()
