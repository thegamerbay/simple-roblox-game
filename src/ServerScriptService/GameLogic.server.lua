--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Include our new module
local CoinManager = require(script.Parent.Modules.CoinManager)

-- 1. Create the baseplate
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Size = Vector3.new(100, 1, 100)
baseplate.Position = Vector3.new(0, 5, 0) 
baseplate.Anchored = true
baseplate.BrickColor = BrickColor.new("Dark green")
baseplate.Parent = Workspace

-- 2. Set up the points system
Players.PlayerAdded:Connect(function(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end)

-- 3. Start the game loop from the module
CoinManager.spawnCoin()
