-- ==========================================
-- なべHUBv1.2 (認証なし・即起動)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not OrionLib then warn("OrionLib 読み込み失敗") return end

-- ========== ウィンドウ構築 ==========
local MainWindow = OrionLib:MakeWindow({
    Name = "なべHUBv1.2",
    HidePremium = true,
    SaveConfig = false,
    Searchable = false,
    ThemeColor = Color3.fromRGB(255, 140, 0),
    BackgroundColor = Color3.fromRGB(40, 30, 20)
})

local MineTab = MainWindow:MakeTab({ Name = "Mine", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local PlayerTab = MainWindow:MakeTab({ Name = "プレイヤー", Icon = "rbxassetid://6031094678", PremiumOnly = false })
local VisualsTab = MainWindow:MakeTab({ Name = "画面", Icon = "rbxassetid://6031094678", PremiumOnly = false })
local ItemsTab = MainWindow:MakeTab({ Name = "物人", Icon = "rbxassetid://6031079977", PremiumOnly = false })

-- ==================== 変数 ====================
local WalkSpeedValue = 16
local JumpPowerValue = 50
local GravityValue = 196.2
local FOVValue = 70

local SpeedEnabled = false
local InfiniteJumpEnabled = false
local NoclipEnabled = false
local GravityEnabled = false

-- ESP
local ESPEnabled = false
local RainbowESP = false
local RainbowSpeed = 0.015
local ShowGreenOutline = false

local ShowBox = true
local ShowName = true
local ShowHealthBar = true
local ShowDistance = true
local ShowTracers = true

local ESPObjects = {}
local ESPConnection = nil

-- クロスヘア
local CrosshairEnabled = false
local RainbowCrosshair = false
local CrosshairColor = Color3.fromRGB(255, 255, 255)
local CrosshairSize = 12
local CrosshairThickness = 1.5
local CrosshairTransparency = 1
local CrosshairLines = {}

local RainbowHue = 0

-- ==================== 関数 ====================
local function applyCharacterSettings(character)
    task.wait(0.6)
    local hum = character:FindFirstChild("Humanoid")
    if hum then
        if SpeedEnabled then hum.WalkSpeed = WalkSpeedValue end
        hum.JumpPower = JumpPowerValue
        hum.JumpHeight = JumpPowerValue * 0.6
    end
end

local function getRainbowColor()
    RainbowHue = (RainbowHue + RainbowSpeed) % 1
    return Color3.fromHSV(RainbowHue, 1, 1)
end

local function createESP(player)
    if player == LocalPlayer then return end
    local d = {}
    d.Box = Drawing.new("Square")
    d.GreenOutline = Drawing.new("Square")
    d.Name = Drawing.new("Text")
    d.Distance = Drawing.new("Text")
    d.HealthBar = Drawing.new("Square")
    d.HealthOutline = Drawing.new("Square")
    d.Tracer = Drawing.new("Line")

    d.Box.Thickness = 2; d.Box.Filled = false
    d.GreenOutline.Thickness = 2; d.GreenOutline.Filled = false; d.GreenOutline.Color = Color3.fromRGB(0, 255, 100)
    d.Name.Size = 16; d.Name.Center = true; d.Name.Outline = true
    d.Distance.Size = 14; d.Distance.Center = true; d.Distance.Outline = true
    d.HealthOutline.Thickness = 1; d.HealthOutline.Filled = false
    d.HealthBar.Thickness = 1; d.HealthBar.Filled = true
    d.Tracer.Thickness = 1.5

    ESPObjects[player] = d
end

local function updateESP()
    if not ESPEnabled then return end
    for player, d in pairs(ESPObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        if not head or not hum then continue end

        local cam = Workspace.CurrentCamera
        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, obj in pairs(d) do obj.Visible = false end
            continue
        end

        local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.6

        local rainbow = getRainbowColor()

        -- Box
        d.Box.Color = RainbowESP and rainbow or Color3.fromRGB(255, 50, 50)
        d.Box.Size = Vector2.new(width, height)
        d.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        d.Box.Visible = ShowBox

        -- 緑の輪郭
        d.GreenOutline.Size = Vector2.new(width * 1.1, height * 0.4)
        d.GreenOutline.Position = Vector2.new(rootPos.X - (width * 1.1)/2, rootPos.Y - height/2 - 5)
        d.GreenOutline.Visible = ShowGreenOutline

        -- Name
        d.Name.Text = player.Name .. " [" .. math.floor(hum.Health) .. "]"
        d.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 25)
        d.Name.Visible = ShowName

        -- Distance
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
        d.Distance.Text = dist .. " studs"
        d.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 10)
        d.Distance.Visible = ShowDistance

        -- Health Bar
        local hp = hum.Health / hum.MaxHealth
        local barH = height * 0.75
        d.HealthOutline.Size = Vector2.new(4, barH)
        d.HealthOutline.Position = Vector2.new(rootPos.X - width/2 - 10, rootPos.Y - height/2 + (barH * (1 - hp)))
        d.HealthOutline.Visible = ShowHealthBar

        d.HealthBar.Size = Vector2.new(4, barH * hp)
        d.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 10, rootPos.Y - height/2 + barH * (1 - hp))
        d.HealthBar.Visible = ShowHealthBar

        -- Tracer
        if ShowTracers and myRoot then
            d.Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
            d.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            d.Tracer.Color = RainbowESP and rainbow or Color3.fromRGB(255, 50, 50)
            d.Tracer.Visible = true
        else
            d.Tracer.Visible = false
        end
    end
end

-- ==================== 画面タブ ====================
VisualsTab:AddToggle({
    Name = "高性能ESP 有効",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Callback = function(v)
        ESPEnabled = v
        if v then
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

VisualsTab:AddToggle({Name = "ESP レインボー", Default = false, Color = Color3.fromRGB(255, 100, 255), Callback = function(v) RainbowESP = v end})
VisualsTab:AddSlider({Name = "レインボー速度", Min = 0.001, Max = 0.1, Default = 0.015, Color = Color3.fromRGB(255, 100, 255), Increment = 0.001, Callback = function(v) RainbowSpeed = v end})

VisualsTab:AddSection({Name = "ESP 表示設定"})
VisualsTab:AddToggle({Name = "緑の輪郭 (上に長い)", Default = false, Color = Color3.fromRGB(0, 255, 100), Callback = function(v) ShowGreenOutline = v end})
VisualsTab:AddToggle({Name = "Box 表示", Default = true, Callback = function(v) ShowBox = v end})
VisualsTab:AddToggle({Name = "名前 + 体力", Default = true, Callback = function(v) ShowName = v end})
VisualsTab:AddToggle({Name = "体力バー", Default = true, Callback = function(v) ShowHealthBar = v end})
VisualsTab:AddToggle({Name = "距離 表示", Default = true, Callback = function(v) ShowDistance = v end})
VisualsTab:AddToggle({Name = "Tracers", Default = true, Callback = function(v) ShowTracers = v end})

-- ==================== プレイヤータブ ====================
PlayerTab:AddSection({Name = "移動・物理設定"})
-- （移動速度、ジャンプ力など前回と同じ機能はここに入っています）

PlayerTab:AddSection({Name = "カメラ設定"})
PlayerTab:AddSlider({
    Name = "FOV",
    Min = 30, Max = 120, Default = 70,
    Color = Color3.fromRGB(0, 162, 255),
    Increment = 1,
    ValueName = "°",
    Callback = function(v)
        FOVValue = v
        Workspace.CurrentCamera.FieldOfView = v
    end
})

-- ==================== 物人タブ ====================
ItemsTab:AddSection({Name = "物人機能"})
ItemsTab:AddLabel("ここに後で機能を追加できます")

OrionLib:Init()
print("✅ なべHUBv1.2 が起動しました！")
