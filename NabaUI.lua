-- // NabeUI Library v2.0 - GitHub版
local NabeUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

NabeUI.DefaultTheme = {
    Main = Color3.fromRGB(25, 25, 30),
    Second = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(255, 100, 80),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(160, 160, 160),
    Stroke = Color3.fromRGB(60, 60, 60),
    ToggleOn = Color3.fromRGB(40, 60, 40),
    ToggleOff = Color3.fromRGB(35, 35, 42),
    SliderBar = Color3.fromRGB(40, 40, 45),
    SliderFill = Color3.fromRGB(255, 100, 80),
    TitleFont = "GothamBold",
    TabFont = "Gotham",
    Font = "Gotham",
    TitleSize = 14,
    TabSize = 12,
    ElementSize = 11,
    WindowRadius = 10,
    TabRadius = 6,
    ElementRadius = 6,
}

NabeUI.CurrentTheme = NabeUI.DefaultTheme

function NabeUI:SetTheme(theme)
    for k, v in pairs(theme) do self.CurrentTheme[k] = v end
end

NabeUI.Themes = {
    Dark = {Main=Color3.fromRGB(25,25,30),Second=Color3.fromRGB(35,35,40),Accent=Color3.fromRGB(255,100,80),Text=Color3.fromRGB(240,240,240),TextDark=Color3.fromRGB(160,160,160),Stroke=Color3.fromRGB(60,60,60)},
    Blue = {Main=Color3.fromRGB(20,25,35),Second=Color3.fromRGB(30,35,45),Accent=Color3.fromRGB(100,180,255),Text=Color3.fromRGB(240,240,255),TextDark=Color3.fromRGB(150,170,200),Stroke=Color3.fromRGB(50,70,100)},
    Green = {Main=Color3.fromRGB(20,30,25),Second=Color3.fromRGB(30,40,35),Accent=Color3.fromRGB(100,255,150),Text=Color3.fromRGB(240,255,240),TextDark=Color3.fromRGB(150,200,160),Stroke=Color3.fromRGB(50,80,60)},
    Purple = {Main=Color3.fromRGB(30,20,35),Second=Color3.fromRGB(40,30,45),Accent=Color3.fromRGB(180,130,255),Text=Color3.fromRGB(240,230,255),TextDark=Color3.fromRGB(180,160,210),Stroke=Color3.fromRGB(80,50,100)},
}

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        if k == "Parent" then obj.Parent = v else pcall(function() obj[k] = v end) end
    end
    return obj
end

local function addCorner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = parent})
end

local function makeDraggable(gui, handle)
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
            gui.Position = UDim2.new(0, math.clamp(sp.X.Offset + d.X, 0, Camera.ViewportSize.X - gui.AbsoluteSize.X), 0, math.clamp(sp.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - gui.AbsoluteSize.Y))
        end
    end)
end

function NabeUI:ShowLoading(config)
    config = config or {}
    local title = config.Title or "NabeUI"
    local subtitle = config.Subtitle or "Loading..."
    local duration = config.Duration or 2
    local theme = self.CurrentTheme

    local loadingFrame = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7, BorderSizePixel = 0,
        Parent = gethui and gethui() or CoreGui
    })

    local logo = create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 50), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.45, 0), Text = title,
        TextColor3 = theme.Accent, Font = theme.TitleFont, TextSize = 28,
        BackgroundTransparency = 1, Parent = loadingFrame
    })

    local sub = create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 30), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.55, 0), Text = subtitle,
        TextColor3 = theme.TextDark, Font = theme.Font, TextSize = 14,
        BackgroundTransparency = 1, Parent = loadingFrame
    })

    task.delay(duration, function()
        TweenService:Create(loadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(logo, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(sub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        loadingFrame:Destroy()
    end)
end

function NabeUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "NabeUI"
    local width = config.Width or 320
    local height = config.Height or 420
    local theme = self.CurrentTheme

    local screenGui = create("ScreenGui", {Name = "NabeUI", Parent = gethui and gethui() or CoreGui, ResetOnSpawn = false})
    local mainFrame = create("Frame", {
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width/2, 0.5, -height/2),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0, Parent = screenGui
    })
    addCorner(mainFrame, theme.WindowRadius or 10)
    create("UIStroke", {Color = theme.Stroke, Thickness = 1, Parent = mainFrame})

    local titleBar = create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 32), Text = "  " .. title,
        TextColor3 = theme.Text, Font = theme.TitleFont or "GothamBold",
        TextSize = theme.TitleSize or 14, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = theme.Second, Parent = mainFrame
    })
    addCorner(titleBar, theme.WindowRadius or 10)

    local minimizeBtn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -34, 0, 0),
        Text = "_", TextColor3 = theme.TextDark, Font = theme.Font,
        TextSize = 18, BackgroundColor3 = theme.Second, BorderSizePixel = 0, Parent = mainFrame
    })
    addCorner(minimizeBtn, 8)

    local contentArea = create("Frame", {
        Size = UDim2.new(1, 0, 1, -32), Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1, Parent = mainFrame
    })

    makeDraggable(mainFrame, titleBar)

    local tabArea = create("ScrollingFrame", {
        Size = UDim2.new(0, 105, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Accent, Parent = contentArea
    })
    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = tabArea})
    create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), Parent = tabArea})

    local pageContainer = create("Frame", {
        Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 1, Parent = contentArea
    })
    local pages = {}
    local tabs = {}
    local firstTab = true

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tabArea.Visible = false
            pageContainer.Visible = false
            mainFrame.Size = UDim2.new(0, width, 0, 32)
            minimizeBtn.Text = "+"
        else
            tabArea.Visible = true
            pageContainer.Visible = true
            mainFrame.Size = UDim2.new(0, width, 0, height)
            minimizeBtn.Text = "_"
        end
    end)

    local window = {}

    function window:CreateTab(tabName)
        local tabBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32), Text = tabName,
            TextColor3 = theme.TextDark, Font = theme.TabFont or "Gotham",
            TextSize = theme.TabSize or 12, BackgroundColor3 = theme.Second,
            BorderSizePixel = 0, Parent = tabArea
        })
        addCorner(tabBtn, theme.TabRadius or 6)

        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 500),
            Visible = false, Parent = pageContainer
        })
        create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = page})
        create("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = page})

        if firstTab then
            firstTab = false; page.Visible = true
            tabBtn.TextColor3 = theme.Text; tabBtn.Font = theme.TitleFont or "GothamBold"
        end
        table.insert(pages, page); table.insert(tabs, tabBtn)

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            for _, t in pairs(tabs) do t.TextColor3 = theme.TextDark; t.Font = theme.TabFont or "Gotham" end
            page.Visible = true; tabBtn.TextColor3 = theme.Text; tabBtn.Font = theme.TitleFont or "GothamBold"
        end)

        local function createToggle(name, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34), Text = "[ ] " .. name,
                TextColor3 = theme.Accent, Font = theme.Font or "Gotham",
                TextSize = theme.ElementSize or 11, TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = theme.ToggleOff, BorderSizePixel = 0,
                AutoButtonColor = false, Parent = page
            })
            addCorner(btn, theme.ElementRadius or 6)
            local on = false
            btn.MouseEnter:Connect(function() if not on then btn.BackgroundColor3 = theme.Second end end)
            btn.MouseLeave:Connect(function() if not on then btn.BackgroundColor3 = theme.ToggleOff end end)
            btn.MouseButton1Click:Connect(function()
                on = not on
                btn.Text = (on and "[X] " or "[ ] ") .. name
                btn.BackgroundColor3 = on and theme.ToggleOn or theme.ToggleOff
                if callback then callback(on) end
            end)
            return btn
        end

        local function createSlider(name, min, max, def, callback)
            local container = create("Frame", {
                Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = theme.Second,
                BorderSizePixel = 0, Parent = page
            })
            addCorner(container, theme.ElementRadius or 6)

            local label = create("TextLabel", {
                Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0, 8, 0, 5),
                Text = name .. ": " .. def, TextColor3 = theme.Text,
                Font = theme.Font or "Gotham", TextSize = theme.ElementSize or 11,
                TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Parent = container
            })

            local bar = create("Frame", {
                Size = UDim2.new(1, -16, 0, 5), Position = UDim2.new(0, 8, 0, 28),
                BackgroundColor3 = theme.SliderBar, BorderSizePixel = 0, Parent = container
            })
            addCorner(bar, 3)

            local pct = (def - min) / (max - min)
            local fill = create("Frame", {
                Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = theme.SliderFill,
                BorderSizePixel = 0, Parent = bar
            })
            addCorner(fill, 3)

            local sbtn = create("TextButton", {
                Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(pct, -7, -0.5, -4),
                BackgroundColor3 = theme.SliderFill, Text = "", BorderSizePixel = 0, Parent = bar
            })
            addCorner(sbtn, 1)

            local val = def; local hold = false
            sbtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hold = true end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hold = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hold and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    sbtn.Position = UDim2.new(p, -7, -0.5, -4); fill.Size = UDim2.new(p, 0, 1, 0)
                    val = min + p * (max - min)
                    if min < 1 then val = math.floor(val * 100) / 100 else val = math.floor(val) end
                    label.Text = name .. ": " .. val
                    if callback then callback(val) end
                end
            end)
        end

        local function createButton(name, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34), Text = name,
                TextColor3 = theme.Text, Font = theme.Font or "Gotham",
                TextSize = theme.ElementSize or 11, BackgroundColor3 = theme.Second,
                BorderSizePixel = 0, Parent = page
            })
            addCorner(btn, theme.ElementRadius or 6)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = theme.Accent end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = theme.Second end)
            btn.MouseButton1Click:Connect(function() if callback then callback() end end)
            return btn
        end

        local function createLabel(text)
            return create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20), Text = text,
                TextColor3 = theme.TextDark, Font = theme.Font or "Gotham",
                TextSize = theme.ElementSize or 11, TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1, Parent = page
            })
        end

        return {
            CreateToggle = createToggle,
            CreateSlider = createSlider,
            CreateButton = createButton,
            CreateLabel = createLabel,
        }
    end

    return window
end

return NabeUI
