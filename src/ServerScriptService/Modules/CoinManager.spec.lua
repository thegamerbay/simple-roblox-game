-- selene:allow(undefined_variable)
return function()
    local CoinManager = require(script.Parent.CoinManager)

    describe("CoinManager.Logic.isRare", function()
        it("should return true for values <= 20", function()
            local result1 = CoinManager.Logic.isRare(1)
            local result20 = CoinManager.Logic.isRare(20)
            
            expect(result1).to.equal(true)
            expect(result20).to.equal(true)
        end)

        it("should return false for values > 20", function()
            local result21 = CoinManager.Logic.isRare(21)
            local result100 = CoinManager.Logic.isRare(100)
            
            expect(result21).to.equal(false)
            expect(result100).to.equal(false)
        end)
    end)

    describe("CoinManager.Logic.getCoinStats", function()
        it("should return correct stats for a rare coin", function()
            local stats = CoinManager.Logic.getCoinStats(true)
            
            expect(stats.value).to.equal(5)
            expect(stats.diameter).to.equal(4)
            expect(stats.thickness).to.equal(0.4)
            expect(stats.color).to.equal(BrickColor.new("Really red"))
        end)

        it("should return correct stats for a regular coin", function()
            local stats = CoinManager.Logic.getCoinStats(false)
            
            expect(stats.value).to.equal(1)
            expect(stats.diameter).to.equal(2.5)
            expect(stats.thickness).to.equal(0.2)
            expect(stats.color).to.equal(BrickColor.new("Bright yellow"))
        end)
    end)
    
    describe("CoinManager Engine Logic", function()
        local Workspace = game:GetService("Workspace")
        local CollectionService = game:GetService("CollectionService")
        
        it("should create a collect effect", function()
            local pos = Vector3.new(10, 20, 30)
            local color = Color3.new(1, 0, 0)
            
            CoinManager.createCollectEffect(pos, color)
            
            -- the attachment is parented to Workspace.Terrain
            local foundAttachment = false
            for _, child in pairs(Workspace.Terrain:GetChildren()) do
                if child:IsA("Attachment") and child.Position == pos then
                    foundAttachment = true
                    break
                end
            end
            expect(foundAttachment).to.equal(true)
        end)

        it("should spawn a coin", function()
            -- Find the coins before we spawn
            local oldCoins = {}
            for _, c in pairs(CollectionService:GetTagged("AnimatedCoin")) do
                oldCoins[c] = true
            end
            
            local startCount = #CollectionService:GetTagged("AnimatedCoin")
            CoinManager.spawnCoin()
            local endCount = #CollectionService:GetTagged("AnimatedCoin")
            
            expect(endCount).to.equal(startCount + 1)
            
            -- Clean up ONLY the coin spawned by the test so it doesn't leak into the actual game
            for _, coin in pairs(CollectionService:GetTagged("AnimatedCoin")) do
                if not oldCoins[coin] and coin.Parent == Workspace then
                    coin:Destroy()
                end
            end
        end)
    end)
end
