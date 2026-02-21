--[[
    AURORA LIBRARY - Premium UI Framework
    Version: 2.0.0
    For Learning Purposes Only
]]--

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Aurora Library
local Aurora = {}
Aurora.Version = "2.0.0"

-- Theme
Aurora.Theme = {
    BgMain = Color3.fromRGB(12, 12, 16),
    BgCard = Color3.fromRGB(18, 18, 24),
    BgPanel = Color3.fromRGB(22, 22, 30),
    BgInput = Color3.fromRGB(28, 28, 38),
    BgHover = Color3.fromRGB(35, 35, 48),
    Accent = Color3.fromRGB(124, 77, 255),
    AccentLight = Color3.fromRGB(150, 110, 255),
    Cyan = Color3.fromRGB(80, 200, 255),
    Green = Color3.fromRGB(80, 220, 140),
    Orange = Color3.fromRGB(255, 160, 60),
    Red = Color3.fromRGB(255, 85, 85),
    TextMain = Color3.fromRGB(240, 240, 245),
    TextSub = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(100, 100, 120),
    Border = Color3.fromRGB(45, 45, 60),
    GradientAccent = {Color3.fromRGB(124, 77, 255), Color3.fromRGB(80, 200, 255)}
}

-- Config
Aurora.Config = {
    Duration = 0.25,
    Easing = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Utility Functions (standalone, not methods)
local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k == "Parent" then inst.Parent = v else inst[k] = v end
    end
    return inst
end

local function Tween(inst, props, dur)
    local info = TweenInfo.new(dur or Aurora.Config.Duration, Aurora.Config.Easing, Aurora.Config.Direction)
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

local function Corner(r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function Stroke(color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Aurora.Theme.Border
    s.Thickness = thick or 1
    return s
end

local function Gradient(colors, rot)
    local keypoints = {}
    for i, c in ipairs(colors) do
        table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / math.max(1, #colors - 1), c))
    end
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(keypoints)
    g.Rotation = rot or 90
    return g
end

local function Ripple(btn, x, y)
    local r = New("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = btn
    })
    Corner(100).Parent = r
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    Tween(r, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
    task.delay(0.5, function() r:Destroy() end)
end

local function GetTime()
    local t = os.date("*t")
    local h = t.hour
    local ampm = "AM"
    if h >= 12 then ampm = "PM"; if h > 12 then h = h - 12 end end
    if h == 0 then h = 12 end
    return string.format("%02d:%02d:%02d %s", h, t.min, t.sec, ampm)
end

local function GetExecutorInfo()
    local info = {Name = "Unknown", Version = "Unknown"}
    pcall(function()
        if identifyexecutor then
            local n, v = identifyexecutor()
            info.Name = n or "Unknown"
            info.Version = v or "Unknown"
        end
    end)
    return info
end

-- Loading Screen
function Aurora.LoadingScreen(config)
    config = config or {}
    local duration = config.Duration or 3
    local onComplete = config.OnComplete or function() end
    
    local screen = New("ScreenGui", {
        Name = "AuroraLoading",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local bg = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = screen
    })
    Corner(0).Parent = bg
    
    local gradFrame = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = bg
    })
    local grad = Gradient(Aurora.Theme.GradientAccent, 135)
    grad.Parent = gradFrame
    
    task.spawn(function()
        while screen and screen.Parent do
            for r = 0, 360, 2 do grad.Rotation = r; task.wait(0.02) end
        end
    end)
    
    local center = New("Frame", {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = bg
    })
    
    local logo = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "AURORA",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 48,
        Font = Enum.Font.GothamBlack,
        Parent = center
    })
    Gradient(Aurora.Theme.GradientAccent, 0).Parent = logo
    
    local tagline = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 75),
        BackgroundTransparency = 1,
        Text = config.Subtitle or "Loading...",
        TextColor3 = Aurora.Theme.TextSub,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Parent = center
    })
    
    local progressBg = New("Frame", {
        Size = UDim2.new(0.8, 0, 0, 4),
        Position = UDim2.new(0.1, 0, 0, 130),
        BackgroundColor3 = Aurora.Theme.BgInput,
        Parent = center
    })
    Corner(2).Parent = progressBg
    
    local progressFill = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = progressBg
    })
    Corner(2).Parent = progressFill
    Gradient(Aurora.Theme.GradientAccent, 0).Parent = progressFill
    
    local percentText = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 145),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = center
    })
    
    local statusText = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 170),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Aurora.Theme.TextSub,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = center
    })
    
    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Text = "Aurora Library v" .. Aurora.Version .. " | Learning Purpose Only",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = bg
    })
    
    local statuses = {"Initializing...", "Loading Components...", "Setting Up Interface...", "Configuring Theme...", "Preparing UI...", "Almost Ready...", "Welcome!"}
    
    task.spawn(function()
        for i, status in ipairs(statuses) do
            statusText.Text = status
            local target = (i / #statuses) * 100
            while tonumber(percentText.Text:match("%d+")) < target do
                local current = tonumber(percentText.Text:match("%d+")) + 1
                percentText.Text = math.min(current, target) .. "%"
                progressFill.Size = UDim2.new(math.min(current, target) / 100, 0, 1, 0)
                task.wait(duration / 100)
            end
            task.wait(0.15)
        end
        task.wait(0.3)
        Tween(bg, {BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        screen:Destroy()
        onComplete()
    end)
    
    return screen
end

-- Window
function Aurora.Window(config)
    config = config or {}
    
    local window = {
        Title = config.Title or "Aurora",
        Size = config.Size or UDim2.new(0, 580, 0, 400),
        Tabs = {},
        CurrentTab = nil,
        Dragging = false,
        DragOffset = Vector2.new()
    }
    
    local screen = New("ScreenGui", {
        Name = "AuroraWindow",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    window.Screen = screen
    
    local main = New("Frame", {
        Size = window.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = screen
    })
    Corner(10).Parent = main
    Stroke(Aurora.Theme.Border).Parent = main
    
    local glow = New("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Aurora.Theme.Accent,
        ImageTransparency = 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = main
    })
    
    task.spawn(function()
        local t, d = 0.85, 1
        while screen and screen.Parent do
            t = t + d * 0.008
            if t <= 0.7 then d = 1 elseif t >= 0.95 then d = -1 end
            glow.ImageTransparency = t
            task.wait(0.03)
        end
    end)
    
    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgCard,
        Parent = main
    })
    Corner(10).Parent = header
    New("Frame", {Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Aurora.Theme.BgCard, BorderSizePixel = 0, Parent = header})
    
    local accentLine = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = header
    })
    Gradient(Aurora.Theme.GradientAccent, 0).Parent = accentLine
    
    New("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10886031167",
        ImageColor3 = Aurora.Theme.Cyan,
        Parent = header
    })
    
    New("TextLabel", {
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Title,
        TextColor3 = Aurora.Theme.TextMain,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local controls = New("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1,
        Parent = header
    })
    local ctrlLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6)
    })
    ctrlLayout.Parent = controls
    
    local function CtrlBtn(text, callback)
        local btn = New("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            BackgroundColor3 = Aurora.Theme.BgInput,
            BackgroundTransparency = 0.5,
            Text = text,
            TextColor3 = Aurora.Theme.TextSub,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            Parent = controls
        })
        Corner(6).Parent = btn
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0})
            if text == "X" then btn.BackgroundColor3 = Aurora.Theme.Red; btn.TextColor3 = Color3.new(1, 1, 1) end
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.5})
            btn.BackgroundColor3 = Aurora.Theme.BgInput
            btn.TextColor3 = Aurora.Theme.TextSub
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local minBtn = CtrlBtn("-", function()
        if window.Minimized then
            Tween(main, {Size = window.Size}, 0.25)
            minBtn.Text = "-"
        else
            Tween(main, {Size = UDim2.new(window.Size.X.Offset, 0, 0, 50)}, 0.25)
            minBtn.Text = "+"
        end
        window.Minimized = not window.Minimized
    end)
    
    CtrlBtn("[]", function()
        if window.Maximized then
            Tween(main, {Size = window.Size, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.25)
        else
            Tween(main, {Size = UDim2.new(0.85, 0, 0.85, 0)}, 0.25)
        end
        window.Maximized = not window.Maximized
    end)
    
    CtrlBtn("X", function()
        Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        screen:Destroy()
    end)
    
    local sidebar = New("Frame", {
        Size = UDim2.new(0, 140, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgCard,
        Parent = main
    })
    
    local tabList = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -100),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar
    })
    local tabPadding = New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
    tabPadding.Parent = tabList
    local tabLayout = New("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4)})
    tabLayout.Parent = tabList
    
    local userCard = New("Frame", {
        Size = UDim2.new(1, -16, 0, 85),
        Position = UDim2.new(0, 8, 1, -93),
        BackgroundColor3 = Aurora.Theme.BgPanel,
        Parent = sidebar
    })
    Corner(8).Parent = userCard
    Stroke(Aurora.Theme.Border).Parent = userCard
    
    local avatarBg = New("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Aurora.Theme.BgInput,
        Parent = userCard
    })
    Corner(6).Parent = avatarBg
    
    local avatar = New("ImageLabel", {
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
        Parent = avatarBg
    })
    Corner(4).Parent = avatar
    
    New("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16),
        Position = UDim2.new(0, 54, 0, 10),
        BackgroundTransparency = 1,
        Text = Players.LocalPlayer.Name,
        TextColor3 = Aurora.Theme.TextMain,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = userCard
    })
    
    New("TextLabel", {
        Size = UDim2.new(1, -60, 0, 14),
        Position = UDim2.new(0, 54, 0, 26),
        BackgroundTransparency = 1,
        Text = "ID: " .. Players.LocalPlayer.UserId,
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userCard
    })
    
    local timeLabel = New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 1, -26),
        BackgroundTransparency = 1,
        Text = GetTime(),
        TextColor3 = Aurora.Theme.Cyan,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userCard
    })
    
    task.spawn(function()
        while screen and screen.Parent do timeLabel.Text = GetTime(); task.wait(1) end
    end)
    
    local content = New("Frame", {
        Size = UDim2.new(1, -140, 1, -50),
        Position = UDim2.new(0, 140, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = main
    })
    
    local contentScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Aurora.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = content
    })
    local contentPadding = New("UIPadding", {PaddingBottom = UDim.new(0, 8)})
    contentPadding.Parent = contentScroll
    local contentLayout = New("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8)})
    contentLayout.Parent = contentScroll
    
    window.TabList = tabList
    window.Content = contentScroll
    
    -- Dragging
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = true
            window.DragOffset = Vector2.new(input.Position.X - main.AbsolutePosition.X, input.Position.Y - main.AbsolutePosition.Y)
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then window.Dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X - window.DragOffset.X, input.Position.Y - window.DragOffset.Y)
            main.Position = UDim2.new(0, pos.X, 0, pos.Y)
            main.AnchorPoint = Vector2.new(0, 0)
        end
    end)
    
    -- Toggle shortcut
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
    end)
    
    -- Tab function
    function window.Tab(tabConfig)
        tabConfig = tabConfig or {}
        local tab = {Name = tabConfig.Name or "Tab", Window = window}
        
        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Aurora.Theme.BgPanel,
            BackgroundTransparency = 0.5,
            Text = "",
            Parent = window.TabList
        })
        Corner(6).Parent = btn
        
        New("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = tab.Name,
            TextColor3 = Aurora.Theme.TextSub,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = btn
        })
        
        local tabContent = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
            Parent = window.Content
        })
        New("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8)}).Parent = tabContent
        
        tab.Button = btn
        tab.Content = tabContent
        
        btn.MouseButton1Click:Connect(function() window.SelectTab(tab) end)
        btn.MouseEnter:Connect(function() if tab ~= window.CurrentTab then Tween(btn, {BackgroundTransparency = 0.3}) end end)
        btn.MouseLeave:Connect(function() if tab ~= window.CurrentTab then Tween(btn, {BackgroundTransparency = 0.5}) end end)
        
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then window.SelectTab(tab) end
        
        -- Section function
        function tab.Section(secConfig)
            secConfig = secConfig or {}
            local section = {Name = secConfig.Name or "Section"}
            
            local frame = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Aurora.Theme.BgCard,
                Parent = tab.Content
            })
            Corner(8).Parent = frame
            Stroke(Aurora.Theme.Border).Parent = frame
            local framePadding = New("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})
            framePadding.Parent = frame
            New("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8)}).Parent = frame
            
            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = section.Name,
                TextColor3 = Aurora.Theme.TextMain,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            
            section.Frame = frame
            
            -- Button
            function section.Button(btnConfig)
                btnConfig = btnConfig or {}
                local btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Aurora.Theme.Accent,
                    Text = btnConfig.Name or "Button",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    Parent = frame
                })
                Corner(6).Parent = btn
                Gradient(Aurora.Theme.GradientAccent, 0).Parent = btn
                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Aurora.Theme.AccentLight}) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Aurora.Theme.Accent}) end)
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Ripple(btn, input.Position.X - btn.AbsolutePosition.X, input.Position.Y - btn.AbsolutePosition.Y)
                        if btnConfig.Callback then btnConfig.Callback() end
                    end
                end)
                return btn
            end
            
            -- Toggle
            function section.Toggle(togConfig)
                togConfig = togConfig or {}
                local toggle = {Value = togConfig.Default or false}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = frame})
                New("TextLabel", {Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Text = togConfig.Name or "Toggle", TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = container})
                
                local toggleBtn = New("TextButton", {Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -43, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Aurora.Theme.BgInput, Text = "", Parent = container})
                Corner(10).Parent = toggleBtn
                Stroke(Aurora.Theme.Border).Parent = toggleBtn
                
                local indicator = New("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Aurora.Theme.TextMuted, Parent = toggleBtn})
                Corner(7).Parent = indicator
                
                if togConfig.Default then
                    indicator.Position = UDim2.new(1, -17, 0.5, 0)
                    indicator.BackgroundColor3 = Aurora.Theme.Cyan
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 70)
                end
                
                toggleBtn.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    if toggle.Value then
                        Tween(indicator, {Position = UDim2.new(1, -17, 0.5, 0), BackgroundColor3 = Aurora.Theme.Cyan}, 0.2)
                        Tween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(30, 60, 70)}, 0.2)
                    else
                        Tween(indicator, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Aurora.Theme.TextMuted}, 0.2)
                        Tween(toggleBtn, {BackgroundColor3 = Aurora.Theme.BgInput}, 0.2)
                    end
                    if togConfig.Callback then togConfig.Callback(toggle.Value) end
                end)
                
                return toggle
            end
            
            -- Slider
            function section.Slider(sldConfig)
                sldConfig = sldConfig or {}
                local slider = {Value = sldConfig.Default or sldConfig.Min or 0, Min = sldConfig.Min or 0, Max = sldConfig.Max or 100}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = frame})
                local headerC = New("Frame", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = container})
                New("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = sldConfig.Name or "Slider", TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = headerC})
                
                local valLabel = New("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, Text = tostring(slider.Value) .. (sldConfig.Suffix or ""), TextColor3 = Aurora.Theme.Cyan, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = headerC})
                
                local track = New("Frame", {Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5), BackgroundColor3 = Aurora.Theme.BgInput, Parent = container})
                Corner(2).Parent = track
                
                local fill = New("Frame", {Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0), BackgroundColor3 = Aurora.Theme.Accent, Parent = track})
                Corner(2).Parent = fill
                Gradient(Aurora.Theme.GradientAccent, 0).Parent = fill
                
                local knob = New("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -7, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track})
                Corner(7).Parent = knob
                Stroke(Aurora.Theme.Accent, 2).Parent = knob
                
                local dragging = false
                
                local function update(input)
                    local x = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor((slider.Min + (slider.Max - slider.Min) * x) / (sldConfig.Increment or 1) + 0.5) * (sldConfig.Increment or 1)
                    val = math.clamp(val, slider.Min, slider.Max)
                    slider.Value = val
                    valLabel.Text = tostring(val) .. (sldConfig.Suffix or "")
                    local pct = (val - slider.Min) / (slider.Max - slider.Min)
                    Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                    Tween(knob, {Position = UDim2.new(pct, -7, 0.5, 0)}, 0.05)
                    if sldConfig.Callback then sldConfig.Callback(val) end
                end
                
                track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end)
                track.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
                
                return slider
            end
            
            -- Dropdown
            function section.Dropdown(dropConfig)
                dropConfig = dropConfig or {}
                local dropdown = {Value = dropConfig.Default or dropConfig.Options[1], Options = dropConfig.Options or {}, IsOpen = false}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = frame})
                
                local btn = New("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Aurora.Theme.BgInput, Text = "", Parent = container})
                Corner(6).Parent = btn
                Stroke(Aurora.Theme.Border).Parent = btn
                
                local label = New("TextLabel", {Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = dropConfig.Name .. ": " .. dropdown.Value, TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn})
                
                local icon = New("TextLabel", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -26, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = Aurora.Theme.TextMuted, TextSize = 10, Font = Enum.Font.GothamBold, Parent = btn})
                
                local list = New("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Aurora.Theme.BgPanel, Visible = false, ZIndex = 10, Parent = container})
                Corner(6).Parent = list
                Stroke(Aurora.Theme.Border).Parent = list
                New("UIListLayout", {FillDirection = Enum.FillDirection.Vertical}).Parent = list
                
                for _, opt in ipairs(dropdown.Options) do
                    local optBtn = New("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = opt, TextColor3 = Aurora.Theme.TextSub, TextSize = 11, Font = Enum.Font.GothamMedium, Parent = list})
                    optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundColor3 = Aurora.Theme.Accent, BackgroundTransparency = 0}); optBtn.TextColor3 = Color3.new(1, 1, 1) end)
                    optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundTransparency = 1}); optBtn.TextColor3 = Aurora.Theme.TextSub end)
                    optBtn.MouseButton1Click:Connect(function()
                        dropdown.Value = opt
                        label.Text = dropConfig.Name .. ": " .. opt
                        toggleList()
                        if dropConfig.Callback then dropConfig.Callback(opt) end
                    end)
                end
                
                local function toggleList()
                    dropdown.IsOpen = not dropdown.IsOpen
                    if dropdown.IsOpen then
                        list.Visible = true
                        Tween(list, {Size = UDim2.new(1, 0, 0, #dropdown.Options * 26)}, 0.15)
                        Tween(icon, {Rotation = 180}, 0.15)
                        container.Size = UDim2.new(1, 0, 0, 36 + #dropdown.Options * 26)
                    else
                        Tween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        Tween(icon, {Rotation = 0}, 0.15)
                        task.wait(0.15)
                        list.Visible = false
                        container.Size = UDim2.new(1, 0, 0, 32)
                    end
                end
                
                btn.MouseButton1Click:Connect(toggleList)
                
                return dropdown
            end
            
            -- Keybind
            function section.Keybind(keyConfig)
                keyConfig = keyConfig or {}
                local keybind = {Key = keyConfig.Default or Enum.KeyCode.F, Listening = false}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = frame})
                New("TextLabel", {Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Text = keyConfig.Name or "Keybind", TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = container})
                
                local btn = New("TextButton", {Size = UDim2.new(0, 70, 0, 24), Position = UDim2.new(1, -75, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Aurora.Theme.BgInput, Text = keybind.Key.Name, TextColor3 = Aurora.Theme.TextSub, TextSize = 11, Font = Enum.Font.GothamBold, Parent = container})
                Corner(6).Parent = btn
                Stroke(Aurora.Theme.Border).Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    keybind.Listening = true
                    btn.Text = "..."
                    Tween(btn, {BackgroundColor3 = Aurora.Theme.Accent, TextColor3 = Color3.new(1, 1, 1)}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gp)
                    if keybind.Listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            keybind.Key = input.KeyCode
                            btn.Text = input.KeyCode.Name
                            Tween(btn, {BackgroundColor3 = Aurora.Theme.BgInput, TextColor3 = Aurora.Theme.TextSub}, 0.15)
                            keybind.Listening = false
                        end
                    elseif not gp and input.KeyCode == keybind.Key then
                        if keyConfig.Callback then keyConfig.Callback() end
                    end
                end)
                
                return keybind
            end
            
            -- Textbox
            function section.Textbox(txtConfig)
                txtConfig = txtConfig or {}
                local textbox = {Value = txtConfig.Default or ""}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = frame})
                New("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = txtConfig.Name or "Input", TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = container})
                
                local input = New("TextBox", {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = Aurora.Theme.BgInput, Text = txtConfig.Default or "", PlaceholderText = txtConfig.Placeholder or "", PlaceholderColor3 = Aurora.Theme.TextMuted, TextColor3 = Aurora.Theme.TextMain, TextSize = 11, Font = Enum.Font.Gotham, Parent = container})
                Corner(6).Parent = input
                Stroke(Aurora.Theme.Border).Parent = input
                
                input.Focused:Connect(function()
                    Tween(input, {BackgroundColor3 = Aurora.Theme.BgHover})
                    Tween(input:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Accent})
                end)
                input.FocusLost:Connect(function(enter)
                    Tween(input, {BackgroundColor3 = Aurora.Theme.BgInput})
                    Tween(input:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Border})
                    textbox.Value = input.Text
                    if txtConfig.Callback then txtConfig.Callback(input.Text, enter) end
                end)
                
                textbox.Input = input
                return textbox
            end
            
            -- ColorPicker
            function section.ColorPicker(colorConfig)
                colorConfig = colorConfig or {}
                local picker = {Value = colorConfig.Default or Color3.fromRGB(255, 255, 255), IsOpen = false}
                
                local container = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = frame})
                New("TextLabel", {Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = colorConfig.Name or "Color", TextColor3 = Aurora.Theme.TextMain, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = container})
                
                local preview = New("TextButton", {Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -55, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = picker.Value, Text = "", Parent = container})
                Corner(6).Parent = preview
                Stroke(Aurora.Theme.Border).Parent = preview
                
                local popup = New("Frame", {Size = UDim2.new(0, 180, 0, 160), Position = UDim2.new(1, -185, 1, 4), BackgroundColor3 = Aurora.Theme.BgPanel, Visible = false, ZIndex = 10, Parent = container})
                Corner(8).Parent = popup
                Stroke(Aurora.Theme.Border).Parent = popup
                
                local satVal = New("ImageLabel", {Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.new(1, 0, 0), Image = "rbxassetid://4155801252", Parent = popup})
                Corner(6).Parent = satVal
                
                local hue = New("ImageLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 1, -35), BackgroundColor3 = Color3.new(1, 1, 1), Image = "rbxassetid://3570695787", Parent = popup})
                Corner(6).Parent = hue
                
                local h, s, v = 0, 1, 1
                local selectingSV, selectingH = false, false
                
                local function update()
                    local color = Color3.fromHSV(h, s, v)
                    picker.Value = color
                    preview.BackgroundColor3 = color
                    satVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    if colorConfig.Callback then colorConfig.Callback(color) end
                end
                
                satVal.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingSV = true end end)
                satVal.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingSV = false end end)
                hue.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingH = true end end)
                hue.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingH = false end end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if selectingSV then
                            s = math.clamp((input.Position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
                            v = 1 - math.clamp((input.Position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
                            update()
                        elseif selectingH then
                            h = math.clamp((input.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
                            update()
                        end
                    end
                end)
                
                preview.MouseButton1Click:Connect(function()
                    picker.IsOpen = not picker.IsOpen
                    popup.Visible = picker.IsOpen
                    container.Size = picker.IsOpen and UDim2.new(1, 0, 0, 195) or UDim2.new(1, 0, 0, 28)
                end)
                
                return picker
            end
            
            -- Paragraph
            function section.Paragraph(paraConfig)
                paraConfig = paraConfig or {}
                
                local para = New("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Aurora.Theme.BgPanel, BackgroundTransparency = 0.5, Parent = frame})
                Corner(6).Parent = para
                local paraPadding = New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
                paraPadding.Parent = para
                
                if paraConfig.Title then
                    New("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = paraConfig.Title, TextColor3 = Aurora.Theme.Cyan, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = para})
                end
                
                New("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = paraConfig.Text or "", TextColor3 = Aurora.Theme.TextSub, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = para})
                
                return para
            end
            
            return section
        end
        
        return tab
    end
    
    -- SelectTab
    function window.SelectTab(tab)
        if window.CurrentTab then
            Tween(window.CurrentTab.Button, {BackgroundTransparency = 0.5})
            window.CurrentTab.Button:FindFirstChild("TextLabel").TextColor3 = Aurora.Theme.TextSub
            window.CurrentTab.Content.Visible = false
        end
        window.CurrentTab = tab
        Tween(tab.Button, {BackgroundTransparency = 0})
        tab.Button:FindFirstChild("TextLabel").TextColor3 = Aurora.Theme.TextMain
        tab.Content.Visible = true
    end
    
    -- Notify
    function window.Notify(notifConfig)
        notifConfig = notifConfig or {}
        local types = {info = Aurora.Theme.Cyan, success = Aurora.Theme.Green, warning = Aurora.Theme.Orange, error = Aurora.Theme.Red}
        local color = types[notifConfig.Type] or Aurora.Theme.Cyan
        
        local notif = New("Frame", {Size = UDim2.new(0, 280, 0, 60), Position = UDim2.new(1, 0, 1, -80), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Aurora.Theme.BgCard, Parent = screen})
        Corner(8).Parent = notif
        Stroke(color, 2).Parent = notif
        
        New("TextLabel", {Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = notifConfig.Title or "Notification", TextColor3 = color, TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = notif})
        New("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 1, -30), BackgroundTransparency = 1, Text = notifConfig.Content or "", TextColor3 = Aurora.Theme.TextSub, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = notif})
        
        local progress = New("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = color, Parent = notif})
        Corner(1).Parent = progress
        
        local yPos = 90
        for _, n in pairs(screen:GetChildren()) do
            if n ~= notif and n:IsA("Frame") and n.Size.X.Offset == 280 then yPos = yPos + 70 end
        end
        
        Tween(notif, {Position = UDim2.new(1, -300, 1, -yPos)}, 0.3)
        
        task.spawn(function()
            local dur = notifConfig.Duration or 4
            local start = tick()
            while tick() - start < dur do
                progress.Size = UDim2.new(1 - ((tick() - start) / dur), 0, 0, 2)
                task.wait(0.03)
            end
        end)
        
        task.delay(notifConfig.Duration or 4, function()
            Tween(notif, {Position = UDim2.new(1, 50, 1, -yPos)}, 0.3)
            task.wait(0.3)
            notif:Destroy()
        end)
        
        return notif
    end
    
    return window
end

-- Info
function Aurora.Info()
    local user = Players.LocalPlayer
    local exec = GetExecutorInfo()
    return string.format([[AURORA LIBRARY v%s

USER: %s | ID: %d | Age: %d days
EXECUTOR: %s | Version: %s
DATE: %s | TIME: %s

For Learning Purposes Only]],
        Aurora.Version, user.Name, user.UserId, math.floor(user.AccountAge / 86400),
        exec.Name, exec.Version, os.date("%d/%m/%Y"), GetTime())
end

return Aurora
