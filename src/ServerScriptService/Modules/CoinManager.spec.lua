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
end
