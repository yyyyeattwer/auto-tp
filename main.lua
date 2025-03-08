local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")


local screenGui = Instance.new("ScreenGui")
local toggleButton = Instance.new("TextButton")
local uiCorner = Instance.new("UICorner")
local uiGradient = Instance.new("UIGradient")

screenGui.Parent = game.CoreGui
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 140, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Auto TP: OFF"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleButton.BorderSizePixel = 0

-- Rounded corners
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = toggleButton

-- Gradient effect
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 70))
}
uiGradient.Rotation = 90
uiGradient.Parent = toggleButton

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

toggleButton.MouseEnter:Connect(function()
    toggleButton.TextSize = 18
end)

toggleButton.MouseLeave:Connect(function()
    toggleButton.TextSize = 16
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
