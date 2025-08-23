-- Menu.lua
-- This script is responsible for creating the role information UI for each player.

local Menu = {}

-- Function to create the role display UI
function Menu.createRoleUI(player)
    -- Clean up any old UI
    local playerGui = player:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("RoleDisplayGui")
    if oldGui then
        oldGui:Destroy()
    end

    -- Create the ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoleDisplayGui"
    screenGui.Parent = playerGui

    -- Create the main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.3, 0, 0.4, 0)
    frame.Position = UDim2.new(0.35, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.Parent = screenGui

    -- Create the title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    titleLabel.Text = "Your Role"
    titleLabel.FontSize = Enum.FontSize.Size36
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    titleLabel.Parent = frame

    -- Get player's role and character
    local role = player:GetAttribute("Role")
    local characterName = ""
    local abilities = ""

    if role == "Killer" then
        characterName = "1x1x1x1"
        abilities = "Q: Teleport\nE: Grab/Throw\nF: Throw Sword"
    elseif role == "Survivor" then
        characterName = "Rig"
        abilities = "Q: Place Wall\nE: Fire Rocket"
    end

    -- Create the role name label
    local roleNameLabel = Instance.new("TextLabel")
    roleNameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    roleNameLabel.Position = UDim2.new(0, 0, 0.2, 0)
    roleNameLabel.Text = role .. ": " .. characterName
    roleNameLabel.FontSize = Enum.FontSize.Size24
    roleNameLabel.TextColor3 = Color3.new(1, 1, 1)
    roleNameLabel.BackgroundTransparency = 1
    roleNameLabel.Parent = frame

    -- Create the abilities label
    local abilitiesLabel = Instance.new("TextLabel")
    abilitiesLabel.Size = UDim2.new(1, 0, 0.6, 0)
    abilitiesLabel.Position = UDim2.new(0, 0, 0.4, 0)
    abilitiesLabel.Text = abilities
    abilitiesLabel.FontSize = Enum.FontSize.Size18
    abilitiesLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    abilitiesLabel.BackgroundTransparency = 1
    abilitiesLabel.TextWrapped = true
    abilitiesLabel.Parent = frame

    -- UI will disappear after 15 seconds
    game:GetService("Debris"):AddItem(screenGui, 15)
end

return Menu
