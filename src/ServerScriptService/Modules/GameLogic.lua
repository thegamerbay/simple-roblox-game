--!strict
local GameLogic = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")

local coinStore = DataStoreService:GetDataStore("PlayerCoinsStore")
local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalCoinLeaderboard")

local CoinManager = require(script.Parent.CoinManager)
local EnvironmentManager = require(script.Parent.EnvironmentManager) -- NEW LINE

-- NEW: Helper function to save a specific player's data
function GameLogic.savePlayerData(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("Coins")
        if coins and coins:IsA("IntValue") then
            -- 1. Save to the regular database
            pcall(function()
                coinStore:SetAsync(tostring(player.UserId), coins.Value)
            end)
            
            -- 2. Save to the special database for Top-20
            pcall(function()
                leaderboardStore:SetAsync(tostring(player.UserId), coins.Value)
            end)
        end
    end
end

function GameLogic.init()
    -- 1. Create the baseplate
    local baseplate = Instance.new("Part")
    baseplate.Name = "Baseplate"
    baseplate.Size = Vector3.new(100, 1, 100)
    baseplate.Position = Vector3.new(0, 0, 0) 
    baseplate.Anchored = true
    baseplate.BrickColor = BrickColor.new("Dark green")
    baseplate.Parent = Workspace

    -- 1.5. Create a SpawnLocation
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.Position = Vector3.new(0, 1, 0)
    spawnLocation.Anchored = true
    spawnLocation.BrickColor = BrickColor.new("Medium stone grey")
    spawnLocation.Parent = Workspace

    -- 1.8 Place decorations
    task.spawn(function()
        EnvironmentManager.spawnTrees()
    end)

    -- 2. Connect player added and removing events
    Players.PlayerAdded:Connect(GameLogic.onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player: Player)
        GameLogic.savePlayerData(player) -- Call our function when a player leaves
    end)

    -- 3. Start the game loop from the module
    CoinManager.spawnCoin()

    -- NEW: 4. Start the background auto-save process
    task.spawn(function()
        while true do
            task.wait(60) -- Wait for 60 seconds
            -- Go through the list of all players currently on the server
            for _, player in ipairs(Players:GetPlayers()) do
                GameLogic.savePlayerData(player)
            end
        end
    end)
end

function GameLogic.onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    -- Load data on join
    local success, savedCoins = pcall(function()
        return coinStore:GetAsync(tostring(player.UserId))
    end)

    if success and savedCoins then
        coins.Value = savedCoins :: number
    end
end

return GameLogic
