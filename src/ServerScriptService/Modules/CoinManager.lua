--!strict
local CoinManager = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

export type CoinStats = {
    value: number,
    diameter: number,
    thickness: number,
    color: BrickColor
}

-- ==========================================
-- 1. PURE LOGIC (Ideal for testing)
-- ==========================================
CoinManager.Logic = {}

-- Check if a rare coin should drop (20% chance)
function CoinManager.Logic.isRare(randomRoll: number): boolean
    return randomRoll <= 20
end

-- Get all coin stats based on rarity
function CoinManager.Logic.getCoinStats(isRare: boolean): CoinStats
    if isRare then
        return { value = 5, diameter = 4, thickness = 0.4, color = BrickColor.new("Really red") }
    else
        return { value = 1, diameter = 2.5, thickness = 0.2, color = BrickColor.new("Bright yellow") }
    end
end

-- ==========================================
-- 2. ROBLOX ENGINE LOGIC (Effects and Spawn)
-- ==========================================
function CoinManager.createCollectEffect(position: Vector3, color: Color3)
    local attachment = Instance.new("Attachment")
    attachment.Position = position
    attachment.Parent = Workspace.Terrain

    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(color)
    particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
    particle.Speed = NumberRange.new(15, 25)
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.Parent = attachment

    particle:Emit(30)
    Debris:AddItem(attachment, 1.5)
end

function CoinManager.spawnCoin()
    -- Use our testable logic
    local randomRoll = math.random(1, 100)
    local isRare = CoinManager.Logic.isRare(randomRoll)
    local stats = CoinManager.Logic.getCoinStats(isRare)

    -- Create physical object (Hitbox only)
    local coin = Instance.new("Part")
    coin.Name = isRare and "RareCoin" or "Coin"
    coin.Shape = Enum.PartType.Cylinder
    coin.Size = Vector3.new(stats.thickness, stats.diameter, stats.diameter)
    
    -- === NEW SAFE SPAWN LOGIC ===
    local startY = 4 
    local finalPos = Vector3.new(0, startY, 0)

    -- Give the server 15 attempts to find an empty spot
    for _ = 1, 15 do
        local testPos = Vector3.new(math.random(-20, 20), startY, math.random(-20, 20))
        
        -- Virtually check a box the size of the coin at this point
        local partsInside = Workspace:GetPartBoundsInBox(CFrame.new(testPos), coin.Size)

        -- If the array is empty, there is nothing at this spot
        if #partsInside == 0 then
            finalPos = testPos
            break -- Found a free spot, break out of the loop!
        end
    end

    coin.Position = finalPos
    -- =======================================
    coin.Transparency = 1 -- Invisible on the server
    coin.BrickColor = stats.color
    coin.Material = Enum.Material.Neon
    coin.Anchored = true
    coin.CanCollide = false
    
    -- Tag the coin so the client knows to animate it
    CollectionService:AddTag(coin, "AnimatedCoin")

    coin.Parent = Workspace

    -- Setup Memory Management
    local coinTrove = Trove.new()
    coinTrove:AttachToInstance(coin) -- Ensures trove cleans up if coin is destroyed externally

    -- Collecting event
    local touchConnection = coin.Touched:Connect(function(otherPart)
        CoinManager.handleCoinTouched(otherPart, coin, coinTrove, stats)
    end)
    
    coinTrove:Add(touchConnection)
end

function CoinManager.handleCoinTouched(otherPart: BasePart, coin: BasePart, coinTrove: any, stats: CoinStats)
    local character = otherPart.Parent
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoid then
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            local collectPos = coin.Position
            local collectColor = coin.Color

            -- This will disconnect touched event and destroy the coin
            coinTrove:Clean() 
            if coin and coin.Parent then
                coin:Destroy()
            end

            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local coins = leaderstats:FindFirstChild("Coins")
                if coins and coins:IsA("IntValue") then
                    coins.Value += stats.value
                end
            end
            
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://127645268874265"
            sound.Volume = 0.8
            sound.Parent = character:FindFirstChild("Head") or Workspace
            sound:Play()
            Debris:AddItem(sound, 2)

            CoinManager.createCollectEffect(collectPos, collectColor)
            
            task.wait(1)
            CoinManager.spawnCoin()
        end
    end
end

return CoinManager
