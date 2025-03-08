local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local toggleButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local exitButton = Instance.new("TextButton")
local uiCorner = Instance.new("UICorner")
local uiGradient = Instance.new("UIGradient")

screenGui.Parent = game.CoreGui
mainFrame.Parent = screenGui
toggleButton.Parent = mainFrame
minimizeButton.Parent = mainFrame
exitButton.Parent = mainFrame

-- Main Frame (Centered with bounce effect)
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true

uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local function bounceEffect()
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    mainFrame.Visible = true
    local tween = tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Position = UDim2.new(0.5, -100, 0.5, -40)})
    tween:Play()
end

bounceEffect()


toggleButton.Size = UDim2.new(0, 140, 0, 50)
toggleButton.Position = UDim2.new(0, 30, 0, 10)
toggleButton.Text = "Auto TP: OFF"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BorderSizePixel = 0

uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 70))
}
uiGradient.Rotation = 90
uiGradient.Parent = toggleButton

toggleButton.Parent = mainFrame


minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -50, 0, 5)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)


exitButton.Size = UDim2.new(0, 20, 0, 20)
exitButton.Position = UDim2.new(1, -25, 0, 5)
exitButton.Text = "X"
exitButton.Font = Enum.Font.GothamBold
exitButton.TextSize = 16
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local autoTeleport = false
local lastTeleportTime = 0
local teleportCooldown = 2 

local function updateButton()
    toggleButton.Text = "Auto TP: " .. (autoTeleport and "ON" or "OFF")

    local goal = {BackgroundColor3 = autoTeleport and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(255, 50, 50)}
    local tween = tweenService:Create(toggleButton, TweenInfo.new(0.3), goal)
    tween:Play()

    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, autoTeleport and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)),
        ColorSequenceKeypoint.new(1, autoTeleport and Color3.fromRGB(70, 255, 70) or Color3.fromRGB(255, 70, 70))
    }
end

toggleButton.MouseButton1Click:Connect(function()
    autoTeleport = not autoTeleport
    updateButton()
end)

local function getCurrentWorld()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local worldValue = leaderstats:FindFirstChild("WORLD")
        if worldValue and worldValue:IsA("IntValue") then
            return tostring(worldValue.Value) -- Convert to string to match folder names
        end
    end
    return nil
end

local function findValidOrb()
    local world = getCurrentWorld()
    if not world then return end

    local worldFolder = workspace.Map.Stages.Boosts:FindFirstChild(world)
    if not worldFolder then return end

    for _, obj in ipairs(worldFolder:GetChildren()) do
        if obj:IsA("Model") and obj.Name:match("^MAP_" .. world .. "_%d$") then
            local num = tonumber(obj.Name:match("_(%d+)$"))
            if num and num > 2 then
                return obj
            end
        end
    end
end

local function teleportToOrb()
    local orb = findValidOrb()
    if orb and hrp then
        local currentTime = tick()
        if currentTime - lastTeleportTime >= teleportCooldown then
            lastTeleportTime = currentTime
            local orbPos = orb:GetPivot().Position
            hrp.CFrame = CFrame.new(orbPos + Vector3.new(0, 5, 0)) -- Teleport slightly above
        end
    end
end


runService.RenderStepped:Connect(function()
    if autoTeleport then
        teleportToOrb()
    end
end)


local minimized = false

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 200, 0, 25)})
        tween:Play()
        toggleButton.Visible = false
    else
        local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 200, 0, 80)})
        tween:Play()
        toggleButton.Visible = true
    end
end)

exitButton.MouseButton1Click:Connect(function()
    local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -100, 1.5, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPos
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)
