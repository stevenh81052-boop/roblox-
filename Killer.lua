-- This script defines the killer character and their abilities.

local killer = {}

function killer.createAbilities(player)
    -- Create the "teleport" ability
    local teleportTool = Instance.new("Tool")
    teleportTool.Name = "Teleport"
    teleportTool.ToolTip = "Teleport to a new location."
    teleportTool.Parent = player.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Parent = teleportTool

    teleportTool.Activated:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local mouse = player:GetMouse()
            rootPart.CFrame = CFrame.new(mouse.Hit.p)
        end
    end)

    -- Create the "grab and throw" ability
    local grabTool = Instance.new("Tool")
    grabTool.Name = "GrabAndThrow"
    grabTool.ToolTip = "Grab a survivor and throw them."
    grabTool.Parent = player.Backpack

    local grabHandle = Instance.new("Part")
    grabHandle.Name = "Handle"
    grabHandle.Size = Vector3.new(1, 1, 1)
    grabHandle.Parent = grabTool

    local grabbing = false
    local grabbedPlayer = nil

    grabTool.Activated:Connect(function()
        if grabbing then
            -- Throw the player
            if grabbedPlayer and grabbedPlayer.Character and grabbedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = grabbedPlayer.Character.HumanoidRootPart
                rootPart.Parent.Parent = game.Workspace -- un-weld
                rootPart.Velocity = player.Character.HumanoidRootPart.CFrame.LookVector * 50
            end
            grabbing = false
            grabbedPlayer = nil
        else
            -- Grab a nearby player
            local character = player.Character
            if character then
                local rootPart = character.HumanoidRootPart
                for _, otherPlayer in pairs(game.Players:GetPlayers()) do
                    if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local otherRootPart = otherPlayer.Character.HumanoidRootPart
                        if (rootPart.Position - otherRootPart.Position).Magnitude < 10 then
                            -- Weld the player to the killer
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = rootPart
                            weld.Part1 = otherRootPart
                            weld.Parent = rootPart
                            grabbing = true
                            grabbedPlayer = otherPlayer
                            break
                        end
                    end
                end
            end
        end
    end)
    -- Create the "marking sword" ability
    local swordTool = Instance.new("Tool")
    swordTool.Name = "MarkingSword"
    swordTool.ToolTip = "Throw a sword to mark a survivor."
    swordTool.Parent = player.Backpack

    local swordHandle = Instance.new("Part")
    swordHandle.Name = "Handle"
    swordHandle.Size = Vector3.new(1, 1, 1)
    swordHandle.Parent = swordTool

    swordTool.Activated:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local sword = Instance.new("Part")
            sword.Name = "Sword"
            sword.Size = Vector3.new(1, 1, 5)
            sword.Position = rootPart.Position + (rootPart.CFrame.LookVector * 5)
            sword.CFrame = rootPart.CFrame
            sword.Anchored = false
            sword.BrickColor = BrickColor.new("Gray")
            sword.Parent = game.Workspace

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = rootPart.CFrame.LookVector * 100
            bodyVelocity.Parent = sword

            sword.Touched:Connect(function(hit)
                local hitModel = hit.Parent
                if hitModel and hitModel:FindFirstChild("Humanoid") and not hitModel:FindFirstChild("IsKiller") then
                    print(hitModel.Name .. " has been marked!")
                    -- You can add more effects for marked players here
                end
                sword:Destroy()
            end)

            game.Debris:AddItem(sword, 10)
        end
    end)
end

return killer
