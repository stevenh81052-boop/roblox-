-- This script defines the survivor character and their abilities.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local survivor = {}

function survivor.placeWall(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local wall = Instance.new("Part")
        wall.Name = "Wall"
        wall.Size = Vector3.new(10, 10, 1)
        wall.Position = rootPart.Position + (rootPart.CFrame.LookVector * 10)
        wall.Anchored = true
        wall.BrickColor = BrickColor.new("Bright blue")
        wall.Parent = game.Workspace

        -- Make the wall disappear after a short time
        game.Debris:AddItem(wall, 5)
    end
end

function survivor.createAbilities(player)
    -- Create the "stun rocket" ability
    local stunRocketTool = Instance.new("Tool")
    stunRocketTool.Name = "StunRocket"
    stunRocketTool.ToolTip = "Fire a rocket to stun the killer."
    stunRocketTool.Parent = player.Backpack

    local rocketHandle = Instance.new("Part")
    rocketHandle.Name = "Handle"
    rocketHandle.Size = Vector3.new(1, 1, 1)
    rocketHandle.Parent = stunRocketTool

    stunRocketTool.Activated:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local rocket = Instance.new("Part")
            rocket.Name = "Rocket"
            rocket.Size = Vector3.new(1, 1, 3)
            rocket.Position = rootPart.Position + (rootPart.CFrame.LookVector * 3)
            rocket.CFrame = rootPart.CFrame
            rocket.Anchored = false
            rocket.BrickColor = BrickColor.new("Bright red")
            rocket.Parent = game.Workspace

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = rootPart.CFrame.LookVector * 100
            bodyVelocity.Parent = rocket

            rocket.Touched:Connect(function(hit)
                local hitModel = hit.Parent
                if hitModel and hitModel:FindFirstChild("Humanoid") and hitModel:FindFirstChild("IsKiller") then
                    local humanoid = hitModel.Humanoid
                    humanoid.WalkSpeed = 0
                    wait(5)
                    humanoid.WalkSpeed = 16 -- a default value, will be changed later
                end
                rocket:Destroy()
            end)

            game.Debris:AddItem(rocket, 10)
        end
    end)
end

return survivor
