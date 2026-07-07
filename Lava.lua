-- // Lava Tower アイコン式メニュー + オーラモード(連続スラッシュ) // --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local EXCLUDED_PLAYER = "gitab170"

local SlashRemote
pcall(function()
    SlashRemote = ReplicatedStorage:WaitForChild("lol", 5)
end)

local function getValidTargets()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Name ~= EXCLUDED_PLAYER then
            table.insert(targets, p)
        end
    end
    return targets
end

local function slashAll()
    if not SlashRemote then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    for _, target in ipairs(getValidTargets()) do
        local tChar = target.Character
        if not tChar or not tChar:FindFirstChild("Head") then continue end
        pcall(function()
            SlashRemote:FireServer("slash", tChar, tChar.Head.Position)
        end)
    end
end

local function killRandom()
    local targets = getValidTargets()
    if #targets == 0 then return end
    local victim = targets[math.random(1, #targets)]
    print("[ランダムキル] " .. victim.Name)
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

-- ===== オーラモード（連続スラッシュ） =====
local auraActive = false
local auraConnection = nil
local auraParts = {}

local function startAura()
    if auraActive then return end
    auraActive = true

    local AURA_RADIUS = 8
    local AURA_INTERVAL = 0.5

    -- リング作成
    local function createAuraRing()
        local ring = Instance.new("Part")
        ring.Name = "AuraRing"
        ring.Shape = Enum.PartType.Cylinder
        ring.Size = Vector3.new(AURA_RADIUS * 2, 0.3, AURA_RADIUS * 2)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0.6
        ring.Color = Color3.fromRGB(100, 200, 255)
        ring.Material = Enum.Material.Neon
        ring.Parent = Workspace
        table.insert(auraParts, ring)
        return ring
    end

    -- 軌跡パーティクル
    local function createTrailParticle(pos)
        local p = Instance.new("Part")
        p.Name = "AuraTrail"
        p.Size = Vector3.new(0.5, 0.5, 0.5)
        p.Shape = Enum.PartType.Ball
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 0.5
        p.Color = Color3.fromRGB(
            math.random(100, 255),
            math.random(150, 255),
            255
        )
        p.Material = Enum.Material.Neon
        p.CFrame = CFrame.new(pos)
        p.Parent = Workspace
        task.delay(0.5, function() p:Destroy() end)
    end

    local lastSlashTime = 0

    auraConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        local now = tick()

        -- リング更新
        for _, ring in ipairs(auraParts) do
            if ring and ring.Parent then
                ring.CFrame = CFrame.new(myPos)
                ring.Color = Color3.fromRGB(
                    math.random(80, 150),
                    math.random(150, 255),
                    math.random(150, 255)
                )
                ring.Transparency = 0.5 + math.sin(now * 3) * 0.2
            end
        end

        -- 軌跡パーティクル
        if math.random(1, 3) == 1 then
            local angle = math.random() * math.pi * 2
            local dist = math.random(0, AURA_RADIUS)
            local trailPos = myPos + Vector3.new(
                math.cos(angle) * dist,
                math.random(-2, 2),
                math.sin(angle) * dist
            )
            createTrailParticle(trailPos)
        end

        -- 範囲内のプレイヤーにスラッシュ
        if now - lastSlashTime >= AURA_INTERVAL and SlashRemote then
            for _, target in ipairs(getValidTargets()) do
                local tChar = target.Character
                if tChar and tChar:FindFirstChild("Head") then
                    local dist = (tChar.Head.Position - myPos).Magnitude
                    if dist <= AURA_RADIUS then
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

    print("[オーラ] ON - 半径8m内を0.5秒ごとに攻撃")
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
    print("[オーラ] OFF")
end

-- ===== ロープトラップ =====
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

    if #ropeDataList == 0 then return end

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
                if player.Character and hit:IsDescendantOf(player.Character) then
                    print("[ロープトラップ] " .. player.Name .. " がロープに引っかかった")
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

-- ===== 引き寄せ =====
local pullConnection = nil
local function pullPlayersHere()
    if pullConnection then
        pullConnection:Disconnect()
        pullConnection = nil
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for _, target in ipairs(getValidTargets()) do
        local tChar = target.Character
        if tChar and tChar:FindFirstChild("HumanoidRootPart") then
            pcall(function() tChar.HumanoidRootPart:SetNetworkOwner(LocalPlayer) end)
        end
    end

    pullConnection = RunService.Heartbeat:Connect(function()
        local currentPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        if not currentPos then return end
        for _, target in ipairs(getValidTargets()) do
            local tChar = target.Character
            if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                local hrp = tChar.HumanoidRootPart
                local offset = Vector3.new(math.random(-3, 3), 3, math.random(-3, 3))
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
        for _, target in ipairs(getValidTargets()) do
            local tChar = target.Character
            if tChar and tChar:FindFirstChild("HumanoidRootPart") then
                pcall(function() tChar.HumanoidRootPart:SetNetworkOwner(nil) end)
            end
        end
    end
end

-- ===== UI =====
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0, 10, 0.5, -25)
Icon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Icon.BackgroundTransparency = 0.2
Icon.Text = "⚔️"
Icon.TextScaled = true
Icon.Font = Enum.Font.GothamBold
Icon.BorderSizePixel = 2
Icon.BorderColor3 = Color3.fromRGB(255, 200, 0)
Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 25)

local iconDragging, iconStartPos, iconFrameStart
Icon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = true
        iconStartPos = i.Position
        iconFrameStart = Icon.Position
    end
end)
Icon.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then iconDragging = false end
end)
Icon.InputChanged:Connect(function(i)
    if iconDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - iconStartPos
        Icon.Position = UDim2.new(iconFrameStart.X.Scale, iconFrameStart.X.Offset + d.X, iconFrameStart.Y.Scale, iconFrameStart.Y.Offset + d.Y)
    end
end)

-- ===== メニュー =====
local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 220, 0, 310)
MenuFrame.Position = UDim2.new(0, 70, 0.5, -155)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MenuFrame.BackgroundTransparency = 0.2
MenuFrame.BorderSizePixel = 2
MenuFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
MenuFrame.Visible = false
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MenuFrame)
Title.Size = UDim2.new(1, -20, 0, 25)
Title.Position = UDim2.new(0.5, 0, 0.03, 0)
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ Lava Tower"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", MenuFrame)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -25, 0.03, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 11)
CloseBtn.MouseButton1Click:Connect(function() MenuFrame.Visible = false end)

local function createButton(parent, y, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0.5, 0, y, 0)
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function createSlider(parent, y, label, minVal, maxVal, defaultVal)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -20, 0, 16)
    lbl.Position = UDim2.new(0.5, 0, y, 0)
    lbl.AnchorPoint = Vector2.new(0.5, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. defaultVal
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham

    local sld = Instance.new("TextBox", parent)
    sld.Size = UDim2.new(1, -20, 0, 22)
    sld.Position = UDim2.new(0.5, 0, y + 0.06, 0)
    sld.AnchorPoint = Vector2.new(0.5, 0)
    sld.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sld.TextColor3 = Color3.new(1, 1, 1)
    sld.Text = tostring(defaultVal)
    sld.Font = Enum.Font.Gotham
    sld.TextScaled = true
    sld.BorderSizePixel = 0
    Instance.new("UICorner", sld).CornerRadius = UDim.new(0, 4)

    sld.FocusLost:Connect(function()
        local num = tonumber(sld.Text)
        if num then
            num = math.clamp(num, minVal, maxVal)
            sld.Text = tostring(num)
            lbl.Text = label .. ": " .. num
        end
    end)

    return {
        Label = lbl,
        Input = sld,
        GetValue = function()
            local num = tonumber(sld.Text)
            return num or defaultVal
        end
    }
end

local BtnAura = createButton(MenuFrame, 0.13, "オーラ OFF", Color3.fromRGB(0, 150, 200))
local BtnTrap = createButton(MenuFrame, 0.24, "ロープトラップ", Color3.fromRGB(150, 0, 200))
local BtnPull = createButton(MenuFrame, 0.35, "引き寄せ OFF", Color3.fromRGB(0, 150, 200))
local BtnRandom = createButton(MenuFrame, 0.46, "ランダムキル", Color3.fromRGB(200, 100, 0))

local SliderSpeed = createSlider(MenuFrame, 0.58, "攻撃速度(回/秒)", 1, 50, 10)
local SliderDuration = createSlider(MenuFrame, 0.70, "継続時間(秒)", 1, 10, 3)

local Btn3Sec = createButton(MenuFrame, 0.82, "全体攻撃", Color3.fromRGB(200, 0, 0))
local BtnMagma = createButton(MenuFrame, 0.93, "溶岩無効化 OFF", Color3.fromRGB(200, 0, 0))

BtnAura.MouseButton1Click:Connect(function()
    if auraActive then
        stopAura()
        BtnAura.Text = "オーラ OFF"
        BtnAura.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    else
        startAura()
        BtnAura.Text = "オーラ ON"
        BtnAura.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    end
end)

local pullActive = false
BtnPull.MouseButton1Click:Connect(function()
    pullActive = not pullActive
    if pullActive then
        pullPlayersHere()
        BtnPull.Text = "引き寄せ ON"
        BtnPull.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        stopPull()
        BtnPull.Text = "引き寄せ OFF"
        BtnPull.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

Icon.MouseButton1Click:Connect(function() MenuFrame.Visible = not MenuFrame.Visible end)

local function flash(btn)
    local orig = btn.BackgroundColor3
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    task.wait(0.3)
    btn.BackgroundColor3 = orig
end

BtnTrap.MouseButton1Click:Connect(function() ropeTrap() flash(BtnTrap) end)
BtnRandom.MouseButton1Click:Connect(function() killRandom() flash(BtnRandom) end)

Btn3Sec.MouseButton1Click:Connect(function()
    local sps = SliderSpeed:GetValue()
    local dur = SliderDuration:GetValue()
    local interval = 1 / sps
    Btn3Sec.Text = "攻撃中..."
    Btn3Sec.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    local t = tick()
    while tick() - t < dur do
        slashAll()
        task.wait(interval)
    end
    Btn3Sec.Text = "全体攻撃"
    Btn3Sec.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end)

local magmaOff = false
local lavaConn
BtnMagma.MouseButton1Click:Connect(function()
    magmaOff = not magmaOff
    if magmaOff then
        for _, v in ipairs(Workspace:GetDescendants()) do
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
        BtnMagma.Text = "溶岩無効化 ON"
        BtnMagma.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    else
        if lavaConn then lavaConn:Disconnect() end
        BtnMagma.Text = "溶岩無効化 OFF"
        BtnMagma.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- メニュードラッグ
local menuDragging, menuStartPos, menuFrameStart
MenuFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and i.Target == MenuFrame then
        menuDragging = true
        menuStartPos = i.Position
        menuFrameStart = MenuFrame.Position
    end
end)
MenuFrame.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then menuDragging = false end
end)
MenuFrame.InputChanged:Connect(function(i)
    if menuDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - menuStartPos
        MenuFrame.Position = UDim2.new(menuFrameStart.X.Scale, menuFrameStart.X.Offset + d.X, menuFrameStart.Y.Scale, menuFrameStart.Y.Offset + d.Y)
    end
end)

print("メニュー読み込み完了 - オーラは0.5秒ごとに連続スラッシュ")
