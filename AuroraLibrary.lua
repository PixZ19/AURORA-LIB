local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Check if mobile
local IS_MOBILE = UserInputService.TouchEnabled

local Aurora = {}

-- ============================================
-- THEME CONFIG
-- ============================================
local Theme = {
    -- Primary Colors
    Primary = Color3.fromRGB(139, 92, 246),         -- Violet
    Secondary = Color3.fromRGB(6, 182, 212),        -- Cyan
    Accent = Color3.fromRGB(236, 72, 153),          -- Pink
    
    -- Status Colors
    Success = Color3.fromRGB(34, 197, 94),          -- Green
    Warning = Color3.fromRGB(251, 146, 60),         -- Orange
    Error = Color3.fromRGB(239, 68, 68),            -- Red
    
    -- Background
    Background = Color3.fromRGB(10, 10, 18),        -- Deep dark
    Surface = Color3.fromRGB(18, 18, 28),           -- Card surface
    SurfaceHover = Color3.fromRGB(25, 25, 40),      -- Hover state
    
    -- Glass
    Glass = Color3.fromRGB(255, 255, 255),          -- Glass tint
    GlassAlpha = 0.03,                              -- Glass transparency
    Border = Color3.fromRGB(80, 80, 120),           -- Border color
    BorderAlpha = 0.3,                              -- Border transparency
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    
    -- Sizes
    WindowWidth = IS_MOBILE and 360 or 580,
    WindowHeight = IS_MOBILE and 500 or 420,
    SidebarWidth = IS_MOBILE and 60 or 160,
    CornerRadius = UDim.new(0, 12),
    ElementHeight = IS_MOBILE and 44 or 36,
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function Create(instance, parent, props)
    local obj = Instance.new(instance)
    for prop, value in pairs(props or {}) do
        obj[prop] = value
    end
    obj.Parent = parent
    return obj
end

local function Round(frame, radius)
    local corner = Create("UICorner", frame, {
        CornerRadius = radius or UDim.new(0, 8)
    })
    return corner
end

local function Stroke(frame, color, thickness)
    local stroke = Create("UIStroke", frame, {
        Color = color or Theme.Border,
        Transparency = Theme.BorderAlpha,
        Thickness = thickness or 1
    })
    return stroke
end

local function Gradient(frame, color1, color2, rotation)
    local gradient = Create("UIGradient", frame, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1 or Theme.Primary),
            ColorSequenceKeypoint.new(1, color2 or Theme.Secondary)
        }),
        Rotation = rotation or 90
    })
    return gradient
end

local function Tween(obj, props, duration, callback)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

local function Ripple(button, x, y)
    local ripple = Create("Frame", button, {
        Name = "Ripple",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.6,
        ZIndex = 100,
        BorderSizePixel = 0
    })
    Round(ripple, UDim.new(1, 0))
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5, function()
        ripple:Destroy()
    end)
end

local function GetPlayerInfo()
    local p = LocalPlayer
    local years = math.floor(p.AccountAge / 365)
    local days = p.AccountAge % 365
    return {
        Username = p.Name,
        DisplayName = p.DisplayName,
        UserId = p.UserId,
        AccountAge = string.format("%dy %dd", years, days),
        Membership = p.MembershipType.Name,
        Thumbnail = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    }
end

local function GetExecutorInfo()
    local info = {Name = "Unknown", Version = "N/A"}
    if syn then info.Name = "Synapse X"; info.Version = "v2"
    elseif KRNL then info.Name = "KRNL"
    elseif identifyexecutor then
        local n, v = identifyexecutor()
        info.Name = n or "Unknown"
        info.Version = v or "N/A"
    end
    return info
end

local function GetGameInfo()
    return {
        Name = game.Name,
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        ServerType = game.JobId ~= "" and "Private" or "Public"
    }
end

-- ============================================
-- LOADING SCREEN
-- ============================================
function Aurora.LoadingScreen(options)
    options = options or {}
    local duration = options.Duration or 2.5
    local callback = options.OnComplete or function() end

    local gui = Create("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "AuroraLoading",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local bg = Create("Frame", gui, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })

    -- Animated gradient background
    local gradientBg = Create("Frame", bg, {
        Size = UDim2.new(3, 0, 3, 0),
        Position = UDim2.new(-1, 0, -1, 0),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0
    })

    local bgGradient = Gradient(gradientBg, Theme.Primary, Theme.Secondary, 45)

    -- Main container
    local container = Create("Frame", bg, {
        Size = UDim2.new(0, 300, 0, 180),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    })

    -- Logo
    local logo = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0.5, 0, 0.35, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "AURORA",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 42,
        Font = Enum.Font.GothamBlack
    })
    Gradient(logo)

    local subtitle = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.52, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "MODERN UI LIBRARY",
        TextColor3 = Theme.TextMuted,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        LetterSpacing = 3
    })

    -- Progress bar
    local progressBg = Create("Frame", container, {
        Size = UDim2.new(0.7, 0, 0, 4),
        Position = UDim2.new(0.5, 0, 0.72, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        BorderSizePixel = 0
    })
    Round(progressBg, UDim.new(1, 0))

    local progressFill = Create("Frame", progressBg, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0
    })
    Round(progressFill, UDim.new(1, 0))
    Gradient(progressFill)

    local loadingText = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.85, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium
    })

    -- Animate gradient
    local rotation = 0
    local conn = RunService.Heartbeat:Connect(function()
        rotation = rotation + 0.3
        bgGradient.Rotation = rotation % 360
    end)

    -- Loading sequence
    local messages = {"Initializing...", "Loading modules...", "Preparing UI...", "Ready!"}
    for i, msg in ipairs(messages) do
        wait(duration / #messages)
        loadingText.Text = msg
        Tween(progressFill, {Size = UDim2.new(i / #messages, 0, 1, 0)}, 0.2)
    end

    wait(0.3)
    conn:Disconnect()
    Tween(bg, {BackgroundTransparency = 1}, 0.4)
    wait(0.4)
    gui:Destroy()
    callback()
end

-- ============================================
-- CREATE WINDOW
-- ============================================
function Aurora:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Aurora"
    local subtitle = options.Subtitle or "v2.0.0"

    local window = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false,
        Gui = nil,
        MainFrame = nil,
        MiniFrame = nil
    }

    -- Main GUI
    local gui = Create("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "AuroraWindow",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    window.Gui = gui

    -- ============================================
    -- MINIMIZED STATE (Mini Toggle Button)
    -- ============================================
    local miniFrame = Create("Frame", gui, {
        Name = "MiniFrame",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, 0, 0, -60),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Visible = false
    })
    window.MiniFrame = miniFrame
    Round(miniFrame, UDim.new(1, 0))
    Stroke(miniFrame)

    -- Glow effect
    local miniGlow = Create("ImageLabel", miniFrame, {
        Size = UDim2.new(1.5, 0, 1.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Theme.Primary,
        ImageTransparency = 0.5,
        ZIndex = -1
    })

    local miniIcon = Create("TextLabel", miniFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "◈",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold
    })
    Gradient(miniIcon)

    -- Mini frame click to restore
    miniFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            window:Restore()
        end
    end)

    -- ============================================
    -- MAIN WINDOW FRAME
    -- ============================================
    local mainFrame = Create("Frame", gui, {
        Name = "MainFrame",
        Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0
    })
    window.MainFrame = mainFrame
    Round(mainFrame, Theme.CornerRadius)
    Stroke(mainFrame)

    -- Animated gradient overlay
    local gradientOverlay = Create("Frame", mainFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.97,
        BorderSizePixel = 0,
        ZIndex = -1
    })
    Round(gradientOverlay, Theme.CornerRadius)

    local overlayGrad = Gradient(gradientOverlay, Theme.Primary, Theme.Secondary, 45)
    coroutine.wrap(function()
        local rot = 0
        while mainFrame and mainFrame.Parent do
            rot = rot + 0.2
            overlayGrad.Rotation = rot % 360
            wait(0.016)
        end
    end)()

    -- ============================================
    -- SIDEBAR
    -- ============================================
    local sidebar = Create("Frame", mainFrame, {
        Name = "Sidebar",
        Size = UDim2.new(0, Theme.SidebarWidth, 1, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 20),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Round(sidebar, Theme.CornerRadius)

    -- Fix sidebar corner
    local sidebarFix = Create("Frame", sidebar, {
        Size = UDim2.new(0, Theme.CornerRadius.Offset, 1, 0),
        Position = UDim2.new(1, -Theme.CornerRadius.Offset, 0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 20),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })

    -- Header
    local header = Create("Frame", sidebar, {
        Size = UDim2.new(1, 0, 0, IS_MOBILE and 50 or 55),
        BackgroundTransparency = 1
    })

    -- Logo
    local logoText = Create("TextLabel", header, {
        Size = UDim2.new(1, -10, 0, IS_MOBILE and 24 or 28),
        Position = UDim2.new(0.5, 0, IS_MOBILE and 0.35 or 0.3, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = IS_MOBILE and "◈" or "AURORA",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = IS_MOBILE and 20 or 20,
        Font = Enum.Font.GothamBlack
    })
    if not IS_MOBILE then Gradient(logoText) end

    local subtitleLabel = Create("TextLabel", header, {
        Size = UDim2.new(1, -10, 0, 14),
        Position = UDim2.new(0.5, 0, IS_MOBILE and 0.7 or 0.65, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = IS_MOBILE and "" or subtitle,
        TextColor3 = Theme.TextMuted,
        TextSize = 9,
        Font = Enum.Font.Gotham
    })

    -- Tab container
    local tabContainer = Create("ScrollingFrame", sidebar, {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 1, -IS_MOBILE and 60 or 115),
        Position = UDim2.new(0, 0, 0, IS_MOBILE and 55 or 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0
    })

    local tabLayout = Create("UIListLayout", tabContainer, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    -- User info section (desktop only)
    if not IS_MOBILE then
        local userInfo = Create("Frame", sidebar, {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50),
            BackgroundColor3 = Color3.fromRGB(12, 12, 20),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0
        })
        Round(userInfo, Theme.CornerRadius)

        local infoFix = Create("Frame", userInfo, {
            Size = UDim2.new(0, Theme.CornerRadius.Offset, 1, 0),
            Position = UDim2.new(1, -Theme.CornerRadius.Offset, 0, 0),
            BackgroundColor3 = Color3.fromRGB(12, 12, 20),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0
        })

        local playerInfo = GetPlayerInfo()
        
        local avatar = Create("ImageLabel", userInfo, {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Primary,
            Image = playerInfo.Thumbnail,
            BorderSizePixel = 0
        })
        Round(avatar, UDim.new(1, 0))
        Stroke(avatar, Theme.Secondary, 1.5)

        local userName = Create("TextLabel", userInfo, {
            Size = UDim2.new(1, -50, 0, 15),
            Position = UDim2.new(0, 46, 0.5, -10),
            BackgroundTransparency = 1,
            Text = playerInfo.DisplayName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local executorName = Create("TextLabel", userInfo, {
            Size = UDim2.new(1, -50, 0, 13),
            Position = UDim2.new(0, 46, 0.5, 6),
            BackgroundTransparency = 1,
            Text = GetExecutorInfo().Name,
            TextColor3 = Theme.Secondary,
            TextSize = 9,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local contentArea = Create("Frame", mainFrame, {
        Size = UDim2.new(1, -Theme.SidebarWidth, 1, 0),
        Position = UDim2.new(0, Theme.SidebarWidth, 0, 0),
        BackgroundTransparency = 1
    })

    -- Title bar
    local titleBar = Create("Frame", contentArea, {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(15, 15, 25),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })

    local titleText = Create("TextLabel", titleBar, {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Window controls
    local controls = Create("Frame", titleBar, {
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -75, 0, 0),
        BackgroundTransparency = 1
    })

    local controlsLayout = Create("UIListLayout", controls, {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6)
    })

    -- Minimize button
    local minBtn = Create("TextButton", controls, {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Theme.Warning,
        BackgroundTransparency = 0.5,
        Text = "—",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })
    Round(minBtn, UDim.new(0.5, 0))

    minBtn.MouseButton1Click:Connect(function()
        window:Minimize()
    end)

    minBtn.MouseEnter:Connect(function() Tween(minBtn, {BackgroundTransparency = 0.2}) end)
    minBtn.MouseLeave:Connect(function() Tween(minBtn, {BackgroundTransparency = 0.5}) end)

    -- Close button
    local closeBtn = Create("TextButton", controls, {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Theme.Error,
        BackgroundTransparency = 0.5,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })
    Round(closeBtn, UDim.new(0.5, 0))

    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.2}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.5}) end)

    -- Tab content container
    local tabContentContainer = Create("Frame", contentArea, {
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1
    })
    window.TabContentContainer = tabContentContainer

    -- ============================================
    -- DRAGGING (Desktop only)
    -- ============================================
    if not IS_MOBILE then
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
    end

    -- ============================================
    -- WINDOW FUNCTIONS
    -- ============================================
    function window:Minimize()
        if window.Minimized then return end
        window.Minimized = true
        
        -- Animate main window out
        Tween(mainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, function()
            mainFrame.Visible = false
        end)
        
        -- Show mini frame at top center
        miniFrame.Position = UDim2.new(0.5, 0, 0, -60)
        miniFrame.Visible = true
        Tween(miniFrame, {Position = UDim2.new(0.5, 0, 0, 15)}, 0.4)
    end

    function window:Restore()
        if not window.Minimized then return end
        window.Minimized = false
        
        -- Hide mini frame
        Tween(miniFrame, {Position = UDim2.new(0.5, 0, 0, -60)}, 0.3, function()
            miniFrame.Visible = false
        end)
        
        -- Show main window
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        Tween(mainFrame, {
            Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight),
            BackgroundTransparency = 0
        }, 0.4)
    end

    function window:Destroy()
        Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3, function()
            gui:Destroy()
        end)
        miniFrame:Destroy()
    end

    function window:Notify(options)
        options = options or {}
        local nTitle = options.Title or "Notification"
        local content = options.Content or ""
        local duration = options.Duration or 4
        local notifType = options.Type or "info"

        local colors = {
            info = Theme.Secondary,
            success = Theme.Success,
            warning = Theme.Warning,
            error = Theme.Error
        }

        local notif = Create("Frame", gui, {
            Size = UDim2.new(0, IS_MOBILE and 280 or 300, 0, IS_MOBILE and 65 or 60),
            Position = UDim2.new(0.5, 0, 0, -70),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0
        })
        Round(notif, UDim.new(0, 10))
        Stroke(notif, colors[notifType] or colors.info, 1.5)

        local accent = Create("Frame", notif, {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = colors[notifType] or colors.info,
            BorderSizePixel = 0
        })
        Round(accent, UDim.new(0, 3))

        local nTitleLabel = Create("TextLabel", notif, {
            Size = UDim2.new(1, -18, 0, 20),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text = nTitle,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local nContent = Create("TextLabel", notif, {
            Size = UDim2.new(1, -18, 0, 28),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text = content,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        Tween(notif, {Position = UDim2.new(0.5, 0, 0, 15)}, 0.4)

        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(0.5, 0, 0, -70)}, 0.4, function()
                notif:Destroy()
            end)
        end)
    end

    -- ============================================
    -- CREATE TAB
    -- ============================================
    function window:CreateTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or "◐"

        local tab = {
            Name = tabName,
            Icon = tabIcon,
            Sections = {},
            Button = nil,
            Content = nil,
            Indicator = nil
        }

        -- Tab button
        local tabBtn = Create("TextButton", tabContainer, {
            Size = UDim2.new(1, -8, 0, IS_MOBILE and 42 or 32),
            BackgroundColor3 = Color3.fromRGB(25, 25, 40),
            BackgroundTransparency = 0.6,
            Text = "",
            BorderSizePixel = 0
        })
        Round(tabBtn, UDim.new(0, 8))
        tab.Button = tabBtn

        -- Indicator
        local indicator = Create("Frame", tabBtn, {
            Size = UDim2.new(0, 3, 0.55, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })
        Round(indicator, UDim.new(1, 0))
        Gradient(indicator)
        tab.Indicator = indicator

        -- Tab icon (mobile) or text
        local tabLabel = Create("TextLabel", tabBtn, {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Text = IS_MOBILE and tabIcon or tabName,
            TextColor3 = Theme.TextSecondary,
            TextSize = IS_MOBILE and 18 or 12,
            Font = Enum.Font.GothamSemibold
        })

        -- Tab content
        local tabContent = Create("ScrollingFrame", tabContentContainer, {
            Name = "Content_" .. tabName,
            Size = UDim2.new(1, -12, 1, -8),
            Position = UDim2.new(0, 6, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Primary,
            ScrollBarImageTransparency = 0.5,
            BorderSizePixel = 0,
            Visible = false
        })

        local contentLayout = Create("UIListLayout", tabContent, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
        tab.Content = tabContent

        -- Tab click handler
        tabBtn.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        tabBtn.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabBtn, {BackgroundTransparency = 0.3})
                Tween(tabLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(tabBtn, {BackgroundTransparency = 0.6})
                Tween(tabLabel, {TextColor3 = Theme.TextSecondary})
            end
        end)

        table.insert(window.Tabs, tab)

        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end

        -- ============================================
        -- CREATE SECTION
        -- ============================================
        function tab:CreateSection(sectionOptions)
            sectionOptions = sectionOptions or {}
            local sectionName = sectionOptions.Name or "Section"

            local section = {
                Name = sectionName,
                Frame = nil,
                Content = nil
            }

            local sectionFrame = Create("Frame", tabContent, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 32),
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Round(sectionFrame, UDim.new(0, 10))
            Stroke(sectionFrame)
            section.Frame = sectionFrame

            local sectionHeader = Create("Frame", sectionFrame, {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1
            })

            local sectionTitle = Create("TextLabel", sectionHeader, {
                Size = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local sectionContent = Create("Frame", sectionFrame, {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            section.Content = sectionContent

            local contentPadding = Create("UIPadding", sectionContent, {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })

            local contentLayout = Create("UIListLayout", sectionContent, {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })

            return section
        end

        return tab
    end

    -- ============================================
    -- SELECT TAB
    -- ============================================
    function window:SelectTab(tab)
        if window.CurrentTab == tab then return end

        -- Deselect current
        if window.CurrentTab then
            local current = window.CurrentTab
            if current.Content then current.Content.Visible = false end
            if current.Button then Tween(current.Button, {BackgroundTransparency = 0.6}) end
            if current.Indicator then Tween(current.Indicator, {BackgroundTransparency = 1}) end
            
            local label = current.Button and current.Button:FindFirstChild("TextLabel")
            if label then Tween(label, {TextColor3 = Theme.TextSecondary}) end
        end

        -- Select new
        window.CurrentTab = tab
        if tab.Content then tab.Content.Visible = true end
        if tab.Button then Tween(tab.Button, {BackgroundTransparency = 0.2}) end
        if tab.Indicator then Tween(tab.Indicator, {BackgroundTransparency = 0}) end
        
        local label = tab.Button and tab.Button:FindFirstChild("TextLabel")
        if label then Tween(label, {TextColor3 = Color3.fromRGB(255, 255, 255)}) end
    end

    return window
end

-- ============================================
-- UI COMPONENTS
-- ============================================
Aurora.Components = {}

function Aurora.Components.Button(section, options)
    options = options or {}
    local text = options.Text or "Button"
    local callback = options.Callback or function() end

    local btn = Create("TextButton", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.6,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        BorderSizePixel = 0
    })
    Round(btn, UDim.new(0, 8))
    Gradient(btn)

    btn.MouseButton1Click:Connect(function()
        local x, y = IS_MOBILE and btn.AbsoluteSize.X / 2 or Mouse.X - btn.AbsolutePosition.X,
                     IS_MOBILE and btn.AbsoluteSize.Y / 2 or Mouse.Y - btn.AbsolutePosition.Y
        Ripple(btn, x, y)
        callback()
    end)

    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.3}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.6}) end)

    return btn
end

function Aurora.Components.Toggle(section, options)
    options = options or {}
    local text = options.Text or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    local value = default

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggle = Create("TextButton", container, {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default and Theme.Success or Color3.fromRGB(50, 50, 70),
        BackgroundTransparency = 0.4,
        Text = "",
        BorderSizePixel = 0
    })
    Round(toggle, UDim.new(1, 0))

    local circle = Create("Frame", toggle, {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Round(circle, UDim.new(1, 0))

    toggle.MouseButton1Click:Connect(function()
        value = not value
        Tween(toggle, {BackgroundColor3 = value and Theme.Success or Color3.fromRGB(50, 50, 70)})
        Tween(circle, {Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
        callback(value)
    end)

    return {
        SetValue = function(v)
            value = v
            Tween(toggle, {BackgroundColor3 = value and Theme.Success or Color3.fromRGB(50, 50, 70)})
            Tween(circle, {Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            callback(value)
        end,
        GetValue = function() return value end
    }
end

function Aurora.Components.Slider(section, options)
    options = options or {}
    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local decimals = options.Decimals or 0
    local callback = options.Callback or function() end
    local value = default

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight + 8),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -50, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Create("TextLabel", container, {
        Size = UDim2.new(0, 42, 0, 18),
        Position = UDim2.new(1, -4, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Theme.Secondary,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local sliderBg = Create("Frame", container, {
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 1, -5),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.fromRGB(35, 35, 55),
        BorderSizePixel = 0
    })
    Round(sliderBg, UDim.new(1, 0))

    local sliderFill = Create("Frame", sliderBg, {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0
    })
    Round(sliderFill, UDim.new(1, 0))
    Gradient(sliderFill)

    local sliderBtn = Create("TextButton", sliderBg, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * pos
        value = math.floor(value * (10 ^ decimals)) / (10 ^ decimals)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)

    return {
        SetValue = function(v)
            value = math.clamp(v, min, max)
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end,
        GetValue = function() return value end
    }
end

function Aurora.Components.Dropdown(section, options)
    options = options or {}
    local text = options.Text or "Dropdown"
    local items = options.Items or {}
    local default = options.Default or items[1] or "Select"
    local callback = options.Callback or function() end
    local value = default
    local isOpen = false

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dropBtn = Create("TextButton", container, {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Color3.fromRGB(25, 25, 42),
        BackgroundTransparency = 0.4,
        Text = "",
        BorderSizePixel = 0
    })
    Round(dropBtn, UDim.new(0, 6))
    Stroke(dropBtn)

    local selected = Create("TextLabel", dropBtn, {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local arrow = Create("TextLabel", dropBtn, {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextSecondary,
        TextSize = 8,
        Font = Enum.Font.GothamBold
    })

    local list = Create("Frame", container, {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Round(list, UDim.new(0, 6))
    Stroke(list)

    local listLayout = Create("UIListLayout", list, {
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local function refresh()
        for _, child in pairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, item in pairs(items) do
            local itemBtn = Create("TextButton", list, {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = item == value and Theme.Primary or Color3.fromRGB(25, 25, 42),
                BackgroundTransparency = 0.5,
                Text = item,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0
            })
            Round(itemBtn, UDim.new(0, 5))

            itemBtn.MouseButton1Click:Connect(function()
                value = item
                selected.Text = item
                isOpen = false
                Tween(container, {Size = UDim2.new(1, 0, 0, Theme.ElementHeight)})
                arrow.Text = "▼"
                refresh()
                callback(item)
            end)

            itemBtn.MouseEnter:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundColor3 = Theme.Secondary}) end
            end)

            itemBtn.MouseLeave:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 42)}) end
            end)
        end
    end

    refresh()

    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local h = 28 * #items + 6
            Tween(container, {Size = UDim2.new(1, 0, 0, Theme.ElementHeight + h)})
            arrow.Text = "▲"
        else
            Tween(container, {Size = UDim2.new(1, 0, 0, Theme.ElementHeight)})
            arrow.Text = "▼"
        end
    end)

    return {
        SetValue = function(v)
            value = v
            selected.Text = v
            refresh()
            callback(v)
        end,
        GetValue = function() return value end,
        Refresh = function(newItems)
            items = newItems
            refresh()
        end
    }
end

function Aurora.Components.Label(section, options)
    options = options or {}
    local text = options.Text or "Label"

    local label = Create("TextLabel", section.Content, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    return {SetText = function(t) label.Text = t end}
end

function Aurora.Components.Paragraph(section, options)
    options = options or {}
    local title = options.Title or "Title"
    local content = options.Content or "Content"

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Round(container, UDim.new(0, 8))

    local padding = Create("UIPadding", container, {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local titleLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local contentLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y
    })

    return {
        SetTitle = function(t) titleLabel.Text = t end,
        SetContent = function(c) contentLabel.Text = c end
    }
end

function Aurora.Components.Divider(section)
    local divider = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    return divider
end

function Aurora.Components.Keybind(section, options)
    options = options or {}
    local text = options.Text or "Keybind"
    local default = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end
    local key = default
    local listening = false

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -75, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local keyBtn = Create("TextButton", container, {
        Size = UDim2.new(0, 65, 0, 26),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(25, 25, 42),
        BackgroundTransparency = 0.4,
        Text = key.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        BorderSizePixel = 0
    })
    Round(keyBtn, UDim.new(0, 6))
    Stroke(keyBtn)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Theme.Primary
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                keyBtn.Text = key.Name
                keyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
                listening = false
                callback(key)
            end
        elseif key ~= Enum.KeyCode.Unknown and input.KeyCode == key and not gp then
            callback(key)
        end
    end)

    return {
        SetKey = function(k) key = k; keyBtn.Text = k.Name; callback(k) end,
        GetKey = function() return key end
    }
end

function Aurora.Components.Textbox(section, options)
    options = options or {}
    local text = options.Text or "Input"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter..."
    local numeric = options.Numeric or false
    local callback = options.Callback or function() end
    local value = default

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Theme.ElementHeight + 6),
        BackgroundTransparency = 1
    })

    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local textbox = Create("TextBox", container, {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Color3.fromRGB(25, 25, 42),
        BackgroundTransparency = 0.4,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    Round(textbox, UDim.new(0, 6))
    Stroke(textbox)

    local padding = Create("UIPadding", textbox, {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

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
        SetValue = function(v) value = v; textbox.Text = tostring(v); callback(v) end,
        GetValue = function() return value end
    }
end

function Aurora.Components.PlayerInfo(section)
    local info = GetPlayerInfo()

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, IS_MOBILE and 85 or 70),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Round(container, UDim.new(0, 10))
    Stroke(container)

    local padding = Create("UIPadding", container, {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local avatar = Create("ImageLabel", container, {
        Size = UDim2.new(0, IS_MOBILE and 45 or 42, 0, IS_MOBILE and 45 or 42),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Primary,
        Image = info.Thumbnail,
        BorderSizePixel = 0
    })
    Round(avatar, UDim.new(0, 8))
    Stroke(avatar, Theme.Secondary, 1.5)

    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, -IS_MOBILE and 65 or 60, 1, 0),
        Position = UDim2.new(0, IS_MOBILE and 60 or 55, 0, 0),
        BackgroundTransparency = 1
    })

    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.DisplayName .. " (@" .. info.Username .. ")",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local uid = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "ID: " .. info.UserId,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local age = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundTransparency = 1,
        Text = "Age: " .. info.AccountAge,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local membership = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        Text = "Membership: " .. info.Membership,
        TextColor3 = info.Membership == "Premium" and Theme.Warning or Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return container
end

function Aurora.Components.ExecutorInfo(section)
    local info = GetExecutorInfo()

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Round(container, UDim.new(0, 10))
    Stroke(container)

    local padding = Create("UIPadding", container, {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local icon = Create("TextLabel", container, {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.5,
        Text = "⚡",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })
    Round(icon, UDim.new(0, 6))
    Gradient(icon)

    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1
    })

    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local version = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "Version: " .. info.Version,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return container
end

function Aurora.Components.GameInfo(section)
    local info = GetGameInfo()

    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Round(container, UDim.new(0, 10))
    Stroke(container)

    local padding = Create("UIPadding", container, {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local icon = Create("TextLabel", container, {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.5,
        Text = "🎮",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    })
    Round(icon, UDim.new(0, 6))
    Gradient(icon, Theme.Secondary, Theme.Primary)

    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1
    })

    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local placeId = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "Place ID: " .. info.PlaceId,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local server = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundTransparency = 1,
        Text = "Server: " .. info.ServerType,
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return container
end

function Aurora.Components.TimeDisplay(section)
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Color3.fromRGB(22, 22, 38),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    })
    Round(container, UDim.new(0, 10))
    Stroke(container)

    local timeLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0.35, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "00:00:00 AM",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    Gradient(timeLabel)

    local dateLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.7, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "Monday, 01/01/2024",
        TextColor3 = Theme.TextSecondary,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    coroutine.wrap(function()
        while container and container.Parent do
            local d = os.date("*t")
            local h = d.hour
            local ampm = h >= 12 and "PM" or "AM"
            h = h % 12
            h = h == 0 and 12 or h
            timeLabel.Text = string.format("%02d:%02d:%02d %s", h, d.min, d.sec, ampm)
            dateLabel.Text = os.date("%A") .. ", " .. string.format("%02d/%02d/%04d", d.day, d.month, d.year)
            wait(1)
        end
    end)()

    return container
end

Aurora.Version = "2.0.0"
Aurora.Name = "Aurora Library"

return Aurora
