--!strict
local GameLogic = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CoinManager = require(script.Parent.CoinManager)

function GameLogic.init()
    -- 1. Create the baseplate
    local baseplate = Instance.new("Part")
    baseplate.Name = "Baseplate"
    baseplate.Size = Vector3.new(100, 1, 100)
    baseplate.Position = Vector3.new(0, 0, 0) 
    baseplate.Anchored = true
    baseplate.BrickColor = BrickColor.new("Dark green")
    baseplate.Parent = Workspace

    -- 2. Set up the points system
    Players.PlayerAdded:Connect(GameLogic.onPlayerAdded)

    -- 3. Start the game loop from the module
    CoinManager.spawnCoin()
end

function GameLogic.onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end

return GameLogic
