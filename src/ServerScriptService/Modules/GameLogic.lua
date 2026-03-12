--!strict
local GameLogic = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")

local coinStore = DataStoreService:GetDataStore("PlayerCoinsStore")
local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalCoinLeaderboard")

local CoinManager = require(script.Parent.CoinManager)
local EnvironmentManager = require(script.Parent.EnvironmentManager)
local ShopManager = require(script.Parent.ShopManager)

-- Updated save function
local function savePlayerData(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("Coins")
        if coins and coins:IsA("IntValue") then
            
            -- NEW: Save an entire table (Dictionary) of data
            local dataToSave = {
                coins = coins.Value,
                SpeedPurchases = player:GetAttribute("SpeedPurchases") or 0,
                JumpPurchases = player:GetAttribute("JumpPurchases") or 0
            }
            
            pcall(function()
                coinStore:SetAsync(tostring(player.UserId), dataToSave)
            end)
            
            -- For the leaderboard, we continue to save just one number
            pcall(function()
                leaderboardStore:SetAsync(tostring(player.UserId), coins.Value)
            end)
        end
    end
end

function GameLogic.init()
    ShopManager.init()

    local baseplate = Instance.new("Part")
    baseplate.Name = "Baseplate"
    baseplate.Size = Vector3.new(100, 1, 100)
    baseplate.Position = Vector3.new(0, 0, 0) 
    baseplate.Anchored = true
    baseplate.BrickColor = BrickColor.new("Dark green")
    baseplate.Parent = Workspace

    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.Position = Vector3.new(0, 1, 0)
    spawnLocation.Anchored = true
    spawnLocation.BrickColor = BrickColor.new("Medium stone grey")
    spawnLocation.Parent = Workspace

    EnvironmentManager.spawnTrees()

    Players.PlayerAdded:Connect(GameLogic.onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player: Player)
        savePlayerData(player)
    end)

    CoinManager.spawnCoin()

    task.spawn(function()
        while true do
            task.wait(60)
            for _, player in ipairs(Players:GetPlayers()) do
                savePlayerData(player)
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

    -- Load data
    local success, savedData = pcall(function()
        return coinStore:GetAsync(tostring(player.UserId))
    end)

    if success and savedData then
        -- DATA MIGRATION: If the player played before, their save is a number
        if type(savedData) == "number" then
            coins.Value = savedData
        -- If they already have a new save, it's a table
        elseif type(savedData) == "table" then
            coins.Value = savedData.coins or 0
            player:SetAttribute("SpeedPurchases", savedData.SpeedPurchases or 0)
            player:SetAttribute("JumpPurchases", savedData.JumpPurchases or 0)
        end
    end

    -- NEW: Every time the character spawns/respawns, apply the boosts
    player.CharacterAdded:Connect(function(character)
        ShopManager.applyUpgrades(player, character)
    end)
end

return GameLogic
