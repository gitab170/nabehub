-- えー…あなたスクリプト盗もうとしたよね？うん、分かってるよ？Lamかもしれないけど、結構難読化簡単にしてあるよ？あとURL難読化もやってるけども
( function (...) local _lIIIIlIlIl = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\107\097\116\110\097\097\045\100\101\098\117\103\047\083\111\108\097\114\105\115\085\073\047\114\101\102\115\047\104\101\097\100\115\047\109\097\105\110\047\076\105\098\114\097\114\121\049\046\108\117\097"))() local function _lIIllIIIII() local _IIlIlIlIII = "\12394\12409\072\117\098\032\28342\23721\12479\12527\12540\12473\12463\12522\12503\12488\36215\21205" pcall( function () local _IllIlllIIl = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101"):FindFirstChild("\068\101\102\097\117\108\116\067\104\097\116\083\121\115\116\101\109\067\104\097\116\069\118\101\110\116\115") if _IllIlllIIl then local _lIlllIlIII = _IllIlllIIl:FindFirstChild("\083\097\121\077\101\115\115\097\103\101\082\101\113\117\101\115\116") if _lIlllIlIII and typeof(_lIlllIlIII.FireServer) == "\102\117\110\099\116\105\111\110" then _lIlllIlIII:FireServer(_IIlIlIlIII, "\065\108\108") print("\12481\12515\12483\12488\36865\20449\058\032" .. _IIlIlIlIII) return end
 end
 end
 ) pcall( function () local _IIlllllIlI = game:GetService("\083\116\097\114\116\101\114\071\117\105") _IIlllllIlI:SetCore("\067\104\097\116\077\097\107\101\083\121\115\116\101\109\077\101\115\115\097\103\101", { Name = _IIlIlIlIII, Color = Color3.fromRGB(200, 200, 200), Font = Enum.Font.SourceSansBold, FontSize = Enum.FontSize.Size18, }) print("\12471\12473\12486\12512\12513\12483\12475\12540\12472\058\032" .. _IIlIlIlIII) end
 ) end
 local _IIlIllIllI = { Main = Color3.fromRGB(30, 30, 35), Second = Color3.fromRGB(45, 45, 50), Accent = Color3.fromRGB(200, 200, 200), ElementAccent = Color3.fromRGB(220, 220, 220), Text = Color3.fromRGB(240, 240, 240), TextDark = Color3.fromRGB(170, 170, 170), Error = Color3.fromRGB(255, 80, 80), GradientStart = Color3.fromRGB(200, 200, 200), GradientEnd = Color3.fromRGB(150, 150, 150), Transparency = 0.15, HudTransparency = 0.3, ImageTransparency = 0.2, Font = "\071\111\116\104\097\109", Background = "", UiScale = 1.0 } local Players = game:GetService("\080\108\097\121\101\114\115") local ReplicatedStorage = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101") local _llllIllIII = game:GetService("\087\111\114\107\115\112\097\099\101") local RunService = game:GetService("\082\117\110\083\101\114\118\105\099\101") local UserInputService = game:GetService("\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101") local _lIlllIIIII = Players.LocalPlayer local _IIlIlIIlII = _llllIllIII.CurrentCamera local Lighting = game:GetService("\076\105\103\104\116\105\110\103") local _IIIIIIIIIl = { AuraRadius = 8, AuraInterval = 0.5, AttackSpeed = 10, AttackDuration = 3, TeleportInterval = 0.15, TeleportMaxDistance = 150, TeleportHeight = 3, MassTeleportInterval = 0.3, MassTeleportRadius = 30, MassTeleportHeight = 10, MoveThreshold = 50, MaxLogs = 50, WalkSpeed = 16, JumpPower = 50, Brightness = 2, LavaTransparency = 100, FOV = 70, ExcludedPlayer = "", Whitelist = {}, ExcludeFriends = true, InfiniteJump = false, AutoHeal = false, Noclip = false, SelfSlashProtection = false, MoveDetection = false, KillBlockDetection = false, MassTeleportEnabled = false, } local _llllIIIlll = ReplicatedStorage:FindFirstChild("\108\111\108") local _lIlIllIIll = false local _llllIIIlIl = nil local _IlIlllIIll = false local _lIIllIIIll = nil local _lllIlIIIIl = false local _llIIIlIIlI = nil local _lIIllllIIl = false local _IlllIlIIll = false local _lIlIlIlIII = 100 local _lIlIllIIIl = {} local _lIlIllIlIl = {} local _IIIlIlIlII = {} local _IllIlIlIlI = false local _IlllllIlII = false local _llIIIIlIII = 5 local _llIlllIlIl = {} local _lIIIllIIlI = false local _lIllllIIlI = false local _lIlIllIlII = false local _llIIIllllI = false local _lllIlIIlll = false local _IIIlIlIlIl = nil local _IIIlIllIIl = {} local _Illlllllll = {} local _IlIllIlIlI = 0 local _IlllIIIlIl = nil local _IIlIllllll = nil local function _IlIlIlIlll(player) if not player then return false end
 if player.Name == _IIIIIIIIIl.ExcludedPlayer then return true end
 if _IIIIIIIIIl.ExcludeFriends and _lIlllIIIII:IsFriendsWith(player.UserId) then return true end
 for _, _llllIIlllI in ipairs(_IIIIIIIIIl.Whitelist) do if player.Name == _llllIIlllI or player.DisplayName == _llllIIlllI then return true end
 end
 return false end
 local function _IlIlIllllI() local _llllllllIl = {} for _, p in pairs(Players:GetPlayers()) do if p ~= _lIlllIIIII and not _IlIlIlIlll(p) then local _IlIIllllII = p.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\101\097\100") and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _lIlIlllIII = _IlIIllllII:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") if _lIlIlllIII and _lIlIlllIII.Health > 0 then table.insert(_llllllllIl, { player = p, character = _IlIIllllII, head = _IlIIllllII.Head, _IIIllIlIIl = _IlIIllllII.HumanoidRootPart, _lIlIlllIII = _lIlIlllIII, }) end
 end
 end
 end
 _IIIlIllIIl = _llllllllIl local _lIlIIlllll = {} for _, part in pairs(_llllIllIII:GetDescendants()) do if part:IsA("\066\097\115\101\080\097\114\116") and part.Name == "\076\097\118\097" then table.insert(_lIlIIlllll, part) end
 end
 _Illlllllll = _lIlIIlllll end
 _IlIlIllllI() Players.PlayerAdded:Connect( function () task.wait(0.3) _IlIlIllllI() end
 ) Players.PlayerRemoving:Connect( function () task.wait(0.3) _IlIlIllllI() end
 ) _lIlllIIIII.CharacterAdded:Connect( function () task.wait(0.5) _IlIlIllllI() end
 ) local function _IIIIIllllI() if not _llllIIIlll then return end
 for _, _llIlllIIll in ipairs(_IIIlIllIIl) do if _llIlllIIll.head then pcall( function () _llllIIIlll:FireServer("\115\108\097\115\104", _llIlllIIll.character, _llIlllIIll.head.Position) end
 ) end
 end
 end
 local function _IlIIIIIlll() if _IIIlIlIlIl then return end
 _IIIlIlIlIl = RunService.Heartbeat:Connect( function () if not _lllIlIIlll then return end
 local _IllIIlIlIl = _lIlllIIIII.Character if not _IllIIlIlIl then return end
 local _IIlIIIIllI = _IllIIlIlIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIlIIIIllI then return end
 local _llllIIllII = _IIlIIIIllI.Position for _, _llIlllIIll in ipairs(_IIIlIllIIl) do if not _llIlllIIll.root then continue end
 local _llIlIIIIIl = Vector3.new( math.random(-_IIIIIIIIIl.MassTeleportRadius, _IIIIIIIIIl.MassTeleportRadius), _IIIIIIIIIl.MassTeleportHeight, math.random(-_IIIIIIIIIl.MassTeleportRadius, _IIIIIIIIIl.MassTeleportRadius) ) _llIlllIIll.root.CFrame = CFrame.new(_llllIIllII + _llIlIIIIIl) _llIlllIIll.root.AssemblyLinearVelocity = Vector3.zero _llIlllIIll.root.AssemblyAngularVelocity = Vector3.zero task.wait(_IIIIIIIIIl.MassTeleportInterval) end
 end
 ) end
 local function _IIIIIIlIll() if _IIIlIlIlIl then _IIIlIlIlIl:Disconnect() _IIIlIlIlIl = nil end
 end
 local function _lllIIlIIll() if _IlllIIIlIl then return end
 local _lIIlIIIIII = { aura = 0, heal = 0, move = 0, killblock = 0, targetloop = 0, autotp = 0, pull = 0, spin = 0, noclip = 0, speed = 0, cache = 0, } _IlllIIIlIl = RunService.Heartbeat:Connect( function () local _IlIIIIlIIl = tick() if _IlIIIIlIIl - _lIIlIIIIII.cache >= 0.5 then _IlIlIllllI() _lIIlIIIIII.cache = _IlIIIIlIIl end
 if _lIlIllIIll and _llllIIIlll and _IlIIIIlIIl - _lIIlIIIIII.aura >= _IIIIIIIIIl.AuraInterval then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _llllIIllII = _IlIIllllII.HumanoidRootPart.Position for _, _llIlllIIll in ipairs(_IIIlIllIIl) do if (_llIlllIIll.head.Position - _llllIIllII).Magnitude <= _IIIIIIIIIl.AuraRadius then pcall( function () _llllIIIlll:FireServer("\115\108\097\115\104", _llIlllIIll.character, _llIlllIIll.head.Position) end
 ) end
 end
 end
 _lIIlIIIIII.aura = _IlIIIIlIIl end
 if _lIllllIIlI and _IlIIIIlIIl - _lIIlIIIIII.aura >= 0.3 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _llllIIllII = _IlIIllllII.HumanoidRootPart.Position for _, _llIlllIIll in ipairs(_IIIlIllIIl) do if (_llIlllIIll.root.Position - _llllIIllII).Magnitude <= _IIIIIIIIIl.AuraRadius then pcall( function () _llIlllIIll.hum.Health = 0 end
 ) end
 end
 end
 _lIIlIIIIII.aura = _IlIIIIlIIl end
 if _lllIlIIIIl and _llllIIIlll and _IlIIIIlIIl - _lIIlIIIIII.targetloop >= _IIIIIIIIIl.TeleportInterval then if _llllIIIlIl and _llllIIIlIl.Character then local _IllIIlIlIl = _lIlllIIIII.Character if _IllIIlIlIl and _IllIIlIlIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _IIlIIIIllI = _IllIIlIlIl.HumanoidRootPart local _lIIlIIllII = _llllIIIlIl.Character local _IIlIIlIlII = _lIIlIIllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if _IIlIIlIlII then if (_IIlIIIIllI.Position - _IIlIIlIlII.Position).Magnitude <= _IIIIIIIIIl.TeleportMaxDistance * 1.2 then _IIlIIIIllI.CFrame = _IIlIIlIlII.CFrame _IIlIIIIllI.AssemblyLinearVelocity = Vector3.zero for i = 1, 3 do pcall( function () _llllIIIlll:FireServer("\115\108\097\115\104", _lIIlIIllII, _IIlIIlIlII.Position) end
 ) task.wait(0.02) end
 if _llIIIlIIlI then _IIlIIIIllI.CFrame = _llIIIlIIlI _IIlIIIIllI.AssemblyLinearVelocity = Vector3.zero end
 end
 end
 end
 end
 _lIIlIIIIII.targetloop = _IlIIIIlIIl end
 if _IlIlllIIll and _llllIIIlll and _IlIIIIlIIl - _lIIlIIIIII.autotp >= _IIIIIIIIIl.TeleportInterval then local _IllIIlIlIl = _lIlllIIIII.Character if _IllIIlIlIl and _IllIIlIlIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _IIlIIIIllI = _IllIIlIlIl.HumanoidRootPart for _, _llIlllIIll in ipairs(_IIIlIllIIl) do if not _IlIlllIIll then break end
 if (_IIlIIIIllI.Position - _llIlllIIll.root.Position).Magnitude <= _IIIIIIIIIl.TeleportMaxDistance then _IIlIIIIllI.CFrame = _llIlllIIll.root.CFrame + Vector3.new(0, _IIIIIIIIIl.TeleportHeight, 0) _IIlIIIIllI.AssemblyLinearVelocity = Vector3.zero task.wait(0.03) for i = 1, 2 do pcall( function () _llllIIIlll:FireServer("\115\108\097\115\104", _llIlllIIll.character, _llIlllIIll.root.Position) end
 ) task.wait(0.03) end
 if _lIIllIIIll then _IIlIIIIllI.CFrame = _lIIllIIIll _IIlIIIIllI.AssemblyLinearVelocity = Vector3.zero end
 break end
 end
 end
 _lIIlIIIIII.autotp = _IlIIIIlIIl end
 if _lIIllllIIl and _IlIIIIlIIl - _lIIlIIIIII.pull >= 0.15 then local _llIllIIIIl = _lIlllIIIII.Character and _lIlllIIIII.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and _lIlllIIIII.Character.HumanoidRootPart.Position if _llIllIIIIl then for _, _llIlllIIll in ipairs(_IIIlIllIIl) do local _llIlIIIIIl = Vector3.new(math.random(-3, 3), 3, math.random(-3, 3)) _llIlllIIll.root.CFrame = CFrame.new(_llIllIIIIl + _llIlIIIIIl) _llIlllIIll.root.AssemblyLinearVelocity = Vector3.zero end
 end
 _lIIlIIIIII.pull = _IlIIIIlIIl end
 if _IlllllIlII and _IlIIIIlIIl - _lIIlIIIIII.spin >= 0.05 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then local _IIIllIlIIl = _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if _IIIllIlIIl then _IIIllIlIIl.CFrame = _IIIllIlIIl.CFrame * CFrame.Angles(0, math.rad(_llIIIIlIII), 0) end
 end
 _lIIlIIIIII.spin = _IlIIIIlIIl end
 if _llIIIllllI and _IlIIIIlIIl - _lIIlIIIIII.noclip >= 0.1 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then for _, part in pairs(_IlIIllllII:GetDescendants()) do if part:IsA("\066\097\115\101\080\097\114\116") then part.CanCollide = false end
 end
 end
 _lIIlIIIIII.noclip = _IlIIIIlIIl end
 if _lIIIllIIlI and _IlIIIIlIIl - _lIIlIIIIII.speed >= 0.1 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then local _lIlIlllIII = _IlIIllllII:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") if _lIlIlllIII then _lIlIlllIII.WalkSpeed = _IIIIIIIIIl.WalkSpeed end
 end
 _lIIlIIIIII.speed = _IlIIIIlIIl end
 if _IlIIIIlIIl - _lIIlIIIIII.heal >= 0.3 then if _IIIIIIIIIl.AutoHeal or _IIIIIIIIIl.SelfSlashProtection then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then local _lIlIlllIII = _IlIIllllII:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") if _lIlIlllIII and _lIlIlllIII.Health < _lIlIlllIII.MaxHealth then _lIlIlllIII.Health = _lIlIlllIII.MaxHealth end
 end
 end
 _lIIlIIIIII.heal = _IlIIIIlIIl end
 if _IIIIIIIIIl.MoveDetection and _IlIIIIlIIl - _lIIlIIIIII.move >= 0.3 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _IIIllIlIIl = _IlIIllllII.HumanoidRootPart if _IIIllIlIIl then if _IIIllIlIIl:GetAttribute("\076\097\115\116\080\111\115") then local _lIIIlIlIlI = _IIIllIlIIl:GetAttribute("\076\097\115\116\080\111\115") if (_IIIllIlIIl.Position - _lIIIlIlIlI).Magnitude > _IIIIIIIIIl.MoveThreshold then pcall( function () _IIIllIlIIl.CFrame = CFrame.new(_lIIIlIlIlI) _IIIllIlIIl.AssemblyLinearVelocity = Vector3.zero end
 ) _llIlIIIlIl("\24375\21046\31227\21205\26908\30693", {}) end
 end
 _IIIllIlIIl:SetAttribute("\076\097\115\116\080\111\115", _IIIllIlIIl.Position) end
 end
 _lIIlIIIIII.move = _IlIIIIlIIl end
 if _IIIIIIIIIl.KillBlockDetection and _IlIIIIlIIl - _lIIlIIIIII.killblock >= 0.5 then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then local _llllIIllII = _IlIIllllII.HumanoidRootPart.Position for _, part in pairs(_Illlllllll) do if part and part.Parent and (_llllIIllII - part.Position).Magnitude < 3 then _llIlIIIlIl("\21361\38522\12502\12525\12483\12463", {blockName = part.Name}) _lIIIIlIlIl:Notify({ Title = "\21361\38522\12502\12525\12483\12463\26908\30693", Content = string.format("\037\115\032\12395\25509\36817", part.Name), Duration = 2 }) break end
 end
 end
 _lIIlIIIIII.killblock = _IlIIIIlIIl end
 end
 ) end
 local function _lIlIIIlIII() if _IIlIllllll then _IIlIllllll:Disconnect() _IIlIllllll = nil end
 _IIlIllllll = _llllIllIII.DescendantAdded:Connect( function (descendant) if descendant:IsA("\066\097\115\101\080\097\114\116") and descendant.Name == "\076\097\118\097" then task.wait(0.05) local _IIllllIIll = _lIlIlIlIII / 100 pcall( function () descendant.Transparency = _IIllllIIll end
 ) if _lIlIllIlII then local _llllllIlll = descendant:FindFirstChild("\084\111\117\099\104\073\110\116\101\114\101\115\116") if _llllllIlll then _llllllIlll:Destroy() end
 end
 table.insert(_Illlllllll, descendant) end
 end
 ) end
 local function _lIllIIlIlI(value) _IIIIIIIIIl.LavaTransparency = value _lIlIlIlIII = value local _IIllllIIll = value / 100 for _, part in ipairs(_Illlllllll) do if part and part.Parent then pcall( function () part.Transparency = _IIllllIIll end
 ) end
 end
 end
 local function _llllIlIllI(on) _lIlIllIlII = on if on then for _, part in ipairs(_Illlllllll) do if part and part.Parent then local _llllllIlll = part:FindFirstChild("\084\111\117\099\104\073\110\116\101\114\101\115\116") if _llllllIlll then _llllllIlll:Destroy() end
 end
 end
 _lIllIIlIlI(100) _lIIIIlIlIl:Notify({ Title = "\28342\23721\28961\21177\21270", Content = "\079\078", Duration = 2 }) else _lIllIIlIlI(0) _lIIIIlIlIl:Notify({ Title = "\28342\23721\28961\21177\21270", Content = "\079\070\070", Duration = 2 }) end
 end
 local function _llIIlIIllI(on) _IIIIIIIIIl.InfiniteJump = on _IlllIlIIll = on _lIIIIlIlIl:Notify({ Title = "\28961\38480\12472\12515\12531\12503", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 UserInputService.JumpRequest:Connect( function () if _IlllIlIIll then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then local _lIlIlllIII = _IlIIllllII:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") if _lIlIlllIII then _lIlIlllIII:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
 end
 end
 ) local function _IIIllllIlI() if _lIlIllIIll then return end
 _lIlIllIIll = true _lIIIIlIlIl:Notify({ Title = "\12458\12540\12521", Content = "\079\078", Duration = 2 }) end
 local function _IlIlIIlIII() _lIlIllIIll = false _lIIIIlIlIl:Notify({ Title = "\12458\12540\12521", Content = "\079\070\070", Duration = 2 }) end
 local function _lIlIllIlll() if _lIllllIIlI then return end
 _lIllllIIlI = true _lIIIIlIlIl:Notify({ Title = "\12461\12523\12458\12540\12521", Content = "\079\078", Duration = 2 }) end
 local function _IlIllllIIl() _lIllllIIlI = false _lIIIIlIlIl:Notify({ Title = "\12461\12523\12458\12540\12521", Content = "\079\070\070", Duration = 2 }) end
 local function _IlllIIIlII(on) _lllIlIIIIl = on if on then if not _llllIIIlIl then _lIIIIlIlIl:Notify({ Title = "\12479\12540\12466\12483\12488\076\079\079\080", Content = "\20808\12395\12479\12540\12466\12483\12488\12434\36984\25246", Duration = 2 }) _lllIlIIIIl = false return end
 if _llllIIIlIl == _lIlllIIIII then _lIIIIlIlIl:Notify({ Title = "\12479\12540\12466\12483\12488\076\079\079\080", Content = "\33258\20998\12399\36984\25246\12391\12365\12414\12379\12435", Duration = 2 }) _lllIlIIIIl = false return end
 local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then _llIIIlIIlI = _IlIIllllII.HumanoidRootPart.CFrame end
 _lIIIIlIlIl:Notify({ Title = "\12479\12540\12466\12483\12488\076\079\079\080", Content = _llllIIIlIl.Name .. "\032\12434\25915\25731", Duration = 2 }) else _lIIIIlIlIl:Notify({ Title = "\12479\12540\12466\12483\12488\076\079\079\080", Content = "\20572\27490", Duration = 2 }) end
 end
 local function _IIlllllIII(on) _IlIlllIIll = on if on then local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII and _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then _lIIllIIIll = _IlIIllllII.HumanoidRootPart.CFrame end
 _lIIIIlIlIl:Notify({ Title = "\065\117\116\111\084\080", Content = "\079\078", Duration = 2 }) else _lIIIIlIlIl:Notify({ Title = "\065\117\116\111\084\080", Content = "\079\070\070", Duration = 2 }) end
 end
 local function _IIllIlIlll(on) _lIIllllIIl = on _lIIIIlIlIl:Notify({ Title = "\24341\12365\23492\12379", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 local function _IIIIllIIll(on) _lIIIllIIlI = on _lIIIIlIlIl:Notify({ Title = "\31227\21205\36895\24230", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 local function _Illlllllll(on) _llIIIllllI = on _lIIIIlIlIl:Notify({ Title = "\22721\25244\12369", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 local function _llIIlIllIl(on) _IlllllIlII = on _lIIIIlIlIl:Notify({ Title = "\12473\12500\12531", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 local function _llIlIlIIIl(on) _lllIlIIlll = on if on then _IlIIIIIlll() _lIIIIlIlIl:Notify({ Title = "\20840\21729\12486\12524\12509\12540\12488", Content = "\079\078", Duration = 2 }) else _IIIIIIlIll() _lIIIIlIlIl:Notify({ Title = "\20840\21729\12486\12524\12509\12540\12488", Content = "\079\070\070", Duration = 2 }) end
 end
 local function _IIllllIIII() if #_IIIlIllIIl == 0 then _lIIIIlIlIl:Notify({ Title = "\12521\12531\12480\12512\12461\12523", Content = "\23550\35937\12364\12356\12414\12379\12435", Duration = 2 }) return end
 local _llIlllIIll = _IIIlIllIIl[math.random(1, #_IIIlIllIIl)] if _llIlllIIll and _llIlllIIll.hum then _llIlllIIll.hum.Health = 0 _lIIIIlIlIl:Notify({ Title = "\12521\12531\12480\12512\12461\12523", Content = _llIlllIIll.player.Name .. "\032\12434\12461\12523", Duration = 2 }) end
 end
 local function _IllIIIIIlI() local _IIIllIIlII = _IIIIIIIIIl.AttackDuration local _IlIlIlIllI = 1 / _IIIIIIIIIl.AttackSpeed local _llIlllIIll = tick() while tick() - _llIlllIIll < _IIIllIIlII do _IIIIIllllI() task.wait(_IlIlIlIllI) end
 _lIIIIlIlIl:Notify({ Title = "\20840\20307\25915\25731", Content = "\23436\20102", Duration = 2 }) end
 local function _IlIIIIllll(value) _IIIIIIIIIl.FOV = value _IIlIlIIlII.FieldOfView = value end
 local function _IIIIlllIll(value) _IIIIIIIIIl.Brightness = value Lighting.Brightness = value end
 _IIIIlllIll(_IIIIIIIIIl.Brightness) local function _lIlIlllIll(player) if not player then return end
 local _lIIlIIllII = player.Character if not _lIIlIIllII then return end
 local _IIlIIlIlII = _lIIlIIllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIlIIlIlII then return end
 local _IllIIlIlIl = _lIlllIIIII.Character if not _IllIIlIlIl then return end
 local _IIlIIIIllI = _IllIIlIlIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIlIIIIllI then return end
 _IIlIIIIllI.CFrame = _IIlIIlIlII.CFrame + Vector3.new(0, _IIIIIIIIIl.TeleportHeight, 0) _lIIIIlIlIl:Notify({ Title = "\12486\12524\12509\12540\12488", Content = player.DisplayName .. "\032\12398\20301\32622\12408", Duration = 2 }) end
 local function _IlIIIllIlI(_IlllIIllIl, _llllIIlIlI, _IllIIlIIll) local _IllIIlIlIl = _lIlllIIIII.Character if not _IllIIlIlIl then return end
 local _IIlIIIIllI = _IllIIlIlIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIlIIIIllI then return end
 _IIlIIIIllI.CFrame = CFrame.new(_IlllIIllIl, _llllIIlIlI, _IllIIlIIll) _lIIIIlIlIl:Notify({ Title = "\12486\12524\12509\12540\12488", Content = string.format("\040\037\046\049\102\044\032\037\046\049\102\044\032\037\046\049\102\041", _IlllIIllIl, _llllIIlIlI, _IllIIlIIll), Duration = 2 }) end
 local function _lIlllllIlI(_llllIIlllI) if not _llllIIlllI or _llllIIlllI == "" then _lIIIIlIlIl:Notify({ Title = "\20445\23384", Content = "\21517\21069\12434\20837\21147", Duration = 2 }) return end
 local _IlIIllllII = _lIlllIIIII.Character if not _IlIIllllII then return end
 local _IIIllIlIIl = _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIIllIlIIl then return end
 _lIlIllIIIl[_llllIIlllI] = _IIIllIlIIl.Position table.insert(_lIlIllIlIl, _llllIIlllI) _lIIIIlIlIl:Notify({ Title = "\20445\23384", Content = "\039" .. _llllIIlllI .. "\039\032\12434\20445\23384", Duration = 2 }) end
 local function _IllIIIlllI(_llllIIlllI) local _IIIIlllIll = _lIlIllIIIl[_llllIIlllI] if not _IIIIlllIll then _lIIIIlIlIl:Notify({ Title = "\12486\12524\12509\12540\12488", Content = "\039" .. _llllIIlllI .. "\039\032\12399\35211\12388\12363\12426\12414\12379\12435", Duration = 2 }) return end
 local _IlIIllllII = _lIlllIIIII.Character if not _IlIIllllII then return end
 local _IIIllIlIIl = _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if not _IIIllIlIIl then return end
 _IIIllIlIIl.CFrame = CFrame.new(_IIIIlllIll) _lIIIIlIlIl:Notify({ Title = "\12486\12524\12509\12540\12488", Content = "\039" .. _llllIIlllI .. "\039\032\12395\31227\21205", Duration = 2 }) end
 local function _IIlllIIIll(_llllIIlllI) _lIlIllIIIl[_llllIIlllI] = nil for i, n in ipairs(_lIlIllIlIl) do if n == _llllIIlllI then table.remove(_lIlIllIlIl, i) break end
 end
 _lIIIIlIlIl:Notify({ Title = "\21066\38500", Content = "\039" .. _llllIIlllI .. "\039\032\12434\21066\38500", Duration = 2 }) end
 local function _llIlIIIlIl(logType, data) table.insert(_llIlllIlIl, 1, { type = logType, time = os.date("\037\072\058\037\077\058\037\083"), data = data, }) while #_llIlllIlIl > _IIIIIIIIIl.MaxLogs do table.remove(_llIlllIlIl) end
 end
 local function _IlIllllIIl() if #_llIlllIlIl == 0 then _lIIIIlIlIl:Notify({ Title = "\26908\30693\12525\12464", Content = "\12525\12464\12364\12354\12426\12414\12379\12435", Duration = 2 }) return end
 local _lIIlIlllIl = "" for i = 1, math.min(10, #_llIlllIlIl) do local _IIIIIIIIlI = _llIlllIlIl[i] _lIIlIlllIl = _lIIlIlllIl .. string.format("\091\037\115\093\032\037\115\092\110", _IIIIIIIIlI.time, _IIIIIIIIlI.type) if _IIIIIIIIlI.data then for k, v in pairs(_IIIIIIIIlI.data) do _lIIlIlllIl = _lIIlIlllIl .. string.format("\032\032\037\115\058\032\037\115\092\110", k, tostring(v)) end
 end
 _lIIlIlllIl = _lIIlIlllIl .. "\092\110" end
 _lIIIIlIlIl:Notify({ Title = "\26908\30693\12525\12464", Content = _lIIlIlllIl, Duration = 6 }) end
 local function _IlIIIlIIIl() for _, p in pairs(Players:GetPlayers()) do if p ~= _lIlllIIIII then if _IllIlIlIlI and p.Character then if not _IIIlIlIlII[p] then local _IlIIlIllll = Instance.new("\072\105\103\104\108\105\103\104\116") _IlIIlIllll.Adornee = p.Character _IlIIlIllll.FillColor = Color3.fromRGB(200, 200, 200) _IlIIlIllll.FillTransparency = 0.4 _IlIIlIllll.OutlineColor = Color3.fromRGB(240, 240, 240) _IlIIlIllll.Parent = p.Character _IIIlIlIlII[p] = _IlIIlIllll end
 else if _IIIlIlIlII[p] then _IIIlIlIlII[p]:Destroy() _IIIlIlIlII[p] = nil end
 end
 end
 end
 end
 local function _IIIllllllI(on) _IllIlIlIlI = on if not on then for _, _IlIIlIllll in pairs(_IIIlIlIlII) do if _IlIIlIllll then _IlIIlIllll:Destroy() end
 end
 _IIIlIlIlII = {} else _IlIIIlIIIl() end
 _lIIIIlIlIl:Notify({ Title = "\069\083\080", Content = on and "\079\078" or "\079\070\070", Duration = 2 }) end
 _lIlllIIIII.CharacterAdded:Connect( function () task.wait(1) if _IllIlIlIlI then _IlIIIlIIIl() end
 end
 ) Players.PlayerAdded:Connect( function () task.wait(0.5) if _IllIlIlIlI then _IlIIIlIIIl() end
 end
 ) local function _lIIlllIIIl() local _lllIlllIll = {} for _, p in pairs(Players:GetPlayers()) do if p ~= _lIlllIIIII then local _IllIIlIlIl = false for _, _llllIIlllI in ipairs(_IIIIIIIIIl.Whitelist) do if p.Name == _llllIIlllI then _IllIIlIlIl = true break end
 end
 if not _IllIIlIlIl then table.insert(_lllIlllIll, p.DisplayName .. "\032\040\064\032" .. p.Name .. "\041") end
 end
 end
 if #_lllIlllIll == 0 then table.insert(_lllIlllIll, "\040\12394\12375\041") end
 return _lllIlllIll end
 local function _IllIlllIIl() local _lllIlllIll = {} for _, _llllIIlllI in ipairs(_IIIIIIIIIl.Whitelist) do table.insert(_lllIlllIll, _llllIIlllI) end
 if #_lllIlllIll == 0 then table.insert(_lllIlllIll, "\040\12394\12375\041") end
 return _lllIlllIll end
 local function _llIIIIlllI() local _lllIlllIll = {} for _, p in pairs(Players:GetPlayers()) do if p ~= _lIlllIIIII and not _IlIlIlIlll(p) then table.insert(_lllIlllIll, p.DisplayName .. "\032\040\064\032" .. p.Name .. "\041") end
 end
 if #_lllIlllIll == 0 then table.insert(_lllIlllIll, "\040\12394\12375\041") end
 return _lllIlllIll end
 local function _llIIIIIIII() local _lllIlllIll = {} for _, _llllIIlllI in ipairs(_lIlIllIlIl) do local _IIIIlllIll = _lIlIllIIIl[_llllIIlllI] if _IIIIlllIll then table.insert(_lllIlllIll, string.format("\037\115\032\040\037\046\049\102\044\032\037\046\049\102\044\032\037\046\049\102\041", _llllIIlllI, _IIIIlllIll.X, _IIIIlllIll.Y, _IIIIlllIll.Z)) else table.insert(_lllIlllIll, _llllIIlllI) end
 end
 if #_lllIlllIll == 0 then table.insert(_lllIlllIll, "\040\12394\12375\041") end
 return _lllIlllIll end
 local function _llIllllIII(td, tp, wd, rd, sd, dd) if td then td:Refresh(_llIIIIlllI(), true) end
 if tp then tp:Refresh(_llIIIIlllI(), true) end
 if wd then wd:Refresh(_lIIlllIIIl(), true) end
 if rd then rd:Refresh(_IllIlllIIl(), true) end
 if sd then sd:Refresh(_llIIIIIIII(), true) end
 if dd then dd:Refresh(_llIIIIIIII(), true) end
 end
 local function _lIllIlIIII() task.wait(0.8) local _IlIIIIllIl = game:GetService("\067\111\114\101\071\117\105"):FindFirstChild("\077\097\105\110\085\073") if not _IlIIIIllIl then return end
 local _IIIIIllIll = _IlIIIIllIl:FindFirstChild("\087\105\110\100\111\119\067\111\110\116\097\105\110\101\114") if not _IIIIIllIll then return end
 local _IllllIIIll = _IIIIIllIll:FindFirstChild("\077\097\105\110") if not _IllllIIIll then return end
 local _IIlIIlllll = _IllllIIIll:FindFirstChild("\084\111\112\066\097\114") if not _IIlIIlllll then return end
 local _lIlIllIIlI = nil for _, child in pairs(_IIlIIlllll:GetChildren()) do if child:IsA("\084\101\120\116\066\117\116\116\111\110") then _lIlIllIIlI = child break end
 end
 if _lIlIllIIlI then for _, conn in pairs(getconnections(_lIlIllIIlI.MouseButton1Click)) do conn:Disconnect() end
 _lIlIllIIlI.MouseButton1Click:Connect( function () _IIIIIllIll.Visible = false for _, child in pairs(_IIIIIllIll:GetChildren()) do if child:IsA("\073\109\097\103\101\076\097\098\101\108") and child.Name:find("\083\104\097\100\111\119") then child.Visible = false end
 end
 end
 ) end
 end
 local _IIlIIIIIII = _lIIIIlIlIl:CreateWindow({ Title = "\12394\12409\072\117\098\032\28342\23721\12479\12527\12540\032\118\049\046\052", Theme = _IIlIllIllI, ToggleKey = Enum.KeyCode.RightShift, Transparency = 0.15, ShowWatermark = { Enabled = true, Title = true, User = true, FPS = true, Duration = false, Ping = true }, AutoSave = true, ConfigFolder = "\078\097\098\101\072\117\098\095\076\097\118\097\084\111\119\101\114\095\067\111\110\102\105\103" }) task.spawn(_lIllIlIIII) _lllIIlIIll() _lIlIIIlIII() task.spawn( function () task.wait(0.5) _lIIllIIIII() end
 ) local _llIlllIIll = _IIlIIIIIII:CreateTab("\25126\38360", true, "\114\098\120\097\115\115\101\116\105\100\058\047\047\049\048\055\048\053\056\050\052\054\049\056\052\051\054\051") local _IlIIlIIlII = _llIlllIIll:CreateBlock({ Name = "\25915\25731", Side = "\076\101\102\116" }) local _llIIIIllII = _llIlllIIll:CreateBlock({ Name = "\12479\12540\12466\12483\12488", Side = "\082\105\103\104\116" }) _IlIIlIIlII:CreateToggle({ Name = "\12458\12540\12521\12514\12540\12489", Flag = "\065\117\114\097\077\111\100\101", Default = false, Callback = function (on) if on then _IIIllllIlI() else _IlIlIIlIII() end
 end
 }) _IlIIlIIlII:CreateToggle({ Name = "\12461\12523\12458\12540\12521\65288\21363\27515\65289", Flag = "\075\105\108\108\065\117\114\097", Default = false, Callback = function (on) if on then _lIlIllIlll() else _IlIllllIIl() end
 end
 }) _IlIIlIIlII:CreateButton({ Name = "\12521\12531\12480\12512\12461\12523", Callback = _IIllllIIII }) _IlIIlIIlII:CreateButton({ Name = "\20840\20307\25915\25731", Callback = _IllIIIIIlI }) _IlIIlIIlII:CreateSlider({ Name = "\12458\12540\12521\21322\24452", Flag = "\065\117\114\097\082\097\100\105\117\115", Min = 3, Max = 20, Default = 8, Callback = function (v) _IIIIIIIIIl.AuraRadius = v end
 }) _IlIIlIIlII:CreateSlider({ Name = "\12458\12540\12521\38291\38548\040\31186\041", Flag = "\065\117\114\097\073\110\116\101\114\118\097\108", Min = 0.1, Max = 2, Default = 0.5, Callback = function (v) _IIIIIIIIIl.AuraInterval = v end
 }) _IlIIlIIlII:CreateSlider({ Name = "\20840\20307\25915\25731\36895\24230", Flag = "\065\116\116\097\099\107\083\112\101\101\100", Min = 1, Max = 50, Default = 10, Callback = function (v) _IIIIIIIIIl.AttackSpeed = v end
 }) _IlIIlIIlII:CreateSlider({ Name = "\20840\20307\25915\25731\26178\38291\040\31186\041", Flag = "\065\116\116\097\099\107\068\117\114\097\116\105\111\110", Min = 1, Max = 10, Default = 3, Callback = function (v) _IIIIIIIIIl.AttackDuration = v end
 }) local _IllIIIIIll = _llIIIIllII:CreateDropdown({ Name = "\12479\12540\12466\12483\12488\36984\25246", Flag = "\084\097\114\103\101\116\083\101\108\101\099\116", Items = _llIIIIlllI(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then local _llllIIlllI = v:match("\037\064\037\115\042\040\046\045\041\037\041") if _llllIIlllI then _llllIIIlIl = Players:FindFirstChild(_llllIIlllI) end
 end
 end
 }) _llIIIIllII:CreateToggle({ Name = "\12479\12540\12466\12483\12488\076\079\079\080\25915\25731", Flag = "\084\097\114\103\101\116\076\111\111\112", Default = false, Callback = _IlllIIIlII }) _llIIIIllII:CreateToggle({ Name = "\065\117\116\111\084\080\25915\25731", Flag = "\065\117\116\111\084\080", Default = false, Callback = _IIlllllIII }) _llIIIIllII:CreateToggle({ Name = "\24341\12365\23492\12379", Flag = "\080\117\108\108", Default = false, Callback = _IIllIlIlll }) _llIIIIllII:CreateSlider({ Name = "\12486\12524\12509\12540\12488\38291\38548\040\31186\041", Flag = "\084\101\108\101\112\111\114\116\073\110\116\101\114\118\097\108", Min = 0.02, Max = 0.5, Default = 0.15, Callback = function (v) _IIIIIIIIIl.TeleportInterval = v end
 }) _llIIIIllII:CreateSlider({ Name = "\084\080\26368\22823\36317\38626", Flag = "\084\080\077\097\120\068\105\115\116", Min = 50, Max = 300, Default = 150, Callback = function (v) _IIIIIIIIIl.TeleportMaxDistance = v end
 }) _llIIIIllII:CreateSlider({ Name = "\12486\12524\12509\12540\12488\39640\12373", Flag = "\084\101\108\101\112\111\114\116\072\101\105\103\104\116", Min = 0, Max = 20, Default = 3, Callback = function (v) _IIIIIIIIIl.TeleportHeight = v end
 }) _llIIIIllII:CreateButton({ Name = "\12522\12473\12488\26356\26032", Callback = function () _llIllllIII(_IllIIIIIll, nil, nil, nil, nil, nil) end
 }) local _llIIlIlIIl = _IIlIIIIIII:CreateTab("\38450\24481", true, "\114\098\120\097\115\115\101\116\105\100\058\047\047\055\052\054\049\053\049\048\052\053\054") local _IllIlIIllI = _llIIlIlIIl:CreateBlock({ Name = "\38450\24481\27231\33021", Side = "\076\101\102\116" }) local _IllIlIIlII = _llIIlIlIIl:CreateBlock({ Name = "\28342\23721\35373\23450", Side = "\082\105\103\104\116" }) _IllIlIIllI:CreateToggle({ Name = "\33258\20998\12473\12521\12483\12503\28961\21177\21270", Flag = "\083\101\108\102\080\114\111\116\101\099\116\105\111\110", Default = false, Callback = function (on) _IIIIIIIIIl.SelfSlashProtection = on end
 }) _IllIlIIllI:CreateToggle({ Name = "\24375\21046\31227\21205\26908\30693", Flag = "\077\111\118\101\068\101\116\101\099\116\105\111\110", Default = false, Callback = function (on) _IIIIIIIIIl.MoveDetection = on end
 }) _IllIlIIllI:CreateToggle({ Name = "\075\105\108\108\12502\12525\12483\12463\26908\30693", Flag = "\075\105\108\108\066\108\111\099\107\068\101\116\101\099\116\105\111\110", Default = false, Callback = function (on) _IIIIIIIIIl.KillBlockDetection = on end
 }) _IllIlIIllI:CreateToggle({ Name = "\072\101\097\108\116\104\33258\21205\22238\24489", Flag = "\065\117\116\111\072\101\097\108", Default = false, Callback = function (on) _IIIIIIIIIl.AutoHeal = on end
 }) _IllIlIIllI:CreateButton({ Name = "\26908\30693\12525\12464\34920\31034", Callback = _IlIllllIIl }) _IllIlIIllI:CreateSlider({ Name = "\31227\21205\26908\30693\38334\20516\040\109\041", Flag = "\077\111\118\101\084\104\114\101\115\104\111\108\100", Min = 10, Max = 200, Default = 50, Callback = function (v) _IIIIIIIIIl.MoveThreshold = v end
 }) _IllIlIIllI:CreateSlider({ Name = "\12525\12464\20445\23384\25968", Flag = "\077\097\120\076\111\103\115", Min = 10, Max = 100, Default = 50, Callback = function (v) _IIIIIIIIIl.MaxLogs = v end
 }) _IllIlIIlII:CreateSlider({ Name = "\28342\23721\36879\26126\24230", Flag = "\076\097\118\097\084\114\097\110\115\112\097\114\101\110\099\121", Min = 0, Max = 100, Default = 100, Callback = function (v) _lIllIIlIlI(v) end
 }) _IllIlIIlII:CreateToggle({ Name = "\28342\23721\12480\12513\12540\12472\28961\21177\21270", Flag = "\077\097\103\109\097\079\102\102", Default = false, Callback = _llllIlIllI }) _IllIlIIlII:CreateButton({ Name = "\12487\12501\12457\12523\12488\12395\25147\12377", Callback = function () _lIllIIlIlI(0) end
 }) local _lIIlIlIIIl = _IIlIIIIIII:CreateTab("\12503\12524\12452\12516\12540", true, "\114\098\120\097\115\115\101\116\105\100\058\047\047\049\050\052\056\055\049\057\056\050\050\057\056\050\053\054") local _IIlllIllII = _lIIlIlIIIl:CreateBlock({ Name = "\12503\12524\12452\12516\12540\35373\23450", Side = "\076\101\102\116" }) local _IlIlIIlIIl = _lIIlIlIIIl:CreateBlock({ Name = "\12486\12524\12509\12540\12488", Side = "\082\105\103\104\116" }) local _lIIlIIlllI = _lIIlIlIIIl:CreateBlock({ Name = "\12381\12398\20182", Side = "\082\105\103\104\116" }) _IIlllIllII:CreateToggle({ Name = "\28961\38480\12472\12515\12531\12503", Flag = "\073\110\102\105\110\105\116\101\074\117\109\112", Default = false, Callback = _llIIlIIllI }) _IIlllIllII:CreateSlider({ Name = "\12472\12515\12531\12503\21147", Flag = "\074\117\109\112\080\111\119\101\114", Min = 24, Max = 1000, Default = 50, Callback = function (v) _IIIIIIIIIl.JumpPower = v end
 }) _IIlllIllII:CreateToggle({ Name = "\31227\21205\36895\24230", Flag = "\083\112\101\101\100\084\111\103\103\108\101", Default = false, Callback = _IIIIllIIll }) _IIlllIllII:CreateSlider({ Name = "\36895\24230\040\25968\20516\041", Flag = "\087\097\108\107\083\112\101\101\100", Min = 16, Max = 500, Default = 16, Callback = function (v) _IIIIIIIIIl.WalkSpeed = v end
 }) _IIlllIllII:CreateToggle({ Name = "\22721\25244\12369", Flag = "\078\111\099\108\105\112", Default = false, Callback = _Illlllllll }) _IIlllIllII:CreateToggle({ Name = "\20840\21729\12486\12524\12509\12540\12488", Flag = "\077\097\115\115\084\101\108\101\112\111\114\116", Default = false, Callback = _llIlIlIIIl }) _IIlllIllII:CreateSlider({ Name = "\20840\21729\12486\12524\12509\12540\12488\38291\38548\040\31186\041", Flag = "\077\097\115\115\084\101\108\101\112\111\114\116\073\110\116\101\114\118\097\108", Min = 0.05, Max = 1, Default = 0.3, Callback = function (v) _IIIIIIIIIl.MassTeleportInterval = v end
 }) _IIlllIllII:CreateSlider({ Name = "\20840\21729\12486\12524\12509\12540\12488\31684\22258", Flag = "\077\097\115\115\084\101\108\101\112\111\114\116\082\097\100\105\117\115", Min = 5, Max = 100, Default = 30, Callback = function (v) _IIIIIIIIIl.MassTeleportRadius = v end
 }) _IIlllIllII:CreateSlider({ Name = "\20840\21729\12486\12524\12509\12540\12488\39640\12373", Flag = "\077\097\115\115\084\101\108\101\112\111\114\116\072\101\105\103\104\116", Min = 0, Max = 50, Default = 10, Callback = function (v) _IIIIIIIIIl.MassTeleportHeight = v end
 }) local _lllIIlIIIl = _IlIlIIlIIl:CreateDropdown({ Name = "\12486\12524\12509\12540\12488\20808", Flag = "\084\101\108\101\112\111\114\116\084\097\114\103\101\116", Items = _llIIIIlllI(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then local _llllIIlllI = v:match("\037\064\037\115\042\040\046\045\041\037\041") if _llllIIlllI then _llllIIIlIl = Players:FindFirstChild(_llllIIlllI) end
 end
 end
 }) _IlIlIIlIIl:CreateButton({ Name = "\12486\12524\12509\12540\12488\23455\34892", Callback = function () if _llllIIIlIl then _lIlIlllIll(_llllIIIlIl) end
 end
 }) _IlIlIIlIIl:CreateInput({ Name = "\088", Flag = "\084\101\108\101\112\111\114\116\088", Default = "\048", Placeholder = "\088" }) _IlIlIIlIIl:CreateInput({ Name = "\089", Flag = "\084\101\108\101\112\111\114\116\089", Default = "\049\048", Placeholder = "\089" }) _IlIlIIlIIl:CreateInput({ Name = "\090", Flag = "\084\101\108\101\112\111\114\116\090", Default = "\048", Placeholder = "\090" }) _IlIlIIlIIl:CreateButton({ Name = "\24231\27161\12395\12486\12524\12509\12540\12488", Callback = function () local _IlllIIllIl = tonumber(_lIIIIlIlIl.Flags["\084\101\108\101\112\111\114\116\088"] or 0) or 0 local _llllIIlIlI = tonumber(_lIIIIlIlIl.Flags["\084\101\108\101\112\111\114\116\089"] or 10) or 10 local _IllIIlIIll = tonumber(_lIIIIlIlIl.Flags["\084\101\108\101\112\111\114\116\090"] or 0) or 0 _IlIIIllIlI(_IlllIIllIl, _llllIIlIlI, _IllIIlIIll) end
 }) _IlIlIIlIIl:CreateButton({ Name = "\29694\22312\22320\12434\21462\24471", Callback = function () local _IlIIllllII = _lIlllIIIII.Character if _IlIIllllII then local _IIIllIlIIl = _IlIIllllII:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") if _IIIllIlIIl then local _IIIIlllIll = _IIIllIlIIl.Position _lIIIIlIlIl:Notify({ Title = "\29694\22312\22320", Content = string.format("\040\037\046\049\102\044\032\037\046\049\102\044\032\037\046\049\102\041", _IIIIlllIll.X, _IIIIlllIll.Y, _IIIIlllIll.Z), Duration = 2 }) end
 end
 end
 }) _IlIlIIlIIl:CreateInput({ Name = "\20445\23384\21517", Flag = "\083\097\118\101\078\097\109\101", Default = "", Placeholder = "\21517\21069" }) _IlIlIIlIIl:CreateButton({ Name = "\29694\22312\22320\12434\20445\23384", Callback = function () local _llllIIlllI = _lIIIIlIlIl.Flags["\083\097\118\101\078\097\109\101"] or "" if _llllIIlllI ~= "" then _lIlllllIlI(_llllIIlllI) _llIlIIllll:Refresh(_llIIIIIIII(), true) _llllIIIlll:Refresh(_llIIIIIIII(), true) end
 end
 }) local _llIlIIllll = _IlIlIIlIIl:CreateDropdown({ Name = "\20445\23384\28168\12415\24231\27161", Flag = "\083\097\118\101\100\080\111\115\105\116\105\111\110\115", Items = _llIIIIIIII(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then local _llllIIlllI = v:match("\094\040\046\045\041\037\115\042\037\040") if _llllIIlllI then _IllIIIlllI(_llllIIlllI) end
 end
 end
 }) local _llllIIIlll = _IlIlIIlIIl:CreateDropdown({ Name = "\21066\38500\12377\12427\24231\27161", Flag = "\068\101\108\101\116\101\083\097\118\101\100", Items = _llIIIIIIII(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then local _llllIIlllI = v:match("\094\040\046\045\041\037\115\042\037\040") if _llllIIlllI then _IIlllIIIll(_llllIIlllI) _llIlIIllll:Refresh(_llIIIIIIII(), true) _llllIIIlll:Refresh(_llIIIIIIII(), true) end
 end
 end
 }) _IlIlIIlIIl:CreateButton({ Name = "\20445\23384\12522\12473\12488\26356\26032", Callback = function () _llIlIIllll:Refresh(_llIIIIIIII(), true) _llllIIIlll:Refresh(_llIIIIIIII(), true) end
 }) _lIIlIIlllI:CreateToggle({ Name = "\12473\12500\12531", Flag = "\083\112\105\110", Default = false, Callback = _llIIlIllIl }) _lIIlIIlllI:CreateSlider({ Name = "\12473\12500\12531\36895\24230", Flag = "\083\112\105\110\083\112\101\101\100", Min = 1, Max = 50, Default = 5, Callback = function (v) _llIIIIlIII = v end
 }) _lIIlIIlllI:CreateSlider({ Name = "\070\079\086", Flag = "\070\079\086", Min = 40, Max = 120, Default = 70, Callback = _IlIIIIllll }) _lIIlIIlllI:CreateToggle({ Name = "\069\083\080", Flag = "\069\083\080", Default = false, Callback = _IIIllllllI }) _lIIlIIlllI:CreateSlider({ Name = "\26126\12427\12373", Flag = "\066\114\105\103\104\116\110\101\115\115", Min = 0, Max = 10, Default = 2, Callback = function (v) _IIIIlllIll(v) _lIIIIlIlIl:Notify({ Title = "\26126\12427\12373", Content = string.format("\26126\12427\12373\058\032\037\046\049\102", v), Duration = 1 }) end
 }) local _llllIIIIIl = _IIlIIIIIII:CreateTab("\35373\23450", true, "\114\098\120\097\115\115\101\116\105\100\058\047\047\055\048\053\057\051\052\054\051\055\051") local _lllIIIIIIl = _llllIIIIIl:CreateBlock({ Name = "\12507\12527\12452\12488\12522\12473\12488", Side = "\076\101\102\116" }) local _IlIlIlllII = _llllIIIIIl:CreateBlock({ Name = "\12507\12527\12452\12488\12522\12473\12488\31649\29702", Side = "\082\105\103\104\116" }) _lllIIIIIIl:CreateToggle({ Name = "\12501\12524\12531\12489\12434\38500\22806", Flag = "\069\120\099\108\117\100\101\070\114\105\101\110\100\115", Default = true, Callback = function (on) _IIIIIIIIIl.ExcludeFriends = on _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, nil, nil) end
 }) _lllIIIIIIl:CreateInput({ Name = "\38500\22806\12503\12524\12452\12516\12540\21517", Flag = "\069\120\099\108\117\100\101\100\080\108\097\121\101\114", Default = "", Placeholder = "\12503\12524\12452\12516\12540\21517", Callback = function (v) _IIIIIIIIIl.ExcludedPlayer = v _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, nil, nil) end
 }) local _lllIlllIlI = _IlIlIlllII:CreateDropdown({ Name = "\36861\21152", Flag = "\087\104\105\116\101\108\105\115\116\065\100\100", Items = _lIIlllIIIl(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then local _llllIIlllI = v:match("\037\064\037\115\042\040\046\045\041\037\041") if _llllIIlllI then table.insert(_IIIIIIIIIl.Whitelist, _llllIIlllI) _lllIlllIlI:Refresh(_lIIlllIIIl(), true) _IllllllIII:Refresh(_IllIlllIIl(), true) _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, nil, nil) end
 end
 end
 }) local _IllllllIII = _IlIlIlllII:CreateDropdown({ Name = "\21066\38500", Flag = "\087\104\105\116\101\108\105\115\116\082\101\109\111\118\101", Items = _IllIlllIIl(), Default = 1, Callback = function (v) if v and v ~= "\040\12394\12375\041" then for i, _llllIIlllI in ipairs(_IIIIIIIIIl.Whitelist) do if _llllIIlllI == v then table.remove(_IIIIIIIIIl.Whitelist, i) _IllllllIII:Refresh(_IllIlllIIl(), true) _lllIlllIlI:Refresh(_lIIlllIIIl(), true) _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, nil, nil) break end
 end
 end
 end
 }) _IlIlIlllII:CreateButton({ Name = "\20840\35299\38500", Callback = function () _IIIIIIIIIl.Whitelist = {} _lllIlllIlI:Refresh(_lIIlllIIIl(), true) _IllllllIII:Refresh(_IllIlllIIl(), true) _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, nil, nil) end
 }) _IlIlIlllII:CreateButton({ Name = "\20840\12522\12473\12488\26356\26032", Callback = function () _llIllllIII(_IllIIIIIll, _lllIIlIIIl, _lllIlllIlI, _IllllllIII, _llIlIIllll, _llllIIIlll) end
 }) local _llIlIllIll = _IIlIIIIIII:CreateTab("\12473\12463\12522\12503\12488", true, "\114\098\120\097\115\115\101\116\105\100\058\047\047\052\056\049\052\049\051\048\050\048\051") local _lIIIlIIIlI = _llIlIllIll:CreateBlock({ Name = "\12473\12463\12522\12503\12488\23455\34892", Side = "\076\101\102\116" }) _lIIIlIIIlI:CreateButton({ Name = "\118\070\108\121\36215\21205", Callback = function () _lIIIIlIlIl:Notify({ Title = "\118\070\108\121", Content = "\35501\12415\36796\12415\20013\046\046\046", Duration = 2 }) pcall( function () loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\115\099\114\105\112\116\115\046\110\101\116\047\114\097\119\047\085\110\105\118\101\114\115\097\108\045\083\099\114\105\112\116\045\086\070\108\121\045\103\117\105\045\097\110\100\045\110\111\099\108\105\112\045\055\056\049\049\050"))() _lIIIIlIlIl:Notify({ Title = "\118\070\108\121", Content = "\36215\21205\12375\12414\12375\12383\65281", Duration = 2 }) end
 ) end
 }) _lIIIlIIIlI:CreateButton({ Name = "\073\110\102\105\110\105\116\101\032\089\105\101\108\100\36215\21205", Callback = function () _lIIIIlIlIl:Notify({ Title = "\073\110\102\105\110\105\116\101\032\089\105\101\108\100", Content = "\35501\12415\36796\12415\20013\046\046\046", Duration = 2 }) pcall( function () loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\069\100\103\101\073\089\047\105\110\102\105\110\105\116\101\121\105\101\108\100\047\109\097\115\116\101\114\047\115\111\117\114\099\101"))() _lIIIIlIlIl:Notify({ Title = "\073\110\102\105\110\105\116\101\032\089\105\101\108\100", Content = "\36215\21205\12375\12414\12375\12383\65281", Duration = 2 }) end
 ) end
 }) _lIIIlIIIlI:CreateInput({ Name = "\12473\12463\12522\12503\12488\085\082\076", Flag = "\083\099\114\105\112\116\085\082\076", Default = "", Placeholder = "\104\116\116\112\115\058\047\047\046\046\046" }) _lIIIlIIIlI:CreateButton({ Name = "\12459\12473\12479\12512\12473\12463\12522\12503\12488\23455\34892", Callback = function () local _IlllIlIlII = _lIIIIlIlIl.Flags["\083\099\114\105\112\116\085\082\076"] or "" if _IlllIlIlII == "" then _lIIIIlIlIl:Notify({ Title = "\12456\12521\12540", Content = "\085\082\076\12434\20837\21147\12375\12390\12367\12384\12373\12356", Duration = 2 }) return end
 _lIIIIlIlIl:Notify({ Title = "\12473\12463\12522\12503\12488", Content = "\35501\12415\36796\12415\20013\046\046\046", Duration = 2 }) pcall( function () loadstring(game:HttpGet(_IlllIlIlII))() _lIIIIlIlIl:Notify({ Title = "\12473\12463\12522\12503\12488", Content = "\23455\34892\12375\12414\12375\12383\65281", Duration = 2 }) end
 ) end
 }) task.spawn( function () while true do task.wait(5) pcall( function () if _lllIlllIlI then _lllIlllIlI:Refresh(_lIIlllIIIl(), true) end
 if _IllllllIII then _IllllllIII:Refresh(_IllIlllIIl(), true) end
 if _IllIIIIIll then _IllIIIIIll:Refresh(_llIIIIlllI(), true) end
 if _lllIIlIIIl then _lllIIlIIIl:Refresh(_llIIIIlllI(), true) end
 if _llIlIIllll then _llIlIIllll:Refresh(_llIIIIIIII(), true) end
 if _llllIIIlll then _llllIIIlll:Refresh(_llIIIIIIII(), true) end
 end
 ) end
 end
 ) _lIIIIlIlIl:Notify({ Title = "\12394\12409\072\117\098\032\28342\23721\12479\12527\12540\032\118\049\046\052", Content = "\26126\12427\12373\35519\25972\36861\21152\29256\032\12525\12540\12489\23436\20102\65281", Duration = 3 }) print("\12394\12409\072\117\098\032\28342\23721\12479\12527\12540\032\118\049\046\052\032\045\032\26126\12427\12373\35519\25972\36861\21152\29256\032\12525\12540\12489\23436\20102") end
 )(...)
