-- ==========================================
-- なべHUBv1 (認証なし・即起動)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not OrionLib then
    warn("OrionLib 読み込み失敗")
    return
end

-- ========== ウィンドウ構築 ==========
local MainWindow = OrionLib:MakeWindow({
    Name = "なべHUBv1",
    HidePremium = true,
    SaveConfig = false,
    Searchable = false,
    ThemeColor = Color3.fromRGB(255, 140, 0),
    BackgroundColor = Color3.fromRGB(40, 30, 20)
})

-- Mineタブ（空）
local MineTab = MainWindow:MakeTab({
    Name = "Mine",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ==================== プレイヤータブ ====================
local PlayerTab = MainWindow:MakeTab({
    Name = "プレイヤー",
    Icon = "rbxassetid://6031094678",
    PremiumOnly = false
})

-- ==================== 変数 ====================
local WalkSpeedValue = 16
local JumpPowerValue = 50
local GravityValue = 196.2

local SpeedEnabled = false
local InfiniteJumpEnabled = false
local NoclipEnabled = false
local GravityEnabled = false

-- ==================== ESP変数 ====================
local ESPEnabled = false
local ESPObjects = {}
local ESPConnection = nil

local ShowBox = true
local ShowName = true
local ShowHealthBar = true
local ShowDistance = true
local ShowTracers = true

-- ==================== 基本関数 ====================
local function applyCharacterSettings(character)
    task.wait(0.6)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if SpeedEnabled then humanoid.WalkSpeed = WalkSpeedValue end
    humanoid.JumpPower = JumpPowerValue
    humanoid.JumpHeight = JumpPowerValue * 0.6
end

local function resetGravity()
    Workspace.Gravity = 196.2
end

-- ==================== 高性能ESP ====================
local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2; box.Filled = false; box.Color = Color3.fromRGB(255, 50, 50); box.Transparency = 1

    local nameText = Drawing.new("Text")
    nameText.Size = 16; nameText.Center = true; nameText.Outline = true; nameText.Color = Color3.fromRGB(255, 255, 255)

    local distanceText = Drawing.new("Text")
    distanceText.Size = 14; distanceText.Center = true; distanceText.Outline = true; distanceText.Color = Color3.fromRGB(200, 200, 200)

    local healthBarOutline = Drawing.new("Square")
    healthBarOutline.Thickness = 1; healthBarOutline.Filled = false; healthBarOutline.Color = Color3.fromRGB(0, 0, 0)

    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1; healthBar.Filled = true; healthBar.Color = Color3.fromRGB(0, 255, 0)

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1.5; tracer.Color = Color3.fromRGB(255, 50, 50); tracer.Transparency = 0.7

    ESPObjects[player] = {Box = box, Name = nameText, Distance = distanceText, HealthBar = healthBar, HealthOutline = healthBarOutline, Tracer = tracer}
end

local function updateESP()
    if not ESPEnabled then return end
    for player, drawings in pairs(ESPObjects) do
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(drawings) do v.Visible = false end
            continue
        end

        local root = character.HumanoidRootPart
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChild("Humanoid")
        if not head or not humanoid then continue end

        local camera = Workspace.CurrentCamera
        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen then 
            for _, v in pairs(drawings) do v.Visible = false end
            continue 
        end

        local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))

        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.6

        -- Box
        drawings.Box.Size = Vector2.new(width, height)
        drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        drawings.Box.Visible = ShowBox

        -- Name
        drawings.Name.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
        drawings.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 22)
        drawings.Name.Visible = ShowName

        -- Distance
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
        drawings.Distance.Text = dist .. " studs"
        drawings.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 8)
        drawings.Distance.Visible = ShowDistance

        -- Health Bar
        local hpPercent = humanoid.Health / humanoid.MaxHealth
        local barH = height * 0.8
        drawings.HealthOutline.Size = Vector2.new(4, barH)
        drawings.HealthOutline.Position = Vector2.new(rootPos.X - width/2 - 8, rootPos.Y - height/2)
        drawings.HealthOutline.Visible = ShowHealthBar

        drawings.HealthBar.Size = Vector2.new(4, barH * hpPercent)
        drawings.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 8, rootPos.Y - height/2 + barH * (1 - hpPercent))
        drawings.HealthBar.Visible = ShowHealthBar

        -- Tracer
        if ShowTracers and myRoot then
            drawings.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
        end
    end
end

-- ==================== ESP UI ====================
PlayerTab:AddToggle({
    Name = "高性能ESP 有効",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not ESPObjects[p] then createESP(p) end
            end
            ESPConnection = RunService.RenderStepped:Connect(updateESP)
        else
            if ESPConnection then ESPConnection:Disconnect() end
            for _, drawings in pairs(ESPObjects) do
                for _, obj in pairs(drawings) do if obj then obj:Remove() end end
            end
            ESPObjects = {}
        end
    end
})

PlayerTab:AddSection({Name = "ESP 表示設定"})
PlayerTab:AddToggle({Name = "Box 表示", Default = true, Callback = function(v) ShowBox = v end})
PlayerTab:AddToggle({Name = "名前 + 体力 表示", Default = true, Callback = function(v) ShowName = v end})
PlayerTab:AddToggle({Name = "体力バー 表示", Default = true, Callback = function(v) ShowHealthBar = v end})
PlayerTab:AddToggle({Name = "距離 表示", Default = true, Callback = function(v) ShowDistance = v end})
PlayerTab:AddToggle({Name = "Tracers 表示", Default = true, Callback = function(v) ShowTracers = v end})

-- ==================== 移動・その他機能 ====================
PlayerTab:AddSection({Name = "移動・物理設定"})

PlayerTab:AddSlider({
    Name = "移動速度", Min = 16, Max = 200, Default = 16,
    Color = Color3.fromRGB(0, 162, 255), Increment = 1, ValueName = " studs/s",
    Callback = function(v) WalkSpeedValue = v; if SpeedEnabled then
        local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
    end end
})

PlayerTab:AddToggle({
    Name = "カスタム移動速度有効", Default = false, Color = Color3.fromRGB(0, 162, 255),
    Callback = function(v) SpeedEnabled = v; local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v and WalkSpeedValue or 16 end end
})

PlayerTab:AddSlider({
    Name = "ジャンプ力", Min = 50, Max = 400, Default = 50,
    Color = Color3.fromRGB(0, 162, 255), Increment = 1, ValueName = " power",
    Callback = function(v)
        JumpPowerValue = v
        local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then
            c.Humanoid.JumpPower = v; c.Humanoid.JumpHeight = v * 0.6
        end
    end
})

PlayerTab:AddToggle({
    Name = "無限ジャンプ", Default = false, Color = Color3.fromRGB(0, 162, 255),
    Callback = function(v) InfiniteJumpEnabled = v end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local c = LocalPlayer.Character; local h = c and c:FindFirstChild("Humanoid")
        if h then h:ChangeState("Jumping") end
    end
end)

PlayerTab:AddToggle({
    Name = "壁抜け (Noclip)", Default = false, Color = Color3.fromRGB(0, 162, 255),
    Callback = function(v)
        NoclipEnabled = v
        local c = LocalPlayer.Character
        if c then for _, part in pairs(c:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = not v end end end
    end
})

PlayerTab:AddSlider({
    Name = "重力", Min = 0, Max = 400, Default = 196.2,
    Color = Color3.fromRGB(0, 162, 255), Increment = 0.1, ValueName = " gravity",
    Callback = function(v) GravityValue = v; if GravityEnabled then Workspace.Gravity = v end end
})

PlayerTab:AddToggle({
    Name = "カスタム重力有効", Default = false, Color = Color3.fromRGB(0, 162, 255),
    Callback = function(v) GravityEnabled = v; Workspace.Gravity = v and GravityValue or 196.2 end
})

-- リスポーン対応
LocalPlayer.CharacterAdded:Connect(applyCharacterSettings)
if LocalPlayer.Character then applyCharacterSettings(LocalPlayer.Character) end

-- ==================== 虹色枠エフェクト ====================
local function addRainbowBorder()
    task.wait(0.5)
    local mainFrame = nil
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:find("Orion") then
            mainFrame = gui:FindFirstChild("MainFrame") or gui:FindFirstChild("WindowFrame")
            if mainFrame then break end
        end
    end
    if not mainFrame then return end
    
    local old = mainFrame:FindFirstChild("RainbowBorder")
    if old then old:Destroy() end

    local border = Instance.new("Frame")
    border.Name = "RainbowBorder"
    border.Size = UDim2.new(1, 10, 1, 10)
    border.Position = UDim2.new(0, -5, 0, -5)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 0
    border.Parent = mainFrame

    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 1, 0)
    outer.BackgroundTransparency = 0.3
    outer.BorderSizePixel = 0
    outer.Parent = border

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,127,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
    }
    gradient.Parent = outer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = outer
end

addRainbowBorder()
task.spawn(function()
    while true do
        task.wait(3)
        addRainbowBorder()
    end
end)

OrionLib:Init()
print("✅ なべHUBv1 が正常に起動しました！")
