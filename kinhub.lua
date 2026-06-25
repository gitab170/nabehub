local function clr() local c=game:GetService("CoreGui"):FindFirstChild("tpGUI") if c then c:Destroy() end end clr()
local sg=Instance.new("ScreenGui",game:GetService("CoreGui")) sg.Name="tpGUI"
local fr=Instance.new("Frame",sg) fr.Size=UDim2.new(0,210,0,300) fr.Position=UDim2.new(0.5,-105,0.5,-140) fr.BackgroundColor3=Color3.fromRGB(20,20,20) fr.Visible=false fr.Active=true fr.Draggable=true

-- 閉じるボタン(非表示)
local cl = Instance.new("TextButton",fr) cl.Size=UDim2.new(0,25,0,25) cl.Position=UDim2.new(1,-25,0,0) cl.Text="×" cl.BackgroundColor3=Color3.new(0.3,0,0) cl.TextColor3=Color3.new(1,1,1)
cl.MouseButton1Click:Connect(function() fr.Visible = false end)

local tkn=Instance.new("TextButton",sg) tkn.Size=UDim2.new(0,45,0,45) tkn.Position=UDim2.new(0,5,0.15,0) tkn.BackgroundColor3=Color3.fromRGB(200,0,0) tkn.Text="kin" tkn.TextColor3=Color3.new(1,1,1) 
tkn.MouseButton1Click:Connect(function() fr.Visible=not fr.Visible end)

local sc=Instance.new("ScrollingFrame",fr) sc.Size=UDim2.new(1,0,1,-25) sc.Position=UDim2.new(0,0,0,25) sc.CanvasSize=UDim2.new(0,0,10,0) sc.BackgroundColor3=Color3.fromRGB(30,30,30) Instance.new("UIListLayout",sc)

-- 動作管理用フラグ
_G.Run = true
_G.WData = {}

local function btn(nm,cb)
    local b=Instance.new("TextButton",sc) b.Size=UDim2.new(1,0,0,35) b.Text=nm b.BackgroundColor3=Color3.fromRGB(70,70,70) b.TextColor3=Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() if _G.Run then pcall(cb) end end)
end

local function tgl(nm,on,off)
    local s=false local b=Instance.new("TextButton",sc) b.Size=UDim2.new(1,0,0,35) b.Text=nm.." [OFF]" b.BackgroundColor3=Color3.fromRGB(50,50,50) b.TextColor3=Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() if not _G.Run then return end s=not s b.Text=nm..(s and " [ON]" or " [OFF]") b.BackgroundColor3=s and Color3.fromRGB(0,150,80) or Color3.fromRGB(50,50,50) if s then pcall(on) else pcall(off) end end)
end

-- --- 機能 ---
_G.PIdx = 1
btn("👥 次の人の背後へワープ", function()
    local t = {} for _, p in pairs(game.Players:GetPlayers()) do if p ~= game.Players.LocalPlayer then table.insert(t, p) end end
    if #t > 0 then
        if _G.PIdx > #t then _G.PIdx = 1 end
        local target = t[_G.PIdx]
        if target.Character then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
        _G.PIdx = _G.PIdx + 1
    end
end)

btn("🏃 3歩前に進む", function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 0, -10) end)

tgl("壁を半透明に", function()
    _G.WData = {} for _,v in pairs(game.Workspace:GetDescendants()) do if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then _G.WData[v] = v.Transparency v.Transparency = 0.5 end end
end, function()
    for p, o in pairs(_G.WData) do if p and p.Parent then p.Transparency = o end end
end)

_G.Svd = nil
btn("📍 現在地を保存(赤い柱)", function()
    _G.Svd = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    if _G.M then _G.M:Destroy() end
    local p = Instance.new("Part", game.Workspace) p.Size = Vector3.new(1, 200, 1) p.CFrame = _G.Svd p.Anchored = true p.CanCollide = false p.Transparency = 0.5 p.Color = Color3.new(1,0,0) p.Material = "Neon" _G.M = p
end)

btn("🌀 保存した場所へ戻る", function() if _G.Svd then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.Svd end end)

tgl("空を飛ぶ(Fly)", function()
    _G.F=true local r=game.Players.LocalPlayer.Character.HumanoidRootPart local v=Instance.new("BodyVelocity",r) v.Name="kF" v.MaxForce=Vector3.new(1e6,1e6,1e6)
    task.spawn(function() while _G.F and _G.Run do v.Velocity=game.Workspace.CurrentCamera.CFrame.LookVector*100 task.wait() end v:Destroy() end)
end, function() _G.F=false end)

tgl("クリック移動(TP)", function() _G.CTP = game.Players.LocalPlayer:GetMouse().Button1Down:Connect(function() if _G.Run then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer:GetMouse().Hit.p + Vector3.new(0,3,0)) end end) end, function() if _G.CTP then _G.CTP:Disconnect() end end)

tgl("壁抜け", function() _G.N=game:GetService("RunService").Stepped:Connect(function() if _G.Run then for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end) end, function() if _G.N then _G.N:Disconnect() end end)

tgl("プレイヤー透視(ESP)", function() for _,v in pairs(game.Players:GetPlayers()) do if v.Character then local h=Instance.new("Highlight",v.Character) h.Name="kE" end end end, function() for _,v in pairs(game.Workspace:GetDescendants()) do if v.Name=="kE" then v:Destroy() end end end)

tgl("空中ジャンプ", function() _G.I=true _G.JR = game:GetService("UserInputService").JumpRequest:Connect(function() if _G.I and _G.Run then game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end) end, function() _G.I=false if _G.JR then _G.JR:Disconnect() end end)

tgl("自動クリック", function() _G.A=true task.spawn(function() while _G.A and _G.Run do task.wait() game:GetService("VirtualUser"):ClickButton1(Vector2.new()) end end) end, function() _G.A=false end)

-- --- 完全停止 & 削除 ---
btn("⚠️ スプリクトを完全に削除・停止", function()
    _G.Run = false _G.F = false _G.A = false _G.I = false
    if _G.CTP then _G.CTP:Disconnect() end
    if _G.N then _G.N:Disconnect() end
    if _G.JR then _G.JR:Disconnect() end
    if _G.M then _G.M:Destroy() end
    for p, o in pairs(_G.WData) do if p and p.Parent then p.Transparency = o end end
    for _,v in pairs(game.Workspace:GetDescendants()) do if v.Name=="kE" then v:Destroy() end end
    sg:Destroy()
end)
