local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyGUI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.Active = true
MainFrame.Draggable = true
local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.ZIndex = 2
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Text = "By SigmaScripts"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 10)
local FlyButton = Instance.new("TextButton")
FlyButton.Name = "FlyButton"
FlyButton.Parent = MainFrame
FlyButton.Text = "OFF"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.TextSize = 16
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FlyButton.Size = UDim2.new(0.8, 0, 0, 40)
FlyButton.Position = UDim2.new(0.1, 0, 0.3, 0)
local FlyButtonCorner = Instance.new("UICorner")
FlyButtonCorner.Parent = FlyButton
FlyButtonCorner.CornerRadius = UDim.new(0, 8)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = MainFrame
SpeedLabel.Text = "Speed: 50"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Size = UDim2.new(0.8, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.1, 0, 0.65, 0)
local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Parent = MainFrame
SpeedSlider.Text = ""
SpeedSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SpeedSlider.Size = UDim2.new(0.8, 0, 0, 10)
SpeedSlider.Position = UDim2.new(0.1, 0, 0.8, 0)
local SpeedFill = Instance.new("Frame")
SpeedFill.Name = "SpeedFill"
SpeedFill.Parent = SpeedSlider
SpeedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpeedFill.Size = UDim2.new(0.5, 0, 1, 0)
SpeedFill.BorderSizePixel = 0
local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = SpeedSlider
UICorner2.CornerRadius = UDim.new(0, 5)
local flying = false
local flySpeed = 50
local bodyVelocity
local bodyGyro
local flyConnection
local function startFlying()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    flying = true
    FlyButton.Text = "ON"
    FlyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = character.HumanoidRootPart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 10000
    bodyGyro.D = 500
    bodyGyro.CFrame = character.HumanoidRootPart.CFrame
    bodyGyro.Parent = character.HumanoidRootPart
    flyConnection = RunService.Heartbeat:Connect(function(dt)
        if not flying or not character or not character:FindFirstChild("HumanoidRootPart") then
            flyConnection:Disconnect()
            return
        end
        local root = character.HumanoidRootPart
        local camera = workspace.CurrentCamera
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Period) then -- .
            direction = direction + Vector3.new(0, 1, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Comma) then -- ,
            direction = direction + Vector3.new(0, -1, 0)
        end
        if direction.Magnitude > 0 then
            direction = direction.Unit * flySpeed
        end
        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = camera.CFrame
    end)
end
local function stopFlying()
    flying = false
    FlyButton.Text = "OFF"
    FlyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    
    if flyConnection then
        flyConnection:Disconnect()
    end
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end
FlyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)
local speedDragging = false
SpeedSlider.MouseButton1Down:Connect(function()
    speedDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = SpeedSlider.AbsolutePosition
        local sliderSize = SpeedSlider.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
        SpeedFill.Size = UDim2.new(relativeX, 0, 1, 0)
        
        flySpeed = math.floor(10 + relativeX * 90)
        SpeedLabel.Text = "Speed: " .. flySpeed
    end
end)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if flying then
        stopFlying()
    end
end)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    if flying then
        stopFlying()
    end
end)