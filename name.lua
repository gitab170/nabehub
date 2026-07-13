-- ============================================
-- なべHub 溶岩タワー v1.5
-- 空中歩行（ホバリング）機能追加
-- 無限滞空 / ジャンプ→待機→滞空 シーケンス
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/katnaa-debug/SolarisUI/refs/heads/main/Library1.lua"))()

-- ============================================
-- 起動チャット通知
-- ============================================
local function sendStartMessage()
    local message = "なべHub 溶岩タワースクリプト v1.5 起動 (空中歩行追加)"
    
    pcall(function()
        local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local say = chatEvents:FindFirstChild("SayMessageRequest")
            if say and typeof(say.FireServer) == "function" then
                say:FireServer(message, "All")
                print("✅ チャット送信: " .. message)
                return
            end
        end
    end)
    
    pcall(function()
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("ChatMakeSystemMessage", {
            Name = message,
            Color = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size18,
        })
        print("✅ システムメッセージ: " .. message)
    end)
end

-- ============================================
-- カスタムテーマ: グレー＆ホワイト
-- ============================================
local CustomTheme = {
    Main = Color3.fromRGB(30, 30, 35),
    Second = Color3.fromRGB(45, 45, 50),
    Accent = Color3.fromRGB(200, 200, 200),
    ElementAccent = Color3.fromRGB(220, 220, 220),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(170, 170, 170),
    Error = Color3.fromRGB(255, 80, 80),
    GradientStart = Color3.fromRGB(200, 200, 200),
    GradientEnd = Color3.fromRGB(150, 150, 150),
    Transparency = 0.15,
    HudTransparency = 0.3,
    ImageTransparency = 0.2,
    Font = "Gotham",
    Background = "",
    UiScale = 1.0
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- ============================================
-- 設定（v1.5 空中歩行追加）
-- ============================================
local CONFIG = {
    -- 戦闘系
    AuraRadius = 8,
    AuraInterval = 0.5,
    AttackSpeed = 10,
    AttackDuration = 3,
    -- テレポート系
    TeleportInterval = 0.15,
    TeleportMaxDistance = 150,
    TeleportHeight = 3,
    -- 全員テレポート系
    MassTeleportInterval = 0.3,
    MassTeleportRadius = 30,
    MassTeleportHeight = 10,
    -- 防御系
    MoveThreshold = 50,
    MaxLogs = 50,
    -- 移動系
    WalkSpeed = 16,
    JumpPower = 50,
    -- 明るさ
    Brightness = 2,
    -- その他
    LavaTransparency = 100,
    FOV = 70,
    ExcludedPlayer = "",
    Whitelist = {},
    ExcludeFriends = true,
    InfiniteJump = false,
    AutoHeal = false,
    Noclip = false,
    SelfSlashProtection = false,
    MoveDetection = false,
    KillBlockDetection = false,
    MassTeleportEnabled = false,
    -- ============================================
    -- ★ v1.5 空中歩行（ホバリング）設定
    -- ============================================
    HoverEnabled = false,
    HoverDuration = 3,          -- 浮遊持続時間（秒）
    HoverHeight = 5,            -- 浮遊高さ
    HoverInfinite = false,      -- 無限滞空モード
    HoverJumpDelay = 0.15,      -- ジャンプ後の待機時間（秒）
    HoverFallSpeed = 0.5,       -- 落下速度（遅くする）
    HoverSmoothness = 0.3,      -- 浮遊の滑らかさ
}

local SlashRemote = ReplicatedStorage:FindFirstChild("lol")

-- ============================================
-- 変数
-- ============================================
local auraActive = false
local selectedTarget = nil
local autoTPActive = false
local autoTPStartPos = nil
local targetLoopActive = false
local targetLoopStartPos = nil
local pullActive = false
local infiniteJumpActive = false
local currentLavaTransparency = 100
local savedPositions = {}
local savedPositionNames = {}
local espHighlights = {}
local espEnabled = false
local spinActive = false
local spinSpeed = 5
local detectionLogs = {}
local speedActive = false
local killAuraActive = false
local magmaOff = false
local noclipActive = false
local massTeleportActive = false
local massTeleportConnection = nil

-- ★ v1.5 空中歩行変数
local hoverActive = false
local hoverConnection = nil
local hoverStartTime = 0
local hoverTimerConnection = nil
local hoverJumping = false
local hoverWaitTask = nil
local hoverTargetHeight = 0
local hoverCurrentHeight = 0
local hoverOriginalGravity = 0

-- キャッシュ
local cachedTargets = {}
local cachedLavaParts = {}
local lastCacheUpdate = 0

-- 接続管理
local mainLoopConnection = nil
local lavaMonitorConnection = nil

-- ============================================
-- ホワイトリスト
-- ============================================
local function isWhitelisted(player)
    if not player then return false end
    if player.Name == CONFIG.ExcludedPlayer then return true end
    if CONFIG.ExcludeFriends and LocalPlayer:IsFriendsWith(player.UserId) then return true end
    for _, name in ipairs(CONFIG.Whitelist) do
        if player.Name == name or player.DisplayName == name then
            return true
        end
    end
    return false
end

-- ============================================
-- キャッシュ更新
-- ============================================
local function updateCaches()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            local char = p.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(targets, {
                        player = p,
                        character = char,
                        head = char.Head,
                        root = char.HumanoidRootPart,
                        hum = hum,
                    })
                end
            end
        end
    end
    cachedTargets = targets
    
    local lavas = {}
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Lava" then
            table.insert(lavas, part)
        end
    end
    cachedLavaParts = lavas
end

updateCaches()
Players.PlayerAdded:Connect(function() task.wait(0.3) updateCaches() end)
Players.PlayerRemoving:Connect(function() task.wait(0.3) updateCaches() end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) updateCaches() end)

-- ============================================
-- ★ v1.5 空中歩行（ホバリング）コア機能
-- ============================================

-- 重力を保存/復元
local function SaveGravity()
    hoverOriginalGravity = Workspace.Gravity
end

local function RestoreGravity()
    Workspace.Gravity = hoverOriginalGravity
end

-- ホバリング制御（BodyPosition使用）
local function StartHover()
    if hoverActive then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- 既存のホバー用BodyPositionを削除
    local oldBP = root:FindFirstChild("HoverBodyPosition")
    if oldBP then oldBP:Destroy() end
    local oldBG = root:FindFirstChild("HoverBodyGyro")
    if oldBG then oldBG:Destroy() end
    
    -- 重力を軽減（浮遊感）
    SaveGravity()
    Workspace.Gravity = Workspace.Gravity * 0.1
    
    -- 現在位置を基準に浮遊高さを設定
    hoverTargetHeight = root.Position.Y + CONFIG.HoverHeight
    hoverCurrentHeight = root.Position.Y
    hoverStartTime = tick()
    
    -- BodyPositionで浮遊制御
    local bp = Instance.new("BodyPosition")
    bp.Name = "HoverBodyPosition"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 5000 * CONFIG.HoverSmoothness
    bp.D = 2000
    bp.Parent = root
    
    -- BodyGyroで姿勢制御
    local bg = Instance.new("BodyGyro")
    bg.Name = "HoverBodyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 20000
    bg.D = 500
    bg.Parent = root
    
    hoverActive = true
    
    -- ホバー更新ループ
    if hoverConnection then hoverConnection:Disconnect() end
    hoverConnection = RunService.Heartbeat:Connect(function()
        if not hoverActive or not root or not root.Parent then
            StopHover()
            return
        end
        
        -- 無限滞空モード or 時間制限内
        local elapsed = tick() - hoverStartTime
        local shouldHover = CONFIG.HoverInfinite or (elapsed < CONFIG.HoverDuration)
        
        if not shouldHover then
            -- 時間切れならゆっくり落下
            Workspace.Gravity = hoverOriginalGravity * 0.3
            bp.Position = Vector3.new(root.Position.X, root.Position.Y - 0.1, root.Position.Z)
            bp.MaxForce = Vector3.new(0, 500, 0)
            return
        end
        
        -- 浮遊位置を更新（徐々に目標高さへ）
        local currentY = root.Position.Y
        local diff = hoverTargetHeight - currentY
        local smoothStep = diff * 0.08 * CONFIG.HoverSmoothness
        local newY = currentY + smoothStep
        
        -- 目標高さに近づいたら固定
        if math.abs(diff) < 0.05 then
            newY = hoverTargetHeight
        end
        
        bp.Position = Vector3.new(root.Position.X, newY, root.Position.Z)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        -- 水平移動は自由
        bp.P = 8000 * CONFIG.HoverSmoothness
        bp.D = 3000
        
        -- カメラ方向を向く
        bg.CFrame = Camera.CFrame
        
        -- 落下速度を抑制
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            math.clamp(root.AssemblyLinearVelocity.Y, -CONFIG.HoverFallSpeed, CONFIG.HoverFallSpeed),
            root.AssemblyLinearVelocity.Z
        )
    end)
    
    Library:Notify({
        Title = "空中歩行",
        Content = CONFIG.HoverInfinite and "無限滞空 ON" or string.format("%.1f秒浮遊", CONFIG.HoverDuration),
        Duration = 2
    })
end

local function StopHover()
    if not hoverActive then return end
    
    hoverActive = false
    
    if hoverConnection then
        hoverConnection:Disconnect()
        hoverConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bp = root:FindFirstChild("HoverBodyPosition")
            if bp then bp:Destroy() end
            local bg = root:FindFirstChild("HoverBodyGyro")
            if bg then bg:Destroy() end
        end
    end
    
    RestoreGravity()
    Library:Notify({ Title = "空中歩行", Content = "終了", Duration = 2 })
end

-- ジャンプ検知 → 待機 → ホバリング開始
local function SetupHoverJumpDetection()
    -- 既存の接続をクリーンアップ
    if hoverTimerConnection then
        hoverTimerConnection:Disconnect()
        hoverTimerConnection = nil
    end
    
    if hoverWaitTask then
        task.cancel(hoverWaitTask)
        hoverWaitTask = nil
    end
    
    -- ジャンプ検知（CharacterAddedで再設定）
    local function onJump()
        if not CONFIG.HoverEnabled then return end
        if hoverActive then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        -- ジャンプ状態を検知
        local function checkJump()
            if hum:GetState() == Enum.HumanoidStateType.Jumping then
                -- ジャンプ検知！待機時間後にホバリング開始
                if hoverWaitTask then
                    task.cancel(hoverWaitTask)
                    hoverWaitTask = nil
                end
                
                -- ジャンプフラグ
                hoverJumping = true
                
                -- 指定時間待機してからホバリング開始
                hoverWaitTask = task.spawn(function()
                    task.wait(CONFIG.HoverJumpDelay)
                    if hoverJumping and CONFIG.HoverEnabled then
                        -- 空中にいるか確認
                        local char2 = LocalPlayer.Character
                        if char2 then
                            local root = char2:FindFirstChild("HumanoidRootPart")
                            if root then
                                -- 地面からの高さをチェック（0.5以上で空中と判定）
                                local groundCheck = Workspace:FindPartOnRay(
                                    Ray.new(root.Position, Vector3.new(0, -3, 0)),
                                    char2
                                )
                                if not groundCheck then
                                    StartHover()
                                end
                            end
                        end
                    end
                    hoverJumping = false
                    hoverWaitTask = nil
                end)
            elseif hum:GetState() == Enum.HumanoidStateType.Landed then
                -- 着地したらホバリング解除
                if hoverActive then
                    StopHover()
                end
                hoverJumping = false
                if hoverWaitTask then
                    task.cancel(hoverWaitTask)
                    hoverWaitTask = nil
                end
            end
        end
        
        -- 状態変化を監視
        if hoverTimerConnection then
            hoverTimerConnection:Disconnect()
        end
        hoverTimerConnection = hum:GetPropertyChangedSignal("State"):Connect(checkJump)
    end
    
    -- 現在のキャラクターに適用
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            onJump()
        end
    end
    
    -- キャラクター追加時にも適用
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.3)
        local hum = newChar:FindFirstChildOfClass("Humanoid")
        if hum then
            -- 既存接続をクリーンアップ
            if hoverTimerConnection then
                hoverTimerConnection:Disconnect()
                hoverTimerConnection = nil
            end
            -- ジャンプ検知を再設定
            local function onJumpNew()
                if not CONFIG.HoverEnabled then return end
                if hoverActive then return end
                
                local function checkJumpNew()
                    local hum2 = newChar:FindFirstChildOfClass("Humanoid")
                    if not hum2 then return end
                    
                    if hum2:GetState() == Enum.HumanoidStateType.Jumping then
                        if hoverWaitTask then
                            task.cancel(hoverWaitTask)
                            hoverWaitTask = nil
                        end
                        hoverJumping = true
                        hoverWaitTask = task.spawn(function()
                            task.wait(CONFIG.HoverJumpDelay)
                            if hoverJumping and CONFIG.HoverEnabled then
                                StartHover()
                            end
                            hoverJumping = false
                            hoverWaitTask = nil
                        end)
                    elseif hum2:GetState() == Enum.HumanoidStateType.Landed then
                        if hoverActive then
                            StopHover()
                        end
                        hoverJumping = false
                        if hoverWaitTask then
                            task.cancel(hoverWaitTask)
                            hoverWaitTask = nil
                        end
                    end
                end
                
                if hoverTimerConnection then
                    hoverTimerConnection:Disconnect()
                end
                hoverTimerConnection = hum:GetPropertyChangedSignal("State"):Connect(checkJumpNew)
            end
            
            -- キャラクター追加時のジャンプ検知
            local function onJumpNewChar()
                if not CONFIG.HoverEnabled then return end
                if hoverActive then return end
                
                local function checkJumpNewChar()
                    local hum3 = newChar:FindFirstChildOfClass("Humanoid")
                    if not hum3 then return end
                    
                    if hum3:GetState() == Enum.HumanoidStateType.Jumping then
                        if hoverWaitTask then
                            task.cancel(hoverWaitTask)
                            hoverWaitTask = nil
                        end
                        hoverJumping = true
                        hoverWaitTask = task.spawn(function()
                            task.wait(CONFIG.HoverJumpDelay)
                            if hoverJumping and CONFIG.HoverEnabled then
                                StartHover()
                            end
                            hoverJumping = false
                            hoverWaitTask = nil
                        end)
                    elseif hum3:GetState() == Enum.HumanoidStateType.Landed then
                        if hoverActive then
                            StopHover()
                        end
                        hoverJumping = false
                        if hoverWaitTask then
                            task.cancel(hoverWaitTask)
                            hoverWaitTask = nil
                        end
                    end
                end
                
                if hoverTimerConnection then
                    hoverTimerConnection:Disconnect()
                end
                hoverTimerConnection = hum:GetPropertyChangedSignal("State"):Connect(checkJumpNewChar)
            end
            
            onJumpNew()
        end
    end)
end

-- ホバリング手動開始（トグル用）
local function ToggleHoverManual()
    if hoverActive then
        StopHover()
    else
        StartHover()
    end
end

-- ============================================
-- 基本攻撃
-- ============================================
local function slashAll()
    if not SlashRemote then return end
    for _, t in ipairs(cachedTargets) do
        if t.head then
            pcall(function()
                SlashRemote:FireServer("slash", t.character, t.head.Position)
            end)
        end
    end
end

-- ============================================
-- 全員テレポート
-- ============================================
local function startMassTeleport()
    if massTeleportConnection then return end
    massTeleportConnection = RunService.Heartbeat:Connect(function()
        if not massTeleportActive then return end
        
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local myPos = myRoot.Position
        
        for _, t in ipairs(cachedTargets) do
            if not t.root then continue end
            local offset = Vector3.new(
                math.random(-CONFIG.MassTeleportRadius, CONFIG.MassTeleportRadius),
                CONFIG.MassTeleportHeight,
                math.random(-CONFIG.MassTeleportRadius, CONFIG.MassTeleportRadius)
            )
            t.root.CFrame = CFrame.new(myPos + offset)
            t.root.AssemblyLinearVelocity = Vector3.zero
            t.root.AssemblyAngularVelocity = Vector3.zero
            task.wait(CONFIG.MassTeleportInterval)
        end
    end)
end

local function stopMassTeleport()
    if massTeleportConnection then
        massTeleportConnection:Disconnect()
        massTeleportConnection = nil
    end
end

-- ============================================
-- メインループ（超軽量）
-- ============================================
local function startMainLoop()
    if mainLoopConnection then return end
    
    local timers = {
        aura = 0,
        heal = 0,
        move = 0,
        killblock = 0,
        targetloop = 0,
        autotp = 0,
        pull = 0,
        spin = 0,
        noclip = 0,
        speed = 0,
        cache = 0,
    }
    
    mainLoopConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        
        if now - timers.cache >= 0.5 then
            updateCaches()
            timers.cache = now
        end
        
        -- オーラ
        if auraActive and SlashRemote and now - timers.aura >= CONFIG.AuraInterval then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                for _, t in ipairs(cachedTargets) do
                    if (t.head.Position - myPos).Magnitude <= CONFIG.AuraRadius then
                        pcall(function()
                            SlashRemote:FireServer("slash", t.character, t.head.Position)
                        end)
                    end
                end
            end
            timers.aura = now
        end
        
        -- キルオーラ
        if killAuraActive and now - timers.aura >= 0.3 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                for _, t in ipairs(cachedTargets) do
                    if (t.root.Position - myPos).Magnitude <= CONFIG.AuraRadius then
                        pcall(function()
                            t.hum.Health = 0
                        end)
                    end
                end
            end
            timers.aura = now
        end
        
        -- ターゲットLOOP
        if targetLoopActive and SlashRemote and now - timers.targetloop >= CONFIG.TeleportInterval then
            if selectedTarget and selectedTarget.Character then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local myRoot = myChar.HumanoidRootPart
                    local tChar = selectedTarget.Character
                    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        if (myRoot.Position - tRoot.Position).Magnitude <= CONFIG.TeleportMaxDistance * 1.2 then
                            myRoot.CFrame = tRoot.CFrame
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            for i = 1, 3 do
                                pcall(function()
                                    SlashRemote:FireServer("slash", tChar, tRoot.Position)
                                end)
                                task.wait(0.02)
                            end
                            if targetLoopStartPos then
                                myRoot.CFrame = targetLoopStartPos
                                myRoot.AssemblyLinearVelocity = Vector3.zero
                            end
                        end
                    end
                end
            end
            timers.targetloop = now
        end
        
        -- AutoTP
        if autoTPActive and SlashRemote and now - timers.autotp >= CONFIG.TeleportInterval then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myRoot = myChar.HumanoidRootPart
                for _, t in ipairs(cachedTargets) do
                    if not autoTPActive then break end
                    if (myRoot.Position - t.root.Position).Magnitude <= CONFIG.TeleportMaxDistance then
                        myRoot.CFrame = t.root.CFrame + Vector3.new(0, CONFIG.TeleportHeight, 0)
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.03)
                        for i = 1, 2 do
                            pcall(function()
                                SlashRemote:FireServer("slash", t.character, t.root.Position)
                            end)
                            task.wait(0.03)
                        end
                        if autoTPStartPos then
                            myRoot.CFrame = autoTPStartPos
                            myRoot.AssemblyLinearVelocity = Vector3.zero
                        end
                        break
                    end
                end
            end
            timers.autotp = now
        end
        
        -- 引き寄せ
        if pullActive and now - timers.pull >= 0.15 then
            local currentPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            if currentPos then
                for _, t in ipairs(cachedTargets) do
                    local offset = Vector3.new(math.random(-3, 3), 3, math.random(-3, 3))
                    t.root.CFrame = CFrame.new(currentPos + offset)
                    t.root.AssemblyLinearVelocity = Vector3.zero
                end
            end
            timers.pull = now
        end
        
        -- スピン
        if spinActive and now - timers.spin >= 0.05 then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                end
            end
            timers.spin = now
        end
        
        -- 壁抜け
        if noclipActive and now - timers.noclip >= 0.1 then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            timers.noclip = now
        end
        
        -- 移動速度
        if speedActive and now - timers.speed >= 0.1 then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = CONFIG.WalkSpeed
                end
            end
            timers.speed = now
        end
        
        -- Health
        if now - timers.heal >= 0.3 then
            if CONFIG.AutoHeal or CONFIG.SelfSlashProtection then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end
            end
            timers.heal = now
        end
        
        -- 強制移動検知
        if CONFIG.MoveDetection and now - timers.move >= 0.3 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                if root then
                    if root:GetAttribute("LastPos") then
                        local lastPos = root:GetAttribute("LastPos")
                        if (root.Position - lastPos).Magnitude > CONFIG.MoveThreshold then
                            pcall(function()
                                root.CFrame = CFrame.new(lastPos)
                                root.AssemblyLinearVelocity = Vector3.zero
                            end)
                            AddLog("強制移動検知", {})
                        end
                    end
                    root:SetAttribute("LastPos", root.Position)
                end
            end
            timers.move = now
        end
        
        -- Killブロック検知
        if CONFIG.KillBlockDetection and now - timers.killblock >= 0.5 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                for _, part in pairs(cachedLavaParts) do
                    if part and part.Parent and (myPos - part.Position).Magnitude < 3 then
                        AddLog("危険ブロック", {blockName = part.Name})
                        Library:Notify({
                            Title = "危険ブロック検知",
                            Content = string.format("%s に接近", part.Name),
                            Duration = 2
                        })
                        break
                    end
                end
            end
            timers.killblock = now
        end
    end)
end

-- ============================================
-- 溶岩監視
-- ============================================
local function setupLavaMonitor()
    if lavaMonitorConnection then
        lavaMonitorConnection:Disconnect()
        lavaMonitorConnection = nil
    end
    
    lavaMonitorConnection = Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") and descendant.Name == "Lava" then
            task.wait(0.05)
            local transparency = currentLavaTransparency / 100
            pcall(function()
                descendant.Transparency = transparency
            end)
            if magmaOff then
                local ti = descendant:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
            end
            table.insert(cachedLavaParts, descendant)
        end
    end)
end

-- ============================================
-- 溶岩透明度
-- ============================================
local function setLavaTransparency(value)
    CONFIG.LavaTransparency = value
    currentLavaTransparency = value
    local transparency = value / 100
    
    for _, part in ipairs(cachedLavaParts) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = transparency
            end)
        end
    end
end

-- ============================================
-- 溶岩無効化
-- ============================================
local function toggleMagma(on)
    magmaOff = on
    if on then
        for _, part in ipairs(cachedLavaParts) do
            if part and part.Parent then
                local ti = part:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
            end
        end
        setLavaTransparency(100)
        Library:Notify({ Title = "溶岩無効化", Content = "ON", Duration = 2 })
    else
        setLavaTransparency(0)
        Library:Notify({ Title = "溶岩無効化", Content = "OFF", Duration = 2 })
    end
end

-- ============================================
-- 無限ジャンプ
-- ============================================
local function toggleInfiniteJump(on)
    CONFIG.InfiniteJump = on
    infiniteJumpActive = on
    Library:Notify({ Title = "無限ジャンプ", Content = on and "ON" or "OFF", Duration = 2 })
end

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpActive then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ============================================
-- 各機能トグル
-- ============================================
local function startAura()
    if auraActive then return end
    auraActive = true
    Library:Notify({ Title = "オーラ", Content = "ON", Duration = 2 })
end

local function stopAura()
    auraActive = false
    Library:Notify({ Title = "オーラ", Content = "OFF", Duration = 2 })
end

local function startKillAura()
    if killAuraActive then return end
    killAuraActive = true
    Library:Notify({ Title = "キルオーラ", Content = "ON", Duration = 2 })
end

local function stopKillAura()
    killAuraActive = false
    Library:Notify({ Title = "キルオーラ", Content = "OFF", Duration = 2 })
end

local function toggleTargetLoop(on)
    targetLoopActive = on
    if on then
        if not selectedTarget then
            Library:Notify({ Title = "ターゲットLOOP", Content = "先にターゲットを選択", Duration = 2 })
            targetLoopActive = false
            return
        end
        if selectedTarget == LocalPlayer then
            Library:Notify({ Title = "ターゲットLOOP", Content = "自分は選択できません", Duration = 2 })
            targetLoopActive = false
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            targetLoopStartPos = char.HumanoidRootPart.CFrame
        end
        Library:Notify({ Title = "ターゲットLOOP", Content = selectedTarget.Name .. " を攻撃", Duration = 2 })
    else
        Library:Notify({ Title = "ターゲットLOOP", Content = "停止", Duration = 2 })
    end
end

local function toggleAutoTP(on)
    autoTPActive = on
    if on then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            autoTPStartPos = char.HumanoidRootPart.CFrame
        end
        Library:Notify({ Title = "AutoTP", Content = "ON", Duration = 2 })
    else
        Library:Notify({ Title = "AutoTP", Content = "OFF", Duration = 2 })
    end
end

local function togglePull(on)
    pullActive = on
    Library:Notify({ Title = "引き寄せ", Content = on and "ON" or "OFF", Duration = 2 })
end

local function toggleSpeed(on)
    speedActive = on
    Library:Notify({ Title = "移動速度", Content = on and "ON" or "OFF", Duration = 2 })
end

local function toggleNoclip(on)
    noclipActive = on
    Library:Notify({ Title = "壁抜け", Content = on and "ON" or "OFF", Duration = 2 })
end

local function toggleSpin(on)
    spinActive = on
    Library:Notify({ Title = "スピン", Content = on and "ON" or "OFF", Duration = 2 })
end

local function toggleMassTeleport(on)
    massTeleportActive = on
    if on then
        startMassTeleport()
        Library:Notify({ Title = "全員テレポート", Content = "ON", Duration = 2 })
    else
        stopMassTeleport()
        Library:Notify({ Title = "全員テレポート", Content = "OFF", Duration = 2 })
    end
end

-- ============================================
-- ★ v1.5 ホバリングトグル
-- ============================================
local function toggleHover(on)
    CONFIG.HoverEnabled = on
    if not on and hoverActive then
        StopHover()
    end
    if on then
        Library:Notify({
            Title = "空中歩行",
            Content = string.format("ON (浮遊%.1f秒%s)", CONFIG.HoverDuration, CONFIG.HoverInfinite and " / 無限滞空" or ""),
            Duration = 3
        })
        -- ジャンプ検知をセットアップ
        SetupHoverJumpDetection()
    else
        Library:Notify({ Title = "空中歩行", Content = "OFF", Duration = 2 })
    end
end

local function toggleHoverInfinite(on)
    CONFIG.HoverInfinite = on
    Library:Notify({
        Title = "無限滞空",
        Content = on and "ON (永遠に浮遊)" or "OFF (時間制限)",
        Duration = 2
    })
    if on and hoverActive then
        -- 無限滞空ONでホバリング継続
        hoverStartTime = tick() -- リセットして継続
    end
end

-- 手動ホバリング開始ボタン用
local function manualHover()
    if hoverActive then
        StopHover()
    else
        StartHover()
    end
end

-- ============================================
-- ランダムキル
-- ============================================
local function killRandom()
    if #cachedTargets == 0 then
        Library:Notify({ Title = "ランダムキル", Content = "対象がいません", Duration = 2 })
        return
    end
    local t = cachedTargets[math.random(1, #cachedTargets)]
    if t and t.hum then
        t.hum.Health = 0
        Library:Notify({ Title = "ランダムキル", Content = t.player.Name .. " をキル", Duration = 2 })
    end
end

-- ============================================
-- 全体攻撃
-- ============================================
local function attackAll()
    local dur = CONFIG.AttackDuration
    local interval = 1 / CONFIG.AttackSpeed
    local t = tick()
    while tick() - t < dur do
        slashAll()
        task.wait(interval)
    end
    Library:Notify({ Title = "全体攻撃", Content = "完了", Duration = 2 })
end

-- ============================================
-- FOV
-- ============================================
local function setFOV(value)
    CONFIG.FOV = value
    Camera.FieldOfView = value
end

-- ============================================
-- 明るさ設定
-- ============================================
local function setBrightness(value)
    CONFIG.Brightness = value
    Lighting.Brightness = value
end

setBrightness(CONFIG.Brightness)

-- ============================================
-- テレポート
-- ============================================
local function TeleportToPlayer(player)
    if not player then return end
    local tChar = player.Character
    if not tChar then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    myRoot.CFrame = tRoot.CFrame + Vector3.new(0, CONFIG.TeleportHeight, 0)
    Library:Notify({ Title = "テレポート", Content = player.DisplayName .. " の位置へ", Duration = 2 })
end

local function TeleportToCoordinates(x, y, z)
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    myRoot.CFrame = CFrame.new(x, y, z)
    Library:Notify({ Title = "テレポート", Content = string.format("(%.1f, %.1f, %.1f)", x, y, z), Duration = 2 })
end

local function SaveCurrentPosition(name)
    if not name or name == "" then
        Library:Notify({ Title = "保存", Content = "名前を入力", Duration = 2 })
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    savedPositions[name] = root.Position
    table.insert(savedPositionNames, name)
    Library:Notify({ Title = "保存", Content = "'" .. name .. "' を保存", Duration = 2 })
end

local function TeleportToSaved(name)
    local pos = savedPositions[name]
    if not pos then
        Library:Notify({ Title = "テレポート", Content = "'" .. name .. "' は見つかりません", Duration = 2 })
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(pos)
    Library:Notify({ Title = "テレポート", Content = "'" .. name .. "' に移動", Duration = 2 })
end

local function DeleteSavedPosition(name)
    savedPositions[name] = nil
    for i, n in ipairs(savedPositionNames) do
        if n == name then
            table.remove(savedPositionNames, i)
            break
        end
    end
    Library:Notify({ Title = "削除", Content = "'" .. name .. "' を削除", Duration = 2 })
end

-- ============================================
-- ログ
-- ============================================
local function AddLog(logType, data)
    table.insert(detectionLogs, 1, {
        type = logType,
        time = os.date("%H:%M:%S"),
        data = data,
    })
    while #detectionLogs > CONFIG.MaxLogs do
        table.remove(detectionLogs)
    end
end

local function showDetectionLogs()
    if #detectionLogs == 0 then
        Library:Notify({ Title = "検知ログ", Content = "ログがありません", Duration = 2 })
        return
    end
    local logText = ""
    for i = 1, math.min(10, #detectionLogs) do
        local log = detectionLogs[i]
        logText = logText .. string.format("[%s] %s\n", log.time, log.type)
        if log.data then
            for k, v in pairs(log.data) do
                logText = logText .. string.format("  %s: %s\n", k, tostring(v))
            end
        end
        logText = logText .. "\n"
    end
    Library:Notify({ Title = "検知ログ", Content = logText, Duration = 6 })
end

-- ============================================
-- ESP
-- ============================================
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if espEnabled and p.Character then
                if not espHighlights[p] then
                    local h = Instance.new("Highlight")
                    h.Adornee = p.Character
                    h.FillColor = Color3.fromRGB(200, 200, 200)
                    h.FillTransparency = 0.4
                    h.OutlineColor = Color3.fromRGB(240, 240, 240)
                    h.Parent = p.Character
                    espHighlights[p] = h
                end
            else
                if espHighlights[p] then
                    espHighlights[p]:Destroy()
                    espHighlights[p] = nil
                end
            end
        end
    end
end

local function toggleESP(on)
    espEnabled = on
    if not on then
        for _, h in pairs(espHighlights) do
            if h then h:Destroy() end
        end
        espHighlights = {}
    else
        updateESP()
    end
    Library:Notify({ Title = "ESP", Content = on and "ON" or "OFF", Duration = 2 })
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if espEnabled then updateESP() end
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if espEnabled then updateESP() end
end)

-- ============================================
-- リスト系関数
-- ============================================
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local whitelisted = false
            for _, name in ipairs(CONFIG.Whitelist) do
                if p.Name == name then whitelisted = true break end
            end
            if not whitelisted then
                table.insert(list, p.DisplayName .. " (@ " .. p.Name .. ")")
            end
        end
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function getWhitelistForDropdown()
    local list = {}
    for _, name in ipairs(CONFIG.Whitelist) do
        table.insert(list, name)
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function getTargetList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            table.insert(list, p.DisplayName .. " (@ " .. p.Name .. ")")
        end
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function getSavedPositionNames()
    local list = {}
    for _, name in ipairs(savedPositionNames) do
        local pos = savedPositions[name]
        if pos then
            table.insert(list, string.format("%s (%.1f, %.1f, %.1f)", name, pos.X, pos.Y, pos.Z))
        else
            table.insert(list, name)
        end
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function updateAllLists(td, tp, wd, rd, sd, dd)
    if td then td:Refresh(getTargetList(), true) end
    if tp then tp:Refresh(getTargetList(), true) end
    if wd then wd:Refresh(getPlayerList(), true) end
    if rd then rd:Refresh(getWhitelistForDropdown(), true) end
    if sd then sd:Refresh(getSavedPositionNames(), true) end
    if dd then dd:Refresh(getSavedPositionNames(), true) end
end

-- ============================================
-- Closeボタンパッチ
-- ============================================
local function PatchCloseButton()
    task.wait(0.8)
    local screenGui = game:GetService("CoreGui"):FindFirstChild("MainUI")
    if not screenGui then return end
    local windowContainer = screenGui:FindFirstChild("WindowContainer")
    if not windowContainer then return end
    local main = windowContainer:FindFirstChild("Main")
    if not main then return end
    local topBar = main:FindFirstChild("TopBar")
    if not topBar then return end
    local closeBtn = nil
    for _, child in pairs(topBar:GetChildren()) do
        if child:IsA("TextButton") then
            closeBtn = child
            break
        end
    end
    if closeBtn then
        for _, conn in pairs(getconnections(closeBtn.MouseButton1Click)) do
            conn:Disconnect()
        end
        closeBtn.MouseButton1Click:Connect(function()
            windowContainer.Visible = false
            for _, child in pairs(windowContainer:GetChildren()) do
                if child:IsA("ImageLabel") and child.Name:find("Shadow") then
                    child.Visible = false
                end
            end
        end)
    end
end

-- ============================================
-- UI作成
-- ============================================
local Window = Library:CreateWindow({
    Title = "なべHub 溶岩タワー v1.5",
    Theme = CustomTheme,
    ToggleKey = Enum.KeyCode.RightShift,
    Transparency = 0.15,
    ShowWatermark = {
        Enabled = true,
        Title = true,
        User = true,
        FPS = true,
        Duration = false,
        Ping = true
    },
    AutoSave = true,
    ConfigFolder = "NabeHub_LavaTower_Config"
})

task.spawn(PatchCloseButton)
startMainLoop()
setupLavaMonitor()

-- ============================================
-- 起動チャット通知
-- ============================================
task.spawn(function()
    task.wait(0.5)
    sendStartMessage()
end)

-- ============================================
-- タブ1: 戦闘
-- ============================================
local CombatTab = Window:CreateTab("戦闘", true, "rbxassetid://107058246184363")
local CombatGroup = CombatTab:CreateBlock({ Name = "攻撃", Side = "Left" })
local TargetGroup = CombatTab:CreateBlock({ Name = "ターゲット", Side = "Right" })

CombatGroup:CreateToggle({
    Name = "オーラモード",
    Flag = "AuraMode",
    Default = false,
    Callback = function(on)
        if on then startAura() else stopAura() end
    end
})

CombatGroup:CreateToggle({
    Name = "キルオーラ（即死）",
    Flag = "KillAura",
    Default = false,
    Callback = function(on)
        if on then startKillAura() else stopKillAura() end
    end
})

CombatGroup:CreateButton({
    Name = "ランダムキル",
    Callback = killRandom
})

CombatGroup:CreateButton({
    Name = "全体攻撃",
    Callback = attackAll
})

CombatGroup:CreateSlider({
    Name = "オーラ半径",
    Flag = "AuraRadius",
    Min = 3,
    Max = 20,
    Default = 8,
    Callback = function(v) CONFIG.AuraRadius = v end
})

CombatGroup:CreateSlider({
    Name = "オーラ間隔(秒)",
    Flag = "AuraInterval",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Callback = function(v) CONFIG.AuraInterval = v end
})

CombatGroup:CreateSlider({
    Name = "全体攻撃速度",
    Flag = "AttackSpeed",
    Min = 1,
    Max = 50,
    Default = 10,
    Callback = function(v) CONFIG.AttackSpeed = v end
})

CombatGroup:CreateSlider({
    Name = "全体攻撃時間(秒)",
    Flag = "AttackDuration",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(v) CONFIG.AttackDuration = v end
})

local targetDropdown = TargetGroup:CreateDropdown({
    Name = "ターゲット選択",
    Flag = "TargetSelect",
    Items = getTargetList(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then selectedTarget = Players:FindFirstChild(name) end
        end
    end
})

TargetGroup:CreateToggle({
    Name = "ターゲットLOOP攻撃",
    Flag = "TargetLoop",
    Default = false,
    Callback = toggleTargetLoop
})

TargetGroup:CreateToggle({
    Name = "AutoTP攻撃",
    Flag = "AutoTP",
    Default = false,
    Callback = toggleAutoTP
})

TargetGroup:CreateToggle({
    Name = "引き寄せ",
    Flag = "Pull",
    Default = false,
    Callback = togglePull
})

TargetGroup:CreateSlider({
    Name = "テレポート間隔(秒)",
    Flag = "TeleportInterval",
    Min = 0.02,
    Max = 0.5,
    Default = 0.15,
    Callback = function(v) CONFIG.TeleportInterval = v end
})

TargetGroup:CreateSlider({
    Name = "TP最大距離",
    Flag = "TPMaxDist",
    Min = 50,
    Max = 300,
    Default = 150,
    Callback = function(v) CONFIG.TeleportMaxDistance = v end
})

TargetGroup:CreateSlider({
    Name = "テレポート高さ",
    Flag = "TeleportHeight",
    Min = 0,
    Max = 20,
    Default = 3,
    Callback = function(v) CONFIG.TeleportHeight = v end
})

TargetGroup:CreateButton({
    Name = "リスト更新",
    Callback = function()
        updateAllLists(targetDropdown, nil, nil, nil, nil, nil)
    end
})

-- ============================================
-- タブ2: 防御
-- ============================================
local DefenseTab = Window:CreateTab("防御", true, "rbxassetid://7461510456")
local DefenseGroup = DefenseTab:CreateBlock({ Name = "防御機能", Side = "Left" })
local LavaGroup = DefenseTab:CreateBlock({ Name = "溶岩設定", Side = "Right" })

DefenseGroup:CreateToggle({
    Name = "自分スラップ無効化",
    Flag = "SelfProtection",
    Default = false,
    Callback = function(on) CONFIG.SelfSlashProtection = on end
})

DefenseGroup:CreateToggle({
    Name = "強制移動検知",
    Flag = "MoveDetection",
    Default = false,
    Callback = function(on) CONFIG.MoveDetection = on end
})

DefenseGroup:CreateToggle({
    Name = "Killブロック検知",
    Flag = "KillBlockDetection",
    Default = false,
    Callback = function(on) CONFIG.KillBlockDetection = on end
})

DefenseGroup:CreateToggle({
    Name = "Health自動回復",
    Flag = "AutoHeal",
    Default = false,
    Callback = function(on) CONFIG.AutoHeal = on end
})

DefenseGroup:CreateButton({
    Name = "検知ログ表示",
    Callback = showDetectionLogs
})

DefenseGroup:CreateSlider({
    Name = "移動検知閾値(m)",
    Flag = "MoveThreshold",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v) CONFIG.MoveThreshold = v end
})

DefenseGroup:CreateSlider({
    Name = "ログ保存数",
    Flag = "MaxLogs",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(v) CONFIG.MaxLogs = v end
})

LavaGroup:CreateSlider({
    Name = "溶岩透明度",
    Flag = "LavaTransparency",
    Min = 0,
    Max = 100,
    Default = 100,
    Callback = function(v) setLavaTransparency(v) end
})

LavaGroup:CreateToggle({
    Name = "溶岩ダメージ無効化",
    Flag = "MagmaOff",
    Default = false,
    Callback = toggleMagma
})

LavaGroup:CreateButton({
    Name = "デフォルトに戻す",
    Callback = function() setLavaTransparency(0) end
})

-- ============================================
-- タブ3: プレイヤー（空中歩行追加）
-- ============================================
local PlayerTab = Window:CreateTab("プレイヤー", true, "rbxassetid://124871982298256")
local PlayerGroup = PlayerTab:CreateBlock({ Name = "プレイヤー設定", Side = "Left" })
local TeleportGroup = PlayerTab:CreateBlock({ Name = "テレポート", Side = "Right" })
local ExtraGroup = PlayerTab:CreateBlock({ Name = "その他", Side = "Right" })
-- ★ v1.5 空中歩行専用ブロック
local HoverGroup = PlayerTab:CreateBlock({ Name = "空中歩行（ホバリング）", Side = "Left" })

-- ★ 空中歩行設定
HoverGroup:CreateToggle({
    Name = "空中歩行（ジャンプで浮遊）",
    Flag = "HoverEnable",
    Default = false,
    Callback = toggleHover
})

HoverGroup:CreateToggle({
    Name = "無限滞空モード",
    Flag = "HoverInfinite",
    Default = false,
    Callback = toggleHoverInfinite
})

HoverGroup:CreateButton({
    Name = "手動ホバリング開始/停止",
    Callback = manualHover
})

HoverGroup:CreateSlider({
    Name = "浮遊持続時間(秒)",
    Flag = "HoverDuration",
    Min = 0.5,
    Max = 20,
    Default = 3,
    Increment = 0.5,
    Callback = function(v)
        CONFIG.HoverDuration = v
        Library:Notify({
            Title = "浮遊時間",
            Content = string.format("%.1f秒に設定", v),
            Duration = 1
        })
    end
})

HoverGroup:CreateSlider({
    Name = "浮遊高さ",
    Flag = "HoverHeight",
    Min = 1,
    Max = 20,
    Default = 5,
    Increment = 0.5,
    Callback = function(v)
        CONFIG.HoverHeight = v
        Library:Notify({
            Title = "浮遊高さ",
            Content = string.format("%.1fに設定", v),
            Duration = 1
        })
    end
})

HoverGroup:CreateSlider({
    Name = "ジャンプ後の待機時間(秒)",
    Flag = "HoverJumpDelay",
    Min = 0.05,
    Max = 1,
    Default = 0.15,
    Increment = 0.05,
    Callback = function(v)
        CONFIG.HoverJumpDelay = v
        -- 設定を再適用
        if CONFIG.HoverEnabled then
            SetupHoverJumpDetection()
        end
        Library:Notify({
            Title = "待機時間",
            Content = string.format("%.2f秒に設定", v),
            Duration = 1
        })
    end
})

HoverGroup:CreateSlider({
    Name = "落下速度（遅く）",
    Flag = "HoverFallSpeed",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Increment = 0.1,
    Callback = function(v)
        CONFIG.HoverFallSpeed = v
        Library:Notify({
            Title = "落下速度",
            Content = string.format("%.1fに設定", v),
            Duration = 1
        })
    end
})

HoverGroup:CreateSlider({
    Name = "浮遊の滑らかさ",
    Flag = "HoverSmoothness",
    Min = 0.1,
    Max = 1,
    Default = 0.3,
    Increment = 0.05,
    Callback = function(v)
        CONFIG.HoverSmoothness = v
        Library:Notify({
            Title = "滑らかさ",
            Content = string.format("%.2fに設定", v),
            Duration = 1
        })
    end
})

HoverGroup:CreateButton({
    Name = "現在の高さを基準に設定",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                -- 現在地の高さを基準に浮遊高さを設定
                CONFIG.HoverHeight = 3
                Library:Notify({
                    Title = "高さ設定",
                    Content = "現在の高さ + 3 に設定しました",
                    Duration = 2
                })
            end
        end
    end
})

-- 既存のプレイヤー設定
PlayerGroup:CreateToggle({
    Name = "無限ジャンプ",
    Flag = "InfiniteJump",
    Default = false,
    Callback = toggleInfiniteJump
})

PlayerGroup:CreateSlider({
    Name = "ジャンプ力",
    Flag = "JumpPower",
    Min = 24,
    Max = 1000,
    Default = 50,
    Callback = function(v) CONFIG.JumpPower = v end
})

PlayerGroup:CreateToggle({
    Name = "移動速度",
    Flag = "SpeedToggle",
    Default = false,
    Callback = toggleSpeed
})

PlayerGroup:CreateSlider({
    Name = "速度(数値)",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Callback = function(v) CONFIG.WalkSpeed = v end
})

PlayerGroup:CreateToggle({
    Name = "壁抜け",
    Flag = "Noclip",
    Default = false,
    Callback = toggleNoclip
})

PlayerGroup:CreateToggle({
    Name = "全員テレポート",
    Flag = "MassTeleport",
    Default = false,
    Callback = toggleMassTeleport
})

PlayerGroup:CreateSlider({
    Name = "全員テレポート間隔(秒)",
    Flag = "MassTeleportInterval",
    Min = 0.05,
    Max = 1,
    Default = 0.3,
    Callback = function(v) CONFIG.MassTeleportInterval = v end
})

PlayerGroup:CreateSlider({
    Name = "全員テレポート範囲",
    Flag = "MassTeleportRadius",
    Min = 5,
    Max = 100,
    Default = 30,
    Callback = function(v) CONFIG.MassTeleportRadius = v end
})

PlayerGroup:CreateSlider({
    Name = "全員テレポート高さ",
    Flag = "MassTeleportHeight",
    Min = 0,
    Max = 50,
    Default = 10,
    Callback = function(v) CONFIG.MassTeleportHeight = v end
})

local teleportDropdown = TeleportGroup:CreateDropdown({
    Name = "テレポート先",
    Flag = "TeleportTarget",
    Items = getTargetList(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then selectedTarget = Players:FindFirstChild(name) end
        end
    end
})

TeleportGroup:CreateButton({
    Name = "テレポート実行",
    Callback = function()
        if selectedTarget then TeleportToPlayer(selectedTarget) end
    end
})

TeleportGroup:CreateInput({
    Name = "X",
    Flag = "TeleportX",
    Default = "0",
    Placeholder = "X"
})

TeleportGroup:CreateInput({
    Name = "Y",
    Flag = "TeleportY",
    Default = "10",
    Placeholder = "Y"
})

TeleportGroup:CreateInput({
    Name = "Z",
    Flag = "TeleportZ",
    Default = "0",
    Placeholder = "Z"
})

TeleportGroup:CreateButton({
    Name = "座標にテレポート",
    Callback = function()
        local x = tonumber(Library.Flags["TeleportX"] or 0) or 0
        local y = tonumber(Library.Flags["TeleportY"] or 10) or 10
        local z = tonumber(Library.Flags["TeleportZ"] or 0) or 0
        TeleportToCoordinates(x, y, z)
    end
})

TeleportGroup:CreateButton({
    Name = "現在地を取得",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                Library:Notify({ Title = "現在地", Content = string.format("(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z), Duration = 2 })
            end
        end
    end
})

TeleportGroup:CreateInput({
    Name = "保存名",
    Flag = "SaveName",
    Default = "",
    Placeholder = "名前"
})

TeleportGroup:CreateButton({
    Name = "現在地を保存",
    Callback = function()
        local name = Library.Flags["SaveName"] or ""
        if name ~= "" then
            SaveCurrentPosition(name)
            savedDropdown:Refresh(getSavedPositionNames(), true)
            deleteDropdown:Refresh(getSavedPositionNames(), true)
        end
    end
})

local savedDropdown = TeleportGroup:CreateDropdown({
    Name = "保存済み座標",
    Flag = "SavedPositions",
    Items = getSavedPositionNames(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("^(.-)%s*%(")
            if name then TeleportToSaved(name) end
        end
    end
})

local deleteDropdown = TeleportGroup:CreateDropdown({
    Name = "削除する座標",
    Flag = "DeleteSaved",
    Items = getSavedPositionNames(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("^(.-)%s*%(")
            if name then
                DeleteSavedPosition(name)
                savedDropdown:Refresh(getSavedPositionNames(), true)
                deleteDropdown:Refresh(getSavedPositionNames(), true)
            end
        end
    end
})

TeleportGroup:CreateButton({
    Name = "保存リスト更新",
    Callback = function()
        savedDropdown:Refresh(getSavedPositionNames(), true)
        deleteDropdown:Refresh(getSavedPositionNames(), true)
    end
})

ExtraGroup:CreateToggle({
    Name = "スピン",
    Flag = "Spin",
    Default = false,
    Callback = toggleSpin
})

ExtraGroup:CreateSlider({
    Name = "スピン速度",
    Flag = "SpinSpeed",
    Min = 1,
    Max = 50,
    Default = 5,
    Callback = function(v) spinSpeed = v end
})

ExtraGroup:CreateSlider({
    Name = "FOV",
    Flag = "FOV",
    Min = 40,
    Max = 120,
    Default = 70,
    Callback = setFOV
})

ExtraGroup:CreateToggle({
    Name = "ESP",
    Flag = "ESP",
    Default = false,
    Callback = toggleESP
})

ExtraGroup:CreateSlider({
    Name = "明るさ",
    Flag = "Brightness",
    Min = 0,
    Max = 10,
    Default = 2,
    Callback = function(v)
        setBrightness(v)
        Library:Notify({
            Title = "明るさ",
            Content = string.format("明るさ: %.1f", v),
            Duration = 1
        })
    end
})

-- ============================================
-- タブ4: 設定
-- ============================================
local SettingsTab = Window:CreateTab("設定", true, "rbxassetid://7059346373")
local WhitelistGroup = SettingsTab:CreateBlock({ Name = "ホワイトリスト", Side = "Left" })
local WhitelistManage = SettingsTab:CreateBlock({ Name = "ホワイトリスト管理", Side = "Right" })

WhitelistGroup:CreateToggle({
    Name = "フレンドを除外",
    Flag = "ExcludeFriends",
    Default = true,
    Callback = function(on)
        CONFIG.ExcludeFriends = on
        updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, nil, nil)
    end
})

WhitelistGroup:CreateInput({
    Name = "除外プレイヤー名",
    Flag = "ExcludedPlayer",
    Default = "",
    Placeholder = "プレイヤー名",
    Callback = function(v)
        CONFIG.ExcludedPlayer = v
        updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, nil, nil)
    end
})

local whitelistDropdown = WhitelistManage:CreateDropdown({
    Name = "追加",
    Flag = "WhitelistAdd",
    Items = getPlayerList(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then
                table.insert(CONFIG.Whitelist, name)
                whitelistDropdown:Refresh(getPlayerList(), true)
                removeDropdown:Refresh(getWhitelistForDropdown(), true)
                updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, nil, nil)
            end
        end
    end
})

local removeDropdown = WhitelistManage:CreateDropdown({
    Name = "削除",
    Flag = "WhitelistRemove",
    Items = getWhitelistForDropdown(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            for i, name in ipairs(CONFIG.Whitelist) do
                if name == v then
                    table.remove(CONFIG.Whitelist, i)
                    removeDropdown:Refresh(getWhitelistForDropdown(), true)
                    whitelistDropdown:Refresh(getPlayerList(), true)
                    updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, nil, nil)
                    break
                end
            end
        end
    end
})

WhitelistManage:CreateButton({
    Name = "全解除",
    Callback = function()
        CONFIG.Whitelist = {}
        whitelistDropdown:Refresh(getPlayerList(), true)
        removeDropdown:Refresh(getWhitelistForDropdown(), true)
        updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, nil, nil)
    end
})

WhitelistManage:CreateButton({
    Name = "全リスト更新",
    Callback = function()
        updateAllLists(targetDropdown, teleportDropdown, whitelistDropdown, removeDropdown, savedDropdown, deleteDropdown)
    end
})

-- ============================================
-- タブ5: スクリプト
-- ============================================
local ScriptTab = Window:CreateTab("スクリプト", true, "rbxassetid://4814130203")
local ScriptGroup = ScriptTab:CreateBlock({ Name = "スクリプト実行", Side = "Left" })

ScriptGroup:CreateButton({
    Name = "vFly起動",
    Callback = function()
        Library:Notify({ Title = "vFly", Content = "読み込み中...", Duration = 2 })
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-VFly-gui-and-noclip-78112"))()
            Library:Notify({ Title = "vFly", Content = "起動しました！", Duration = 2 })
        end)
    end
})

ScriptGroup:CreateButton({
    Name = "Infinite Yield起動",
    Callback = function()
        Library:Notify({ Title = "Infinite Yield", Content = "読み込み中...", Duration = 2 })
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            Library:Notify({ Title = "Infinite Yield", Content = "起動しました！", Duration = 2 })
        end)
    end
})

ScriptGroup:CreateInput({
    Name = "スクリプトURL",
    Flag = "ScriptURL",
    Default = "",
    Placeholder = "https://..."
})

ScriptGroup:CreateButton({
    Name = "カスタムスクリプト実行",
    Callback = function()
        local url = Library.Flags["ScriptURL"] or ""
        if url == "" then
            Library:Notify({ Title = "エラー", Content = "URLを入力してください", Duration = 2 })
            return
        end
        Library:Notify({ Title = "スクリプト", Content = "読み込み中...", Duration = 2 })
        pcall(function()
            loadstring(game:HttpGet(url))()
            Library:Notify({ Title = "スクリプト", Content = "実行しました！", Duration = 2 })
        end)
    end
})

-- ============================================
-- 自動更新（負荷軽減：5秒間隔）
-- ============================================
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            if whitelistDropdown then whitelistDropdown:Refresh(getPlayerList(), true) end
            if removeDropdown then removeDropdown:Refresh(getWhitelistForDropdown(), true) end
            if targetDropdown then targetDropdown:Refresh(getTargetList(), true) end
            if teleportDropdown then teleportDropdown:Refresh(getTargetList(), true) end
            if savedDropdown then savedDropdown:Refresh(getSavedPositionNames(), true) end
            if deleteDropdown then deleteDropdown:Refresh(getSavedPositionNames(), true) end
        end)
    end
end)

-- ============================================
-- 初期化完了
-- ============================================
Library:Notify({
    Title = "なべHub 溶岩タワー v1.5",
    Content = "空中歩行（ホバリング）追加版 ロード完了！",
    Duration = 3
})

print("なべHub 溶岩タワー v1.5 - 空中歩行（ホバリング）追加版 ロード完了")
