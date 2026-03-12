-- selene:allow(undefined_variable)
return function()
    local ShopManager = require(script.Parent.ShopManager)

    describe("ShopManager Initialization", function()
        it("should initialize without errors", function()
            expect(function()
                ShopManager.init()
            end).never.to.throw()
        end)
    end)
    
    describe("ShopManager.processPurchase", function()
        local function createMockPlayer(coinsAmount)
            local player = {}
            local attributes = {
                SpeedPurchases = 0,
                JumpPurchases = 0
            }
            
            function player:GetAttribute(name)
                return attributes[name] or 0
            end
            
            function player:SetAttribute(name, value)
                attributes[name] = value
            end
            
            local leaderstats = {
                FindFirstChild = function(_, name)
                    if name == "Coins" then
                        return {Value = coinsAmount}
                    end
                    return nil
                end
            }
            
            function player:FindFirstChild(name)
                if name == "leaderstats" then
                    return leaderstats
                end
                return nil
            end
            
            local humanoid = {
                WalkSpeed = 16,
                JumpHeight = 50,
                UseJumpPower = true
            }
            
            local character = {
                FindFirstChild = function(_, name)
                    if name == "Humanoid" then
                        return humanoid
                    end
                    return nil
                end
            }
            
            player.Character = character
            
            return player, attributes, leaderstats.FindFirstChild(nil, "Coins"), humanoid
        end
        
        it("should fail when buying an invalid item", function()
            local success, msg = ShopManager.processPurchase({}, "InvalidItemXYZ")
            expect(success).to.equal(false)
            expect(msg).to.equal("Item not found!")
        end)
        
        it("should fail when player does not have enough coins", function()
            local player = createMockPlayer(5) -- Speed costs 10 base
            local success, msg = ShopManager.processPurchase(player, "Speed")
            expect(success).to.equal(false)
            expect(msg).to.equal("Need 10 coins!")
        end)
        
        it("should succeed and apply boost on valid purchase", function()
            local player, attrs, coins, humanoid = createMockPlayer(20)
            local success, msg = ShopManager.processPurchase(player, "Speed")
            
            expect(success).to.equal(true)
            expect(msg).to.equal("Success!")
            expect(coins.Value).to.equal(10) -- 20 - 10
            expect(attrs.SpeedPurchases).to.equal(1)
            expect(humanoid.WalkSpeed).to.equal(20) -- 16 + 4
        end)
        
        it("should increase cost exponentially for subsequent purchases", function()
            local player, attrs, coins, humanoid = createMockPlayer(100)
            
            -- Base cost is 10. math.pow(2, 0) = 1. Cost is 10.
            local success1 = ShopManager.processPurchase(player, "Speed")
            expect(success1).to.equal(true)
            expect(coins.Value).to.equal(90) -- 100 - 10
            expect(attrs.SpeedPurchases).to.equal(1)
            
            -- Second purchase. math.pow(2, 1) = 2. Cost is 20.
            local success2 = ShopManager.processPurchase(player, "Speed")
            expect(success2).to.equal(true)
            expect(coins.Value).to.equal(70) -- 90 - 20
            expect(attrs.SpeedPurchases).to.equal(2)
            expect(humanoid.WalkSpeed).to.equal(24) -- 16 + 4 + 4
            
            -- Third purchase. math.pow(2, 2) = 4. Cost is 40.
            local success3 = ShopManager.processPurchase(player, "Speed")
            expect(success3).to.equal(true)
            expect(coins.Value).to.equal(30) -- 70 - 40
            expect(attrs.SpeedPurchases).to.equal(3)
            
            -- Fourth purchase. math.pow(2, 3) = 8. Cost is 80 -> Should fail, only has 30
            local success4, msg = ShopManager.processPurchase(player, "Speed")
            expect(success4).to.equal(false)
            expect(msg).to.equal("Need 80 coins!")
        end)
        
        it("should apply jump upgrade correctly", function()
            local player, attrs, coins, humanoid = createMockPlayer(15) -- Math.pow(2, 0) * 15 = 15
            local success = ShopManager.processPurchase(player, "Jump")
            
            expect(success).to.equal(true)
            expect(coins.Value).to.equal(0)
            expect(attrs.JumpPurchases).to.equal(1)
            expect(humanoid.UseJumpPower).to.equal(false)
            expect(humanoid.JumpHeight).to.equal(55) -- 50 + 5
        end)
    end)
    
    describe("ShopManager.applyUpgrades", function()
        local function createMockPlayerAndCharacter(speedPurchases, jumpPurchases)
            local player = {}
            function player:GetAttribute(name)
                if name == "SpeedPurchases" then
                    return speedPurchases
                elseif name == "JumpPurchases" then
                    return jumpPurchases
                end
                return 0
            end
            
            local humanoid = {
                WalkSpeed = 16,
                JumpHeight = 50,
                UseJumpPower = true
            }
            
            local character = {
                WaitForChild = function(_, name)
                    if name == "Humanoid" then
                        return humanoid
                    end
                    return nil
                end
            }
            
            return player, character, humanoid
        end
        
        it("should safely return if humanoid is missing", function()
            local player = {}
            local character = {
                WaitForChild = function() return nil end
            }
            expect(function()
                ShopManager.applyUpgrades(player, character)
            end).never.to.throw()
        end)
        
        it("should not change anything if no upgrades", function()
            local player, character, humanoid = createMockPlayerAndCharacter(0, 0)
            ShopManager.applyUpgrades(player, character)
            
            expect(humanoid.WalkSpeed).to.equal(16)
            expect(humanoid.JumpHeight).to.equal(50)
            expect(humanoid.UseJumpPower).to.equal(true)
        end)
        
        it("should apply correct boosters based on purchases", function()
            local player, character, humanoid = createMockPlayerAndCharacter(2, 3)
            ShopManager.applyUpgrades(player, character)
            
            expect(humanoid.WalkSpeed).to.equal(16 + (4 * 2)) -- 24
            expect(humanoid.JumpHeight).to.equal(50 + (5 * 3)) -- 65
            expect(humanoid.UseJumpPower).to.equal(false)
        end)
    end)
end
