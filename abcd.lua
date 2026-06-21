-- ==========================================
-- なべHUBv1.3 完全版 (軽量化済み)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not OrionLib then warn("OrionLib 読み込み失敗") return end

-- ========== ウィンドウ構築 ==========
local MainWindow = OrionLib:MakeWindow({
    Name = "なべHUBv1.3",
    HidePremium = true,
    SaveConfig = false,
    Searchable = false,
    ThemeColor = Color3.fromRGB(255, 140, 0),
    BackgroundColor = Color3.fromRGB(40, 30, 20)
})

local MineTab = MainWindow:MakeTab({ Name = "Mine", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local PlayerTab = MainWindow:MakeTab({ Name = "プレイヤー", Icon = "rbxassetid://6031094678", PremiumOnly = false })
local VisualsTab = MainWindow:MakeTab({ Name = "画面", Icon = "rbxassetid://6031094678", PremiumOnly = false })
local EffectTab = MainWindow:MakeTab({ Name = "エフェクト", Icon = "rbxassetid://6031094678", PremiumOnly = false })
local ItemsTab = MainWindow:MakeTab({ Name = "物人", Icon = "rbxassetid://6031079977", PremiumOnly = false })

-- ==================== 変数 ====================
local WalkSpeedValue = 16
local JumpPowerValue = 50
local GravityValue = 196.2
local FOVValue = 70

local SpeedEnabled = false
local InfiniteJumpEnabled = false
local GravityEnabled = false

-- ESP
local ESPEnabled = false
local RainbowESP = false
local RainbowSpeed = 0.015
local AutoUpdateESP = true
local ESPObjects = {}
local ESPConnection = nil

local ShowBox = true
local ShowName = true
local ShowHealthBar = true
local ShowDistance = true
local ShowTracers = true

local RainbowHue = 0

-- ==================== 起動時チャット ====================
local function sendChat(message)
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local say = chatEvents:FindFirstChild("SayMessageRequest")
        if say then say:FireServer(message, "All") end
    end
end

task.spawn(function()
    task.wait(2)
    sendChat("なべHUB v1.3 起動完了")
end)

-- ==================== 関数 ====================
local function applyCharacterSettings(character)
    task.wait(0.7)
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
    if player == LocalPlayer or ESPObjects[player] then return end
    local d = {}
    d.Box = Drawing.new("Square")
    d.Name = Drawing.new("Text")
    d.Distance = Drawing.new("Text")
    d.HealthBar = Drawing.new("Square")
    d.HealthOutline = Drawing.new("Square")
    d.Tracer = Drawing.new("Line")

    d.Box.Thickness = 2; d.Box.Filled = false; d.Box.Transparency = 1
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
            for _, obj in pairs(d) do if obj then obj.Visible = false end end
            continue
        end

        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        if not head or not hum then continue end

        local cam = Workspace.CurrentCamera
        local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height * 0.6

        local rainbow = getRainbowColor()

        d.Box.Color = RainbowESP and rainbow or Color3.fromRGB(255, 50, 50)
        d.Box.Size = Vector2.new(width, height)
        d.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        d.Box.Visible = ShowBox

        d.Name.Text = player.Name .. " [" .. math.floor(hum.Health) .. "]"
        d.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 25)
        d.Name.Visible = ShowName

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
        d.Distance.Text = dist .. " studs"
        d.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 10)
        d.Distance.Visible = ShowDistance

        local hp = hum.Health / hum.MaxHealth
        local barH = height * 0.75
        d.HealthOutline.Size = Vector2.new(4, barH)
        d.HealthOutline.Position = Vector2.new(rootPos.X - width/2 - 10, rootPos.Y - height/2)
        d.HealthOutline.Visible = ShowHealthBar

        d.HealthBar.Size = Vector2.new(4, barH * hp)
        d.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 10, rootPos.Y - height/2 + barH * (1 - hp))
        d.HealthBar.Visible = ShowHealthBar

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

-- ==================== UI ====================
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

VisualsTab:AddToggle({Name = "ESP 自動更新 (5秒)", Default = true, Color = Color3.fromRGB(0, 200, 255), Callback = function(v) AutoUpdateESP = v end})
VisualsTab:AddToggle({Name = "ESP レインボー", Default = false, Color = Color3.fromRGB(255, 100, 255), Callback = function(v) RainbowESP = v end})
VisualsTab:AddSlider({Name = "レインボー速度", Min = 0.001, Max = 0.1, Default = 0.015, Color = Color3.fromRGB(255, 100, 255), Increment = 0.001, Callback = function(v) RainbowSpeed = v end})

VisualsTab:AddSection({Name = "ESP 表示設定"})
VisualsTab:AddToggle({Name = "Box 表示", Default = true, Callback = function(v) ShowBox = v end})
VisualsTab:AddToggle({Name = "名前 + 体力", Default = true, Callback = function(v) ShowName = v end})
VisualsTab:AddToggle({Name = "体力バー", Default = true, Callback = function(v) ShowHealthBar = v end})
VisualsTab:AddToggle({Name = "距離 表示", Default = true, Callback = function(v) ShowDistance = v end})
VisualsTab:AddToggle({Name = "Tracers", Default = true, Callback = function(v) ShowTracers = v end})

-- プレイヤータブ機能
PlayerTab:AddSection({Name = "移動・物理設定"})
PlayerTab:AddSlider({Name = "移動速度", Min = 16, Max = 200, Default = 16, Color = Color3.fromRGB(0, 162, 255), Increment = 1, ValueName = " studs/s", Callback = function(v) WalkSpeedValue = v; if SpeedEnabled then local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end end end})
PlayerTab:AddToggle({Name = "カスタム移動速度有効", Default = false, Color = Color3.fromRGB(0, 162, 255), Callback = function(v) SpeedEnabled = v; local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v and WalkSpeedValue or 16 end end})

PlayerTab:AddSlider({Name = "ジャンプ力", Min = 50, Max = 400, Default = 50, Color = Color3.fromRGB(0, 162, 255), Increment = 1, ValueName = " power", Callback = function(v) JumpPowerValue = v; local c=LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v; c.Humanoid.JumpHeight = v*0.6 end end})
PlayerTab:AddToggle({Name = "無限ジャンプ", Default = false, Color = Color3.fromRGB(0, 162, 255), Callback = function(v) InfiniteJumpEnabled = v end})

PlayerTab:AddSlider({Name = "重力", Min = 0, Max = 400, Default = 196.2, Color = Color3.fromRGB(0, 162, 255), Increment = 0.1, ValueName = " gravity", Callback = function(v) GravityValue = v; if GravityEnabled then Workspace.Gravity = v end end})
PlayerTab:AddToggle({Name = "カスタム重力有効", Default = false, Color = Color3.fromRGB(0, 162, 255), Callback = function(v) GravityEnabled = v; Workspace.Gravity = v and GravityValue or 196.2 end})

PlayerTab:AddSection({Name = "カメラ設定"})
PlayerTab:AddSlider({Name = "FOV", Min = 30, Max = 120, Default = 70, Color = Color3.fromRGB(0, 162, 255), Increment = 1, ValueName = "°", Callback = function(v) FOVValue = v; Workspace.CurrentCamera.FieldOfView = v end})

-- エフェクトタブ
EffectTab:AddSection({Name = "視覚エフェクト"})
EffectTab:AddLabel("ここに虹色枠などのエフェクトを追加できます")

-- ==================== 初期化 ====================
LocalPlayer.CharacterAdded:Connect(applyCharacterSettings)
if LocalPlayer.Character then applyCharacterSettings(LocalPlayer.Character) end

OrionLib:Init()
print("✅ なべHUBv1.3 完全版 起動完了！")
