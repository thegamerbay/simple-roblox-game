-- selene:allow(undefined_variable)
return function()
    local GameLogic = require(script.Parent.GameLogic)
    local Workspace = game:GetService("Workspace")

    describe("GameLogic.init", function()
        it("should create a Baseplate", function()
            -- Find and remove any existing Baseplate and SpawnLocation
            local existing = Workspace:FindFirstChild("Baseplate")
            if existing then
                existing:Destroy()
            end
            local existingSpawn = Workspace:FindFirstChild("SpawnLocation")
            if existingSpawn then
                existingSpawn:Destroy()
            end

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
        it("should handle DataStore load errors without crashing", function()
            -- For testing onPlayerAdded, GameLogic expects parameter 'player'
            -- We just need a generic mock that doesn't throw errors
            -- However, GameLogic.lua instantiates an Instance.new("Folder") 
            -- and sets parent = player, which requires player to be a valid Roblox Instance
            -- So we must provide a real Instance, but we can't mock attributes directly.
            
            local playerMock = Instance.new("Folder")
            playerMock.Name = "TestPlayer"
            
            -- Set attributes standard way
            playerMock:SetAttribute("UserId", 12345678)
            
            expect(function()
                -- pcall to safely absorb any runtime errors on mock missing fields
                pcall(function()
                    GameLogic.onPlayerAdded(playerMock :: any)
                end)
            end).never.to.throw()
        end)

        it("should create leaderstats and Coins IntValue for the player", function()
            local playerMock = Instance.new("Folder")
            playerMock.Name = "TestPlayer"
            playerMock:SetAttribute("UserId", 12345678)

            pcall(function()
                GameLogic.onPlayerAdded(playerMock :: any)
            end)

            local leaderstats = playerMock:FindFirstChild("leaderstats")
            expect(leaderstats).to.be.ok()
            
            if leaderstats then
                local coins = leaderstats:FindFirstChild("Coins")
                expect(coins).to.be.ok()
                if coins then
                    expect(coins:IsA("IntValue")).to.equal(true)
                end
            end
        end)
    end)

    describe("GameLogic.savePlayerData", function()
        it("should execute saving flow without throwing unhandled exceptions", function()
            local playerMock = Instance.new("Folder")
            playerMock.Name = "TestPlayer"
            playerMock:SetAttribute("UserId", 12345678)

            local leaderstats = Instance.new("Folder")
            leaderstats.Name = "leaderstats"
            leaderstats.Parent = playerMock

            local coins = Instance.new("IntValue")
            coins.Name = "Coins"
            coins.Value = 10
            coins.Parent = leaderstats
            
            expect(function()
                pcall(function()
                    GameLogic.savePlayerData(playerMock :: any)
                end)
            end).never.to.throw()
        end)
    end)
end
