-- selene:allow(undefined_variable)
return function()
    local ClientCoinAnimator = require(script.Parent.ClientCoinAnimator)
    local Workspace = game:GetService("Workspace")

    beforeEach(function()
        -- Reset state
        ClientCoinAnimator.activeCoins = {}
    end)

    describe("ClientCoinAnimator.onCoinAdded", function()
        it("should ignore non-BaseParts", function()
            local folder = Instance.new("Folder")
            ClientCoinAnimator.onCoinAdded(folder :: any)
            local count = 0
            for _ in pairs(ClientCoinAnimator.activeCoins) do count += 1 end
            expect(count).to.equal(0)
            folder:Destroy()
        end)

        it("should create a visual clone for a valid coin", function()
            local coin = Instance.new("Part")
            coin.Name = "TestCoin"
            coin.Position = Vector3.new(10, 20, 30)

            ClientCoinAnimator.onCoinAdded(coin)

            local data = ClientCoinAnimator.activeCoins[coin]
            expect(data).to.be.ok()
            expect(data.startPos).to.equal(Vector3.new(10, 20, 30))
            
            local clone = data.part
            expect(clone).to.be.ok()
            expect(clone.Name).to.equal("VisualTestCoin")
            expect(clone.Size).to.equal(Vector3.new(0.01, 0.01, 0.01))
            expect(clone.CanCollide).to.equal(false)
            expect(clone.Anchored).to.equal(true)
            expect(clone.Parent).to.equal(Workspace)
            
            clone:Destroy()
            coin:Destroy()
        end)
    end)

    describe("ClientCoinAnimator.onCoinRemoved", function()
        it("should remove tracking and destroy clone", function()
            local coin = Instance.new("Part")
            
            -- Add first
            ClientCoinAnimator.onCoinAdded(coin)
            local data = ClientCoinAnimator.activeCoins[coin]
            expect(data).to.be.ok()
            local clone = data.part

            -- Then remove
            ClientCoinAnimator.onCoinRemoved(coin)

            expect(ClientCoinAnimator.activeCoins[coin]).to.equal(nil)
            expect(clone.Parent).to.equal(nil) -- Assuming Destroy sets Parent to nil

            coin:Destroy()
        end)
    end)
end
