local Services = {}

local function GetService(ServiceName)
    local Success, Service = pcall(function()
        return game:GetService(ServiceName)
    end)
    return Success and Service or nil
end

Services.Players = GetService("Players")
Services.TweenService = GetService("TweenService")
Services.UserInputService = GetService("UserInputService")
Services.RunService = GetService("RunService")
Services.TextService = GetService("TextService")

local LocalPlayer = Services.Players and Services.Players.LocalPlayer
local LocalMouse = LocalPlayer and LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local Utility = {}

function Utility.Round(Number, Decimals)
    Decimals = Decimals or 0
    local Multiplier = 10 ^ Decimals
    return math.floor(Number * Multiplier + 0.5) / Multiplier
end

function Utility.Clamp(Value, Min, Max)
    return math.max(Min, math.min(Max, Value))
end

function Utility.FormatTime(Seconds)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local Secs = math.floor(Seconds % 60)
    return string.format("%02d:%02d:%02d", Hours, Minutes, Secs)
end

function Utility.FormatNumber(Number)
    return tostring(Number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- ═══════════════════════════════════════════════════════════════
-- AURORA LIBRARY MAIN TABLE
-- ═══════════════════════════════════════════════════════════════

local Aurora = {
    Version = "1.0.1",
    Author = "Aurora Development Team",
    Theme = {},
    Animation = {},
    Components = {},
    InfoProvider = {},
    Core = {},
    State = {},
    Windows = {},
    ActiveWindow = nil,
}

-- ═══════════════════════════════════════════════════════════════
-- THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.Theme = {
    AuroraCyan = Color3.fromRGB(100, 220, 255),
    AuroraViolet = Color3.fromRGB(180, 100, 255),
    AuroraPink = Color3.fromRGB(255, 100, 180),
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
    TextAccent = Color3.fromRGB(100, 200, 255),
    Divider = Color3.fromRGB(60, 60, 80),
    Shadow = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(100, 180, 255),
    WindowWidth = 520,
    WindowMinWidth = 400,
    WindowMaxWidth = 700,
    WindowHeight = 450,
    WindowMinHeight = 300,
    WindowMaxHeight = 600,
    SidebarWidth = 140,
    TabHeight = 36,
    SectionPadding = 12,
    ComponentHeight = 40,
    ComponentSpacing = 8,
    CornerRadius = {
        Window = UDim.new(0, 16),
        Card = UDim.new(0, 12),
        Button = UDim.new(0, 8),
        Small = UDim.new(0, 6),
        Pill = UDim.new(0, 20),
    },
    AnimationDuration = {
        Fast = 0.15,
        Normal = 0.25,
        Slow = 0.4,
    },
    Font = {
        Title = Enum.Font.GothamBold,
        Subtitle = Enum.Font.GothamSemibold,
        Body = Enum.Font.Gotham,
        Mono = Enum.Font.Code,
    },
    FontSize = {
        Title = 20,
        Subtitle = 14,
        Body = 13,
        Small = 11,
        Tiny = 9,
    },
}

function Aurora.Theme:Apply(CustomTheme)
    if type(CustomTheme) ~= "table" then return end
    for Key, Value in pairs(CustomTheme) do
        if self[Key] ~= nil then
            self[Key] = Value
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ANIMATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.Animation = {
    DefaultEasingStyle = Enum.EasingStyle.Quad,
    DefaultEasingDirection = Enum.EasingDirection.Out,
    ActiveTweens = {},
}

function Aurora.Animation:Create(Object, Properties, Duration, EasingStyle, EasingDirection)
    if not Object or not Properties then return nil end
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    EasingStyle = EasingStyle or self.DefaultEasingStyle
    EasingDirection = EasingDirection or self.DefaultEasingDirection
    local TweenInfo = TweenInfo.new(Duration, EasingStyle, EasingDirection)
    local Tween = Services.TweenService:Create(Object, TweenInfo, Properties)
    return Tween
end

function Aurora.Animation:Play(Object, Properties, Duration, EasingStyle, EasingDirection)
    local Tween = self:Create(Object, Properties, Duration, EasingStyle, EasingDirection)
    if Tween then
        Tween:Play()
        return Tween
    end
    return nil
end

function Aurora.Animation:Fade(Object, TargetTransparency, Duration, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    local Properties = {}
    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
        Properties.TextTransparency = TargetTransparency
        Properties.BackgroundTransparency = TargetTransparency
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        Properties.ImageTransparency = TargetTransparency
        Properties.BackgroundTransparency = TargetTransparency
    elseif Object:IsA("Frame") or Object:IsA("ScrollingFrame") then
        Properties.BackgroundTransparency = TargetTransparency
    end
    local Tween = self:Play(Object, Properties, Duration)
    if Callback then Tween.Completed:Connect(Callback) end
    return Tween
end

function Aurora.Animation:Scale(Object, TargetScale, Duration, EasingStyle, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    local UIScale = Object:FindFirstChildOfClass("UIScale")
    if not UIScale then
        UIScale = Instance.new("UIScale")
        UIScale.Parent = Object
        UIScale.Scale = 1
    end
    local Tween = self:Play(Object.UIScale, { Scale = TargetScale }, Duration, EasingStyle)
    if Callback then Tween.Completed:Connect(Callback) end
    return Tween
end

function Aurora.Animation:Slide(Object, TargetPosition, Duration, EasingStyle, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    EasingStyle = EasingStyle or Enum.EasingStyle.Quart
    local Tween = self:Play(Object, { Position = TargetPosition }, Duration, EasingStyle)
    if Callback then Tween.Completed:Connect(Callback) end
    return Tween
end

function Aurora.Animation:FadeScale(Object, TargetScale, TargetTransparency, Duration, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    self:Scale(Object, TargetScale, Duration, Enum.EasingStyle.Quad)
    local Tween = self:Fade(Object, TargetTransparency, Duration)
    if Callback then Tween.Completed:Connect(Callback) end
    return Tween
end

-- ═══════════════════════════════════════════════════════════════
-- INFO PROVIDER SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.InfoProvider = {
    SessionStartTime = os.time(),
    ExecutorInfo = nil,
    GameInfo = nil,
    PlayerInfo = nil,
}

function Aurora.InfoProvider:GetExecutorInfo()
    if self.ExecutorInfo then return self.ExecutorInfo end
    local Info = { Name = "Unknown", Version = "N/A", Environment = "Unknown" }
    
    -- Detect executors safely
    pcall(function()
        if syn and syn.request then
            Info.Name = "Synapse X"
            Info.Environment = "Synapse"
        end
    end)
    
    pcall(function()
        if getgenv and getgenv().SCRIPTWARE then
            Info.Name = "Script-Ware"
            Info.Environment = "ScriptWare"
        end
    end)
    
    pcall(function()
        if KRNL_LOADED then
            Info.Name = "KRNL"
            Info.Environment = "KRNL"
        end
    end)
    
    pcall(function()
        if fluxus then
            Info.Name = "Fluxus"
            Info.Environment = "Fluxus"
        end
    end)
    
    pcall(function()
        if Services.RunService and Services.RunService:IsStudio() then
            Info.Name = "Roblox Studio"
            Info.Version = "Editor"
            Info.Environment = "Studio"
        end
    end)
    
    self.ExecutorInfo = Info
    return Info
end

function Aurora.InfoProvider:GetGameInfo()
    if self.GameInfo then return self.GameInfo end
    local Info = {
        Name = "Unknown", GameId = "N/A", PlaceId = "N/A",
        JobId = "N/A", ServerType = "Unknown", MaxPlayers = "N/A", PlayerCount = "N/A",
    }
    pcall(function() Info.Name = game.Name or "Unknown" end)
    pcall(function() Info.GameId = tostring(game.GameId) end)
    pcall(function() Info.PlaceId = tostring(game.PlaceId) end)
    pcall(function() Info.JobId = game.JobId or "N/A" end)
    pcall(function()
        if game.PrivateServerId and game.PrivateServerId ~= "" then
            Info.ServerType = "Private"
        else
            Info.ServerType = "Public"
        end
    end)
    pcall(function()
        if Services.Players then
            Info.MaxPlayers = tostring(Services.Players.MaxPlayers)
            Info.PlayerCount = tostring(#Services.Players:GetPlayers())
        end
    end)
    self.GameInfo = Info
    return Info
end

function Aurora.InfoProvider:GetPlayerInfo()
    local Info = {
        Username = "Unknown", UserId = "N/A", DisplayName = "Unknown",
        AccountAge = "N/A", AccountAgeDays = 0, Membership = "None",
    }
    if not LocalPlayer then return Info end
    pcall(function() Info.Username = LocalPlayer.Name or "Unknown" end)
    pcall(function() Info.UserId = tostring(LocalPlayer.UserId) end)
    pcall(function() Info.DisplayName = LocalPlayer.DisplayName or "Unknown" end)
    pcall(function()
        local Age = LocalPlayer.AccountAge or 0
        Info.AccountAgeDays = Age
        Info.AccountAge = Utility.FormatNumber(Age) .. " days"
    end)
    pcall(function()
        if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
            Info.Membership = "Premium"
        end
    end)
    return Info
end

function Aurora.InfoProvider:GetSessionInfo()
    local Info = {
        StartTime = self.SessionStartTime,
        StartTimeFormatted = os.date("%H:%M:%S", self.SessionStartTime),
        CurrentTime = os.time(),
        CurrentTimeFormatted = os.date("%H:%M:%S", os.time()),
        Runtime = 0,
        RuntimeFormatted = "00:00:00",
        UILoadedTimestamp = os.date("%Y-%m-%d %H:%M:%S", self.SessionStartTime),
    }
    Info.Runtime = os.time() - self.SessionStartTime
    Info.RuntimeFormatted = Utility.FormatTime(Info.Runtime)
    return Info
end

-- ═══════════════════════════════════════════════════════════════
-- COMPONENT FACTORY SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.Components = {}

function Aurora.Components:CreateCorner(Parent, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Radius or Aurora.Theme.CornerRadius.Card
    Corner.Parent = Parent
    return Corner
end

function Aurora.Components:CreateStroke(Parent, Color, Transparency, Thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Aurora.Theme.GlassBorder
    Stroke.Transparency = Transparency or Aurora.Theme.GlassBorderTransparency
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Parent
    return Stroke
end

function Aurora.Components:CreateGradient(Parent, ColorSequence, Rotation)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Aurora.Theme.AuroraCyan),
        ColorSequenceKeypoint.new(1, Aurora.Theme.AuroraViolet),
    })
    Gradient.Rotation = Rotation or 90
    Gradient.Parent = Parent
    return Gradient
end

function Aurora.Components:CreateListLayout(Parent, Direction, Padding)
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.FillDirection = Direction or Enum.FillDirection.Vertical
    Layout.Padding = Padding or UDim.new(0, Aurora.Theme.ComponentSpacing)
    Layout.Parent = Parent
    return Layout
end

function Aurora.Components:CreatePadding(Parent, PaddingTop, PaddingBottom, PaddingLeft, PaddingRight)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = PaddingTop or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingBottom = PaddingBottom or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingLeft = PaddingLeft or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingRight = PaddingRight or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.Parent = Parent
    return UIPadding
end

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.State = {
    Storage = {},
    Save = function(self, Key, Value) self.Storage[Key] = Value end,
    Load = function(self, Key, Default) return self.Storage[Key] or Default end,
    Clear = function(self) self.Storage = {} end,
    Exists = function(self, Key) return self.Storage[Key] ~= nil end,
}

-- ═══════════════════════════════════════════════════════════════
-- CORE WINDOW SYSTEM
-- ═══════════════════════════════════════════════════════════════

Aurora.Core = {}

function Aurora.Core:CreateWindow(Config)
    Config = Config or {}
    local Title = Config.Title or "Aurora Library"
    local Subtitle = Config.Subtitle or "Modern Futuristic UI"
    local AccentColor = Config.Accent or Aurora.Theme.Accent
    local Size = Config.Size or UDim2.new(0, Aurora.Theme.WindowWidth, 0, Aurora.Theme.WindowHeight)
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuroraUI_" .. tostring(math.random(10000, 99999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            ScreenGui.Parent = LocalPlayer.PlayerGui
        else
            ScreenGui.Parent = game.CoreGui
        end
    end)
    
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    end
    
    -- Main Window
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = Size
    MainWindow.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    MainWindow.BackgroundColor3 = Aurora.Theme.BackgroundPrimary
    MainWindow.BackgroundTransparency = 0.05
    MainWindow.BorderSizePixel = 0
    MainWindow.Parent = ScreenGui
    self:CreateCorner(MainWindow, Aurora.Theme.CornerRadius.Window)
    self:CreateStroke(MainWindow, Color3.fromRGB(60, 60, 80), 0.5, 1)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow
    self:CreateCorner(TitleBar, Aurora.Theme.CornerRadius.Window)
    
    -- Accent Line
    local AccentLine = Instance.new("Frame")
    AccentLine.Name = "AccentLine"
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = AccentColor
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TitleBar
    self:CreateGradient(AccentLine, ColorSequence.new({
        ColorSequenceKeypoint.new(0, AccentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(AccentColor.R * 255 * 0.6 + 100, 255),
            math.min(AccentColor.G * 255 * 0.6 + 50, 255),
            math.min(AccentColor.B * 255 * 0.8 + 50, 255)
        )),
    }), 90)
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(0.6, 0, 0.6, 0)
    TitleText.Position = UDim2.new(0, 16, 0, 4)
    TitleText.Text = Title
    TitleText.Font = Aurora.Theme.Font.Title
    TitleText.TextSize = Aurora.Theme.FontSize.Title
    TitleText.TextColor3 = Aurora.Theme.TextPrimary
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.BackgroundTransparency = 1
    TitleText.Parent = TitleBar
    
    -- Subtitle Text
    local SubtitleText = Instance.new("TextLabel")
    SubtitleText.Name = "Subtitle"
    SubtitleText.Size = UDim2.new(0.6, 0, 0.4, 0)
    SubtitleText.Position = UDim2.new(0, 16, 0.55, 0)
    SubtitleText.Text = Subtitle
    SubtitleText.Font = Aurora.Theme.Font.Body
    SubtitleText.TextSize = Aurora.Theme.FontSize.Small
    SubtitleText.TextColor3 = Aurora.Theme.TextSecondary
    SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleText.BackgroundTransparency = 1
    SubtitleText.Parent = TitleBar
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
    MinimizeButton.Position = UDim2.new(1, -72, 0.5, -14)
    MinimizeButton.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
    MinimizeButton.BackgroundTransparency = 0.2
    MinimizeButton.Text = "─"
    MinimizeButton.Font = Aurora.Theme.Font.Body
    MinimizeButton.TextSize = 14
    MinimizeButton.TextColor3 = Aurora.Theme.TextSecondary
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar
    self:CreateCorner(MinimizeButton, Aurora.Theme.CornerRadius.Small)
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.Position = UDim2.new(1, -36, 0.5, -14)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.Text = "✕"
    CloseButton.Font = Aurora.Theme.Font.Body
    CloseButton.TextSize = 12
    CloseButton.TextColor3 = Aurora.Theme.TextPrimary
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    self:CreateCorner(CloseButton, Aurora.Theme.CornerRadius.Small)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, Aurora.Theme.SidebarWidth, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainWindow
    self:CreateCorner(Sidebar, Aurora.Theme.CornerRadius.Window)
    
    -- Sidebar Content
    local SidebarContent = Instance.new("ScrollingFrame")
    SidebarContent.Name = "Content"
    SidebarContent.Size = UDim2.new(1, -8, 1, -16)
    SidebarContent.Position = UDim2.new(0, 4, 0, 8)
    SidebarContent.BackgroundTransparency = 1
    SidebarContent.ScrollBarThickness = 4
    SidebarContent.ScrollBarImageColor3 = Aurora.Theme.Accent
    SidebarContent.ScrollBarImageTransparency = 0.5
    SidebarContent.BorderSizePixel = 0
    SidebarContent.Parent = Sidebar
    self:CreatePadding(SidebarContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
    self:CreateListLayout(SidebarContent, Enum.FillDirection.Vertical, UDim.new(0, 6))
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -Aurora.Theme.SidebarWidth, 1, -50)
    ContentArea.Position = UDim2.new(0, Aurora.Theme.SidebarWidth, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainWindow
    
    -- Content Container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Container"
    ContentContainer.Size = UDim2.new(1, -16, 1, -16)
    ContentContainer.Position = UDim2.new(0, 8, 0, 8)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = Aurora.Theme.Accent
    ContentContainer.ScrollBarImageTransparency = 0.5
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = ContentArea
    self:CreatePadding(ContentContainer, UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8))
    self:CreateListLayout(ContentContainer, Enum.FillDirection.Vertical, UDim.new(0, 12))
    
    -- Minimized Pill
    local MinimizedPill = Instance.new("Frame")
    MinimizedPill.Name = "MinimizedPill"
    MinimizedPill.Size = UDim2.new(0, 150, 0, 44)
    MinimizedPill.Position = UDim2.new(1, -170, 1, -60)
    MinimizedPill.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    MinimizedPill.BackgroundTransparency = 0.1
    MinimizedPill.BorderSizePixel = 0
    MinimizedPill.Visible = false
    MinimizedPill.Parent = ScreenGui
    self:CreateCorner(MinimizedPill, Aurora.Theme.CornerRadius.Pill)
    self:CreateStroke(MinimizedPill, Aurora.Theme.GlassBorder, 0.7)
    
    -- Pill Accent
    local PillAccent = Instance.new("Frame")
    PillAccent.Name = "Accent"
    PillAccent.Size = UDim2.new(0, 3, 0.6, 0)
    PillAccent.Position = UDim2.new(0, 6, 0.2, 0)
    PillAccent.BackgroundColor3 = AccentColor
    PillAccent.BorderSizePixel = 0
    PillAccent.Parent = MinimizedPill
    self:CreateCorner(PillAccent, UDim.new(0, 2))
    
    -- Pill Title
    local PillText = Instance.new("TextLabel")
    PillText.Name = "Title"
    PillText.Size = UDim2.new(1, -40, 1, 0)
    PillText.Position = UDim2.new(0, 18, 0, 0)
    PillText.Text = Title
    PillText.Font = Aurora.Theme.Font.Subtitle
    PillText.TextSize = Aurora.Theme.FontSize.Body
    PillText.TextColor3 = Aurora.Theme.TextPrimary
    PillText.TextXAlignment = Enum.TextXAlignment.Left
    PillText.BackgroundTransparency = 1
    PillText.Parent = MinimizedPill
    
    -- Pill Button
    local PillButton = Instance.new("TextButton")
    PillButton.Name = "ExpandButton"
    PillButton.Size = UDim2.new(1, 0, 1, 0)
    PillButton.BackgroundTransparency = 1
    PillButton.Text = ""
    PillButton.BorderSizePixel = 0
    PillButton.Parent = MinimizedPill
    
    -- Window State
    local WindowState = {
        IsMinimized = false,
        ActiveTab = nil,
        Tabs = {},
        ScrollPositions = {},
    }
    
    -- Dragging
    local Dragging = false
    local DragStart, StartPosition
    
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainWindow.Position
            ScreenGui.DisplayOrder = 100 + math.random(1, 10)
        end
    end)
    
    TitleBar.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    
    if Services.UserInputService then
        Services.UserInputService.InputChanged:Connect(function(Input)
            if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local Delta = Input.Position - DragStart
                MainWindow.Position = UDim2.new(
                    StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                    StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
                )
            end
        end)
    end
    
    -- Minimize/Restore
    local function MinimizeWindow()
        if WindowState.IsMinimized then return end
        WindowState.ScrollPositions = {}
        for _, Tab in ipairs(WindowState.Tabs) do
            if Tab.Content then
                WindowState.ScrollPositions[Tab.Name] = Tab.Content.CanvasPosition
            end
        end
        Aurora.Animation:FadeScale(MainWindow, 0.8, 0.5, Aurora.Theme.AnimationDuration.Normal, function()
            MainWindow.Visible = false
            MinimizedPill.Visible = true
            Aurora.Animation:Scale(MinimizedPill, 0.9, 0)
            Aurora.Animation:Scale(MinimizedPill, 1, Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
        end)
        WindowState.IsMinimized = true
    end
    
    local function RestoreWindow()
        if not WindowState.IsMinimized then return end
        Aurora.Animation:Scale(MinimizedPill, 0.9, Aurora.Theme.AnimationDuration.Fast, Enum.EasingStyle.Quad, function()
            MinimizedPill.Visible = false
            MainWindow.Visible = true
            Aurora.Animation:Scale(MainWindow, 0.9, 0)
            Aurora.Animation:Scale(MainWindow, 1, Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
            Aurora.Animation:Fade(MainWindow, 0, Aurora.Theme.AnimationDuration.Normal)
            for _, Tab in ipairs(WindowState.Tabs) do
                if Tab.Content and WindowState.ScrollPositions[Tab.Name] then
                    Tab.Content.CanvasPosition = WindowState.ScrollPositions[Tab.Name]
                end
            end
        end)
        WindowState.IsMinimized = false
    end
    
    MinimizeButton.MouseButton1Click:Connect(MinimizeWindow)
    CloseButton.MouseButton1Click:Connect(function()
        Aurora.Animation:FadeScale(MainWindow, 0.9, 0.8, Aurora.Theme.AnimationDuration.Normal, function()
            ScreenGui:Destroy()
        end)
    end)
    PillButton.MouseButton1Click:Connect(RestoreWindow)
    
    -- Tab System
    local TabCount = 0
    
    local function CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        local TabName = TabConfig.Name or "Tab " .. tostring(TabCount + 1)
        local TabIcon = TabConfig.Icon
        TabCount = TabCount + 1
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, Aurora.Theme.TabHeight)
        TabButton.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
        TabButton.BackgroundTransparency = 0.5
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0
        TabButton.LayoutOrder = TabCount
        TabButton.Parent = SidebarContent
        self:CreateCorner(TabButton, Aurora.Theme.CornerRadius.Button)
        
        -- Tab Icon
        local IconOffset = 0
        if TabIcon then
            local IconLabel = Instance.new("TextLabel")
            IconLabel.Size = UDim2.new(0, 20, 0, 20)
            IconLabel.Position = UDim2.new(0, 8, 0.5, -10)
            IconLabel.Text = TabIcon
            IconLabel.Font = Aurora.Theme.Font.Body
            IconLabel.TextSize = 14
            IconLabel.TextColor3 = Aurora.Theme.TextSecondary
            IconLabel.BackgroundTransparency = 1
            IconLabel.Parent = TabButton
            IconOffset = 24
        end
        
        -- Tab Label (IMPORTANT: Store reference!)
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "TabLabel"
        TabLabel.Size = UDim2.new(1, -IconOffset - 16, 1, 0)
        TabLabel.Position = UDim2.new(0, IconOffset + 8, 0, 0)
        TabLabel.Text = TabName
        TabLabel.Font = Aurora.Theme.Font.Body
        TabLabel.TextSize = Aurora.Theme.FontSize.Body
        TabLabel.TextColor3 = Aurora.Theme.TextSecondary
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Parent = TabButton
        
        -- Selection Indicator
        local SelectionIndicator = Instance.new("Frame")
        SelectionIndicator.Name = "Indicator"
        SelectionIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        SelectionIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        SelectionIndicator.BackgroundColor3 = AccentColor
        SelectionIndicator.BackgroundTransparency = 1
        SelectionIndicator.BorderSizePixel = 0
        SelectionIndicator.Parent = TabButton
        self:CreateCorner(SelectionIndicator, UDim.new(0, 2))
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Aurora.Theme.Accent
        TabContent.ScrollBarImageTransparency = 0.5
        TabContent.Visible = false
        TabContent.BorderSizePixel = 0
        TabContent.Parent = ContentContainer
        self:CreatePadding(TabContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
        self:CreateListLayout(TabContent, Enum.FillDirection.Vertical, UDim.new(0, 8))
        
        -- Tab Object
        local Tab = {
            Name = TabName,
            Button = TabButton,
            Label = TabLabel, -- Store reference!
            Content = TabContent,
            Sections = {},
            SectionCount = 0,
        }
        
        -- Select Tab Function
        local function SelectTab()
            for _, OtherTab in ipairs(WindowState.Tabs) do
                OtherTab.Content.Visible = false
                Aurora.Animation:Play(OtherTab.Button, { BackgroundTransparency = 0.5 }, Aurora.Theme.AnimationDuration.Fast)
                Aurora.Animation:Play(OtherTab.Button.Indicator, { BackgroundTransparency = 1 }, Aurora.Theme.AnimationDuration.Fast)
                -- Use stored reference instead of FindFirstChild
                if OtherTab.Label then
                    OtherTab.Label.TextColor3 = Aurora.Theme.TextSecondary
                end
            end
            
            TabContent.Visible = true
            Aurora.Animation:Play(TabButton, { BackgroundTransparency = 0.2 }, Aurora.Theme.AnimationDuration.Fast)
            Aurora.Animation:Play(TabButton.Indicator, { BackgroundTransparency = 0 }, Aurora.Theme.AnimationDuration.Fast)
            if Tab.Label then
                Tab.Label.TextColor3 = Aurora.Theme.TextPrimary
            end
            
            WindowState.ActiveTab = Tab
            
            task.defer(function()
                local Layout = TabContent:FindFirstChildOfClass("UIListLayout")
                if Layout then
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
                end
            end)
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        TabButton.MouseEnter:Connect(function()
            if WindowState.ActiveTab ~= Tab then
                Aurora.Animation:Play(TabButton, { BackgroundTransparency = 0.3 }, Aurora.Theme.AnimationDuration.Fast)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if WindowState.ActiveTab ~= Tab then
                Aurora.Animation:Play(TabButton, { BackgroundTransparency = 0.5 }, Aurora.Theme.AnimationDuration.Fast)
            end
        end)
        
        -- Section System
        local function CreateSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            local SectionName = SectionConfig.Name or "Section"
            Tab.SectionCount = Tab.SectionCount + 1
            
            local SectionCard = Instance.new("Frame")
            SectionCard.Name = SectionName
            SectionCard.Size = UDim2.new(1, 0, 0, 0)
            SectionCard.AutomaticSize = Enum.AutomaticSize.Y
            SectionCard.BackgroundColor3 = Aurora.Theme.GlassBackground
            SectionCard.BackgroundTransparency = Aurora.Theme.GlassBackgroundTransparency
            SectionCard.BorderSizePixel = 0
            SectionCard.LayoutOrder = Tab.SectionCount
            SectionCard.Parent = TabContent
            self:CreateCorner(SectionCard, Aurora.Theme.CornerRadius.Card)
            self:CreateStroke(SectionCard, Aurora.Theme.GlassBorder, Aurora.Theme.GlassBorderTransparency)
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.Parent = SectionCard
            self:CreatePadding(SectionContent, UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12))
            self:CreateListLayout(SectionContent, Enum.FillDirection.Vertical, UDim.new(0, Aurora.Theme.ComponentSpacing))
            
            local Header = Instance.new("Frame")
            Header.Name = "Header"
            Header.Size = UDim2.new(1, 0, 0, 24)
            Header.BackgroundTransparency = 1
            Header.BorderSizePixel = 0
            Header.Parent = SectionContent
            
            local HeaderText = Instance.new("TextLabel")
            HeaderText.Size = UDim2.new(1, 0, 1, 0)
            HeaderText.Text = SectionName
            HeaderText.Font = Aurora.Theme.Font.Subtitle
            HeaderText.TextSize = Aurora.Theme.FontSize.Subtitle
            HeaderText.TextColor3 = Aurora.Theme.TextPrimary
            HeaderText.TextXAlignment = Enum.TextXAlignment.Left
            HeaderText.BackgroundTransparency = 1
            HeaderText.Parent = Header
            
            local Divider = Instance.new("Frame")
            Divider.Name = "Divider"
            Divider.Size = UDim2.new(1, 0, 0, 1)
            Divider.BackgroundColor3 = Aurora.Theme.Divider
            Divider.BackgroundTransparency = 0.5
            Divider.BorderSizePixel = 0
            Divider.Parent = SectionContent
            
            local ComponentContainer = Instance.new("Frame")
            ComponentContainer.Name = "Components"
            ComponentContainer.Size = UDim2.new(1, 0, 0, 0)
            ComponentContainer.AutomaticSize = Enum.AutomaticSize.Y
            ComponentContainer.BackgroundTransparency = 1
            ComponentContainer.BorderSizePixel = 0
            ComponentContainer.Parent = SectionContent
            self:CreateListLayout(ComponentContainer, Enum.FillDirection.Vertical, UDim.new(0, Aurora.Theme.ComponentSpacing))
            
            local Layout = ComponentContainer:FindFirstChildOfClass("UIListLayout")
            if Layout then
                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    task.defer(function()
                        local ContentLayout = TabContent:FindFirstChildOfClass("UIListLayout")
                        if ContentLayout then
                            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 16)
                        end
                    end)
                end)
            end
            
            local Section = {
                Name = SectionName,
                Card = SectionCard,
                Container = ComponentContainer,
                ComponentCount = 0,
            }
            
            -- ═══ COMPONENT FACTORIES ═══
            
            -- Button
            function Section:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                local ButtonText = ButtonConfig.Text or "Button"
                local Callback = ButtonConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local Button = Instance.new("TextButton")
                Button.Name = "Button_" .. self.ComponentCount
                Button.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Button.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
                Button.BackgroundTransparency = 0.2
                Button.Text = ButtonText
                Button.Font = Aurora.Theme.Font.Body
                Button.TextSize = Aurora.Theme.FontSize.Body
                Button.TextColor3 = Aurora.Theme.TextPrimary
                Button.BorderSizePixel = 0
                Button.LayoutOrder = self.ComponentCount
                Button.Parent = self.Container
                Aurora.Components:CreateCorner(Button, Aurora.Theme.CornerRadius.Button)
                Aurora.Components:CreateStroke(Button, Aurora.Theme.GlassBorder, 0.9)
                
                Button.MouseEnter:Connect(function()
                    Aurora.Animation:Play(Button, { BackgroundTransparency = 0.1 }, Aurora.Theme.AnimationDuration.Fast)
                end)
                Button.MouseLeave:Connect(function()
                    Aurora.Animation:Play(Button, { BackgroundTransparency = 0.2 }, Aurora.Theme.AnimationDuration.Fast)
                end)
                Button.MouseButton1Click:Connect(Callback)
                
                return Button
            end
            
            -- Toggle
            function Section:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                local ToggleTitle = ToggleConfig.Title or "Toggle"
                local DefaultValue = ToggleConfig.Default or false
                local Callback = ToggleConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local ToggleValue = DefaultValue
                
                local Container = Instance.new("Frame")
                Container.Name = "Toggle_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(1, -60, 1, 0)
                TitleLabel.Text = ToggleTitle
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = Container
                
                local ToggleSwitch = Instance.new("TextButton")
                ToggleSwitch.Name = "Switch"
                ToggleSwitch.Size = UDim2.new(0, 48, 0, 24)
                ToggleSwitch.Position = UDim2.new(1, -48, 0.5, -12)
                ToggleSwitch.BackgroundColor3 = ToggleValue and AccentColor or Aurora.Theme.BackgroundQuaternary
                ToggleSwitch.BackgroundTransparency = 0.2
                ToggleSwitch.Text = ""
                ToggleSwitch.BorderSizePixel = 0
                ToggleSwitch.Parent = Container
                Aurora.Components:CreateCorner(ToggleSwitch, Aurora.Theme.CornerRadius.Pill)
                Aurora.Components:CreateStroke(ToggleSwitch, Aurora.Theme.GlassBorder, 0.85)
                
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 18, 0, 18)
                Knob.Position = UDim2.new(ToggleValue and 1 or 0, ToggleValue and -21 or 3, 0.5, -9)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = ToggleSwitch
                Aurora.Components:CreateCorner(Knob, UDim.new(0, 10))
                
                local function UpdateToggle(Value, Animate)
                    Animate = Animate ~= false
                    ToggleValue = Value
                    if Animate then
                        Aurora.Animation:Play(ToggleSwitch, {
                            BackgroundColor3 = Value and AccentColor or Aurora.Theme.BackgroundQuaternary
                        }, Aurora.Theme.AnimationDuration.Fast)
                        Aurora.Animation:Play(Knob, {
                            Position = UDim2.new(Value and 1 or 0, Value and -21 or 3, 0.5, -9)
                        }, Aurora.Theme.AnimationDuration.Fast, Enum.EasingStyle.Quad)
                    else
                        ToggleSwitch.BackgroundColor3 = Value and AccentColor or Aurora.Theme.BackgroundQuaternary
                        Knob.Position = UDim2.new(Value and 1 or 0, Value and -21 or 3, 0.5, -9)
                    end
                end
                
                ToggleSwitch.MouseButton1Click:Connect(function()
                    UpdateToggle(not ToggleValue, true)
                    Callback(ToggleValue)
                end)
                
                return {
                    SetValue = function(self, Value)
                        UpdateToggle(Value, true)
                        Callback(Value)
                    end,
                    GetValue = function() return ToggleValue end
                }
            end
            
            -- Slider
            function Section:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                local SliderTitle = SliderConfig.Title or "Slider"
                local MinValue = SliderConfig.Min or 0
                local MaxValue = SliderConfig.Max or 100
                local DefaultValue = SliderConfig.Default or MinValue
                local Decimals = SliderConfig.Decimals or 0
                local Suffix = SliderConfig.Suffix or ""
                local Callback = SliderConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local SliderValue = Utility.Clamp(DefaultValue, MinValue, MaxValue)
                
                local Container = Instance.new("Frame")
                Container.Name = "Slider_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight + 8)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                local HeaderContainer = Instance.new("Frame")
                HeaderContainer.Size = UDim2.new(1, 0, 0, 20)
                HeaderContainer.BackgroundTransparency = 1
                HeaderContainer.BorderSizePixel = 0
                HeaderContainer.Parent = Container
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
                TitleLabel.Text = SliderTitle
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = HeaderContainer
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.5, 0, 1, 0)
                ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ValueLabel.Text = tostring(Utility.Round(SliderValue, Decimals)) .. Suffix
                ValueLabel.Font = Aurora.Theme.Font.Body
                ValueLabel.TextSize = Aurora.Theme.FontSize.Body
                ValueLabel.TextColor3 = Aurora.Theme.TextSecondary
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Parent = HeaderContainer
                
                local SliderTrack = Instance.new("TextButton")
                SliderTrack.Name = "Track"
                SliderTrack.Size = UDim2.new(1, 0, 0, 8)
                SliderTrack.Position = UDim2.new(0, 0, 1, -8)
                SliderTrack.BackgroundColor3 = Aurora.Theme.BackgroundQuaternary
                SliderTrack.BackgroundTransparency = 0.2
                SliderTrack.Text = ""
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = Container
                Aurora.Components:CreateCorner(SliderTrack, Aurora.Theme.CornerRadius.Small)
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((SliderValue - MinValue) / (MaxValue - MinValue), 0, 1, 0)
                SliderFill.BackgroundColor3 = AccentColor
                SliderFill.BackgroundTransparency = 0.1
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                Aurora.Components:CreateCorner(SliderFill, Aurora.Theme.CornerRadius.Small)
                Aurora.Components:CreateGradient(SliderFill, nil, 0)
                
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Name = "Knob"
                SliderKnob.Size = UDim2.new(0, 16, 0, 16)
                SliderKnob.Position = UDim2.new((SliderValue - MinValue) / (MaxValue - MinValue), -8, 0.5, -8)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderKnob.BorderSizePixel = 0
                SliderKnob.Parent = SliderTrack
                Aurora.Components:CreateCorner(SliderKnob, UDim.new(0, 8))
                
                local DraggingSlider = false
                
                local function UpdateSlider(X, Animate)
                    local RelativeX = math.clamp((X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local NewValue = MinValue + (MaxValue - MinValue) * RelativeX
                    NewValue = Utility.Round(NewValue, Decimals)
                    NewValue = Utility.Clamp(NewValue, MinValue, MaxValue)
                    SliderValue = NewValue
                    local Percent = (SliderValue - MinValue) / (MaxValue - MinValue)
                    SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(Percent, -8, 0.5, -8)
                    ValueLabel.Text = tostring(Utility.Round(SliderValue, Decimals)) .. Suffix
                end
                
                SliderTrack.MouseButton1Down:Connect(function()
                    DraggingSlider = true
                    UpdateSlider(LocalMouse.X, true)
                end)
                
                if Services.UserInputService then
                    Services.UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and DraggingSlider then
                            DraggingSlider = false
                            Callback(SliderValue)
                        end
                    end)
                    Services.UserInputService.InputChanged:Connect(function(Input)
                        if DraggingSlider and Input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(Input.Position.X, true)
                        end
                    end)
                end
                
                return {
                    SetValue = function(self, Value)
                        SliderValue = Utility.Clamp(Value, MinValue, MaxValue)
                        local Percent = (SliderValue - MinValue) / (MaxValue - MinValue)
                        SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(Percent, -8, 0.5, -8)
                        ValueLabel.Text = tostring(Utility.Round(SliderValue, Decimals)) .. Suffix
                        Callback(SliderValue)
                    end,
                    GetValue = function() return SliderValue end
                }
            end
            
            -- Dropdown
            function Section:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                local DropdownTitle = DropdownConfig.Title or "Dropdown"
                local Options = DropdownConfig.Options or { "Option 1", "Option 2" }
                local DefaultOption = DropdownConfig.Default or Options[1]
                local Callback = DropdownConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local DropdownOpen = false
                local SelectedOption = DefaultOption
                
                local Container = Instance.new("Frame")
                Container.Name = "Dropdown_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Container.ClipsDescendants = true
                Container.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
                Container.BackgroundTransparency = 0.2
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                Aurora.Components:CreateCorner(Container, Aurora.Theme.CornerRadius.Button)
                Aurora.Components:CreateStroke(Container, Aurora.Theme.GlassBorder, 0.85)
                
                local Header = Instance.new("TextButton")
                Header.Name = "Header"
                Header.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Header.BackgroundTransparency = 1
                Header.Text = ""
                Header.BorderSizePixel = 0
                Header.Parent = Container
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(1, -50, 1, 0)
                TitleLabel.Position = UDim2.new(0, 12, 0, 0)
                TitleLabel.Text = SelectedOption
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = Header
                
                local ArrowLabel = Instance.new("TextLabel")
                ArrowLabel.Size = UDim2.new(0, 30, 1, 0)
                ArrowLabel.Position = UDim2.new(1, -36, 0, 0)
                ArrowLabel.Text = "▼"
                ArrowLabel.Font = Aurora.Theme.Font.Body
                ArrowLabel.TextSize = 10
                ArrowLabel.TextColor3 = Aurora.Theme.TextSecondary
                ArrowLabel.BackgroundTransparency = 1
                ArrowLabel.Parent = Header
                
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Name = "Options"
                OptionsContainer.Size = UDim2.new(1, -4, 0, 0)
                OptionsContainer.Position = UDim2.new(0, 2, 0, Aurora.Theme.ComponentHeight)
                OptionsContainer.BackgroundTransparency = 1
                OptionsContainer.BorderSizePixel = 0
                OptionsContainer.Parent = Container
                Aurora.Components:CreateListLayout(OptionsContainer, Enum.FillDirection.Vertical, UDim.new(0, 2))
                
                for _, Option in ipairs(Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = Option
                    OptionButton.Size = UDim2.new(1, 0, 0, 32)
                    OptionButton.BackgroundColor3 = Option == SelectedOption and AccentColor or Aurora.Theme.BackgroundQuaternary
                    OptionButton.BackgroundTransparency = Option == SelectedOption and 0.3 or 0.4
                    OptionButton.Text = Option
                    OptionButton.Font = Aurora.Theme.Font.Body
                    OptionButton.TextSize = Aurora.Theme.FontSize.Body
                    OptionButton.TextColor3 = Aurora.Theme.TextPrimary
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Parent = OptionsContainer
                    Aurora.Components:CreateCorner(OptionButton, Aurora.Theme.CornerRadius.Small)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        SelectedOption = Option
                        TitleLabel.Text = Option
                        Callback(Option)
                        Aurora.Animation:Play(Container, { Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight) }, Aurora.Theme.AnimationDuration.Fast)
                        Aurora.Animation:Play(ArrowLabel, { Rotation = 0 }, Aurora.Theme.AnimationDuration.Fast)
                        DropdownOpen = false
                    end)
                end
                
                local OptionsHeight = #Options * 34
                
                Header.MouseButton1Click:Connect(function()
                    if DropdownOpen then
                        Aurora.Animation:Play(Container, { Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight) }, Aurora.Theme.AnimationDuration.Fast)
                        Aurora.Animation:Play(ArrowLabel, { Rotation = 0 }, Aurora.Theme.AnimationDuration.Fast)
                    else
                        Aurora.Animation:Play(Container, { Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight + OptionsHeight + 4) }, Aurora.Theme.AnimationDuration.Fast)
                        Aurora.Animation:Play(ArrowLabel, { Rotation = 180 }, Aurora.Theme.AnimationDuration.Fast)
                    end
                    DropdownOpen = not DropdownOpen
                end)
                
                return {
                    SetOption = function(self, Option)
                        if table.find(Options, Option) then
                            SelectedOption = Option
                            TitleLabel.Text = Option
                            Callback(Option)
                        end
                    end,
                    GetOption = function() return SelectedOption end
                }
            end
            
            -- Textbox
            function Section:AddTextbox(TextboxConfig)
                TextboxConfig = TextboxConfig or {}
                local TextboxTitle = TextboxConfig.Title or "Textbox"
                local Placeholder = TextboxConfig.Placeholder or "Enter text..."
                local DefaultValue = TextboxConfig.Default or ""
                local Callback = TextboxConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local Container = Instance.new("Frame")
                Container.Name = "Textbox_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
                TitleLabel.Text = TextboxTitle
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = Container
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Size = UDim2.new(0.6, 0, 1, 0)
                TextboxFrame.Position = UDim2.new(0.4, 0, 0, 0)
                TextboxFrame.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
                TextboxFrame.BackgroundTransparency = 0.2
                TextboxFrame.BorderSizePixel = 0
                TextboxFrame.Parent = Container
                Aurora.Components:CreateCorner(TextboxFrame, Aurora.Theme.CornerRadius.Button)
                Aurora.Components:CreateStroke(TextboxFrame, Aurora.Theme.GlassBorder, 0.85)
                
                local Textbox = Instance.new("TextBox")
                Textbox.Size = UDim2.new(1, -16, 1, 0)
                Textbox.Position = UDim2.new(0, 8, 0, 0)
                Textbox.Text = DefaultValue
                Textbox.PlaceholderText = Placeholder
                Textbox.PlaceholderColor3 = Aurora.Theme.TextMuted
                Textbox.Font = Aurora.Theme.Font.Body
                Textbox.TextSize = Aurora.Theme.FontSize.Body
                Textbox.TextColor3 = Aurora.Theme.TextPrimary
                Textbox.TextXAlignment = Enum.TextXAlignment.Left
                Textbox.BackgroundTransparency = 1
                Textbox.BorderSizePixel = 0
                Textbox.Parent = TextboxFrame
                
                Textbox.FocusLost:Connect(function(EnterPressed)
                    Callback(Textbox.Text, EnterPressed)
                end)
                
                return {
                    SetValue = function(self, Value) Textbox.Text = Value end,
                    GetValue = function() return Textbox.Text end
                }
            end
            
            -- Keybind
            function Section:AddKeybind(KeybindConfig)
                KeybindConfig = KeybindConfig or {}
                local KeybindTitle = KeybindConfig.Title or "Keybind"
                local DefaultKey = KeybindConfig.Default or Enum.KeyCode.Unknown
                local Callback = KeybindConfig.Callback or function() end
                self.ComponentCount = self.ComponentCount + 1
                
                local Listening = false
                local CurrentKey = DefaultKey
                
                local Container = Instance.new("Frame")
                Container.Name = "Keybind_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
                TitleLabel.Text = KeybindTitle
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = Container
                
                local KeyButton = Instance.new("TextButton")
                KeyButton.Size = UDim2.new(0.4, 0, 1, 0)
                KeyButton.Position = UDim2.new(0.6, 0, 0, 0)
                KeyButton.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
                KeyButton.BackgroundTransparency = 0.2
                KeyButton.Text = CurrentKey.Name
                KeyButton.Font = Aurora.Theme.Font.Mono
                KeyButton.TextSize = Aurora.Theme.FontSize.Body
                KeyButton.TextColor3 = Aurora.Theme.TextPrimary
                KeyButton.BorderSizePixel = 0
                KeyButton.Parent = Container
                Aurora.Components:CreateCorner(KeyButton, Aurora.Theme.CornerRadius.Button)
                Aurora.Components:CreateStroke(KeyButton, Aurora.Theme.GlassBorder, 0.85)
                
                KeyButton.MouseButton1Click:Connect(function()
                    if Listening then return end
                    Listening = true
                    KeyButton.Text = "..."
                    Aurora.Animation:Play(KeyButton, {
                        BackgroundColor3 = AccentColor,
                        BackgroundTransparency = 0.5
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                if Services.UserInputService then
                    Services.UserInputService.InputBegan:Connect(function(Input, Processed)
                        if Listening then
                            Listening = false
                            CurrentKey = Input.KeyCode
                            KeyButton.Text = CurrentKey.Name
                            Aurora.Animation:Play(KeyButton, {
                                BackgroundColor3 = Aurora.Theme.BackgroundTertiary,
                                BackgroundTransparency = 0.2
                            }, Aurora.Theme.AnimationDuration.Fast)
                            Callback(CurrentKey)
                        elseif not Processed and Input.KeyCode == CurrentKey then
                            Callback(CurrentKey)
                        end
                    end)
                end
                
                return {
                    SetKey = function(self, Key)
                        CurrentKey = Key
                        KeyButton.Text = Key.Name
                        Callback(Key)
                    end,
                    GetKey = function() return CurrentKey end
                }
            end
            
            -- Label
            function Section:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                local LabelText = LabelConfig.Text or "Label"
                self.ComponentCount = self.ComponentCount + 1
                
                local Label = Instance.new("TextLabel")
                Label.Name = "Label_" .. self.ComponentCount
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Text = LabelText
                Label.Font = Aurora.Theme.Font.Body
                Label.TextSize = Aurora.Theme.FontSize.Body
                Label.TextColor3 = Aurora.Theme.TextSecondary
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.BorderSizePixel = 0
                Label.LayoutOrder = self.ComponentCount
                Label.Parent = self.Container
                
                return {
                    SetText = function(self, Text) Label.Text = Text end
                }
            end
            
            -- Paragraph
            function Section:AddParagraph(ParagraphConfig)
                ParagraphConfig = ParagraphConfig or {}
                local ParagraphTitle = ParagraphConfig.Title or ""
                local ParagraphText = ParagraphConfig.Text or "Paragraph text..."
                self.ComponentCount = self.ComponentCount + 1
                
                local Container = Instance.new("Frame")
                Container.Name = "Paragraph_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, 0)
                Container.AutomaticSize = Enum.AutomaticSize.Y
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                if ParagraphTitle ~= "" then
                    local TitleLabel = Instance.new("TextLabel")
                    TitleLabel.Size = UDim2.new(1, 0, 0, 20)
                    TitleLabel.Text = ParagraphTitle
                    TitleLabel.Font = Aurora.Theme.Font.Subtitle
                    TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                    TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    TitleLabel.BackgroundTransparency = 1
                    TitleLabel.Parent = Container
                end
                
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(1, 0, 0, 0)
                TextLabel.AutomaticSize = Enum.AutomaticSize.Y
                TextLabel.Text = ParagraphText
                TextLabel.Font = Aurora.Theme.Font.Body
                TextLabel.TextSize = Aurora.Theme.FontSize.Body
                TextLabel.TextColor3 = Aurora.Theme.TextSecondary
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.TextWrapped = true
                TextLabel.BackgroundTransparency = 1
                TextLabel.Parent = Container
                
                return {
                    SetText = function(self, Text) TextLabel.Text = Text end
                }
            end
            
            -- Divider
            function Section:AddDivider()
                self.ComponentCount = self.ComponentCount + 1
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider_" .. self.ComponentCount
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.BackgroundColor3 = Aurora.Theme.Divider
                Divider.BackgroundTransparency = 0.5
                Divider.BorderSizePixel = 0
                Divider.LayoutOrder = self.ComponentCount
                Divider.Parent = self.Container
                return Divider
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        Tab.CreateSection = CreateSection
        table.insert(WindowState.Tabs, Tab)
        
        if #WindowState.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        MinimizedPill = MinimizedPill,
        State = WindowState,
        AccentColor = AccentColor,
        CreateTab = CreateTab,
    }
    
    -- Toast Container
    local ToastContainer = Instance.new("Frame")
    ToastContainer.Name = "ToastContainer"
    ToastContainer.Size = UDim2.new(0, 300, 1, -20)
    ToastContainer.Position = UDim2.new(1, -320, 0, 10)
    ToastContainer.BackgroundTransparency = 1
    ToastContainer.BorderSizePixel = 0
    ToastContainer.Parent = ScreenGui
    self:CreateListLayout(ToastContainer, Enum.FillDirection.Vertical, UDim.new(0, 8))
    
    -- Notify Function
    function Window:Notify(NotifyConfig)
        NotifyConfig = NotifyConfig or {}
        local Title = NotifyConfig.Title or "Notification"
        local Message = NotifyConfig.Message or ""
        local Duration = NotifyConfig.Duration or 5
        local NotifyType = NotifyConfig.Type or "info"
        
        local NotifyColor = Aurora.Theme.Info
        if NotifyType == "success" then NotifyColor = Aurora.Theme.Success
        elseif NotifyType == "warning" then NotifyColor = Aurora.Theme.Warning
        elseif NotifyType == "error" then NotifyColor = Aurora.Theme.Error end
        
        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Size = UDim2.new(1, 0, 0, 0)
        Toast.AutomaticSize = Enum.AutomaticSize.Y
        Toast.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
        Toast.BackgroundTransparency = 0.1
        Toast.BorderSizePixel = 0
        Toast.Parent = ToastContainer
        self:CreateCorner(Toast, Aurora.Theme.CornerRadius.Card)
        self:CreateStroke(Toast, Aurora.Theme.GlassBorder, 0.7)
        
        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(0, 3, 1, 0)
        AccentLine.BackgroundColor3 = NotifyColor
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = Toast
        self:CreateCorner(AccentLine, UDim.new(0, 2))
        
        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -20, 0, 0)
        Content.Position = UDim2.new(0, 12, 0, 8)
        Content.AutomaticSize = Enum.AutomaticSize.Y
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.Parent = Toast
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, 0, 0, 20)
        TitleLabel.Text = Title
        TitleLabel.Font = Aurora.Theme.Font.Subtitle
        TitleLabel.TextSize = Aurora.Theme.FontSize.Body
        TitleLabel.TextColor3 = NotifyColor
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Parent = Content
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Size = UDim2.new(1, 0, 0, 0)
        MessageLabel.Position = UDim2.new(0, 0, 0, 22)
        MessageLabel.AutomaticSize = Enum.AutomaticSize.Y
        MessageLabel.Text = Message
        MessageLabel.Font = Aurora.Theme.Font.Body
        MessageLabel.TextSize = Aurora.Theme.FontSize.Small
        MessageLabel.TextColor3 = Aurora.Theme.TextSecondary
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextWrapped = true
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Parent = Content
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 8)
        Padding.Parent = Content
        
        Toast.Position = UDim2.new(1, 0, 0, 0)
        Aurora.Animation:Slide(Toast, UDim2.new(0, 0, 0, 0), Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
        
        task.delay(Duration, function()
            Aurora.Animation:Fade(Toast, 1, Aurora.Theme.AnimationDuration.Normal)
            Aurora.Animation:Slide(Toast, UDim2.new(0.2, 0, 0, 0), Aurora.Theme.AnimationDuration.Normal, nil, function()
                Toast:Destroy()
            end)
        end)
    end
    
    -- System Info Tab
    function Window:CreateSystemInfoTab()
        local Tab = self:CreateTab({ Name = "System", Icon = "⚡" })
        
        local EnvSection = Tab:CreateSection("Environment")
        local ExecutorInfo = Aurora.InfoProvider:GetExecutorInfo()
        EnvSection:AddLabel({ Text = "Executor: " .. ExecutorInfo.Name })
        EnvSection:AddLabel({ Text = "Version: " .. ExecutorInfo.Version })
        EnvSection:AddLabel({ Text = "Environment: " .. ExecutorInfo.Environment })
        
        local GameSection = Tab:CreateSection("Game")
        local GameInfo = Aurora.InfoProvider:GetGameInfo()
        GameSection:AddLabel({ Text = "Game: " .. GameInfo.Name })
        GameSection:AddLabel({ Text = "GameId: " .. GameInfo.GameId })
        GameSection:AddLabel({ Text = "PlaceId: " .. GameInfo.PlaceId })
        GameSection:AddLabel({ Text = "JobId: " .. GameInfo.JobId })
        GameSection:AddLabel({ Text = "Server: " .. GameInfo.ServerType })
        GameSection:AddLabel({ Text = "Players: " .. GameInfo.PlayerCount .. "/" .. GameInfo.MaxPlayers })
        
        local PlayerSection = Tab:CreateSection("Player")
        local PlayerInfo = Aurora.InfoProvider:GetPlayerInfo()
        PlayerSection:AddLabel({ Text = "Username: " .. PlayerInfo.Username })
        PlayerSection:AddLabel({ Text = "Display Name: " .. PlayerInfo.DisplayName })
        PlayerSection:AddLabel({ Text = "UserId: " .. PlayerInfo.UserId })
        PlayerSection:AddLabel({ Text = "Account Age: " .. PlayerInfo.AccountAge })
        PlayerSection:AddLabel({ Text = "Membership: " .. PlayerInfo.Membership })
        
        local SessionSection = Tab:CreateSection("Session")
        local TimeLabel = SessionSection:AddLabel({ Text = "Local Time: --:--:--" })
        local RuntimeLabel = SessionSection:AddLabel({ Text = "Runtime: 00:00:00" })
        local LoadedLabel = SessionSection:AddLabel({ Text = "UI Loaded: " .. Aurora.InfoProvider:GetSessionInfo().UILoadedTimestamp })
        
        task.spawn(function()
            while ScreenGui and ScreenGui.Parent do
                local SessionInfo = Aurora.InfoProvider:GetSessionInfo()
                TimeLabel:SetText("Local Time: " .. SessionInfo.CurrentTimeFormatted)
                RuntimeLabel.SetText("Runtime: " .. SessionInfo.RuntimeFormatted)
                task.wait(1)
            end
        end)
        
        return Tab
    end
    
    table.insert(Aurora.Windows, Window)
    Aurora.ActiveWindow = Window
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════

function Aurora:CreateWindow(Config)
    return Aurora.Core:CreateWindow(Config)
end

return Aurora
