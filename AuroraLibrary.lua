local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- AURORA LIBRARY
-- ============================================
local Aurora = {}

Aurora.Config = {
    Colors = {
        Primary = Color3.fromRGB(138, 43, 226),
        Secondary = Color3.fromRGB(0, 195, 255),
        Accent = Color3.fromRGB(255, 0, 127),
        Success = Color3.fromRGB(0, 255, 136),
        Warning = Color3.fromRGB(255, 170, 0),
        Error = Color3.fromRGB(255, 65, 65),
        Background = Color3.fromRGB(15, 15, 25),
        BackgroundLight = Color3.fromRGB(25, 25, 40),
        Glass = Color3.fromRGB(20, 20, 35),
        GlassBorder = Color3.fromRGB(60, 60, 100),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextMuted = Color3.fromRGB(120, 120, 140),
    },
    Sizes = {
        WindowWidth = 620,
        WindowHeight = 420,
        SidebarWidth = 170,
        ElementHeight = 34,
        CornerRadius = UDim.new(0, 10),
    },
    Animation = {
        Duration = 0.25,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out,
    },
}

-- ============================================
-- UTILITIES
-- ============================================
local function Round(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = frame
    return corner
end

local function Stroke(frame, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Aurora.Config.Colors.GlassBorder
    stroke.Thickness = thickness or 1
    stroke.Parent = frame
    return stroke
end

local function Gradient(frame, startColor, endColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor or Aurora.Config.Colors.Primary),
        ColorSequenceKeypoint.new(1, endColor or Aurora.Config.Colors.Secondary)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = frame
    return gradient
end

local function Padding(frame, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingBottom = UDim.new(0, bottom or 8)
    padding.PaddingLeft = UDim.new(0, left or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.Parent = frame
    return padding
end

local function Tween(instance, properties, duration, callback)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or Aurora.Config.Animation.Duration, Aurora.Config.Animation.EasingStyle, Aurora.Config.Animation.EasingDirection),
        properties
    )
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

local function Ripple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.ZIndex = 100
    ripple.Parent = button
    Round(ripple, UDim.new(1, 0))
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.4, function()
        ripple:Destroy()
    end)
end

local function GetExecutorInfo()
    local info = {Name = "Unknown", Version = "Unknown"}
    local syn = syn or {}
    
    if syn and syn.request then
        info.Name = "Synapse X"
        info.Version = "v2.4.8"
    elseif KRNL then
        info.Name = "KRNL"
        info.Version = "v1.5.6"
    elseif UNC then
        info.Name = "UNC"
        info.Version = "Universal"
    elseif scriptware then
        info.Name = "Script-Ware"
        info.Version = "v1.2.5"
    elseif identifyexecutor then
        local name, version = identifyexecutor()
        info.Name = name or "Unknown"
        info.Version = version or "Unknown"
    end
    
    return info
end

local function GetPlayerInfo()
    local player = LocalPlayer
    local years = math.floor(player.AccountAge / 365)
    local days = player.AccountAge % 365
    
    return {
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        AccountAge = player.AccountAge,
        AccountAgeFormatted = string.format("%d years, %d days", years, days),
        Membership = player.MembershipType.Name,
        Thumbnail = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100),
    }
end

local function GetGameInfo()
    return {
        GameName = game.Name or "Unknown",
        PlaceId = game.PlaceId or 0,
        JobId = game.JobId or "",
        ServerType = game.JobId ~= "" and "Private Server" or "Public Server",
    }
end

local function FormatTime()
    local d = os.date("*t")
    local h = d.hour
    local ampm = h >= 12 and "PM" or "AM"
    h = h % 12
    h = h == 0 and 12 or h
    
    return {
        Time = string.format("%02d:%02d:%02d %s", h, d.min, d.sec, ampm),
        Date = string.format("%02d/%02d/%04d", d.day, d.month, d.year),
        Day = os.date("%A"),
    }
end

-- ============================================
-- LOADING SCREEN
-- ============================================
function Aurora.LoadingScreen(options)
    options = options or {}
    local duration = options.Duration or 3
    local onComplete = options.OnComplete or function() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraLoading"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Aurora.Config.Colors.Background
    bg.BorderSizePixel = 0
    bg.Parent = screenGui

    local gradientBg = Instance.new("Frame")
    gradientBg.Size = UDim2.new(2, 0, 2, 0)
    gradientBg.Position = UDim2.new(-0.5, 0, -0.5, 0)
    gradientBg.BackgroundColor3 = Aurora.Config.Colors.Primary
    gradientBg.BackgroundTransparency = 0.92
    gradientBg.BorderSizePixel = 0
    gradientBg.Parent = bg

    local auroraGradient = Instance.new("UIGradient")
    auroraGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 195, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 127))
    })
    auroraGradient.Rotation = 45
    auroraGradient.Parent = gradientBg

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 350, 0, 180)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = bg

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 55)
    logo.Position = UDim2.new(0.5, 0, 0.32, 0)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.BackgroundTransparency = 1
    logo.Text = "A U R O R A"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 45
    logo.Font = Enum.Font.GothamBold
    logo.Parent = container
    Gradient(logo)

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0.5, 0, 0.52, 0)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "L I B R A R Y"
    subtitle.TextColor3 = Aurora.Config.Colors.TextSecondary
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.GothamBold
    subtitle.Parent = container

    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.Size = UDim2.new(0.75, 0, 0, 5)
    loadingBarBg.Position = UDim2.new(0.5, 0, 0.72, 0)
    loadingBarBg.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingBarBg.BackgroundColor3 = Aurora.Config.Colors.BackgroundLight
    loadingBarBg.BorderSizePixel = 0
    loadingBarBg.Parent = container
    Round(loadingBarBg, UDim.new(1, 0))

    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BackgroundColor3 = Aurora.Config.Colors.Primary
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBarBg
    Round(loadingBar, UDim.new(1, 0))
    Gradient(loadingBar)

    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 22)
    loadingText.Position = UDim2.new(0.5, 0, 0.85, 0)
    loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Initializing..."
    loadingText.TextColor3 = Aurora.Config.Colors.TextSecondary
    loadingText.TextSize = 11
    loadingText.Font = Enum.Font.GothamSemibold
    loadingText.Parent = container

    -- Rotate gradient
    local rotation = 0
    local connection = RunService.Heartbeat:Connect(function()
        rotation = rotation + 0.4
        auroraGradient.Rotation = rotation % 360
    end)

    local messages = {"Initializing Aurora...", "Loading modules...", "Preparing UI...", "Almost ready...", "Welcome!"}
    
    for i, msg in ipairs(messages) do
        wait(duration / #messages)
        loadingText.Text = msg
        Tween(loadingBar, {Size = UDim2.new(i / #messages, 0, 1, 0)}, 0.25)
    end
    
    wait(0.3)
    connection:Disconnect()
    Tween(bg, {BackgroundTransparency = 1}, 0.4)
    wait(0.4)
    screenGui:Destroy()
    onComplete()
end

-- ============================================
-- CREATE WINDOW
-- ============================================
function Aurora:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Aurora Library"
    local subtitle = options.Subtitle or "v1.0.0"

    local window = {
        Tabs = {},
        CurrentTab = nil,
        Open = true,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraWindow"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    window.ScreenGui = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, Aurora.Config.Sizes.WindowWidth, 0, Aurora.Config.Sizes.WindowHeight)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Aurora.Config.Colors.Glass
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    window.MainFrame = mainFrame

    Round(mainFrame, Aurora.Config.Sizes.CornerRadius)
    Stroke(mainFrame, Aurora.Config.Colors.GlassBorder, 1)

    -- Animated gradient overlay
    local gradientOverlay = Instance.new("Frame")
    gradientOverlay.Name = "GradientOverlay"
    gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    gradientOverlay.BackgroundColor3 = Aurora.Config.Colors.Primary
    gradientOverlay.BackgroundTransparency = 0.96
    gradientOverlay.BorderSizePixel = 0
    gradientOverlay.Parent = mainFrame
    Round(gradientOverlay, Aurora.Config.Sizes.CornerRadius)

    local overlayGradient = Instance.new("UIGradient")
    overlayGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Aurora.Config.Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Aurora.Config.Colors.Secondary),
        ColorSequenceKeypoint.new(1, Aurora.Config.Colors.Accent)
    })
    overlayGradient.Rotation = 45
    overlayGradient.Parent = gradientOverlay

    coroutine.wrap(function()
        local rot = 0
        while mainFrame and mainFrame.Parent do
            rot = rot + 0.25
            overlayGradient.Rotation = rot % 360
            wait(0.016)
        end
    end)()

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Aurora.Config.Sizes.SidebarWidth, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    sidebar.BackgroundTransparency = 0.4
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    Round(sidebar, Aurora.Config.Sizes.CornerRadius)

    -- Fix sidebar corner
    local sidebarFix = Instance.new("Frame")
    sidebarFix.Size = UDim2.new(0, Aurora.Config.Sizes.CornerRadius.Offset, 1, 0)
    sidebarFix.Position = UDim2.new(1, -Aurora.Config.Sizes.CornerRadius.Offset, 0, 0)
    sidebarFix.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    sidebarFix.BackgroundTransparency = 0.4
    sidebarFix.BorderSizePixel = 0
    sidebarFix.Parent = sidebar

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundTransparency = 1
    header.Parent = sidebar

    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, -12, 0, 28)
    logoText.Position = UDim2.new(0, 12, 0, 6)
    logoText.BackgroundTransparency = 1
    logoText.Text = "AURORA"
    logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    logoText.TextSize = 20
    logoText.Font = Enum.Font.GothamBold
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    logoText.Parent = header
    Gradient(logoText)

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "Subtitle"
    subtitleLabel.Size = UDim2.new(1, -12, 0, 16)
    subtitleLabel.Position = UDim2.new(0, 12, 0, 34)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = subtitle
    subtitleLabel.TextColor3 = Aurora.Config.Colors.TextMuted
    subtitleLabel.TextSize = 9
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Parent = header

    -- Tab Container
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, -105)
    tabContainer.Position = UDim2.new(0, 0, 0, 56)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ScrollBarThickness = 0
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = sidebar
    Padding(tabContainer, 4, 4, 4, 4)

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.Parent = tabContainer

    -- User Info Section
    local infoSection = Instance.new("Frame")
    infoSection.Name = "InfoSection"
    infoSection.Size = UDim2.new(1, 0, 0, 48)
    infoSection.Position = UDim2.new(0, 0, 1, -48)
    infoSection.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    infoSection.BackgroundTransparency = 0.25
    infoSection.BorderSizePixel = 0
    infoSection.Parent = sidebar
    Round(infoSection, Aurora.Config.Sizes.CornerRadius)

    local infoFix = Instance.new("Frame")
    infoFix.Size = UDim2.new(0, Aurora.Config.Sizes.CornerRadius.Offset, 1, 0)
    infoFix.Position = UDim2.new(1, -Aurora.Config.Sizes.CornerRadius.Offset, 0, 0)
    infoFix.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    infoFix.BackgroundTransparency = 0.25
    infoFix.BorderSizePixel = 0
    infoFix.Parent = infoSection

    local playerInfo = GetPlayerInfo()
    local executorInfo = GetExecutorInfo()

    local userAvatar = Instance.new("ImageLabel")
    userAvatar.Name = "Avatar"
    userAvatar.Size = UDim2.new(0, 30, 0, 30)
    userAvatar.Position = UDim2.new(0, 8, 0.5, 0)
    userAvatar.AnchorPoint = Vector2.new(0, 0.5)
    userAvatar.BackgroundColor3 = Aurora.Config.Colors.Primary
    userAvatar.Image = playerInfo.Thumbnail
    userAvatar.Parent = infoSection
    Round(userAvatar, UDim.new(1, 0))
    Stroke(userAvatar, Aurora.Config.Colors.Secondary, 1.5)

    local userName = Instance.new("TextLabel")
    userName.Name = "UserName"
    userName.Size = UDim2.new(1, -48, 0, 15)
    userName.Position = UDim2.new(0, 44, 0.5, -10)
    userName.BackgroundTransparency = 1
    userName.Text = playerInfo.DisplayName
    userName.TextColor3 = Color3.fromRGB(255, 255, 255)
    userName.TextSize = 11
    userName.Font = Enum.Font.GothamBold
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = infoSection

    local executorName = Instance.new("TextLabel")
    executorName.Name = "ExecutorName"
    executorName.Size = UDim2.new(1, -48, 0, 13)
    executorName.Position = UDim2.new(0, 44, 0.5, 5)
    executorName.BackgroundTransparency = 1
    executorName.Text = executorInfo.Name
    executorName.TextColor3 = Aurora.Config.Colors.Secondary
    executorName.TextSize = 9
    executorName.Font = Enum.Font.Gotham
    executorName.TextXAlignment = Enum.TextXAlignment.Left
    executorName.Parent = infoSection

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -Aurora.Config.Sizes.SidebarWidth, 1, 0)
    contentArea.Position = UDim2.new(0, Aurora.Config.Sizes.SidebarWidth, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    titleBar.BackgroundTransparency = 0.5
    titleBar.BorderSizePixel = 0
    titleBar.Parent = contentArea

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 13
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Aurora.Config.Colors.Error
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    Round(closeBtn, UDim.new(1, 0))

    closeBtn.MouseButton1Click:Connect(function()
        Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25, function()
            screenGui:Destroy()
        end)
    end)

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.4}) end)

    -- Tab Content Container
    local tabContentContainer = Instance.new("Frame")
    tabContentContainer.Name = "TabContentContainer"
    tabContentContainer.Size = UDim2.new(1, 0, 1, -40)
    tabContentContainer.Position = UDim2.new(0, 0, 0, 40)
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

    -- ============================================
    -- CREATE TAB FUNCTION
    -- ============================================
    function window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"

        local tab = {
            Name = tabName,
            Sections = {},
            Button = nil,
            Content = nil,
            Indicator = nil,
            Label = nil,
        }

        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabBtn_" .. tabName
        tabButton.Size = UDim2.new(1, 0, 0, 30)
        tabButton.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
        tabButton.BackgroundTransparency = 0.5
        tabButton.Text = ""
        tabButton.Parent = tabContainer
        Round(tabButton, UDim.new(0, 7))

        -- Indicator
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Name = "Indicator"
        tabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        tabIndicator.BackgroundColor3 = Aurora.Config.Colors.Primary
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tabButton
        Round(tabIndicator, UDim.new(1, 0))
        Gradient(tabIndicator)

        -- Tab Label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Size = UDim2.new(1, -10, 1, 0)
        tabLabel.Position = UDim2.new(0, 10, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
        tabLabel.TextSize = 12
        tabLabel.Font = Enum.Font.GothamSemibold
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton

        -- Store references
        tab.Button = tabButton
        tab.Indicator = tabIndicator
        tab.Label = tabLabel

        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "Content_" .. tabName
        tabContent.Size = UDim2.new(1, -16, 1, -8)
        tabContent.Position = UDim2.new(0, 8, 0, 4)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Aurora.Config.Colors.Primary
        tabContent.ScrollBarImageTransparency = 0.6
        tabContent.BorderSizePixel = 0
        tabContent.Visible = false
        tabContent.Parent = tabContentContainer
        Padding(tabContent, 4, 4, 4, 4)

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent

        tab.Content = tabContent

        -- Tab Click Handler
        tabButton.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        tabButton.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabButton, {BackgroundTransparency = 0.3})
                Tween(tabLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabButton, {BackgroundTransparency = 0.5})
                Tween(tabLabel, {TextColor3 = Aurora.Config.Colors.TextSecondary})
            end
        end)

        table.insert(window.Tabs, tab)

        -- Auto select first tab
        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end

        -- ============================================
        -- CREATE SECTION FUNCTION
        -- ============================================
        function tab:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"

            local section = {
                Name = sectionName,
                Frame = nil,
                Content = nil,
            }

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section_" .. sectionName
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            sectionFrame.BackgroundTransparency = 0.35
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = tabContent
            Round(sectionFrame, UDim.new(0, 8))
            Stroke(sectionFrame, Aurora.Config.Colors.GlassBorder, 1)

            local sectionHeader = Instance.new("Frame")
            sectionHeader.Name = "Header"
            sectionHeader.Size = UDim2.new(1, 0, 0, 28)
            sectionHeader.BackgroundTransparency = 1
            sectionHeader.Parent = sectionFrame

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, -12, 1, 0)
            sectionTitle.Position = UDim2.new(0, 12, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 12
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionHeader

            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
            sectionContent.Position = UDim2.new(0, 0, 0, 28)
            sectionContent.BackgroundTransparency = 1
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.Parent = sectionFrame
            Padding(sectionContent, 6, 10, 10, 10)

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 6)
            contentLayout.Parent = sectionContent

            section.Frame = sectionFrame
            section.Content = sectionContent

            table.insert(tab.Sections, section)

            return section
        end

        return tab
    end

    -- ============================================
    -- SELECT TAB FUNCTION
    -- ============================================
    function window:SelectTab(tab)
        if window.CurrentTab == tab then return end

        -- Deselect current tab
        if window.CurrentTab then
            local current = window.CurrentTab
            if current.Content then current.Content.Visible = false end
            if current.Button then Tween(current.Button, {BackgroundTransparency = 0.5}) end
            if current.Label then Tween(current.Label, {TextColor3 = Aurora.Config.Colors.TextSecondary}) end
            if current.Indicator then Tween(current.Indicator, {BackgroundTransparency = 1}) end
        end

        -- Select new tab
        window.CurrentTab = tab
        if tab.Content then tab.Content.Visible = true end
        if tab.Button then Tween(tab.Button, {BackgroundTransparency = 0.25}) end
        if tab.Label then Tween(tab.Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}) end
        if tab.Indicator then Tween(tab.Indicator, {BackgroundTransparency = 0}) end
    end

    -- ============================================
    -- NOTIFY FUNCTION
    -- ============================================
    function window:Notify(options)
        options = options or {}
        local nTitle = options.Title or "Notification"
        local content = options.Content or ""
        local duration = options.Duration or 4
        local notifType = options.Type or "info"

        local colors = {
            info = Aurora.Config.Colors.Secondary,
            success = Aurora.Config.Colors.Success,
            warning = Aurora.Config.Colors.Warning,
            error = Aurora.Config.Colors.Error,
        }

        local notifFrame = Instance.new("Frame")
        notifFrame.Name = "Notification"
        notifFrame.Size = UDim2.new(0, 260, 0, 65)
        notifFrame.Position = UDim2.new(1, 15, 1, -80)
        notifFrame.AnchorPoint = Vector2.new(1, 1)
        notifFrame.BackgroundColor3 = Aurora.Config.Colors.Glass
        notifFrame.BorderSizePixel = 0
        notifFrame.Parent = screenGui
        Round(notifFrame, UDim.new(0, 8))
        Stroke(notifFrame, colors[notifType] or colors.info, 1.5)

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = colors[notifType] or colors.info
        accent.BorderSizePixel = 0
        accent.Parent = notifFrame
        Round(accent, UDim.new(0, 3))

        local nTitleLabel = Instance.new("TextLabel")
        nTitleLabel.Name = "Title"
        nTitleLabel.Size = UDim2.new(1, -18, 0, 20)
        nTitleLabel.Position = UDim2.new(0, 12, 0, 8)
        nTitleLabel.BackgroundTransparency = 1
        nTitleLabel.Text = nTitle
        nTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nTitleLabel.TextSize = 12
        nTitleLabel.Font = Enum.Font.GothamBold
        nTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        nTitleLabel.Parent = notifFrame

        local nContent = Instance.new("TextLabel")
        nContent.Name = "Content"
        nContent.Size = UDim2.new(1, -18, 0, 28)
        nContent.Position = UDim2.new(0, 12, 0, 30)
        nContent.BackgroundTransparency = 1
        nContent.Text = content
        nContent.TextColor3 = Aurora.Config.Colors.TextSecondary
        nContent.TextSize = 11
        nContent.Font = Enum.Font.Gotham
        nContent.TextXAlignment = Enum.TextXAlignment.Left
        nContent.TextWrapped = true
        nContent.Parent = notifFrame

        Tween(notifFrame, {Position = UDim2.new(1, -10, 1, -80)}, 0.4)

        task.delay(duration, function()
            Tween(notifFrame, {Position = UDim2.new(1, 15, 1, -80)}, 0.4, function()
                notifFrame:Destroy()
            end)
        end)
    end

    return window
end

-- ============================================
-- UI COMPONENTS
-- ============================================
Aurora.Components = {}

-- Button
function Aurora.Components.Button(section, options)
    options = options or {}
    local text = options.Text or "Button"
    local callback = options.Callback or function() end

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)
    button.BackgroundColor3 = Aurora.Config.Colors.Primary
    button.BackgroundTransparency = 0.55
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamSemibold
    button.Parent = section.Content
    Round(button, UDim.new(0, 7))
    Gradient(button)

    button.MouseButton1Click:Connect(function()
        Ripple(button, button.AbsoluteSize.X / 2, button.AbsoluteSize.Y / 2)
        callback()
    end)

    button.MouseEnter:Connect(function() Tween(button, {BackgroundTransparency = 0.25}) end)
    button.MouseLeave:Connect(function() Tween(button, {BackgroundTransparency = 0.55}) end)

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
    label.Size = UDim2.new(1, -52, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleFrame = Instance.new("TextButton")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(0, 40, 0, 22)
    toggleFrame.Position = UDim2.new(1, -4, 0.5, 0)
    toggleFrame.AnchorPoint = Vector2.new(1, 0.5)
    toggleFrame.BackgroundColor3 = default and Aurora.Config.Colors.Success or Color3.fromRGB(45, 45, 65)
    toggleFrame.BackgroundTransparency = 0.35
    toggleFrame.Text = ""
    toggleFrame.Parent = container
    Round(toggleFrame, UDim.new(1, 0))

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleFrame
    Round(toggleCircle, UDim.new(1, 0))

    toggleFrame.MouseButton1Click:Connect(function()
        value = not value
        Tween(toggleFrame, {BackgroundColor3 = value and Aurora.Config.Colors.Success or Color3.fromRGB(45, 45, 65)})
        Tween(toggleCircle, {Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
        callback(value)
    end)

    return {
        SetValue = function(newValue)
            value = newValue
            Tween(toggleFrame, {BackgroundColor3 = value and Aurora.Config.Colors.Success or Color3.fromRGB(45, 45, 65)})
            Tween(toggleCircle, {Position = value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
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
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + 8)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 42, 0, 16)
    valueLabel.Position = UDim2.new(1, -4, 0, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Aurora.Config.Colors.Secondary
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, 0, 0, 5)
    sliderBg.Position = UDim2.new(0, 0, 1, -5)
    sliderBg.AnchorPoint = Vector2.new(0, 1)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Round(sliderBg, UDim.new(1, 0))

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Aurora.Config.Colors.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Round(sliderFill, UDim.new(1, 0))
    Gradient(sliderFill)

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
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownBtn"
    dropdownBtn.Size = UDim2.new(1, 0, 0, 24)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 18)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
    dropdownBtn.BackgroundTransparency = 0.35
    dropdownBtn.Text = ""
    dropdownBtn.Parent = container
    Round(dropdownBtn, UDim.new(0, 6))
    Stroke(dropdownBtn, Aurora.Config.Colors.GlassBorder, 1)

    local selectedText = Instance.new("TextLabel")
    selectedText.Name = "SelectedText"
    selectedText.Size = UDim2.new(1, -22, 1, 0)
    selectedText.Position = UDim2.new(0, 8, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = default
    selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedText.TextSize = 11
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.Parent = dropdownBtn

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Aurora.Config.Colors.TextSecondary
    arrow.TextSize = 8
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = dropdownBtn

    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 0, 48)
    dropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    dropdownList.BackgroundTransparency = 0.35
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = container
    Round(dropdownList, UDim.new(0, 6))
    Stroke(dropdownList, Aurora.Config.Colors.GlassBorder, 1)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList

    local function refreshItems()
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, item in pairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Name = "Item"
            itemBtn.Size = UDim2.new(1, 0, 0, 24)
            itemBtn.BackgroundColor3 = item == value and Aurora.Config.Colors.Primary or Color3.fromRGB(25, 25, 42)
            itemBtn.BackgroundTransparency = 0.5
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 11
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = dropdownList
            Round(itemBtn, UDim.new(0, 5))

            itemBtn.MouseButton1Click:Connect(function()
                value = item
                selectedText.Text = item
                callback(item)
                isOpen = false
                Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)})
                arrow.Text = "▼"
                refreshItems()
            end)

            itemBtn.MouseEnter:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundColor3 = Aurora.Config.Colors.Secondary}) end
            end)

            itemBtn.MouseLeave:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 42)}) end
            end)
        end
    end

    refreshItems()

    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local listHeight = 26 * #items + 6
            Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + listHeight)})
            arrow.Text = "▲"
        else
            Tween(container, {Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight)})
            arrow.Text = "▼"
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

-- Label
function Aurora.Components.Label(section, options)
    options = options or {}
    local text = options.Text or "Label"

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Aurora.Config.Colors.TextSecondary
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = section.Content

    return {
        SetText = function(newText) label.Text = newText end
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
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section.Content
    Round(container, UDim.new(0, 7))
    Padding(container, 10, 10, 10, 10)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.Position = UDim2.new(0, 0, 0, 18)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
    contentLabel.TextSize = 10
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Parent = container

    return {
        SetTitle = function(t) titleLabel.Text = t end,
        SetContent = function(c) contentLabel.Text = c end
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
    label.Size = UDim2.new(1, -75, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "KeyBtn"
    keyBtn.Size = UDim2.new(0, 65, 0, 26)
    keyBtn.Position = UDim2.new(1, -4, 0.5, 0)
    keyBtn.AnchorPoint = Vector2.new(1, 0.5)
    keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
    keyBtn.BackgroundTransparency = 0.35
    keyBtn.Text = key.Name
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextSize = 11
    keyBtn.Font = Enum.Font.GothamSemibold
    keyBtn.Parent = container
    Round(keyBtn, UDim.new(0, 6))
    Stroke(keyBtn, Aurora.Config.Colors.GlassBorder, 1)

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
                keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
                listening = false
                callback(key)
            end
        elseif key ~= Enum.KeyCode.Unknown and input.KeyCode == key and not gameProcessed then
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
    container.Size = UDim2.new(1, 0, 0, Aurora.Config.Sizes.ElementHeight + 4)
    container.BackgroundTransparency = 1
    container.Parent = section.Content

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Name = "Input"
    textbox.Size = UDim2.new(1, 0, 0, 24)
    textbox.Position = UDim2.new(0, 0, 0, 18)
    textbox.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
    textbox.BackgroundTransparency = 0.35
    textbox.Text = default
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = Aurora.Config.Colors.TextMuted
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.TextSize = 11
    textbox.Font = Enum.Font.Gotham
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Parent = container
    Round(textbox, UDim.new(0, 6))
    Stroke(textbox, Aurora.Config.Colors.GlassBorder, 1)
    Padding(textbox, 0, 0, 8, 8)

    textbox.FocusLost:Connect(function()
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

-- Player Info
function Aurora.Components.PlayerInfo(section)
    local playerInfo = GetPlayerInfo()

    local container = Instance.new("Frame")
    container.Name = "PlayerInfo"
    container.Size = UDim2.new(1, 0, 0, 72)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    container.BackgroundTransparency = 0.35
    container.BorderSizePixel = 0
    container.Parent = section.Content
    Round(container, UDim.new(0, 8))
    Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Padding(container, 10, 10, 10, 10)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 45, 0, 45)
    avatar.Position = UDim2.new(0, 8, 0.5, 0)
    avatar.AnchorPoint = Vector2.new(0, 0.5)
    avatar.BackgroundColor3 = Aurora.Config.Colors.Primary
    avatar.Image = playerInfo.Thumbnail
    avatar.Parent = container
    Round(avatar, UDim.new(0, 8))
    Stroke(avatar, Aurora.Config.Colors.Secondary, 1.5)

    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -65, 1, 0)
    infoContainer.Position = UDim2.new(0, 60, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, 0, 0, 16)
    username.BackgroundTransparency = 1
    username.Text = playerInfo.DisplayName .. " (@" .. playerInfo.Username .. ")"
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 12
    username.Font = Enum.Font.GothamBold
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = infoContainer

    local userId = Instance.new("TextLabel")
    userId.Name = "UserId"
    userId.Size = UDim2.new(1, 0, 0, 13)
    userId.Position = UDim2.new(0, 0, 0, 18)
    userId.BackgroundTransparency = 1
    userId.Text = "User ID: " .. playerInfo.UserId
    userId.TextColor3 = Aurora.Config.Colors.TextSecondary
    userId.TextSize = 10
    userId.Font = Enum.Font.Gotham
    userId.TextXAlignment = Enum.TextXAlignment.Left
    userId.Parent = infoContainer

    local accountAge = Instance.new("TextLabel")
    accountAge.Name = "AccountAge"
    accountAge.Size = UDim2.new(1, 0, 0, 13)
    accountAge.Position = UDim2.new(0, 0, 0, 31)
    accountAge.BackgroundTransparency = 1
    accountAge.Text = "Account Age: " .. playerInfo.AccountAgeFormatted
    accountAge.TextColor3 = Aurora.Config.Colors.TextSecondary
    accountAge.TextSize = 10
    accountAge.Font = Enum.Font.Gotham
    accountAge.TextXAlignment = Enum.TextXAlignment.Left
    accountAge.Parent = infoContainer

    local membership = Instance.new("TextLabel")
    membership.Name = "Membership"
    membership.Size = UDim2.new(1, 0, 0, 13)
    membership.Position = UDim2.new(0, 0, 0, 44)
    membership.BackgroundTransparency = 1
    membership.Text = "Membership: " .. playerInfo.Membership
    membership.TextColor3 = playerInfo.Membership == "Premium" and Aurora.Config.Colors.Warning or Aurora.Config.Colors.TextSecondary
    membership.TextSize = 10
    membership.Font = Enum.Font.Gotham
    membership.TextXAlignment = Enum.TextXAlignment.Left
    membership.Parent = infoContainer

    return container
end

-- Executor Info
function Aurora.Components.ExecutorInfo(section)
    local executorInfo = GetExecutorInfo()

    local container = Instance.new("Frame")
    container.Name = "ExecutorInfo"
    container.Size = UDim2.new(1, 0, 0, 46)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    container.BackgroundTransparency = 0.35
    container.BorderSizePixel = 0
    container.Parent = section.Content
    Round(container, UDim.new(0, 8))
    Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Padding(container, 8, 8, 8, 8)

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.BackgroundColor3 = Aurora.Config.Colors.Primary
    icon.BackgroundTransparency = 0.5
    icon.Text = "⚡"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container
    Round(icon, UDim.new(0, 6))
    Gradient(icon)

    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -40, 1, 0)
    infoContainer.Position = UDim2.new(0, 36, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, 0, 0, 16)
    name.BackgroundTransparency = 1
    name.Text = executorInfo.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = 12
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = infoContainer

    local version = Instance.new("TextLabel")
    version.Name = "Version"
    version.Size = UDim2.new(1, 0, 0, 13)
    version.Position = UDim2.new(0, 0, 0, 18)
    version.BackgroundTransparency = 1
    version.Text = "Version: " .. executorInfo.Version
    version.TextColor3 = Aurora.Config.Colors.TextSecondary
    version.TextSize = 10
    version.Font = Enum.Font.Gotham
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.Parent = infoContainer

    return container
end

-- Game Info
function Aurora.Components.GameInfo(section)
    local gameInfo = GetGameInfo()

    local container = Instance.new("Frame")
    container.Name = "GameInfo"
    container.Size = UDim2.new(1, 0, 0, 68)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    container.BackgroundTransparency = 0.35
    container.BorderSizePixel = 0
    container.Parent = section.Content
    Round(container, UDim.new(0, 8))
    Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Padding(container, 8, 8, 8, 8)

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.BackgroundColor3 = Aurora.Config.Colors.Secondary
    icon.BackgroundTransparency = 0.5
    icon.Text = "🎮"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 16
    icon.Font = Enum.Font.GothamBold
    icon.Parent = container
    Round(icon, UDim.new(0, 6))
    Gradient(icon, Aurora.Config.Colors.Secondary, Aurora.Config.Colors.Primary)

    local infoContainer = Instance.new("Frame")
    infoContainer.Name = "Info"
    infoContainer.Size = UDim2.new(1, -40, 1, 0)
    infoContainer.Position = UDim2.new(0, 36, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = container

    local gameName = Instance.new("TextLabel")
    gameName.Name = "GameName"
    gameName.Size = UDim2.new(1, 0, 0, 16)
    gameName.BackgroundTransparency = 1
    gameName.Text = gameInfo.GameName
    gameName.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameName.TextSize = 12
    gameName.Font = Enum.Font.GothamBold
    gameName.TextXAlignment = Enum.TextXAlignment.Left
    gameName.Parent = infoContainer

    local placeId = Instance.new("TextLabel")
    placeId.Name = "PlaceId"
    placeId.Size = UDim2.new(1, 0, 0, 13)
    placeId.Position = UDim2.new(0, 0, 0, 18)
    placeId.BackgroundTransparency = 1
    placeId.Text = "Place ID: " .. gameInfo.PlaceId
    placeId.TextColor3 = Aurora.Config.Colors.TextSecondary
    placeId.TextSize = 10
    placeId.Font = Enum.Font.Gotham
    placeId.TextXAlignment = Enum.TextXAlignment.Left
    placeId.Parent = infoContainer

    local serverType = Instance.new("TextLabel")
    serverType.Name = "ServerType"
    serverType.Size = UDim2.new(1, 0, 0, 13)
    serverType.Position = UDim2.new(0, 0, 0, 31)
    serverType.BackgroundTransparency = 1
    serverType.Text = "Server: " .. gameInfo.ServerType
    serverType.TextColor3 = Aurora.Config.Colors.TextSecondary
    serverType.TextSize = 10
    serverType.Font = Enum.Font.Gotham
    serverType.TextXAlignment = Enum.TextXAlignment.Left
    serverType.Parent = infoContainer

    return container
end

-- Time Display
function Aurora.Components.TimeDisplay(section)
    local container = Instance.new("Frame")
    container.Name = "TimeDisplay"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    container.BackgroundTransparency = 0.35
    container.BorderSizePixel = 0
    container.Parent = section.Content
    Round(container, UDim.new(0, 8))
    Stroke(container, Aurora.Config.Colors.GlassBorder, 1)
    Padding(container, 8, 8, 8, 8)

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "Time"
    timeLabel.Size = UDim2.new(1, 0, 0, 26)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "00:00:00 AM"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextSize = 20
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.Parent = container

    local dateLabel = Instance.new("TextLabel")
    dateLabel.Name = "Date"
    dateLabel.Size = UDim2.new(1, 0, 0, 18)
    dateLabel.Position = UDim2.new(0, 0, 0, 30)
    dateLabel.BackgroundTransparency = 1
    dateLabel.Text = "Monday, 01/01/2024"
    dateLabel.TextColor3 = Aurora.Config.Colors.TextSecondary
    dateLabel.TextSize = 10
    dateLabel.Font = Enum.Font.Gotham
    dateLabel.TextXAlignment = Enum.TextXAlignment.Center
    dateLabel.Parent = container

    coroutine.wrap(function()
        while container and container.Parent do
            local timeData = FormatTime()
            timeLabel.Text = timeData.Time
            dateLabel.Text = timeData.Day .. ", " .. timeData.Date
            wait(1)
        end
    end)()

    return container
end

-- ============================================
-- VERSION INFO
-- ============================================
Aurora.Version = "1.0.1"
Aurora.Name = "Aurora Library"

return Aurora
