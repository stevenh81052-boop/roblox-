-- Maze Generation Script
-- This script generates a random maze using a randomized depth-first search algorithm.

-- Configuration
local MAZE_SIZE = 20 -- The size of the maze (in cells)
local CELL_SIZE = 10 -- The size of each cell (in studs)
local WALL_THICKNESS = 1
local WALL_HEIGHT = 10
local WALL_COLOR = Color3.new(0.5, 0.5, 0.5)
local FLOOR_COLOR = Color3.new(0.8, 0.8, 0.8)

-- Services
local Workspace = game:GetService("Workspace")

-- Create a folder to hold the maze parts
local mazeFolder = Instance.new("Folder")
mazeFolder.Name = "Maze"
mazeFolder.Parent = Workspace

-- Create the floor
local floor = Instance.new("Part")
floor.Name = "Floor"
floor.Size = Vector3.new(MAZE_SIZE * CELL_SIZE, WALL_THICKNESS, MAZE_SIZE * CELL_SIZE)
floor.Position = Vector3.new((MAZE_SIZE * CELL_SIZE) / 2, -WALL_THICKNESS / 2, (MAZE_SIZE * CELL_SIZE) / 2)
floor.Anchored = true
floor.Color = FLOOR_COLOR
floor.Parent = mazeFolder

-- Create the grid
local grid = {}
for x = 1, MAZE_SIZE do
    grid[x] = {}
    for y = 1, MAZE_SIZE do
        grid[x][y] = {
            visited = false,
            walls = {
                top = true,
                bottom = true,
                left = true,
                right = true
            }
        }
    end
end

-- Recursive backtracking algorithm
local function carve(x, y)
    grid[x][y].visited = true

    local directions = {"top", "bottom", "left", "right"}
    while #directions > 0 do
        local randomIndex = math.random(#directions)
        local direction = table.remove(directions, randomIndex)

        local nextX, nextY = x, y
        if direction == "top" then
            nextY = y - 1
        elseif direction == "bottom" then
            nextY = y + 1
        elseif direction == "left" then
            nextX = x - 1
        elseif direction == "right" then
            nextX = x + 1
        end

        if nextX > 0 and nextX <= MAZE_SIZE and nextY > 0 and nextY <= MAZE_SIZE and not grid[nextX][nextY].visited then
            if direction == "top" then
                grid[x][y].walls.top = false
                grid[nextX][nextY].walls.bottom = false
            elseif direction == "bottom" then
                grid[x][y].walls.bottom = false
                grid[nextX][nextY].walls.top = false
            elseif direction == "left" then
                grid[x][y].walls.left = false
                grid[nextX][nextY].walls.right = false
            elseif direction == "right" then
                grid[x][y].walls.right = false
                grid[nextX][nextY].walls.left = false
            end
            carve(nextX, nextY)
        end
    end
end

-- Start carving the maze from a random cell
carve(math.random(MAZE_SIZE), math.random(MAZE_SIZE))

-- Create the walls
for x = 1, MAZE_SIZE do
    for y = 1, MAZE_SIZE do
        if grid[x][y].walls.top then
            local wall = Instance.new("Part")
            wall.Name = "Wall"
            wall.Size = Vector3.new(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
            wall.Position = Vector3.new((x - 0.5) * CELL_SIZE, WALL_HEIGHT / 2, (y - 1) * CELL_SIZE)
            wall.Anchored = true
            wall.Color = WALL_COLOR
            wall.Parent = mazeFolder
        end
        if grid[x][y].walls.bottom then
            local wall = Instance.new("Part")
            wall.Name = "Wall"
            wall.Size = Vector3.new(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
            wall.Position = Vector3.new((x - 0.5) * CELL_SIZE, WALL_HEIGHT / 2, y * CELL_SIZE)
            wall.Anchored = true
            wall.Color = WALL_COLOR
            wall.Parent = mazeFolder
        end
        if grid[x][y].walls.left then
            local wall = Instance.new("Part")
            wall.Name = "Wall"
            wall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE)
            wall.Position = Vector3.new((x - 1) * CELL_SIZE, WALL_HEIGHT / 2, (y - 0.5) * CELL_SIZE)
            wall.Anchored = true
            wall.Color = WALL_COLOR
            wall.Parent = mazeFolder
        end
        if grid[x][y].walls.right then
            local wall = Instance.new("Part")
            wall.Name = "Wall"
            wall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE)
            wall.Position = Vector3.new(x * CELL_SIZE, WALL_HEIGHT / 2, (y - 0.5) * CELL_SIZE)
            wall.Anchored = true
            wall.Color = WALL_COLOR
            wall.Parent = mazeFolder
        end
    end
end

-- Create start and end points
local start = Instance.new("SpawnLocation")
start.Name = "Start"
start.Size = Vector3.new(CELL_SIZE, 1, CELL_SIZE)
start.Position = Vector3.new(0.5 * CELL_SIZE, 1, 0.5 * CELL_SIZE)
start.Anchored = true
start.Parent = Workspace

local goal = Instance.new("Part")
goal.Name = "Goal"
goal.Size = Vector3.new(CELL_SIZE, 1, CELL_SIZE)
goal.Position = Vector3.new((MAZE_SIZE - 0.5) * CELL_SIZE, 1, (MAZE_SIZE - 0.5) * CELL_SIZE)
goal.Anchored = true
goal.Color = Color3.new(0, 1, 0)
goal.Transparency = 0.5
goal.Parent = Workspace

print("Maze generation complete.")
