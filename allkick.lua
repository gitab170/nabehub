-- [[ Orion Lib ]]
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

OrionLib:MakeNotification({
    Name = "なべHub",
    Content = "なべHubロード中…",
    Image = "rbxassetid://4483345998",
    Time = 4
})

local Window = OrionLib:MakeWindow({
    Name = "なべHub allkick テスト",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "NabeHubKickConfig"
})

local Tab = Window:MakeTab({
    Name = "Kick All",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local currentBlob = nil
local isActive = false
local isLoopActive = false
local safeTeleportEnabled = false  -- デフォルト：オフ
local playerStatus = {}

local function GetAllPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end
    return players
end

local function GetMyRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetBlobman()
    local toyFolder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
    return toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
end

-- Blobmanに座る
local function SitOnBlobman()
    currentBlob = GetBlobman()
    if not currentBlob then
        OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanが見つかりません。", Time = 3})
        return
    end

    local vehicleSeat = currentBlob:FindFirstChild("VehicleSeat")
    local character = LocalPlayer.Character
    if vehicleSeat and character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            vehicleSeat:Sit(humanoid)
            OrionLib:MakeNotification({Name = "成功", Content = "Blobmanに座りました。", Time = 3})
        end
    end
end

local function ResetTargets()
    for id, _ in pairs(playerStatus) do
        playerStatus[id] = nil
    end
end

local function PerformKick()
    if isActive then return end
    isActive = true
    
    local allPlayers = GetAllPlayers()
    if #allPlayers == 0 then 
        isActive = false
        return 
    end

    currentBlob = GetBlobman()
    if not currentBlob then 
        isActive = false
        return 
    end

    local myRoot = GetMyRoot()
    if not myRoot then 
        isActive = false
        return 
    end

    local tpWait = 0.012

    for _, targetPlayer in ipairs(allPlayers) do
        for attempt = 1, 4 do
            local character = targetPlayer.Character
            local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and targetRoot.Parent then
                myRoot.CFrame = targetRoot.CFrame
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                task.wait(tpWait)

                local distance = (myRoot.Position - targetRoot.Position).Magnitude
                if distance <= 40 then
                    for i = 1, 9 do
                        if not targetRoot.Parent or not currentBlob.Parent then break end
                        pcall(function()
                            currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                                currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld
                            )
                            currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                                currentBlob.RightDetector, targetRoot, currentBlob.RightDetector.RightWeld
                            )
                            task.wait(0.007)
                            currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(currentBlob.LeftDetector.LeftWeld)
                        end)
                    end
                end
                break
            else
                task.wait(0.15)
            end
        end
    end

    -- 安全テレポート（トグルで制御）
    if safeTeleportEnabled and myRoot then
        pcall(function()
            myRoot.CFrame = CFrame.new(0, 500, 10000)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(0.3)
    end

    -- 対象プレイヤー位置調整
    local radius = 15
    for i, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #allPlayers))
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            pcall(function()
                targetRoot.CFrame = CFrame.new(x, 110, z)
                targetRoot.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end
    task.wait(0.15)

    -- 最終グラブ
    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            task.spawn(function()
                pcall(function()
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld
                    )
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        currentBlob.RightDetector, targetRoot, currentBlob.RightDetector.RightWeld
                    )
                end)
            end)
        end
    end

    task.wait(1)
    isActive = false
end

-- ループ機能
local function LoopAllKick()
    while isLoopActive do
        PerformKick()
        if isLoopActive then
            task.wait(15)
        end
    end
end

-- ボタン配置
Tab:AddButton({
    Name = "Sit on Blobman",
    Callback = SitOnBlobman
})

Tab:AddButton({
    Name = "Kick All (単発)",
    Callback = PerformKick
})

Tab:AddToggle({
    Name = "Loop All Kick",
    Default = false,
    Callback = function(state)
        isLoopActive = state
        if state then
            OrionLib:MakeNotification({Name = "Loop", Content = "ループAllKickを開始しました。", Time = 3})
            task.spawn(LoopAllKick)
        else
            OrionLib:MakeNotification({Name = "Loop", Content = "ループAllKickを停止しました。", Time = 3})
        end
    end
})

Tab:AddToggle({
    Name = "Kick後安全テレポート",
    Default = false,   -- デフォルト：オフ
    Callback = function(state)
        safeTeleportEnabled = state
        OrionLib:MakeNotification({
            Name = "設定変更",
            Content = "安全テレポートを " .. (state and "有効" or "無効") .. " にしました。",
            Time = 3
        })
    end
})

OrionLib:Init()
