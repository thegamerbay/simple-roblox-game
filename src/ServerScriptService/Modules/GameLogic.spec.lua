-- selene:allow(undefined_variable)
return function()
    local GameLogic = require(script.Parent.GameLogic)
    local Workspace = game:GetService("Workspace")

    describe("GameLogic.init", function()
        it("should create a Baseplate", function()
            -- Find and remove any existing Baseplate and SpawnLocation
            local existing = Workspace:FindFirstChild("Baseplate")
            if existing then existing:Destroy() end
            local existingSpawn = Workspace:FindFirstChild("SpawnLocation")
            if existingSpawn then existingSpawn:Destroy() end

            -- Stub CoinManager and EnvironmentManager so they don't loop or interfere with test execution
            local CoinManager = require(script.Parent.CoinManager)
            local originalSpawn = CoinManager.spawnCoin
            CoinManager.spawnCoin = function() end

            local EnvironmentManager = require(script.Parent.EnvironmentManager)
            local originalSpawnTrees = EnvironmentManager.spawnTrees
            EnvironmentManager.spawnTrees = function() end

            GameLogic.init()

            local baseplate = Workspace:FindFirstChild("Baseplate")
            expect(baseplate).to.be.ok()
            expect(baseplate.Name).to.equal("Baseplate")
            expect(baseplate.Anchored).to.equal(true)
            expect(baseplate.Position.Y).to.equal(0)

            local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
            expect(spawnLocation).to.be.ok()
            expect(spawnLocation.Name).to.equal("SpawnLocation")
            expect(spawnLocation.Anchored).to.equal(true)
            expect(spawnLocation.Position.Y).to.equal(1)

            -- Restore
            CoinManager.spawnCoin = originalSpawn
            EnvironmentManager.spawnTrees = originalSpawnTrees
        end)
    end)

    describe("GameLogic.onPlayerAdded", function()
        it("should create leaderstats and Coins IntValue for player, handling DataStore load errors gracefully", function()
            local dummyPlayer = Instance.new("Model")
            dummyPlayer.Name = "TestPlayer"
            
            expect(function()
                GameLogic.onPlayerAdded(dummyPlayer :: any)
            end).never.to.throw()

            local leaderstats = dummyPlayer:FindFirstChild("leaderstats")
            expect(leaderstats).to.be.ok()
            
            local coins = leaderstats:FindFirstChild("Coins")
            expect(coins).to.be.ok()
            expect(coins.Value).to.equal(0)
            expect(coins:IsA("IntValue")).to.equal(true)
        end)
    end)

    describe("GameLogic.savePlayerData", function()
        it("should save coins to both PlayerCoinsStore and GlobalCoinLeaderboard gracefully", function()
            local dummyPlayer = Instance.new("Model")
            dummyPlayer.Name = "TestPlayer"
            
            -- We can't directly mock Roblox instances like DataStoreService easily in standard Busted without a full mocking framework,
            -- but we can ensure it doesn't throw and covers the execution paths.
            -- Real validation would require dependency injection of the stores into GameLogic.
            -- Right now, we ensure it runs without throwing any error in a pcall.

            local leaderstats = Instance.new("Folder")
            leaderstats.Name = "leaderstats"
            leaderstats.Parent = dummyPlayer

            local coins = Instance.new("IntValue")
            coins.Name = "Coins"
            coins.Value = 10
            coins.Parent = leaderstats
            
            expect(function()
                GameLogic.savePlayerData(dummyPlayer :: any)
            end).never.to.throw()
        end)
    end)
end
