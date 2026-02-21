local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IS_MOBILE = UserInputService.TouchEnabled

local Aurora = {}

-- ============================================
-- THEME
-- ============================================
local Colors = {
    -- Main
    Background = Color3.fromRGB(12, 12, 16),
    Card = Color3.fromRGB(20, 20, 26),
    CardHover = Color3.fromRGB(28, 28, 36),
    Border = Color3.fromRGB(45, 45, 55),
    
    -- Accent
    Primary = Color3.fromRGB(124, 58, 237),
    Secondary = Color3.fromRGB(96, 165, 250),
    Accent = Color3.fromRGB(244, 63, 94),
    
    -- Status
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(250, 152, 58),
    Error = Color3.fromRGB(239, 68, 68),
    
    -- Text
    Text = Color3.fromRGB(248, 250, 252),
    TextMuted = Color3.fromRGB(148, 163, 184),
    TextDim = Color3.fromRGB(100, 116, 139),
}

local Sizes = {
    Width = IS_MOBILE and 340 or 520,
    Height = IS_MOBILE and 480 or 400,
    Sidebar = IS_MOBILE and 55 or 170,
    Radius = 14,
    ElementHeight = IS_MOBILE and 46 or 38,
}

-- ============================================
-- UTILITIES
-- ============================================
local function Create(class, parent, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

local function Corner(frame, radius)
    return Create("UICorner", frame, {CornerRadius = UDim.new(0, radius or 8)})
end

local function Stroke(frame, color, thickness)
    return Create("UIStroke", frame, {
        Color = color or Colors.Border,
        Thickness = thickness or 1,
        Transparency = 0.5
    })
end

local function Pad(frame, t, b, l, r)
    return Create("UIPadding", frame, {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0)
    })
end

local function Tween(obj, props, dur, cb)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    if cb then t.Completed:Connect(cb) end
    t:Play()
    return t
end

local function Gradient(frame, c1, c2)
    return Create("UIGradient", frame, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1 or Colors.Primary),
            ColorSequenceKeypoint.new(1, c2 or Colors.Secondary)
        }),
        Rotation = 90
    })
end

local function Glow(frame, color)
    local glow = Create("ImageLabel", frame, {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = color or Colors.Primary,
        ImageTransparency = 0.6,
        ZIndex = -1
    })
    return glow
end

local function GetPlayerInfo()
    local p = LocalPlayer
    local y, d = math.floor(p.AccountAge / 365), p.AccountAge % 365
    return {
        Name = p.DisplayName,
        Username = p.Name,
        Id = p.UserId,
        Age = string.format("%dy %dd", y, d),
        Membership = p.MembershipType.Name,
        Avatar = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    }
end

local function GetExecutorInfo()
    local info = {Name = "Unknown", Version = "?"}
    if syn then info.Name = "Synapse X"; info.Version = "v2"
    elseif KRNL then info.Name = "KRNL"
    elseif identifyexecutor then
        local n, v = identifyexecutor()
        info.Name = n or "Unknown"
        info.Version = v or "?"
    end
    return info
end

local function GetGameInfo()
    return {
        Name = game.Name,
        PlaceId = game.PlaceId,
        ServerType = game.JobId ~= "" and "Private" or "Public"
    }
end

-- ============================================
-- LOADING SCREEN
-- ============================================
function Aurora.LoadingScreen(opts)
    opts = opts or {}
    local dur = opts.Duration or 2
    
    local gui = Create("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "AuroraLoad",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    local bg = Create("Frame", gui, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    
    -- Animated orbs
    local orb1 = Create("Frame", bg, {
        Size = UDim2.new(0, 400, 0, 400),
        Position = UDim2.new(-0.2, 0, -0.2, 0),
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0
    })
    Corner(orb1, UDim.new(1, 0))
    
    local orb2 = Create("Frame", bg, {
        Size = UDim2.new(0, 300, 0, 300),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Colors.Secondary,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0
    })
    Corner(orb2, UDim.new(1, 0))
    
    -- Logo container
    local container = Create("Frame", bg, {
        Size = UDim2.new(0, 280, 0, 160),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    })
    
    -- Animated logo ring
    local ring = Create("Frame", container, {
        Size = UDim2.new(0, 80, 0, 80),
        Position = UDim2.new(0.5, 0, 0.3, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0
    })
    Corner(ring, UDim.new(1, 0))
    Gradient(ring)
    
    -- Inner circle
    local inner = Create("Frame", ring, {
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    Corner(inner, UDim.new(1, 0))
    
    -- Logo text
    local logo = Create("TextLabel", inner, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "A",
        TextColor3 = Colors.Text,
        TextSize = 28,
        Font = Enum.Font.GothamBold
    })
    Gradient(logo)
    
    -- Title
    local title = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0.5, 0, 0.62, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = "AURORA",
        TextColor3 = Colors.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold
    })
    Gradient(title)
    
    -- Subtitle
    local sub = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.78, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Colors.TextMuted,
        TextSize = 12,
        Font = Enum.Font.GothamMedium
    })
    
    -- Progress bar
    local progBg = Create("Frame", container, {
        Size = UDim2.new(0.6, 0, 0, 3),
        Position = UDim2.new(0.5, 0, 0.92, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    Corner(progBg, UDim.new(1, 0))
    
    local prog = Create("Frame", progBg, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0
    })
    Corner(prog, UDim.new(1, 0))
    Gradient(prog)
    
    -- Animate
    local rot = 0
    local conn = RunService.Heartbeat:Connect(function()
        rot = rot + 2
        orb1.Rotation = rot
        orb2.Rotation = -rot
    end)
    
    local msgs = {"Initializing", "Loading modules", "Preparing UI", "Ready"}
    for i, m in ipairs(msgs) do
        task.wait(dur / #msgs)
        sub.Text = m .. "..."
        Tween(prog, {Size = UDim2.new(i / #msgs, 0, 1, 0)}, 0.15)
    end
    
    task.wait(0.2)
    conn:Disconnect()
    Tween(bg, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.3)
    gui:Destroy()
    if opts.OnComplete then opts.OnComplete() end
end

-- ============================================
-- WINDOW
-- ============================================
function Aurora:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "Aurora"
    local sub = opts.Subtitle or "v3.0"
    
    local window = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false
    }
    
    local gui = Create("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"), {
        Name = "AuroraUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    window.Gui = gui
    
    -- ============================================
    -- MINI BUTTON (when minimized)
    -- ============================================
    local miniBtn = Create("TextButton", gui, {
        Name = "MiniBtn",
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0.5, 0, 0, -50),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.Card,
        BorderSizePixel = 0,
        Visible = false,
        Text = ""
    })
    Corner(miniBtn, UDim.new(0, 22))
    Stroke(miniBtn, Colors.Primary, 1.5)
    Glow(miniBtn, Colors.Primary)
    
    local miniIcon = Create("ImageLabel", miniBtn, {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6034277709",
        ImageColor3 = Colors.Text
    })
    
    miniBtn.MouseButton1Click:Connect(function()
        window:Restore()
    end)
    
    miniBtn.MouseEnter:Connect(function()
        Tween(miniBtn, {BackgroundColor3 = Colors.CardHover})
    end)
    
    miniBtn.MouseLeave:Connect(function()
        Tween(miniBtn, {BackgroundColor3 = Colors.Card})
    end)
    
    -- ============================================
    -- MAIN WINDOW
    -- ============================================
    local main = Create("Frame", gui, {
        Name = "Main",
        Size = UDim2.new(0, Sizes.Width, 0, Sizes.Height),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    Corner(main, Sizes.Radius)
    Stroke(main)
    Glow(main, Colors.Primary)
    window.Main = main
    
    -- ============================================
    -- TOP BAR
    -- ============================================
    local topbar = Create("Frame", main, {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })
    Corner(topbar, Sizes.Radius)
    
    local topbarFix = Create("Frame", topbar, {
        Size = UDim2.new(1, 0, 0, Sizes.Radius),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })
    
    -- Sidebar toggle (mobile)
    local menuBtn
    if IS_MOBILE then
        menuBtn = Create("TextButton", topbar, {
            Size = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(0, 6, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Text = "☰",
            TextColor3 = Colors.Text,
            TextSize = 20,
            Font = Enum.Font.GothamMedium
        })
    end
    
    -- Logo
    local logoContainer = Create("Frame", topbar, {
        Size = UDim2.new(0, IS_MOBILE and 30 or 140, 0, 28),
        Position = UDim2.new(IS_MOBILE and 0.12 or 0.02, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1
    })
    
    local logoIcon = Create("Frame", logoContainer, {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0
    })
    Corner(logoIcon, UDim.new(0, 7))
    Gradient(logoIcon)
    
    local logoA = Create("TextLabel", logoIcon, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "A",
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold
    })
    
    if not IS_MOBILE then
        local logoText = Create("TextLabel", logoContainer, {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Colors.Text,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    -- Controls
    local controls = Create("Frame", topbar, {
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1
    })
    
    local ctrlLayout = Create("UIListLayout", controls, {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6)
    })
    
    -- Minimize
    local minBtn2 = Create("TextButton", controls, {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Colors.Warning,
        BackgroundTransparency = 0.6,
        Text = "",
        BorderSizePixel = 0
    })
    Corner(minBtn2, UDim.new(0.5, 0))
    
    local minIcon = Create("Frame", minBtn2, {
        Size = UDim2.new(0, 10, 0, 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    Corner(minIcon, UDim.new(1, 0))
    
    minBtn2.MouseButton1Click:Connect(function() window:Minimize() end)
    minBtn2.MouseEnter:Connect(function() Tween(minBtn2, {BackgroundTransparency = 0.3}) end)
    minBtn2.MouseLeave:Connect(function() Tween(minBtn2, {BackgroundTransparency = 0.6}) end)
    
    -- Close
    local closeBtn = Create("TextButton", controls, {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Colors.Error,
        BackgroundTransparency = 0.6,
        Text = "",
        BorderSizePixel = 0
    })
    Corner(closeBtn, UDim.new(0.5, 0))
    
    local closeIcon = Create("Frame", closeBtn, {
        Size = UDim2.new(0, 12, 0, 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0,
        Rotation = 45
    })
    Corner(closeIcon, UDim.new(1, 0))
    
    local closeIcon2 = Create("Frame", closeBtn, {
        Size = UDim2.new(0, 12, 0, 2),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0,
        Rotation = -45
    })
    Corner(closeIcon2, UDim.new(1, 0))
    
    closeBtn.MouseButton1Click:Connect(function() window:Destroy() end)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.3}) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundTransparency = 0.6}) end)
    
    -- ============================================
    -- SIDEBAR
    -- ============================================
    local sidebarVisible = not IS_MOBILE
    local sidebar = Create("Frame", main, {
        Size = UDim2.new(0, Sizes.Sidebar, 1, 0),
        Position = UDim2.new(0, IS_MOBILE and -Sizes.Sidebar or 0, 0, 0),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Visible = sidebarVisible
    })
    Corner(sidebar, Sizes.Radius)
    
    local sidebarContent = Create("ScrollingFrame", sidebar, {
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0
    })
    Pad(sidebarContent, 4, 4, 4, 4)
    
    local tabList = Create("UIListLayout", sidebarContent, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    -- Mobile menu toggle
    if IS_MOBILE and menuBtn then
        menuBtn.MouseButton1Click:Connect(function()
            sidebarVisible = not sidebarVisible
            if sidebarVisible then
                sidebar.Visible = true
                Tween(sidebar, {Position = UDim2.new(0, 0, 0, 0)})
            else
                Tween(sidebar, {Position = UDim2.new(0, -Sizes.Sidebar, 0, 0)}, 0.2, function()
                    if not sidebarVisible then sidebar.Visible = false end
                end)
            end
        end)
    end
    
    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local content = Create("Frame", main, {
        Size = UDim2.new(1, IS_MOBILE and 0 or -Sizes.Sidebar, 1, -48),
        Position = UDim2.new(0, IS_MOBILE and 0 or Sizes.Sidebar, 0, 48),
        BackgroundTransparency = 1
    })
    window.Content = content
    
    local contentContainer = Create("Frame", content, {
        Size = UDim2.new(1, -12, 1, -8),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundTransparency = 1
    })
    window.ContentContainer = contentContainer
    
    -- ============================================
    -- DRAG
    -- ============================================
    if not IS_MOBILE then
        local dragging, dragStart, startPos
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end
    
    -- ============================================
    -- WINDOW FUNCTIONS
    -- ============================================
    function window:Minimize()
        if self.Minimized then return end
        self.Minimized = true
        
        Tween(main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.25, function()
            main.Visible = false
        end)
        
        miniBtn.Visible = true
        miniBtn.Position = UDim2.new(0.5, 0, 0, -50)
        Tween(miniBtn, {Position = UDim2.new(0.5, 0, 0, 12)}, 0.3)
    end
    
    function window:Restore()
        if not self.Minimized then return end
        self.Minimized = false
        
        Tween(miniBtn, {Position = UDim2.new(0.5, 0, 0, -50)}, 0.2, function()
            miniBtn.Visible = false
        end)
        
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        Tween(main, {Size = UDim2.new(0, Sizes.Width, 0, Sizes.Height)}, 0.3)
    end
    
    function window:Destroy()
        Tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, function() gui:Destroy() end)
    end
    
    function window:Notify(opts)
        opts = opts or {}
        local nTitle = opts.Title or "Notification"
        local nContent = opts.Content or ""
        local nDuration = opts.Duration or 4
        local nType = opts.Type or "info"
        
        local typeColors = {
            info = Colors.Secondary,
            success = Colors.Success,
            warning = Colors.Warning,
            error = Colors.Error
        }
        
        local notif = Create("Frame", gui, {
            Size = UDim2.new(0, IS_MOBILE and 300 or 320, 0, IS_MOBILE and 70 or 65),
            Position = UDim2.new(0.5, 0, 0, -80),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Colors.Card,
            BorderSizePixel = 0
        })
        Corner(notif, 10)
        Stroke(notif, typeColors[nType] or Colors.Secondary, 1.5)
        Glow(notif, typeColors[nType] or Colors.Secondary)
        
        local accent = Create("Frame", notif, {
            Size = UDim2.new(0, 4, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundColor3 = typeColors[nType] or Colors.Secondary,
            BorderSizePixel = 0
        })
        Corner(accent, 2)
        
        local titleLabel = Create("TextLabel", notif, {
            Size = UDim2.new(1, -24, 0, 22),
            Position = UDim2.new(0, 16, 0, 8),
            BackgroundTransparency = 1,
            Text = nTitle,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local contentLabel = Create("TextLabel", notif, {
            Size = UDim2.new(1, -24, 0, 28),
            Position = UDim2.new(0, 16, 1, -36),
            BackgroundTransparency = 1,
            Text = nContent,
            TextColor3 = Colors.TextMuted,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })
        
        Tween(notif, {Position = UDim2.new(0.5, 0, 0, 12)}, 0.3)
        
        task.delay(nDuration, function()
            Tween(notif, {Position = UDim2.new(0.5, 0, 0, -80)}, 0.3, function()
                notif:Destroy()
            end)
        end)
    end
    
    -- ============================================
    -- CREATE TAB
    -- ============================================
    function window:CreateTab(opts)
        opts = opts or {}
        local name = opts.Name or "Tab"
        local icon = opts.Icon or "rbxassetid://6034277709"
        
        local tab = {
            Name = name,
            Sections = {}
        }
        
        -- Tab button
        local btn = Create("TextButton", sidebarContent, {
            Size = UDim2.new(1, -4, 0, IS_MOBILE and 44 or 34),
            BackgroundColor3 = Colors.Card,
            BackgroundTransparency = 0.7,
            Text = "",
            BorderSizePixel = 0
        })
        Corner(btn, 8)
        tab.Button = btn
        
        local btnContent = Create("Frame", btn, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        })
        
        -- Icon
        local iconLabel = Create("ImageLabel", btnContent, {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(IS_MOBILE and 0.5 or 0.08, 0, 0.5, 0),
            AnchorPoint = Vector2.new(IS_MOBILE and 0.5 or 0, 0.5),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Colors.TextMuted
        })
        tab.Icon = iconLabel
        
        -- Label (desktop only)
        local label
        if not IS_MOBILE then
            label = Create("TextLabel", btnContent, {
                Size = UDim2.new(1, -32, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Colors.TextMuted,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            tab.Label = label
        end
        
        -- Tab content
        local tabContent = Create("ScrollingFrame", contentContainer, {
            Name = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Primary,
            ScrollBarImageTransparency = 0.5,
            BorderSizePixel = 0,
            Visible = false
        })
        Pad(tabContent, 0, 0, 0, 4)
        
        local layout = Create("UIListLayout", tabContent, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        tab.Content = tabContent
        
        -- Events
        btn.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)
        
        btn.MouseEnter:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(btn, {BackgroundTransparency = 0.4})
                Tween(iconLabel, {ImageColor3 = Colors.Text})
                if label then Tween(label, {TextColor3 = Colors.Text}) end
            end
        end)
        
        btn.MouseLeave:Connect(function()
            if window.CurrentTab ~= tab then
                Tween(btn, {BackgroundTransparency = 0.7})
                Tween(iconLabel, {ImageColor3 = Colors.TextMuted})
                if label then Tween(label, {TextColor3 = Colors.TextMuted}) end
            end
        end)
        
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then window:SelectTab(tab) end
        
        -- Create Section
        function tab:CreateSection(sOpts)
            sOpts = sOpts or {}
            local sName = sOpts.Name or "Section"
            
            local section = {Name = sName}
            
            local sectionFrame = Create("Frame", tabContent, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Colors.Card,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Corner(sectionFrame, 10)
            Stroke(sectionFrame)
            section.Frame = sectionFrame
            
            local header = Create("Frame", sectionFrame, {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            })
            
            local headerTitle = Create("TextLabel", header, {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = sName,
                TextColor3 = Colors.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sectionContent = Create("Frame", sectionFrame, {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Pad(sectionContent, 8, 12, 10, 10)
            
            local cLayout = Create("UIListLayout", sectionContent, {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            section.Content = sectionContent
            
            return section
        end
        
        return tab
    end
    
    -- ============================================
    -- SELECT TAB
    -- ============================================
    function window:SelectTab(tab)
        if window.CurrentTab == tab then return end
        
        if window.CurrentTab then
            local cur = window.CurrentTab
            if cur.Content then cur.Content.Visible = false end
            if cur.Button then Tween(cur.Button, {BackgroundTransparency = 0.7, BackgroundColor3 = Colors.Card}) end
            if cur.Icon then Tween(cur.Icon, {ImageColor3 = Colors.TextMuted}) end
            if cur.Label then Tween(cur.Label, {TextColor3 = Colors.TextMuted}) end
        end
        
        window.CurrentTab = tab
        if tab.Content then tab.Content.Visible = true end
        if tab.Button then
            Tween(tab.Button, {BackgroundTransparency = 0, BackgroundColor3 = Colors.Primary})
        end
        if tab.Icon then Tween(tab.Icon, {ImageColor3 = Colors.Text}) end
        if tab.Label then Tween(tab.Label, {TextColor3 = Colors.Text}) end
        
        -- Close sidebar on mobile
        if IS_MOBILE and sidebarVisible then
            Tween(sidebar, {Position = UDim2.new(0, -Sizes.Sidebar, 0, 0)}, 0.2, function()
                sidebarVisible = false
                sidebar.Visible = false
            end)
        end
    end
    
    return window
end

-- ============================================
-- COMPONENTS
-- ============================================
Aurora.Components = {}

function Aurora.Components.Button(section, opts)
    opts = opts or {}
    local text = opts.Text or "Button"
    local callback = opts.Callback or function() end
    
    local btn = Create("TextButton", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight),
        BackgroundColor3 = Colors.Primary,
        BackgroundTransparency = 0.7,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        BorderSizePixel = 0
    })
    Corner(btn, 8)
    Gradient(btn)
    
    btn.MouseButton1Click:Connect(function() callback() end)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.4}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0.7}) end)
    
    return btn
end

function Aurora.Components.Toggle(section, opts)
    opts = opts or {}
    local text = opts.Text or "Toggle"
    local default = opts.Default or false
    local callback = opts.Callback or function() end
    local value = default
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggle = Create("TextButton", container, {
        Size = UDim2.new(0, 46, 0, 26),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default and Colors.Success or Colors.Border,
        BackgroundTransparency = default and 0.5 or 0.3,
        Text = "",
        BorderSizePixel = 0
    })
    Corner(toggle, UDim.new(1, 0))
    
    local circle = Create("Frame", toggle, {
        Size = UDim2.new(0, 20, 0, 20),
        Position = default and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0
    })
    Corner(circle, UDim.new(1, 0))
    
    toggle.MouseButton1Click:Connect(function()
        value = not value
        Tween(toggle, {
            BackgroundColor3 = value and Colors.Success or Colors.Border,
            BackgroundTransparency = value and 0.5 or 0.3
        })
        Tween(circle, {Position = value and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
        callback(value)
    end)
    
    return {
        SetValue = function(v)
            value = v
            Tween(toggle, {BackgroundColor3 = value and Colors.Success or Colors.Border})
            Tween(circle, {Position = value and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)})
            callback(value)
        end,
        GetValue = function() return value end
    }
end

function Aurora.Components.Slider(section, opts)
    opts = opts or {}
    local text = opts.Text or "Slider"
    local min = opts.Min or 0
    local max = opts.Max or 100
    local default = opts.Default or min
    local decimals = opts.Decimals or 0
    local callback = opts.Callback or function() end
    local value = default
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight + 8),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -50, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valLabel = Create("TextLabel", container, {
        Size = UDim2.new(0, 42, 0, 18),
        Position = UDim2.new(1, -4, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Colors.Secondary,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderBg = Create("Frame", container, {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    Corner(sliderBg, UDim.new(1, 0))
    
    local sliderFill = Create("Frame", sliderBg, {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0
    })
    Corner(sliderFill, UDim.new(1, 0))
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
        valLabel.Text = tostring(value)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    return {
        SetValue = function(v)
            value = math.clamp(v, min, max)
            sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valLabel.Text = tostring(value)
            callback(value)
        end,
        GetValue = function() return value end
    }
end

function Aurora.Components.Dropdown(section, opts)
    opts = opts or {}
    local text = opts.Text or "Dropdown"
    local items = opts.Items or {}
    local default = opts.Default or items[1] or "Select"
    local callback = opts.Callback or function() end
    local value = default
    local open = false
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    
    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local btn = Create("TextButton", container, {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        Text = "",
        BorderSizePixel = 0
    })
    Corner(btn, 8)
    Stroke(btn)
    
    local selected = Create("TextLabel", btn, {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local arrow = Create("TextLabel", btn, {
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -22, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Colors.TextMuted,
        TextSize = 8,
        Font = Enum.Font.GothamBold
    })
    
    local list = Create("Frame", container, {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Corner(list, 8)
    Stroke(list)
    
    local listLayout = Create("UIListLayout", list, {SortOrder = Enum.SortOrder.LayoutOrder})
    
    local function refresh()
        for _, child in pairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, item in pairs(items) do
            local itemBtn = Create("TextButton", list, {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = item == value and Colors.Primary or Colors.Card,
                BackgroundTransparency = item == value and 0.5 or 0.7,
                Text = item,
                TextColor3 = Colors.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0
            })
            Corner(itemBtn, 6)
            
            itemBtn.MouseButton1Click:Connect(function()
                value = item
                selected.Text = item
                open = false
                Tween(container, {Size = UDim2.new(1, 0, 0, Sizes.ElementHeight)})
                arrow.Text = "▼"
                refresh()
                callback(item)
            end)
            
            itemBtn.MouseEnter:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundTransparency = 0.4}) end
            end)
            
            itemBtn.MouseLeave:Connect(function()
                if item ~= value then Tween(itemBtn, {BackgroundTransparency = 0.7}) end
            end)
        end
    end
    
    refresh()
    
    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local h = 30 * #items + 6
            Tween(container, {Size = UDim2.new(1, 0, 0, Sizes.ElementHeight + h)})
            arrow.Text = "▲"
        else
            Tween(container, {Size = UDim2.new(1, 0, 0, Sizes.ElementHeight)})
            arrow.Text = "▼"
        end
    end)
    
    return {
        SetValue = function(v) value = v; selected.Text = v; refresh(); callback(v) end,
        GetValue = function() return value end,
        Refresh = function(newItems) items = newItems; refresh() end
    }
end

function Aurora.Components.Label(section, opts)
    opts = opts or {}
    local text = opts.Text or "Label"
    
    local label = Create("TextLabel", section.Content, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    return {SetText = function(t) label.Text = t end}
end

function Aurora.Components.Paragraph(section, opts)
    opts = opts or {}
    local title = opts.Title or "Title"
    local content = opts.Content or "Content"
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    Corner(container, 8)
    Pad(container, 10, 10, 10, 10)
    
    local titleLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local contentLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Colors.TextMuted,
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
    local div = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Colors.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    return div
end

function Aurora.Components.Keybind(section, opts)
    opts = opts or {}
    local text = opts.Text or "Keybind"
    local default = opts.Default or Enum.KeyCode.Unknown
    local callback = opts.Callback or function() end
    local key = default
    local listening = false
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local keyBtn = Create("TextButton", container, {
        Size = UDim2.new(0, 62, 0, 28),
        Position = UDim2.new(1, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        Text = key.Name,
        TextColor3 = Colors.Text,
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        BorderSizePixel = 0
    })
    Corner(keyBtn, 6)
    Stroke(keyBtn)
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = Colors.Primary
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                keyBtn.Text = key.Name
                keyBtn.BackgroundColor3 = Colors.Card
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

function Aurora.Components.Textbox(section, opts)
    opts = opts or {}
    local text = opts.Text or "Input"
    local default = opts.Default or ""
    local placeholder = opts.Placeholder or "Enter..."
    local numeric = opts.Numeric or false
    local callback = opts.Callback or function() end
    local value = default
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, Sizes.ElementHeight + 6),
        BackgroundTransparency = 1
    })
    
    local label = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textbox = Create("TextBox", container, {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Colors.TextDim,
        TextColor3 = Colors.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0
    })
    Corner(textbox, 6)
    Stroke(textbox)
    Pad(textbox, 0, 0, 10, 10)
    
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
        Size = UDim2.new(1, 0, 0, IS_MOBILE and 80 or 70),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Corner(container, 10)
    Stroke(container)
    Pad(container, 10, 10, 10, 10)
    
    local avatar = Create("ImageLabel", container, {
        Size = UDim2.new(0, IS_MOBILE and 48 or 44, 0, IS_MOBILE and 48 or 44),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Colors.Primary,
        Image = info.Avatar,
        BorderSizePixel = 0
    })
    Corner(avatar, 10)
    Gradient(avatar)
    
    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, IS_MOBILE and -68 or -60, 1, 0),
        Position = UDim2.new(0, IS_MOBILE and 64 or 56, 0, 0),
        BackgroundTransparency = 1
    })
    
    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.Name .. " (@" .. info.Username .. ")",
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local id = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "ID: " .. info.Id .. "  •  Age: " .. info.Age,
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local membership = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = info.Membership,
        TextColor3 = info.Membership == "Premium" and Colors.Warning or Colors.TextMuted,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return container
end

function Aurora.Components.ExecutorInfo(section)
    local info = GetExecutorInfo()
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Corner(container, 10)
    Stroke(container)
    Pad(container, 10, 10, 10, 10)
    
    local icon = Create("Frame", container, {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0
    })
    Corner(icon, 8)
    Gradient(icon)
    
    local iconText = Create("TextLabel", icon, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⚡",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    
    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1
    })
    
    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.Name,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local version = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "Version: " .. info.Version,
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return container
end

function Aurora.Components.GameInfo(section)
    local info = GetGameInfo()
    
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Corner(container, 10)
    Stroke(container)
    Pad(container, 10, 10, 10, 10)
    
    local icon = Create("Frame", container, {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0
    })
    Corner(icon, 8)
    Gradient(icon, Colors.Secondary, Colors.Primary)
    
    local iconText = Create("TextLabel", icon, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🎮",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    })
    
    local infoFrame = Create("Frame", container, {
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1
    })
    
    local name = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = info.Name,
        TextColor3 = Colors.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local placeId = Create("TextLabel", infoFrame, {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "Place: " .. info.PlaceId .. "  •  " .. info.ServerType,
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return container
end

function Aurora.Components.TimeDisplay(section)
    local container = Create("Frame", section.Content, {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Colors.Card,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    })
    Corner(container, 10)
    Stroke(container)
    Pad(container, 8, 8, 8, 8)
    
    local timeLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0.35, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "00:00:00 AM",
        TextColor3 = Colors.Text,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    Gradient(timeLabel)
    
    local dateLabel = Create("TextLabel", container, {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.72, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "Monday, January 01",
        TextColor3 = Colors.TextMuted,
        TextSize = 11,
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
            dateLabel.Text = os.date("%A, %B %d")
            task.wait(1)
        end
    end)()
    
    return container
end

Aurora.Version = "3.0.0"
Aurora.Name = "Aurora Library"

return Aurora
