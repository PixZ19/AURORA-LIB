-- ═══════════════════════════════════════════════════════════════
-- SERVICES & UTILITIES
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- We use pcall (protected call) to safely get services.
-- This ensures the library won't crash if a service is unavailable.
-- It's a defensive programming practice for robustness.

local Services = {}

local function GetService(ServiceName)
    -- Try to get the service, return nil if it fails
    local Success, Service = pcall(function()
        return game:GetService(ServiceName)
    end)
    return Success and Service or nil
end

-- Core Roblox services we'll need
Services.Players = GetService("Players")
Services.TweenService = GetService("TweenService")
Services.UserInputService = GetService("UserInputService")
Services.RunService = GetService("RunService")
Services.TextService = GetService("TextService")

-- [EXPLANATION]
-- LocalPlayer reference - we'll use this throughout the library
-- for player-related operations like getting username, userId, etc.

local LocalPlayer = Services.Players and Services.Players.LocalPlayer
local LocalMouse = LocalPlayer and LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- Utility functions are helper functions that perform common operations.
-- Keeping them centralized makes the code cleaner and easier to maintain.

local Utility = {}

-- Round a number to specified decimal places
function Utility.Round(Number, Decimals)
    Decimals = Decimals or 0
    local Multiplier = 10 ^ Decimals
    return math.floor(Number * Multiplier + 0.5) / Multiplier
end

-- Clamp a number between min and max values
function Utility.Clamp(Value, Min, Max)
    return math.max(Min, math.min(Max, Value))
end

-- Linear interpolation between two values
function Utility.Lerp(Start, End, Alpha)
    return Start + (End - Start) * Alpha
end

-- Check if a point is inside a rectangle
function Utility.PointInRect(Point, Position, Size)
    return Point.X >= Position.X and Point.X <= Position.X + Size.X
       and Point.Y >= Position.Y and Point.Y <= Position.Y + Size.Y
end

-- Deep copy a table (for state management)
function Utility.DeepCopy(Original)
    local Copy = {}
    for Key, Value in pairs(Original) do
        if type(Value) == "table" then
            Copy[Key] = Utility.DeepCopy(Value)
        else
            Copy[Key] = Value
        end
    end
    return Copy
end

-- Format seconds into HH:MM:SS
function Utility.FormatTime(Seconds)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local Secs = math.floor(Seconds % 60)
    return string.format("%02d:%02d:%02d", Hours, Minutes, Secs)
end

-- Format number with thousands separator
function Utility.FormatNumber(Number)
    return tostring(Number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Safely get nested properties (prevents errors)
function Utility.SafeGet(Object, ...)
    local Current = Object
    for _, Property in pairs({...}) do
        if Current and Current[Property] then
            Current = Current[Property]
        else
            return nil
        end
    end
    return Current
end

-- ═══════════════════════════════════════════════════════════════
-- AURORA LIBRARY MAIN TABLE
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The Aurora table is the main container for our entire library.
-- All systems are organized as subtables within Aurora for clean namespacing.

local Aurora = {
    Version = "1.0.0",
    Author = "Aurora Development Team",
    
    -- Internal system tables (organized like modules)
    Theme = {},
    Animation = {},
    Components = {},
    InfoProvider = {},
    Core = {},
    State = {},
    
    -- Active instances tracking
    Windows = {},
    ActiveWindow = nil,
}

-- ═══════════════════════════════════════════════════════════════
-- THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The Theme system defines our visual identity - glassmorphism colors,
-- gradients, spacing, and all visual parameters. Having a centralized
-- theme makes it easy to maintain consistency and allow customization.

Aurora.Theme = {
    -- ═══ Primary Color Palette ═══
    -- These are the core colors that define the Aurora aesthetic
    -- Aurora gradient colors (cyan to violet)
    AuroraCyan = Color3.fromRGB(100, 220, 255),
    AuroraViolet = Color3.fromRGB(180, 100, 255),
    AuroraPink = Color3.fromRGB(255, 100, 180),
    
    -- Default accent color (can be customized per window)
    Accent = Color3.fromRGB(100, 200, 255),
    
    -- ═══ Background Colors (Dark Theme) ═══
    -- Multiple levels for depth and hierarchy
    BackgroundPrimary = Color3.fromRGB(15, 15, 25),      -- Main background
    BackgroundSecondary = Color3.fromRGB(20, 20, 35),    -- Cards, panels
    BackgroundTertiary = Color3.fromRGB(25, 25, 40),     -- Hover states
    BackgroundQuaternary = Color3.fromRGB(35, 35, 55),   -- Active states
    
    -- ═══ Glassmorphism Settings ═══
    -- These create the frosted glass effect
    GlassBackground = Color3.fromRGB(20, 20, 35),
    GlassBackgroundTransparency = 0.15,
    GlassBorder = Color3.fromRGB(255, 255, 255),
    GlassBorderTransparency = 0.85,
    GlassBlur = 24, -- Blur intensity (requires client-side processing)
    
    -- ═══ Text Colors ═══
    TextPrimary = Color3.fromRGB(255, 255, 255),         -- Main text
    TextSecondary = Color3.fromRGB(180, 180, 200),       -- Subtitles
    TextMuted = Color3.fromRGB(120, 120, 140),           -- Disabled, hints
    TextAccent = Color3.fromRGB(100, 200, 255),          -- Accent colored text
    
    -- ═══ UI Element Colors ═══
    Divider = Color3.fromRGB(60, 60, 80),
    Shadow = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(100, 180, 255),
    
    -- ═══ Gradient Definitions ═══
    -- Pre-defined gradients for consistent look
    Gradients = {
        Aurora = {
            ColorSequence = {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 220, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 100, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 180)),
            }
        },
        Accent = {
            ColorSequence = {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 100, 255)),
            }
        },
        Glass = {
            ColorSequence = {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220)),
            }
        }
    },
    
    -- ═══ Sizing & Spacing ═══
    -- Consistent measurements for layout
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
    
    -- ═══ Corner Radius ═══
    -- Modern rounded corners for different elements
    CornerRadius = {
        Window = UDim.new(0, 16),
        Card = UDim.new(0, 12),
        Button = UDim.new(0, 8),
        Small = UDim.new(0, 6),
        Pill = UDim.new(0, 20),
    },
    
    -- ═══ Animation Timing ═══
    AnimationDuration = {
        Fast = 0.15,
        Normal = 0.25,
        Slow = 0.4,
    },
    
    -- ═══ Typography ═══
    -- Font settings for text elements
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

-- Theme customization function
-- [EXPLANATION]
-- This function allows users to customize the theme by passing
-- a table of overrides. Only specified values are changed.

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

-- [EXPLANATION]
-- The Animation system provides a centralized way to create smooth
-- animations using TweenService. All animations in Aurora go through
-- this system for consistency and easy management.

Aurora.Animation = {
    -- Default easing styles for smooth, modern animations
    DefaultEasingStyle = Enum.EasingStyle.Quad,
    DefaultEasingDirection = Enum.EasingDirection.Out,
    
    -- Active tweens tracking (for cancellation)
    ActiveTweens = {},
}

-- Create a tween animation
-- [EXPLANATION]
-- This is the core animation function. It creates a TweenService
-- animation with proper defaults. Returns the tween for control.
function Aurora.Animation:Create(Object, Properties, Duration, EasingStyle, EasingDirection)
    if not Object or not Properties then return nil end
    
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    EasingStyle = EasingStyle or self.DefaultEasingStyle
    EasingDirection = EasingDirection or self.DefaultEasingDirection
    
    local TweenInfo = TweenInfo.new(
        Duration,
        EasingStyle,
        EasingDirection
    )
    
    local Tween = Services.TweenService:Create(Object, TweenInfo, Properties)
    return Tween
end

-- Play an animation (convenience function)
-- [EXPLANATION]
-- Creates and immediately plays an animation. This is the most
-- commonly used function for simple animations.
function Aurora.Animation:Play(Object, Properties, Duration, EasingStyle, EasingDirection)
    local Tween = self:Create(Object, Properties, Duration, EasingStyle, EasingDirection)
    if Tween then
        Tween:Play()
        return Tween
    end
    return nil
end

-- Fade animation
-- [EXPLANATION]
-- Smoothly fades an object in or out by animating transparency
-- and optionally the visibility (BackgroundTransparency for backgrounds).
function Aurora.Animation:Fade(Object, TargetTransparency, Duration, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    
    local Properties = {}
    
    -- Handle different object types
    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
        Properties.TextTransparency = TargetTransparency
        if Object.BackgroundTransparency then
            Properties.BackgroundTransparency = TargetTransparency
        end
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        Properties.ImageTransparency = TargetTransparency
        if Object.BackgroundTransparency then
            Properties.BackgroundTransparency = TargetTransparency
        end
    elseif Object:IsA("Frame") or Object:IsA("ScrollingFrame") then
        Properties.BackgroundTransparency = TargetTransparency
    end
    
    local Tween = self:Play(Object, Properties, Duration)
    
    if Callback then
        Tween.Completed:Connect(Callback)
    end
    
    return Tween
end

-- Scale animation
-- [EXPLANATION]
-- Animates the scale of an object using a UIScale modifier.
-- Requires the object to have or creates a UIScale child.
function Aurora.Animation:Scale(Object, TargetScale, Duration, EasingStyle, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    
    -- Find or create UIScale
    local UIScale = Object:FindFirstChildOfClass("UIScale")
    if not UIScale then
        UIScale = Instance.new("UIScale")
        UIScale.Parent = Object
        UIScale.Scale = 1
    end
    
    local Tween = self:Play(Object.UIScale, { Scale = TargetScale }, Duration, EasingStyle)
    
    if Callback then
        Tween.Completed:Connect(Callback)
    end
    
    return Tween
end

-- Slide animation
-- [EXPLANATION]
-- Animates the position of an object. Useful for slide-in/out effects.
function Aurora.Animation:Slide(Object, TargetPosition, Duration, EasingStyle, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    EasingStyle = EasingStyle or Enum.EasingStyle.Quart
    
    local Tween = self:Play(Object, { Position = TargetPosition }, Duration, EasingStyle)
    
    if Callback then
        Tween.Completed:Connect(Callback)
    end
    
    return Tween
end

-- Combined fade + scale (for minimize/restore)
-- [EXPLANATION]
-- Combines fade and scale for a smooth minimize/restore effect.
-- This creates a polished, professional transition.
function Aurora.Animation:FadeScale(Object, TargetScale, TargetTransparency, Duration, Callback)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    
    -- Start scale animation
    self:Scale(Object, TargetScale, Duration, Enum.EasingStyle.Quad)
    
    -- Start fade animation
    local Tween = self:Fade(Object, TargetTransparency, Duration)
    
    if Callback then
        Tween.Completed:Connect(Callback)
    end
    
    return Tween
end

-- Staggered entrance animation
-- [EXPLANATION]
-- Creates a professional staggered reveal effect for multiple objects.
-- Each object animates slightly after the previous one.
function Aurora.Animation:StaggeredEntrance(Objects, Duration, StaggerDelay)
    Duration = Duration or Aurora.Theme.AnimationDuration.Normal
    StaggerDelay = StaggerDelay or 0.05
    
    for Index, Object in ipairs(Objects) do
        -- Set initial state
        Object.BackgroundTransparency = 1
        
        -- Delay each animation
        task.delay((Index - 1) * StaggerDelay, function()
            self:Fade(Object, 0, Duration, Enum.EasingStyle.Quad)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INFO PROVIDER SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The InfoProvider system gathers information about the game environment,
-- executor, player, and session. It handles missing data gracefully
-- and never crashes the UI.

Aurora.InfoProvider = {
    SessionStartTime = os.time(),
    ExecutorInfo = nil,
    GameInfo = nil,
    PlayerInfo = nil,
}

-- Detect executor information
-- [EXPLANATION]
-- This function attempts to detect the executor being used.
-- Different executors have different functions for identification.
-- We use pcall to prevent crashes on unsupported environments.
function Aurora.InfoProvider:GetExecutorInfo()
    if self.ExecutorInfo then return self.ExecutorInfo end
    
    local Info = {
        Name = "Unknown",
        Version = "N/A",
        Environment = "Unknown",
    }
    
    -- Try to detect common executors
    -- [NOTE] These checks are done safely with pcall
    
    -- Check for Synapse X
    local SynapseCheck = pcall(function()
        return syn and syn.request
    end)
    if SynapseCheck then
        Info.Name = "Synapse X"
        Info.Environment = "Synapse"
        pcall(function()
            Info.Version = syn.getversion and syn.getversion() or "N/A"
        end)
    end
    
    -- Check for Script-Ware
    local ScriptWareCheck = pcall(function()
        return getgenv and getgenv().SCRIPTWARE
    end)
    if ScriptWareCheck then
        Info.Name = "Script-Ware"
        Info.Environment = "ScriptWare"
    end
    
    -- Check for KRNL
    local KRNLCheck = pcall(function()
        return KRNL_LOADED
    end)
    if KRNLCheck then
        Info.Name = "KRNL"
        Info.Environment = "KRNL"
    end
    
    -- Check for Fluxus
    local FluxusCheck = pcall(function()
        return fluxus and fluxus.getname
    end)
    if FluxusCheck then
        Info.Name = "Fluxus"
        Info.Environment = "Fluxus"
    end
    
    -- Check for Electron
    local ElectronCheck = pcall(function()
        return electron and electron.getname
    end)
    if ElectronCheck then
        Info.Name = "Electron"
        Info.Environment = "Electron"
    end
    
    -- Check for Codex
    local CodexCheck = pcall(function()
        return codex and codex.getname
    end)
    if CodexCheck then
        Info.Name = "Codex"
        Info.Environment = "Codex"
    end
    
    -- Check if we're in Roblox Studio
    if Services.RunService and Services.RunService:IsStudio() then
        Info.Name = "Roblox Studio"
        Info.Version = "Editor"
        Info.Environment = "Studio"
    end
    
    -- Fallback: Check for generic Lua environment
    pcall(function()
        if _G and rawget(_G, "LoadedScripts") then
            Info.Environment = Info.Environment ~= "Unknown" and Info.Environment or "Custom"
        end
    end)
    
    self.ExecutorInfo = Info
    return Info
end

-- Get game information
-- [EXPLANATION]
-- Retrieves information about the current game/place.
-- All values have fallbacks to prevent errors.
function Aurora.InfoProvider:GetGameInfo()
    if self.GameInfo then return self.GameInfo end
    
    local Info = {
        Name = "Unknown",
        GameId = "N/A",
        PlaceId = "N/A",
        JobId = "N/A",
        ServerType = "Unknown",
        MaxPlayers = "N/A",
        PlayerCount = "N/A",
    }
    
    -- Safely get game info
    pcall(function()
        Info.Name = game.Name or "Unknown"
    end)
    
    pcall(function()
        Info.GameId = tostring(game.GameId)
    end)
    
    pcall(function()
        Info.PlaceId = tostring(game.PlaceId)
    end)
    
    pcall(function()
        Info.JobId = game.JobId or "N/A"
    end)
    
    -- Detect server type
    pcall(function()
        if LocalPlayer then
            local PrivateServerId = game.PrivateServerId
            if PrivateServerId and PrivateServerId ~= "" then
                Info.ServerType = "Private"
            else
                Info.ServerType = "Public"
            end
        end
    end)
    
    -- Get player count
    pcall(function()
        if Services.Players then
            Info.MaxPlayers = tostring(Services.Players.MaxPlayers)
            Info.PlayerCount = tostring(#Services.Players:GetPlayers())
        end
    end)
    
    self.GameInfo = Info
    return Info
end

-- Get player information
-- [EXPLANATION]
-- Retrieves information about the local player.
-- Handles missing LocalPlayer gracefully.
function Aurora.InfoProvider:GetPlayerInfo()
    -- Always refresh for live data like account age
    local Info = {
        Username = "Unknown",
        UserId = "N/A",
        DisplayName = "Unknown",
        AccountAge = "N/A",
        AccountAgeDays = 0,
        Membership = "None",
    }
    
    if not LocalPlayer then return Info end
    
    pcall(function()
        Info.Username = LocalPlayer.Name or "Unknown"
    end)
    
    pcall(function()
        Info.UserId = tostring(LocalPlayer.UserId)
    end)
    
    pcall(function()
        Info.DisplayName = LocalPlayer.DisplayName or "Unknown"
    end)
    
    pcall(function()
        local Age = LocalPlayer.AccountAge or 0
        Info.AccountAgeDays = Age
        Info.AccountAge = Utility.FormatNumber(Age) .. " days"
    end)
    
    pcall(function()
        if LocalPlayer.MembershipType then
            local MembershipType = LocalPlayer.MembershipType
            if MembershipType == Enum.MembershipType.Premium then
                Info.Membership = "Premium"
            else
                Info.Membership = "None"
            end
        end
    end)
    
    return Info
end

-- Get session information (live updating)
-- [EXPLANATION]
-- Returns session-related information including runtime.
-- This should be called periodically for live updates.
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

-- Get all information combined
-- [EXPLANATION]
-- Convenience function that returns all info in one table.
function Aurora.InfoProvider:GetAllInfo()
    return {
        Executor = self:GetExecutorInfo(),
        Game = self:GetGameInfo(),
        Player = self:GetPlayerInfo(),
        Session = self:GetSessionInfo(),
    }
end

-- ═══════════════════════════════════════════════════════════════
-- COMPONENT FACTORY SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The Components table contains factory functions for creating UI elements.
-- Each component follows a consistent pattern: Create -> Configure -> Return

Aurora.Components = {}

-- Create a UICorner (rounded corners)
-- [EXPLANATION]
-- UICorner is used to create rounded corners on frames.
-- This helper function creates one with the specified radius.
function Aurora.Components:CreateCorner(Parent, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Radius or Aurora.Theme.CornerRadius.Card
    Corner.Parent = Parent
    return Corner
end

-- Create a UIStroke (border)
-- [EXPLANATION]
-- UIStroke creates a border effect. For glassmorphism, we use
-- a semi-transparent white stroke to simulate light reflection.
function Aurora.Components:CreateStroke(Parent, Color, Transparency, Thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Aurora.Theme.GlassBorder
    Stroke.Transparency = Transparency or Aurora.Theme.GlassBorderTransparency
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Parent
    return Stroke
end

-- Create a UIGradient
-- [EXPLANATION]
-- UIGradient applies a gradient effect. Used for accent colors
-- and the signature Aurora gradient effect.
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

-- Create a UIListLayout
-- [EXPLANATION]
-- UIListLayout arranges children in a list (vertical or horizontal).
-- Used for component stacking in sections.
function Aurora.Components:CreateListLayout(Parent, Direction, Padding)
    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.FillDirection = Direction or Enum.FillDirection.Vertical
    Layout.Padding = Padding or UDim.new(0, Aurora.Theme.ComponentSpacing)
    Layout.Parent = Parent
    return Layout
end

-- Create a UIPadding
-- [EXPLANATION]
-- UIPadding adds internal spacing to a frame.
-- Essential for clean, breathable layouts.
function Aurora.Components:CreatePadding(Parent, PaddingTop, PaddingBottom, PaddingLeft, PaddingRight)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = PaddingTop or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingBottom = PaddingBottom or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingLeft = PaddingLeft or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.PaddingRight = PaddingRight or UDim.new(0, Aurora.Theme.SectionPadding)
    UIPadding.Parent = Parent
    return UIPadding
end

-- Create glass panel (core visual element)
-- [EXPLANATION]
-- This creates the signature glassmorphism panel - a semi-transparent
-- frame with rounded corners, subtle border, and optional gradient.
function Aurora.Components:CreateGlassPanel(Parent, Size, Position)
    local Panel = Instance.new("Frame")
    Panel.Name = "GlassPanel"
    Panel.Size = Size or UDim2.new(1, 0, 1, 0)
    Panel.Position = Position or UDim2.new(0, 0, 0, 0)
    Panel.BackgroundColor3 = Aurora.Theme.GlassBackground
    Panel.BackgroundTransparency = Aurora.Theme.GlassBackgroundTransparency
    Panel.BorderSizePixel = 0
    Panel.Parent = Parent
    
    -- Add rounded corners
    self:CreateCorner(Panel, Aurora.Theme.CornerRadius.Card)
    
    -- Add glass border
    self:CreateStroke(Panel, Aurora.Theme.GlassBorder, Aurora.Theme.GlassBorderTransparency)
    
    return Panel
end

-- Create text label
-- [EXPLANATION]
-- Helper function for creating consistently styled text labels.
function Aurora.Components:CreateTextLabel(Parent, Text, Size, Position, Font, TextSize, TextColor)
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Text = Text or ""
    Label.Size = Size or UDim2.new(1, 0, 0, 20)
    Label.Position = Position or UDim2.new(0, 0, 0, 0)
    Label.Font = Font or Aurora.Theme.Font.Body
    Label.TextSize = TextSize or Aurora.Theme.FontSize.Body
    Label.TextColor3 = TextColor or Aurora.Theme.TextPrimary
    Label.TextWrapped = true
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Parent
    return Label
end

-- Create text button
-- [EXPLANATION]
-- Helper function for creating consistently styled buttons.
function Aurora.Components:CreateTextButton(Parent, Text, Size, Position, Callback)
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Text = Text or ""
    Button.Size = Size or UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
    Button.Position = Position or UDim2.new(0, 0, 0, 0)
    Button.Font = Aurora.Theme.Font.Body
    Button.TextSize = Aurora.Theme.FontSize.Body
    Button.TextColor3 = Aurora.Theme.TextPrimary
    Button.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
    Button.BackgroundTransparency = 0.3
    Button.BorderSizePixel = 0
    Button.Parent = Parent
    
    -- Add rounded corners
    self:CreateCorner(Button, Aurora.Theme.CornerRadius.Button)
    
    -- Add hover effect
    Button.MouseEnter:Connect(function()
        Aurora.Animation:Play(Button, {
            BackgroundColor3 = Aurora.Theme.BackgroundQuaternary
        }, Aurora.Theme.AnimationDuration.Fast)
    end)
    
    Button.MouseLeave:Connect(function()
        Aurora.Animation:Play(Button, {
            BackgroundColor3 = Aurora.Theme.BackgroundTertiary
        }, Aurora.Theme.AnimationDuration.Fast)
    end)
    
    -- Add click callback
    if Callback then
        Button.MouseButton1Click:Connect(Callback)
    end
    
    return Button
end

-- ═══════════════════════════════════════════════════════════════
-- STATE MANAGEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The State system manages UI state for persistence during minimize/restore.
-- It stores toggle states, scroll positions, active tabs, etc.

Aurora.State = {
    -- Global state storage
    Storage = {},
    
    -- Save a value to state
    Save = function(self, Key, Value)
        self.Storage[Key] = Value
    end,
    
    -- Load a value from state
    Load = function(self, Key, Default)
        return self.Storage[Key] or Default
    end,
    
    -- Clear all state
    Clear = function(self)
        self.Storage = {}
    end,
    
    -- Check if key exists
    Exists = function(self, Key)
        return self.Storage[Key] ~= nil
    end,
}

-- ═══════════════════════════════════════════════════════════════
-- CORE WINDOW SYSTEM
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- The Core system handles window creation, dragging, minimizing,
-- and all high-level UI management. This is the main entry point.

Aurora.Core = {}

-- Create the main window
-- [EXPLANATION]
-- This is the primary function users call to create a UI window.
-- It returns a Window object with methods for creating tabs and sections.
function Aurora.Core:CreateWindow(Config)
    Config = Config or {}
    
    -- ═══ Validate Configuration ═══
    local Title = Config.Title or "Aurora Library"
    local Subtitle = Config.Subtitle or "Modern Futuristic UI"
    local AccentColor = Config.Accent or Aurora.Theme.Accent
    local Size = Config.Size or UDim2.new(0, Aurora.Theme.WindowWidth, 0, Aurora.Theme.WindowHeight)
    
    -- ═══ Create ScreenGui ═══
    -- [EXPLANATION]
    -- ScreenGui is the container for all UI elements.
    -- We use ResetOnSpawn = false so UI persists after respawn.
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AuroraUI_" .. tostring(math.random(10000, 99999))
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    -- Parent to appropriate container
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            ScreenGui.Parent = LocalPlayer.PlayerGui
        else
            ScreenGui.Parent = game.CoreGui
        end
    end)
    
    -- Fallback: try CoreGui directly
    if not ScreenGui.Parent then
        pcall(function()
            ScreenGui.Parent = game:GetService("CoreGui")
        end)
    end
    
    -- ═══ Create Background Blur Effect ═══
    -- [EXPLANATION]
    -- Creates a subtle blur effect behind the main window
    -- for enhanced glassmorphism aesthetic.
    
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "Background"
    BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    BackgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    BackgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundFrame.BackgroundTransparency = 0.6
    BackgroundFrame.Visible = false
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Parent = ScreenGui
    
    -- ═══ Create Main Window Container ═══
    -- [EXPLANATION]
    -- The main window is positioned in the center of the screen
    -- and contains all UI elements (sidebar, content area, etc.)
    
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = Size
    MainWindow.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    MainWindow.BackgroundColor3 = Aurora.Theme.BackgroundPrimary
    MainWindow.BackgroundTransparency = 0.05
    MainWindow.BorderSizePixel = 0
    MainWindow.Parent = ScreenGui
    Aurora.Components:CreateCorner(MainWindow, Aurora.Theme.CornerRadius.Window)
    Aurora.Components:CreateStroke(MainWindow, Color3.fromRGB(60, 60, 80), 0.5, 1)
    
    -- Add shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993" -- Shadow asset
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = -1
    Shadow.Parent = MainWindow
    
    -- ═══ Create Title Bar ═══
    -- [EXPLANATION]
    -- The title bar contains the window title, subtitle, and control buttons.
    -- It also serves as the draggable area for the window.
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow
    Aurora.Components:CreateCorner(TitleBar, Aurora.Theme.CornerRadius.Window)
    
    -- Create gradient accent line under title bar
    local AccentLine = Instance.new("Frame")
    AccentLine.Name = "AccentLine"
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = AccentColor
    AccentLine.BackgroundTransparency = 0
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TitleBar
    Aurora.Components:CreateGradient(AccentLine, ColorSequence.new({
        ColorSequenceKeypoint.new(0, AccentColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(AccentColor.R * 255 * 0.6 + 100, 255),
            math.min(AccentColor.G * 255 * 0.6 + 50, 255),
            math.min(AccentColor.B * 255 * 0.8 + 50, 255)
        )),
    }), 90)
    
    -- Title text
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
    
    -- Subtitle text
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
    
    -- ═══ Create Control Buttons ═══
    -- [EXPLANATION]
    -- Control buttons (minimize, close) are positioned in the title bar.
    -- They have hover effects for visual feedback.
    
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
    Aurora.Components:CreateCorner(MinimizeButton, Aurora.Theme.CornerRadius.Small)
    
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
    Aurora.Components:CreateCorner(CloseButton, Aurora.Theme.CornerRadius.Small)
    
    -- ═══ Create Sidebar (Tab Navigation) ═══
    -- [EXPLANATION]
    -- The sidebar contains tab buttons for navigation between sections.
    -- It uses a vertical list layout for tab buttons.
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, Aurora.Theme.SidebarWidth, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainWindow
    Aurora.Components:CreateCorner(Sidebar, Aurora.Theme.CornerRadius.Window)
    
    -- Sidebar content container
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
    Aurora.Components:CreatePadding(SidebarContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
    Aurora.Components:CreateListLayout(SidebarContent, Enum.FillDirection.Vertical, UDim.new(0, 6))
    
    -- ═══ Create Main Content Area ═══
    -- [EXPLANATION]
    -- The content area displays the active tab's content.
    -- It's positioned next to the sidebar.
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -Aurora.Theme.SidebarWidth, 1, -50)
    ContentArea.Position = UDim2.new(0, Aurora.Theme.SidebarWidth, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainWindow
    
    -- Content container with scrolling
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
    Aurora.Components:CreatePadding(ContentContainer, UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8))
    Aurora.Components:CreateListLayout(ContentContainer, Enum.FillDirection.Vertical, UDim.new(0, 12))
    
    -- ═══ Create Minimized State UI ═══
    -- [EXPLANATION]
    -- When minimized, the window transforms into a small floating pill.
    -- This maintains visual presence while being out of the way.
    
    local MinimizedPill = Instance.new("Frame")
    MinimizedPill.Name = "MinimizedPill"
    MinimizedPill.Size = UDim2.new(0, 150, 0, 44)
    MinimizedPill.Position = UDim2.new(1, -170, 1, -60)
    MinimizedPill.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
    MinimizedPill.BackgroundTransparency = 0.1
    MinimizedPill.BorderSizePixel = 0
    MinimizedPill.Visible = false
    MinimizedPill.Parent = ScreenGui
    Aurora.Components:CreateCorner(MinimizedPill, Aurora.Theme.CornerRadius.Pill)
    Aurora.Components:CreateStroke(MinimizedPill, Aurora.Theme.GlassBorder, 0.7)
    
    -- Pill accent line
    local PillAccent = Instance.new("Frame")
    PillAccent.Name = "Accent"
    PillAccent.Size = UDim2.new(0, 3, 0.6, 0)
    PillAccent.Position = UDim2.new(0, 6, 0.2, 0)
    PillAccent.BackgroundColor3 = AccentColor
    PillAccent.BackgroundTransparency = 0
    PillAccent.BorderSizePixel = 0
    PillAccent.Parent = MinimizedPill
    Aurora.Components:CreateCorner(PillAccent, UDim.new(0, 2))
    
    -- Pill text
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
    
    -- Pill expand button (whole pill is clickable)
    local PillButton = Instance.new("TextButton")
    PillButton.Name = "ExpandButton"
    PillButton.Size = UDim2.new(1, 0, 1, 0)
    PillButton.Position = UDim2.new(0, 0, 0, 0)
    PillButton.BackgroundTransparency = 1
    PillButton.Text = ""
    PillButton.BorderSizePixel = 0
    PillButton.Parent = MinimizedPill
    
    -- ═══ State Management ═══
    -- [EXPLANATION]
    -- Window state tracks the current state of the UI for persistence.
    
    local WindowState = {
        IsMinimized = false,
        ActiveTab = nil,
        Tabs = {},
        Components = {},
        ScrollPositions = {},
        ToggleStates = {},
    }
    
    -- ═══ Dragging System ═══
    -- [EXPLANATION]
    -- Allows the window to be dragged by clicking and holding the title bar.
    -- Uses UserInputService for smooth mouse tracking.
    
    local Dragging = false
    local DragStart, StartPosition
    
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainWindow.Position
            
            -- Bring to front
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
                local NewPosition = UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset + Delta.X,
                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset + Delta.Y
                )
                MainWindow.Position = NewPosition
            end
        end)
    end
    
    -- ═══ Minimize/Restore System ═══
    -- [EXPLANATION]
    -- Handles the minimize animation and state preservation.
    -- When minimized, all state is saved and restored on expand.
    
    local function MinimizeWindow()
        if WindowState.IsMinimized then return end
        
        -- Save current state
        WindowState.ScrollPositions = {}
        for _, Tab in ipairs(WindowState.Tabs) do
            if Tab.Content then
                WindowState.ScrollPositions[Tab.Name] = Tab.Content.CanvasPosition
            end
        end
        
        -- Animate minimize
        Aurora.Animation:FadeScale(MainWindow, 0.8, 0.5, Aurora.Theme.AnimationDuration.Normal, function()
            MainWindow.Visible = false
            MinimizedPill.Visible = true
            
            -- Animate pill entrance
            MinimizedPill.Position = UDim2.new(1, -170, 1, -60)
            Aurora.Animation:Scale(MinimizedPill, 0.9, 0)
            Aurora.Animation:Scale(MinimizedPill, 1, Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
        end)
        
        WindowState.IsMinimized = true
    end
    
    local function RestoreWindow()
        if not WindowState.IsMinimized then return end
        
        -- Animate pill exit
        Aurora.Animation:Scale(MinimizedPill, 0.9, Aurora.Theme.AnimationDuration.Fast, Enum.EasingStyle.Quad, function()
            MinimizedPill.Visible = false
            
            -- Show and animate main window
            MainWindow.Visible = true
            Aurora.Animation:Scale(MainWindow, 0.9, 0)
            Aurora.Animation:Scale(MainWindow, 1, Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
            Aurora.Animation:Fade(MainWindow, 0, Aurora.Theme.AnimationDuration.Normal)
            
            -- Restore scroll positions
            for _, Tab in ipairs(WindowState.Tabs) do
                if Tab.Content and WindowState.ScrollPositions[Tab.Name] then
                    Tab.Content.CanvasPosition = WindowState.ScrollPositions[Tab.Name]
                end
            end
        end)
        
        WindowState.IsMinimized = false
    end
    
    -- Connect button events
    MinimizeButton.MouseButton1Click:Connect(MinimizeWindow)
    CloseButton.MouseButton1Click:Connect(function()
        -- Animate out
        Aurora.Animation:FadeScale(MainWindow, 0.9, 0.8, Aurora.Theme.AnimationDuration.Normal, function()
            ScreenGui:Destroy()
        end)
    end)
    
    PillButton.MouseButton1Click:Connect(RestoreWindow)
    
    -- ═══ Tab System ═══
    -- [EXPLANATION]
    -- Tabs allow organizing content into separate sections.
    -- Each tab has a button in the sidebar and a content area.
    
    local TabCount = 0
    local ActiveTabButton = nil
    
    local function CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        local TabName = TabConfig.Name or "Tab " .. tostring(TabCount + 1)
        local TabIcon = TabConfig.Icon
        
        TabCount = TabCount + 1
        
        -- Create tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, Aurora.Theme.TabHeight)
        TabButton.BackgroundColor3 = Aurora.Theme.BackgroundTertiary
        TabButton.BackgroundTransparency = 0.5
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0
        TabButton.LayoutOrder = TabCount
        TabButton.Parent = SidebarContent
        Aurora.Components:CreateCorner(TabButton, Aurora.Theme.CornerRadius.Button)
        
        -- Tab button content container
        local TabButtonContent = Instance.new("Frame")
        TabButtonContent.Size = UDim2.new(1, -8, 1, 0)
        TabButtonContent.Position = UDim2.new(0, 4, 0, 0)
        TabButtonContent.BackgroundTransparency = 1
        TabButtonContent.BorderSizePixel = 0
        TabButtonContent.Parent = TabButton
        
        -- Tab icon (if provided)
        local IconOffset = 0
        if TabIcon then
            local IconLabel = Instance.new("TextLabel")
            IconLabel.Size = UDim2.new(0, 20, 0, 20)
            IconLabel.Position = UDim2.new(0, 4, 0.5, -10)
            IconLabel.Text = TabIcon
            IconLabel.Font = Aurora.Theme.Font.Body
            IconLabel.TextSize = 14
            IconLabel.TextColor3 = Aurora.Theme.TextSecondary
            IconLabel.BackgroundTransparency = 1
            IconLabel.Parent = TabButtonContent
            IconOffset = 24
        end
        
        -- Tab name label
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -IconOffset - 8, 1, 0)
        TabLabel.Position = UDim2.new(0, IconOffset + 4, 0, 0)
        TabLabel.Text = TabName
        TabLabel.Font = Aurora.Theme.Font.Body
        TabLabel.TextSize = Aurora.Theme.FontSize.Body
        TabLabel.TextColor3 = Aurora.Theme.TextSecondary
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Parent = TabButtonContent
        
        -- Tab selection indicator
        local SelectionIndicator = Instance.new("Frame")
        SelectionIndicator.Name = "Indicator"
        SelectionIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        SelectionIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        SelectionIndicator.BackgroundColor3 = AccentColor
        SelectionIndicator.BackgroundTransparency = 1
        SelectionIndicator.BorderSizePixel = 0
        SelectionIndicator.Parent = TabButton
        Aurora.Components:CreateCorner(SelectionIndicator, UDim.new(0, 2))
        
        -- Create tab content container
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
        Aurora.Components:CreatePadding(TabContent, UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
        Aurora.Components:CreateListLayout(TabContent, Enum.FillDirection.Vertical, UDim.new(0, 8))
        
        -- Tab state
        local Tab = {
            Name = TabName,
            Button = TabButton,
            Content = TabContent,
            Sections = {},
            SectionCount = 0,
        }
        
        -- Tab selection logic
        local function SelectTab()
            -- Deselect all tabs
            for _, OtherTab in ipairs(WindowState.Tabs) do
                OtherTab.Content.Visible = false
                Aurora.Animation:Play(OtherTab.Button, {
                    BackgroundTransparency = 0.5
                }, Aurora.Theme.AnimationDuration.Fast)
                OtherTab.Button.Indicator.BackgroundTransparency = 1
                OtherTab.Button:FindFirstChild("Label", true).TextColor3 = Aurora.Theme.TextSecondary
            end
            
            -- Select this tab
            TabContent.Visible = true
            Aurora.Animation:Play(TabButton, {
                BackgroundTransparency = 0.2
            }, Aurora.Theme.AnimationDuration.Fast)
            Aurora.Animation:Play(TabButton.Indicator, {
                BackgroundTransparency = 0
            }, Aurora.Theme.AnimationDuration.Fast)
            TabButton:FindFirstChild("Label", true).TextColor3 = Aurora.Theme.TextPrimary
            
            WindowState.ActiveTab = Tab
            
            -- Update content container canvas size
            task.defer(function()
                local Layout = TabContent:FindFirstChildOfClass("UIListLayout")
                if Layout then
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
                end
            end)
        end
        
        TabButton.MouseButton1Click:Connect(SelectTab)
        
        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if WindowState.ActiveTab ~= Tab then
                Aurora.Animation:Play(TabButton, {
                    BackgroundTransparency = 0.3
                }, Aurora.Theme.AnimationDuration.Fast)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if WindowState.ActiveTab ~= Tab then
                Aurora.Animation:Play(TabButton, {
                    BackgroundTransparency = 0.5
                }, Aurora.Theme.AnimationDuration.Fast)
            end
        end)
        
        -- ═══ Section System ═══
        -- [EXPLANATION]
        -- Sections are glass card containers within tabs for organizing components.
        
        local function CreateSection(SectionConfig)
            SectionConfig = SectionConfig or {}
            local SectionName = SectionConfig.Name or "Section"
            
            Tab.SectionCount = Tab.SectionCount + 1
            
            -- Create glass card container
            local SectionCard = Instance.new("Frame")
            SectionCard.Name = SectionName
            SectionCard.Size = UDim2.new(1, 0, 0, 0)
            SectionCard.AutomaticSize = Enum.AutomaticSize.Y
            SectionCard.BackgroundColor3 = Aurora.Theme.GlassBackground
            SectionCard.BackgroundTransparency = Aurora.Theme.GlassBackgroundTransparency
            SectionCard.BorderSizePixel = 0
            SectionCard.LayoutOrder = Tab.SectionCount
            SectionCard.Parent = TabContent
            Aurora.Components:CreateCorner(SectionCard, Aurora.Theme.CornerRadius.Card)
            Aurora.Components:CreateStroke(SectionCard, Aurora.Theme.GlassBorder, Aurora.Theme.GlassBorderTransparency)
            
            -- Section content container
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.Parent = SectionCard
            Aurora.Components:CreatePadding(SectionContent, UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12))
            Aurora.Components:CreateListLayout(SectionContent, Enum.FillDirection.Vertical, UDim.new(0, Aurora.Theme.ComponentSpacing))
            
            -- Section header
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
            
            -- Divider line
            local Divider = Instance.new("Frame")
            Divider.Name = "Divider"
            Divider.Size = UDim2.new(1, 0, 0, 1)
            Divider.BackgroundColor3 = Aurora.Theme.Divider
            Divider.BackgroundTransparency = 0.5
            Divider.BorderSizePixel = 0
            Divider.Parent = SectionContent
            
            -- Component container
            local ComponentContainer = Instance.new("Frame")
            ComponentContainer.Name = "Components"
            ComponentContainer.Size = UDim2.new(1, 0, 0, 0)
            ComponentContainer.AutomaticSize = Enum.AutomaticSize.Y
            ComponentContainer.BackgroundTransparency = 1
            ComponentContainer.BorderSizePixel = 0
            ComponentContainer.Parent = SectionContent
            Aurora.Components:CreateListLayout(ComponentContainer, Enum.FillDirection.Vertical, UDim.new(0, Aurora.Theme.ComponentSpacing))
            
            -- Update canvas size on content change
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
            
            -- Section object
            local Section = {
                Name = SectionName,
                Card = SectionCard,
                Container = ComponentContainer,
                ComponentCount = 0,
            }
            
            -- ═══ Component Factories ═══
            -- [EXPLANATION]
            -- These functions create the various UI components that users
            -- can add to sections. Each follows a consistent pattern.
            
            -- Add Button Component
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
                
                -- Hover effects
                Button.MouseEnter:Connect(function()
                    Aurora.Animation:Play(Button, {
                        BackgroundTransparency = 0.1
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                Button.MouseLeave:Connect(function()
                    Aurora.Animation:Play(Button, {
                        BackgroundTransparency = 0.2
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                -- Click animation
                Button.MouseButton1Down:Connect(function()
                    Aurora.Animation:Play(Button, {
                        BackgroundColor3 = AccentColor,
                        BackgroundTransparency = 0.5
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Aurora.Animation:Play(Button, {
                        BackgroundColor3 = Aurora.Theme.BackgroundTertiary
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                Button.MouseButton1Click:Connect(Callback)
                
                return Button
            end
            
            -- Add Toggle Component
            function Section:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                local ToggleTitle = ToggleConfig.Title or "Toggle"
                local DefaultValue = ToggleConfig.Default or false
                local Callback = ToggleConfig.Callback or function() end
                
                self.ComponentCount = self.ComponentCount + 1
                
                -- Restore saved state if exists
                local StateKey = ToggleTitle .. "_" .. self.Name
                local SavedValue = Aurora.State:Load(StateKey, DefaultValue)
                
                local ToggleValue = SavedValue
                
                local Container = Instance.new("Frame")
                Container.Name = "Toggle_" .. self.ComponentCount
                Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.LayoutOrder = self.ComponentCount
                Container.Parent = self.Container
                
                -- Title label
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(1, -60, 1, 0)
                TitleLabel.Position = UDim2.new(0, 0, 0, 0)
                TitleLabel.Text = ToggleTitle
                TitleLabel.Font = Aurora.Theme.Font.Body
                TitleLabel.TextSize = Aurora.Theme.FontSize.Body
                TitleLabel.TextColor3 = Aurora.Theme.TextPrimary
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Parent = Container
                
                -- Toggle switch background
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
                
                -- Toggle knob
                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.new(0, 18, 0, 18)
                Knob.Position = UDim2.new(ToggleValue and 1 or 0, ToggleValue and -21 or 3, 0.5, -9)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BackgroundTransparency = 0
                Knob.BorderSizePixel = 0
                Knob.Parent = ToggleSwitch
                Aurora.Components:CreateCorner(Knob, UDim.new(0, 10))
                
                -- Toggle logic
                local function UpdateToggle(Value, Animate)
                    Animate = Animate ~= false
                    ToggleValue = Value
                    Aurora.State:Save(StateKey, Value)
                    
                    if Animate then
                        -- Animate background color
                        Aurora.Animation:Play(ToggleSwitch, {
                            BackgroundColor3 = Value and AccentColor or Aurora.Theme.BackgroundQuaternary
                        }, Aurora.Theme.AnimationDuration.Fast)
                        
                        -- Animate knob position
                        Aurora.Animation:Play(Knob, {
                            Position = UDim2.new(Value and 1 or 0, Value and -21 or 3, 0.5, -9)
                        }, Aurora.Theme.AnimationDuration.Fast, Enum.EasingStyle.Quad)
                    else
                        ToggleSwitch.BackgroundColor3 = Value and AccentColor or Aurora.Theme.BackgroundQuaternary
                        Knob.Position = UDim2.new(Value and 1 or 0, Value and -21 or 3, 0.5, -9)
                    end
                end
                
                -- Set initial state without animation
                UpdateToggle(ToggleValue, false)
                
                ToggleSwitch.MouseButton1Click:Connect(function()
                    UpdateToggle(not ToggleValue, true)
                    Callback(ToggleValue)
                end)
                
                -- Return toggle object with SetValue method
                return {
                    SetValue = function(self, Value)
                        UpdateToggle(Value, true)
                        Callback(Value)
                    end,
                    GetValue = function()
                        return ToggleValue
                    end
                }
            end
            
            -- Add Slider Component
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
                
                -- Title and value display
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
                
                -- Slider track
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
                
                -- Slider fill
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((SliderValue - MinValue) / (MaxValue - MinValue), 0, 1, 0)
                SliderFill.BackgroundColor3 = AccentColor
                SliderFill.BackgroundTransparency = 0.1
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                Aurora.Components:CreateCorner(SliderFill, Aurora.Theme.CornerRadius.Small)
                Aurora.Components:CreateGradient(SliderFill, nil, 0)
                
                -- Slider knob
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Name = "Knob"
                SliderKnob.Size = UDim2.new(0, 16, 0, 16)
                SliderKnob.Position = UDim2.new((SliderValue - MinValue) / (MaxValue - MinValue), -8, 0.5, -8)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderKnob.BackgroundTransparency = 0
                SliderKnob.BorderSizePixel = 0
                SliderKnob.Parent = SliderTrack
                Aurora.Components:CreateCorner(SliderKnob, UDim.new(0, 8))
                
                -- Slider interaction
                local DraggingSlider = false
                
                local function UpdateSlider(X, Animate)
                    local RelativeX = math.clamp((X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local NewValue = MinValue + (MaxValue - MinValue) * RelativeX
                    NewValue = Utility.Round(NewValue, Decimals)
                    NewValue = Utility.Clamp(NewValue, MinValue, MaxValue)
                    
                    SliderValue = NewValue
                    local Percent = (SliderValue - MinValue) / (MaxValue - MinValue)
                    
                    if Animate then
                        Aurora.Animation:Play(SliderFill, {
                            Size = UDim2.new(Percent, 0, 1, 0)
                        }, Aurora.Theme.AnimationDuration.Fast)
                        Aurora.Animation:Play(SliderKnob, {
                            Position = UDim2.new(Percent, -8, 0.5, -8)
                        }, Aurora.Theme.AnimationDuration.Fast)
                    else
                        SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(Percent, -8, 0.5, -8)
                    end
                    
                    ValueLabel.Text = tostring(Utility.Round(SliderValue, Decimals)) .. Suffix
                end
                
                SliderTrack.MouseButton1Down:Connect(function()
                    DraggingSlider = true
                    UpdateSlider(LocalMouse.X, true)
                end)
                
                if Services.UserInputService then
                    Services.UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if DraggingSlider then
                                DraggingSlider = false
                                Callback(SliderValue)
                            end
                        end
                    end)
                    
                    Services.UserInputService.InputChanged:Connect(function(Input)
                        if DraggingSlider and (Input.UserInputType == Enum.UserInputType.MouseMovement) then
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
                    GetValue = function()
                        return SliderValue
                    end
                }
            end
            
            -- Add Dropdown Component
            function Section:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                local DropdownTitle = DropdownConfig.Title or "Dropdown"
                local Options = DropdownConfig.Options or { "Option 1", "Option 2", "Option 3" }
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
                
                -- Dropdown header
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
                
                -- Options container
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Name = "Options"
                OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                OptionsContainer.Position = UDim2.new(0, 0, 0, Aurora.Theme.ComponentHeight)
                OptionsContainer.BackgroundTransparency = 1
                OptionsContainer.BorderSizePixel = 0
                OptionsContainer.Parent = Container
                Aurora.Components:CreateListLayout(OptionsContainer, Enum.FillDirection.Vertical, UDim.new(0, 2))
                
                -- Create option buttons
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
                        
                        -- Update all options visual
                        for _, Child in ipairs(OptionsContainer:GetChildren()) do
                            if Child:IsA("TextButton") then
                                Aurora.Animation:Play(Child, {
                                    BackgroundColor3 = Child.Name == Option and AccentColor or Aurora.Theme.BackgroundQuaternary,
                                    BackgroundTransparency = Child.Name == Option and 0.3 or 0.4
                                }, Aurora.Theme.AnimationDuration.Fast)
                            end
                        end
                        
                        -- Close dropdown
                        CloseDropdown()
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        if Option ~= SelectedOption then
                            Aurora.Animation:Play(OptionButton, {
                                BackgroundTransparency = 0.2
                            }, Aurora.Theme.AnimationDuration.Fast)
                        end
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        if Option ~= SelectedOption then
                            Aurora.Animation:Play(OptionButton, {
                                BackgroundTransparency = 0.4
                            }, Aurora.Theme.AnimationDuration.Fast)
                        end
                    end)
                end
                
                -- Calculate options container size
                local OptionsHeight = #Options * 34
                OptionsContainer.Size = UDim2.new(1, -4, 0, OptionsHeight)
                OptionsContainer.Position = UDim2.new(0, 2, 0, Aurora.Theme.ComponentHeight)
                
                local function OpenDropdown()
                    DropdownOpen = true
                    Container.Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight + OptionsHeight + 4)
                    Aurora.Animation:Play(ArrowLabel, {
                        Rotation = 180
                    }, Aurora.Theme.AnimationDuration.Fast)
                end
                
                local function CloseDropdown()
                    DropdownOpen = false
                    Aurora.Animation:Play(Container, {
                        Size = UDim2.new(1, 0, 0, Aurora.Theme.ComponentHeight)
                    }, Aurora.Theme.AnimationDuration.Fast)
                    Aurora.Animation:Play(ArrowLabel, {
                        Rotation = 0
                    }, Aurora.Theme.AnimationDuration.Fast)
                end
                
                Header.MouseButton1Click:Connect(function()
                    if DropdownOpen then
                        CloseDropdown()
                    else
                        OpenDropdown()
                    end
                end)
                
                return {
                    SetOption = function(self, Option)
                        if table.find(Options, Option) then
                            SelectedOption = Option
                            TitleLabel.Text = Option
                            Callback(Option)
                        end
                    end,
                    GetOption = function()
                        return SelectedOption
                    end
                }
            end
            
            -- Add Textbox Component
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
                
                -- Focus effects
                Textbox.Focused:Connect(function()
                    Aurora.Animation:Play(TextboxFrame, {
                        BackgroundTransparency = 0
                    }, Aurora.Theme.AnimationDuration.Fast)
                end)
                
                Textbox.FocusLost:Connect(function(EnterPressed)
                    Aurora.Animation:Play(TextboxFrame, {
                        BackgroundTransparency = 0.2
                    }, Aurora.Theme.AnimationDuration.Fast)
                    Callback(Textbox.Text, EnterPressed)
                end)
                
                return {
                    SetValue = function(self, Value)
                        Textbox.Text = Value
                    end,
                    GetValue = function()
                        return Textbox.Text
                    end
                }
            end
            
            -- Add Keybind Component
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
                    GetKey = function()
                        return CurrentKey
                    end
                }
            end
            
            -- Add Label Component
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
                    SetText = function(self, Text)
                        Label.Text = Text
                    end
                }
            end
            
            -- Add Paragraph Component
            function Section:AddParagraph(ParagraphConfig)
                ParagraphConfig = ParagraphConfig or {}
                local ParagraphTitle = ParagraphConfig.Title or ""
                local ParagraphText = ParagraphConfig.Text or "Paragraph text goes here..."
                
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
                    SetText = function(self, Text)
                        TextLabel.Text = Text
                    end
                }
            end
            
            -- Add Divider Component
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
        
        -- Add CreateSection to Tab
        Tab.CreateSection = CreateSection
        
        table.insert(WindowState.Tabs, Tab)
        
        -- Auto-select first tab
        if #WindowState.Tabs == 1 then
            SelectTab()
        end
        
        return Tab
    end
    
    -- Add CreateTab to Window
    local Window = {
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        MinimizedPill = MinimizedPill,
        State = WindowState,
        AccentColor = AccentColor,
    }
    
    Window.CreateTab = CreateTab
    
    -- ═══ Toast/Notification System ═══
    -- [EXPLANATION]
    -- Toast notifications appear at the top-right of the screen
    -- and automatically dismiss after a duration.
    
    local ToastContainer = Instance.new("Frame")
    ToastContainer.Name = "ToastContainer"
    ToastContainer.Size = UDim2.new(0, 300, 1, -20)
    ToastContainer.Position = UDim2.new(1, -320, 0, 10)
    ToastContainer.BackgroundTransparency = 1
    ToastContainer.BorderSizePixel = 0
    ToastContainer.Parent = ScreenGui
    Aurora.Components:CreateListLayout(ToastContainer, Enum.FillDirection.Vertical, UDim.new(0, 8))
    
    function Window:Notify(NotifyConfig)
        NotifyConfig = NotifyConfig or {}
        local Title = NotifyConfig.Title or "Notification"
        local Message = NotifyConfig.Message or ""
        local Duration = NotifyConfig.Duration or 5
        local NotifyType = NotifyConfig.Type or "info" -- info, success, warning, error
        
        local NotifyColor = Aurora.Theme.Info
        if NotifyType == "success" then
            NotifyColor = Aurora.Theme.Success
        elseif NotifyType == "warning" then
            NotifyColor = Aurora.Theme.Warning
        elseif NotifyType == "error" then
            NotifyColor = Aurora.Theme.Error
        end
        
        local Toast = Instance.new("Frame")
        Toast.Name = "Toast"
        Toast.Size = UDim2.new(1, 0, 0, 0)
        Toast.AutomaticSize = Enum.AutomaticSize.Y
        Toast.BackgroundColor3 = Aurora.Theme.BackgroundSecondary
        Toast.BackgroundTransparency = 0.1
        Toast.BorderSizePixel = 0
        Toast.Parent = ToastContainer
        Aurora.Components:CreateCorner(Toast, Aurora.Theme.CornerRadius.Card)
        Aurora.Components:CreateStroke(Toast, Aurora.Theme.GlassBorder, 0.7)
        
        -- Accent line
        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(0, 3, 1, 0)
        AccentLine.BackgroundColor3 = NotifyColor
        AccentLine.BackgroundTransparency = 0
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = Toast
        Aurora.Components:CreateCorner(AccentLine, UDim.new(0, 2))
        
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
        
        -- Padding at bottom
        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 8)
        Padding.Parent = Content
        
        -- Entrance animation
        Toast.Position = UDim2.new(1, 0, 0, 0)
        Aurora.Animation:Slide(Toast, UDim2.new(0, 0, 0, 0), Aurora.Theme.AnimationDuration.Normal, Enum.EasingStyle.Back)
        
        -- Auto dismiss
        task.delay(Duration, function()
            Aurora.Animation:Fade(Toast, 1, Aurora.Theme.AnimationDuration.Normal)
            Aurora.Animation:Slide(Toast, UDim2.new(0.2, 0, 0, 0), Aurora.Theme.AnimationDuration.Normal, nil, function()
                Toast:Destroy()
            end)
        end)
    end
    
    -- ═══ System Info Panel Helper ═══
    -- [EXPLANATION]
    -- This function creates a pre-built info panel with system information.
    
    function Window:CreateSystemInfoTab()
        local Tab = self:CreateTab({ Name = "System", Icon = "⚡" })
        
        -- Environment Section
        local EnvSection = Tab:CreateSection("Environment")
        local ExecutorInfo = Aurora.InfoProvider:GetExecutorInfo()
        
        EnvSection:AddLabel({ Text = "Executor: " .. ExecutorInfo.Name })
        EnvSection:AddLabel({ Text = "Version: " .. ExecutorInfo.Version })
        EnvSection:AddLabel({ Text = "Environment: " .. ExecutorInfo.Environment })
        
        -- Game Section
        local GameSection = Tab:CreateSection("Game")
        local GameInfo = Aurora.InfoProvider:GetGameInfo()
        
        GameSection:AddLabel({ Text = "Game: " .. GameInfo.Name })
        GameSection:AddLabel({ Text = "GameId: " .. GameInfo.GameId })
        GameSection:AddLabel({ Text = "PlaceId: " .. GameInfo.PlaceId })
        GameSection:AddLabel({ Text = "JobId: " .. GameInfo.JobId })
        GameSection:AddLabel({ Text = "Server: " .. GameInfo.ServerType })
        GameSection:AddLabel({ Text = "Players: " .. GameInfo.PlayerCount .. "/" .. GameInfo.MaxPlayers })
        
        -- Player Section
        local PlayerSection = Tab:CreateSection("Player")
        local PlayerInfo = Aurora.InfoProvider:GetPlayerInfo()
        
        PlayerSection:AddLabel({ Text = "Username: " .. PlayerInfo.Username })
        PlayerSection:AddLabel({ Text = "Display Name: " .. PlayerInfo.DisplayName })
        PlayerSection:AddLabel({ Text = "UserId: " .. PlayerInfo.UserId })
        PlayerSection:AddLabel({ Text = "Account Age: " .. PlayerInfo.AccountAge })
        PlayerSection:AddLabel({ Text = "Membership: " .. PlayerInfo.Membership })
        
        -- Session Section (with live updates)
        local SessionSection = Tab:CreateSection("Session")
        
        local TimeLabel = SessionSection:AddLabel({ Text = "Local Time: --:--:--" })
        local RuntimeLabel = SessionSection:AddLabel({ Text = "Runtime: 00:00:00" })
        local LoadedLabel = SessionSection:AddLabel({ Text = "UI Loaded: " .. Aurora.InfoProvider:GetSessionInfo().UILoadedTimestamp })
        
        -- Live updating
        task.spawn(function()
            while ScreenGui and ScreenGui.Parent do
                local SessionInfo = Aurora.InfoProvider:GetSessionInfo()
                TimeLabel.SetText("Local Time: " .. SessionInfo.CurrentTimeFormatted)
                RuntimeLabel.SetText("Runtime: " .. SessionInfo.RuntimeFormatted)
                task.wait(1)
            end
        end)
        
        return Tab
    end
    
    -- Track this window
    table.insert(Aurora.Windows, Window)
    Aurora.ActiveWindow = Window
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API: CreateWindow Alias
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- This is the main entry point for users. They call Aurora:CreateWindow()
-- which internally calls Core:CreateWindow().

function Aurora:CreateWindow(Config)
    return Aurora.Core:CreateWindow(Config)
end

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE USAGE
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- This example demonstrates how to use Aurora Library.
-- It creates a complete UI with multiple tabs and components.
-- Uncomment to test the library.

--[[
local UI = Aurora:CreateWindow({
    Title = "Aurora Library",
    Subtitle = "Modern Futuristic UI",
    Accent = Color3.fromRGB(100, 200, 255),
    Size = UDim2.new(0, 520, 0, 450)
})

-- Create System Info Tab (built-in)
UI:CreateSystemInfoTab()

-- Create Settings Tab
local SettingsTab = UI:CreateTab({ Name = "Settings", Icon = "⚙" })
local GeneralSection = SettingsTab:CreateSection("General")

GeneralSection:AddToggle({
    Title = "Enabled",
    Default = false,
    Callback = function(Value)
        print("Toggle:", Value)
    end
})

GeneralSection:AddSlider({
    Title = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 1,
    Suffix = " studs/s",
    Callback = function(Value)
        print("Slider:", Value)
    end
})

GeneralSection:AddDropdown({
    Title = "Mode",
    Options = { "Normal", "Fast", "Instant" },
    Default = "Normal",
    Callback = function(Value)
        print("Dropdown:", Value)
    end
})

-- Create Actions Tab
local ActionsTab = UI:CreateTab({ Name = "Actions", Icon = "▶" })
local MainSection = ActionsTab:CreateSection("Main Actions")

MainSection:AddButton({
    Text = "Execute Script",
    Callback = function()
        UI:Notify({
            Title = "Success",
            Message = "Script executed successfully!",
            Type = "success",
            Duration = 3
        })
    end
})

MainSection:AddButton({
    Text = "Reset Settings",
    Callback = function()
        UI:Notify({
            Title = "Warning",
            Message = "Settings have been reset.",
            Type = "warning",
            Duration = 3
        })
    end
})

local InputSection = ActionsTab:CreateSection("Input")

InputSection:AddTextbox({
    Title = "Command",
    Placeholder = "Enter command...",
    Default = "",
    Callback = function(Text, EnterPressed)
        if EnterPressed then
            print("Command:", Text)
        end
    end
})

InputSection:AddKeybind({
    Title = "Toggle Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(Key)
        print("Keybind pressed:", Key.Name)
    end
})

-- Create Info Tab
local InfoTab = UI:CreateTab({ Name = "Info", Icon = "ℹ" })
local AboutSection = InfoTab:CreateSection("About Aurora Library")

AboutSection:AddParagraph({
    Title = "Aurora Library",
    Text = "A modern, futuristic Roblox UI library featuring glassmorphism aesthetics, smooth animations, and a premium user experience. Designed for learning and educational purposes."
})

AboutSection:AddDivider()

AboutSection:AddLabel({ Text = "Version: 1.0.0" })
AboutSection:AddLabel({ Text = "Author: Aurora Development Team" })

-- Show welcome notification
UI:Notify({
    Title = "Welcome",
    Message = "Aurora Library has been loaded successfully!",
    Type = "info",
    Duration = 4
})
--]]

-- ═══════════════════════════════════════════════════════════════
-- RETURN AURORA LIBRARY
-- ═══════════════════════════════════════════════════════════════

-- [EXPLANATION]
-- Return the Aurora table so it can be loaded with loadstring()
-- Usage: local Aurora = loadstring(game:HttpGet(url))()

return Aurora
