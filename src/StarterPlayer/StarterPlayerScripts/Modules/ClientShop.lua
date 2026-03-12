--!strict
local ClientShop = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function ClientShop.init()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    
    local PlayerGui = localPlayer:WaitForChild("PlayerGui")
    
    -- Wait for the purchase function to appear from the server
    local buyItemFunc = ReplicatedStorage:WaitForChild("BuyItem") :: RemoteFunction

    -- 1. Create the interface
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShopGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- Shop open button (middle left)
    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0, 120, 0, 50)
    openButton.Position = UDim2.new(0, 20, 0.5, -25)
    openButton.Text = "🛒 Shop"
    openButton.Font = Enum.Font.FredokaOne
    openButton.TextScaled = true
    openButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    openButton.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)
    
    -- ADDED: Padding for the Shop button (so icon and text don't stick to edges)
    local openPadding = Instance.new("UIPadding", openButton)
    openPadding.PaddingLeft = UDim.new(0, 12)
    openPadding.PaddingRight = UDim.new(0, 12)
    openPadding.PaddingTop = UDim.new(0, 8)
    openPadding.PaddingBottom = UDim.new(0, 8)

    openButton.Parent = screenGui

    -- Background button to close shop when clicking outside
    local closeBackground = Instance.new("TextButton")
    closeBackground.Name = "CloseBackground"
    closeBackground.Size = UDim2.new(1, 0, 1, 0)
    closeBackground.BackgroundTransparency = 1
    closeBackground.Text = ""
    closeBackground.Visible = false
    closeBackground.Parent = screenGui

    -- Main shop panel (center screen, hidden by default)
    local shopFrame = Instance.new("Frame")
    shopFrame.Size = UDim2.new(0, 300, 0, 260) -- Increased panel height for coin balance
    shopFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
    shopFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    shopFrame.BackgroundTransparency = 0.1
    shopFrame.Visible = false
    shopFrame.Active = true -- Prevent clicks passing through to the background
    Instance.new("UICorner", shopFrame).CornerRadius = UDim.new(0, 15)
    shopFrame.Parent = screenGui

    -- Panel title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "UPGRADE SHOP"
    title.Font = Enum.Font.FredokaOne
    title.TextScaled = true
    title.TextColor3 = Color3.new(1, 0.8, 0)
    title.BackgroundTransparency = 1
    
    -- ADDED: Padding for the title
    local titlePadding = Instance.new("UIPadding", title)
    titlePadding.PaddingTop = UDim.new(0, 20)
    titlePadding.PaddingBottom = UDim.new(0, 4)
    
    title.Parent = shopFrame

    -- ADDED: Display current coin balance
    local coinsDisplay = Instance.new("TextLabel")
    coinsDisplay.Size = UDim2.new(1, 0, 0, 25)
    coinsDisplay.Position = UDim2.new(0, 0, 0, 50) -- Position right below the title
    coinsDisplay.Font = Enum.Font.GothamMedium
    coinsDisplay.TextScaled = true
    coinsDisplay.TextColor3 = Color3.new(1, 0.9, 0)
    coinsDisplay.BackgroundTransparency = 1
    coinsDisplay.Text = "💰 Coins: 0"
    
    local coinsDisplayPadding = Instance.new("UIPadding", coinsDisplay)
    coinsDisplayPadding.PaddingTop = UDim.new(0, 4)
    coinsDisplayPadding.PaddingBottom = UDim.new(0, 4)
    
    coinsDisplay.Parent = shopFrame

    -- Logic for updating balance in the shop interface
    task.spawn(function()
        local leaderstats = localPlayer:WaitForChild("leaderstats", 10)
        if leaderstats then
            local coins = leaderstats:WaitForChild("Coins", 10)
            if coins and coins:IsA("IntValue") then
                -- Initial value
                coinsDisplay.Text = "💰 Coins: " .. tostring(coins.Value)
                -- Subscribe to changes
                coins.Changed:Connect(function(newVal)
                    coinsDisplay.Text = "💰 Coins: " .. tostring(newVal)
                end)
            end
        end
    end)

    -- Updated function to generate purchase buttons
    local function createBuyButton(id: string, text: string, baseCost: number, yPos: number)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 55) -- Slightly increased button height
        btn.Position = UDim2.new(0.1, 0, 0, yPos)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        btn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        -- ADDED: Padding inside purchase buttons
        local btnPadding = Instance.new("UIPadding", btn)
        btnPadding.PaddingTop = UDim.new(0, 8)
        btnPadding.PaddingBottom = UDim.new(0, 8)
        btnPadding.PaddingLeft = UDim.new(0, 10)
        btnPadding.PaddingRight = UDim.new(0, 10)
        
        btn.Parent = shopFrame

        -- Function that updates the text on the button
        local function updateButtonText()
            local purchases = localPlayer:GetAttribute(id .. "Purchases") or 0
            local currentCost = baseCost * (math.pow(2, purchases))
            btn.Text = text .. "\n(" .. currentCost .. " coins)"
        end

        -- Set the initial text
        updateButtonText()

        -- Automatically update text whenever the purchase counter changes!
        localPlayer:GetAttributeChangedSignal(id .. "Purchases"):Connect(updateButtonText)

        btn.MouseButton1Click:Connect(function()
            -- Send request to server
            local success, message = buyItemFunc:InvokeServer(id)
            
            -- Show message from server
            btn.Text = message
            if success then
                btn.BackgroundColor3 = Color3.new(1, 0.8, 0) -- Yellow (success)
            else
                btn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2) -- Red (error)
            end
            
            -- After 1.5 seconds, revert to normal color and new price
            task.wait(1.5)
            updateButtonText()
            btn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        end)
    end

    -- Add items to the storefront (passing the base price)
    -- Shifted buttons slightly lower (from 60/130 to 75/145) to make room for coins
    createBuyButton("Speed", "🏃 +Speed", 10, 75)
    createBuyButton("Jump", "⬆️ +Jump", 15, 145)

    -- "Open/Close" button logic
    openButton.MouseButton1Click:Connect(function()
        local newState = not shopFrame.Visible
        shopFrame.Visible = newState
        closeBackground.Visible = newState
    end)

    -- Close shop when clicking outside it
    closeBackground.MouseButton1Click:Connect(function()
        shopFrame.Visible = false
        closeBackground.Visible = false
    end)
end

return ClientShop