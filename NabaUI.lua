-- // NabaUI Library v3.0 - OrionLib風
local NabaUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- テーマ
NabaUI.DefaultTheme = {
    Main = Color3.fromRGB(25, 25, 25),
    Second = Color3.fromRGB(32, 32, 32),
    Stroke = Color3.fromRGB(60, 60, 60),
    Divider = Color3.fromRGB(60, 60, 60),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(9, 99, 195),
}
NabaUI.CurrentTheme = NabaUI.DefaultTheme
NabaUI.Flags = {}
NabaUI.SaveCfg = false
NabaUI.Folder = "NabaUI"

function NabaUI:SetTheme(theme)
    for k, v in pairs(theme) do self.CurrentTheme[k] = v end
end

-- 通知
local NotificationHolder
function NabaUI:MakeNotification(config)
    if not NotificationHolder then
        NotificationHolder = Instance.new("Frame")
        NotificationHolder.Size = UDim2.new(0, 300, 1, -25)
        NotificationHolder.Position = UDim2.new(1, -25, 1, -25)
        NotificationHolder.AnchorPoint = Vector2.new(1, 1)
        NotificationHolder.BackgroundTransparency = 1
        NotificationHolder.Parent = CoreGui
        local list = Instance.new("UIListLayout", NotificationHolder)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
        list.Padding = UDim.new(0, 5)
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -55, 0, 0)
    frame.Parent = NotificationHolder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(93, 93, 93)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -30, 0, 20)
    title.Position = UDim2.new(0, 30, 0, 12)
    title.Text = config.Name or "Notification"
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.BackgroundTransparency = 1

    local content = Instance.new("TextLabel", frame)
    content.Size = UDim2.new(1, -24, 0, 0)
    content.Position = UDim2.new(0, 12, 0, 37)
    content.Text = config.Content or ""
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.Font = Enum.Font.GothamSemibold
    content.TextSize = 14
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.TextWrapped = true

    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0, 12)
    icon.Image = config.Image or "rbxassetid://4384403532"
    icon.BackgroundTransparency = 1

    task.delay(config.Time or 5, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(frame.UIStroke, TweenInfo.new(0.5), {Transparency = 0.9}):Play()
        TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0.4}):Play()
        TweenService:Create(content, TweenInfo.new(0.5), {TextTransparency = 0.5}):Play()
        task.wait(0.6)
        frame:Destroy()
    end)

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
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

-- ウィンドウ作成
function NabaUI:MakeWindow(config)
    config = config or {}
    local title = config.Name or "NabaUI"
    local width = 615
    local height = 344
    local theme = self.CurrentTheme
    self.SaveCfg = config.SaveConfig or false

    if config.SaveConfig then self:LoadConfig() end

    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "NabaUI"
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, width, 0, height)
    mainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    mainFrame.BackgroundColor3 = theme.Main
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundTransparency = 1
    topBar.Name = "TopBar"

    local windowName = Instance.new("TextLabel", topBar)
    windowName.Size = UDim2.new(1, -80, 0, 50)
    windowName.Position = UDim2.new(0, 25, 0, 0)
    windowName.Text = title
    windowName.TextColor3 = theme.Text
    windowName.Font = Enum.Font.GothamBlack
    windowName.TextSize = 20
    windowName.TextXAlignment = Enum.TextXAlignment.Left
    windowName.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 35, 0, 30)
    closeBtn.Position = UDim2.new(1, -85, 0, 10)
    closeBtn.Text = ""
    closeBtn.BackgroundColor3 = theme.Second
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", closeBtn).Color = theme.Stroke

    local closeIcon = Instance.new("ImageLabel", closeBtn)
    closeIcon.Size = UDim2.new(0, 18, 0, 18)
    closeIcon.Position = UDim2.new(0, 9, 0, 6)
    closeIcon.Image = "rbxassetid://7072725342"
    closeIcon.BackgroundTransparency = 1

    local minimizeBtn = Instance.new("TextButton", topBar)
    minimizeBtn.Size = UDim2.new(0, 35, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 10)
    minimizeBtn.Text = ""
    minimizeBtn.BackgroundColor3 = theme.Second
    minimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", minimizeBtn).Color = theme.Stroke

    local minimizeIcon = Instance.new("ImageLabel", minimizeBtn)
    minimizeIcon.Size = UDim2.new(0, 18, 0, 18)
    minimizeIcon.Position = UDim2.new(0, 9, 0, 6)
    minimizeIcon.Image = "rbxassetid://7072719338"
    minimizeIcon.BackgroundTransparency = 1

    -- ドラッグ
    local dragging, ds, sp
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; sp = mainFrame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            mainFrame.Position = UDim2.new(0, math.clamp(sp.X.Offset + d.X, 0, Camera.ViewportSize.X - mainFrame.AbsoluteSize.X), 0, math.clamp(sp.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - mainFrame.AbsoluteSize.Y))
        end
    end)

    -- タブエリア
    local tabHolder = Instance.new("ScrollingFrame", mainFrame)
    tabHolder.Size = UDim2.new(0, 150, 1, -50)
    tabHolder.Position = UDim2.new(0, 0, 0, 50)
    tabHolder.BackgroundColor3 = theme.Second
    tabHolder.BorderSizePixel = 0
    tabHolder.ScrollBarThickness = 4
    tabHolder.ScrollBarImageColor3 = theme.Stroke
    Instance.new("UICorner", tabHolder).CornerRadius = UDim.new(0, 10)
    local tabList = Instance.new("UIListLayout", tabHolder)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 6)
    Instance.new("UIPadding", tabHolder).PaddingTop = UDim.new(0, 8)

    -- ページコンテナ
    local pageContainer = Instance.new("ScrollingFrame", mainFrame)
    pageContainer.Size = UDim2.new(1, -150, 1, -50)
    pageContainer.Position = UDim2.new(0, 150, 0, 50)
    pageContainer.BackgroundTransparency = 1
    pageContainer.BorderSizePixel = 0
    pageContainer.ScrollBarThickness = 5
    pageContainer.ScrollBarImageColor3 = theme.Divider

    local pages = {}
    local tabs = {}
    local firstTab = true

    local window = {MainFrame = mainFrame, Minimized = false}

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        if window.Minimized then
            tabHolder.Visible = false
            pageContainer.Visible = false
            mainFrame.Size = UDim2.new(0, windowName.TextBounds.X + 140, 0, 50)
            minimizeIcon.Image = "rbxassetid://7072720870"
        else
            tabHolder.Visible = true
            pageContainer.Visible = true
            mainFrame.Size = UDim2.new(0, width, 0, height)
            minimizeIcon.Image = "rbxassetid://7072719338"
        end
    end)

    function window:MakeTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local icon = config.Icon or "rbxassetid://4483345998"

        local tabBtn = Instance.new("TextButton", tabHolder)
        tabBtn.Size = UDim2.new(1, 0, 0, 30)
        tabBtn.Text = ""
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0

        local tabIcon = Instance.new("ImageLabel", tabBtn)
        tabIcon.Size = UDim2.new(0, 18, 0, 18)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -9)
        tabIcon.Image = icon
        tabIcon.ImageTransparency = 0.4
        tabIcon.BackgroundTransparency = 1

        local tabTitle = Instance.new("TextLabel", tabBtn)
        tabTitle.Size = UDim2.new(1, -35, 1, 0)
        tabTitle.Position = UDim2.new(0, 35, 0, 0)
        tabTitle.Text = tabName
        tabTitle.TextColor3 = theme.Text
        tabTitle.TextTransparency = 0.4
        tabTitle.Font = Enum.Font.GothamSemibold
        tabTitle.TextSize = 14
        tabTitle.TextXAlignment = Enum.TextXAlignment.Left
        tabTitle.BackgroundTransparency = 1

        local page = Instance.new("Frame", pageContainer)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        local pageList = Instance.new("UIListLayout", page)
        pageList.SortOrder = Enum.SortOrder.LayoutOrder
        pageList.Padding = UDim.new(0, 6)
        Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 15)

        if firstTab then
            firstTab = false
            page.Visible = true
            tabIcon.ImageTransparency = 0
            tabTitle.TextTransparency = 0
            tabTitle.Font = Enum.Font.GothamBlack
        end
        table.insert(pages, page)
        table.insert(tabs, {btn = tabBtn, icon = tabIcon, title = tabTitle})

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            for _, t in pairs(tabs) do
                t.icon.ImageTransparency = 0.4
                t.title.TextTransparency = 0.4
                t.title.Font = Enum.Font.GothamSemibold
            end
            page.Visible = true
            tabIcon.ImageTransparency = 0
            tabTitle.TextTransparency = 0
            tabTitle.Font = Enum.Font.GothamBlack
        end)

        local tabAPI = {}

        -- セクション
        function tabAPI:AddSection(config)
            local section = Instance.new("Frame", page)
            section.Size = UDim2.new(1, 0, 0, 26)
            section.BackgroundTransparency = 1

            local label = Instance.new("TextLabel", section)
            label.Size = UDim2.new(1, -12, 0, 16)
            label.Position = UDim2.new(0, 0, 0, 3)
            label.Text = config.Name or "Section"
            label.TextColor3 = theme.TextDark
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 14
            label.BackgroundTransparency = 1

            local holder = Instance.new("Frame", section)
            holder.Size = UDim2.new(1, 0, 1, -24)
            holder.Position = UDim2.new(0, 0, 0, 23)
            holder.BackgroundTransparency = 1
            local holderList = Instance.new("UIListLayout", holder)
            holderList.SortOrder = Enum.SortOrder.LayoutOrder
            holderList.Padding = UDim.new(0, 6)

            local sectionAPI = {}
            function sectionAPI:AddToggle(config)
                return createToggle(config, holder, theme)
            end
            function sectionAPI:AddSlider(config)
                return createSlider(config, holder, theme)
            end
            function sectionAPI:AddButton(config)
                return createButton(config, holder, theme)
            end
            function sectionAPI:AddDropdown(config)
                return createDropdown(config, holder, theme)
            end
            function sectionAPI:AddLabel(text)
                local lbl = Instance.new("TextLabel", holder)
                lbl.Size = UDim2.new(1, 0, 0, 30)
                lbl.Text = text
                lbl.TextColor3 = theme.Text
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 15
                lbl.BackgroundColor3 = theme.Second
                lbl.BackgroundTransparency = 0.7
                lbl.BorderSizePixel = 0
                Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
                return lbl
            end
            return sectionAPI
        end

        -- トグル
        function tabAPI:AddToggle(config)
            return createToggle(config, page, theme)
        end

        -- スライダー
        function tabAPI:AddSlider(config)
            return createSlider(config, page, theme)
        end

        -- ボタン
        function tabAPI:AddButton(config)
            return createButton(config, page, theme)
        end

        -- ドロップダウン
        function tabAPI:AddDropdown(config)
            return createDropdown(config, page, theme)
        end

        -- ラベル
        function tabAPI:AddLabel(text)
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.Text = text
            lbl.TextColor3 = theme.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 15
            lbl.BackgroundColor3 = theme.Second
            lbl.BackgroundTransparency = 0.7
            lbl.BorderSizePixel = 0
            Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
            return lbl
        end

        return tabAPI
    end

    -- 動的変更API
    function window:SetTitle(newTitle)
        windowName.Text = newTitle
    end

    function window:SetSize(w, h)
        mainFrame.Size = UDim2.new(0, w, 0, h)
        mainFrame.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end

    function window:Hide()
        mainFrame.Visible = false
    end

    function window:Show()
        mainFrame.Visible = true
    end

    function window:Destroy()
        screenGui:Destroy()
    end

    return window
end

-- 共通UI部品
function createToggle(config, parent, theme)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = theme.Second
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", frame).Color = theme.Stroke

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = config.Name or "Toggle"
    label.TextColor3 = theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local toggleBox = Instance.new("Frame", frame)
    toggleBox.Size = UDim2.new(0, 24, 0, 24)
    toggleBox.Position = UDim2.new(1, -24, 0.5, 0)
    toggleBox.AnchorPoint = Vector2.new(0, 0.5)
    toggleBox.BackgroundColor3 = theme.Divider
    toggleBox.BorderSizePixel = 0
    Instance.new("UICorner", toggleBox).CornerRadius = UDim.new(0, 4)

    local toggleIcon = Instance.new("ImageLabel", toggleBox)
    toggleIcon.Size = UDim2.new(0, 20, 0, 20)
    toggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleIcon.Image = "rbxassetid://3944680095"
    toggleIcon.ImageTransparency = 1
    toggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    toggleIcon.BackgroundTransparency = 1

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Text = ""
    clickBtn.BackgroundTransparency = 1
    clickBtn.BorderSizePixel = 0

    local toggle = {Value = config.Default or false}
    function toggle:Set(val)
        self.Value = val
        if val then
            toggleBox.BackgroundColor3 = Color3.fromRGB(9, 99, 195)
            toggleIcon.ImageTransparency = 0
        else
            toggleBox.BackgroundColor3 = theme.Divider
            toggleIcon.ImageTransparency = 1
        end
        if config.Callback then config.Callback(val) end
    end

    clickBtn.MouseButton1Click:Connect(function()
        toggle:Set(not toggle.Value)
        if NabaUI.SaveCfg then NabaUI:SaveConfig() end
    end)

    if config.Flag then
        toggle.Save = config.Save or false
        NabaUI.Flags[config.Flag] = toggle
    end

    toggle:Set(toggle.Value)
    return toggle
end

function createSlider(config, parent, theme)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundColor3 = theme.Second
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", frame).Color = theme.Stroke

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -12, 0, 14)
    label.Position = UDim2.new(0, 12, 0, 10)
    label.Text = config.Name or "Slider"
    label.TextColor3 = theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local barBg = Instance.new("Frame", frame)
    barBg.Size = UDim2.new(1, -24, 0, 26)
    barBg.Position = UDim2.new(0, 12, 0, 30)
    barBg.BackgroundColor3 = Color3.fromRGB(9, 99, 195)
    barBg.BackgroundTransparency = 0.9
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", barBg).Color = Color3.fromRGB(9, 99, 195)

    local pct = ((config.Default or 50) - (config.Min or 0)) / ((config.Max or 100) - (config.Min or 0))
    local fill = Instance.new("Frame", barBg)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(9, 99, 195)
    fill.BackgroundTransparency = 0.3
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)

    local valueLabel = Instance.new("TextLabel", barBg)
    valueLabel.Size = UDim2.new(1, -12, 0, 26)
    valueLabel.Position = UDim2.new(0, 6, 0, 0)
    valueLabel.Text = tostring(config.Default or 50) .. " " .. (config.ValueName or "")
    valueLabel.TextColor3 = theme.Text
    valueLabel.TextTransparency = 0.8
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.BackgroundTransparency = 1

    local slider = {Value = config.Default or 50}
    function slider:Set(val)
        local inc = config.Increment or 1
        val = math.clamp(math.floor(val / inc + 0.5) * inc, config.Min or 0, config.Max or 100)
        self.Value = val
        local p = (val - (config.Min or 0)) / ((config.Max or 100) - (config.Min or 0))
        fill.Size = UDim2.new(p, 0, 1, 0)
        valueLabel.Text = tostring(val) .. " " .. (config.ValueName or "")
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
            local val = (config.Min or 0) + p * ((config.Max or 100) - (config.Min or 0))
            slider:Set(val)
            if NabaUI.SaveCfg then NabaUI:SaveConfig() end
        end
    end)

    if config.Flag then
        slider.Save = config.Save or false
        NabaUI.Flags[config.Flag] = slider
    end

    slider:Set(slider.Value)
    return slider
end

function createButton(config, parent, theme)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 33)
    frame.BackgroundColor3 = theme.Second
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", frame).Color = theme.Stroke

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = config.Name or "Button"
    label.TextColor3 = theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Text = ""
    clickBtn.BackgroundTransparency = 1
    clickBtn.BorderSizePixel = 0

    clickBtn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    return {Set = function(t) label.Text = t end}
end

function createDropdown(config, parent, theme)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = theme.Second
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", frame).Color = theme.Stroke

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = config.Name or "Dropdown"
    label.TextColor3 = theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local selected = Instance.new("TextLabel", frame)
    selected.Size = UDim2.new(1, -40, 1, 0)
    selected.Text = config.Default or "..."
    selected.TextColor3 = theme.TextDark
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 13
    selected.TextXAlignment = Enum.TextXAlignment.Right
    selected.BackgroundTransparency = 1

    local arrow = Instance.new("ImageLabel", frame)
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -30, 0.5, -10)
    arrow.Image = "rbxassetid://7072706796"
    arrow.ImageColor3 = theme.Text
    arrow.BackgroundTransparency = 1

    local list = Instance.new("ScrollingFrame", frame)
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 38)
    list.BackgroundColor3 = theme.Second
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = theme.Stroke
    list.CanvasSize = UDim2.new(0, 0, 0, #(config.Options or {}) * 28)
    list.Visible = false
    list.ZIndex = 10

    local options = config.Options or {}
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", list)
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1)*28)
        optBtn.Text = opt
        optBtn.TextColor3 = theme.TextDark
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 13
        optBtn.BackgroundTransparency = 1
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 10
        optBtn.MouseButton1Click:Connect(function()
            selected.Text = opt
            list.Visible = false
            frame.Size = UDim2.new(1, 0, 0, 38)
            if config.Callback then config.Callback(opt) end
        end)
    end

    local clickBtn = Instance.new("TextButton", frame)
    clickBtn.Size = UDim2.new(1, 0, 0, 38)
    clickBtn.Text = ""
    clickBtn.BackgroundTransparency = 1
    clickBtn.BorderSizePixel = 0

    clickBtn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        frame.Size = list.Visible and UDim2.new(1, 0, 0, 38 + math.min(140, #options * 28)) or UDim2.new(1, 0, 0, 38)
    end)

    return {
        Refresh = function(newOpts, del)
            options = newOpts
            for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            for i, opt in ipairs(options) do
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.new(1, 0, 0, 28)
                b.Position = UDim2.new(0, 0, 0, (i-1)*28)
                b.Text = opt
                b.TextColor3 = theme.TextDark
                b.Font = Enum.Font.Gotham
                b.TextSize = 13
                b.BackgroundTransparency = 1
                b.BorderSizePixel = 0
                b.ZIndex = 10
                b.MouseButton1Click:Connect(function()
                    selected.Text = opt
                    list.Visible = false
                    frame.Size = UDim2.new(1, 0, 0, 38)
                    if config.Callback then config.Callback(opt) end
                end)
            end
            list.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
        end,
        Set = function(val) selected.Text = val end,
    }
end

return NabaUI
