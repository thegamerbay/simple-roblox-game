--!strict
local ClientCoinAnimator = {}
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

ClientCoinAnimator.activeCoins = {}

-- Create a visual dummy for a given coin hitbox
function ClientCoinAnimator.onCoinAdded(coin: BasePart)
    if not coin:IsA("BasePart") then return end
    if ClientCoinAnimator.activeCoins[coin] then return end -- Prevent duplicates

    -- Generate purely visual replica
    local clone = Instance.new("Part")
    clone.Name = "Visual" .. coin.Name
    clone.Shape = coin.Shape
    clone.Size = coin.Size
    clone.BrickColor = coin.BrickColor
    clone.Material = coin.Material
    clone.Anchored = true
    clone.CanCollide = false
    clone.CastShadow = false -- Optimization
    clone.Position = coin.Position
    clone.Parent = Workspace
    
    ClientCoinAnimator.activeCoins[coin] = {
        part = clone,
        startPos = coin.Position,
        timePassed = 0
    }
end

-- Destroy the visual dummy when the server removes the hitbox
function ClientCoinAnimator.onCoinRemoved(coin: BasePart)
    local data = ClientCoinAnimator.activeCoins[coin]
    if data then
        if data.part then
            data.part:Destroy()
        end
        ClientCoinAnimator.activeCoins[coin] = nil
    end
end

-- Animate all visual dummies every frame
function ClientCoinAnimator.onRenderStepped(deltaTime: number)
    for coin, data in pairs(ClientCoinAnimator.activeCoins) do
        data.timePassed += deltaTime
        local rotation = CFrame.Angles(0, math.rad(100) * data.timePassed, 0)
        local hoverOffset = Vector3.new(0, math.sin(data.timePassed * 3) * 0.5, 0)
        
        -- Apply transformations to the purely visual clone
        if data.part and data.part.Parent then
            data.part.CFrame = CFrame.new(data.startPos + hoverOffset) * rotation
        end
    end
end

function ClientCoinAnimator.init()
    if ClientCoinAnimator.isInitialized then return {} end
    ClientCoinAnimator.isInitialized = true

    local connections = {}

    -- Animate all visual dummies every frame
    table.insert(connections, RunService.RenderStepped:Connect(ClientCoinAnimator.onRenderStepped))

    -- Monitor the CollectionService for existing and new coins
    table.insert(connections, CollectionService:GetInstanceAddedSignal("AnimatedCoin"):Connect(function(instance)
        ClientCoinAnimator.onCoinAdded(instance :: BasePart)
    end))

    table.insert(connections, CollectionService:GetInstanceRemovedSignal("AnimatedCoin"):Connect(function(instance)
        ClientCoinAnimator.onCoinRemoved(instance :: BasePart)
    end))

    -- Catch any coins that might have spawned before this specific script ran
    for _, instance in pairs(CollectionService:GetTagged("AnimatedCoin")) do
        ClientCoinAnimator.onCoinAdded(instance :: BasePart)
    end

    return connections
end

return ClientCoinAnimator
