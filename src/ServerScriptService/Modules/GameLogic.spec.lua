-- selene:allow(undefined_variable)
return function()
    local GameLogic = require(script.Parent.GameLogic)
    local Workspace = game:GetService("Workspace")

    describe("GameLogic.init", function()
        it("should create a Baseplate", function()
            -- Find and remove any existing Baseplate
            local existing = Workspace:FindFirstChild("Baseplate")
            if existing then existing:Destroy() end

            -- Stub CoinManager spawnCoin so it doesn't loop or interfere
            local CoinManager = require(script.Parent.CoinManager)
            local originalSpawn = CoinManager.spawnCoin
            CoinManager.spawnCoin = function() end

            GameLogic.init()

            local baseplate = Workspace:FindFirstChild("Baseplate")
            expect(baseplate).to.be.ok()
            expect(baseplate.Name).to.equal("Baseplate")
            expect(baseplate.Anchored).to.equal(true)
            expect(baseplate.Position.Y).to.equal(5)

            -- Restore
            CoinManager.spawnCoin = originalSpawn
        end)
    end)

    describe("GameLogic.onPlayerAdded", function()
        it("should create leaderstats and Coins IntValue for player", function()
            local dummyPlayer = Instance.new("Model")
            dummyPlayer.Name = "TestPlayer"
            
            GameLogic.onPlayerAdded(dummyPlayer :: any)

            local leaderstats = dummyPlayer:FindFirstChild("leaderstats")
            expect(leaderstats).to.be.ok()
            
            local coins = leaderstats:FindFirstChild("Coins")
            expect(coins).to.be.ok()
            expect(coins.Value).to.equal(0)
            expect(coins:IsA("IntValue")).to.equal(true)
        end)
    end)
end
