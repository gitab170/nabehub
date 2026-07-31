-- // ユニバーサル引き寄せ v2.1 - 安定性強化 + 最小化ボタン
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if PlayerGui:FindFirstChild("PullGUI") then PlayerGui.PullGUI:Destroy() end

local CONFIG = {
    Enabled = false,
    Pattern = "回転",
    Speed = 1,
    Radius = 12,
    Height = 3,
    Strength = 50,
    MaxParts = 30,
    MaxDistance = 60,
}

local enabled = false
local connection = nil
local angle = 0
local time = 0
local isMinimized = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PullGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, -35, 0, 30)
TitleBar.Text = "引き寄せ v2.1"
TitleBar.TextColor3 = Color3.fromRGB(255, 180, 50)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 14
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

-- 最小化ボタン
local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -32, 0, 0)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 2
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

-- 最小化した時のコンテンツ（タイトルバー以外）
local contentElements = {}

-- メインON/OFF
local MainToggle = Instance.new("TextButton", MainFrame)
MainToggle.Size = UDim2.new(0.9, 0, 0, 35)
MainToggle.Position = UDim2.new(0.05, 0, 0, 40)
MainToggle.Text = "[ ] 引き寄せ"
MainToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainToggle.TextColor3 = Color3.fromRGB(255, 180, 50)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 14
MainToggle.BorderSizePixel = 0
Instance.new("UICorner", MainToggle).CornerRadius = UDim.new(0, 6)
table.insert(contentElements, MainToggle)

-- パターン選択ラベル
local PatternLabel = Instance.new("TextLabel", MainFrame)
PatternLabel.Size = UDim2.new(0.9, 0, 0, 20)
PatternLabel.Position = UDim2.new(0.05, 0, 0, 85)
PatternLabel.BackgroundTransparency = 1
PatternLabel.Text = "パターン選択"
PatternLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PatternLabel.Font = Enum.Font.Code
PatternLabel.TextSize = 11
PatternLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(contentElements, PatternLabel)

-- パターンボタン
local patterns = {"回転", "渦巻き", "上下波動", "ランダム", "静止"}
local patternBtns = {}
for i, name in ipairs(patterns) do
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.42, 0, 0, 28)
    btn.Position = UDim2.new(i % 2 == 1 and 0.05 or 0.53, 0, 0, 110 + math.floor((i-1)/2) * 33)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        CONFIG.Pattern = name
        for _, b in ipairs(patternBtns) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 150, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    patternBtns[i] = btn
    table.insert(contentElements, btn)
end
patternBtns[1].BackgroundColor3 = Color3.fromRGB(255, 150, 30)
patternBtns[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- スライダー
local function createSlider(name, min, max, def, y, callback)
    local container = Instance.new("Frame", MainFrame)
    container.Size = UDim2.new(0.9, 0, 0, 45)
    container.Position = UDim2.new(0.05, 0, 0, y)
    container.BackgroundTransparency = 1
    table.insert(contentElements, container)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. def
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Code
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", container)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = UDim2.new((def - min) / (max - min), -7, -0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 150, 30)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local val = def
    local hold = false

    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hold = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            hold = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if hold and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(pct, -7, -0.5, 0)
            val = math.floor(min + pct * (max - min))
            label.Text = name .. ": " .. val
            if callback then callback(val) end
        end
    end)
end

createSlider("速度", 0.1, 5, 1, 195, function(v) CONFIG.Speed = v end)
createSlider("半径", 3, 30, 12, 245, function(v) CONFIG.Radius = v end)
createSlider("高さ", -5, 15, 3, 295, function(v) CONFIG.Height = v end)
createSlider("強さ", 10, 100, 50, 345, function(v) CONFIG.Strength = v end)

-- 最小化ボタン処理
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 30)
        MinimizeBtn.Text = "+"
        for _, el in ipairs(contentElements) do
            el.Visible = false
        end
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MinimizeBtn.Text = "_"
        for _, el in ipairs(contentElements) do
            el.Visible = true
        end
    end
end)

-- ドラッグ
local function makeDraggable(gui, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = Vector2.new(gui.AbsolutePosition.X, gui.AbsolutePosition.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            local newX = startPos.X + delta.X
            local newY = startPos.Y + delta.Y
            local halfW = gui.AbsoluteSize.X / 2
            local halfH = gui.AbsoluteSize.Y / 2
            newX = math.clamp(newX, halfW, Camera.ViewportSize.X - halfW)
            newY = math.clamp(newY, halfH, Camera.ViewportSize.Y - halfH)
            gui.Position = UDim2.new(0, newX - halfW, 0, newY - halfH)
        end
    end)
end
makeDraggable(MainFrame, TitleBar)

-- パーツ判定（キャッシュ化でラグ軽減）
local playerPartsCache = {}
local lastCacheClear = 0

local function isPlayerPart(part)
    local now = os.clock()
    if now - lastCacheClear > 1 then
        playerPartsCache = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, d in pairs(p.Character:GetDescendants()) do
                    if d:IsA("BasePart") then playerPartsCache[d] = true end
                end
            end
        end
        lastCacheClear = now
    end
    return playerPartsCache[part] == true
end

-- 引き寄せロジック（ラグ軽減版）
local function startPull()
    if connection then return end
    connection = RunService.Heartbeat:Connect(function(dt)
        if not enabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local myPos = root.Position

        angle = angle + CONFIG.Speed * dt * 60
        time = time + dt
        local count = 0

        for _, obj in pairs(Workspace:GetDescendants()) do
            if count >= CONFIG.MaxParts then break end
            if not obj:IsA("BasePart") then continue end
            if obj.Anchored then continue end
            if isPlayerPart(obj) then continue end
            if obj:IsDescendantOf(char) then continue end

            local dist = (obj.Position - myPos).Magnitude
            if dist < CONFIG.MaxDistance then
                count = count + 1
                local targetPos
                local r = math.min(dist * 0.4, CONFIG.Radius)
                r = math.max(3, r)

                if CONFIG.Pattern == "回転" then
                    local a = angle + (count * 0.6)
                    targetPos = myPos + Vector3.new(math.cos(a) * r, CONFIG.Height + math.sin(count * 0.3) * 1.5, math.sin(a) * r)
                elseif CONFIG.Pattern == "渦巻き" then
                    local a = angle + (count * 0.3)
                    targetPos = myPos + Vector3.new(math.cos(a) * math.min(count * 0.8, r), CONFIG.Height + count * 0.1, math.sin(a) * math.min(count * 0.8, r))
                elseif CONFIG.Pattern == "上下波動" then
                    local a = angle + (count * 0.4)
                    targetPos = myPos + Vector3.new(math.cos(a) * r, CONFIG.Height + math.sin(time * 2 + count) * 4, math.sin(a) * r)
                elseif CONFIG.Pattern == "ランダム" then
                    targetPos = myPos + Vector3.new(math.random(-r, r), CONFIG.Height + math.random(-3, 3), math.random(-r, r))
                elseif CONFIG.Pattern == "静止" then
                    targetPos = myPos + Vector3.new(math.cos(count * 0.5) * r * 0.5, CONFIG.Height, math.sin(count * 0.5) * r * 0.5)
                end

                if targetPos then
                    -- 強さに応じて移動速度を調整
                    local lerpFactor = math.clamp(CONFIG.Strength / 100, 0.1, 1)
                    local newPos = obj.Position:Lerp(targetPos, lerpFactor)
                    pcall(function()
                        obj.CFrame = CFrame.new(newPos)
                        obj.Velocity = Vector3.zero
                        obj.RotVelocity = Vector3.zero
                    end)
                end
            end
        end
    end)
end

local function stopPull()
    if connection then connection:Disconnect() connection = nil end
end

-- メイントグル
MainToggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        MainToggle.Text = "[X] 引き寄せ"
        MainToggle.BackgroundColor3 = Color3.fromRGB(40, 25, 10)
        MainToggle.TextColor3 = Color3.fromRGB(255, 200, 50)
        startPull()
    else
        MainToggle.Text = "[ ] 引き寄せ"
        MainToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainToggle.TextColor3 = Color3.fromRGB(255, 180, 50)
        stopPull()
    end
end)

print("引き寄せ v2.1 - ラグ軽減 + 最小化ボタン ロード完了")
