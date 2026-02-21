local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Aurora Library
local Aurora = {}

-- ============================================
-- CONFIGURATION
-- ============================================
Aurora.Config = {
    -- Colors (Aurora Theme - Purple/Cyan gradient)
    Colors = {
        Primary = Color3.fromRGB(138, 43, 226),        -- Purple
        Secondary = Color3.fromRGB(0, 195, 255),       -- Cyan
        Accent = Color3.fromRGB(255, 0, 127),          -- Pink
        Success = Color3.fromRGB(0, 255, 136),         -- Green
        Warning = Color3.fromRGB(255, 170, 0),         -- Orange
        Error = Color3.fromRGB(255, 65, 65),           -- Red

        -- Background colors
        Background = Color3.fromRGB(15, 15, 25),       -- Dark background
        BackgroundLight = Color3.fromRGB(25, 25, 40),  -- Lighter background
        Glass = Color3.fromRGB(20, 20, 35),            -- Glass effect
        GlassBorder = Color3.fromRGB(60, 60, 100),     -- Glass border

        -- Text colors
        TextPrimary = Color3.fromRGB(255, 255, 255),   -- White
        TextSecondary = Color3.fromRGB(180, 180, 200), -- Gray
        TextMuted = Color3.fromRGB(120, 120, 140),     -- Muted

        -- Gradient
        GradientStart = Color3.fromRGB(138, 43, 226),  -- Purple
        GradientEnd = Color3.fromRGB(0, 195, 255),     -- Cyan
    },

    -- Sizes
    Sizes = {
        WindowWidth = 650,
        WindowHeight = 450,
        SidebarWidth = 180,
        TabHeight = 40,
        ElementHeight = 36,
        ElementSpacing = 8,
        CornerRadius = UDim.new(0, 12),
    },

    -- Animation
    Animation = {
        Duration = 0.3,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out,
    },
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
Aurora.Utils = {}

-- Create rounded rectangle
function Aurora.Utils.Round(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = frame
    return corner
end

-- Create stroke
function Aurora.Utils.Stroke(frame, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Aurora.Config.Colors.GlassBorder
    stroke.Thickness = thickness or 1
    stroke.Parent = frame
    return stroke
end

-- Create gradient
function Aurora.Utils.Gradient(frame, startColor, endColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor or Aurora.Config.Colors.GradientStart),
        ColorSequenceKeypoint.new(1, endColor or Aurora.Config.Colors.GradientEnd)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = frame
    return gradient
end

-- Create padding
function Aurora.Utils.Padding(frame, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 10)
    padding.PaddingBottom = UDim.new(0, bottom or 10)
    padding.PaddingLeft = UDim.new(0, left or 10)
    padding.PaddingRight = UDim.new(0, right or 10)
    padding.Parent = frame
    return padding
end

-- Create list layout
function Aurora.Utils.ListLayout(frame, direction, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, spacing or 8)
    layout.Parent = frame
    return layout
end

-- Tween function
function Aurora.Utils.Tween(instance, properties, duration, callback)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Aurora.Config.Animation.Duration,
            Aurora.Config.Animation.EasingStyle,
            Aurora.Config.Animation.EasingDirection
        ),
        properties
    )
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

-- Create ripple effect
function Aurora.Utils.Ripple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.ZIndex = 100
    ripple.Parent = button

    Aurora.Utils.Round(ripple, UDim.new(1, 0))

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2

    Aurora.Utils.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5, function()
        ripple:Destroy()
    end)
end

-- Get executor info
function Aurora.Utils.GetExecutorInfo()
    local executorInfo = {
        Name = "Unknown",
        Version = "Unknown",
    }

    -- Try to identify executor
    local syn = syn or {}
    local KRNL = KRNL
    local UNC = UNC
    local scriptware = scriptware
    local electron = electron
    local fluxus = fluxus
    local codex = codex
    local krnl = krnl
    local oxygen = oxygen
    local valyse = valyse
    local temple = temple
    local trigon = trigon
    local sasware = sasware
    local celeztial = celeztial
    local velocity = velocity
    local xo = xo

    if syn and syn.request then
        executorInfo.Name = "Synapse X"
        executorInfo.Version = "v2.4.8"
    elseif KRNL then
        executorInfo.Name = "KRNL"
        executorInfo.Version = "v1.5.6"
    elseif UNC then
        executorInfo.Name = "UNC"
        executorInfo.Version = "Universal"
    elseif scriptware then
        executorInfo.Name = "Script-Ware"
        executorInfo.Version = "v1.2.5"
    elseif electron then
        executorInfo.Name = "Electron"
        executorInfo.Version = "v2.0.0"
    elseif fluxus then
        executorInfo.Name = "Fluxus"
        executorInfo.Version = "v2.1.0"
    elseif codex then
        executorInfo.Name = "Codex"
        executorInfo.Version = "v1.0.0"
    elseif identifyexecutor then
        local name, version = identifyexecutor()
        executorInfo.Name = name or "Unknown"
        executorInfo.Version = version or "Unknown"
    end

    return executorInfo
end

-- Get player info
function Aurora.Utils.GetPlayerInfo()
    local player = LocalPlayer
    local userId = player.UserId
    local username = player.Name
    local displayName = player.DisplayName
    local accountAge = player.AccountAge

    -- Calculate account age
    local years = math.floor(accountAge / 365)
    local days = accountAge % 365

    return {
        Username = username,
        DisplayName = displayName,
        UserId = userId,
        AccountAge = accountAge,
        AccountAgeFormatted = string.format("%d years, %d days", years, days),
        Membership = player.MembershipType.Name,
        Thumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100),
    }
end

-- Get game info
function Aurora.Utils.GetGameInfo()
    local gameInfo = {
        GameName = game.Name or "Unknown",
        GameId = game.GameId or 0,
        PlaceId = game.PlaceId or 0,
        JobId = game.JobId or "Unknown",
        InstanceName = game.JobId ~= "" and "Private Server" or "Public Server",
        MaxPlayers = game:GetService("Players").MaxPlayers or 0,
    }

    return gameInfo
end

-- Format time
function Aurora.Utils.FormatTime()
    local date = os.date("*t")
    local hour = date.hour
    local minute = date.min
    local second = date.sec
    local ampm = hour >= 12 and "PM" or "AM"
    hour = hour % 12
    hour = hour == 0 and 12 or hour

    return {
        Time = string.format("%02d:%02d:%02d %s", hour, minute, second, ampm),
        Date = string.format("%02d/%02d/%04d", date.day, date.month, date.year),
        Day = os.date("%A"),
    }
end

-- ============================================
-- LOADING SCREEN
-- ============================================
function Aurora.LoadingScreen(options)
    options = options or {}

    local loadingDuration = options.Duration or 3
    local title = options.Title or "Aurora Library"
    local subtitle = options.Subtitle or "Loading..."
    local onComplete = options.OnComplete or function() end

    -- Create screen gui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraLoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Aurora.Config.Colors.Background
    background.BorderSizePixel = 0
    background.Parent = screenGui

    -- Aurora gradient background
    local gradientBg = Instance.new("Frame")
    gradientBg.Name = "GradientBg"
    gradientBg.Size = UDim2.new(2, 0, 2, 0)
    gradientBg.Position = UDim2.new(-0.5, 0, -0.5, 0)
    gradientBg.BackgroundColor3 = Aurora.Config.Colors.Primary
    gradientBg.BackgroundTransparency = 0.9
    gradientBg.BorderSizePixel = 0
    gradientBg.Parent = background

    local auroraGradient = Instance.new("UIGradient")
    auroraGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 195, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 127))
    })
    auroraGradient.Rotation = 45
    auroraGradient.Parent = gradientBg

    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 300)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = background

    -- Logo (Aurora text)
    local logoFrame = Instance.new("Frame")
    logoFrame.Name = "LogoFrame"
    logoFrame.Size = UDim2.new(1, 0, 0, 80)
    logoFrame.Position = UDim2.new(0.5, 0, 0.3, 0)
    logoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    logoFrame.BackgroundTransparency = 1
    logoFrame.Parent = container

    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "AURORA"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 60
    logoText.Font = Enum.Font.GothamBold
    logoText.TextStrokeTransparency = 0.8
    logoText.Parent = logoFrame

    -- Logo gradient
    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Aurora.Config.Colors.Primary),
        ColorSequenceKeypoint.new(1, Aurora.Config.Colors.Secondary)
    })
    logoGradient.Parent = logoText

    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
    subtitleLabel.Position = UDim2.new(0.5, 0, 0.45, 0)
    subtitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "L I B R A R Y"
    subtitleLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
    subtitleLabel.TextSize = 16
    subtitleLabel.Font = Enum.Font.GothamBold
    subtitleLabel.TextTransparency = 0.3
    subtitleLabel.Parent = container

    -- Loading bar container
    local loadingBarContainer = Instance.new("Frame")
    loadingBarContainer.Name = "LoadingBarContainer"
    loadingBarContainer.Size = UDim2.new(0.8, 0, 0, 8)
    loadingBarContainer.Position = UDim2.new(0.5, 0, 0.65, 0)
    loadingBarContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingBarContainer.BackgroundColor3 = Aurora.Config.Colors.BackgroundLight
    loadingBarContainer.Parent = container

    Aurora.Utils.Round(loadingBarContainer, UDim.new(1, 0))

    -- Loading bar fill
    local loadingBar = Instance.new("Frame")
    loadingBar.Name = "LoadingBar"
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BackgroundColor3 = Aurora.Config.Colors.Primary
    loadingBar.Parent = loadingBarContainer

    Aurora.Utils.Round(loadingBar, UDim.new(1, 0))
    Aurora.Utils.Gradient(loadingBar)

    -- Loading text
    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0.5, 0, 0.75, 0)
    loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = subtitle
    loadingText.TextColor3 = Aurora.Config.Colors.TextSecondary
    loadingText.TextSize = 14
    loadingText.Font = Enum.Font.GothamSemibold
    loadingText.Parent = container

    -- Animated particles
    local particlesContainer = Instance.new("Frame")
    particlesContainer.Name = "Particles"
    particlesContainer.Size = UDim2.new(1, 0, 1, 0)
    particlesContainer.BackgroundTransparency = 1
    particlesContainer.Parent = background

    -- Create particles
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Name = "Particle" .. i
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        particle.BackgroundTransparency = math.random(50, 80) / 100
        particle.Parent = particlesContainer

        Aurora.Utils.Round(particle, UDim.new(1, 0))
    end

    -- Rotation animation for gradient background
    local rotation = 0
    local rotationConnection
    rotationConnection = RunService.Heartbeat:Connect(function()
        rotation = rotation + 0.5
        auroraGradient.Rotation = rotation % 360

        -- Animate particles
        for _, particle in pairs(particlesContainer:GetChildren()) do
            if particle:IsA("Frame") then
                local currentPos = particle.Position
                local newY = currentPos.Y.Scale - 0.001
                if newY < -0.1 then
                    newY = 1.1
                end
                particle.Position = UDim2.new(currentPos.X.Scale, 0, newY, 0)
            end
        end
    end)

    -- Loading animation
    local loadingMessages = {
        "Initializing Aurora...",
        "Loading modules...",
        "Preparing UI components...",
        "Setting up animations...",
        "Almost ready...",
        "Welcome!"
    }

    local messageIndex = 1
    local progress = 0
    local stepDuration = loadingDuration / #loadingMessages

    coroutine.wrap(function()
        for i, message in ipairs(loadingMessages) do
            wait(stepDuration)

            -- Update loading text
            Aurora.Utils.Tween(loadingText, {TextTransparency = 1}, 0.15, function()
                loadingText.Text = message
                Aurora.Utils.Tween(loadingText, {TextTransparency = 0}, 0.15)
            end)

            -- Update loading bar
            progress = i / #loadingMessages
            Aurora.Utils.Tween(loadingBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
        end

        -- Finish loading
        wait(0.5)

        -- Fade out
        Aurora.Utils.Tween(background, {BackgroundTransparency = 1}, 0.5)

        wait(0.5)

        -- Cleanup
        if rotationConnection then
            rotationConnection:Disconnect()
        end
        screenGui:Destroy()

        -- Callback
        onComplete()
    end)()

    return screenGui
end

-- ============================================
-- MAIN WINDOW
-- ============================================
function Aurora:CreateWindow(options)
    options = options or {}

    local title = options.Title or "Aurora Library"
    local subtitle = options.Subtitle or "Made with ❤️"

    local window = {
        Tabs = {},
        CurrentTab = nil,
        Open = true,
    }

    -- Create screen gui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraWindow"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    window.ScreenGui = screenGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, Aurora.Config.Sizes.WindowWidth, 0, Aurora.Config.Sizes.WindowHeight)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Aurora.Config.Colors.Glass
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    window.MainFrame = mainFrame

    -- Glass effect
    Aurora.Utils.Round(mainFrame, Aurora.Config.Sizes.CornerRadius)
    Aurora.Utils.Stroke(mainFrame, Aurora.Config.Colors.GlassBorder, 1)

    -- Add glass blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    -- Background gradient overlay
    local gradientOverlay = Instance.new("Frame")
    gradientOverlay.Name = "GradientOverlay"
    gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    gradientOverlay.BackgroundColor3 = Aurora.Config.Colors.Primary
    gradientOverlay.BackgroundTransparency = 0.95
    gradientOverlay.BorderSizePixel = 0
    gradientOverlay.Parent = mainFrame

    Aurora.Utils.Round(gradientOverlay, Aurora.Config.Sizes.CornerRadius)

    local overlayGradient = Instance.new("UIGradient")
    overlayGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Aurora.Config.Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Aurora.Config.Colors.Secondary),
        ColorSequenceKeypoint.new(1, Aurora.Config.Colors.Accent)
    })
    overlayGradient.Rotation = 45
    overlayGradient.Parent = gradientOverlay

    -- Animate gradient rotation
    coroutine.wrap(function()
        local rotation = 0
        while mainFrame and mainFrame.Parent do
            rotation = rotation + 0.3
            overlayGradient.Rotation = rotation % 360
            wait(0.016)
        end
    end)()

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Aurora.Config.Sizes.SidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = Aurora.Config.Sizes.CornerRadius
    sidebarCorner.Parent = sidebar

    -- Fix sidebar corner (only left side)
    local sidebarFix = Instance.new("Frame")
    sidebarFix.Size = UDim2.new(0, Aurora.Config.Sizes.CornerRadius.Offset, 1, 0)
    sidebarFix.Position = UDim2.new(1, -Aurora.Config.Sizes.CornerRadius.Offset, 0, 0)
    sidebarFix.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    sidebarFix.BackgroundTransparency = 0.5
    sidebarFix.BorderSizePixel = 0
    sidebarFix.Parent = sidebar

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundTransparency = 1
    header.Parent = sidebar

    -- Logo
    local logoFrame = Instance.new("Frame")
    logoFrame.Name = "LogoFrame"
    logoFrame.Size = UDim2.new(1, 0, 0, 40)
    logoFrame.Position = UDim2.new(0, 0, 0, 10)
    logoFrame.BackgroundTransparency = 1
    logoFrame.Parent = header

    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, -10, 1, 0)
    logoText.Position = UDim2.new(0, 10, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "AURORA"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 22
    logoText.Font = Enum.Font.GothamBold
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    logoText.Parent = logoFrame

    -- Logo gradient
    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Aurora.Config.Colors.Primary),
        ColorSequenceKeypoint.new(1, Aurora.Config.Colors.Secondary)
    })
    logoGradient.Parent = logoText

    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, -10, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 10, 0, 38)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = subtitle
    subtitleLabel.TextColor3 = Aurora.Config.Colors.TextMuted
    subtitleLabel.TextSize = 10
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = header

    -- Tab container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, -140)
    tabContainer.Position = UDim2.new(0, 0, 0, 70)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = sidebar

    Aurora.Utils.Padding(tabContainer, 5, 5, 5, 5)
    Aurora.Utils.ListLayout(tabContainer, Enum.FillDirection.Vertical, 5)

    -- Tab buttons container
    local tabButtons = {}
    window.TabButtons = tabButtons

    -- Info section
    local infoSection = Instance.new("Frame")
    infoSection.Name = "InfoSection"
    infoSection.Size = UDim2.new(1, 0, 0, 60)
    infoSection.Position = UDim2.new(0, 0, 1, -60)
    infoSection.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    infoSection.BackgroundTransparency = 0.3
    infoSection.BorderSizePixel = 0
    infoSection.Parent = sidebar

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = Aurora.Config.Sizes.CornerRadius
    infoCorner.Parent = infoSection

    -- Fix info section corner
    local infoFix = Instance.new("Frame")
    infoFix.Size = UDim2.new(0, Aurora.Config.Sizes.CornerRadius.Offset, 1, 0)
    infoFix.Position = UDim2.new(1, -Aurora.Config.Sizes.CornerRadius.Offset, 0, 0)
    infoFix.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    infoFix.BackgroundTransparency = 0.3
    infoFix.BorderSizePixel = 0
    infoFix.Parent = infoSection

    -- User info
    local playerInfo = Aurora.Utils.GetPlayerInfo()
    local executorInfo = Aurora.Utils.GetExecutorInfo()

    local userAvatar = Instance.new("ImageLabel")
    userAvatar.Name = "UserAvatar"
    userAvatar.Size = UDim2.new(0, 35, 0, 35)
    userAvatar.Position = UDim2.new(0, 10, 0.5, 0)
    userAvatar.AnchorPoint = Vector2.new(0, 0.5)
    userAvatar.BackgroundColor3 = Aurora.Config.Colors.Primary
    userAvatar.Image = playerInfo.Thumbnail
    userAvatar.Parent = infoSection

    Aurora.Utils.Round(userAvatar, UDim.new(1, 0))
    Aurora.Utils.Stroke(userAvatar, Aurora.Config.Colors.Secondary, 2)

    local userName = Instance.new("TextLabel")
    userName.Name = "UserName"
    userName.Size = UDim2.new(1, -60, 0, 18)
    userName.Position = UDim2.new(0, 52, 0.5, -12)
    userName.BackgroundTransparency = 1
    userName.Text = playerInfo.DisplayName
    userName.TextColor3 = Color3.fromRGB(255, 255, 255)
    userName.TextSize = 12
    userName.Font = Enum.Font.GothamBold
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = infoSection

    local userStatus = Instance.new("TextLabel")
    userStatus.Name = "UserStatus"
    userStatus.Size = UDim2.new(1, -60, 0, 14)
    userStatus.Position = UDim2.new(0, 52, 0.5, 6)
    userStatus.BackgroundTransparency = 1
    userStatus.Text = executorInfo.Name
    userStatus.TextColor3 = Aurora.Config.Colors.Secondary
    userStatus.TextSize = 10
    userStatus.Font = Enum.Font.Gotham
    userStatus.TextXAlignment = Enum.TextXAlignment.Left
    userStatus.Parent = infoSection

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -Aurora.Config.Sizes.SidebarWidth, 1, 0)
    contentArea.Position = UDim2.new(0, Aurora.Config.Sizes.SidebarWidth, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = contentArea

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Window controls
    local controlContainer = Instance.new("Frame")
    controlContainer.Name = "Controls"
    controlContainer.Size = UDim2.new(0, 80, 1, 0)
    controlContainer.Position = UDim2.new(1, -85, 0, 0)
    controlContainer.BackgroundTransparency = 1
    controlContainer.Parent = titleBar

    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.Parent = controlContainer

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.BackgroundColor3 = Aurora.Config.Colors.Warning
    minimizeBtn.BackgroundTransparency = 0.3
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = controlContainer

    Aurora.Utils.Round(minimizeBtn, UDim.new(1, 0))

    minimizeBtn.MouseButton1Click:Connect(function()
        if window.Open then
            Aurora.Utils.Tween(mainFrame, {
                Size = UDim2.new(0, Aurora.Config.Sizes.WindowWidth, 0, 40)
            }, 0.3)
            window.Open = false
            minimizeBtn.Text = "+"
        else
            Aurora.Utils.Tween(mainFrame, {
                Size = UDim2.new(0, Aurora.Config.Sizes.WindowWidth, 0, Aurora.Config.Sizes.WindowHeight)
            }, 0.3)
            window.Open = true
            minimizeBtn.Text = "−"
        end
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.BackgroundColor3 = Aurora.Config.Colors.Error
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = controlContainer

    Aurora.Utils.Round(closeBtn, UDim.new(1, 0))

    closeBtn.MouseButton1Click:Connect(function()
        Aurora.Utils.Tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, function()
            screenGui:Destroy()
            blur:Destroy()
        end)
    end)

    -- Hover effects for buttons
    for _, btn in pairs({minimizeBtn, closeBtn}) do
        btn.MouseEnter:Connect(function()
            Aurora.Utils.Tween(btn, {BackgroundTransparency = 0})
        end)
        btn.MouseLeave:Connect(function()
            Aurora.Utils.Tween(btn, {BackgroundTransparency = 0.3})
        end)
    end

    -- Tab content container
    local tabContentContainer = Instance.new("Frame")
    tabContentContainer.Name = "TabContentContainer"
    tabContentContainer.Size = UDim2.new(1, 0, 1, -45)
    tabContentContainer.Position = UDim2.new(0, 0, 0, 45)
    tabContentContainer.BackgroundTransparency = 1
    tabContentContainer.Parent = contentArea

    window.TabContentContainer = tabContentContainer

    -- Draggable
    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Create tab function
    function window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}

        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or "rbxassetid://7733964719" -- Default star icon

        local tab = {
            Name = tabName,
            Sections = {},
        }

        -- Tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 35)
        tabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        tabButton.BackgroundTransparency = 0.5
        tabButton.Text = ""
        tabButton.Parent = tabContainer

        Aurora.Utils.Round(tabButton, UDim.new(0, 8))

        -- Tab button content
        local tabBtnContent = Instance.new("Frame")
        tabBtnContent.Size = UDim2.new(1, 0, 1, 0)
        tabBtnContent.BackgroundTransparency = 1
        tabBtnContent.Parent = tabButton

        Aurora.Utils.Padding(tabBtnContent, 0, 0, 10, 10)

        local tabBtnIcon = Instance.new("ImageLabel")
        tabBtnIcon.Name = "Icon"
        tabBtnIcon.Size = UDim2.new(0, 18, 0, 18)
        tabBtnIcon.Position = UDim2.new(0, 10, 0.5, 0)
        tabBtnIcon.AnchorPoint = Vector2.new(0, 0.5)
        tabBtnIcon.BackgroundTransparency = 1
        tabBtnIcon.Image = tabIcon
        tabBtnIcon.ImageColor3 = Aurora.Config.Colors.TextSecondary
        tabBtnIcon.Parent = tabBtnContent

        local tabBtnText = Instance.new("TextLabel")
        tabBtnText.Name = "Text"
        tabBtnText.Size = UDim2.new(1, -40, 1, 0)
        tabBtnText.Position = UDim2.new(0, 35, 0, 0)
        tabBtnText.BackgroundTransparency = 1
        tabBtnText.Text = tabName
        tabBtnText.TextColor3 = Aurora.Config.Colors.TextSecondary
        tabBtnText.TextSize = 13
        tabBtnText.Font = Enum.Font.GothamSemibold
        tabBtnText.TextXAlignment = Enum.TextXAlignment.Left
        tabBtnText.Parent = tabBtnContent

        -- Tab indicator (gradient line on left)
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Name = "Indicator"
        tabIndicator.Size = UDim2.new(0, 3, 0.7, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        tabIndicator.BackgroundColor3 = Aurora.Config.Colors.Primary
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tabButton

        Aurora.Utils.Round(tabIndicator, UDim.new(1, 0))
        Aurora.Utils.Gradient(tabIndicator)

        -- Tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName
        tabContent.Size = UDim2.new(1, -20, 1, -10)
        tabContent.Position = UDim2.new(0, 10, 0, 5)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Aurora.Config.Colors.Primary
        tabContent.ScrollBarImageTransparency = 0.5
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.Parent = tabContentContainer

        Aurora.Utils.Padding(tabContent, 5, 5, 5, 5)
        Aurora.Utils.ListLayout(tabContent, Enum.FillDirection.Vertical, 10)

        tab.Content = tabContent
        tab.Button = tabButton

        -- Tab click handler
        tabButton.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Aurora.Utils.Tween(tabButton, {BackgroundTransparency = 0.3})
                Aurora.Utils.Tween(tabBtnIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
                Aurora.Utils.Tween(tabBtnText, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Aurora.Utils.Tween(tabButton, {BackgroundTransparency = 0.5})
                Aurora.Utils.Tween(tabBtnIcon, {ImageColor3 = Aurora.Config.Colors.TextSecondary})
                Aurora.Utils.Tween(tabBtnText, {TextColor3 = Aurora.Config.Colors.TextSecondary})
            end
        end)

        -- Add to tabs
        table.insert(window.Tabs, tab)

        -- Auto select first tab
        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end

        -- Create section function
        function tab:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}

            local sectionName = sectionOptions.Name or "Section"

            local section = {
                Name = sectionName,
                Elements = {},
            }

            -- Section frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = sectionName
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            sectionFrame.BackgroundTransparency = 0.3
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = tabContent

            Aurora.Utils.Round(sectionFrame, UDim.new(0, 10))
            Aurora.Utils.Stroke(sectionFrame, Aurora.Config.Colors.GlassBorder, 1)

            -- Section header
            local sectionHeader = Instance.new("Frame")
            sectionHeader.Name = "Header"
            sectionHeader.Size = UDim2.new(1, 0, 0, 35)
            sectionHeader.BackgroundTransparency = 1
            sectionHeader.Parent = sectionFrame

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, -20, 1, 0)
            sectionTitle.Position = UDim2.new(0, 15, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 14
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionHeader

            -- Section content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Position = UDim2.new(0, 0, 0, 35)
            sectionContent.BackgroundTransparency = 1
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.Parent = sectionFrame

            Aurora.Utils.Padding(sectionContent, 10, 15, 15, 15)
            Aurora.Utils.ListLayout(sectionContent, Enum.FillDirection.Vertical, 8)

            section.Frame = sectionFrame
            section.Content = sectionContent

            table.insert(tab.Sections, section)

            return section
        end

        return tab
    end

    -- Select tab function
    function window:SelectTab(tab)
        if window.CurrentTab == tab then return end

        -- Deselect current tab
        if window.CurrentTab then
            window.CurrentTab.Content.Visible = false
            Aurora.Utils.Tween(window.CurrentTab.Button, {BackgroundTransparency = 0.5})

            local icon = window.CurrentTab.Button:FindFirstChild("Icon", true)
            local text = window.CurrentTab.Button:FindFirstChild("Text", true)
            local indicator = window.CurrentTab.Button.Indicator

            if icon then Aurora.Utils.Tween(icon, {ImageColor3 = Aurora.Config.Colors.TextSecondary}) end
            if text then Aurora.Utils.Tween(text, {TextColor3 = Aurora.Config.Colors.TextSecondary}) end
            if indicator then Aurora.Utils.Tween(indicator, {BackgroundTransparency = 1}) end
        end

        -- Select new tab
        window.CurrentTab = tab
        tab.Content.Visible = true
        Aurora.Utils.Tween(tab.Button, {BackgroundTransparency = 0.3})

        local icon = tab.Button:FindFirstChild("Icon", true)
        local text = tab.Button:FindFirstChild("Text", true)
        local indicator = tab.Button.Indicator

        if icon then Aurora.Utils.Tween(icon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}) end
        if text then Aurora.Utils.Tween(text, {TextColor3 = Color3.fromRGB(255, 255, 255)}) end
        if indicator then Aurora.Utils.Tween(indicator, {BackgroundTransparency = 0}) end
    end

    -- Notification function
    function window:Notify(options)
        options = options or {}

        local title = options.Title or "Notification"
        local content = options.Content or ""
        local duration = options.Duration or 5
        local notifType = options.Type or "info" -- info, success, warning, error

        local colors = {
            info = Aurora.Config.Colors.Secondary,
            success = Aurora.Config.Colors.Success,
            warning = Aurora.Config.Colors.Warning,
            error = Aurora.Config.Colors.Error,
        }

        -- Notification frame
        local notifFrame = Instance.new("Frame")
        notifFrame.Name = "Notification"
        notifFrame.Size = UDim2.new(0, 300, 0, 80)
        notifFrame.Position = UDim2.new(1, 20, 1, -100)
        notifFrame.AnchorPoint = Vector2.new(1, 1)
        notifFrame.BackgroundColor3 = Aurora.Config.Colors.Glass
        notifFrame.BorderSizePixel = 0
        notifFrame.Parent = screenGui

        Aurora.Utils.Round(notifFrame, UDim.new(0, 10))
        Aurora.Utils.Stroke(notifFrame, colors[notifType] or colors.info, 2)

        -- Accent line
        local accentLine = Instance.new("Frame")
        accentLine.Name = "Accent"
        accentLine.Size = UDim2.new(0, 4, 1, 0)
        accentLine.BackgroundColor3 = colors[notifType] or colors.info
        accentLine.BorderSizePixel = 0
        accentLine.Parent = notifFrame

        Aurora.Utils.Round(accentLine, UDim.new(0, 4))

        -- Content
        local notifTitle = Instance.new("TextLabel")
        notifTitle.Name = "Title"
        notifTitle.Size = UDim2.new(1, -30, 0, 25)
        notifTitle.Position = UDim2.new(0, 20, 0, 10)
        notifTitle.BackgroundTransparency = 1
        notifTitle.Text = title
        notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifTitle.TextSize = 14
        notifTitle.Font = Enum.Font.GothamBold
        notifTitle.TextXAlignment = Enum.TextXAlignment.Left
        notifTitle.Parent = notifFrame

        local notifContent = Instance.new("TextLabel")
        notifContent.Name = "Content"
        notifContent.Size = UDim2.new(1, -30, 0, 35)
        notifContent.Position = UDim2.new(0, 20, 0, 35)
        notifContent.BackgroundTransparency = 1
        notifContent.Text = content
        notifContent.TextColor3 = Aurora.Config.Colors.TextSecondary
        notifContent.TextSize = 12
        notifContent.Font = Enum.Font.Gotham
        notifContent.TextXAlignment = Enum.TextXAlignment.Left
        notifContent.TextWrapped = true
        notifContent.Parent = notifFrame

        -- Animate in
        Aurora.Utils.Tween(notifFrame, {Position = UDim2.new(1, -20, 1, -100)}, 0.5)

        -- Animate out
        task.delay(duration, function()
            Aurora.Utils.Tween(notifFrame, {Position = UDim2.new(1, 20, 1, -100)}, 0.5, function()
                notifFrame:Destroy()
            end)
        end)
    end

    return window
end

-- ============================================
-- UI COMPONENTS
-- ============================================

-- Button
function Aurora.Components.Button(section, options)
    options = options or {}

    local text = options.Text or "Button"
    local callback = options.Callback or function() end

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    button.BackgroundColor3 = Aurora.Config.Colors.Primary
    button.BackgroundTransparency = 0.5
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.Parent = section.Content

    Aurora.Utils.Round(button, UDim.new(0, 8))
    Aurora.Utils.Gradient(button)

    button.MouseButton1Click:Connect(function()
        Aurora.Utils.Ripple(button, button.AbsoluteSize.X / 2, button.AbsoluteSize.Y / 2)
        callback()
    end)

    button.MouseEnter:Connect(function()
        Aurora.Utils.Tween(button, {BackgroundTransparency = 0.2})
    end)

    button.MouseLeave:Connect(function()
        Aurora.Utils.Tween(button, {BackgroundTransparency = 0.5})
    end)

    return button
end

-- Toggle
function Aurora.Components.Toggle(section, options)
    options = options or {}

    local text = options.Text or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end

    local value = default

    local container = Instance.new("Frame")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleFrame = Instance.new("TextButton")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(0, 44, 0, 24)
    toggleFrame.Position = UDim2.new(1, -5, 0.5, 0)
    toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
    toggleFrame.BackgroundColor3 = default and Aurora.Config.Colors.Success or Color3.fromRGB(50, 50, 70)
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.Text = ""
    toggleFrame.Parent = container

    Aurora.Utils.Round(toggleFrame, UDim.new(1, 0))

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = default and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleFrame

    Aurora.Utils.Round(toggleCircle, UDim.new(1, 0))

    toggleFrame.MouseButton1Click:Connect(function()
        value = not value

        Aurora.Utils.Tween(toggleFrame, {
            BackgroundColor3 = value and Aurora.Config.Colors.Success or Color3.fromRGB(50, 50, 70)
        })

        Aurora.Utils.Tween(toggleCircle, {
            Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        })

        callback(value)
    end)

    return {
        SetValue = function(newValue)
            value = newValue
            Aurora.Utils.Tween(toggleFrame, {
                BackgroundColor3 = value and Aurora.Config.Colors.Success or Color3.fromRGB(50, 50, 70)
            })
            Aurora.Utils.Tween(toggleCircle, {
                Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            })
            callback(value)
        end,
        GetValue = function() return value end
    }
end

-- Slider
function Aurora.Components.Slider(section, options)
    options = options or {}

    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local decimals = options.Decimals or 0
    local callback = options.Callback or function() end

    local value = default

    local container = Instance.new("Frame")
    container.Name = "Slider"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + 10)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -5, 0, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Aurora.Config.Colors.Secondary
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 1, -8)
    sliderBg.AnchorPoint = Vector2.new(0, 1)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container

    Aurora.Utils.Round(sliderBg, UDim.new(1, 0))

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Aurora.Config.Colors.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    Aurora.Utils.Round(sliderFill, UDim.new(1, 0))
    Aurora.Utils.Gradient(sliderFill)

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Name = "SliderBtn"
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderBg

    local dragging = false

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        value = math.floor(value * (10 ^ decimals)) / (10 ^ decimals)

        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return {
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end,
        GetValue = function() return value end
    }
end

-- Dropdown
function Aurora.Components.Dropdown(section, options)
    options = options or {}

    local text = options.Text or "Dropdown"
    local items = options.Items or {}
    local default = options.Default or items[1] or "Select..."
    local callback = options.Callback or function() end

    local value = default
    local isOpen = false

    local container = Instance.new("Frame")
    container.Name = "Dropdown"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownBtn"
    dropdownBtn.Size = UDim2.new(1, 0, 0, 30)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 20)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    dropdownBtn.BackgroundTransparency = 0.3
    dropdownBtn.Text = ""
    dropdownBtn.Parent = container

    Aurora.Utils.Round(dropdownBtn, UDim.new(0, 8))
    Aurora.Utils.Stroke(dropdownBtn, Aurora.Config.Colors.GlassBorder, 1)

    local selectedText = Instance.new("TextLabel")
    selectedText.Name = "SelectedText"
    selectedText.Size = UDim2.new(1, -30, 1, 0)
    selectedText.Position = UDim2.new(0, 10, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = default
    selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedText.TextSize = 13
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.Parent = dropdownBtn

    local arrowIcon = Instance.new("TextLabel")
    arrowIcon.Name = "Arrow"
    arrowIcon.Size = UDim2.new(0, 20, 1, 0)
    arrowIcon.Position = UDim2.new(1, -25, 0, 0)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Text = "▼"
    arrowIcon.TextColor3 = Aurora.Config.Colors.TextSecondary
    arrowIcon.TextSize = 10
    arrowIcon.Font = Enum.Font.GothamBold
    arrowIcon.Parent = dropdownBtn

    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 0, 55)
    dropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    dropdownList.BackgroundTransparency = 0.3
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = container

    Aurora.Utils.Round(dropdownList, UDim.new(0, 8))
    Aurora.Utils.Stroke(dropdownList, Aurora.Config.Colors.GlassBorder, 1)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList

    local function refreshItems()
        -- Clear existing items
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        -- Add items
        for _, item in pairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Name = "Item"
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = item == value and Aurora.Config.Colors.Primary or Color3.fromRGB(30, 30, 50)
            itemBtn.BackgroundTransparency = 0.5
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 13
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = dropdownList

            Aurora.Utils.Round(itemBtn, UDim.new(0, 6))

            itemBtn.MouseButton1Click:Connect(function()
                value = item
                selectedText.Text = item
                callback(item)

                -- Close dropdown
                isOpen = false
                Aurora.Utils.Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)})
                Aurora.Utils.Tween(arrowIcon, {Text = "▼"})
                refreshItems()
            end)

            itemBtn.MouseEnter:Connect(function()
                if item ~= value then
                    Aurora.Utils.Tween(itemBtn, {BackgroundColor3 = Aurora.Config.Colors.Secondary})
                end
            end)

            itemBtn.MouseLeave:Connect(function()
                if item ~= value then
                    Aurora.Utils.Tween(itemBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 50)})
                end
            end)
        end
    end

    refreshItems()

    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        if isOpen then
            local listHeight = 32 * #items + 10
            Aurora.Utils.Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + listHeight)})
            Aurora.Utils.Tween(arrowIcon, {Text = "▲"})
        else
            Aurora.Utils.Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)})
            Aurora.Utils.Tween(arrowIcon, {Text = "▼"})
        end
    end)

    return {
        SetValue = function(newValue)
            value = newValue
            selectedText.Text = newValue
            refreshItems()
            callback(newValue)
        end,
        GetValue = function() return value end,
        Refresh = function(newItems)
            items = newItems
            refreshItems()
        end
    }
end

-- Color Picker
function Aurora.Components.ColorPicker(section, options)
    options = options or {}

    local text = options.Text or "Color"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local callback = options.Callback or function() end

    local color = default

    local container = Instance.new("Frame")
    container.Name = "ColorPicker"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local colorBtn = Instance.new("TextButton")
    colorBtn.Name = "ColorBtn"
    colorBtn.Size = UDim2.new(0, 40, 0, 25)
    colorBtn.Position = UDim2.new(1, -5, 0.5, 0)
    colorBtn.AnchorPoint = Vector2.new(1, 0.5)
    colorBtn.BackgroundColor3 = default
    colorBtn.Text = ""
    colorBtn.Parent = container

    Aurora.Utils.Round(colorBtn, UDim.new(0, 6))
    Aurora.Utils.Stroke(colorBtn, Color3.fromRGB(255, 255, 255), 1)

    -- Color picker popup
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "ColorPickerPopup"
    pickerFrame.Size = UDim2.new(0, 200, 0, 220)
    pickerFrame.Position = UDim2.new(1, -205, 0, 30)
    pickerFrame.BackgroundColor3 = Aurora.Config.Colors.Glass
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 100
    pickerFrame.Parent = container

    Aurora.Utils.Round(pickerFrame, UDim.new(0, 10))
    Aurora.Utils.Stroke(pickerFrame, Aurora.Config.Colors.GlassBorder, 1)

    -- Hue slider
    local hueFrame = Instance.new("Frame")
    hueFrame.Name = "HueFrame"
    hueFrame.Size = UDim2.new(1, -20, 0, 20)
    hueFrame.Position = UDim2.new(0, 10, 0, 150)
    hueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueFrame.BorderSizePixel = 0
    hueFrame.Parent = pickerFrame

    Aurora.Utils.Round(hueFrame, UDim.new(0, 6))

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueFrame

    -- Saturation/Value picker
    local svFrame = Instance.new("ImageLabel")
    svFrame.Name = "SVFrame"
    svFrame.Size = UDim2.new(1, -20, 0, 130)
    svFrame.Position = UDim2.new(0, 10, 0, 10)
    svFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    svFrame.BorderSizePixel = 0
    svFrame.Image = "rbxassetid://4155801252" -- White gradient overlay
    svFrame.Parent = pickerFrame

    Aurora.Utils.Round(svFrame, UDim.new(0, 6))

    -- Color preview
    local preview = Instance.new("Frame")
    preview.Name = "Preview"
    preview.Size = UDim2.new(1, -20, 0, 25)
    preview.Position = UDim2.new(0, 10, 0, 180)
    preview.BackgroundColor3 = default
    preview.BorderSizePixel = 0
    preview.Parent = pickerFrame

    Aurora.Utils.Round(preview, UDim.new(0, 6))

    -- Open/close picker
    colorBtn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = not pickerFrame.Visible
    end)

    -- Basic hue selection
    local hueDragging = false
    local hue, sat, val = 0, 1, 1

    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
        end
    end)

    hueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if hueDragging then
                local pos = math.clamp((input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
                hue = pos * 360

                -- Update color
                color = Color3.fromHSV(hue / 360, sat, val)
                colorBtn.BackgroundColor3 = color
                preview.BackgroundColor3 = color
                svFrame.BackgroundColor3 = Color3.fromHSV(hue / 360, 1, 1)
                callback(color)
            end
        end
    end)

    return {
        SetValue = function(newColor)
            color = newColor
            colorBtn.BackgroundColor3 = color
            callback(color)
        end,
        GetValue = function() return color end
    }
end

-- Keybind
function Aurora.Components.Keybind(section, options)
    options = options or {}

    local text = options.Text or "Keybind"
    local default = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end

    local key = default
    local listening = false

    local container = Instance.new("Frame")
    container.Name = "Keybind"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "KeyBtn"
    keyBtn.Size = UDim2.new(0, 70, 0, 28)
    keyBtn.Position = UDim2.new(1, -5, 0.5, 0)
    keyBtn.AnchorPoint = Vector2.new(1, 0.5)
    keyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    keyBtn.BackgroundTransparency = 0.3
    keyBtn.Text = key.Name
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextSize = 12
    keyBtn.Font = Enum.Font.GothamSemibold
    keyBtn.Parent = container

    Aurora.Utils.Round(keyBtn, UDim.new(0, 6))
    Aurora.Utils.Stroke(keyBtn, Aurora.Config.Colors.GlassBorder, 1)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Aurora.Config.Colors.Primary
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                keyBtn.Text = key.Name
                keyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                listening = false
                callback(key)
            end
        elseif key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
            callback(key)
        end
    end)

    return {
        SetKey = function(newKey)
            key = newKey
            keyBtn.Text = key.Name
            callback(key)
        end,
        GetKey = function() return key end
    }
end

-- Textbox
function Aurora.Components.Textbox(section, options)
    options = options or {}

    local text = options.Text or "Textbox"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local numeric = options.Numeric or false
    local callback = options.Callback or function() end

    local value = default

    local container = Instance.new("Frame")
    container.Name = "Textbox"
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + 5)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Name = "Input"
    textbox.Size = UDim2.new(1, 0, 0, 28)
    textbox.Position = UDim2.new(0, 0, 0, 22)
    textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    textbox.BackgroundTransparency = 0.3
    textbox.Text = default
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = Aurora.Config.Colors.TextMuted
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.TextSize = 13
    textbox.Font = Enum.Font.Gotham
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Parent = container

    Aurora.Utils.Round(textbox, UDim.new(0, 6))
    Aurora.Utils.Stroke(textbox, Aurora.Config.Colors.GlassBorder, 1)
    Aurora.Utils.Padding(textbox, 0, 0, 10, 10)

    textbox.FocusLost:Connect(function(enterPressed)
        if numeric then
            value = tonumber(textbox.Text) or 0
            textbox.Text = tostring(value)
        else
            value = textbox.Text
        end
        callback(value)
    end)

    return {
        SetValue = function(newValue)
            value = newValue
            textbox.Text = tostring(newValue)
            callback(value)
        end,
        GetValue = function() return value end
    }
end

-- Label
function Aurora.Components.Label(section, options)
    options = options or {}

    local text = options.Text or "Label"

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Aurora.Config.Colors.TextSecondary
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = section.Content

    label:GetPropertyChangedSignal("TextBounds"):Connect(function()
        label.Size = UDim2.new(1, 0, 0, label.TextBounds.Y + 5)
    end)

    return {
        SetText = function(newText)
            label.Text = newText
        end
    }
end

-- Paragraph
function Aurora.Components.Paragraph(section, options)
    options = options or {}

    local title = options.Title or "Title"
    local content = options.Content or "Content"

    local container = Instance.new("Frame")
    container.Name = "Paragraph"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section.Content

    Aurora.Utils.Round(container, UDim.new(0, 8))
    Aurora.Utils.Padding(container, 12, 12, 12, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.Position = UDim2.new(0, 0, 0, 22)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Parent = container

    return {
        SetTitle = function(newTitle)
            titleLabel.Text = newTitle
        end,
        SetContent = function(newContent)
            contentLabel.Text = newContent
        end
    }
end

-- Divider
function Aurora.Components.Divider(section)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Aurora.Config.Colors.GlassBorder
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = section.Content

    return divider
end

-- Player Info Card
function Aurora.Components.PlayerInfo(section, options)
    options = options or {}

    local playerInfo = Aurora.Utils.GetPlayerInfo()
    local executorInfo = Aurora.Utils.GetExecutorInfo()

    local container = Instance.new("Frame")
    container.Name = "PlayerInfo"
    container.Size = UDim2.new(1, 0, 0, 100)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = section.Content

    Aurora.Utils.Round(container, UDim.new(0, 10))
    Aurora.Utils.Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Aurora.Utils.Padding(container, 12, 12, 12, 12)

    -- Avatar
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 60, 0, 60)
    avatar.Position = UDim2.new(0, 12, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.BackgroundColor3 = Aurora.Config.Colors.Primary
    avatar.Image = playerInfo.Thumbnail
    avatar.Parent = container

    Aurora.Utils.Round(avatar, UDim.new(0, 10))
    Aurora.Utils.Stroke(avatar, Aurora.Config.Colors.Secondary, 2)

    -- Info container
    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -90, 1, 0)
    infoContainer.Position = UDim2.new(0, 85, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    -- Username
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, 0, 0, 20)
    username.BackgroundTransparency = 1
    username.Text = playerInfo.DisplayName .. " (@" .. playerInfo.Username .. ")"
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 14
    username.Font = Enum.Font.GothamBold
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = infoContainer

    -- User ID
    local userId = Instance.new("TextLabel")
    userId.Name = "UserId"
    userId.Size = UDim2.new(1, 0, 0, 16)
    userId.Position = UDim2.new(0, 0, 0, 22)
    userId.BackgroundTransparency = 1
    userId.Text = "User ID: " .. playerInfo.UserId
    userId.TextColor3 = Aurora.Config.Colors.TextSecondary
    userId.TextSize = 11
    userId.Font = Enum.Font.Gotham
    userId.TextXAlignment = Enum.TextXAlignment.Left
    userId.Parent = infoContainer

    -- Account Age
    local accountAge = Instance.new("TextLabel")
    accountAge.Name = "AccountAge"
    accountAge.Size = UDim2.new(1, 0, 0, 16)
    accountAge.Position = UDim2.new(0, 0, 0, 38)
    accountAge.BackgroundTransparency = 1
    accountAge.Text = "Account Age: " .. playerInfo.AccountAgeFormatted
    accountAge.TextColor3 = Aurora.Config.Colors.TextSecondary
    accountAge.TextSize = 11
    accountAge.Font = Enum.Font.Gotham
    accountAge.TextXAlignment = Enum.TextXAlignment.Left
    accountAge.Parent = infoContainer

    -- Membership
    local membership = Instance.new("TextLabel")
    membership.Name = "Membership"
    membership.Size = UDim2.new(1, 0, 0, 16)
    membership.Position = UDim2.new(0, 0, 0, 54)
    membership.BackgroundTransparency = 1
    membership.Text = "Membership: " .. playerInfo.Membership
    membership.TextColor3 = playerInfo.Membership == "Premium" and Aurora.Config.Colors.Warning or Aurora.Config.Colors.TextSecondary
    membership.TextSize = 11
    membership.Font = Enum.Font.Gotham
    membership.TextXAlignment = Enum.TextXAlignment.Left
    membership.Parent = infoContainer

    return container
end

-- Executor Info Card
function Aurora.Components.ExecutorInfo(section, options)
    options = options or {}

    local executorInfo = Aurora.Utils.GetExecutorInfo()

    local container = Instance.new("Frame")
    container.Name = "ExecutorInfo"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = section.Content

    Aurora.Utils.Round(container, UDim.new(0, 10))
    Aurora.Utils.Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Aurora.Utils.Padding(container, 12, 12, 12, 12)

    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.BackgroundColor3 = Aurora.Config.Colors.Primary
    icon.BackgroundTransparency = 0.5
    icon.Text = "⚡"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container

    Aurora.Utils.Round(icon, UDim.new(0, 8))
    Aurora.Utils.Gradient(icon)

    -- Info
    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -50, 1, 0)
    infoContainer.Position = UDim2.new(0, 45, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    -- Name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, 0, 0, 20)
    name.BackgroundTransparency = 1
    name.Text = executorInfo.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = 14
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = infoContainer

    -- Version
    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(1, 0, 0, 16)
    version.Position = UDim2.new(0, 0, 0, 22)
    version.BackgroundTransparency = 1
    version.Text = "Version: " .. executorInfo.Version
    version.TextColor3 = Aurora.Config.Colors.TextSecondary
    version.TextSize = 11
    version.Font = Enum.Font.Gotham
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = infoContainer

    return container
end

-- Game Info Card
function Aurora.Components.GameInfo(section, options)
    options = options or {}

    local gameInfo = Aurora.Utils.GetGameInfo()

    local container = Instance.new("Frame")
    container.Name = "GameInfo"
    container.Size = UDim2.new(1, 0, 0, 90)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = section.Content

    Aurora.Utils.Round(container, UDim.new(0, 10))
    Aurora.Utils.Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Aurora.Utils.Padding(container, 12, 12, 12, 12)

    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.BackgroundColor3 = Aurora.Config.Colors.Secondary
    icon.BackgroundTransparency = 0.5
    icon.Text = "🎮"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 20
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container

    Aurora.Utils.Round(icon, UDim.new(0, 8))
    Aurora.Utils.Gradient(icon, Aurora.Config.Colors.Secondary, Aurora.Config.Colors.Primary)

    -- Info
    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -50, 1, 0)
    infoContainer.Position = UDim2.new(0, 45, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    -- Game Name
    local gameName = Instance.new("TextLabel")
    gameName.Name = "GameName"
    gameName.Size = UDim2.new(1, 0, 0, 20)
    gameName.BackgroundTransparency = 1
    gameName.Text = gameInfo.GameName
    gameName.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameName.TextSize = 14
    gameName.Font = Enum.Font.GothamBold
    gameName.TextXAlignment = Enum.TextXAlignment.Left
    gameName.Parent = infoContainer

    -- Place ID
    local placeId = Instance.new("TextLabel")
    placeId.Name = "PlaceId"
    placeId.Size = UDim2.new(1, 0, 0, 16)
    placeId.Position = UDim2.new(0, 0, 0, 22)
    placeId.BackgroundTransparency = 1
    placeId.Text = "Place ID: " .. gameInfo.PlaceId
    placeId.TextColor3 = Aurora.Config.Colors.TextSecondary
    placeId.TextSize = 11
    placeId.Font = Enum.Font.Gotham
    placeId.TextXAlignment = Enum.TextXAlignment.Left
    placeId.Parent = infoContainer

    -- Job ID
    local jobId = Instance.new("TextLabel")
    jobId.Name = "JobId"
    jobId.Size = UDim2.new(1, 0, 0, 16)
    jobId.Position = UDim2.new(0, 0, 0, 38)
    jobId.BackgroundTransparency = 1
    jobId.Text = "Job ID: " .. string.sub(gameInfo.JobId, 1, 20) .. "..."
    jobId.TextColor3 = Aurora.Config.Colors.TextSecondary
    jobId.TextSize = 11
    jobId.Font = Enum.Font.Gotham
    jobId.TextXAlignment = Enum.TextXAlignment.Left
    jobId.Parent = infoContainer

    -- Server Type
    local serverType = Instance.new("TextLabel")
    serverType.Name = "ServerType"
    serverType.Size = UDim2.new(1, 0, 0, 16)
    serverType.Position = UDim2.new(0, 0, 0, 54)
    serverType.BackgroundTransparency = 1
    serverType.Text = "Server: " .. gameInfo.InstanceName
    serverType.TextColor3 = Aurora.Config.Colors.TextSecondary
    serverType.TextSize = 11
    serverType.Font = Enum.Font.Gotham
    serverType.TextXAlignment = Enum.TextXAlignment.Left
    serverType.Parent = infoContainer

    return container
end

-- Time Display
function Aurora.Components.TimeDisplay(section, options)
    options = options or {}

    local container = Instance.new("Frame")
    container.Name = "TimeDisplay"
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = section.Content

    Aurora.Utils.Round(container, UDim.new(0, 10))
    Aurora.Utils.Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Aurora.Utils.Padding(container, 12, 12, 12, 12)

    -- Time
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(1, 0, 0, 30)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "00:00:00 AM"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextSize = 24
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.Parent = container

    -- Date
    local dateLabel = Instance.new("TextLabel")
    dateLabel.Name = "Date"
    dateLabel.Size = UDim2.new(1, 0, 0, 20)
    dateLabel.Position = UDim2.new(0, 0, 0, 35)
    dateLabel.BackgroundTransparency = 1
    dateLabel.Text = "Monday, 01/01/2024"
    dateLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
    dateLabel.TextSize = 12
    dateLabel.Font = Enum.Font.Gotham
    dateLabel.TextXAlignment = Enum.TextXAlignment.Center
    dateLabel.Parent = container

    -- Update time
    coroutine.wrap(function()
        while container and container.Parent do
            local timeData = Aurora.Utils.FormatTime()
            timeLabel.Text = timeData.Time
            dateLabel.Text = timeData.Day .. ", " .. timeData.Date
            wait(1)
        end
    end)()

    return container
end

-- ============================================
-- EXPORT
-- ============================================
Aurora.Version = "1.0.0"
Aurora.Name = "Aurora Library"

return Aurora
