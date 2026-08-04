-- // NabaUI Library v4.0 - OrionLib改造版
local NabaUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- テーマ
NabaUI.Themes = {
    Dark = {
        Main = Color3.fromRGB(25, 25, 25), Second = Color3.fromRGB(32, 32, 32),
        Stroke = Color3.fromRGB(60, 60, 60), Divider = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(240, 240, 240), TextDark = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(9, 99, 195),
    },
    Blue = {
        Main = Color3.fromRGB(20, 25, 35), Second = Color3.fromRGB(30, 35, 45),
        Stroke = Color3.fromRGB(50, 70, 100), Divider = Color3.fromRGB(50, 70, 100),
        Text = Color3.fromRGB(240, 240, 255), TextDark = Color3.fromRGB(150, 170, 200),
        Accent = Color3.fromRGB(100, 180, 255),
    },
    Red = {
        Main = Color3.fromRGB(30, 20, 20), Second = Color3.fromRGB(40, 25, 25),
        Stroke = Color3.fromRGB(80, 40, 40), Divider = Color3.fromRGB(80, 40, 40),
        Text = Color3.fromRGB(255, 230, 230), TextDark = Color3.fromRGB(200, 150, 150),
        Accent = Color3.fromRGB(255, 60, 60),
    },
    Green = {
        Main = Color3.fromRGB(20, 30, 20), Second = Color3.fromRGB(25, 40, 25),
        Stroke = Color3.fromRGB(40, 80, 40), Divider = Color3.fromRGB(40, 80, 40),
        Text = Color3.fromRGB(230, 255, 230), TextDark = Color3.fromRGB(150, 200, 150),
        Accent = Color3.fromRGB(60, 255, 60),
    },
    Purple = {
        Main = Color3.fromRGB(30, 20, 35), Second = Color3.fromRGB(40, 30, 45),
        Stroke = Color3.fromRGB(80, 50, 100), Divider = Color3.fromRGB(80, 50, 100),
        Text = Color3.fromRGB(240, 230, 255), TextDark = Color3.fromRGB(180, 160, 210),
        Accent = Color3.fromRGB(180, 130, 255),
    },
    Pink = {
        Main = Color3.fromRGB(35, 20, 30), Second = Color3.fromRGB(45, 25, 35),
        Stroke = Color3.fromRGB(100, 50, 70), Divider = Color3.fromRGB(100, 50, 70),
        Text = Color3.fromRGB(255, 230, 240), TextDark = Color3.fromRGB(210, 160, 180),
        Accent = Color3.fromRGB(255, 100, 180),
    },
    Orange = {
        Main = Color3.fromRGB(35, 25, 15), Second = Color3.fromRGB(45, 30, 20),
        Stroke = Color3.fromRGB(100, 60, 30), Divider = Color3.fromRGB(100, 60, 30),
        Text = Color3.fromRGB(255, 240, 220), TextDark = Color3.fromRGB(210, 180, 150),
        Accent = Color3.fromRGB(255, 150, 50),
    },
}

NabaUI.CurrentTheme = NabaUI.Themes.Dark
NabaUI.Flags = {}
NabaUI.SaveCfg = false
NabaUI.Folder = "NabaUI"
NabaUI.KeySystem = nil

-- テーマ設定
function NabaUI:SetTheme(theme)
    self.CurrentTheme = theme
end

function NabaUI:GetTheme()
    return self.CurrentTheme
end

-- キーシステム
function NabaUI:SetKeySystem(config)
    self.KeySystem = config or {}
    self.KeySystem.Key = config.Key or "naba123"
    self.KeySystem.Title = config.Title or "Key System"
    self.KeySystem.Subtitle = config.Subtitle or "Enter key to continue"
    self.KeySystem.SaveKey = config.SaveKey or false
end

function NabaUI:CheckKey(key)
    if self.KeySystem and key == self.KeySystem.Key then
        if self.KeySystem.SaveKey then
            writefile(self.Folder .. "/key.txt", key)
        end
        return true
    end
    return false
end

function NabaUI:IsKeySaved()
    if self.KeySystem and self.KeySystem.SaveKey then
        return isfile(self.Folder .. "/key.txt") and readfile(self.Folder .. "/key.txt") == self.KeySystem.Key
    end
    return false
end

-- 便利関数
local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        if k == "Parent" then obj.Parent = v else pcall(function() obj[k] = v end) end
    end
    return obj
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 10), Parent = parent})
end

-- ドラッグ
local function MakeDraggable(gui, handle)
    local dragging, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; sp = gui.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            gui.Position = UDim2.new(0, math.clamp(sp.X.Offset + d.X, 0, workspace.CurrentCamera.ViewportSize.X - gui.AbsoluteSize.X), 0, math.clamp(sp.Y.Offset + d.Y, 0, workspace.CurrentCamera.ViewportSize.Y - gui.AbsoluteSize.Y))
        end
    end)
end

-- 通知
local NotificationHolder
function NabaUI:MakeNotification(config)
    if not NotificationHolder then
        NotificationHolder = Create("Frame", {
            Size = UDim2.new(0, 300, 1, -25), Position = UDim2.new(1, -25, 1, -25),
            AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, Parent = CoreGui
        })
        local list = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = NotificationHolder})
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end

    local theme = self.CurrentTheme
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Main, BorderSizePixel = 0,
        Position = UDim2.new(1, -55, 0, 0), Parent = NotificationHolder
    })
    AddCorner(frame, 10)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = frame})

    local title = Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 30, 0, 12),
        Text = config.Name or "", TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 15, BackgroundTransparency = 1, Parent = frame
    })
    local content = Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 0), Position = UDim2.new(0, 12, 0, 37),
        Text = config.Content or "", TextColor3 = theme.TextDark,
        Font = Enum.Font.GothamSemibold, TextSize = 14, BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, Parent = frame
    })
    local icon = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 12, 0, 12),
        Image = config.Image or "rbxassetid://4384403532", BackgroundTransparency = 1, Parent = frame
    })

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(config.Time or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(frame.UIStroke, TweenInfo.new(0.5), {Transparency = 0.9}):Play()
        TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0.4}):Play()
        TweenService:Create(content, TweenInfo.new(0.5), {TextTransparency = 0.5}):Play()
        task.wait(0.6)
        frame:Destroy()
    end)
end

-- キーシステムGUI
function NabaUI:ShowKeySystem()
    if not self.KeySystem then return true end
    if self:IsKeySaved() then return true end

    local theme = self.CurrentTheme
    local screenGui = Create("ScreenGui", {Name = "NabaUI_Key", Parent = CoreGui, ResetOnSpawn = false})

    local bg = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = screenGui
    })

    local main = Create("Frame", {
        Size = UDim2.new(0, 350, 0, 220), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = theme.Main,
        BorderSizePixel = 0, Parent = screenGui
    })
    AddCorner(main, 12)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = main})

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 20),
        Text = self.KeySystem.Title, TextColor3 = theme.Text,
        Font = Enum.Font.GothamBlack, TextSize = 22, BackgroundTransparency = 1, Parent = main
    })
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 60),
        Text = self.KeySystem.Subtitle, TextColor3 = theme.TextDark,
        Font = Enum.Font.Gotham, TextSize = 14, BackgroundTransparency = 1, Parent = main
    })

    local input = Create("TextBox", {
        Size = UDim2.new(0.8, 0, 0, 40), Position = UDim2.new(0.1, 0, 0, 95),
        Text = "", PlaceholderText = "Enter key...", TextColor3 = theme.Text,
        PlaceholderColor3 = theme.TextDark, BackgroundColor3 = theme.Second,
        Font = Enum.Font.Gotham, TextSize = 16, BorderSizePixel = 0, Parent = main
    })
    AddCorner(input, 8)

    local status = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 145),
        Text = "", TextColor3 = Color3.fromRGB(255, 80, 80),
        Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1, Parent = main
    })

    local submit = Create("TextButton", {
        Size = UDim2.new(0.8, 0, 0, 40), Position = UDim2.new(0.1, 0, 0, 170),
        Text = "Submit", TextColor3 = theme.Text,
        BackgroundColor3 = theme.Accent, Font = Enum.Font.GothamBold,
        TextSize = 16, BorderSizePixel = 0, Parent = main
    })
    AddCorner(submit, 8)

    local result = false
    submit.MouseButton1Click:Connect(function()
        if NabaUI:CheckKey(input.Text) then
            result = true
            screenGui:Destroy()
        else
            status.Text = "Invalid key!"
        end
    end)

    repeat task.wait() until result or not screenGui.Parent
    if screenGui.Parent then screenGui:Destroy() end
    return result
end

-- 設定保存
function NabaUI:LoadConfig()
    if not self.SaveCfg then return end
    pcall(function()
        if isfile(self.Folder .. "/" .. game.GameId .. ".txt") then
            local data = HttpService:JSONDecode(readfile(self.Folder .. "/" .. game.GameId .. ".txt"))
            for k, v in pairs(data) do
                if self.Flags[k] then self.Flags[k]:Set(v) end
            end
        end
    end)
end

function NabaUI:SaveConfig()
    if not self.SaveCfg then return end
    local data = {}
    for k, v in pairs(self.Flags) do
        if v.Save then data[k] = v.Value end
    end
    if not isfolder(self.Folder) then makefolder(self.Folder) end
    writefile(self.Folder .. "/" .. game.GameId .. ".txt", HttpService:JSONEncode(data))
end

-- ウィンドウ
function NabaUI:MakeWindow(config)
    config = config or {}
    local title = config.Name or "NabaUI"
    local theme = self.CurrentTheme
    local width = config.Width or 615
    local height = config.Height or 344
    self.SaveCfg = config.SaveConfig or false
    self.Folder = config.ConfigFolder or "NabaUI"
    if config.SaveConfig and not isfolder(self.Folder) then makefolder(self.Folder) end

    if config.SaveConfig then self:LoadConfig() end

    local screenGui = Create("ScreenGui", {Name = "NabaUI", Parent = CoreGui, ResetOnSpawn = false})
    local mainFrame = Create("Frame", {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = screenGui
    })
    AddCorner(mainFrame, 10)

    local topBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Parent = mainFrame
    })

    local windowName = Create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 50), Position = UDim2.new(0, 30, 0, 0),
        Text = title, TextColor3 = theme.Text, Font = Enum.Font.GothamBlack,
        TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Parent = topBar
    })

    -- 閉じる/最小化ボタン
    local btnFrame = Create("Frame", {
        Size = UDim2.new(0, 80, 0, 32), Position = UDim2.new(1, -100, 0, 9),
        BackgroundColor3 = theme.Second, BorderSizePixel = 0, Parent = topBar
    })
    AddCorner(btnFrame, 8)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = btnFrame})
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = theme.Stroke, BorderSizePixel = 0, Parent = btnFrame
    })

    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0.5, 0, 1, 0), Text = "", BackgroundTransparency = 1, Parent = btnFrame
    })
    Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 11, 0, 7),
        Image = "rbxassetid://7072725342", ImageColor3 = theme.Text,
        BackgroundTransparency = 1, Parent = closeBtn
    })

    local minimizeBtn = Create("TextButton", {
        Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
        Text = "", BackgroundTransparency = 1, Parent = btnFrame
    })
    local minimizeIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 11, 0, 7),
        Image = "rbxassetid://7072719338", ImageColor3 = theme.Text,
        BackgroundTransparency = 1, Parent = minimizeBtn
    })

    MakeDraggable(mainFrame, topBar)

    -- タブエリア
    local tabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(0, 170, 1, -50), Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = theme.Second, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = theme.Divider, Parent = mainFrame
    })
    AddCorner(tabHolder, 10)
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = tabHolder})
    Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = tabHolder})

    -- ページ
    local pageContainer = Create("ScrollingFrame", {
        Size = UDim2.new(1, -170, 1, -50), Position = UDim2.new(0, 170, 0, 50),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 5, ScrollBarImageColor3 = theme.Divider, Parent = mainFrame
    })

    local pages = {}
    local tabs = {}
    local firstTab = true
    local minimized = false

    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tabHolder.Visible = not minimized; pageContainer.Visible = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0, windowName.TextBounds.X + 160, 0, 50)
            minimizeIcon.Image = "rbxassetid://7072720870"
        else
            mainFrame.Size = UDim2.new(0, width, 0, height)
            minimizeIcon.Image = "rbxassetid://7072719338"
        end
    end)

    local window = {}

    function window:MakeTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local icon = config.Icon or "rbxassetid://4483345998"

        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 35), Text = "", BackgroundTransparency = 1,
            BorderSizePixel = 0, Parent = tabHolder
        })

        local tabIcon = Create("ImageLabel", {
            Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0.5, -11),
            Image = icon, ImageTransparency = 0.4, BackgroundTransparency = 1, Parent = tabBtn
        })

        local tabTitle = Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 40, 0, 0),
            Text = tabName, TextColor3 = theme.Text, TextTransparency = 0.4,
            Font = Enum.Font.GothamSemibold, TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = tabBtn
        })

        local page = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = pageContainer
        })
        local pageList = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = page})
        Create("UIPadding", {PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = page})

        if firstTab then
            firstTab = false; page.Visible = true
            tabIcon.ImageTransparency = 0; tabTitle.TextTransparency = 0; tabTitle.Font = Enum.Font.GothamBlack
        end
        table.insert(pages, page)
        table.insert(tabs, {icon = tabIcon, title = tabTitle})

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            for _, t in pairs(tabs) do t.icon.ImageTransparency = 0.4; t.title.TextTransparency = 0.4; t.title.Font = Enum.Font.GothamSemibold end
            page.Visible = true; tabIcon.ImageTransparency = 0; tabTitle.TextTransparency = 0; tabTitle.Font = Enum.Font.GothamBlack
        end)

        local tabAPI = {}

        function tabAPI:AddSection(config)
            local section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = page
            })
            Create("TextLabel", {
                Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0, 0, 0, 3),
                Text = config.Name or "", TextColor3 = theme.TextDark,
                Font = Enum.Font.GothamSemibold, TextSize = 14, BackgroundTransparency = 1, Parent = section
            })
            local holder = Create("Frame", {
                Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 23),
                BackgroundTransparency = 1, Parent = section
            })
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = holder})

            local secAPI = {}
            function secAPI:AddToggle(cfg) return createToggle(cfg, holder, theme) end
            function secAPI:AddSlider(cfg) return createSlider(cfg, holder, theme) end
            function secAPI:AddButton(cfg) return createButton(cfg, holder, theme) end
            function secAPI:AddDropdown(cfg) return createDropdown(cfg, holder, theme) end
            function secAPI:AddLabel(text)
                local l = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 32), Text = text,
                    TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
                    BackgroundColor3 = theme.Second, BackgroundTransparency = 0.5,
                    BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Center, Parent = holder
                })
                AddCorner(l, 6)
                return {Set = function(t) l.Text = t end}
            end
            return secAPI
        end

        function tabAPI:AddToggle(cfg) return createToggle(cfg, page, theme) end
        function tabAPI:AddSlider(cfg) return createSlider(cfg, page, theme) end
        function tabAPI:AddButton(cfg) return createButton(cfg, page, theme) end
        function tabAPI:AddDropdown(cfg) return createDropdown(cfg, page, theme) end
        function tabAPI:AddLabel(text)
            local l = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 32), Text = text,
                TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
                BackgroundColor3 = theme.Second, BackgroundTransparency = 0.5,
                BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Center, Parent = page
            })
            AddCorner(l, 6)
            return {Set = function(t) l.Text = t end}
        end

        return tabAPI
    end

    -- 動的変更
    function window:SetTitle(t) windowName.Text = t end
    function window:SetSize(w, h) mainFrame.Size = UDim2.new(0, w, 0, h); mainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2) end
    function window:Hide() mainFrame.Visible = false end
    function window:Show() mainFrame.Visible = true end
    function window:Destroy() screenGui:Destroy() end

    return window
end

-- UI部品
function createToggle(config, parent, theme)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = theme.Second,
        BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = parent
    })
    AddCorner(frame, 6)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = frame})

    Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        Text = config.Name or "", TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Parent = frame
    })

    local box = Create("Frame", {
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -30, 0.5, -13),
        BackgroundColor3 = theme.Divider, BorderSizePixel = 0, Parent = frame
    })
    AddCorner(box, 5)

    local ico = Create("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Image = "rbxassetid://3944680095",
        ImageTransparency = 1, ImageColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1, Parent = box
    })

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), Text = "", BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = frame
    })

    local on = config.Default or false
    local function update()
        box.BackgroundColor3 = on and theme.Accent or theme.Divider
        ico.ImageTransparency = on and 0 or 1
        ico.Size = on and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 8, 0, 8)
        if config.Callback then config.Callback(on) end
    end
    btn.MouseButton1Click:Connect(function() on = not on; update() end)
    update()

    local toggle = {Value = on}
    function toggle:Set(v) on = v; update() end
    if config.Flag then toggle.Save = config.Save or false; NabaUI.Flags[config.Flag] = toggle end
    return toggle
end

function createSlider(config, parent, theme)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = theme.Second,
        BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = parent
    })
    AddCorner(frame, 6)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = frame})

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 14, 0, 10),
        Text = config.Name or "", TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Parent = frame
    })

    local barBg = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 28), Position = UDim2.new(0, 14, 0, 34),
        BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.9,
        BorderSizePixel = 0, Parent = frame
    })
    AddCorner(barBg, 5)
    Create("UIStroke", {Color = theme.Accent, Thickness = 1, Parent = barBg})

    local def = config.Default or 50
    local minV = config.Min or 0; local maxV = config.Max or 100
    local pct = (def - minV) / (maxV - minV)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = barBg
    })
    AddCorner(fill, 5)

    local valLabel = Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 28), Position = UDim2.new(0, 5, 0, 0),
        Text = tostring(def), TextColor3 = theme.Text, TextTransparency = 0.7,
        Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1, Parent = barBg
    })

    local val = def
    local function update(v)
        val = math.clamp(v, minV, maxV)
        local p = (val - minV) / (maxV - minV)
        fill.Size = UDim2.new(p, 0, 1, 0)
        valLabel.Text = tostring(val)
        if config.Callback then config.Callback(val) end
    end

    local dragging = false
    barBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            update(math.floor(minV + p * (maxV - minV)))
        end
    end)

    local slider = {Value = val}
    function slider:Set(v) update(v) end
    if config.Flag then slider.Save = config.Save or false; NabaUI.Flags[config.Flag] = slider end
    return slider
end

function createButton(config, parent, theme)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = theme.Second,
        BorderSizePixel = 0, Parent = parent
    })
    AddCorner(frame, 6)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = frame})

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), Text = config.Name or "",
        TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
        BackgroundTransparency = 1, Parent = frame
    })

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), Text = "", BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = frame
    })
    btn.MouseEnter:Connect(function() frame.BackgroundColor3 = theme.Accent end)
    btn.MouseLeave:Connect(function() frame.BackgroundColor3 = theme.Second end)
    btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
    return {Set = function(t) frame.TextLabel.Text = t end}
end

function createDropdown(config, parent, theme)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = theme.Second,
        BackgroundTransparency = 0.3, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 5, Parent = parent
    })
    AddCorner(frame, 6)
    Create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = frame})

    local selected = Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        Text = config.Default or "...", TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Parent = frame
    })

    local arrow = Create("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -30, 0.5, -11),
        Image = "rbxassetid://7072706796", ImageColor3 = theme.Text,
        BackgroundTransparency = 1, Parent = frame
    })

    local list = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = theme.Second, BorderSizePixel = 0,
        ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false, ZIndex = 10, Parent = frame
    })

    local opts = config.Options or {}
    local function buildList()
        for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, opt in ipairs(opts) do
            local b = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, (i-1)*32),
                Text = opt, TextColor3 = theme.TextDark, Font = Enum.Font.Gotham,
                TextSize = 14, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10, Parent = list
            })
            b.MouseButton1Click:Connect(function()
                selected.Text = opt; list.Visible = false
                frame.Size = UDim2.new(1, 0, 0, 42)
                if config.Callback then config.Callback(opt) end
            end)
        end
        list.CanvasSize = UDim2.new(0, 0, 0, #opts * 32)
    end
    buildList()

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), Text = "", BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = frame
    })
    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        frame.Size = list.Visible and UDim2.new(1, 0, 0, 42 + math.min(160, #opts * 32)) or UDim2.new(1, 0, 0, 42)
    end)

    return {
        Refresh = function(newOpts) opts = newOpts; buildList() end,
        Set = function(v) selected.Text = v end,
    }
end

return NabaUI
