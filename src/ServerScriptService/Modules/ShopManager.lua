--!strict
local ShopManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Item database (baseCost - starting price)
local SHOP_ITEMS = {
    Speed = { name = "Walk Speed", baseCost = 10, walkSpeedBoost = 4 },
    Jump = { name = "Jump Height", baseCost = 15, jumpHeightBoost = 5 }
}

function ShopManager.init()
    local buyEvent = Instance.new("RemoteFunction")
    buyEvent.Name = "BuyItem"
    buyEvent.Parent = ReplicatedStorage

    buyEvent.OnServerInvoke = ShopManager.processPurchase
end

function ShopManager.processPurchase(player: Player, itemId: string)
    local item = SHOP_ITEMS[itemId]
    if not item then return false, "Item not found!" end

    local purchases = player:GetAttribute(itemId .. "Purchases") or 0
    local currentCost = item.baseCost * (math.pow(2, purchases))

    local leaderstats = player:FindFirstChild("leaderstats")
    local coins = leaderstats and leaderstats:FindFirstChild("Coins") :: IntValue
    
    if coins and coins.Value >= currentCost then
        coins.Value -= currentCost 
        player:SetAttribute(itemId .. "Purchases", purchases + 1)
        
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid") :: Humanoid
        
        if humanoid then
            if item.walkSpeedBoost then
                humanoid.WalkSpeed += item.walkSpeedBoost
            end
            if item.jumpHeightBoost then
                humanoid.UseJumpPower = false
                humanoid.JumpHeight += item.jumpHeightBoost
            end
        end
        
        return true, "Success!"
    else
        return false, "Need " .. tostring(currentCost) .. " coins!"
    end
end

-- NEW FUNCTION: Applies all saved upgrades after death or joining the game
function ShopManager.applyUpgrades(player: Player, character: Model)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    if not humanoid then return end
    
    local speedPurchases = player:GetAttribute("SpeedPurchases") or 0
    local jumpPurchases = player:GetAttribute("JumpPurchases") or 0

    -- If the player has speed purchases, multiply the boost by their amount
    if speedPurchases > 0 then
        humanoid.WalkSpeed += (SHOP_ITEMS.Speed.walkSpeedBoost * speedPurchases)
    end

    -- Same logic for jump height
    if jumpPurchases > 0 then
        humanoid.UseJumpPower = false
        humanoid.JumpHeight += (SHOP_ITEMS.Jump.jumpHeightBoost * jumpPurchases)
    end
end

return ShopManager
