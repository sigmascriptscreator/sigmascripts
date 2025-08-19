local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Настройки по умолчанию
local SETTINGS = {
    SHOW_HITBOXES = false
}

-- Состояние системы
local hitboxes = {} -- Таблица для хранения хитбоксов
local gui = nil
local dragging = false
local dragStartPos = Vector2.new(0, 0)
local frameStartPos = Vector2.new(0, 0)

-- Создание/удаление хитбоксов
local function updateHitboxes()
    for player, parts in pairs(hitboxes) do
        for _, part in pairs(parts) do
            part:Destroy()
        end
    end
    hitboxes = {}

    if not SETTINGS.SHOW_HITBOXES then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            hitboxes[player] = {}
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local hitbox = Instance.new("BoxHandleAdornment")
                    hitbox.Name = "HitboxVisualizer"
                    hitbox.Adornee = part
                    hitbox.AlwaysOnTop = true
                    hitbox.ZIndex = 10
                    hitbox.Size = part.Size
                    hitbox.Transparency = 0.7
                    hitbox.Color3 = Color3.fromRGB(0, 255, 255)
                    hitbox.Parent = part
                    table.insert(hitboxes[player], hitbox)
                end
            end
        end
    end
end

-- Создание интерфейса
local function createGUI()
    if gui then gui:Destroy() end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "ESPUI"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 80)
    mainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- UICorner для основного фрейма
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 20)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- UICorner для заголовка (только верхние углы)
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    local title = Instance.new("TextLabel")
    title.Text = "By SigmaScripts"
    title.Size = UDim2.new(1, -25, 1, 0)
    title.Position = UDim2.new(0, 60, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, 0, 0, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 1
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundTransparency = 0.9
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end)
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundTransparency = 1
    end)
    closeButton.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    local hitboxBtn = Instance.new("TextButton")
    hitboxBtn.Text = "ESP: " .. (SETTINGS.SHOW_HITBOXES and "ON" or "OFF")
    hitboxBtn.Size = UDim2.new(0.9, 0, 0, 30)
    hitboxBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
    hitboxBtn.BackgroundColor3 = SETTINGS.SHOW_HITBOXES and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
    hitboxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hitboxBtn.Font = Enum.Font.Gotham
    hitboxBtn.TextSize = 14
    hitboxBtn.Parent = mainFrame
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = hitboxBtn
    hitboxBtn.MouseButton1Click:Connect(function()
        SETTINGS.SHOW_HITBOXES = not SETTINGS.SHOW_HITBOXES
        hitboxBtn.Text = "ESP: " .. (SETTINGS.SHOW_HITBOXES and "ON" or "OFF")
        hitboxBtn.BackgroundColor3 = SETTINGS.SHOW_HITBOXES and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        updateHitboxes()
    end)
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = Vector2.new(mainFrame.Position.X.Offset, mainFrame.Position.Y.Offset)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = mousePos - dragStartPos
            local newX = frameStartPos.X + delta.X
            local newY = frameStartPos.Y + delta.Y
            newX = math.clamp(newX, 0, workspace.CurrentCamera.ViewportSize.X - mainFrame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, workspace.CurrentCamera.ViewportSize.Y - mainFrame.AbsoluteSize.Y)
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        if SETTINGS.SHOW_HITBOXES then
            updateHitboxes()
        end
    end)
    player.CharacterRemoving:Connect(function()
        if hitboxes[player] then
            for _, part in pairs(hitboxes[player]) do
                part:Destroy()
            end
            hitboxes[player] = nil
        end
    end)
end
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    if hitboxes[player] then
        for _, part in pairs(hitboxes[player]) do
            part:Destroy()
        end
        hitboxes[player] = nil
    end
end)
createGUI()
game:BindToClose(function()
    if gui then
        gui:Destroy()
    end
    for _, playerParts in pairs(hitboxes) do
        for _, part in pairs(playerParts) do
            part:Destroy()
        end
    end
end)