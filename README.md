# Roblox Horror Game: Piggy's Maze

This is a simple horror game where you have to escape a maze while being chased by a pig monster.

## Setup Instructions

To set up the game in Roblox Studio, follow these steps:

### 1. Maze Generator Script

1.  In the `ServerScriptService`, create a new script named `MazeGenerator`.
2.  Copy the contents of `MazeGenerator.lua` and paste them into the new script.

### 2. Pig Monster AI Script

1.  In the `ServerScriptService`, create a new script named `PigMonster`.
2.  Copy the contents of `PigMonster.lua` and paste them into the new script.
3.  **Note:** The pig uses a sound with the asset ID `rbxassetid://134262287`. You can change this to any other sound asset ID you prefer.

### 3. Game Logic Script

1.  In the `ServerScriptService`, create a new script named `GameLogic`.
2.  Copy the contents of `GameLogic.lua` and paste them into the new script.

### 4. Role Selection Script (LocalScript)

1.  In the `StarterPlayer` service, find the `StarterPlayerScripts` folder.
2.  Create a new `LocalScript` inside `StarterPlayerScripts`. You can name it `RoleSelection`.
3.  Copy the contents of `RoleSelection.lua` and paste them into the new script.

## How to Play

1.  Press `Play` in Roblox Studio.
2.  Your character will spawn at the start of a randomly generated maze.
3.  A pig monster will start chasing you.
4.  Find the green "Goal" platform at the end of the maze to win.
5.  If the pig catches you, you lose.
6.  The game will automatically restart after a few seconds.

Enjoy your new horror game!
