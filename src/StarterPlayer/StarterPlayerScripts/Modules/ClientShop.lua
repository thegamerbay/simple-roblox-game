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
    openButton.Parent = screenGui

    -- Main shop panel (center screen, hidden by default)
    local shopFrame = Instance.new("Frame")
    shopFrame.Size = UDim2.new(0, 300, 0, 220)
    shopFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
    shopFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    shopFrame.BackgroundTransparency = 0.1
    shopFrame.Visible = false
    Instance.new("UICorner", shopFrame).CornerRadius = UDim.new(0, 15)
    shopFrame.Parent = screenGui

    -- Panel title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "UPGRADE SHOP"
    title.Font = Enum.Font.FredokaOne
    title.TextScaled = true
    title.TextColor3 = Color3.new(1, 0.8, 0)
    title.BackgroundTransparency = 1
    title.Parent = shopFrame

    -- Updated function to generate purchase buttons
    local function createBuyButton(id: string, text: string, baseCost: number, yPos: number)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.8, 0, 0, 50)
        btn.Position = UDim2.new(0.1, 0, 0, yPos)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        btn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
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
    createBuyButton("Speed", "🏃 +Speed", 10, 60)
    createBuyButton("Jump", "⬆️ +Jump", 15, 130)

    -- "Open/Close" button logic
    openButton.MouseButton1Click:Connect(function()
        shopFrame.Visible = not shopFrame.Visible
    end)
end

return ClientShop
