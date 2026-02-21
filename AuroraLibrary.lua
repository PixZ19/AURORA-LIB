--[[
    AURORA LIBRARY - Premium UI Framework
    Version: 2.0.0
    For Learning Purposes Only
]]--

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Aurora Library
local Aurora = {}
Aurora.Version = "2.0.0"
Aurora.Name = "Aurora Library"

-- Theme - Clean Minimalist Dark
Aurora.Theme = {
    -- Backgrounds
    BgMain = Color3.fromRGB(12, 12, 16),
    BgCard = Color3.fromRGB(18, 18, 24),
    BgPanel = Color3.fromRGB(22, 22, 30),
    BgInput = Color3.fromRGB(28, 28, 38),
    BgHover = Color3.fromRGB(35, 35, 48),
    
    -- Accents
    Accent = Color3.fromRGB(124, 77, 255),
    AccentLight = Color3.fromRGB(150, 110, 255),
    AccentDark = Color3.fromRGB(90, 50, 200),
    Cyan = Color3.fromRGB(80, 200, 255),
    Green = Color3.fromRGB(80, 220, 140),
    Orange = Color3.fromRGB(255, 160, 60),
    Red = Color3.fromRGB(255, 85, 85),
    
    -- Text
    TextMain = Color3.fromRGB(240, 240, 245),
    TextSub = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(100, 100, 120),
    
    -- Borders
    Border = Color3.fromRGB(45, 45, 60),
    BorderLight = Color3.fromRGB(60, 60, 80),
    
    -- Gradients
    GradientAccent = {
        Color3.fromRGB(124, 77, 255),
        Color3.fromRGB(80, 200, 255)
    }
}

-- Animation Config
Aurora.Config = {
    Duration = 0.25,
    Fast = 0.15,
    Slow = 0.4,
    Easing = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Utilities
local Utils = {}

function Utils:Instance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            inst.Parent = v
        else
            inst[k] = v
        end
    end
    return inst
end

function Utils:Tween(inst, props, duration)
    local info = TweenInfo.new(duration or Aurora.Config.Duration, Aurora.Config.Easing, Aurora.Config.Direction)
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

function Utils:Corner(radius)
    return self:Instance("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
end

function Utils:Stroke(color, thickness)
    return self:Instance("UIStroke", {
        Color = color or Aurora.Theme.Border,
        Thickness = thickness or 1,
        Transparency = 0
    })
end

function Utils:Padding(left, top, right, bottom)
    return self:Instance("UIPadding", {
        PaddingLeft = UDim.new(0, left or 12),
        PaddingTop = UDim.new(0, top or 12),
        PaddingRight = UDim.new(0, right or 12),
        PaddingBottom = UDim.new(0, bottom or 12)
    })
end

function Utils:Gradient(colors, rotation)
    local keypoints = {}
    for i, color in ipairs(colors) do
        local t = (i - 1) / math.max(1, #colors - 1)
        table.insert(keypoints, ColorSequenceKeypoint.new(t, color))
    end
    return self:Instance("UIGradient", {
        Color = ColorSequence.new(keypoints),
        Rotation = rotation or 90
    })
end

function Utils:Time()
    local t = os.date("*t")
    local h = t.hour
    local ampm = "AM"
    if h >= 12 then ampm = "PM"; if h > 12 then h = h - 12 end end
    if h == 0 then h = 12 end
    return string.format("%02d:%02d:%02d %s", h, t.min, t.sec, ampm)
end

function Utils:Date()
    return os.date("%d/%m/%Y")
end

function Utils:ExecutorInfo()
    local info = {Name = "Unknown", Version = "Unknown", Caps = {}}
    local ok, name, ver = pcall(function()
        if identifyexecutor then return identifyexecutor() end
        return nil, nil
    end)
    if ok and name then info.Name = name; info.Version = ver or "Unknown" end
    
    local caps = {"Drawing", "getgenv", "getrenv", "getgc", "hookfunction", "firesignal", "syn", "queueonteleport"}
    for _, cap in ipairs(caps) do
        local success = pcall(function()
            return _G[cap] or getfenv()[cap]
        end)
        if success then table.insert(info.Caps, cap) end
    end
    return info
end

-- Ripple Effect
function Utils:Ripple(btn, x, y)
    local ripple = self:Instance("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = btn
    })
    self:Corner(100).Parent = ripple
    
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    self:Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
    task.delay(0.5, function() ripple:Destroy() end)
end

-- Loading Screen
function Aurora:LoadingScreen(config)
    config = config or {}
    local duration = config.Duration or 3
    local onComplete = config.OnComplete or function() end
    
    local screen = self:Instance("ScreenGui", {
        Name = "AuroraLoading",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Background
    local bg = self:Instance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = screen
    })
    self:Corner(0).Parent = bg
    
    -- Gradient overlay
    local gradientBg = self:Instance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = bg
    })
    local gradientAnim = self:Gradient(Aurora.Theme.GradientAccent, 135)
    gradientAnim.Parent = gradientBg
    
    -- Animate gradient
    task.spawn(function()
        while screen and screen.Parent do
            for r = 0, 360 do
                gradientAnim.Rotation = r
                task.wait(0.02)
            end
        end
    end)
    
    -- Center container
    local center = self:Instance("Frame", {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = bg
    })
    
    -- Logo text
    local logo = self:Instance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "AURORA",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 48,
        Font = Enum.Font.GothamBlack,
        Parent = center
    })
    self:Gradient(Aurora.Theme.GradientAccent, 0).Parent = logo
    
    -- Tagline
    local tagline = self:Instance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 75),
        BackgroundTransparency = 1,
        Text = config.Subtitle or "Loading...",
        TextColor3 = Aurora.Theme.TextSub,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Parent = center
    })
    
    -- Progress bar background
    local progressBg = self:Instance("Frame", {
        Size = UDim2.new(0.8, 0, 0, 4),
        Position = UDim2.new(0.1, 0, 0, 130),
        BackgroundColor3 = Aurora.Theme.BgInput,
        Parent = center
    })
    self:Corner(2).Parent = progressBg
    
    -- Progress bar fill
    local progressFill = self:Instance("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = progressBg
    })
    self:Corner(2).Parent = progressFill
    self:Gradient(Aurora.Theme.GradientAccent, 0).Parent = progressFill
    
    -- Percentage text
    local percentText = self:Instance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 145),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = center
    })
    
    -- Status text
    local statusText = self:Instance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 170),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Aurora.Theme.TextSub,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = center
    })
    
    -- Version footer
    local footer = self:Instance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Text = "Aurora Library v" .. self.Version .. " | Learning Purpose Only",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = bg
    })
    
    -- Loading animation
    local statuses = {
        "Initializing...",
        "Loading Components...",
        "Setting Up Interface...",
        "Configuring Theme...",
        "Preparing UI...",
        "Almost Ready...",
        "Welcome!"
    }
    
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
        self:Tween(bg, {BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        screen:Destroy()
        onComplete()
    end)
    
    return screen
end

-- Window
function Aurora:Window(config)
    config = config or {}
    
    local window = {
        Title = config.Title or "Aurora",
        Size = config.Size or UDim2.new(0, 580, 0, 400),
        Tabs = {},
        CurrentTab = nil,
        Dragging = false,
        DragOffset = Vector2.new()
    }
    
    -- ScreenGui
    local screen = self:Instance("ScreenGui", {
        Name = "AuroraWindow",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    window.Screen = screen
    
    -- Main Frame
    local main = self:Instance("Frame", {
        Name = "Main",
        Size = window.Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = screen
    })
    self:Corner(10).Parent = main
    self:Stroke(Aurora.Theme.Border).Parent = main
    
    -- Glow effect
    local glow = self:Instance("ImageLabel", {
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
    
    -- Animate glow
    task.spawn(function()
        local t = 0.85
        local d = 1
        while screen and screen.Parent do
            t = t + d * 0.008
            if t <= 0.7 then d = 1 elseif t >= 0.95 then d = -1 end
            glow.ImageTransparency = t
            task.wait(0.03)
        end
    end)
    
    -- Header
    local header = self:Instance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgCard,
        Parent = main
    })
    local headerCorner = self:Corner(10)
    headerCorner.Parent = header
    
    -- Fix header bottom corners
    local headerFix = self:Instance("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Aurora.Theme.BgCard,
        BorderSizePixel = 0,
        Parent = header
    })
    
    -- Accent line under header
    local accentLine = self:Instance("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = header
    })
    self:Gradient(Aurora.Theme.GradientAccent, 0).Parent = accentLine
    
    -- Logo icon
    local logoIcon = self:Instance("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10886031167",
        ImageColor3 = Aurora.Theme.Cyan,
        Parent = header
    })
    
    -- Title
    local title = self:Instance("TextLabel", {
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
    
    -- Window controls
    local controls = self:Instance("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1,
        Parent = header
    })
    self:Instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6)
    }).Parent = controls
    
    -- Control buttons
    local btnSize = UDim2.new(0, 26, 0, 26)
    local function ctrlBtn(text, callback)
        local btn = self:Instance("TextButton", {
            Size = btnSize,
            BackgroundColor3 = Aurora.Theme.BgInput,
            BackgroundTransparency = 0.5,
            Text = text,
            TextColor3 = Aurora.Theme.TextSub,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            Parent = controls
        })
        self:Corner(6).Parent = btn
        
        btn.MouseEnter:Connect(function()
            self:Tween(btn, {BackgroundTransparency = 0})
            if text == "X" then
                btn.BackgroundColor3 = Aurora.Theme.Red
                btn.TextColor3 = Color3.new(1, 1, 1)
            end
        end)
        btn.MouseLeave:Connect(function()
            self:Tween(btn, {BackgroundTransparency = 0.5})
            btn.BackgroundColor3 = Aurora.Theme.BgInput
            btn.TextColor3 = Aurora.Theme.TextSub
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local minBtn = ctrlBtn("-", function()
        if window.Minimized then
            self:Tween(main, {Size = window.Size}, 0.25)
            minBtn.Text = "-"
        else
            self:Tween(main, {Size = UDim2.new(window.Size.X.Offset, 0, 0, 50)}, 0.25)
            minBtn.Text = "+"
        end
        window.Minimized = not window.Minimized
    end)
    
    ctrlBtn("[]", function()
        if window.Maximized then
            main.AnchorPoint = Vector2.new(0, 0)
            self:Tween(main, {Size = window.Size, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.25)
            main.AnchorPoint = Vector2.new(0.5, 0.5)
        else
            self:Tween(main, {Size = UDim2.new(0.85, 0, 0.85, 0)}, 0.25)
        end
        window.Maximized = not window.Maximized
    end)
    
    ctrlBtn("X", function()
        self:Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        screen:Destroy()
    end)
    
    -- Sidebar
    local sidebar = self:Instance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgCard,
        Parent = main
    })
    self:Corner(0).Parent = sidebar
    
    -- Tab list
    local tabList = self:Instance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -100),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar
    })
    self:Padding(8, 8, 8, 8).Parent = tabList
    self:Instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4)
    }).Parent = tabList
    
    -- User card at bottom of sidebar
    local userCard = self:Instance("Frame", {
        Size = UDim2.new(1, -16, 0, 85),
        Position = UDim2.new(0, 8, 1, -93),
        BackgroundColor3 = Aurora.Theme.BgPanel,
        Parent = sidebar
    })
    self:Corner(8).Parent = userCard
    self:Stroke(Aurora.Theme.Border).Parent = userCard
    
    -- User avatar
    local avatarBg = self:Instance("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Aurora.Theme.BgInput,
        Parent = userCard
    })
    self:Corner(6).Parent = avatarBg
    
    local avatar = self:Instance("ImageLabel", {
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
        Parent = avatarBg
    })
    self:Corner(4).Parent = avatar
    
    -- Username
    local username = self:Instance("TextLabel", {
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
    
    -- User ID
    local userId = self:Instance("TextLabel", {
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
    
    -- Time display
    local timeLabel = self:Instance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 1, -26),
        BackgroundTransparency = 1,
        Text = Utils:Time(),
        TextColor3 = Aurora.Theme.Cyan,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userCard
    })
    
    task.spawn(function()
        while screen and screen.Parent do
            timeLabel.Text = Utils:Time()
            task.wait(1)
        end
    end)
    
    -- Content area
    local content = self:Instance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -140, 1, -50),
        Position = UDim2.new(0, 140, 0, 50),
        BackgroundColor3 = Aurora.Theme.BgMain,
        Parent = main
    })
    
    local contentScroll = self:Instance("ScrollingFrame", {
        Size = UDim2.new(1, -24, 1, -16),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Aurora.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = content
    })
    self:Padding(0, 0, 0, 8).Parent = contentScroll
    self:Instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8)
    }).Parent = contentScroll
    
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = false
        end
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
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)
    
    -- Create Tab
    function window:Tab(config)
        config = config or {}
        local tab = {Name = config.Name or "Tab", Icon = config.Icon or "", Window = window}
        
        local btn = Utils:Instance("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Aurora.Theme.BgPanel,
            BackgroundTransparency = 0.5,
            Text = "",
            Parent = window.TabList
        })
        Utils:Corner(6).Parent = btn
        
        local label = Utils:Instance("TextLabel", {
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
        
        -- Tab content
        local tabContent = Utils:Instance("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = false,
            Parent = window.Content
        })
        Utils:Instance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 8)
        }).Parent = tabContent
        
        tab.Button = btn
        tab.Content = tabContent
        
        btn.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)
        
        btn.MouseEnter:Connect(function()
            if tab ~= window.CurrentTab then
                Utils:Tween(btn, {BackgroundTransparency = 0.3})
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if tab ~= window.CurrentTab then
                Utils:Tween(btn, {BackgroundTransparency = 0.5})
            end
        end)
        
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then window:SelectTab(tab) end
        
        -- Section
        function tab:Section(config)
            config = config or {}
            local section = {Name = config.Name or "Section"}
            
            local frame = Utils:Instance("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Aurora.Theme.BgCard,
                Parent = tab.Content
            })
            Utils:Corner(8).Parent = frame
            Utils:Stroke(Aurora.Theme.Border).Parent = frame
            Utils:Padding(12, 12, 12, 12).Parent = frame
            
            local list = Utils:Instance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 8)
            })
            list.Parent = frame
            
            -- Section title
            local title = Utils:Instance("TextLabel", {
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
            function section:Button(config)
                config = config or {}
                local btn = Utils:Instance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Aurora.Theme.Accent,
                    Text = config.Name or "Button",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    Parent = frame
                })
                Utils:Corner(6).Parent = btn
                Utils:Gradient(Aurora.Theme.GradientAccent, 0).Parent = btn
                
                btn.MouseEnter:Connect(function()
                    Utils:Tween(btn, {BackgroundColor3 = Aurora.Theme.AccentLight})
                end)
                btn.MouseLeave:Connect(function()
                    Utils:Tween(btn, {BackgroundColor3 = Aurora.Theme.Accent})
                end)
                
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Utils:Ripple(btn, input.Position.X - btn.AbsolutePosition.X, input.Position.Y - btn.AbsolutePosition.Y)
                        if config.Callback then config.Callback() end
                    end
                end)
                
                return btn
            end
            
            -- Toggle
            function section:Toggle(config)
                config = config or {}
                local toggle = {Value = config.Default or false}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Toggle",
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local toggleBtn = Utils:Instance("TextButton", {
                    Size = UDim2.new(0, 38, 0, 20),
                    Position = UDim2.new(1, -43, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.BgInput,
                    Text = "",
                    Parent = container
                })
                Utils:Corner(10).Parent = toggleBtn
                Utils:Stroke(Aurora.Theme.Border).Parent = toggleBtn
                
                local indicator = Utils:Instance("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.TextMuted,
                    Parent = toggleBtn
                })
                Utils:Corner(7).Parent = indicator
                
                if config.Default then
                    indicator.Position = UDim2.new(1, -17, 0.5, 0)
                    indicator.BackgroundColor3 = Aurora.Theme.Cyan
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 70)
                end
                
                toggleBtn.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    if toggle.Value then
                        Utils:Tween(indicator, {Position = UDim2.new(1, -17, 0.5, 0), BackgroundColor3 = Aurora.Theme.Cyan}, 0.2)
                        Utils:Tween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(30, 60, 70)}, 0.2)
                    else
                        Utils:Tween(indicator, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Aurora.Theme.TextMuted}, 0.2)
                        Utils:Tween(toggleBtn, {BackgroundColor3 = Aurora.Theme.BgInput}, 0.2)
                    end
                    if config.Callback then config.Callback(toggle.Value) end
                end)
                
                return toggle
            end
            
            -- Slider
            function section:Slider(config)
                config = config or {}
                local slider = {Value = config.Default or config.Min or 0, Min = config.Min or 0, Max = config.Max or 100}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local header = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = container
                })
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Slider",
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = header
                })
                
                local valLabel = Utils:Instance("TextLabel", {
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(slider.Value) .. (config.Suffix or ""),
                    TextColor3 = Aurora.Theme.Cyan,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = header
                })
                
                local track = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 1, -5),
                    BackgroundColor3 = Aurora.Theme.BgInput,
                    Parent = container
                })
                Utils:Corner(2).Parent = track
                
                local fill = Utils:Instance("Frame", {
                    Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
                    BackgroundColor3 = Aurora.Theme.Accent,
                    Parent = track
                })
                Utils:Corner(2).Parent = fill
                Utils:Gradient(Aurora.Theme.GradientAccent, 0).Parent = fill
                
                local knob = Utils:Instance("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -7, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = track
                })
                Utils:Corner(7).Parent = knob
                Utils:Stroke(Aurora.Theme.Accent, 2).Parent = knob
                
                local dragging = false
                
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                
                function update(input)
                    local x = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor((slider.Min + (slider.Max - slider.Min) * x) / (config.Increment or 1) + 0.5) * (config.Increment or 1)
                    val = math.clamp(val, slider.Min, slider.Max)
                    slider.Value = val
                    valLabel.Text = tostring(val) .. (config.Suffix or "")
                    local pct = (val - slider.Min) / (slider.Max - slider.Min)
                    Utils:Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
                    Utils:Tween(knob, {Position = UDim2.new(pct, -7, 0.5, 0)}, 0.05)
                    if config.Callback then config.Callback(val) end
                end
                
                return slider
            end
            
            -- Dropdown
            function section:Dropdown(config)
                config = config or {}
                local dropdown = {Value = config.Default or config.Options[1], Options = config.Options or {}, IsOpen = false}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local btn = Utils:Instance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Aurora.Theme.BgInput,
                    Text = "",
                    Parent = container
                })
                Utils:Corner(6).Parent = btn
                Utils:Stroke(Aurora.Theme.Border).Parent = btn
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name .. ": " .. dropdown.Value,
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = btn
                })
                
                local icon = Utils:Instance("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -26, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "v",
                    TextColor3 = Aurora.Theme.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Parent = btn
                })
                
                local list = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Aurora.Theme.BgPanel,
                    Visible = false,
                    ZIndex = 10,
                    Parent = container
                })
                Utils:Corner(6).Parent = list
                Utils:Stroke(Aurora.Theme.Border).Parent = list
                
                local listLayout = Utils:Instance("UIListLayout", {FillDirection = Enum.FillDirection.Vertical})
                listLayout.Parent = list
                
                for _, opt in ipairs(dropdown.Options) do
                    local optBtn = Utils:Instance("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = Aurora.Theme.TextSub,
                        TextSize = 11,
                        Font = Enum.Font.GothamMedium,
                        Parent = list
                    })
                    optBtn.MouseEnter:Connect(function()
                        Utils:Tween(optBtn, {BackgroundColor3 = Aurora.Theme.Accent, BackgroundTransparency = 0})
                        optBtn.TextColor3 = Color3.new(1, 1, 1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Utils:Tween(optBtn, {BackgroundTransparency = 1})
                        optBtn.TextColor3 = Aurora.Theme.TextSub
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        dropdown.Value = opt
                        label.Text = config.Name .. ": " .. opt
                        toggleList()
                        if config.Callback then config.Callback(opt) end
                    end)
                end
                
                function toggleList()
                    dropdown.IsOpen = not dropdown.IsOpen
                    if dropdown.IsOpen then
                        list.Visible = true
                        Utils:Tween(list, {Size = UDim2.new(1, 0, 0, #dropdown.Options * 26)}, 0.15)
                        Utils:Tween(icon, {Rotation = 180}, 0.15)
                        container.Size = UDim2.new(1, 0, 0, 36 + #dropdown.Options * 26)
                    else
                        Utils:Tween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        Utils:Tween(icon, {Rotation = 0}, 0.15)
                        task.wait(0.15)
                        list.Visible = false
                        container.Size = UDim2.new(1, 0, 0, 32)
                    end
                end
                
                btn.MouseButton1Click:Connect(toggleList)
                
                return dropdown
            end
            
            -- Keybind
            function section:Keybind(config)
                config = config or {}
                local keybind = {Key = config.Default or Enum.KeyCode.F, Listening = false}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, -80, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Keybind",
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local btn = Utils:Instance("TextButton", {
                    Size = UDim2.new(0, 70, 0, 24),
                    Position = UDim2.new(1, -75, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.BgInput,
                    Text = keybind.Key.Name,
                    TextColor3 = Aurora.Theme.TextSub,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = container
                })
                Utils:Corner(6).Parent = btn
                Utils:Stroke(Aurora.Theme.Border).Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    keybind.Listening = true
                    btn.Text = "..."
                    Utils:Tween(btn, {BackgroundColor3 = Aurora.Theme.Accent, TextColor3 = Color3.new(1, 1, 1)}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gp)
                    if keybind.Listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            keybind.Key = input.KeyCode
                            btn.Text = input.KeyCode.Name
                            Utils:Tween(btn, {BackgroundColor3 = Aurora.Theme.BgInput, TextColor3 = Aurora.Theme.TextSub}, 0.15)
                            keybind.Listening = false
                        end
                    elseif not gp and input.KeyCode == keybind.Key then
                        if config.Callback then config.Callback() end
                    end
                end)
                
                return keybind
            end
            
            -- Textbox
            function section:Textbox(config)
                config = config or {}
                local textbox = {Value = config.Default or ""}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Input",
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local input = Utils:Instance("TextBox", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Aurora.Theme.BgInput,
                    Text = config.Default or "",
                    PlaceholderText = config.Placeholder or "",
                    PlaceholderColor3 = Aurora.Theme.TextMuted,
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    Parent = container
                })
                Utils:Corner(6).Parent = input
                Utils:Stroke(Aurora.Theme.Border).Parent = input
                
                input.Focused:Connect(function()
                    Utils:Tween(input, {BackgroundColor3 = Aurora.Theme.BgHover})
                    Utils:Tween(input:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Accent})
                end)
                
                input.FocusLost:Connect(function(enter)
                    Utils:Tween(input, {BackgroundColor3 = Aurora.Theme.BgInput})
                    Utils:Tween(input:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Border})
                    textbox.Value = input.Text
                    if config.Callback then config.Callback(input.Text, enter) end
                end)
                
                textbox.Input = input
                return textbox
            end
            
            -- ColorPicker
            function section:ColorPicker(config)
                config = config or {}
                local picker = {Value = config.Default or Color3.fromRGB(255, 255, 255), IsOpen = false}
                
                local container = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                
                local label = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Name or "Color",
                    TextColor3 = Aurora.Theme.TextMain,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container
                })
                
                local preview = Utils:Instance("TextButton", {
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -55, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = picker.Value,
                    Text = "",
                    Parent = container
                })
                Utils:Corner(6).Parent = preview
                Utils:Stroke(Aurora.Theme.Border).Parent = preview
                
                local popup = Utils:Instance("Frame", {
                    Size = UDim2.new(0, 180, 0, 160),
                    Position = UDim2.new(1, -185, 1, 4),
                    BackgroundColor3 = Aurora.Theme.BgPanel,
                    Visible = false,
                    ZIndex = 10,
                    Parent = container
                })
                Utils:Corner(8).Parent = popup
                Utils:Stroke(Aurora.Theme.Border).Parent = popup
                
                local satVal = Utils:Instance("ImageLabel", {
                    Size = UDim2.new(1, -20, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    Image = "rbxassetid://4155801252",
                    Parent = popup
                })
                Utils:Corner(6).Parent = satVal
                
                local hue = Utils:Instance("ImageLabel", {
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 1, -35),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Image = "rbxassetid://3570695787",
                    Parent = popup
                })
                Utils:Corner(6).Parent = hue
                
                local h, s, v = 0, 1, 1
                local selectingSV = false
                local selectingH = false
                
                local function update()
                    local color = Color3.fromHSV(h, s, v)
                    picker.Value = color
                    preview.BackgroundColor3 = color
                    satVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    if config.Callback then config.Callback(color) end
                end
                
                satVal.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingSV = true end
                end)
                satVal.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingSV = false end
                end)
                hue.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingH = true end
                end)
                hue.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then selectingH = false end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if selectingSV then
                            local rx = math.clamp((input.Position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
                            local ry = math.clamp((input.Position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
                            s, v = rx, 1 - ry
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
                    if picker.IsOpen then
                        container.Size = UDim2.new(1, 0, 0, 195)
                    else
                        container.Size = UDim2.new(1, 0, 0, 28)
                    end
                end)
                
                return picker
            end
            
            -- Paragraph
            function section:Paragraph(config)
                config = config or {}
                
                local para = Utils:Instance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Aurora.Theme.BgPanel,
                    BackgroundTransparency = 0.5,
                    Parent = frame
                })
                Utils:Corner(6).Parent = para
                Utils:Padding(10, 10, 10, 10).Parent = para
                
                if config.Title then
                    local title = Utils:Instance("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        Text = config.Title,
                        TextColor3 = Aurora.Theme.Cyan,
                        TextSize = 12,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = para
                    })
                end
                
                local text = Utils:Instance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = config.Text or "",
                    TextColor3 = Aurora.Theme.TextSub,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = para
                })
                
                return para
            end
            
            return section
        end
        
        return tab
    end
    
    -- Select Tab
    function window:SelectTab(tab)
        if self.CurrentTab then
            Utils:Tween(self.CurrentTab.Button, {BackgroundTransparency = 0.5})
            self.CurrentTab.Button:FindFirstChild("TextLabel").TextColor3 = Aurora.Theme.TextSub
            self.CurrentTab.Content.Visible = false
        end
        
        self.CurrentTab = tab
        Utils:Tween(tab.Button, {BackgroundTransparency = 0})
        tab.Button:FindFirstChild("TextLabel").TextColor3 = Aurora.Theme.TextMain
        tab.Content.Visible = true
    end
    
    -- Notify
    function window:Notify(config)
        config = config or {}
        local types = {info = Aurora.Theme.Cyan, success = Aurora.Theme.Green, warning = Aurora.Theme.Orange, error = Aurora.Theme.Red}
        local color = types[config.Type] or Aurora.Theme.Cyan
        
        local notif = Utils:Instance("Frame", {
            Size = UDim2.new(0, 280, 0, 60),
            Position = UDim2.new(1, 0, 1, -80),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Aurora.Theme.BgCard,
            Parent = screen
        })
        Utils:Corner(8).Parent = notif
        Utils:Stroke(color, 2).Parent = notif
        
        local title = Utils:Instance("TextLabel", {
            Size = UDim2.new(1, -20, 0, 18),
            Position = UDim2.new(0, 12, 0, 10),
            BackgroundTransparency = 1,
            Text = config.Title or "Notification",
            TextColor3 = color,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
        
        local content = Utils:Instance("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 12, 1, -30),
            BackgroundTransparency = 1,
            Text = config.Content or "",
            TextColor3 = Aurora.Theme.TextSub,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = notif
        })
        
        local progress = Utils:Instance("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = color,
            Parent = notif
        })
        Utils:Corner(1).Parent = progress
        
        local yPos = 90
        for _, n in pairs(screen:GetChildren()) do
            if n ~= notif and n.Name == "" and n.Size.X.Offset == 280 then
                yPos = yPos + 70
            end
        end
        
        Utils:Tween(notif, {Position = UDim2.new(1, -300, 1, -yPos)}, 0.3)
        
        task.spawn(function()
            local dur = config.Duration or 4
            local start = tick()
            while tick() - start < dur do
                local p = 1 - ((tick() - start) / dur)
                progress.Size = UDim2.new(p, 0, 0, 2)
                task.wait(0.03)
            end
        end)
        
        task.delay(config.Duration or 4, function()
            Utils:Tween(notif, {Position = UDim2.new(1, 50, 1, -yPos)}, 0.3)
            task.wait(0.3)
            notif:Destroy()
        end)
        
        return notif
    end
    
    return window
end

-- Get Info Card
function Aurora:Info()
    local user = Players.LocalPlayer
    local exec = Utils:ExecutorInfo()
    return string.format([[
====================================
        AURORA LIBRARY v%s
====================================

USER INFO
  Username: %s
  Display: %s
  ID: %d
  Age: %d days
  Membership: %s

EXECUTOR INFO
  Name: %s
  Version: %s
  Capabilities: %d

SYSTEM
  Date: %s
  Time: %s

====================================
     For Learning Purposes Only
====================================
]], self.Version, user.Name, user.DisplayName, user.UserId, math.floor(user.AccountAge / 86400), user.MembershipType.Name, exec.Name, exec.Version, #exec.Caps, Utils:Date(), Utils:Time())
end

return Aurora
