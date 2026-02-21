-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Constants & Configuration
local Aurora = {}

Aurora.Version = "1.0.0"
Aurora.Name = "Aurora Library"

-- Theme Configuration (Premium Dark Theme with Aurora Borealis Accents)
Aurora.Theme = {
    -- Background Colors
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundSecondary = Color3.fromRGB(20, 20, 35),
    BackgroundTertiary = Color3.fromRGB(25, 25, 45),
    BackgroundAccent = Color3.fromRGB(30, 30, 55),
    
    -- Accent Colors (Aurora Borealis Gradient)
    Accent = Color3.fromRGB(138, 43, 226),         -- Purple
    AccentSecondary = Color3.fromRGB(0, 206, 209), -- Cyan
    AccentTertiary = Color3.fromRGB(255, 20, 147), -- Pink
    AccentSuccess = Color3.fromRGB(0, 255, 127),   -- Green
    AccentWarning = Color3.fromRGB(255, 165, 0),   -- Orange
    AccentDanger = Color3.fromRGB(255, 69, 58),    -- Red
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    
    -- UI Elements
    Border = Color3.fromRGB(60, 60, 90),
    BorderLight = Color3.fromRGB(80, 80, 120),
    Shadow = Color3.fromRGB(0, 0, 0),
    
    -- Gradients
    GradientPrimary = {
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(0, 206, 209)
    },
    GradientAurora = {
        Color3.fromRGB(0, 206, 209),
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(255, 20, 147)
    }
}

-- Animation Configuration
Aurora.AnimationConfig = {
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
    DefaultDuration = 0.3,
    FastDuration = 0.15,
    SlowDuration = 0.5
}

-- Utility Functions
local Utilities = {}

function Utilities:Create(class, properties, children)
    local instance = Instance.new(class)
    
    for prop, value in pairs(properties or {}) do
        if prop == "Parent" then
            instance.Parent = value
        else
            instance[prop] = value
        end
    end
    
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    
    return instance
end

function Utilities:Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or Aurora.AnimationConfig.DefaultDuration,
        easingStyle or Aurora.AnimationConfig.EasingStyle,
        easingDirection or Aurora.AnimationConfig.EasingDirection
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utilities:CreateGradient(colors, rotation)
    -- Convert Color3 array to ColorSequenceKeypoints
    local keypoints = {}
    
    if type(colors) == "table" then
        for i, color in ipairs(colors) do
            local time = (i - 1) / (#colors - 1)
            table.insert(keypoints, ColorSequenceKeypoint.new(time, color))
        end
    else
        -- If single Color3, create simple gradient
        return self:Create("UIGradient", {
            Color = ColorSequence.new(colors),
            Rotation = rotation or 90
        })
    end
    
    return self:Create("UIGradient", {
        Color = ColorSequence.new(keypoints),
        Rotation = rotation or 90
    })
end

function Utilities:CreateCorner(radius)
    return self:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    })
end

function Utilities:CreateStroke(color, thickness, transparency)
    return self:Create("UIStroke", {
        Color = color or Aurora.Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    })
end

function Utilities:CreatePadding(paddingLeft, paddingTop, paddingRight, paddingBottom)
    return self:Create("UIPadding", {
        PaddingLeft = UDim.new(0, paddingLeft or 10),
        PaddingTop = UDim.new(0, paddingTop or 10),
        PaddingRight = UDim.new(0, paddingRight or 10),
        PaddingBottom = UDim.new(0, paddingBottom or 10)
    })
end

function Utilities:CreateListLayout(fillDirection, padding, horizontalAlignment)
    return self:Create("UIListLayout", {
        FillDirection = fillDirection or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, padding or 8),
        HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left
    })
end

function Utilities:CreateFlex(fillDirection, padding)
    return self:Create("UIFlex", {
        Mode = Enum.UIFlexMode.Fill,
        FillDirection = fillDirection or Enum.UIFlexDirection.Horizontal,
        ItemLineAlignment = Enum.ItemLineAlignment.Center,
        Gap = UDim.new(0, padding or 10)
    })
end

function Utilities:Round(number, decimalPlaces)
    local multiplier = 10 ^ (decimalPlaces or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function Utilities:GetTime()
    local time = os.date("*t")
    local hour = time.hour
    local ampm = "AM"
    
    if hour >= 12 then
        ampm = "PM"
        if hour > 12 then
            hour = hour - 12
        end
    elseif hour == 0 then
        hour = 12
    end
    
    return string.format("%02d:%02d:%02d %s", hour, time.min, time.sec, ampm)
end

function Utilities:GetDate()
    return os.date("%d/%m/%Y")
end

function Utilities:GetUserInfo()
    local player = Players.LocalPlayer
    return {
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        AccountAge = player.AccountAge,
        AccountAgeDays = math.floor(player.AccountAge / 86400),
        Membership = player.MembershipType.Name,
        CharacterAppearanceId = player.CharacterAppearanceId
    }
end

function Utilities:GetExecutorInfo()
    local executorInfo = {
        Name = "Unknown",
        Version = "Unknown",
        Capabilities = {}
    }
    
    -- Detect executor
    if identifyexecutor then
        local name, version = identifyexecutor()
        executorInfo.Name = name or "Unknown"
        executorInfo.Version = version or "Unknown"
    end
    
    -- Check capabilities
    local capabilities = {
        {Name = "Drawing", Check = function() return Drawing ~= nil end},
        {Name = "getgenv", Check = function() return getgenv ~= nil end},
        {Name = "getrenv", Check = function() return getrenv ~= nil end},
        {Name = "getgc", Check = function() return getgc ~= nil end},
        {Name = "getinstances", Check = function() return getinstances ~= nil end},
        {Name = "getnilinstances", Check = function() return getnilinstances ~= nil end},
        {Name = "firesignal", Check = function() return firesignal ~= nil end},
        {Name = "hookfunction", Check = function() return hookfunction ~= nil end},
        {Name = "syn", Check = function() return syn ~= nil end},
        {Name = "queueonteleport", Check = function() return queueonteleport ~= nil end}
    }
    
    for _, cap in pairs(capabilities) do
        local success, result = pcall(cap.Check)
        if success and result then
            table.insert(executorInfo.Capabilities, cap.Name)
        end
    end
    
    return executorInfo
end

-- Animation Functions
local Animations = {}

function Animations:Pulse(instance, scale, duration)
    local originalSize = instance.Size
    local tween1 = Utilities:Tween(instance, {Size = originalSize + UDim2.new(0, scale, 0, scale)}, duration / 2)
    tween1.Completed:Connect(function()
        Utilities:Tween(instance, {Size = originalSize}, duration / 2)
    end)
end

function Animations:FadeIn(instance, duration)
    instance.Transparency = 1
    Utilities:Tween(instance, {Transparency = 0}, duration or 0.3)
end

function Animations:FadeOut(instance, duration, callback)
    local tween = Utilities:Tween(instance, {Transparency = 1}, duration or 0.3)
    if callback then
        tween.Completed:Connect(callback)
    end
end

function Animations:SlideIn(instance, direction, distance, duration)
    local originalPosition = instance.Position
    local startPosition = originalPosition
    
    if direction == "Left" then
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset - distance, originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif direction == "Right" then
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + distance, originalPosition.Y.Scale, originalPosition.Y.Offset)
    elseif direction == "Top" then
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, originalPosition.Y.Scale, originalPosition.Y.Offset - distance)
    elseif direction == "Bottom" then
        startPosition = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, originalPosition.Y.Scale, originalPosition.Y.Offset + distance)
    end
    
    instance.Position = startPosition
    Utilities:Tween(instance, {Position = originalPosition}, duration or 0.4)
end

function Animations:Glow(instance, color, duration, loops)
    local stroke = instance:FindFirstChildOfClass("UIStroke") or Utilities:CreateStroke(color, 2, 1)
    stroke.Parent = instance
    
    spawn(function()
        local loopCount = 0
        while loops == -1 or loopCount < (loops or 1) do
            Utilities:Tween(stroke, {Transparency = 0}, duration / 2)
            wait(duration / 2)
            Utilities:Tween(stroke, {Transparency = 1}, duration / 2)
            wait(duration / 2)
            loopCount = loopCount + 1
        end
    end)
end

function Animations:Typewriter(textLabel, text, speed)
    textLabel.Text = ""
    for i = 1, #text do
        textLabel.Text = string.sub(text, 1, i)
        wait(speed or 0.03)
    end
end

function Animations:Shake(instance, intensity, duration)
    local originalPosition = instance.Position
    local elapsed = 0
    
    spawn(function()
        while elapsed < duration do
            local offsetX = math.random(-intensity, intensity)
            local offsetY = math.random(-intensity, intensity)
            instance.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + offsetX, originalPosition.Y.Scale, originalPosition.Y.Offset + offsetY)
            wait(0.02)
            elapsed = elapsed + 0.02
        end
        instance.Position = originalPosition
    end)
end

-- Ripple Effect
function Animations:Ripple(button, x, y, color)
    local ripple = Utilities:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = color or Color3.new(1, 1, 1),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = button
    }, {
        Utilities:CreateCorner(100)
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    Utilities:Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.5)
    
    delay(0.5, function()
        ripple:Destroy()
    end)
end

-- Loading Screen System
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function Aurora:CreateLoadingScreen(config)
    config = config or {}
    
    local loadingScreen = {
        Title = config.Title or "Aurora Library",
        Subtitle = config.Subtitle or "Loading...",
        Logo = config.Logo or "AURORA",
        Duration = config.Duration or 3,
        BackgroundMusic = config.BackgroundMusic,
        OnComplete = config.OnComplete or function() end,
        Elements = {}
    }
    
    -- Create ScreenGui
    local ScreenGui = Utilities:Create("ScreenGui", {
        Name = "AuroraLoadingScreen",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    loadingScreen.ScreenGui = ScreenGui
    
    -- Background
    local Background = Utilities:Create("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Aurora.Theme.Background,
        Parent = ScreenGui
    }, {
        Utilities:CreateCorner(0)
    })
    
    -- Animated Background Gradient
    local BackgroundGradient = Utilities:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Aurora.Theme.BackgroundTertiary),
            ColorSequenceKeypoint.new(0.5, Aurora.Theme.BackgroundSecondary),
            ColorSequenceKeypoint.new(1, Aurora.Theme.BackgroundTertiary)
        }),
        Rotation = 45,
        Parent = Background
    })
    
    -- Animate background gradient
    spawn(function()
        local rotation = 45
        while ScreenGui and ScreenGui.Parent do
            rotation = rotation + 0.5
            if rotation >= 360 then rotation = 0 end
            BackgroundGradient.Rotation = rotation
            wait(0.03)
        end
    end)
    
    -- Particle Effects Container
    local ParticlesContainer = Utilities:Create("Frame", {
        Name = "Particles",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = Background
    })
    
    -- Create floating particles
    spawn(function()
        for i = 1, 50 do
            local particle = Utilities:Create("Frame", {
                Name = "Particle" .. i,
                Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6)),
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundColor3 = Aurora.Theme.AccentSecondary,
                BackgroundTransparency = 0.5 + (math.random() * 0.3),
                Parent = ParticlesContainer
            }, {
                Utilities:CreateCorner(100)
            })
            
            spawn(function()
                while ScreenGui and ScreenGui.Parent do
                    local duration = math.random(3, 8)
                    local startY = math.random()
                    local endY = math.random()
                    
                    particle.Position = UDim2.new(math.random(), 0, startY, 0)
                    
                    local tween = Utilities:Tween(particle, {
                        Position = UDim2.new(math.random(), 0, endY, 0)
                    }, duration, Enum.EasingStyle.Linear)
                    
                    wait(duration)
                end
            end)
            
            wait(0.1)
        end
    end)
    
    -- Main Container
    local MainContainer = Utilities:Create("Frame", {
        Name = "MainContainer",
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = Background
    })
    
    -- Logo Container
    local LogoContainer = Utilities:Create("Frame", {
        Name = "LogoContainer",
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = MainContainer
    })
    
    -- Aurora Text Logo with Gradient
    local LogoText = Utilities:Create("TextLabel", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = loadingScreen.Logo,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 60,
        Font = Enum.Font.GothamBold,
        Parent = LogoContainer
    }, {
        Utilities:CreateGradient({
            Color3.fromRGB(0, 206, 209),
            Color3.fromRGB(138, 43, 226),
            Color3.fromRGB(255, 20, 147)
        }, 0)
    })
    
    -- Animated Glow behind logo
    local LogoGlow = Utilities:Create("ImageLabel", {
        Name = "Glow",
        Size = UDim2.new(0, 300, 0, 100),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Aurora.Theme.Accent,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = LogoContainer
    })
    
    -- Animate glow
    spawn(function()
        local transparency = 0.5
        local direction = 1
        while ScreenGui and ScreenGui.Parent do
            transparency = transparency + (direction * 0.02)
            if transparency <= 0.3 then direction = 1
            elseif transparency >= 0.7 then direction = -1 end
            LogoGlow.ImageTransparency = transparency
            wait(0.03)
        end
    end)
    
    -- Subtitle
    local SubtitleLabel = Utilities:Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 130),
        BackgroundTransparency = 1,
        Text = loadingScreen.Subtitle,
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        Parent = MainContainer
    })
    
    -- Loading Bar Container
    local LoadingBarContainer = Utilities:Create("Frame", {
        Name = "LoadingBarContainer",
        Size = UDim2.new(0.8, 0, 0, 8),
        Position = UDim2.new(0.1, 0, 0, 250),
        BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
        Parent = MainContainer
    }, {
        Utilities:CreateCorner(4),
        Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
    })
    
    -- Loading Bar Fill
    local LoadingBarFill = Utilities:Create("Frame", {
        Name = "LoadingBarFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = LoadingBarContainer
    }, {
        Utilities:CreateCorner(4),
        Utilities:CreateGradient({
            Aurora.Theme.AccentSecondary,
            Aurora.Theme.Accent,
            Aurora.Theme.AccentTertiary
        }, 0)
    })
    
    -- Loading Percentage
    local PercentageLabel = Utilities:Create("TextLabel", {
        Name = "Percentage",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 265),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        Parent = MainContainer
    })
    
    -- Status Messages
    local StatusLabel = Utilities:Create("TextLabel", {
        Name = "Status",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 290),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = MainContainer
    })
    
    -- Animated Spinning Icon
    local SpinningContainer = Utilities:Create("Frame", {
        Name = "SpinnerContainer",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, 0, 0, 340),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = MainContainer
    })
    
    local SpinningIcon = Utilities:Create("ImageLabel", {
        Name = "Spinner",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10886031167",
        ImageColor3 = Aurora.Theme.AccentSecondary,
        Parent = SpinningContainer
    })
    
    -- Animate spinner
    spawn(function()
        while ScreenGui and ScreenGui.Parent do
            SpinningIcon.Rotation = SpinningIcon.Rotation + 3
            wait(0.01)
        end
    end)
    
    -- Footer
    local Footer = Utilities:Create("TextLabel", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -30),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Text = "Aurora Library v" .. Aurora.Version .. " | For Learning Purposes Only",
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Parent = Background
    })
    
    -- Loading Progress Animation
    local statusMessages = {
        "Initializing Aurora Library...",
        "Loading UI Components...",
        "Setting up Animations...",
        "Configuring Theme...",
        "Optimizing Performance...",
        "Preparing Interface...",
        "Almost Ready...",
        "Welcome to Aurora!"
    }
    
    local currentProgress = 0
    local targetProgress = 0
    local messageIndex = 1
    
    spawn(function()
        for i = 1, #statusMessages do
            StatusLabel.Text = statusMessages[i]
            targetProgress = (i / #statusMessages) * 100
            
            while currentProgress < targetProgress do
                currentProgress = math.min(currentProgress + 1, targetProgress)
                LoadingBarFill.Size = UDim2.new(currentProgress / 100, 0, 1, 0)
                PercentageLabel.Text = math.floor(currentProgress) .. "%"
                wait(loadingScreen.Duration / 100)
            end
            
            wait(0.2)
        end
        
        wait(0.5)
        
        -- Fade out loading screen
        Utilities:Tween(ScreenGui, {}, 0.5) -- Placeholder
        Utilities:Tween(Background, {BackgroundTransparency = 1}, 0.5)
        
        wait(0.5)
        
        ScreenGui:Destroy()
        loadingScreen.OnComplete()
    end)
    
    -- Typewriter effect for subtitle
    spawn(function()
        while ScreenGui and ScreenGui.Parent do
            Animations:Typewriter(SubtitleLabel, loadingScreen.Subtitle, 0.05)
            wait(2)
        end
    end)
    
    function loadingScreen:Remove()
        if ScreenGui and ScreenGui.Parent then
            Utilities:Tween(Background, {BackgroundTransparency = 1}, 0.5)
            wait(0.5)
            ScreenGui:Destroy()
        end
    end
    
    return loadingScreen
end

-- Window System
local Window = {}
Window.__index = Window

function Aurora:CreateWindow(config)
    config = config or {}
    
    local window = {
        Title = config.Title or "Aurora Library",
        Subtitle = config.Subtitle or "",
        Size = config.Size or UDim2.new(0, 680, 0, 450),
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        MinSize = config.MinSize or UDim2.new(0, 400, 0, 300),
        Theme = config.Theme or Aurora.Theme,
        Tabs = {},
        CurrentTab = nil,
        IsOpen = true,
        IsMinimized = false,
        Dragging = false,
        DragOffset = Vector2.new(0, 0),
        Connections = {}
    }
    
    -- Create ScreenGui
    local ScreenGui = Utilities:Create("ScreenGui", {
        Name = "AuroraWindow_" .. tostring(math.random(100000, 999999)),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    window.ScreenGui = ScreenGui
    
    -- Background Overlay (for click-off detection)
    local Overlay = Utilities:Create("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = ScreenGui
    })
    
    window.Overlay = Overlay
    
    -- Main Window Frame
    local MainFrame = Utilities:Create("Frame", {
        Name = "MainFrame",
        Size = window.Size,
        Position = window.Position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Aurora.Theme.Background,
        Parent = ScreenGui
    }, {
        Utilities:CreateCorner(12),
        Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
    })
    
    window.MainFrame = MainFrame
    
    -- Shadow Effect
    local Shadow = Utilities:Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = MainFrame
    })
    
    -- Glow Border Effect
    local GlowBorder = Utilities:Create("ImageLabel", {
        Name = "GlowBorder",
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0, -4, 0, -4),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Aurora.Theme.Accent,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = MainFrame
    })
    
    -- Animate glow
    spawn(function()
        local transparency = 0.7
        local direction = 1
        while ScreenGui and ScreenGui.Parent do
            transparency = transparency + (direction * 0.01)
            if transparency <= 0.5 then direction = 1
            elseif transparency >= 0.9 then direction = -1 end
            GlowBorder.ImageTransparency = transparency
            wait(0.03)
        end
    end)
    
    -- Title Bar
    local TitleBar = Utilities:Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
        Parent = MainFrame
    }, {
        Utilities:CreateCorner(12)
    })
    
    -- Fix corner overlap
    local TitleBarFix = Utilities:Create("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    window.TitleBar = TitleBar
    
    -- Title Bar Gradient Accent Line
    local AccentLine = Utilities:Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Aurora.Theme.Accent,
        Parent = TitleBar
    }, {
        Utilities:CreateGradient(Aurora.Theme.GradientAurora, 90)
    })
    
    -- Logo/Icon
    local Logo = Utilities:Create("ImageLabel", {
        Name = "Logo",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10886031167",
        ImageColor3 = Aurora.Theme.AccentSecondary,
        Parent = TitleBar
    })
    
    -- Title Text
    local TitleText = Utilities:Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 48, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Title,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Subtitle Text
    if window.Subtitle ~= "" then
        local SubtitleLabel = Utilities:Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, -200, 0, 14),
            Position = UDim2.new(0, 48, 1, -18),
            BackgroundTransparency = 1,
            Text = window.Subtitle,
            TextColor3 = Aurora.Theme.TextMuted,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TitleBar
        })
    end
    
    -- Window Controls Container
    local ControlsContainer = Utilities:Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -105, 0, 0),
        BackgroundTransparency = 1,
        Parent = TitleBar
    }, {
        Utilities:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 5)
        })
    })
    
    -- Minimize Button
    local MinimizeButton = Utilities:Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
        BackgroundTransparency = 0.5,
        Text = "−",
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = ControlsContainer
    }, {
        Utilities:CreateCorner(6)
    })
    
    -- Maximize Button
    local MaximizeButton = Utilities:Create("TextButton", {
        Name = "Maximize",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
        BackgroundTransparency = 0.5,
        Text = "□",
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = ControlsContainer
    }, {
        Utilities:CreateCorner(6)
    })
    
    -- Close Button
    local CloseButton = Utilities:Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
        BackgroundTransparency = 0.5,
        Text = "✕",
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = ControlsContainer
    }, {
        Utilities:CreateCorner(6)
    })
    
    -- Button Hover Effects
    for _, button in pairs({MinimizeButton, MaximizeButton, CloseButton}) do
        button.MouseEnter:Connect(function()
            Utilities:Tween(button, {BackgroundTransparency = 0}, 0.15)
            if button.Name == "Close" then
                button.BackgroundColor3 = Aurora.Theme.AccentDanger
                button.TextColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        button.MouseLeave:Connect(function()
            Utilities:Tween(button, {BackgroundTransparency = 0.5}, 0.15)
            button.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
            button.TextColor3 = Aurora.Theme.TextSecondary
        end)
        
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Animations:Ripple(button, button.AbsoluteSize.X / 2, button.AbsoluteSize.Y / 2, Color3.new(1, 1, 1))
            end
        end)
    end
    
    -- Tab Container (Left Sidebar)
    local TabContainer = Utilities:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 160, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
        Parent = MainFrame
    }, {
        Utilities:CreatePadding(10, 10, 10, 10),
        Utilities:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 4)
        })
    })
    
    window.TabContainer = TabContainer
    
    -- Content Container (Main Area)
    local ContentContainer = Utilities:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -160, 1, -45),
        Position = UDim2.new(0, 160, 0, 45),
        BackgroundColor3 = Aurora.Theme.Background,
        Parent = MainFrame
    })
    
    window.ContentContainer = ContentContainer
    
    -- Tab Content Container
    local TabContentContainer = Utilities:Create("ScrollingFrame", {
        Name = "TabContent",
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Aurora.Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentContainer
    }, {
        Utilities:CreatePadding(0, 0, 0, 5),
        Utilities:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 10)
        })
    })
    
    window.TabContentContainer = TabContentContainer
    
    -- User Info Container (Bottom of Tab Container)
    local UserInfoContainer = Utilities:Create("Frame", {
        Name = "UserInfoContainer",
        Size = UDim2.new(1, -20, 0, 90),
        Position = UDim2.new(0, 10, 1, -100),
        BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
        Parent = TabContainer
    }, {
        Utilities:CreateCorner(8),
        Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
    })
    
    -- User Avatar
    local AvatarFrame = Utilities:Create("Frame", {
        Name = "AvatarFrame",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Aurora.Theme.BackgroundAccent,
        Parent = UserInfoContainer
    }, {
        Utilities:CreateCorner(8)
    })
    
    local AvatarImage = Utilities:Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
        Parent = AvatarFrame
    }, {
        Utilities:CreateCorner(6)
    })
    
    -- Username
    local UsernameLabel = Utilities:Create("TextLabel", {
        Name = "Username",
        Size = UDim2.new(1, -70, 0, 18),
        Position = UDim2.new(0, 58, 0, 10),
        BackgroundTransparency = 1,
        Text = Players.LocalPlayer.Name,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = UserInfoContainer
    })
    
    -- User ID
    local UserIdLabel = Utilities:Create("TextLabel", {
        Name = "UserId",
        Size = UDim2.new(1, -70, 0, 14),
        Position = UDim2.new(0, 58, 0, 28),
        BackgroundTransparency = 1,
        Text = "ID: " .. tostring(Players.LocalPlayer.UserId),
        TextColor3 = Aurora.Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserInfoContainer
    })
    
    -- Time Display
    local TimeLabel = Utilities:Create("TextLabel", {
        Name = "Time",
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 1, -26),
        BackgroundTransparency = 1,
        Text = "⏱ " .. Utilities:GetTime(),
        TextColor3 = Aurora.Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserInfoContainer
    })
    
    -- Update time every second
    spawn(function()
        while ScreenGui and ScreenGui.Parent do
            TimeLabel.Text = "⏱ " .. Utilities:GetTime()
            wait(1)
        end
    end)
    
    -- Dragging functionality
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = true
            window.DragOffset = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, input.Position.Y - MainFrame.AbsolutePosition.Y)
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPosition = Vector2.new(input.Position.X - window.DragOffset.X, input.Position.Y - window.DragOffset.Y)
            MainFrame.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
            MainFrame.AnchorPoint = Vector2.new(0, 0)
        end
    end)
    
    -- Control Button Functions
    MinimizeButton.MouseButton1Click:Connect(function()
        window.IsMinimized = not window.IsMinimized
        
        if window.IsMinimized then
            Utilities:Tween(MainFrame, {Size = UDim2.new(window.Size.X.Offset, 0, 0, 45)}, 0.3)
            MinimizeButton.Text = "+"
        else
            Utilities:Tween(MainFrame, {Size = window.Size}, 0.3)
            MinimizeButton.Text = "−"
        end
    end)
    
    MaximizeButton.MouseButton1Click:Connect(function()
        -- Toggle maximize
        if MainFrame.Size ~= UDim2.new(0.9, 0, 0.9, 0) then
            window.PreviousSize = MainFrame.Size
            window.PreviousPosition = MainFrame.Position
            MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            Utilities:Tween(MainFrame, {Size = UDim2.new(0.9, 0, 0.9, 0)}, 0.3)
        else
            MainFrame.AnchorPoint = Vector2.new(0, 0)
            Utilities:Tween(MainFrame, {Size = window.PreviousSize, Position = window.PreviousPosition}, 0.3)
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Utilities:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Keyboard shortcut (Right Shift to toggle)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- Create Tab Function
    function window:CreateTab(config)
        config = config or {}
        
        local tab = {
            Name = config.Name or "Tab",
            Icon = config.Icon or "📁",
            Window = window,
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = Utilities:Create("TextButton", {
            Name = tab.Name,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
            BackgroundTransparency = 0.5,
            Text = "",
            Parent = TabContainer
        }, {
            Utilities:CreateCorner(6)
        })
        
        -- Tab Button Content
        local TabIcon = Utilities:Create("TextLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = tab.Icon,
            TextColor3 = Aurora.Theme.TextSecondary,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = TabButton
        })
        
        local TabName = Utilities:Create("TextLabel", {
            Name = "Name",
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = tab.Name,
            TextColor3 = Aurora.Theme.TextSecondary,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TabButton
        })
        
        -- Tab Content Frame
        local TabContent = Utilities:Create("Frame", {
            Name = tab.Name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = TabContentContainer
        })
        
        tab.Button = TabButton
        tab.Content = TabContent
        
        -- Tab Selection
        TabButton.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if tab ~= window.CurrentTab then
                Utilities:Tween(TabButton, {BackgroundTransparency = 0.3}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if tab ~= window.CurrentTab then
                Utilities:Tween(TabButton, {BackgroundTransparency = 0.5}, 0.15)
            end
        end)
        
        table.insert(window.Tabs, tab)
        
        -- Auto-select first tab
        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end
        
        -- Section Functions
        function tab:CreateSection(config)
            config = config or {}
            
            local section = {
                Name = config.Name or "Section",
                Tab = tab,
                Elements = {}
            }
            
            local SectionFrame = Utilities:Create("Frame", {
                Name = section.Name,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
                Parent = TabContent
            }, {
                Utilities:CreateCorner(8),
                Utilities:CreateStroke(Aurora.Theme.Border, 1, 0),
                Utilities:CreatePadding(10, 35, 10, 10),
                Utilities:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 8)
                })
            })
            
            -- Section Title
            local SectionTitle = Utilities:Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = section.Name,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            section.Frame = SectionFrame
            
            -- Button Component
            function section:CreateButton(config)
                config = config or {}
                
                local button = {
                    Name = config.Name or "Button",
                    Callback = config.Callback or function() end
                }
                
                local ButtonFrame = Utilities:Create("TextButton", {
                    Name = button.Name,
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Aurora.Theme.Accent,
                    Text = "",
                    Parent = SectionFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateGradient(Aurora.Theme.GradientAurora, 90)
                })
                
                local ButtonLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = button.Name,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    Parent = ButtonFrame
                })
                
                -- Hover Effects
                ButtonFrame.MouseEnter:Connect(function()
                    Utilities:Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(160, 60, 255)}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Utilities:Tween(ButtonFrame, {BackgroundColor3 = Aurora.Theme.Accent}, 0.15)
                end)
                
                ButtonFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Animations:Ripple(ButtonFrame, input.Position.X - ButtonFrame.AbsolutePosition.X, input.Position.Y - ButtonFrame.AbsolutePosition.Y)
                        button.Callback()
                    end
                end)
                
                button.Frame = ButtonFrame
                
                return button
            end
            
            -- Toggle Component
            function section:CreateToggle(config)
                config = config or {}
                
                local toggle = {
                    Name = config.Name or "Toggle",
                    Default = config.Default or false,
                    Callback = config.Callback or function() end,
                    Value = config.Default or false
                }
                
                local ToggleFrame = Utilities:Create("Frame", {
                    Name = toggle.Name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local ToggleLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Text = toggle.Name,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Utilities:Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -45, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    Text = "",
                    Parent = ToggleFrame
                }, {
                    Utilities:CreateCorner(11),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                local ToggleIndicator = Utilities:Create("Frame", {
                    Name = "Indicator",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.TextMuted,
                    Parent = ToggleButton
                }, {
                    Utilities:CreateCorner(8)
                })
                
                -- Set initial state
                if toggle.Default then
                    ToggleIndicator.Position = UDim2.new(1, -19, 0.5, 0)
                    ToggleIndicator.BackgroundColor3 = Aurora.Theme.AccentSecondary
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 60, 70)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggle.Value = not toggle.Value
                    
                    if toggle.Value then
                        Utilities:Tween(ToggleIndicator, {Position = UDim2.new(1, -19, 0.5, 0), BackgroundColor3 = Aurora.Theme.AccentSecondary}, 0.2)
                        Utilities:Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(20, 60, 70)}, 0.2)
                    else
                        Utilities:Tween(ToggleIndicator, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Aurora.Theme.TextMuted}, 0.2)
                        Utilities:Tween(ToggleButton, {BackgroundColor3 = Aurora.Theme.BackgroundTertiary}, 0.2)
                    end
                    
                    toggle.Callback(toggle.Value)
                end)
                
                toggle.Frame = ToggleFrame
                toggle.Button = ToggleButton
                
                return toggle
            end
            
            -- Slider Component
            function section:CreateSlider(config)
                config = config or {}
                
                local slider = {
                    Name = config.Name or "Slider",
                    Min = config.Min or 0,
                    Max = config.Max or 100,
                    Default = config.Default or 50,
                    Increment = config.Increment or 1,
                    Suffix = config.Suffix or "",
                    Callback = config.Callback or function() end,
                    Value = config.Default or 50
                }
                
                local SliderFrame = Utilities:Create("Frame", {
                    Name = slider.Name,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local SliderHeader = Utilities:Create("Frame", {
                    Name = "Header",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = SliderFrame
                })
                
                local SliderLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = slider.Name,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderHeader
                })
                
                local SliderValue = Utilities:Create("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(slider.Default) .. slider.Suffix,
                    TextColor3 = Aurora.Theme.AccentSecondary,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderHeader
                })
                
                local SliderTrack = Utilities:Create("Frame", {
                    Name = "Track",
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -6),
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    Parent = SliderFrame
                }, {
                    Utilities:CreateCorner(3)
                })
                
                local SliderFill = Utilities:Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((slider.Default - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
                    BackgroundColor3 = Aurora.Theme.Accent,
                    Parent = SliderTrack
                }, {
                    Utilities:CreateCorner(3),
                    Utilities:CreateGradient({
                        Aurora.Theme.AccentSecondary,
                        Aurora.Theme.Accent
                    }, 0)
                })
                
                local SliderKnob = Utilities:Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new((slider.Default - slider.Min) / (slider.Max - slider.Min), -8, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Parent = SliderTrack
                }, {
                    Utilities:CreateCorner(8),
                    Utilities:CreateStroke(Aurora.Theme.Accent, 2, 0)
                })
                
                local dragging = false
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                function updateSlider(input)
                    local xPos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = math.floor(((slider.Min + (slider.Max - slider.Min) * xPos) / slider.Increment) + 0.5) * slider.Increment
                    value = math.clamp(value, slider.Min, slider.Max)
                    
                    slider.Value = value
                    SliderValue.Text = tostring(Utilities:Round(value, 2)) .. slider.Suffix
                    
                    local fillSize = (value - slider.Min) / (slider.Max - slider.Min)
                    Utilities:Tween(SliderFill, {Size = UDim2.new(fillSize, 0, 1, 0)}, 0.05)
                    Utilities:Tween(SliderKnob, {Position = UDim2.new(fillSize, -8, 0.5, 0)}, 0.05)
                    
                    slider.Callback(value)
                end
                
                slider.Frame = SliderFrame
                
                return slider
            end
            
            -- Dropdown Component
            function section:CreateDropdown(config)
                config = config or {}
                
                local dropdown = {
                    Name = config.Name or "Dropdown",
                    Options = config.Options or {"Option 1", "Option 2", "Option 3"},
                    Default = config.Default or config.Options[1],
                    Callback = config.Callback or function() end,
                    Value = config.Default or config.Options[1],
                    IsOpen = false
                }
                
                local DropdownFrame = Utilities:Create("Frame", {
                    Name = dropdown.Name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local DropdownButton = Utilities:Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    Text = "",
                    Parent = DropdownFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                local DropdownLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = dropdown.Name .. ": " .. dropdown.Value,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropdownButton
                })
                
                local DropdownIcon = Utilities:Create("TextLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 24, 1, 0),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Aurora.Theme.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Parent = DropdownButton
                })
                
                local DropdownList = Utilities:Create("Frame", {
                    Name = "List",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
                    Visible = false,
                    ZIndex = 100,
                    Parent = DropdownFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0),
                    Utilities:Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical
                    })
                })
                
                -- Populate options
                for _, option in pairs(dropdown.Options) do
                    local OptionButton = Utilities:Create("TextButton", {
                        Name = option,
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundTransparency = 1,
                        Text = option,
                        TextColor3 = Aurora.Theme.TextSecondary,
                        TextSize = 11,
                        Font = Enum.Font.GothamMedium,
                        Parent = DropdownList
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Utilities:Tween(OptionButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Aurora.Theme.Accent, TextColor3 = Color3.new(1, 1, 1)}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Utilities:Tween(OptionButton, {BackgroundTransparency = 1, TextColor3 = Aurora.Theme.TextSecondary}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        dropdown.Value = option
                        DropdownLabel.Text = dropdown.Name .. ": " .. option
                        dropdown.Callback(option)
                        toggleDropdown()
                    end)
                end
                
                DropdownList.AutomaticSize = Enum.AutomaticSize.Y
                
                function toggleDropdown()
                    dropdown.IsOpen = not dropdown.IsOpen
                    
                    if dropdown.IsOpen then
                        DropdownList.Visible = true
                        DropdownList.Size = UDim2.new(1, 0, 0, 0)
                        Utilities:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, #dropdown.Options * 28)}, 0.2)
                        Utilities:Tween(DropdownIcon, {Rotation = 180}, 0.2)
                    else
                        Utilities:Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        Utilities:Tween(DropdownIcon, {Rotation = 0}, 0.2)
                        delay(0.2, function()
                            DropdownList.Visible = false
                        end)
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                dropdown.Frame = DropdownFrame
                
                return dropdown
            end
            
            -- Keybind Component
            function section:CreateKeybind(config)
                config = config or {}
                
                local keybind = {
                    Name = config.Name or "Keybind",
                    Default = config.Default or Enum.KeyCode.F,
                    Callback = config.Callback or function() end,
                    Key = config.Default or Enum.KeyCode.F,
                    Listening = false
                }
                
                local KeybindFrame = Utilities:Create("Frame", {
                    Name = keybind.Name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local KeybindLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -70, 1, 0),
                    BackgroundTransparency = 1,
                    Text = keybind.Name,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Utilities:Create("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 60, 0, 26),
                    Position = UDim2.new(1, -65, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    Text = keybind.Key.Name,
                    TextColor3 = Aurora.Theme.TextSecondary,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = KeybindFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    keybind.Listening = true
                    KeybindButton.Text = "..."
                    Utilities:Tween(KeybindButton, {BackgroundColor3 = Aurora.Theme.Accent, TextColor3 = Color3.new(1, 1, 1)}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if keybind.Listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            keybind.Key = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Utilities:Tween(KeybindButton, {BackgroundColor3 = Aurora.Theme.BackgroundTertiary, TextColor3 = Aurora.Theme.TextSecondary}, 0.15)
                            keybind.Listening = false
                        end
                    elseif not gameProcessed and input.KeyCode == keybind.Key then
                        keybind.Callback()
                    end
                end)
                
                keybind.Frame = KeybindFrame
                
                return keybind
            end
            
            -- Paragraph/Label Component
            function section:CreateParagraph(config)
                config = config or {}
                
                local paragraph = {
                    Title = config.Title or "",
                    Text = config.Text or "Paragraph text"
                }
                
                local ParagraphFrame = Utilities:Create("Frame", {
                    Name = "Paragraph",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    Parent = SectionFrame
                }, {
                    Utilities:CreateCorner(6)
                })
                
                local Padding = Utilities:CreatePadding(10, 10, 10, 10)
                Padding.Parent = ParagraphFrame
                
                if paragraph.Title ~= "" then
                    local TitleLabel = Utilities:Create("TextLabel", {
                        Name = "Title",
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = paragraph.Title,
                        TextColor3 = Aurora.Theme.AccentSecondary,
                        TextSize = 12,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ParagraphFrame
                    })
                end
                
                local TextLabel = Utilities:Create("TextLabel", {
                    Name = "Text",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = paragraph.Text,
                    TextColor3 = Aurora.Theme.TextSecondary,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = ParagraphFrame
                })
                
                paragraph.Frame = ParagraphFrame
                
                return paragraph
            end
            
            -- Textbox Component
            function section:CreateTextbox(config)
                config = config or {}
                
                local textbox = {
                    Name = config.Name or "Textbox",
                    Default = config.Default or "",
                    Placeholder = config.Placeholder or "Enter text...",
                    Callback = config.Callback or function() end,
                    Value = config.Default or ""
                }
                
                local TextboxFrame = Utilities:Create("Frame", {
                    Name = textbox.Name,
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local TextboxLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = textbox.Name,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxFrame
                })
                
                local TextboxInput = Utilities:Create("TextBox", {
                    Name = "Input",
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                    Text = textbox.Default,
                    PlaceholderColor3 = Aurora.Theme.TextMuted,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    PlaceholderText = textbox.Placeholder,
                    Parent = TextboxFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                TextboxInput.Focused:Connect(function()
                    Utilities:Tween(TextboxInput, {BackgroundColor3 = Aurora.Theme.BackgroundAccent}, 0.15)
                    Utilities:Tween(TextboxInput:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Accent}, 0.15)
                end)
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    Utilities:Tween(TextboxInput, {BackgroundColor3 = Aurora.Theme.BackgroundTertiary}, 0.15)
                    Utilities:Tween(TextboxInput:FindFirstChildOfClass("UIStroke"), {Color = Aurora.Theme.Border}, 0.15)
                    
                    textbox.Value = TextboxInput.Text
                    textbox.Callback(TextboxInput.Text, enterPressed)
                end)
                
                textbox.Frame = TextboxFrame
                textbox.Input = TextboxInput
                
                return textbox
            end
            
            -- Color Picker Component
            function section:CreateColorPicker(config)
                config = config or {}
                
                local colorPicker = {
                    Name = config.Name or "Color Picker",
                    Default = config.Default or Color3.fromRGB(255, 255, 255),
                    Callback = config.Callback or function() end,
                    Value = config.Default or Color3.fromRGB(255, 255, 255),
                    IsOpen = false
                }
                
                local ColorFrame = Utilities:Create("Frame", {
                    Name = colorPicker.Name,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = SectionFrame
                })
                
                local ColorLabel = Utilities:Create("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = colorPicker.Name,
                    TextColor3 = Aurora.Theme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorPreview = Utilities:Create("TextButton", {
                    Name = "Preview",
                    Size = UDim2.new(0, 50, 0, 26),
                    Position = UDim2.new(1, -55, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = colorPicker.Default,
                    Text = "",
                    Parent = ColorFrame
                }, {
                    Utilities:CreateCorner(6),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                -- Color Picker Popup
                local ColorPopup = Utilities:Create("Frame", {
                    Name = "Popup",
                    Size = UDim2.new(0, 200, 0, 180),
                    Position = UDim2.new(1, -205, 0, 36),
                    BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
                    Visible = false,
                    ZIndex = 100,
                    Parent = ColorFrame
                }, {
                    Utilities:CreateCorner(8),
                    Utilities:CreateStroke(Aurora.Theme.Border, 1, 0)
                })
                
                -- HSV Color Selector
                local ColorGradient = Utilities:Create("ImageLabel", {
                    Name = "Gradient",
                    Size = UDim2.new(1, -20, 0, 120),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.new(1, 0, 0),
                    Image = "rbxassetid://4155801252",
                    Parent = ColorPopup
                }, {
                    Utilities:CreateCorner(6)
                })
                
                -- Hue Slider
                local HueSlider = Utilities:Create("ImageLabel", {
                    Name = "Hue",
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 1, -40),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Image = "rbxassetid://3570695787",
                    Parent = ColorPopup
                }, {
                    Utilities:CreateCorner(6)
                })
                
                -- Color picking logic
                local function updateColor(hue, sat, val)
                    local color = Color3.fromHSV(hue, sat, val)
                    colorPicker.Value = color
                    ColorPreview.BackgroundColor3 = color
                    colorPicker.Callback(color)
                end
                
                local selectingColor = false
                local selectingHue = false
                
                ColorGradient.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        selectingColor = true
                    end
                end)
                
                ColorGradient.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        selectingColor = false
                    end
                end)
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        selectingHue = true
                    end
                end)
                
                HueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        selectingHue = false
                    end
                end)
                
                -- Handle color selection
                local currentHue = 0
                local currentSat = 1
                local currentVal = 1
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if selectingColor then
                            local relX = math.clamp((input.Position.X - ColorGradient.AbsolutePosition.X) / ColorGradient.AbsoluteSize.X, 0, 1)
                            local relY = math.clamp((input.Position.Y - ColorGradient.AbsolutePosition.Y) / ColorGradient.AbsoluteSize.Y, 0, 1)
                            currentSat = relX
                            currentVal = 1 - relY
                            updateColor(currentHue, currentSat, currentVal)
                        elseif selectingHue then
                            local relX = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                            currentHue = relX
                            ColorGradient.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                            updateColor(currentHue, currentSat, currentVal)
                        end
                    end
                end)
                
                ColorPreview.MouseButton1Click:Connect(function()
                    colorPicker.IsOpen = not colorPicker.IsOpen
                    ColorPopup.Visible = colorPicker.IsOpen
                end)
                
                colorPicker.Frame = ColorFrame
                
                return colorPicker
            end
            
            return section
        end
        
        return tab
    end
    
    -- Select Tab Function
    function window:SelectTab(tab)
        -- Deselect current tab
        if window.CurrentTab then
            Utilities:Tween(window.CurrentTab.Button, {BackgroundTransparency = 0.5})
            window.CurrentTab.Button:FindFirstChild("Name").TextColor3 = Aurora.Theme.TextSecondary
            window.CurrentTab.Button:FindFirstChild("Icon").TextColor3 = Aurora.Theme.TextSecondary
            window.CurrentTab.Content.Visible = false
        end
        
        -- Select new tab
        window.CurrentTab = tab
        Utilities:Tween(tab.Button, {BackgroundTransparency = 0})
        tab.Button:FindFirstChild("Name").TextColor3 = Color3.new(1, 1, 1)
        tab.Button:FindFirstChild("Icon").TextColor3 = Aurora.Theme.AccentSecondary
        tab.Content.Visible = true
    end
    
    -- Notification System
    function window:Notify(config)
        config = config or {}
        
        local notification = {
            Title = config.Title or "Notification",
            Content = config.Content or "Notification content",
            Duration = config.Duration or 5,
            Type = config.Type or "info" -- info, success, warning, error
        }
        
        local typeColors = {
            info = Aurora.Theme.AccentSecondary,
            success = Aurora.Theme.AccentSuccess,
            warning = Aurora.Theme.AccentWarning,
            error = Aurora.Theme.AccentDanger
        }
        
        local NotificationContainer = Utilities:Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 300, 0, 70),
            Position = UDim2.new(1, -320, 1, 0),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Aurora.Theme.BackgroundSecondary,
            Parent = ScreenGui
        }, {
            Utilities:CreateCorner(8),
            Utilities:CreateStroke(typeColors[notification.Type], 2, 0)
        })
        
        local TitleLabel = Utilities:Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = notification.Title,
            TextColor3 = typeColors[notification.Type],
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotificationContainer
        })
        
        local ContentLabel = Utilities:Create("TextLabel", {
            Name = "Content",
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 15, 0, 30),
            BackgroundTransparency = 1,
            Text = notification.Content,
            TextColor3 = Aurora.Theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = NotificationContainer
        })
        
        -- Progress Bar
        local ProgressBar = Utilities:Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = typeColors[notification.Type],
            Parent = NotificationContainer
        }, {
            Utilities:CreateCorner(2)
        })
        
        -- Slide in animation
        local targetY = 20
        local yPos = 120
        for _, existing in pairs(ScreenGui:GetChildren()) do
            if existing.Name == "Notification" and existing ~= NotificationContainer then
                yPos = yPos + 80
            end
        end
        
        NotificationContainer.Position = UDim2.new(1, 0, 1, -yPos)
        Utilities:Tween(NotificationContainer, {Position = UDim2.new(1, -320, 1, -yPos)}, 0.4)
        
        -- Progress animation
        spawn(function()
            local startTime = tick()
            while tick() - startTime < notification.Duration do
                local progress = 1 - ((tick() - startTime) / notification.Duration)
                ProgressBar.Size = UDim2.new(progress, 0, 0, 3)
                wait(0.03)
            end
        end)
        
        -- Auto dismiss
        delay(notification.Duration, function()
            Utilities:Tween(NotificationContainer, {Position = UDim2.new(1, 50, 1, -yPos)}, 0.4)
            wait(0.4)
            NotificationContainer:Destroy()
        end)
        
        return notification
    end
    
    return window
end

-- Executor Info Display Component
function Aurora:GetExecutorCard()
    local executorInfo = Utilities:GetExecutorInfo()
    local userInfo = Utilities:GetUserInfo()
    
    local text = string.format([[
═══════════════════════════════════════
           AURORA LIBRARY INFO
═══════════════════════════════════════

👤 USER INFORMATION
   Username: %s
   Display Name: %s
   User ID: %d
   Account Age: %d days
   Membership: %s

⚡ EXECUTOR INFORMATION
   Name: %s
   Version: %s
   Capabilities: %d detected

📊 SYSTEM
   Date: %s
   Time: %s

═══════════════════════════════════════
    Version: %s | Learning Purpose Only
═══════════════════════════════════════
    ]],
        userInfo.Username,
        userInfo.DisplayName,
        userInfo.UserId,
        userInfo.AccountAgeDays,
        userInfo.Membership,
        executorInfo.Name,
        executorInfo.Version,
        #executorInfo.Capabilities,
        Utilities:GetDate(),
        Utilities:GetTime(),
        Aurora.Version
    )
    
    return text
end

-- Return Library
return Aurora
