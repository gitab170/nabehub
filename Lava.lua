-- ============================================
-- なべうどん版 Lava Tower HUB - 構文修正完全版
-- ============================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ForceCheckbox = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

-- ============================================
-- 設定
-- ============================================
local CONFIG = {
    AuraRadius = 8,
    AuraInterval = 0.5,
    AttackSpeed = 10,
    AttackDuration = 3,
    ExcludedPlayer = "gitab170",
    Whitelist = {},
    ExcludeFriends = true,
    AutoTPInterval = 0.15,
    AutoTPMaxDistance = 150,
    SelfSlashProtection = false,
    MoveDetection = false,
    MoveThreshold = 50,
    KillBlockDetection = false,
    AttackDetection = false,
    AutoHeal = false,
    HealthDropThreshold = 30,
    MaxLogs = 50,
    UIScale = 0.8,
    UINotifySide = "Right",
    UIShowCursor = true,
}

local SlashRemote = ReplicatedStorage:FindFirstChild("lol")

-- ============================================
-- 検知ログシステム
-- ============================================
local detectionLogs = {}
local logIdCounter = 0

local function AddLog(logType, data)
    logIdCounter = logIdCounter + 1
    table.insert(detectionLogs, 1, {
        id = logIdCounter,
        type = logType,
        time = os.date("%H:%M:%S"),
        data = data,
    })
    while #detectionLogs > CONFIG.MaxLogs do
        table.remove(detectionLogs)
    end
end

local function ClearLogs()
    detectionLogs = {}
    logIdCounter = 0
    Library:Notify({Title = "検知ログ", Description = "全ログをクリアしました", Time = 2})
end

-- ============================================
-- ホワイトリスト管理
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

local function getValidTargets()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            table.insert(targets, p)
        end
    end
    return targets
end

local function updateWhitelistDisplay(label)
    if not label then return end
    local parts = {}
    table.insert(parts, CONFIG.ExcludeFriends and "[フレンド除外: ON]" or "[フレンド除外: OFF]")
    if #CONFIG.Whitelist > 0 then
        table.insert(parts, table.concat(CONFIG.Whitelist, ", "))
    else
        table.insert(parts, "なし")
    end
    label:Set("ホワイトリスト", table.concat(parts, " | "))
end

-- ============================================
-- サーバー情報関数（事前定義）
-- ============================================
local function getServerInfo()
    local ping = 0
    pcall(function()
        ping = Stats:GetService("NetworkStats"):GetLatency() or 0
    end)
    return {
        jobId = game.JobId or "不明",
        playerCount = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers or 0,
        ping = ping,
        fps = math.floor(1 / RunService.Heartbeat:Wait()),
        uptime = math.floor(os.clock()),
    }
end

local function formatUptime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- ============================================
-- 攻撃関数
-- ============================================
local function slashAll()
    if not SlashRemote then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    for _, target in ipairs(getValidTargets()) do
        if target == LocalPlayer then continue end
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("Head") then
            pcall(function()
                SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
            end)
        end
    end
end

local function killRandom()
    local targets = getValidTargets()
    if #targets == 0 then
        Library:Notify({Title = "ランダムキル", Description = "攻撃対象が見つかりません", Time = 2})
        return
    end
    local victim = targets[math.random(1, #targets)]
    Library:Notify({Title = "ランダムキル", Description = victim.Name .. " を攻撃中", Time = 2})
    if not SlashRemote then return end
    local t = tick()
    while tick() - t < 5 do
        local tChar = victim.Character
        if tChar and tChar:FindFirstChild("Head") then
            pcall(function()
                SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
            end)
        end
        task.wait(0.03)
    end
end

-- ============================================
-- オーラ
-- ============================================
local auraActive = false
local auraConnection = nil

local function startAura()
    if auraActive then return end
    auraActive = true
    local lastSlashTime = 0
    auraConnection = RunService.Heartbeat:Connect(function()
        if not auraActive then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local now = tick()
        if now - lastSlashTime >= CONFIG.AuraInterval and SlashRemote then
            for _, target in ipairs(getValidTargets()) do
                if target == LocalPlayer then continue end
                local tChar = target.Character
                if tChar and tChar:FindFirstChild("Head") then
                    local dist = (tChar.Head.Position - myPos).Magnitude
                    if dist <= CONFIG.AuraRadius then
                        pcall(function()
                            SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
                        end)
                    end
                end
            end
            lastSlashTime = now
        end
    end)
    Library:Notify({Title = "オーラ", Description = "ON - 半径" .. CONFIG.AuraRadius .. "m", Time = 2})
end

local function stopAura()
    auraActive = false
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection = nil
    end
    Library:Notify({Title = "オーラ", Description = "OFF", Time = 2})
end

-- ============================================
-- 自分スラップ無効化
-- ============================================
local selfProtectionConn = nil

local function toggleSelfProtection(on)
    CONFIG.SelfSlashProtection = on
    if selfProtectionConn then
        selfProtectionConn:Disconnect()
        selfProtectionConn = nil
    end
    if on then
        selfProtectionConn = RunService.Heartbeat:Connect(function()
            if not CONFIG.SelfSlashProtection then return end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end
        end)
        Library:Notify({Title = "自分スラップ無効化", Description = "ON", Time = 2})
    else
        Library:Notify({Title = "自分スラップ無効化", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- 強制移動検知
-- ============================================
local moveDetectionConn = nil
local savedPositions = {}

local function toggleMoveDetection(on)
    CONFIG.MoveDetection = on
    if moveDetectionConn then
        moveDetectionConn:Disconnect()
        moveDetectionConn = nil
    end
    savedPositions = {}
    if on then
        Library:Notify({Title = "強制移動検知", Description = "ON (閾値: " .. CONFIG.MoveThreshold .. "m)", Time = 2})
        moveDetectionConn = RunService.Heartbeat:Connect(function()
            if not CONFIG.MoveDetection then return end
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart
            local currentPos = root.Position
            table.insert(savedPositions, currentPos)
            if #savedPositions > 5 then table.remove(savedPositions, 1) end
            if #savedPositions >= 3 then
                local oldPos = savedPositions[1]
                local newPos = savedPositions[#savedPositions]
                local distance = (newPos - oldPos).Magnitude
                if distance > CONFIG.MoveThreshold then
                    AddLog("強制移動", {distance = distance, restored = true})
                    pcall(function()
                        root.CFrame = CFrame.new(oldPos)
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                    Library:Notify({
                        Title = "強制移動検知",
                        Description = string.format("%.1fmの強制移動を検知 → 復帰しました", distance),
                        Time = 3
                    })
                    savedPositions = {}
                end
            end
        end)
    else
        Library:Notify({Title = "強制移動検知", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- Killブロック検知
-- ============================================
local killBlockConn = nil

local function toggleKillBlockDetection(on)
    CONFIG.KillBlockDetection = on
    if killBlockConn then
        killBlockConn:Disconnect()
        killBlockConn = nil
    end
    if on then
        Library:Notify({Title = "Killブロック検知", Description = "ON", Time = 2})
        killBlockConn = RunService.Heartbeat:Connect(function()
            if not CONFIG.KillBlockDetection then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local myPos = root.Position
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Parent ~= char then
                    local nameLower = part.Name:lower()
                    if nameLower:find("kill") or nameLower:find("lava") or nameLower:find("death") or nameLower:find("fire") then
                        local dist = (myPos - part.Position).Magnitude
                        if dist < 3 then
                            AddLog("Killブロック", {blockName = part.Name, position = part.Position})
                            Library:Notify({
                                Title = "Killブロック検知",
                                Description = string.format("%s に接近しました", part.Name),
                                Time = 3
                            })
                            break
                        end
                    end
                end
            end
        end)
    else
        Library:Notify({Title = "Killブロック検知", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- 攻撃検知
-- ============================================
local attackDetectionConn = nil
local currentHealth = 100

local function toggleAttackDetection(on)
    CONFIG.AttackDetection = on
    if attackDetectionConn then
        attackDetectionConn:Disconnect()
        attackDetectionConn = nil
    end
    if on then
        Library:Notify({Title = "攻撃検知", Description = "ON", Time = 2})
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then currentHealth = hum.Health end
        end
        attackDetectionConn = RunService.Heartbeat:Connect(function()
            if not CONFIG.AttackDetection then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local newHealth = hum.Health
            if newHealth < currentHealth then
                local damage = currentHealth - newHealth
                local maxHealth = hum.MaxHealth
                if (newHealth / maxHealth) * 100 < (100 - CONFIG.HealthDropThreshold) then
                    local attacker = "不明"
                    local attackerName = "不明"
                    local attackerId = 0
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                            if pRoot and char:FindFirstChild("HumanoidRootPart") then
                                local dist = (pRoot.Position - char.HumanoidRootPart.Position).Magnitude
                                if dist < 15 then
                                    attacker = p.Name
                                    attackerName = p.DisplayName
                                    attackerId = p.UserId
                                    break
                                end
                            end
                        end
                    end
                    AddLog("攻撃", {
                        attacker = attacker,
                        attackerDisplay = attackerName,
                        attackerId = attackerId,
                        damage = damage,
                        health = newHealth,
                        maxHealth = maxHealth,
                    })
                    Library:Notify({
                        Title = "攻撃検知",
                        Description = string.format(
                            "発生源: %s (@%s)\nID: %d\nHP: %.0f/%.0f (-%.0f)",
                            attackerName, attacker, attackerId, newHealth, maxHealth, damage
                        ),
                        Time = 4
                    })
                end
            end
            currentHealth = newHealth
        end)
    else
        Library:Notify({Title = "攻撃検知", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- Health自動回復
-- ============================================
local autoHealConn = nil

local function toggleAutoHeal(on)
    CONFIG.AutoHeal = on
    if autoHealConn then
        autoHealConn:Disconnect()
        autoHealConn = nil
    end
    if on then
        Library:Notify({Title = "Health自動回復", Description = "ON", Time = 2})
        autoHealConn = RunService.Heartbeat:Connect(function()
            if not CONFIG.AutoHeal then return end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end
        end)
    else
        Library:Notify({Title = "Health自動回復", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- 検知ログ表示
-- ============================================
local function showDetectionLogs()
    if #detectionLogs == 0 then
        Library:Notify({Title = "検知ログ", Description = "ログがありません", Time = 2})
        return
    end
    local logText = ""
    for i = 1, math.min(10, #detectionLogs) do
        local log = detectionLogs[i]
        if log.type == "攻撃" then
            local d = log.data
            logText = logText .. string.format("[%s] 攻撃\n  発生源: %s\n  ID: %d\n  HP: %.0f/%.0f (-%.0f)\n\n",
                log.time, d.attackerDisplay or d.attacker or "不明", d.attackerId or 0, d.health or 0, d.maxHealth or 100, d.damage or 0)
        elseif log.type == "強制移動" then
            local d = log.data
            logText = logText .. string.format("[%s] 強制移動検知\n  移動距離: %.1fm\n  復帰: %s\n\n",
                log.time, d.distance or 0, d.restored and "済み" or "未")
        elseif log.type == "Killブロック" then
            local d = log.data
            logText = logText .. string.format("[%s] Killブロック検知\n  ブロック: %s\n\n",
                log.time, d.blockName or "不明")
        end
    end
    Library:Notify({Title = "検知ログ", Description = logText .. string.format("\n全ログ数: %d / %d", #detectionLogs, CONFIG.MaxLogs), Time = 8})
end

-- ============================================
-- AutoTP
-- ============================================
local autoTPConn = nil
local autoTPStartPos = nil
local autoTPActive = false

local function toggleAutoTP(on)
    autoTPActive = on
    if autoTPConn then
        autoTPConn:Disconnect()
        autoTPConn = nil
    end
    if on then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            autoTPStartPos = char.HumanoidRootPart.CFrame
        end
        Library:Notify({Title = "AutoスラップTP", Description = "ON", Time = 2})
        autoTPConn = RunService.Heartbeat:Connect(function()
            if not autoTPActive or not SlashRemote then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = myChar.HumanoidRootPart
            for _, target in ipairs(getValidTargets()) do
                if not autoTPActive then break end
                if target == LocalPlayer then continue end
                local tChar = target.Character
                if not tChar then continue end
                local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                if not tRoot then continue end
                if (myRoot.Position - tRoot.Position).Magnitude > CONFIG.AutoTPMaxDistance then continue end
                myRoot.CFrame = tRoot.CFrame
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.05)
                for i = 1, 2 do
                    if not autoTPActive then break end
                    pcall(function()
                        SlashRemote:FireServer("slash", tChar, tRoot.Position)
                    end)
                    task.wait(0.05)
                end
                if autoTPStartPos then
                    myRoot.CFrame = autoTPStartPos
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.03)
                end
            end
        end)
    else
        Library:Notify({Title = "AutoスラップTP", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- ターゲットLOOP
-- ============================================
local targetLoopActive = false
local targetLoopConn = nil
local selectedTarget = nil
local targetLoopStartPos = nil

local function toggleTargetLoop(on)
    targetLoopActive = on
    if targetLoopConn then
        targetLoopConn:Disconnect()
        targetLoopConn = nil
    end
    if on then
        if not selectedTarget then
            Library:Notify({Title = "ターゲットLOOP", Description = "先にターゲットを選択してください", Time = 2})
            targetLoopActive = false
            return
        end
        if selectedTarget == LocalPlayer then
            Library:Notify({Title = "ターゲットLOOP", Description = "自分は選択できません", Time = 2})
            targetLoopActive = false
            return
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            targetLoopStartPos = char.HumanoidRootPart.CFrame
        end
        Library:Notify({Title = "ターゲットLOOP", Description = selectedTarget.Name .. " を攻撃開始", Time = 2})
        targetLoopConn = RunService.Heartbeat:Connect(function()
            if not targetLoopActive or not SlashRemote then return end
            if not selectedTarget or not selectedTarget.Character then return end
            if selectedTarget == LocalPlayer then return end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            local myRoot = myChar.HumanoidRootPart
            local tChar = selectedTarget.Character
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            if not tRoot then return end
            if (myRoot.Position - tRoot.Position).Magnitude > CONFIG.AutoTPMaxDistance * 1.2 then return end
            myRoot.CFrame = tRoot.CFrame
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.02)
            for i = 1, 5 do
                if not targetLoopActive then break end
                pcall(function()
                    SlashRemote:FireServer("slash", tChar, tRoot.Position)
                end)
                task.wait(0.01)
            end
            if targetLoopStartPos then
                myRoot.CFrame = targetLoopStartPos
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.01)
            end
        end)
    else
        Library:Notify({Title = "ターゲットLOOP", Description = "停止", Time = 2})
    end
end

-- ============================================
-- 特殊機能
-- ============================================
local function ropeTrap()
    Library:Notify({Title = "ロープトラップ", Description = "実行中...", Time = 2})
end

local pullConn = nil
local pullActive = false

local function togglePull(on)
    pullActive = on
    if pullConn then
        pullConn:Disconnect()
        pullConn = nil
    end
    if on then
        Library:Notify({Title = "引き寄せ", Description = "ON", Time = 2})
        pullConn = RunService.Heartbeat:Connect(function()
            if not pullActive then return end
            local currentPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            if not currentPos then return end
            for _, target in ipairs(getValidTargets()) do
                if target == LocalPlayer then continue end
                local tChar = target.Character
                if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    local hrp = tChar.HumanoidRootPart
                    local offset = Vector3.new(math.random(-3, 3), 3, math.random(-3, 3))
                    hrp.CFrame = CFrame.new(currentPos + offset)
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                end
            end
        end)
    else
        Library:Notify({Title = "引き寄せ", Description = "OFF", Time = 2})
    end
end

local magmaOff = false
local lavaConn = nil

local function toggleMagma(on)
    magmaOff = on
    if lavaConn then
        lavaConn:Disconnect()
        lavaConn = nil
    end
    if on then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Lava" and v:IsA("BasePart") then
                local ti = v:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
            end
        end
        lavaConn = Workspace.DescendantAdded:Connect(function(v)
            if v.Name == "Lava" and v:IsA("BasePart") then
                task.wait(0.05)
                local ti = v:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
            end
        end)
        Library:Notify({Title = "溶岩無効化", Description = "ON", Time = 2})
    else
        Library:Notify({Title = "溶岩無効化", Description = "OFF", Time = 2})
    end
end

-- ============================================
-- ★ プレイヤーリスト取得（構文修正済み） ★
-- ============================================
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local already = false
            for _, name in ipairs(CONFIG.Whitelist) do
                if p.Name == name then
                    already = true
                    break
                end
            end
            if not already then
                table.insert(list, p.DisplayName .. " (@ " .. p.Name .. ")")
            end
        end
    end
    if #list == 0 then
        table.insert(list, "(なし)")
    end
    return list
end

local function GetWhitelistForDropdown()
    local list = {}
    for _, name in ipairs(CONFIG.Whitelist) do
        table.insert(list, name)
    end
    if #list == 0 then
        table.insert(list, "(なし)")
    end
    return list
end

local function GetTargetList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            table.insert(list, p.DisplayName .. " (@ " .. p.Name .. ")")
        end
    end
    if #list == 0 then
        table.insert(list, "(なし)")
    end
    return list
end

-- ============================================
-- サーバー情報更新関数（事前定義済み）
-- ============================================
local serverInfoLabel = nil
local playerListLabel = nil
local targetDropdown = nil
local whitelistLabel = nil
local whitelistDropdown = nil
local removeDropdown = nil
local detailToggle = false

local function updateServerInfo()
    if not serverInfoLabel then return end
    local info = getServerInfo()
    local text = string.format(
        "サーバーID: %s\nプレイヤー数: %d / %d\nPing: %.0fms\nFPS: %d\n経過時間: %s",
        string.sub(info.jobId, 1, 8) .. "...",
        info.playerCount,
        info.maxPlayers,
        info.ping,
        info.fps,
        formatUptime(info.uptime)
    )
    if detailToggle then
        text = text .. string.format("\n\n詳細情報:\nジョブID: %s", info.jobId)
    end
    serverInfoLabel:Set("サーバー情報", text)
end

local function updatePlayerList()
    if not playerListLabel then return end
    local players = Players:GetPlayers()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local sorted = {}
    for _, p in pairs(players) do
        if p ~= LocalPlayer then
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local dist = "?"
            if myRoot and root then
                dist = string.format("%.1fm", (myRoot.Position - root.Position).Magnitude)
            end
            table.insert(sorted, {
                name = p.DisplayName .. " (@ " .. p.Name .. ")",
                dist = dist,
            })
        end
    end
    table.sort(sorted, function(a, b)
        return a.name < b.name
    end)
    local text = ""
    for i, data in ipairs(sorted) do
        text = text .. string.format("%d. %s\n   距離: %s\n", i, data.name, data.dist)
        if i < #sorted then
            text = text .. "\n"
        end
    end
    if text == "" then
        text = "プレイヤーがいません"
    end
    playerListLabel:Set("プレイヤー一覧", text)
end

-- ============================================
-- Obsidian Library UI
-- ============================================
local Window = Library:CreateWindow({
    Title = "なべうどん版 Lava Tower HUB",
    Footer = "なべうどん版 Lava Tower HUB",
    NotifySide = CONFIG.UINotifySide,
    ShowCustomCursor = CONFIG.UIShowCursor,
    Scale = CONFIG.UIScale,
})

-- ===== メインタブ =====
local MainTab = Window:AddTab("メイン", "home")
local MainGroup = MainTab:AddLeftGroupbox("メイン機能")
local MainExtra = MainTab:AddRightGroupbox("情報")

MainExtra:AddLabel("なべうどん版 Lava Tower HUB")
MainExtra:AddLabel("Obsidian Library版")
MainExtra:AddLabel("RightShiftでメニュー")
MainExtra:AddLabel("")

MainGroup:AddLabel("ステータス: 準備完了")

MainGroup:AddToggle("AuraMode", {
    Text = "オーラモード",
    Default = false,
    Callback = function(on)
        if on then startAura() else stopAura() end
    end
})

MainGroup:AddButton("RandomKill", {
    Text = "ランダムキル",
    Callback = killRandom
})

MainGroup:AddButton("AllAttack", {
    Text = "全体攻撃（設定時間）",
    Callback = function()
        local sps = CONFIG.AttackSpeed
        local dur = CONFIG.AttackDuration
        local interval = 1 / sps
        local t = tick()
        while tick() - t < dur do
            slashAll()
            task.wait(interval)
        end
        Library:Notify({Title = "全体攻撃", Description = "完了", Time = 2})
    end
})

-- ===== 自己防衛タブ =====
local DefenseTab = Window:AddTab("自己防衛", "shield")
local DefenseGroup = DefenseTab:AddLeftGroupbox("防御機能")
local DefenseSettings = DefenseTab:AddRightGroupbox("検知設定")

DefenseGroup:AddLabel("自己防衛機能（全て個別トグル）")

DefenseGroup:AddToggle("SelfProtection", {
    Text = "自分スラップ無効化",
    Default = false,
    Callback = toggleSelfProtection
})

DefenseGroup:AddToggle("MoveDetection", {
    Text = "強制移動検知＆復帰",
    Default = false,
    Callback = toggleMoveDetection
})

DefenseGroup:AddToggle("KillBlockDetection", {
    Text = "Killブロック検知（自分接触時）",
    Default = false,
    Callback = toggleKillBlockDetection
})

DefenseGroup:AddToggle("AttackDetection", {
    Text = "攻撃検知（ダメージ）",
    Default = false,
    Callback = toggleAttackDetection
})

DefenseGroup:AddToggle("AutoHeal", {
    Text = "Health自動回復",
    Default = false,
    Callback = toggleAutoHeal
})

DefenseGroup:AddDivider()
DefenseGroup:AddButton("ShowLogs", {
    Text = "検知ログを表示",
    Callback = showDetectionLogs
})

DefenseGroup:AddButton("ClearLogs", {
    Text = "ログを全削除",
    Callback = ClearLogs
})

DefenseSettings:AddLabel("検知設定")

DefenseSettings:AddSlider("MoveThreshold", {
    Text = "移動検知閾値 (m)",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v) CONFIG.MoveThreshold = v end
})

DefenseSettings:AddSlider("HealthDropThreshold", {
    Text = "HP減少検知率 (%)",
    Min = 5,
    Max = 100,
    Default = 30,
    Callback = function(v) CONFIG.HealthDropThreshold = v end
})

DefenseSettings:AddSlider("MaxLogs", {
    Text = "ログ保存数",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(v)
        CONFIG.MaxLogs = v
        while #detectionLogs > CONFIG.MaxLogs do
            table.remove(detectionLogs)
        end
    end
})

-- ===== AutoTPタブ =====
local AutoTPTab = Window:AddTab("AutoTP", "rocket")
local AutoTPGroup = AutoTPTab:AddLeftGroupbox("AutoTP設定")

AutoTPGroup:AddToggle("AutoTP", {
    Text = "AutoスラップTP攻撃",
    Default = false,
    Callback = toggleAutoTP
})

AutoTPGroup:AddSlider("TPInterval", {
    Text = "TP間隔（秒）",
    Min = 0.02,
    Max = 0.3,
    Default = 0.15,
    Precise = true,
    Callback = function(v) CONFIG.AutoTPInterval = v end
})

AutoTPGroup:AddSlider("TPMaxDist", {
    Text = "TP最大距離",
    Min = 50,
    Max = 300,
    Default = 150,
    Callback = function(v) CONFIG.AutoTPMaxDistance = v end
})

-- ===== ターゲットLOOPタブ =====
local TargetLoopTab = Window:AddTab("ターゲットLOOP", "crosshair")
local TargetLoopGroup = TargetLoopTab:AddLeftGroupbox("ターゲットLOOP設定")

TargetLoopGroup:AddLabel("特定のターゲットに連続攻撃（自分除外）")

targetDropdown = TargetLoopGroup:AddDropdown("TargetSelect", {
    Text = "ターゲット選択",
    Values = GetTargetList(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then
                selectedTarget = Players:FindFirstChild(name)
                if selectedTarget then
                    Library:Notify({Title = "ターゲット設定", Description = selectedTarget.DisplayName .. " を選択", Time = 2})
                end
            end
        end
    end
})

TargetLoopGroup:AddToggle("TargetLoop", {
    Text = "ターゲットLOOP攻撃",
    Default = false,
    Callback = toggleTargetLoop
})

TargetLoopGroup:AddButton("UpdateTargetList", {
    Text = "ターゲットリスト更新",
    Callback = function()
        targetDropdown:Refresh(GetTargetList(), true)
        Library:Notify({Title = "更新", Description = "リストを更新しました", Time = 2})
    end
})

-- ===== 攻撃設定タブ =====
local AttackTab = Window:AddTab("攻撃設定", "settings")
local AttackGroup = AttackTab:AddLeftGroupbox("攻撃設定")

AttackGroup:AddSlider("AuraRadius", {
    Text = "オーラ半径",
    Min = 3,
    Max = 20,
    Default = 8,
    Callback = function(v) CONFIG.AuraRadius = v end
})

AttackGroup:AddSlider("AuraInterval", {
    Text = "オーラ間隔（秒）",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Precise = true,
    Callback = function(v) CONFIG.AuraInterval = v end
})

AttackGroup:AddSlider("AttackSpeed", {
    Text = "全体攻撃速度（回/秒）",
    Min = 1,
    Max = 50,
    Default = 10,
    Callback = function(v) CONFIG.AttackSpeed = v end
})

AttackGroup:AddSlider("AttackDuration", {
    Text = "全体攻撃時間（秒）",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(v) CONFIG.AttackDuration = v end
})

-- ===== 特殊タブ =====
local SpecialTab = Window:AddTab("特殊", "star")
local SpecialGroup = SpecialTab:AddLeftGroupbox("特殊機能")

SpecialGroup:AddButton("RopeTrap", {
    Text = "ロープトラップ",
    Callback = ropeTrap
})

SpecialGroup:AddToggle("Pull", {
    Text = "引き寄せ",
    Default = false,
    Callback = togglePull
})

SpecialGroup:AddToggle("MagmaOff", {
    Text = "溶岩無効化",
    Default = false,
    Callback = toggleMagma
})

-- ===== サーバータブ =====
local ServerTab = Window:AddTab("サーバー", "server")
local ServerInfoGroup = ServerTab:AddLeftGroupbox("サーバー情報")
local PlayerListGroup = ServerTab:AddRightGroupbox("プレイヤー一覧")

serverInfoLabel = ServerInfoGroup:AddLabel("")

ServerInfoGroup:AddButton("詳細表示", {
    Text = "詳細表示",
    Callback = function()
        detailToggle = not detailToggle
        updateServerInfo()
    end
})

playerListLabel = PlayerListGroup:AddLabel("")

PlayerListGroup:AddButton("更新", {
    Text = "更新",
    Callback = updatePlayerList
})

-- 初期表示
updateServerInfo()
updatePlayerList()

task.spawn(function()
    while true do
        task.wait(5)
        updateServerInfo()
        updatePlayerList()
    end
end)

-- ===== ホワイトリストタブ =====
local WhitelistTab = Window:AddTab("ホワイトリスト", "users")
local WhitelistGroup = WhitelistTab:AddLeftGroupbox("ホワイトリスト設定")

WhitelistGroup:AddToggle("ExcludeFriends", {
    Text = "フレンドを除外",
    Default = true,
    Callback = function(on)
        CONFIG.ExcludeFriends = on
        updateWhitelistDisplay(whitelistLabel)
        targetDropdown:Refresh(GetTargetList(), true)
        Library:Notify({Title = "フレンド除外", Description = on and "ON" or "OFF", Time = 2})
    end
})

whitelistLabel = WhitelistGroup:AddLabel("ホワイトリスト: なし")

WhitelistGroup:AddDivider()
WhitelistGroup:AddLabel("プレイヤーを追加")

whitelistDropdown = WhitelistGroup:AddDropdown("WhitelistAdd", {
    Text = "追加するプレイヤーを選択",
    Values = GetPlayerList(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then
                local player = Players:FindFirstChild(name)
                if player then
                    table.insert(CONFIG.Whitelist, name)
                    updateWhitelistDisplay(whitelistLabel)
                    whitelistDropdown:Refresh(GetPlayerList(), true)
                    removeDropdown:Refresh(GetWhitelistForDropdown(), true)
                    targetDropdown:Refresh(GetTargetList(), true)
                    Library:Notify({Title = "ホワイトリスト", Description = name .. " を追加", Time = 2})
                end
            end
        end
    end
})

WhitelistGroup:AddDivider()
WhitelistGroup:AddLabel("プレイヤーを削除")

removeDropdown = WhitelistGroup:AddDropdown("WhitelistRemove", {
    Text = "削除するプレイヤーを選択",
    Values = GetWhitelistForDropdown(),
    Default = 1,
    Callback = function(v)
        if v and v ~= "(なし)" then
            for i, name in ipairs(CONFIG.Whitelist) do
                if name == v then
                    table.remove(CONFIG.Whitelist, i)
                    updateWhitelistDisplay(whitelistLabel)
                    removeDropdown:Refresh(GetWhitelistForDropdown(), true)
                    whitelistDropdown:Refresh(GetPlayerList(), true)
                    targetDropdown:Refresh(GetTargetList(), true)
                    Library:Notify({Title = "ホワイトリスト", Description = v .. " を削除", Time = 2})
                    break
                end
            end
        end
    end
})

WhitelistGroup:AddDivider()
WhitelistGroup:AddButton("ClearWhitelist", {
    Text = "ホワイトリストを全解除",
    Callback = function()
        CONFIG.Whitelist = {}
        updateWhitelistDisplay(whitelistLabel)
        whitelistDropdown:Refresh(GetPlayerList(), true)
        removeDropdown:Refresh(GetWhitelistForDropdown(), true)
        targetDropdown:Refresh(GetTargetList(), true)
        Library:Notify({Title = "ホワイトリスト", Description = "全解除しました", Time = 2})
    end
})

task.spawn(function()
    while true do
        task.wait(5)
        if whitelistDropdown then
            whitelistDropdown:Refresh(GetPlayerList(), true)
        end
        if removeDropdown then
            removeDropdown:Refresh(GetWhitelistForDropdown(), true)
        end
        if targetDropdown then
            targetDropdown:Refresh(GetTargetList(), true)
        end
        updateWhitelistDisplay(whitelistLabel)
    end
end)

-- ===== UI設定タブ =====
local UICustomTab = Window:AddTab("UI設定", "settings")
local UICustomGroup = UICustomTab:AddLeftGroupbox("UIカスタマイズ")

UICustomGroup:AddSlider("UIScale", {
    Text = "UIサイズ",
    Min = 0.5,
    Max = 1.2,
    Default = 0.8,
    Precise = true,
    Callback = function(v)
        CONFIG.UIScale = v
        Library:Notify({Title = "UIサイズ", Description = "再起動で反映: " .. v, Time = 2})
    end
})

UICustomGroup:AddDropdown("UINotifySide", {
    Text = "通知位置",
    Values = {"Right", "Left"},
    Default = 1,
    Callback = function(v)
        CONFIG.UINotifySide = v
        Library:Notify({Title = "通知位置", Description = "再起動で反映: " .. v, Time = 2})
    end
})

UICustomGroup:AddToggle("UIShowCursor", {
    Text = "カスタムカーソル",
    Default = true,
    Callback = function(on)
        CONFIG.UIShowCursor = on
        Library:Notify({Title = "カーソル", Description = "再起動で反映", Time = 2})
    end
})

-- ===== 設定タブ =====
local SettingsTab = Window:AddTab("設定", "settings")
local SettingsGroup = SettingsTab:AddLeftGroupbox("除外設定")

SettingsGroup:AddTextbox("ExcludedPlayer", {
    Text = "除外プレイヤー名",
    Default = "gitab170",
    Placeholder = "プレイヤー名を入力",
    Callback = function(v)
        CONFIG.ExcludedPlayer = v
        Library:Notify({Title = "除外設定", Description = "設定: " .. v, Time = 2})
    end
})

SettingsGroup:AddLabel("注意: 除外プレイヤーは常に攻撃対象外です")

SettingsGroup:AddButton("ForceUpdate", {
    Text = "リストを強制更新",
    Callback = function()
        whitelistDropdown:Refresh(GetPlayerList(), true)
        removeDropdown:Refresh(GetWhitelistForDropdown(), true)
        targetDropdown:Refresh(GetTargetList(), true)
        Library:Notify({Title = "更新", Description = "リストを更新しました", Time = 2})
    end
})

-- ============================================
-- テーマ & セーブマネージャー
-- ============================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("NabeUdonHub")
SaveManager:SetFolder("NabeUdonHub/Configs")
SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)

-- ============================================
-- 初期表示更新
-- ============================================
updateWhitelistDisplay(whitelistLabel)

-- ============================================
-- 起動
-- ============================================
Library:Notify({
    Title = "なべうどん版",
    Description = "Lava Tower HUB ロード完了（構文修正版）",
    Time = 3
})

print("なべうどん版 Lava Tower HUB - 構文修正完全版 ロード完了")
