
local Services = {}

local function GetService(Name)
    local ok, svc = pcall(function() return game:GetService(Name) end)
    return ok and svc or nil
end

Services.Players = GetService("Players")
Services.TweenService = GetService("TweenService")
Services.UserInputService = GetService("UserInputService")
Services.RunService = GetService("RunService")

local LocalPlayer = Services.Players and Services.Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════

local Utility = {}

function Utility.Round(n, d)
    d = d or 0
    return math.floor(n * 10^d + 0.5) / 10^d
end

function Utility.Clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function Utility.FormatTime(s)
    return string.format("%02d:%02d:%02d", math.floor(s/3600), math.floor((s%3600)/60), math.floor(s%60))
end

function Utility.FormatNumber(n)
    return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- ═══════════════════════════════════════════════════════════════
-- AURORA LIBRARY
-- ═══════════════════════════════════════════════════════════════

local Aurora = {
    Version = "1.0.2",
    Windows = {},
}

-- ═══════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════

local Theme = {
    -- Colors
    AuroraCyan = Color3.fromRGB(100, 220, 255),
    AuroraViolet = Color3.fromRGB(180, 100, 255),
    Accent = Color3.fromRGB(100, 200, 255),
    BackgroundPrimary = Color3.fromRGB(15, 15, 25),
    BackgroundSecondary = Color3.fromRGB(20, 20, 35),
    BackgroundTertiary = Color3.fromRGB(25, 25, 40),
    BackgroundQuaternary = Color3.fromRGB(35, 35, 55),
    GlassBackground = Color3.fromRGB(20, 20, 35),
    GlassBackgroundTransparency = 0.15,
    GlassBorder = Color3.fromRGB(255, 255, 255),
    GlassBorderTransparency = 0.85,
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 140),
    Divider = Color3.fromRGB(60, 60, 80),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(100, 180, 255),
    
    -- Sizes
    WindowWidth = 520,
    WindowHeight = 450,
    SidebarWidth = 140,
    TabHeight = 36,
    ComponentHeight = 40,
    ComponentSpacing = 8,
    
    -- Corner Radius
    Corner = {
        Window = UDim.new(0, 16),
        Card = UDim.new(0, 12),
        Button = UDim.new(0, 8),
        Small = UDim.new(0, 6),
        Pill = UDim.new(0, 20),
    },
    
    -- Animation
    AnimDuration = { Fast = 0.15, Normal = 0.25, Slow = 0.4 },
    
    -- Font
    Font = {
        Title = Enum.Font.GothamBold,
        Subtitle = Enum.Font.GothamSemibold,
        Body = Enum.Font.Gotham,
        Mono = Enum.Font.Code,
    },
    FontSize = { Title = 20, Subtitle = 14, Body = 13, Small = 11 },
}

-- ═══════════════════════════════════════════════════════════════
-- ANIMATION HELPERS
-- ═══════════════════════════════════════════════════════════════

local Anim = {}

function Anim.Play(obj, props, dur, style)
    dur = dur or Theme.AnimDuration.Normal
    style = style or Enum.EasingStyle.Quad
    local tween = Services.TweenService:Create(obj, TweenInfo.new(dur, style, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

function Anim.Fade(obj, target, dur, cb)
    local props = {}
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        props.TextTransparency = target
        props.BackgroundTransparency = target
    elseif obj:IsA("Frame") then
        props.BackgroundTransparency = target
    end
    local t = Anim.Play(obj, props, dur)
    if cb then t.Completed:Connect(cb) end
    return t
end

function Anim.Scale(obj, target, dur, style, cb)
    dur = dur or Theme.AnimDuration.Normal
    local scale = obj:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Parent = obj
        scale.Scale = 1
    end
    local t = Anim.Play(scale, {Scale = target}, dur, style)
    if cb then t.Completed:Connect(cb) end
    return t
end

function Anim.Slide(obj, target, dur, style, cb)
    local t = Anim.Play(obj, {Position = target}, dur, style or Enum.EasingStyle.Quart)
    if cb then t.Completed:Connect(cb) end
    return t
end

-- ═══════════════════════════════════════════════════════════════
-- UI COMPONENT HELPERS
-- ═══════════════════════════════════════════════════════════════

local UIHelpers = {}

function UIHelpers.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.Corner.Card
    c.Parent = parent
    return c
end

function UIHelpers.Stroke(parent, color, trans, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.GlassBorder
    s.Transparency = trans or Theme.GlassBorderTransparency
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

function UIHelpers.Gradient(parent, colorSeq, rot)
    local g = Instance.new("UIGradient")
    g.Color = colorSeq or ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.AuroraCyan), ColorSequenceKeypoint.new(1, Theme.AuroraViolet)})
    g.Rotation = rot or 90
    g.Parent = parent
    return g
end

function UIHelpers.ListLayout(parent, dir, pad)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = pad or UDim.new(0, Theme.ComponentSpacing)
    l.Parent = parent
    return l
end

function UIHelpers.Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = top or UDim.new(0, 12)
    p.PaddingBottom = bottom or UDim.new(0, 12)
    p.PaddingLeft = left or UDim.new(0, 12)
    p.PaddingRight = right or UDim.new(0, 12)
    p.Parent = parent
    return p
end

-- ═══════════════════════════════════════════════════════════════
-- INFO PROVIDER
-- ═══════════════════════════════════════════════════════════════

local InfoProvider = {
    StartTime = os.time(),
    ExecutorInfo = nil,
}

function InfoProvider.GetExecutor()
    if InfoProvider.ExecutorInfo then return InfoProvider.ExecutorInfo end
    local info = {Name = "Unknown", Version = "N/A", Env = "Unknown"}
    
    pcall(function() if syn then info.Name = "Synapse X" info.Env = "Synapse" end end)
    pcall(function() if getgenv and getgenv().SCRIPTWARE then info.Name = "Script-Ware" end end)
    pcall(function() if KRNL_LOADED then info.Name = "KRNL" end end)
    pcall(function() if fluxus then info.Name = "Fluxus" end end)
    pcall(function() if Services.RunService:IsStudio() then info.Name = "Studio" info.Env = "Editor" end end)
    
    InfoProvider.ExecutorInfo = info
    return info
end

function InfoProvider.GetGame()
    local info = {Name = "Unknown", GameId = "N/A", PlaceId = "N/A", JobId = "N/A", Server = "Unknown", Players = "N/A"}
    pcall(function() info.Name = game.Name end)
    pcall(function() info.GameId = tostring(game.GameId) end)
    pcall(function() info.PlaceId = tostring(game.PlaceId) end)
    pcall(function() info.JobId = game.JobId or "N/A" end)
    pcall(function() info.Server = game.PrivateServerId ~= "" and "Private" or "Public" end)
    pcall(function() info.Players = #Services.Players:GetPlayers() .. "/" .. Services.Players.MaxPlayers end)
    return info
end

function InfoProvider.GetPlayer()
    local info = {Username = "Unknown", UserId = "N/A", DisplayName = "Unknown", Age = "N/A", Premium = "No"}
    if not LocalPlayer then return info end
    pcall(function() info.Username = LocalPlayer.Name end)
    pcall(function() info.UserId = tostring(LocalPlayer.UserId) end)
    pcall(function() info.DisplayName = LocalPlayer.DisplayName end)
    pcall(function() info.Age = Utility.FormatNumber(LocalPlayer.AccountAge) .. " days" end)
    pcall(function() info.Premium = LocalPlayer.MembershipType == Enum.MembershipType.Premium and "Yes" or "No" end)
    return info
end

function InfoProvider.GetSession()
    local runtime = os.time() - InfoProvider.StartTime
    return {
        Time = os.date("%H:%M:%S", os.time()),
        Runtime = Utility.FormatTime(runtime),
        Loaded = os.date("%Y-%m-%d %H:%M:%S", InfoProvider.StartTime)
    }
end

-- ═══════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════

local State = {Data = {}}
function State.Save(k, v) State.Data[k] = v end
function State.Load(k, d) return State.Data[k] or d end

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════

function Aurora:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Aurora"
    local subtitle = cfg.Subtitle or "Modern UI"
    local accent = cfg.Accent or Theme.Accent
    local size = cfg.Size or UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight)
    
    -- ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "Aurora_" .. math.random(10000, 99999)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.DisplayOrder = 100
    
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            screen.Parent = LocalPlayer.PlayerGui
        else
            screen.Parent = game.CoreGui or game:GetService("CoreGui")
        end
    end)
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = size
    main.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    main.BackgroundColor3 = Theme.BackgroundPrimary
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Parent = screen
    UIHelpers.Corner(main, Theme.Corner.Window)
    UIHelpers.Stroke(main, Color3.fromRGB(60, 60, 80), 0.5, 1)
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Theme.BackgroundSecondary
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    UIHelpers.Corner(titleBar, Theme.Corner.Window)
    
    -- Accent Line
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 1, -2)
    accentLine.BackgroundColor3 = accent
    accentLine.BorderSizePixel = 0
    accentLine.Parent = titleBar
    UIHelpers.Gradient(accentLine, ColorSequence.new({ColorSequenceKeypoint.new(0, accent), ColorSequenceKeypoint.new(1, accent)}))
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.6, 0, 0.6, 0)
    titleText.Position = UDim2.new(0, 16, 0, 4)
    titleText.Text = title
    titleText.Font = Theme.Font.Title
    titleText.TextSize = Theme.FontSize.Title
    titleText.TextColor3 = Theme.TextPrimary
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.Parent = titleBar
    
    -- Subtitle
    local subText = Instance.new("TextLabel")
    subText.Size = UDim2.new(0.6, 0, 0.4, 0)
    subText.Position = UDim2.new(0, 16, 0.55, 0)
    subText.Text = subtitle
    subText.Font = Theme.Font.Body
    subText.TextSize = Theme.FontSize.Small
    subText.TextColor3 = Theme.TextSecondary
    subText.TextXAlignment = Enum.TextXAlignment.Left
    subText.BackgroundTransparency = 1
    subText.Parent = titleBar
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -72, 0.5, -14)
    minBtn.BackgroundColor3 = Theme.BackgroundTertiary
    minBtn.BackgroundTransparency = 0.2
    minBtn.Text = "─"
    minBtn.Font = Theme.Font.Body
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BorderSizePixel = 0
    minBtn.Parent = titleBar
    UIHelpers.Corner(minBtn, Theme.Corner.Small)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.Font.Body
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Theme.TextPrimary
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    UIHelpers.Corner(closeBtn, Theme.Corner.Small)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, Theme.SidebarWidth, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    sidebar.BackgroundTransparency = 0.15
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    UIHelpers.Corner(sidebar, Theme.Corner.Window)
    
    -- Sidebar Content
    local sidebarContent = Instance.new("ScrollingFrame")
    sidebarContent.Name = "Content"
    sidebarContent.Size = UDim2.new(1, -8, 1, -16)
    sidebarContent.Position = UDim2.new(0, 4, 0, 8)
    sidebarContent.BackgroundTransparency = 1
    sidebarContent.ScrollBarThickness = 4
    sidebarContent.ScrollBarImageColor3 = Theme.Accent
    sidebarContent.BorderSizePixel = 0
    sidebarContent.Parent = sidebar
    UIHelpers.Padding(sidebarContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
    UIHelpers.ListLayout(sidebarContent, Enum.FillDirection.Vertical, UDim.new(0, 6))
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -Theme.SidebarWidth, 1, -50)
    contentArea.Position = UDim2.new(0, Theme.SidebarWidth, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = main
    
    -- Content Container
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Name = "Container"
    contentContainer.Size = UDim2.new(1, -16, 1, -16)
    contentContainer.Position = UDim2.new(0, 8, 0, 8)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ScrollBarThickness = 4
    contentContainer.ScrollBarImageColor3 = Theme.Accent
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = contentArea
    UIHelpers.Padding(contentContainer, UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8))
    UIHelpers.ListLayout(contentContainer, Enum.FillDirection.Vertical, UDim.new(0, 12))
    
    -- Minimized Pill
    local pill = Instance.new("Frame")
    pill.Name = "MinimizedPill"
    pill.Size = UDim2.new(0, 150, 0, 44)
    pill.Position = UDim2.new(1, -170, 1, -60)
    pill.BackgroundColor3 = Theme.BackgroundSecondary
    pill.BackgroundTransparency = 0.1
    pill.BorderSizePixel = 0
    pill.Visible = false
    pill.Parent = screen
    UIHelpers.Corner(pill, Theme.Corner.Pill)
    UIHelpers.Stroke(pill, Theme.GlassBorder, 0.7)
    
    -- Pill Accent
    local pillAccent = Instance.new("Frame")
    pillAccent.Size = UDim2.new(0, 3, 0.6, 0)
    pillAccent.Position = UDim2.new(0, 6, 0.2, 0)
    pillAccent.BackgroundColor3 = accent
    pillAccent.BorderSizePixel = 0
    pillAccent.Parent = pill
    UIHelpers.Corner(pillAccent, UDim.new(0, 2))
    
    -- Pill Title
    local pillTitle = Instance.new("TextLabel")
    pillTitle.Size = UDim2.new(1, -40, 1, 0)
    pillTitle.Position = UDim2.new(0, 18, 0, 0)
    pillTitle.Text = title
    pillTitle.Font = Theme.Font.Subtitle
    pillTitle.TextSize = Theme.FontSize.Body
    pillTitle.TextColor3 = Theme.TextPrimary
    pillTitle.TextXAlignment = Enum.TextXAlignment.Left
    pillTitle.BackgroundTransparency = 1
    pillTitle.Parent = pill
    
    -- Pill Button
    local pillBtn = Instance.new("TextButton")
    pillBtn.Size = UDim2.new(1, 0, 1, 0)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text = ""
    pillBtn.BorderSizePixel = 0
    pillBtn.Parent = pill
    
    -- Window State
    local winState = {Minimized = false, ActiveTab = nil, Tabs = {}, ScrollPos = {}}
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            screen.DisplayOrder = 100 + math.random(1, 10)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    if Services.UserInputService then
        Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    
    -- Minimize/Restore
    local function minimize()
        if winState.Minimized then return end
        winState.ScrollPos = {}
        for _, tab in ipairs(winState.Tabs) do
            if tab.Content then winState.ScrollPos[tab.Name] = tab.Content.CanvasPosition end
        end
        Anim.Scale(main, 0.8, Theme.AnimDuration.Normal, Enum.EasingStyle.Quad, function()
            main.Visible = false
            pill.Visible = true
            Anim.Scale(pill, 0.9, 0)
            Anim.Scale(pill, 1, Theme.AnimDuration.Normal, Enum.EasingStyle.Back)
        end)
        Anim.Fade(main, 0.5, Theme.AnimDuration.Normal)
        winState.Minimized = true
    end
    
    local function restore()
        if not winState.Minimized then return end
        Anim.Scale(pill, 0.9, Theme.AnimDuration.Fast, Enum.EasingStyle.Quad, function()
            pill.Visible = false
            main.Visible = true
            Anim.Scale(main, 0.9, 0)
            Anim.Scale(main, 1, Theme.AnimDuration.Normal, Enum.EasingStyle.Back)
            Anim.Fade(main, 0, Theme.AnimDuration.Normal)
            for _, tab in ipairs(winState.Tabs) do
                if tab.Content and winState.ScrollPos[tab.Name] then
                    tab.Content.CanvasPosition = winState.ScrollPos[tab.Name]
                end
            end
        end)
        winState.Minimized = false
    end
    
    minBtn.MouseButton1Click:Connect(minimize)
    closeBtn.MouseButton1Click:Connect(function()
        Anim.Scale(main, 0.9, Theme.AnimDuration.Normal, Enum.EasingStyle.Quad)
        Anim.Fade(main, 0.8, Theme.AnimDuration.Normal, function() screen:Destroy() end)
    end)
    pillBtn.MouseButton1Click:Connect(restore)
    
    -- Tab System
    local tabCount = 0
    
    local function createTab(cfg)
        cfg = cfg or {}
        local tabName = cfg.Name or "Tab " .. (tabCount + 1)
        local tabIcon = cfg.Icon
        tabCount = tabCount + 1
        
        -- Tab Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(1, 0, 0, Theme.TabHeight)
        tabBtn.BackgroundColor3 = Theme.BackgroundTertiary
        tabBtn.BackgroundTransparency = 0.5
        tabBtn.Text = ""
        tabBtn.BorderSizePixel = 0
        tabBtn.LayoutOrder = tabCount
        tabBtn.Parent = sidebarContent
        UIHelpers.Corner(tabBtn, Theme.Corner.Button)
        
        -- Icon
        local iconOffset = 0
        if tabIcon then
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, 8, 0.5, -10)
            icon.Text = tabIcon
            icon.Font = Theme.Font.Body
            icon.TextSize = 14
            icon.TextColor3 = Theme.TextSecondary
            icon.BackgroundTransparency = 1
            icon.Parent = tabBtn
            iconOffset = 24
        end
        
        -- Tab Label
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "TabLabel"
        tabLabel.Size = UDim2.new(1, -iconOffset - 16, 1, 0)
        tabLabel.Position = UDim2.new(0, iconOffset + 8, 0, 0)
        tabLabel.Text = tabName
        tabLabel.Font = Theme.Font.Body
        tabLabel.TextSize = Theme.FontSize.Body
        tabLabel.TextColor3 = Theme.TextSecondary
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.BackgroundTransparency = 1
        tabLabel.Parent = tabBtn
        
        -- Indicator
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = tabBtn
        UIHelpers.Corner(indicator, UDim.new(0, 2))
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Theme.Accent
        tabContent.Visible = false
        tabContent.BorderSizePixel = 0
        tabContent.Parent = contentContainer
        UIHelpers.Padding(tabContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
        UIHelpers.ListLayout(tabContent, Enum.FillDirection.Vertical, UDim.new(0, 8))
        
        -- Tab Object
        local tab = {
            Name = tabName,
            Button = tabBtn,
            Label = tabLabel,
            Content = tabContent,
            Sections = {},
            SectionCount = 0,
        }
        
        -- Select Tab
        local function selectTab()
            for _, other in ipairs(winState.Tabs) do
                other.Content.Visible = false
                Anim.Play(other.Button, {BackgroundTransparency = 0.5}, Theme.AnimDuration.Fast)
                Anim.Play(other.Button.Indicator, {BackgroundTransparency = 1}, Theme.AnimDuration.Fast)
                if other.Label then other.Label.TextColor3 = Theme.TextSecondary end
            end
            
            tabContent.Visible = true
            Anim.Play(tabBtn, {BackgroundTransparency = 0.2}, Theme.AnimDuration.Fast)
            Anim.Play(indicator, {BackgroundTransparency = 0}, Theme.AnimDuration.Fast)
            if tabLabel then tabLabel.TextColor3 = Theme.TextPrimary end
            
            winState.ActiveTab = tab
            
            task.defer(function()
                local layout = tabContent:FindFirstChildOfClass("UIListLayout")
                if layout then tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16) end
            end)
        end
        
        tabBtn.MouseButton1Click:Connect(selectTab)
        
        tabBtn.MouseEnter:Connect(function()
            if winState.ActiveTab ~= tab then
                Anim.Play(tabBtn, {BackgroundTransparency = 0.3}, Theme.AnimDuration.Fast)
            end
        end)
        
        tabBtn.MouseLeave:Connect(function()
            if winState.ActiveTab ~= tab then
                Anim.Play(tabBtn, {BackgroundTransparency = 0.5}, Theme.AnimDuration.Fast)
            end
        end)
        
        -- Create Section
        local function createSection(cfg)
            cfg = cfg or {}
            local secName = cfg.Name or "Section"
            tab.SectionCount = tab.SectionCount + 1
            
            local card = Instance.new("Frame")
            card.Name = secName
            card.Size = UDim2.new(1, 0, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = Theme.GlassBackground
            card.BackgroundTransparency = Theme.GlassBackgroundTransparency
            card.BorderSizePixel = 0
            card.LayoutOrder = tab.SectionCount
            card.Parent = tabContent
            UIHelpers.Corner(card, Theme.Corner.Card)
            UIHelpers.Stroke(card, Theme.GlassBorder, Theme.GlassBorderTransparency)
            
            local secContent = Instance.new("Frame")
            secContent.Name = "Content"
            secContent.Size = UDim2.new(1, 0, 0, 0)
            secContent.AutomaticSize = Enum.AutomaticSize.Y
            secContent.BackgroundTransparency = 1
            secContent.BorderSizePixel = 0
            secContent.Parent = card
            UIHelpers.Padding(secContent, UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12))
            UIHelpers.ListLayout(secContent, Enum.FillDirection.Vertical, UDim.new(0, Theme.ComponentSpacing))
            
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 24)
            header.BackgroundTransparency = 1
            header.BorderSizePixel = 0
            header.Parent = secContent
            
            local headerText = Instance.new("TextLabel")
            headerText.Size = UDim2.new(1, 0, 1, 0)
            headerText.Text = secName
            headerText.Font = Theme.Font.Subtitle
            headerText.TextSize = Theme.FontSize.Subtitle
            headerText.TextColor3 = Theme.TextPrimary
            headerText.TextXAlignment = Enum.TextXAlignment.Left
            headerText.BackgroundTransparency = 1
            headerText.Parent = header
            
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, 0, 0, 1)
            divider.BackgroundColor3 = Theme.Divider
            divider.BackgroundTransparency = 0.5
            divider.BorderSizePixel = 0
            divider.Parent = secContent
            
            local compContainer = Instance.new("Frame")
            compContainer.Name = "Components"
            compContainer.Size = UDim2.new(1, 0, 0, 0)
            compContainer.AutomaticSize = Enum.AutomaticSize.Y
            compContainer.BackgroundTransparency = 1
            compContainer.BorderSizePixel = 0
            compContainer.Parent = secContent
            UIHelpers.ListLayout(compContainer, Enum.FillDirection.Vertical, UDim.new(0, Theme.ComponentSpacing))
            
            local layout = compContainer:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    task.defer(function()
                        local cl = tabContent:FindFirstChildOfClass("UIListLayout")
                        if cl then tabContent.CanvasSize = UDim2.new(0, 0, 0, cl.AbsoluteContentSize.Y + 16) end
                    end)
                end)
            end
            
            local section = {
                Name = secName,
                Container = compContainer,
                Count = 0,
            }
            
            -- ═══ COMPONENTS ═══
            
            -- Button
            function section:AddButton(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local text = cfg.Text or "Button"
                local cb = cfg.Callback or function() end
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                btn.BackgroundColor3 = Theme.BackgroundTertiary
                btn.BackgroundTransparency = 0.2
                btn.Text = text
                btn.Font = Theme.Font.Body
                btn.TextSize = Theme.FontSize.Body
                btn.TextColor3 = Theme.TextPrimary
                btn.BorderSizePixel = 0
                btn.LayoutOrder = self.Count
                btn.Parent = self.Container
                UIHelpers.Corner(btn, Theme.Corner.Button)
                UIHelpers.Stroke(btn, Theme.GlassBorder, 0.9)
                
                btn.MouseEnter:Connect(function() Anim.Play(btn, {BackgroundTransparency = 0.1}, Theme.AnimDuration.Fast) end)
                btn.MouseLeave:Connect(function() Anim.Play(btn, {BackgroundTransparency = 0.2}, Theme.AnimDuration.Fast) end)
                btn.MouseButton1Click:Connect(cb)
                
                return btn
            end
            
            -- Toggle
            function section:AddToggle(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or "Toggle"
                local default = cfg.Default or false
                local cb = cfg.Callback or function() end
                local value = default
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -60, 1, 0)
                label.Text = title
                label.Font = Theme.Font.Body
                label.TextSize = Theme.FontSize.Body
                label.TextColor3 = Theme.TextPrimary
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = container
                
                local switch = Instance.new("TextButton")
                switch.Size = UDim2.new(0, 48, 0, 24)
                switch.Position = UDim2.new(1, -48, 0.5, -12)
                switch.BackgroundColor3 = value and accent or Theme.BackgroundQuaternary
                switch.BackgroundTransparency = 0.2
                switch.Text = ""
                switch.BorderSizePixel = 0
                switch.Parent = container
                UIHelpers.Corner(switch, Theme.Corner.Pill)
                UIHelpers.Stroke(switch, Theme.GlassBorder, 0.85)
                
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 18, 0, 18)
                knob.Position = UDim2.new(value and 1 or 0, value and -21 or 3, 0.5, -9)
                knob.BackgroundColor3 = Color3.new(1, 1, 1)
                knob.BorderSizePixel = 0
                knob.Parent = switch
                UIHelpers.Corner(knob, UDim.new(0, 10))
                
                local function update(v, animate)
                    animate = animate ~= false
                    value = v
                    if animate then
                        Anim.Play(switch, {BackgroundColor3 = v and accent or Theme.BackgroundQuaternary}, Theme.AnimDuration.Fast)
                        Anim.Play(knob, {Position = UDim2.new(v and 1 or 0, v and -21 or 3, 0.5, -9)}, Theme.AnimDuration.Fast, Enum.EasingStyle.Quad)
                    else
                        switch.BackgroundColor3 = v and accent or Theme.BackgroundQuaternary
                        knob.Position = UDim2.new(v and 1 or 0, v and -21 or 3, 0.5, -9)
                    end
                end
                
                switch.MouseButton1Click:Connect(function()
                    update(not value, true)
                    cb(value)
                end)
                
                return {
                    SetValue = function(_, v) update(v, true); cb(v) end,
                    GetValue = function() return value end
                }
            end
            
            -- Slider
            function section:AddSlider(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or "Slider"
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local default = cfg.Default or min
                local decimals = cfg.Decimals or 0
                local suffix = cfg.Suffix or ""
                local cb = cfg.Callback or function() end
                local value = Utility.Clamp(default, min, max)
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight + 8)
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                
                local header = Instance.new("Frame")
                header.Size = UDim2.new(1, 0, 0, 20)
                header.BackgroundTransparency = 1
                header.BorderSizePixel = 0
                header.Parent = container
                
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
                titleLabel.Text = title
                titleLabel.Font = Theme.Font.Body
                titleLabel.TextSize = Theme.FontSize.Body
                titleLabel.TextColor3 = Theme.TextPrimary
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.BackgroundTransparency = 1
                titleLabel.Parent = header
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
                valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
                valueLabel.Text = Utility.Round(value, decimals) .. suffix
                valueLabel.Font = Theme.Font.Body
                valueLabel.TextSize = Theme.FontSize.Body
                valueLabel.TextColor3 = Theme.TextSecondary
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.BackgroundTransparency = 1
                valueLabel.Parent = header
                
                local track = Instance.new("TextButton")
                track.Size = UDim2.new(1, 0, 0, 8)
                track.Position = UDim2.new(0, 0, 1, -8)
                track.BackgroundColor3 = Theme.BackgroundQuaternary
                track.BackgroundTransparency = 0.2
                track.Text = ""
                track.BorderSizePixel = 0
                track.Parent = container
                UIHelpers.Corner(track, Theme.Corner.Small)
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = accent
                fill.BackgroundTransparency = 0.1
                fill.BorderSizePixel = 0
                fill.Parent = track
                UIHelpers.Corner(fill, Theme.Corner.Small)
                UIHelpers.Gradient(fill)
                
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
                knob.BackgroundColor3 = Color3.new(1, 1, 1)
                knob.BorderSizePixel = 0
                knob.Parent = track
                UIHelpers.Corner(knob, UDim.new(0, 8))
                
                local draggingSlider = false
                
                local function updateSlider(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = Utility.Round(min + (max - min) * rel, decimals)
                    value = Utility.Clamp(value, min, max)
                    local pct = (value - min) / (max - min)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, -8, 0.5, -8)
                    valueLabel.Text = Utility.Round(value, decimals) .. suffix
                end
                
                track.MouseButton1Down:Connect(function()
                    draggingSlider = true
                    updateSlider(Mouse.X)
                end)
                
                if Services.UserInputService then
                    Services.UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then
                            draggingSlider = false
                            cb(value)
                        end
                    end)
                    Services.UserInputService.InputChanged:Connect(function(input)
                        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input.Position.X)
                        end
                    end)
                end
                
                return {
                    SetValue = function(_, v)
                        value = Utility.Clamp(v, min, max)
                        local pct = (value - min) / (max - min)
                        fill.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, -8, 0.5, -8)
                        valueLabel.Text = Utility.Round(value, decimals) .. suffix
                        cb(value)
                    end,
                    GetValue = function() return value end
                }
            end
            
            -- Dropdown
            function section:AddDropdown(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or "Dropdown"
                local options = cfg.Options or {"Option 1", "Option 2"}
                local default = cfg.Default or options[1]
                local cb = cfg.Callback or function() end
                local selected = default
                local open = false
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                container.ClipsDescendants = true
                container.BackgroundColor3 = Theme.BackgroundTertiary
                container.BackgroundTransparency = 0.2
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                UIHelpers.Corner(container, Theme.Corner.Button)
                UIHelpers.Stroke(container, Theme.GlassBorder, 0.85)
                
                local header = Instance.new("TextButton")
                header.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                header.BackgroundTransparency = 1
                header.Text = ""
                header.BorderSizePixel = 0
                header.Parent = container
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -50, 1, 0)
                label.Position = UDim2.new(0, 12, 0, 0)
                label.Text = selected
                label.Font = Theme.Font.Body
                label.TextSize = Theme.FontSize.Body
                label.TextColor3 = Theme.TextPrimary
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = header
                
                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.new(0, 30, 1, 0)
                arrow.Position = UDim2.new(1, -36, 0, 0)
                arrow.Text = "▼"
                arrow.Font = Theme.Font.Body
                arrow.TextSize = 10
                arrow.TextColor3 = Theme.TextSecondary
                arrow.BackgroundTransparency = 1
                arrow.Parent = header
                
                local optionsContainer = Instance.new("Frame")
                optionsContainer.Size = UDim2.new(1, -4, 0, 0)
                optionsContainer.Position = UDim2.new(0, 2, 0, Theme.ComponentHeight)
                optionsContainer.BackgroundTransparency = 1
                optionsContainer.BorderSizePixel = 0
                optionsContainer.Parent = container
                UIHelpers.ListLayout(optionsContainer, Enum.FillDirection.Vertical, UDim.new(0, 2))
                
                for _, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 32)
                    optBtn.BackgroundColor3 = opt == selected and accent or Theme.BackgroundQuaternary
                    optBtn.BackgroundTransparency = opt == selected and 0.3 or 0.4
                    optBtn.Text = opt
                    optBtn.Font = Theme.Font.Body
                    optBtn.TextSize = Theme.FontSize.Body
                    optBtn.TextColor3 = Theme.TextPrimary
                    optBtn.BorderSizePixel = 0
                    optBtn.Parent = optionsContainer
                    UIHelpers.Corner(optBtn, Theme.Corner.Small)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        label.Text = opt
                        cb(opt)
                        Anim.Play(container, {Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)}, Theme.AnimDuration.Fast)
                        Anim.Play(arrow, {Rotation = 0}, Theme.AnimDuration.Fast)
                        open = false
                    end)
                end
                
                local optHeight = #options * 34
                
                header.MouseButton1Click:Connect(function()
                    if open then
                        Anim.Play(container, {Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)}, Theme.AnimDuration.Fast)
                        Anim.Play(arrow, {Rotation = 0}, Theme.AnimDuration.Fast)
                    else
                        Anim.Play(container, {Size = UDim2.new(1, 0, 0, Theme.ComponentHeight + optHeight + 4)}, Theme.AnimDuration.Fast)
                        Anim.Play(arrow, {Rotation = 180}, Theme.AnimDuration.Fast)
                    end
                    open = not open
                end)
                
                return {
                    SetOption = function(_, opt)
                        if table.find(options, opt) then
                            selected = opt
                            label.Text = opt
                            cb(opt)
                        end
                    end,
                    GetOption = function() return selected end
                }
            end
            
            -- Textbox
            function section:AddTextbox(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or "Text"
                local placeholder = cfg.Placeholder or "Enter..."
                local default = cfg.Default or ""
                local cb = cfg.Callback or function() end
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.4, 0, 1, 0)
                label.Text = title
                label.Font = Theme.Font.Body
                label.TextSize = Theme.FontSize.Body
                label.TextColor3 = Theme.TextPrimary
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = container
                
                local boxFrame = Instance.new("Frame")
                boxFrame.Size = UDim2.new(0.6, 0, 1, 0)
                boxFrame.Position = UDim2.new(0.4, 0, 0, 0)
                boxFrame.BackgroundColor3 = Theme.BackgroundTertiary
                boxFrame.BackgroundTransparency = 0.2
                boxFrame.BorderSizePixel = 0
                boxFrame.Parent = container
                UIHelpers.Corner(boxFrame, Theme.Corner.Button)
                UIHelpers.Stroke(boxFrame, Theme.GlassBorder, 0.85)
                
                local textbox = Instance.new("TextBox")
                textbox.Size = UDim2.new(1, -16, 1, 0)
                textbox.Position = UDim2.new(0, 8, 0, 0)
                textbox.Text = default
                textbox.PlaceholderText = placeholder
                textbox.PlaceholderColor3 = Theme.TextMuted
                textbox.Font = Theme.Font.Body
                textbox.TextSize = Theme.FontSize.Body
                textbox.TextColor3 = Theme.TextPrimary
                textbox.TextXAlignment = Enum.TextXAlignment.Left
                textbox.BackgroundTransparency = 1
                textbox.BorderSizePixel = 0
                textbox.Parent = boxFrame
                
                textbox.FocusLost:Connect(function(enter) cb(textbox.Text, enter) end)
                
                return {
                    SetValue = function(_, v) textbox.Text = v end,
                    GetValue = function() return textbox.Text end
                }
            end
            
            -- Keybind
            function section:AddKeybind(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or "Keybind"
                local default = cfg.Default or Enum.KeyCode.Unknown
                local cb = cfg.Callback or function() end
                local current = default
                local listening = false
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, Theme.ComponentHeight)
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.6, 0, 1, 0)
                label.Text = title
                label.Font = Theme.Font.Body
                label.TextSize = Theme.FontSize.Body
                label.TextColor3 = Theme.TextPrimary
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = container
                
                local keyBtn = Instance.new("TextButton")
                keyBtn.Size = UDim2.new(0.4, 0, 1, 0)
                keyBtn.Position = UDim2.new(0.6, 0, 0, 0)
                keyBtn.BackgroundColor3 = Theme.BackgroundTertiary
                keyBtn.BackgroundTransparency = 0.2
                keyBtn.Text = current.Name
                keyBtn.Font = Theme.Font.Mono
                keyBtn.TextSize = Theme.FontSize.Body
                keyBtn.TextColor3 = Theme.TextPrimary
                keyBtn.BorderSizePixel = 0
                keyBtn.Parent = container
                UIHelpers.Corner(keyBtn, Theme.Corner.Button)
                UIHelpers.Stroke(keyBtn, Theme.GlassBorder, 0.85)
                
                keyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyBtn.Text = "..."
                    Anim.Play(keyBtn, {BackgroundColor3 = accent, BackgroundTransparency = 0.5}, Theme.AnimDuration.Fast)
                end)
                
                if Services.UserInputService then
                    Services.UserInputService.InputBegan:Connect(function(input, processed)
                        if listening then
                            listening = false
                            current = input.KeyCode
                            keyBtn.Text = current.Name
                            Anim.Play(keyBtn, {BackgroundColor3 = Theme.BackgroundTertiary, BackgroundTransparency = 0.2}, Theme.AnimDuration.Fast)
                            cb(current)
                        elseif not processed and input.KeyCode == current then
                            cb(current)
                        end
                    end)
                end
                
                return {
                    SetKey = function(_, k) current = k; keyBtn.Text = k.Name; cb(k) end,
                    GetKey = function() return current end
                }
            end
            
            -- Label
            function section:AddLabel(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local text = cfg.Text or "Label"
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Text = text
                label.Font = Theme.Font.Body
                label.TextSize = Theme.FontSize.Body
                label.TextColor3 = Theme.TextSecondary
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.LayoutOrder = self.Count
                label.Parent = self.Container
                
                return {SetText = function(_, t) label.Text = t end}
            end
            
            -- Paragraph
            function section:AddParagraph(cfg)
                cfg = cfg or {}
                self.Count = self.Count + 1
                local title = cfg.Title or ""
                local text = cfg.Text or "Text"
                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 0)
                container.AutomaticSize = Enum.AutomaticSize.Y
                container.BackgroundTransparency = 1
                container.BorderSizePixel = 0
                container.LayoutOrder = self.Count
                container.Parent = self.Container
                
                if title ~= "" then
                    local t = Instance.new("TextLabel")
                    t.Size = UDim2.new(1, 0, 0, 20)
                    t.Text = title
                    t.Font = Theme.Font.Subtitle
                    t.TextSize = Theme.FontSize.Body
                    t.TextColor3 = Theme.TextPrimary
                    t.TextXAlignment = Enum.TextXAlignment.Left
                    t.BackgroundTransparency = 1
                    t.Parent = container
                end
                
                local p = Instance.new("TextLabel")
                p.Size = UDim2.new(1, 0, 0, 0)
                p.AutomaticSize = Enum.AutomaticSize.Y
                p.Text = text
                p.Font = Theme.Font.Body
                p.TextSize = Theme.FontSize.Body
                p.TextColor3 = Theme.TextSecondary
                p.TextXAlignment = Enum.TextXAlignment.Left
                p.TextWrapped = true
                p.BackgroundTransparency = 1
                p.Parent = container
                
                return {SetText = function(_, t) p.Text = t end}
            end
            
            -- Divider
            function section:AddDivider()
                self.Count = self.Count + 1
                local d = Instance.new("Frame")
                d.Size = UDim2.new(1, 0, 0, 1)
                d.BackgroundColor3 = Theme.Divider
                d.BackgroundTransparency = 0.5
                d.BorderSizePixel = 0
                d.LayoutOrder = self.Count
                d.Parent = self.Container
                return d
            end
            
            table.insert(tab.Sections, section)
            return section
        end
        
        tab.CreateSection = createSection
        table.insert(winState.Tabs, tab)
        
        if #winState.Tabs == 1 then selectTab() end
        
        return tab
    end
    
    -- Window Object
    local window = {
        ScreenGui = screen,
        MainWindow = main,
        Pill = pill,
        State = winState,
        Accent = accent,
        CreateTab = createTab,
    }
    
    -- Toast Container
    local toastContainer = Instance.new("Frame")
    toastContainer.Name = "Toasts"
    toastContainer.Size = UDim2.new(0, 300, 1, -20)
    toastContainer.Position = UDim2.new(1, -320, 0, 10)
    toastContainer.BackgroundTransparency = 1
    toastContainer.BorderSizePixel = 0
    toastContainer.Parent = screen
    UIHelpers.ListLayout(toastContainer, Enum.FillDirection.Vertical, UDim.new(0, 8))
    
    -- Notify
    function window:Notify(cfg)
        cfg = cfg or {}
        local t = cfg.Title or "Notification"
        local m = cfg.Message or ""
        local d = cfg.Duration or 5
        local typ = cfg.Type or "info"
        
        local color = Theme.Info
        if typ == "success" then color = Theme.Success
        elseif typ == "warning" then color = Theme.Warning
        elseif typ == "error" then color = Theme.Error end
        
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(1, 0, 0, 0)
        toast.AutomaticSize = Enum.AutomaticSize.Y
        toast.BackgroundColor3 = Theme.BackgroundSecondary
        toast.BackgroundTransparency = 0.1
        toast.BorderSizePixel = 0
        toast.Parent = toastContainer
        UIHelpers.Corner(toast, Theme.Corner.Card)
        UIHelpers.Stroke(toast, Theme.GlassBorder, 0.7)
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = color
        accent.BorderSizePixel = 0
        accent.Parent = toast
        UIHelpers.Corner(accent, UDim.new(0, 2))
        
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -20, 0, 0)
        content.Position = UDim2.new(0, 12, 0, 8)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.Parent = toast
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.Text = t
        titleLabel.Font = Theme.Font.Subtitle
        titleLabel.TextSize = Theme.FontSize.Body
        titleLabel.TextColor3 = color
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = content
        
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, 0, 0, 0)
        msgLabel.Position = UDim2.new(0, 0, 0, 22)
        msgLabel.AutomaticSize = Enum.AutomaticSize.Y
        msgLabel.Text = m
        msgLabel.Font = Theme.Font.Body
        msgLabel.TextSize = Theme.FontSize.Small
        msgLabel.TextColor3 = Theme.TextSecondary
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextWrapped = true
        msgLabel.BackgroundTransparency = 1
        msgLabel.Parent = content
        
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = content
        
        toast.Position = UDim2.new(1, 0, 0, 0)
        Anim.Slide(toast, UDim2.new(0, 0, 0, 0), Theme.AnimDuration.Normal, Enum.EasingStyle.Back)
        
        task.delay(d, function()
            Anim.Fade(toast, 1, Theme.AnimDuration.Normal)
            Anim.Slide(toast, UDim2.new(0.2, 0, 0, 0), Theme.AnimDuration.Normal, nil, function() toast:Destroy() end)
        end)
    end
    
    -- System Info Tab
    function window:CreateSystemInfoTab()
        local tab = self:CreateTab({Name = "System", Icon = "⚡"})
        
        local env = tab:CreateSection("Environment")
        local exec = InfoProvider.GetExecutor()
        env:AddLabel({Text = "Executor: " .. exec.Name})
        env:AddLabel({Text = "Version: " .. exec.Version})
        env:AddLabel({Text = "Environment: " .. exec.Env})
        
        local game = tab:CreateSection("Game")
        local gi = InfoProvider.GetGame()
        game:AddLabel({Text = "Game: " .. gi.Name})
        game:AddLabel({Text = "GameId: " .. gi.GameId})
        game:AddLabel({Text = "PlaceId: " .. gi.PlaceId})
        game:AddLabel({Text = "JobId: " .. gi.JobId})
        game:AddLabel({Text = "Server: " .. gi.Server})
        game:AddLabel({Text = "Players: " .. gi.Players})
        
        local player = tab:CreateSection("Player")
        local pi = InfoProvider.GetPlayer()
        player:AddLabel({Text = "Username: " .. pi.Username})
        player:AddLabel({Text = "Display Name: " .. pi.DisplayName})
        player:AddLabel({Text = "UserId: " .. pi.UserId})
        player:AddLabel({Text = "Account Age: " .. pi.Age})
        player:AddLabel({Text = "Premium: " .. pi.Premium})
        
        local session = tab:CreateSection("Session")
        local timeLabel = session:AddLabel({Text = "Local Time: --:--:--"})
        local runtimeLabel = session:AddLabel({Text = "Runtime: 00:00:00"})
        session:AddLabel({Text = "Loaded: " .. InfoProvider.GetSession().Loaded})
        
        task.spawn(function()
            while screen and screen.Parent do
                local s = InfoProvider.GetSession()
                timeLabel.SetText("Local Time: " .. s.Time)
                runtimeLabel.SetText("Runtime: " .. s.Runtime)
                task.wait(1)
            end
        end)
        
        return tab
    end
    
    table.insert(self.Windows, window)
    self.ActiveWindow = window
    
    return window
end

return Aurora
