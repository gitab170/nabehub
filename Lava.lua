-- OrionLib 読み込み
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ============================================
-- 設定
-- ============================================
local CONFIG = {
    -- 攻撃設定
    AuraRadius = 8,
    AuraInterval = 0.5,
    AttackSpeed = 10,
    AttackDuration = 3,
    ExcludedPlayer = "gitab170",
    Whitelist = {},
    ExcludeFriends = true,
    AutoTPInterval = 0.15,
    AutoTPMaxDistance = 150,
    SelfSlashProtection = true,
    -- エフェクト設定
    EffectEnabled = true,
    EffectIntensity = 1,
    EffectColor = Color3.fromRGB(100, 200, 255),
    EffectParticles = true,
    EffectRings = true,
    EffectTrails = true,
    SelectedColor = "青",
    SelectedEffectStyle = "デフォルト",
}

local SlashRemote = ReplicatedStorage:FindFirstChild("lol")

-- ============================================
-- エフェクト管理
-- ============================================
local effectParts = {}
local effectConnections = {}

-- ============================================
-- カラーマップ
-- ============================================
local colorMap = {
    ["青"] = Color3.fromRGB(50, 150, 255),
    ["赤"] = Color3.fromRGB(255, 50, 50),
    ["緑"] = Color3.fromRGB(50, 255, 50),
    ["黄"] = Color3.fromRGB(255, 200, 50),
    ["紫"] = Color3.fromRGB(200, 50, 255),
    ["オレンジ"] = Color3.fromRGB(255, 150, 50),
    ["ピンク"] = Color3.fromRGB(255, 50, 200),
    ["シアン"] = Color3.fromRGB(50, 255, 255),
    ["白"] = Color3.fromRGB(255, 255, 255),
    ["ネオン"] = Color3.fromRGB(0, 255, 200),
    ["コーラル"] = Color3.fromRGB(255, 127, 80),
    ["ラベンダー"] = Color3.fromRGB(180, 130, 255),
}

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
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            table.insert(targets, p)
        end
    end
    return targets
end

local function updateWhitelistDisplay(label)
    local parts = {}
    if CONFIG.ExcludeFriends then
        table.insert(parts, "[フレンド除外: ON]")
    else
        table.insert(parts, "[フレンド除外: OFF]")
    end
    if #CONFIG.Whitelist > 0 then
        table.insert(parts, table.concat(CONFIG.Whitelist, ", "))
    else
        table.insert(parts, "なし")
    end
    if label then
        label:Set("ホワイトリスト", table.concat(parts, " | "))
    end
end

-- ============================================
-- エフェクト関数
-- ============================================
local function CreateEffect(position, color, size, duration, style)
    if not CONFIG.EffectEnabled then return end
    if not position then return end
    
    local intensity = CONFIG.EffectIntensity
    color = color or CONFIG.EffectColor
    size = size or 1
    duration = duration or 1
    style = style or CONFIG.SelectedEffectStyle
    
    if CONFIG.EffectParticles then
        local count = style == "派手" and 20 * intensity or 10 * intensity
        for i = 1, count do
            local part = Instance.new("Part")
            local pSize = style == "派手" and 0.5 or 0.3
            part.Size = Vector3.new(pSize, pSize, pSize) * size
            part.Position = position + Vector3.new(
                math.random(-4, 4) * intensity,
                math.random(-4, 4) * intensity,
                math.random(-4, 4) * intensity
            )
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.2
            part.BrickColor = BrickColor.new(color)
            part.Material = Enum.Material.Neon
            part.Parent = Workspace
            table.insert(effectParts, part)
            
            task.spawn(function()
                local speed = style == "派手" and 0.03 or 0.05
                for t = 1, 15 do
                    task.wait(speed)
                    part.Transparency = part.Transparency + 0.05
                    part.Size = part.Size + Vector3.new(0.08, 0.08, 0.08)
                    if part.Transparency >= 1 then
                        part:Destroy()
                        break
                    end
                end
            end)
        end
    end
    
    if CONFIG.EffectRings then
        local ringCount = style == "派手" and 3 or 2
        for i = 1, ringCount do
            local ring = Instance.new("Part")
            local rSize = style == "派手" and size * 4 or size * 3
            ring.Size = Vector3.new(rSize * (1 + i * 0.5), 0.2, rSize * (1 + i * 0.5))
            ring.Position = position
            ring.Anchored = true
            ring.CanCollide = false
            ring.Transparency = 0.5
            ring.BrickColor = BrickColor.new(color)
            ring.Material = Enum.Material.Neon
            ring.Parent = Workspace
            table.insert(effectParts, ring)
            
            task.spawn(function()
                local startSize = ring.Size
                local speed = style == "派手" and 0.03 or 0.05
                for t = 1, 20 do
                    task.wait(speed)
                    local scale = 1 + t * 0.1
                    ring.Size = startSize * scale
                    ring.Transparency = ring.Transparency + 0.025
                    if ring.Transparency >= 1 then
                        ring:Destroy()
                        break
                    end
                end
            end)
        end
    end
end

local function CreateTrail(fromPos, toPos, color)
    if not CONFIG.EffectEnabled or not CONFIG.EffectTrails then return end
    if not fromPos or not toPos then return end
    
    color = color or CONFIG.EffectColor
    local distance = (fromPos - toPos).Magnitude
    if distance < 1 then return end
    
    local count = math.floor(distance / 1.5) * 2
    for i = 1, math.min(count, 30) do
        local t = i / math.max(1, count)
        local pos = fromPos:Lerp(toPos, t)
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.2, 0.2, 0.2)
        part.Position = pos + Vector3.new(math.random(-0.5, 0.5), math.random(-0.5, 0.5), math.random(-0.5, 0.5))
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.5
        part.BrickColor = BrickColor.new(color)
        part.Material = Enum.Material.Neon
        part.Parent = Workspace
        table.insert(effectParts, part)
        
        task.spawn(function()
            for t = 1, 10 do
                task.wait(0.05)
                part.Transparency = part.Transparency + 0.05
                part.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                if part.Transparency >= 1 then
                    part:Destroy()
                    break
                end
            end
        end)
    end
end

local function CleanupEffects()
    for _, part in ipairs(effectParts) do
        pcall(function() part:Destroy() end)
    end
    effectParts = {}
    for _, conn in ipairs(effectConnections) do
        pcall(function() conn:Disconnect() end)
    end
    effectConnections = {}
end

-- ============================================
-- 攻撃関数
-- ============================================
local function slashAll()
    if not SlashRemote then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    
    for _, target in ipairs(getValidTargets()) do
        if target == LocalPlayer then continue end
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("Head") then
            local tPos = tChar.Head.Position
            CreateTrail(myPos, tPos, Color3.fromRGB(255, 200, 50))
            CreateEffect(tPos, Color3.fromRGB(255, 100, 50), 0.5, 0.5)
            pcall(function()
                SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
            end)
        end
    end
end

local function killRandom()
    local targets = getValidTargets()
    if #targets == 0 then
        OrionLib:MakeNotification({
            Name = "ランダムキル",
            Content = "攻撃対象が見つかりません",
            Time = 2
        })
        return
    end
    local victim = targets[math.random(1, #targets)]
    OrionLib:MakeNotification({
        Name = "ランダムキル",
        Content = victim.Name .. " を攻撃中",
        Time = 2
    })
    if not SlashRemote then return end
    local t = tick()
    while tick() - t < 5 do
        local tChar = victim.Character
        if tChar and tChar:FindFirstChild("Head") then
            CreateEffect(tChar.Head.Position, Color3.fromRGB(255, 0, 0), 0.3, 0.3)
            pcall(function()
                SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
            end)
        end
        task.wait(0.03)
    end
end

-- ============================================
-- オーラモード
-- ============================================
local auraActive = false
local auraConnection = nil
local auraParts = {}

local function startAura()
    if auraActive then return end
    auraActive = true

    local function createAuraRing()
        local ring = Instance.new("Part")
        ring.Name = "AuraRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(CONFIG.AuraRadius * 2, 0.3, CONFIG.AuraRadius * 2)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0.6
        ring.Color = CONFIG.EffectColor
        ring.Material = Enum.Material.Neon
        ring.Parent = Workspace
        table.insert(auraParts, ring)
        table.insert(effectParts, ring)
        return ring
    end

    local function createTrailParticle(pos)
        if not CONFIG.EffectEnabled or not CONFIG.EffectParticles then return end
        local p = Instance.new("Part")
        p.Name = "AuraTrail"
        p.Size = Vector3.new(0.5, 0.5, 0.5)
        p.Shape = Enum.PartType.Ball
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 0.5
        p.Color = CONFIG.EffectColor
        p.Material = Enum.Material.Neon
        p.CFrame = CFrame.new(pos)
        p.Parent = Workspace
        table.insert(effectParts, p)
        table.insert(auraParts, p)
        task.delay(0.5, function() 
            if p and p.Parent then p:Destroy() end
        end)
    end

    local lastSlashTime = 0

    auraConnection = RunService.Heartbeat:Connect(function()
        if not auraActive then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local now = tick()

        for _, ring in ipairs(auraParts) do
            if ring and ring.Parent then
                ring.CFrame = CFrame.new(myPos)
                ring.Color = CONFIG.EffectColor
                ring.Transparency = 0.5 + math.sin(now * 3) * 0.2
            end
        end

        if math.random(1, 3) == 1 and CONFIG.EffectTrails then
            local angle = math.random() * math.pi * 2
            local dist = math.random(0, CONFIG.AuraRadius)
            local trailPos = myPos + Vector3.new(
                math.cos(angle) * dist,
                math.random(-2, 2),
                math.sin(angle) * dist
            )
            createTrailParticle(trailPos)
        end

        if now - lastSlashTime >= CONFIG.AuraInterval and SlashRemote then
            for _, target in ipairs(getValidTargets()) do
                if target == LocalPlayer then continue end
                local tChar = target.Character
                if tChar and tChar:FindFirstChild("Head") then
                    local dist = (tChar.Head.Position - myPos).Magnitude
                    if dist <= CONFIG.AuraRadius then
                        CreateEffect(tChar.Head.Position, CONFIG.EffectColor, 0.5, 0.3)
                        pcall(function()
                            SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
                        end)
                    end
                end
            end
            lastSlashTime = now
        end
    end)

    for _ = 1, 3 do
        createAuraRing()
    end

    OrionLib:MakeNotification({
        Name = "オーラ",
        Content = "ON - 半径" .. CONFIG.AuraRadius .. "m",
        Time = 2
    })
end

local function stopAura()
    auraActive = false
    if auraConnection then
        auraConnection:Disconnect()
        auraConnection = nil
    end
    for _, part in ipairs(auraParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    auraParts = {}
    OrionLib:MakeNotification({
        Name = "オーラ",
        Content = "OFF",
        Time = 2
    })
end

-- ============================================
-- 自分スラップ無効化
-- ============================================
local selfProtectionActive = false
local selfProtectionConn = nil

local function startSelfProtection()
    if selfProtectionActive then return end
    selfProtectionActive = true
    
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
    
    local function protectCharacter(char)
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
            end
        end
    end
    
    protectCharacter(LocalPlayer.Character)
    
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if CONFIG.SelfSlashProtection then
            protectCharacter(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
        end
    end)
    
    OrionLib:MakeNotification({
        Name = "自分スラップ無効化",
        Content = "ON",
        Time = 2
    })
end

local function stopSelfProtection()
    selfProtectionActive = false
    if selfProtectionConn then
        selfProtectionConn:Disconnect()
        selfProtectionConn = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = true
            end
        end
    end
    
    OrionLib:MakeNotification({
        Name = "自分スラップ無効化",
        Content = "OFF",
        Time = 2
    })
end

-- ============================================
-- AutoスラップTP攻撃
-- ============================================
local autoTPActive = false
local autoTPConnection = nil
local autoTPStartPos = nil

local function startAutoTP()
    if autoTPActive then return end
    autoTPActive = true
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        autoTPStartPos = char.HumanoidRootPart.CFrame
    end
    
    OrionLib:MakeNotification({
        Name = "AutoスラップTP",
        Content = "ON - 開始位置を記録しました",
        Time = 2
    })
    
    autoTPConnection = RunService.Heartbeat:Connect(function()
        if not autoTPActive then return end
        if not SlashRemote then return end
        
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myRoot = myChar.HumanoidRootPart
        local myPos = myRoot.Position
        
        local targets = getValidTargets()
        if #targets == 0 then return end
        
        for _, target in ipairs(targets) do
            if not autoTPActive then break end
            if target == LocalPlayer then continue end
            local tChar = target.Character
            if not tChar then continue end
            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
            if not tRoot then continue end
            
            local dist = (myPos - tRoot.Position).Magnitude
            
            if dist > CONFIG.AutoTPMaxDistance then
                continue
            end
            
            CreateEffect(myPos, Color3.fromRGB(0, 150, 255), 1, 0.3)
            
            myRoot.CFrame = tRoot.CFrame
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            
            CreateEffect(tRoot.Position, Color3.fromRGB(255, 200, 0), 1, 0.3)
            CreateTrail(myPos, tRoot.Position, Color3.fromRGB(0, 200, 255))
            
            task.wait(0.05)
            
            for i = 1, 2 do
                if not autoTPActive then break end
                CreateEffect(tRoot.Position, Color3.fromRGB(255, 100, 0), 0.5, 0.2)
                pcall(function()
                    SlashRemote:FireServer("slash", tChar, tRoot.Position)
                end)
                task.wait(0.05)
            end
            
            if autoTPStartPos then
                CreateEffect(myRoot.Position, Color3.fromRGB(0, 150, 255), 1, 0.3)
                myRoot.CFrame = autoTPStartPos
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.03)
            end
        end
    end)
end

local function stopAutoTP()
    autoTPActive = false
    if autoTPConnection then
        autoTPConnection:Disconnect()
        autoTPConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and autoTPStartPos then
        char.HumanoidRootPart.CFrame = autoTPStartPos
        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end
    
    autoTPStartPos = nil
    OrionLib:MakeNotification({
        Name = "AutoスラップTP",
        Content = "OFF",
        Time = 2
    })
end

-- ============================================
-- ターゲットLOOP攻撃
-- ============================================
local targetLoopActive = false
local targetLoopConnection = nil
local selectedTarget = nil
local targetLoopStartPos = nil

local function startTargetLoop()
    if targetLoopActive then return end
    if not selectedTarget then
        OrionLib:MakeNotification({
            Name = "ターゲットLOOP",
            Content = "先にターゲットを選択してください",
            Time = 2
        })
        return
    end
    
    if selectedTarget == LocalPlayer then
        OrionLib:MakeNotification({
            Name = "ターゲットLOOP",
            Content = "自分は選択できません",
            Time = 2
        })
        return
    end
    
    targetLoopActive = true
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        targetLoopStartPos = char.HumanoidRootPart.CFrame
    end
    
    OrionLib:MakeNotification({
        Name = "ターゲットLOOP",
        Content = selectedTarget.Name .. " を攻撃開始",
        Time = 2
    })
    
    targetLoopConnection = RunService.Heartbeat:Connect(function()
        if not targetLoopActive then return end
        if not SlashRemote then return end
        if not selectedTarget or not selectedTarget.Character then return end
        if selectedTarget == LocalPlayer then return end
        
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myRoot = myChar.HumanoidRootPart
        local myPos = myRoot.Position
        
        local tChar = selectedTarget.Character
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        
        local dist = (myPos - tRoot.Position).Magnitude
        
        if dist > CONFIG.AutoTPMaxDistance * 1.2 then
            return
        end
        
        CreateEffect(myPos, Color3.fromRGB(0, 150, 255), 0.5, 0.2)
        
        myRoot.CFrame = tRoot.CFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        
        CreateEffect(tRoot.Position, Color3.fromRGB(255, 200, 0), 0.5, 0.2)
        
        task.wait(0.02)
        
        for i = 1, 5 do
            if not targetLoopActive then break end
            CreateEffect(tRoot.Position, Color3.fromRGB(255, 0, 0), 0.3, 0.1)
            pcall(function()
                SlashRemote:FireServer("slash", tChar, tRoot.Position)
            end)
            task.wait(0.01)
        end
        
        if targetLoopStartPos then
            CreateEffect(myRoot.Position, Color3.fromRGB(0, 150, 255), 0.5, 0.2)
            myRoot.CFrame = targetLoopStartPos
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.01)
        end
    end)
end

local function stopTargetLoop()
    targetLoopActive = false
    if targetLoopConnection then
        targetLoopConnection:Disconnect()
        targetLoopConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and targetLoopStartPos then
        char.HumanoidRootPart.CFrame = targetLoopStartPos
        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end
    
    targetLoopStartPos = nil
    OrionLib:MakeNotification({
        Name = "ターゲットLOOP",
        Content = "停止",
        Time = 2
    })
end

-- ============================================
-- ロープトラップ
-- ============================================
local function ropeTrap()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    local headY = myPos.Y + 5

    local ropeDataList = {}
    local ropeKeywords = {"Rope", "RopeConstraint", "Rod", "Wire", "Chain", "String", "Thread", "Swing", "Pendulum"}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Constraint") then
            local nameLower = obj.Name:lower()
            for _, kw in ipairs(ropeKeywords) do
                if nameLower:find(kw:lower()) and obj.Attachment0 then
                    local part = obj.Attachment0.Parent
                    if part:IsA("BasePart") then
                        table.insert(ropeDataList, { Constraint = obj, Part = part })
                        break
                    end
                end
            end
        end
    end

    if #ropeDataList == 0 then
        OrionLib:MakeNotification({Name = "ロープトラップ", Content = "ロープが見つかりません", Time = 2})
        return
    end

    local pickCount = math.random(1, math.min(2, #ropeDataList))
    local pickedRopes = {}
    local ropeCopy = {}
    for _, v in ipairs(ropeDataList) do table.insert(ropeCopy, v) end
    for _ = 1, pickCount do
        local idx = math.random(1, #ropeCopy)
        table.insert(pickedRopes, ropeCopy[idx])
        table.remove(ropeCopy, idx)
    end

    for _, data in ipairs(pickedRopes) do
        data.Constraint.Enabled = false
        local angle = math.random() * math.pi * 2
        local dist = math.random(5, 20)
        local offset = Vector3.new(math.cos(angle) * dist, headY - myPos.Y, math.sin(angle) * dist)
        data.Part.CFrame = CFrame.new(myPos + offset)
        data.Part.Velocity = Vector3.zero
        data.Part.RotVelocity = Vector3.zero
    end

    local holdConnection
    holdConnection = RunService.Heartbeat:Connect(function()
        for _, data in ipairs(pickedRopes) do
            if data.Part and data.Part.Parent then
                data.Part.Velocity = Vector3.zero
                data.Part.RotVelocity = Vector3.zero
            end
        end
    end)

    for _, target in ipairs(getValidTargets()) do
        if target == LocalPlayer then continue end
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            local hrp = tChar.HumanoidRootPart
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
            local offset = Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
            hrp.CFrame = CFrame.new(myPos + offset)
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end

    local connections = {}
    for _, data in ipairs(pickedRopes) do
        local conn
        conn = data.Part.Touched:Connect(function(hit)
            for _, player in ipairs(getValidTargets()) do
                if player == LocalPlayer then continue end
                if player.Character and hit:IsDescendantOf(player.Character) then
                    CreateEffect(hit.Position, Color3.fromRGB(255, 200, 0), 1, 0.5)
                    OrionLib:MakeNotification({
                        Name = "ロープトラップ",
                        Content = player.Name .. " が引っかかった",
                        Time = 2
                    })
                    data.Constraint.Enabled = true
                    if conn then conn:Disconnect() end
                    if holdConnection then holdConnection:Disconnect() end
                    break
                end
            end
        end)
        table.insert(connections, conn)
    end

    task.delay(15, function()
        for _, data in ipairs(pickedRopes) do
            if not data.Constraint.Enabled then data.Constraint.Enabled = true end
        end
        for _, conn in ipairs(connections) do
            if conn then conn:Disconnect() end
        end
        if holdConnection then holdConnection:Disconnect() end
    end)
end

-- ============================================
-- 引き寄せ
-- ============================================
local pullConnection = nil
local pullActive = false

local function pullPlayersHere()
    if pullConnection then
        pullConnection:Disconnect()
        pullConnection = nil
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for _, target in ipairs(getValidTargets()) do
        if target == LocalPlayer then continue end
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            pcall(function() tChar.HumanoidRootPart:SetNetworkOwner(LocalPlayer) end)
        end
    end

    pullConnection = RunService.Heartbeat:Connect(function()
        if not pullActive then return end
        local currentPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        if not currentPos then return end
        for _, target in ipairs(getValidTargets()) do
            if target == LocalPlayer then continue end
            local tChar = target.Character
            if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                local hrp = tChar.HumanoidRootPart
                local offset = Vector3.new(math.random(-3, 3), 3, math.random(-3, 3))
                CreateEffect(hrp.Position, Color3.fromRGB(0, 200, 255), 0.5, 0.2)
                hrp.CFrame = CFrame.new(currentPos + offset)
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function stopPull()
    if pullConnection then
        pullConnection:Disconnect()
        pullConnection = nil
    end
    for _, target in ipairs(getValidTargets()) do
        if target == LocalPlayer then continue end
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            pcall(function() tChar.HumanoidRootPart:SetNetworkOwner(nil) end)
        end
    end
end

-- ============================================
-- 溶岩無効化
-- ============================================
local magmaOff = false
local lavaConn = nil

local function toggleMagma(on)
    magmaOff = on
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Lava" and v:IsA("BasePart") then
                local ti = v:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
                CreateEffect(v.Position, Color3.fromRGB(255, 100, 0), 0.5, 0.3)
            end
        end
        lavaConn = Workspace.DescendantAdded:Connect(function(v)
            if v.Name == "Lava" and v:IsA("BasePart") then
                task.wait(0.05)
                local ti = v:FindFirstChild("TouchInterest")
                if ti then ti:Destroy() end
                CreateEffect(v.Position, Color3.fromRGB(255, 100, 0), 0.3, 0.2)
            end
        end)
        OrionLib:MakeNotification({Name = "溶岩無効化", Content = "ON", Time = 2})
    else
        if lavaConn then
            lavaConn:Disconnect()
            lavaConn = nil
        end
        OrionLib:MakeNotification({Name = "溶岩無効化", Content = "OFF", Time = 2})
    end
end

-- ============================================
-- プレイヤーリスト取得
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
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function GetWhitelistForDropdown()
    local list = {}
    for _, name in ipairs(CONFIG.Whitelist) do
        table.insert(list, name)
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

local function GetTargetList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not isWhitelisted(p) then
            table.insert(list, p.DisplayName .. " (@ " .. p.Name .. ")")
        end
    end
    if #list == 0 then table.insert(list, "(なし)") end
    return list
end

-- ============================================
-- OrionLib GUI
-- ============================================
local Window = OrionLib:MakeWindow({
    Name = "なべうどん版 Lava Tower HUB",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "なべうどん版 Lava Tower Hub",
    IntroIcon = "rbxassetid://4483345998"
})

-- ===== メインタブ =====
local MainTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://4483345998"
})

MainTab:AddParagraph("ステータス", "準備完了")
MainTab:AddParagraph("攻撃対象", "ホワイトリスト除外済み")

MainTab:AddToggle({
    Name = "オーラモード",
    Default = false,
    Callback = function(on)
        if on then
            startAura()
        else
            stopAura()
        end
    end
})

MainTab:AddButton({
    Name = "ランダムキル",
    Callback = function()
        killRandom()
    end
})

MainTab:AddButton({
    Name = "全体攻撃（設定時間）",
    Callback = function()
        local sps = CONFIG.AttackSpeed
        local dur = CONFIG.AttackDuration
        local interval = 1 / sps
        MainTab:SetParagraph("ステータス", "全体攻撃中...")
        local t = tick()
        while tick() - t < dur do
            slashAll()
            task.wait(interval)
        end
        MainTab:SetParagraph("ステータス", "準備完了")
        OrionLib:MakeNotification({Name = "全体攻撃", Content = "完了", Time = 2})
    end
})

-- ===== エフェクト設定タブ =====
local EffectTab = Window:MakeTab({
    Name = "エフェクト",
    Icon = "rbxassetid://4483345998"
})

EffectTab:AddParagraph("エフェクト設定", "攻撃時のビジュアルエフェクトをカスタマイズ")

EffectTab:AddToggle({
    Name = "エフェクト有効",
    Default = true,
    Callback = function(on)
        CONFIG.EffectEnabled = on
        if not on then
            CleanupEffects()
        end
        OrionLib:MakeNotification({
            Name = "エフェクト",
            Content = on and "ON" or "OFF",
            Time = 2
        })
    end
})

EffectTab:AddSlider({
    Name = "エフェクト強度",
    Min = 0.5,
    Max = 3,
    Default = 1,
    Increment = 0.1,
    Callback = function(v)
        CONFIG.EffectIntensity = v
    end
})

EffectTab:AddSection("エフェクト種類")

EffectTab:AddToggle({
    Name = "パーティクル",
    Default = true,
    Callback = function(on)
        CONFIG.EffectParticles = on
    end
})

EffectTab:AddToggle({
    Name = "リング",
    Default = true,
    Callback = function(on)
        CONFIG.EffectRings = on
    end
})

EffectTab:AddToggle({
    Name = "軌跡（トレイル）",
    Default = true,
    Callback = function(on)
        CONFIG.EffectTrails = on
    end
})

EffectTab:AddSection("カラー設定")

local colorOptions = {"青", "赤", "緑", "黄", "紫", "オレンジ", "ピンク", "シアン", "白", "ネオン", "コーラル", "ラベンダー"}

EffectTab:AddDropdown({
    Name = "エフェクト色",
    Default = "青",
    Options = colorOptions,
    Callback = function(v)
        CONFIG.SelectedColor = v
        CONFIG.EffectColor = colorMap[v] or Color3.fromRGB(100, 200, 255)
        OrionLib:MakeNotification({
            Name = "エフェクト色",
            Content = v .. " に設定",
            Time = 2
        })
    end
})

EffectTab:AddSection("スタイル設定")

local effectStyles = {"デフォルト", "派手", "ミニマル", "ネオン", "ゴースト"}

EffectTab:AddDropdown({
    Name = "エフェクトスタイル",
    Default = "デフォルト",
    Options = effectStyles,
    Callback = function(v)
        CONFIG.SelectedEffectStyle = v
        if v == "派手" then
            CONFIG.EffectParticles = true
            CONFIG.EffectRings = true
            CONFIG.EffectTrails = true
            CONFIG.EffectIntensity = 2
        elseif v == "ミニマル" then
            CONFIG.EffectParticles = true
            CONFIG.EffectRings = false
            CONFIG.EffectTrails = false
            CONFIG.EffectIntensity = 0.5
        elseif v == "ネオン" then
            CONFIG.EffectColor = Color3.fromRGB(0, 255, 200)
            CONFIG.EffectParticles = true
            CONFIG.EffectRings = true
            CONFIG.EffectTrails = true
            CONFIG.EffectIntensity = 1.5
        elseif v == "ゴースト" then
            CONFIG.EffectColor = Color3.fromRGB(200, 200, 255)
            CONFIG.EffectParticles = true
            CONFIG.EffectRings = true
            CONFIG.EffectTrails = false
            CONFIG.EffectIntensity = 0.8
        else
            CONFIG.EffectParticles = true
            CONFIG.EffectRings = true
            CONFIG.EffectTrails = true
            CONFIG.EffectIntensity = 1
        end
        OrionLib:MakeNotification({
            Name = "エフェクトスタイル",
            Content = v .. " に設定",
            Time = 2
        })
    end
})

EffectTab:AddButton({
    Name = "エフェクトクリア",
    Callback = function()
        CleanupEffects()
        OrionLib:MakeNotification({
            Name = "エフェクト",
            Content = "クリアしました",
            Time = 2
        })
    end
})

-- ===== 自己防御タブ =====
local SelfProtectTab = Window:MakeTab({
    Name = "自己防御",
    Icon = "rbxassetid://4483345998"
})

SelfProtectTab:AddParagraph("自分スラップ無効化", "自分にスラップが当たらないようにします")

SelfProtectTab:AddToggle({
    Name = "自分スラップ無効化",
    Default = true,
    Callback = function(on)
        CONFIG.SelfSlashProtection = on
        if on then
            startSelfProtection()
        else
            stopSelfProtection()
        end
    end
})

SelfProtectTab:AddParagraph("注意", "自分へのスラップダメージを完全に無効化します")

-- ===== AutoスラップTPタブ =====
local AutoTPTab = Window:MakeTab({
    Name = "AutoTP",
    Icon = "rbxassetid://4483345998"
})

AutoTPTab:AddParagraph("AutoスラップTP", "全員に高速TPしてスラップ攻撃（自分除外）")

AutoTPTab:AddToggle({
    Name = "AutoスラップTP攻撃",
    Default = false,
    Callback = function(on)
        if on then
            startAutoTP()
        else
            stopAutoTP()
        end
    end
})

AutoTPTab:AddSlider({
    Name = "TP間隔（秒）",
    Min = 0.02,
    Max = 0.3,
    Default = 0.15,
    Increment = 0.01,
    Callback = function(v)
        CONFIG.AutoTPInterval = v
    end
})

AutoTPTab:AddSlider({
    Name = "TP最大距離",
    Min = 50,
    Max = 300,
    Default = 150,
    Increment = 10,
    Callback = function(v)
        CONFIG.AutoTPMaxDistance = v
    end
})

AutoTPTab:AddParagraph("注意", "TP最大距離を超えると対象外になります")

-- ===== ターゲットLOOPタブ =====
local TargetLoopTab = Window:MakeTab({
    Name = "ターゲットLOOP",
    Icon = "rbxassetid://4483345998"
})

TargetLoopTab:AddParagraph("ターゲットLOOP", "特定のターゲットに連続攻撃（自分除外）")

local targetDropdown = TargetLoopTab:AddDropdown({
    Name = "ターゲット選択",
    Default = "",
    Options = GetTargetList(),
    Callback = function(v)
        if v and v ~= "(なし)" then
            local name = v:match("%@%s*(.-)%)")
            if name then
                selectedTarget = Players:FindFirstChild(name)
                if selectedTarget then
                    OrionLib:MakeNotification({
                        Name = "ターゲット設定",
                        Content = selectedTarget.DisplayName .. " を選択",
                        Time = 2
                    })
                end
            end
        end
    end
})

TargetLoopTab:AddToggle({
    Name = "ターゲットLOOP攻撃",
    Default = false,
    Callback = function(on)
        if on then
            startTargetLoop()
        else
            stopTargetLoop()
        end
    end
})

TargetLoopTab:AddButton({
    Name = "ターゲットリスト更新",
    Callback = function()
        targetDropdown:Refresh(GetTargetList(), true)
        OrionLib:MakeNotification({
            Name = "更新",
            Content = "リストを更新しました",
            Time = 2
        })
    end
})

-- ===== 攻撃設定タブ =====
local AttackTab = Window:MakeTab({
    Name = "攻撃設定",
    Icon = "rbxassetid://4483345998"
})

AttackTab:AddSlider({
    Name = "オーラ半径",
    Min = 3,
    Max = 20,
    Default = 8,
    Callback = function(v)
        CONFIG.AuraRadius = v
    end
})

AttackTab:AddSlider({
    Name = "オーラ間隔（秒）",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Increment = 0.1,
    Callback = function(v)
        CONFIG.AuraInterval = v
    end
})

AttackTab:AddSlider({
    Name = "全体攻撃速度（回/秒）",
    Min = 1,
    Max = 50,
    Default = 10,
    Callback = function(v)
        CONFIG.AttackSpeed = v
    end
})

AttackTab:AddSlider({
    Name = "全体攻撃時間（秒）",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(v)
        CONFIG.AttackDuration = v
    end
})

-- ===== 特殊タブ =====
local SpecialTab = Window:MakeTab({
    Name = "特殊",
    Icon = "rbxassetid://4483345998"
})

SpecialTab:AddButton({
    Name = "ロープトラップ",
    Callback = function()
        ropeTrap()
    end
})

SpecialTab:AddToggle({
    Name = "引き寄せ",
    Default = false,
    Callback = function(on)
        pullActive = on
        if on then
            pullPlayersHere()
            OrionLib:MakeNotification({Name = "引き寄せ", Content = "ON", Time = 2})
        else
            stopPull()
            OrionLib:MakeNotification({Name = "引き寄せ", Content = "OFF", Time = 2})
        end
    end
})

SpecialTab:AddToggle({
    Name = "溶岩無効化",
    Default = false,
    Callback = function(on)
        toggleMagma(on)
    end
})

-- ===== ホワイトリストタブ =====
local WhitelistTab = Window:MakeTab({
    Name = "ホワイトリスト",
    Icon = "rbxassetid://4483345998"
})

WhitelistTab:AddToggle({
    Name = "フレンドを除外",
    Default = true,
    Callback = function(on)
        CONFIG.ExcludeFriends = on
        updateWhitelistDisplay(whitelistLabel)
        targetDropdown:Refresh(GetTargetList(), true)
        OrionLib:MakeNotification({
            Name = "フレンド除外",
            Content = on and "ON" or "OFF",
            Time = 2
        })
    end
})

local whitelistLabel = WhitelistTab:AddParagraph("ホワイトリスト", "")

WhitelistTab:AddSection("プレイヤーを追加")

local whitelistDropdown = WhitelistTab:AddDropdown({
    Name = "追加するプレイヤーを選択",
    Default = "",
    Options = GetPlayerList(),
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
                    OrionLib:MakeNotification({
                        Name = "ホワイトリスト",
                        Content = name .. " を追加",
                        Time = 2
                    })
                end
            end
        end
    end
})

WhitelistTab:AddSection("プレイヤーを削除")

local removeDropdown = WhitelistTab:AddDropdown({
    Name = "削除するプレイヤーを選択",
    Default = "",
    Options = GetWhitelistForDropdown(),
    Callback = function(v)
        if v and v ~= "(なし)" then
            for i, name in ipairs(CONFIG.Whitelist) do
                if name == v then
                    table.remove(CONFIG.Whitelist, i)
                    updateWhitelistDisplay(whitelistLabel)
                    removeDropdown:Refresh(GetWhitelistForDropdown(), true)
                    whitelistDropdown:Refresh(GetPlayerList(), true)
                    targetDropdown:Refresh(GetTargetList(), true)
                    OrionLib:MakeNotification({
                        Name = "ホワイトリスト",
                        Content = v .. " を削除",
                        Time = 2
                    })
                    break
                end
            end
        end
    end
})

WhitelistTab:AddSection("一括操作")

WhitelistTab:AddButton({
    Name = "ホワイトリストを全解除",
    Callback = function()
        CONFIG.Whitelist = {}
        updateWhitelistDisplay(whitelistLabel)
        whitelistDropdown:Refresh(GetPlayerList(), true)
        removeDropdown:Refresh(GetWhitelistForDropdown(), true)
        targetDropdown:Refresh(GetTargetList(), true)
        OrionLib:MakeNotification({
            Name = "ホワイトリスト",
            Content = "全解除しました",
            Time = 2
        })
    end
})

-- ホワイトリスト自動更新（5秒ごと）
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

-- ===== 設定タブ =====
local SettingsTab = Window:MakeTab({
    Name = "設定",
    Icon = "rbxassetid://4483345998"
})

SettingsTab:AddSection("除外設定")

SettingsTab:AddTextbox({
    Name = "除外プレイヤー名",
    Default = "gitab170",
    Placeholder = "プレイヤー名を入力",
    Callback = function(v)
        CONFIG.ExcludedPlayer = v
        OrionLib:MakeNotification({
            Name = "除外設定",
            Content = "設定: " .. v,
            Time = 2
        })
    end
})

SettingsTab:AddParagraph("注意", "除外プレイヤーは常に攻撃対象外です")

SettingsTab:AddButton({
    Name = "リストを強制更新",
    Callback = function()
        whitelistDropdown:Refresh(GetPlayerList(), true)
        removeDropdown:Refresh(GetWhitelistForDropdown(), true)
        targetDropdown:Refresh(GetTargetList(), true)
        OrionLib:MakeNotification({
            Name = "更新",
            Content = "リストを更新しました",
            Time = 2
        })
    end
})

-- ============================================
-- 初期表示更新
-- ============================================
updateWhitelistDisplay(whitelistLabel)

-- 自分スラップ無効化を自動開始
startSelfProtection()

-- ============================================
-- OrionLib初期化
-- ============================================
OrionLib:Init()

print("なべうどん版 Lava Tower HUB - 機能全部入り完全版 ロード完了")
