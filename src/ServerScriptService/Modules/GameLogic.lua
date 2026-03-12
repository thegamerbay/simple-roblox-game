--!strict
local GameLogic = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")

-- Create or connect to the database named "PlayerCoinsStore"
local coinStore = DataStoreService:GetDataStore("PlayerCoinsStore")

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

    -- 1.5. Create a SpawnLocation
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnLocation"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.Position = Vector3.new(0, 1, 0)
    spawnLocation.Anchored = true
    spawnLocation.BrickColor = BrickColor.new("Medium stone grey")
    spawnLocation.Parent = Workspace

    -- 2. Connect player added and removing events
    Players.PlayerAdded:Connect(GameLogic.onPlayerAdded)
    Players.PlayerRemoving:Connect(GameLogic.onPlayerRemoving)

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

    -- Load data on join (Wrap in pcall to protect against network errors)
    local success, savedCoins = pcall(function()
        return coinStore:GetAsync(tostring(player.UserId))
    end)

    if success and savedCoins then
        coins.Value = savedCoins :: number
    end
end

-- Function to save data when a player leaves
function GameLogic.onPlayerRemoving(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coins = leaderstats:FindFirstChild("Coins")
        if coins and coins:IsA("IntValue") then
            -- Wrap the save request in a pcall
            local success, errorMessage = pcall(function()
                coinStore:SetAsync(tostring(player.UserId), coins.Value)
            end)
            
            if not success then
                warn("Failed to save coins for " .. player.Name .. ": " .. tostring(errorMessage))
            end
        end
    end
end

return GameLogic
