local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ═════════════════════════════════════════════════════════════════
-- STATE MANAGER MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    StateManager - Reactive State System
    
    Provides centralized state management with subscriptions.
    Inspired by modern frontend frameworks like React/Redux.
]]

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new(initialState)
    local self = setmetatable({}, StateManager)
    self._state = {}
    self._subscribers = {}
    self._globalSubscribers = {}
    self._history = {}
    self._maxHistorySize = 50
    self._id = HttpService:GenerateGUID(false)
    
    if initialState then
        for key, value in pairs(initialState) do
            self._state[key] = value
        end
    end
    
    return self
end

function StateManager:Get(key, defaultValue)
    if self._state[key] ~= nil then
        return self._state[key]
    end
    return defaultValue
end

function StateManager:Set(key, value, silent)
    local oldValue = self._state[key]
    if oldValue == value then return self end
    
    table.insert(self._history, {
        timestamp = os.clock(),
        key = key,
        oldValue = oldValue,
        newValue = value
    })
    
    if #self._history > self._maxHistorySize then
        table.remove(self._history, 1)
    end
    
    self._state[key] = value
    
    if not silent then
        self:_notifySubscribers(key, value, oldValue)
        self:_notifyGlobalSubscribers(key, value, oldValue)
    end
    
    return self
end

function StateManager:Update(key, updater)
    local oldValue = self:Get(key)
    local newValue = updater(oldValue)
    return self:Set(key, newValue)
end

function StateManager:Delete(key)
    local oldValue = self._state[key]
    self._state[key] = nil
    if oldValue ~= nil then
        self:_notifySubscribers(key, nil, oldValue)
    end
    return self
end

function StateManager:Has(key)
    return self._state[key] ~= nil
end

function StateManager:Subscribe(key, callback)
    if not self._subscribers[key] then
        self._subscribers[key] = {}
    end
    local subscriberId = HttpService:GenerateGUID(false)
    self._subscribers[key][subscriberId] = callback
    return function()
        if self._subscribers[key] then
            self._subscribers[key][subscriberId] = nil
        end
    end
end

function StateManager:SubscribeAll(callback)
    local subscriberId = HttpService:GenerateGUID(false)
    self._globalSubscribers[subscriberId] = callback
    return function()
        self._globalSubscribers[subscriberId] = nil
    end
end

function StateManager:_notifySubscribers(key, newValue, oldValue)
    local subscribers = self._subscribers[key]
    if not subscribers then return end
    for _, callback in pairs(subscribers) do
        local success, err = pcall(callback, newValue, oldValue)
        if not success then
            warn("[StateManager] Subscriber callback error:", err)
        end
    end
end

function StateManager:_notifyGlobalSubscribers(key, newValue, oldValue)
    for _, callback in pairs(self._globalSubscribers) do
        local success, err = pcall(callback, key, newValue, oldValue)
        if not success then
            warn("[StateManager] Global subscriber callback error:", err)
        end
    end
end

function StateManager:SetMultiple(stateTable)
    for key, value in pairs(stateTable) do
        self:Set(key, value)
    end
    return self
end

function StateManager:GetAll()
    local copy = {}
    for key, value in pairs(self._state) do
        copy[key] = value
    end
    return copy
end

function StateManager:Serialize()
    local serializable = {}
    for key, value in pairs(self._state) do
        local valueType = typeof(value)
        if valueType == "string" or valueType == "number" or valueType == "boolean" or valueType == "table" then
            serializable[key] = value
        end
    end
    return HttpService:JSONEncode(serializable)
end

function StateManager:Deserialize(jsonString)
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, jsonString)
    if success and type(decoded) == "table" then
        for key, value in pairs(decoded) do
            self:Set(key, value)
        end
    end
    return self
end

function StateManager:Destroy()
    self._state = {}
    self._subscribers = {}
    self._globalSubscribers = {}
    self._history = {}
end

-- ═════════════════════════════════════════════════════════════════
-- ANIMATION ENGINE MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    AnimationEngine - Centralized Animation System
    
    Premium animations with curated easings.
    No instant show/hide - everything animates with intention.
]]

local EasingPresets = {
    Smooth = { EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.InOut },
    EaseIn = { EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.In },
    EaseOut = { EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out },
    EaseInOut = { EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.InOut },
    Snappy = { EasingStyle = Enum.EasingStyle.Quart, EasingDirection = Enum.EasingDirection.Out },
    Gentle = { EasingStyle = Enum.EasingStyle.Sine, EasingDirection = Enum.EasingDirection.Out },
    Quick = { EasingStyle = Enum.EasingStyle.Linear, EasingDirection = Enum.EasingDirection.InOut }
}

local TimingPresets = {
    Instant = 0.1, Fast = 0.15, Normal = 0.25, Slow = 0.4, Dramatic = 0.6, BootSequence = 0.8
}

local AnimationEngine = {}
AnimationEngine.__index = AnimationEngine

function AnimationEngine.new()
    local self = setmetatable({}, AnimationEngine)
    self._activeTweens = {}
    self._activeThreads = {}
    self._enabled = true
    self._reducedMotion = false
    self._timeScale = 1.0
    return self
end

function AnimationEngine:Tween(object, properties, config)
    config = config or {}
    local duration = (config.Duration or TimingPresets.Normal) * self._timeScale
    if self._reducedMotion then duration = math.min(duration, 0.1) end
    if not self._enabled then
        for prop, value in pairs(properties) do object[prop] = value end
        return nil
    end
    
    local easing = EasingPresets[config.Easing or "Smooth"]
    local tweenInfo = TweenInfo.new(duration, easing.EasingStyle, easing.EasingDirection, 0, false, config.Delay or 0)
    local tween = TweenService:Create(object, tweenInfo, properties)
    local tweenId = tostring(tween)
    self._activeTweens[tweenId] = tween
    
    tween.Completed:Connect(function()
        self._activeTweens[tweenId] = nil
        if config.Callback then config.Callback() end
    end)
    
    tween:Play()
    return tween
end

function AnimationEngine:Cancel(object)
    for tweenId, tween in pairs(self._activeTweens) do
        if tween.Instance == object then
            tween:Cancel()
            self._activeTweens[tweenId] = nil
        end
    end
end

function AnimationEngine:FadeIn(object, config)
    config = config or {}
    object.BackgroundTransparency = 1
    return self:Tween(object, { BackgroundTransparency = config.TargetTransparency or 0 }, {
        Duration = config.Duration or TimingPresets.Fast,
        Easing = config.Easing or "Smooth",
        Callback = config.Callback
    })
end

function AnimationEngine:FadeOut(object, config)
    config = config or {}
    return self:Tween(object, { BackgroundTransparency = 1 }, {
        Duration = config.Duration or TimingPresets.Fast,
        Easing = config.Easing or "Smooth",
        Callback = config.Callback
    })
end

function AnimationEngine:SlideIn(object, direction, config)
    config = config or {}
    local targetPosition = config.To or object.Position
    local startPosition
    
    if direction == "Left" then
        startPosition = UDim2.new(-1, -object.AbsoluteSize.X, targetPosition.Y.Scale, targetPosition.Y.Offset)
    elseif direction == "Right" then
        startPosition = UDim2.new(1, object.AbsoluteSize.X, targetPosition.Y.Scale, targetPosition.Y.Offset)
    elseif direction == "Top" then
        startPosition = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, -1, -object.AbsoluteSize.Y)
    elseif direction == "Bottom" then
        startPosition = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, 1, object.AbsoluteSize.Y)
    else
        startPosition = config.From or targetPosition
    end
    
    object.Position = startPosition
    return self:Tween(object, { Position = targetPosition }, {
        Duration = config.Duration or TimingPresets.Normal,
        Easing = config.Easing or "Snappy",
        Callback = config.Callback
    })
end

function AnimationEngine:Morph(object, targetSize, config)
    config = config or {}
    local properties = { Size = targetSize }
    
    if config.CornerRadius then
        local corner = object:FindFirstChildOfClass("UICorner")
        if corner then
            self:Tween(corner, { CornerRadius = config.CornerRadius }, {
                Duration = config.Duration or TimingPresets.Normal,
                Easing = config.Easing or "Smooth"
            })
        end
    end
    
    return self:Tween(object, properties, {
        Duration = config.Duration or TimingPresets.Normal,
        Easing = config.Easing or "Smooth",
        Callback = config.Callback
    })
end

function AnimationEngine:Typewriter(textLabel, text, config)
    config = config or {}
    local speed = config.Speed or 30
    local delay = 1 / speed
    
    local thread = task.spawn(function()
        textLabel.Text = ""
        for i = 1, #text do
            if not self._enabled then
                textLabel.Text = text
                break
            end
            textLabel.Text = string.sub(text, 1, i)
            if config.OnCharacter then config.OnCharacter(string.sub(text, i, i), i) end
            if config.Sound then config.Sound:Play() end
            task.wait(delay)
        end
        if config.Callback then config.Callback() end
    end)
    
    table.insert(self._activeThreads, thread)
    return thread
end

function AnimationEngine:BootSequence(lines, onLine, config)
    config = config or {}
    local lineDelay = config.LineDelay or 0.15
    
    local thread = task.spawn(function()
        for i, line in ipairs(lines) do
            if not self._enabled then
                onLine(line, i)
                break
            end
            onLine(line, i)
            task.wait(lineDelay)
        end
        if config.Callback then config.Callback() end
    end)
    
    table.insert(self._activeThreads, thread)
    return thread
end

function AnimationEngine:StaggerIn(objects, config)
    config = config or {}
    local staggerDelay = config.StaggerDelay or 0.05
    local animationType = config.Animation or "Fade"
    
    local thread = task.spawn(function()
        for i, object in ipairs(objects) do
            if not self._enabled then
                object.BackgroundTransparency = 0
                break
            end
            if animationType == "Fade" then
                self:FadeIn(object, { Duration = config.Duration or TimingPresets.Fast })
            end
            task.wait(staggerDelay)
        end
        if config.Callback then config.Callback() end
    end)
    
    table.insert(self._activeThreads, thread)
    return thread
end

function AnimationEngine:Pulse(object, config)
    config = config or {}
    local minTrans = config.MinTransparency or 0.3
    local maxTrans = config.MaxTransparency or 0.8
    local speed = config.Speed or 1
    
    local stroke = object:FindFirstChildOfClass("UIStroke")
    if not stroke then return nil end
    
    local thread
    thread = task.spawn(function()
        while self._enabled and object and object.Parent do
            self:Tween(stroke, { Transparency = maxTrans }, { Duration = (1 / speed) / 2, Easing = "Smooth" })
            task.wait((1 / speed) / 2)
            self:Tween(stroke, { Transparency = minTrans }, { Duration = (1 / speed) / 2, Easing = "Smooth" })
            task.wait((1 / speed) / 2)
        end
    end)
    
    table.insert(self._activeThreads, thread)
    return thread
end

function AnimationEngine:SetEnabled(enabled) self._enabled = enabled end
function AnimationEngine:SetReducedMotion(enabled) self._reducedMotion = enabled end
function AnimationEngine:SetTimeScale(scale) self._timeScale = math.clamp(scale, 0.1, 3.0) end

function AnimationEngine:StopAll()
    for _, tween in pairs(self._activeTweens) do tween:Cancel() end
    for _, thread in ipairs(self._activeThreads) do task.cancel(thread) end
    self._activeTweens = {}
    self._activeThreads = {}
end

function AnimationEngine:Destroy() self:StopAll() end

AnimationEngine.EasingPresets = EasingPresets
AnimationEngine.TimingPresets = TimingPresets

-- ═════════════════════════════════════════════════════════════════
-- THEME MANAGER MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    ThemeManager - Theme System with Live Switching
    
    Multiple pre-built terminal-style themes with
    CSS-like semantic color naming.
]]

local Themes = {
    TerminalDark = {
        Name = "Terminal Dark",
        Description = "Classic terminal aesthetic with aurora accents",
        Background = Color3.fromRGB(12, 12, 16),
        BackgroundSecondary = Color3.fromRGB(18, 18, 24),
        BackgroundTertiary = Color3.fromRGB(24, 24, 32),
        Surface = Color3.fromRGB(22, 22, 30),
        SurfaceHover = Color3.fromRGB(30, 30, 40),
        SurfaceActive = Color3.fromRGB(38, 38, 50),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(180, 180, 195),
        TextMuted = Color3.fromRGB(120, 120, 140),
        TextDisabled = Color3.fromRGB(80, 80, 95),
        Accent = Color3.fromRGB(0, 255, 200),
        AccentLight = Color3.fromRGB(100, 255, 220),
        AccentDark = Color3.fromRGB(0, 180, 140),
        AccentGlow = Color3.fromRGB(0, 255, 200),
        Success = Color3.fromRGB(0, 230, 118),
        Warning = Color3.fromRGB(255, 196, 0),
        Error = Color3.fromRGB(255, 82, 82),
        Info = Color3.fromRGB(68, 138, 255),
        Border = Color3.fromRGB(50, 50, 65),
        BorderLight = Color3.fromRGB(70, 70, 90),
        BorderFocus = Color3.fromRGB(0, 255, 200),
        GlassTint = Color3.fromRGB(0, 0, 0),
        GlassTransparency = 0.15,
        GlowIntensity = 0.8,
        TerminalText = Color3.fromRGB(0, 255, 200),
        TerminalCursor = Color3.fromRGB(0, 255, 200),
        TerminalPrompt = Color3.fromRGB(100, 255, 220),
        TerminalComment = Color3.fromRGB(100, 100, 120),
        Font = Enum.Font.Code,
        FontMonospace = Enum.Font.Code,
        FontSize = { Small = 12, Normal = 14, Medium = 16, Large = 18, Title = 24, Header = 32 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32 },
        BorderRadius = { Small = 4, Medium = 6, Large = 8, Round = 16, Pill = 999 }
    },
    
    Cyberpunk = {
        Name = "Cyberpunk",
        Description = "Neon-drenched cyberpunk aesthetic",
        Background = Color3.fromRGB(10, 10, 20),
        BackgroundSecondary = Color3.fromRGB(15, 15, 30),
        BackgroundTertiary = Color3.fromRGB(22, 22, 40),
        Surface = Color3.fromRGB(18, 18, 35),
        SurfaceHover = Color3.fromRGB(28, 28, 50),
        SurfaceActive = Color3.fromRGB(38, 38, 65),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 255),
        TextMuted = Color3.fromRGB(140, 120, 180),
        TextDisabled = Color3.fromRGB(90, 80, 110),
        Accent = Color3.fromRGB(255, 0, 128),
        AccentLight = Color3.fromRGB(255, 100, 180),
        AccentDark = Color3.fromRGB(180, 0, 90),
        AccentGlow = Color3.fromRGB(255, 0, 128),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 50, 100),
        Info = Color3.fromRGB(0, 200, 255),
        Border = Color3.fromRGB(60, 40, 80),
        BorderLight = Color3.fromRGB(90, 60, 120),
        BorderFocus = Color3.fromRGB(255, 0, 128),
        GlassTint = Color3.fromRGB(30, 0, 50),
        GlassTransparency = 0.1,
        GlowIntensity = 1.0,
        TerminalText = Color3.fromRGB(255, 0, 128),
        TerminalCursor = Color3.fromRGB(255, 255, 0),
        TerminalPrompt = Color3.fromRGB(0, 255, 255),
        TerminalComment = Color3.fromRGB(140, 120, 180),
        Font = Enum.Font.Code,
        FontMonospace = Enum.Font.Code,
        FontSize = { Small = 12, Normal = 14, Medium = 16, Large = 18, Title = 24, Header = 32 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32 },
        BorderRadius = { Small = 2, Medium = 4, Large = 6, Round = 12, Pill = 999 }
    },
    
    Midnight = {
        Name = "Midnight",
        Description = "Deep blue, calm and professional",
        Background = Color3.fromRGB(8, 12, 24),
        BackgroundSecondary = Color3.fromRGB(12, 18, 32),
        BackgroundTertiary = Color3.fromRGB(18, 26, 44),
        Surface = Color3.fromRGB(14, 22, 38),
        SurfaceHover = Color3.fromRGB(22, 32, 52),
        SurfaceActive = Color3.fromRGB(30, 42, 66),
        TextPrimary = Color3.fromRGB(230, 235, 255),
        TextSecondary = Color3.fromRGB(170, 180, 210),
        TextMuted = Color3.fromRGB(110, 120, 150),
        TextDisabled = Color3.fromRGB(70, 80, 100),
        Accent = Color3.fromRGB(100, 150, 255),
        AccentLight = Color3.fromRGB(150, 190, 255),
        AccentDark = Color3.fromRGB(60, 100, 200),
        AccentGlow = Color3.fromRGB(100, 150, 255),
        Success = Color3.fromRGB(80, 200, 150),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Info = Color3.fromRGB(100, 150, 255),
        Border = Color3.fromRGB(40, 50, 80),
        BorderLight = Color3.fromRGB(60, 75, 110),
        BorderFocus = Color3.fromRGB(100, 150, 255),
        GlassTint = Color3.fromRGB(10, 20, 40),
        GlassTransparency = 0.12,
        GlowIntensity = 0.6,
        TerminalText = Color3.fromRGB(100, 150, 255),
        TerminalCursor = Color3.fromRGB(100, 150, 255),
        TerminalPrompt = Color3.fromRGB(150, 190, 255),
        TerminalComment = Color3.fromRGB(110, 120, 150),
        Font = Enum.Font.Code,
        FontMonospace = Enum.Font.Code,
        FontSize = { Small = 12, Normal = 14, Medium = 16, Large = 18, Title = 24, Header = 32 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32 },
        BorderRadius = { Small = 4, Medium = 8, Large = 12, Round = 16, Pill = 999 }
    },
    
    Matrix = {
        Name = "Matrix",
        Description = "Green-on-black terminal aesthetic",
        Background = Color3.fromRGB(0, 8, 0),
        BackgroundSecondary = Color3.fromRGB(0, 12, 0),
        BackgroundTertiary = Color3.fromRGB(0, 18, 0),
        Surface = Color3.fromRGB(0, 14, 0),
        SurfaceHover = Color3.fromRGB(0, 22, 0),
        SurfaceActive = Color3.fromRGB(0, 30, 0),
        TextPrimary = Color3.fromRGB(0, 255, 0),
        TextSecondary = Color3.fromRGB(0, 200, 0),
        TextMuted = Color3.fromRGB(0, 140, 0),
        TextDisabled = Color3.fromRGB(0, 80, 0),
        Accent = Color3.fromRGB(0, 255, 65),
        AccentLight = Color3.fromRGB(100, 255, 130),
        AccentDark = Color3.fromRGB(0, 180, 45),
        AccentGlow = Color3.fromRGB(0, 255, 65),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(180, 255, 0),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(0, 200, 200),
        Border = Color3.fromRGB(0, 60, 0),
        BorderLight = Color3.fromRGB(0, 90, 0),
        BorderFocus = Color3.fromRGB(0, 255, 65),
        GlassTint = Color3.fromRGB(0, 20, 0),
        GlassTransparency = 0.08,
        GlowIntensity = 0.7,
        TerminalText = Color3.fromRGB(0, 255, 65),
        TerminalCursor = Color3.fromRGB(0, 255, 65),
        TerminalPrompt = Color3.fromRGB(0, 255, 0),
        TerminalComment = Color3.fromRGB(0, 150, 0),
        Font = Enum.Font.Code,
        FontMonospace = Enum.Font.Code,
        FontSize = { Small = 12, Normal = 14, Medium = 16, Large = 18, Title = 24, Header = 32 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32 },
        BorderRadius = { Small = 2, Medium = 4, Large = 6, Round = 8, Pill = 999 }
    },
    
    TerminalLight = {
        Name = "Terminal Light",
        Description = "Light theme with terminal aesthetics",
        Background = Color3.fromRGB(245, 245, 250),
        BackgroundSecondary = Color3.fromRGB(235, 235, 242),
        BackgroundTertiary = Color3.fromRGB(220, 220, 230),
        Surface = Color3.fromRGB(240, 240, 248),
        SurfaceHover = Color3.fromRGB(230, 230, 240),
        SurfaceActive = Color3.fromRGB(215, 215, 228),
        TextPrimary = Color3.fromRGB(20, 20, 30),
        TextSecondary = Color3.fromRGB(60, 60, 80),
        TextMuted = Color3.fromRGB(100, 100, 120),
        TextDisabled = Color3.fromRGB(150, 150, 165),
        Accent = Color3.fromRGB(0, 150, 136),
        AccentLight = Color3.fromRGB(50, 180, 170),
        AccentDark = Color3.fromRGB(0, 110, 100),
        AccentGlow = Color3.fromRGB(0, 150, 136),
        Success = Color3.fromRGB(46, 125, 50),
        Warning = Color3.fromRGB(245, 124, 0),
        Error = Color3.fromRGB(211, 47, 47),
        Info = Color3.fromRGB(30, 136, 229),
        Border = Color3.fromRGB(200, 200, 210),
        BorderLight = Color3.fromRGB(180, 180, 195),
        BorderFocus = Color3.fromRGB(0, 150, 136),
        GlassTint = Color3.fromRGB(255, 255, 255),
        GlassTransparency = 0.2,
        GlowIntensity = 0.3,
        TerminalText = Color3.fromRGB(0, 100, 90),
        TerminalCursor = Color3.fromRGB(0, 150, 136),
        TerminalPrompt = Color3.fromRGB(0, 120, 110),
        TerminalComment = Color3.fromRGB(100, 100, 120),
        Font = Enum.Font.Code,
        FontMonospace = Enum.Font.Code,
        FontSize = { Small = 12, Normal = 14, Medium = 16, Large = 18, Title = 24, Header = 32 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24, XXL = 32 },
        BorderRadius = { Small = 4, Medium = 6, Large = 8, Round = 16, Pill = 999 }
    }
}

local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new()
    local self = setmetatable({}, ThemeManager)
    self._themes = Themes
    self._activeThemeName = "TerminalDark"
    self._activeTheme = Themes.TerminalDark
    self._subscribers = {}
    return self
end

function ThemeManager:SetActiveTheme(themeName)
    if not self._themes[themeName] then
        warn("[ThemeManager] Theme not found:", themeName)
        return false
    end
    local oldTheme = self._activeTheme
    self._activeThemeName = themeName
    self._activeTheme = self._themes[themeName]
    for _, callback in ipairs(self._subscribers) do
        local success, err = pcall(callback, self._activeTheme, oldTheme)
        if not success then warn("[ThemeManager] Subscriber callback error:", err) end
    end
    return true
end

function ThemeManager:GetActiveTheme() return self._activeTheme end
function ThemeManager:GetActiveThemeName() return self._activeThemeName end
function ThemeManager:GetTheme(themeName) return self._themes[themeName] end

function ThemeManager:GetThemeNames()
    local names = {}
    for name, _ in pairs(self._themes) do table.insert(names, name) end
    table.sort(names)
    return names
end

function ThemeManager:RegisterTheme(themeName, themeData)
    if type(themeName) ~= "string" or themeName == "" then return false end
    if type(themeData) ~= "table" then return false end
    local defaultTheme = Themes.TerminalDark
    local mergedTheme = {}
    for key, value in pairs(defaultTheme) do
        mergedTheme[key] = themeData[key] ~= nil and themeData[key] or value
    end
    self._themes[themeName] = mergedTheme
    return true
end

function ThemeManager:Subscribe(callback)
    table.insert(self._subscribers, callback)
    return function()
        for i, sub in ipairs(self._subscribers) do
            if sub == callback then table.remove(self._subscribers, i) break end
        end
    end
end

function ThemeManager:GetColor(colorName)
    local color = self._activeTheme[colorName]
    if color and typeof(color) == "Color3" then return color end
    return Color3.fromRGB(128, 128, 128)
end

function ThemeManager:GetFontSize(sizeName)
    local sizes = self._activeTheme.FontSize
    return sizes and sizes[sizeName] or 14
end

function ThemeManager:GetSpacing(sizeName)
    local spacing = self._activeTheme.Spacing
    return spacing and spacing[sizeName] or 8
end

function ThemeManager:GetBorderRadius(sizeName)
    local radii = self._activeTheme.BorderRadius
    return UDim.new(0, radii and radii[sizeName] or 6)
end

function ThemeManager:CreateUICorner(parent, radiusName)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self:GetBorderRadius(radiusName or "Medium")
    corner.Parent = parent
    return corner
end

function ThemeManager:Destroy() self._subscribers = {} end
ThemeManager.Themes = Themes

-- ═════════════════════════════════════════════════════════════════
-- INFO PROVIDER MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    InfoProvider - System Diagnostics & Telemetry
    
    Safe, fallback-protected access to system information.
    NEVER crashes or errors, returns "Unknown" for missing data.
]]

local function detectExecutor()
    local executorInfo = { Name = "Unknown", Version = "N/A", Environment = "Standard" }
    local success, result
    
    success, result = pcall(function()
        if syn and type(syn) == "table" then return "Synapse X" end
        return nil
    end)
    if success and result then
        executorInfo.Name = result
        executorInfo.Environment = "Synapse"
        return executorInfo
    end
    
    success, result = pcall(function()
        if getgenv and getgenv().scriptware then return "Script-Ware" end
        return nil
    end)
    if success and result then
        executorInfo.Name = result
        executorInfo.Environment = "ScriptWare"
        return executorInfo
    end
    
    success, result = pcall(function()
        if KRNL_LOADED then return "Krnl" end
        return nil
    end)
    if success and result then
        executorInfo.Name = result
        executorInfo.Environment = "Krnl"
        return executorInfo
    end
    
    success, result = pcall(function()
        if fluxteam and type(fluxteam) == "table" then return "Fluxus" end
        return nil
    end)
    if success and result then
        executorInfo.Name = result
        executorInfo.Environment = "Fluxus"
        return executorInfo
    end
    
    success, result = pcall(function()
        if getgenv or getsenv or getrawmetatable or islclosure then return true end
        return false
    end)
    if success and result then
        executorInfo.Name = "Custom Executor"
        executorInfo.Environment = "Extended"
    end
    
    return executorInfo
end

local InfoProvider = {}
InfoProvider._sessionStart = os.time()
InfoProvider._loadedTimestamp = os.date("%H:%M:%S")

function InfoProvider.GetExecutorInfo() return detectExecutor() end

function InfoProvider.GetGameInfo()
    local info = { GameName = "Unknown", GameId = 0, PlaceId = 0, JobId = "N/A", ServerType = "Unknown", MaxPlayers = 0, PlayerCount = 0 }
    local success, result
    
    success, result = pcall(function() return game.Name end)
    if success and result then info.GameName = result end
    success, result = pcall(function() return game.GameId end)
    if success and result then info.GameId = result end
    success, result = pcall(function() return game.PlaceId end)
    if success and result then info.PlaceId = result end
    success, result = pcall(function() return game.JobId end)
    if success and result then info.JobId = result end
    success, result = pcall(function() return game.PrivateServerId ~= "" and "Private" or "Public" end)
    if success and result then info.ServerType = result end
    success, result = pcall(function() return Players.MaxPlayers end)
    if success and result then info.MaxPlayers = result end
    success, result = pcall(function() return #Players:GetPlayers() end)
    if success and result then info.PlayerCount = result end
    
    return info
end

function InfoProvider.GetPlayerInfo()
    local info = { Username = "Unknown", UserId = 0, DisplayName = "Unknown", AccountAge = 0, Membership = "None", Country = "N/A" }
    if not LocalPlayer then return info end
    
    local success, result
    success, result = pcall(function() return LocalPlayer.Name end)
    if success and result then info.Username = result end
    success, result = pcall(function() return LocalPlayer.UserId end)
    if success and result then info.UserId = result end
    success, result = pcall(function() return LocalPlayer.DisplayName end)
    if success and result then info.DisplayName = result end
    success, result = pcall(function() return LocalPlayer.AccountAge end)
    if success and result then info.AccountAge = result end
    success, result = pcall(function()
        local m = LocalPlayer.MembershipType
        return m == Enum.MembershipType.Premium and "Premium" or "None"
    end)
    if success and result then info.Membership = result end
    
    return info
end

function InfoProvider.GetSessionInfo()
    local currentTime = os.time()
    local runtime = currentTime - InfoProvider._sessionStart
    local hours = math.floor(runtime / 3600)
    local minutes = math.floor((runtime % 3600) / 60)
    local seconds = runtime % 60
    
    return {
        SessionStart = InfoProvider._sessionStart,
        SessionRuntime = string.format("%02d:%02d:%02d", hours, minutes, seconds),
        RuntimeSeconds = runtime,
        LoadTime = InfoProvider._loadedTimestamp,
        LocalTime = os.date("%H:%M:%S")
    }
end

function InfoProvider.GetFullInfo()
    return {
        Executor = InfoProvider.GetExecutorInfo(),
        Game = InfoProvider.GetGameInfo(),
        Player = InfoProvider.GetPlayerInfo(),
        Session = InfoProvider.GetSessionInfo()
    }
end

-- ═════════════════════════════════════════════════════════════════
-- SECTION MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    Section - Collapsible Section Container
    
    Provides collapsible sections with all UI components.
]]

local Section = {}
Section.__index = Section

function Section.new(tab, name)
    local self = setmetatable({}, Section)
    self._tab = tab
    self._aurora = tab._aurora
    self._theme = tab._theme
    self._animation = tab._animation
    self._name = name
    self._isCollapsed = false
    self._components = {}
    self:_createSectionUI()
    return self
end

function Section:_createSectionUI()
    local theme = self._theme:GetActiveTheme()
    local accent = self._tab._console._config.Accent
    
    local container = Instance.new("Frame")
    container.Name = "Section_" .. self._name
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = theme.Surface
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = self._tab._panel
    self._container = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = theme.BackgroundTertiary
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    header.Text = ""
    header.Parent = container
    self._header = header
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "[ " .. self._name:upper() .. " ]"
    title.TextColor3 = accent
    title.TextSize = 12
    title.Font = theme.FontMonospace
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local indicator = Instance.new("TextLabel")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 20, 1, 0)
    indicator.Position = UDim2.new(1, -24, 0, 0)
    indicator.BackgroundTransparency = 1
    indicator.Text = "▼"
    indicator.TextColor3 = theme.TextMuted
    indicator.TextSize = 10
    indicator.Font = theme.FontMonospace
    indicator.Parent = header
    self._indicator = indicator
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 36)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = container
    self._content = content
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = content
    self._layout = layout
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = content
    
    header.MouseButton1Click:Connect(function() self:ToggleCollapse() end)
end

function Section:ToggleCollapse()
    self._isCollapsed = not self._isCollapsed
    if self._isCollapsed then
        self._content.Visible = false
        self._indicator.Text = "▶"
    else
        self._content.Visible = true
        self._indicator.Text = "▼"
    end
end

function Section:AddButton(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 32)
    button.BackgroundColor3 = theme.Surface
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = config.Text or "Button"
    button.TextColor3 = theme.TextPrimary
    button.TextSize = 14
    button.Font = theme.FontMonospace
    button.Parent = self._content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        self._animation:Tween(button, { BackgroundColor3 = theme.SurfaceHover, BackgroundTransparency = 0.1 }, { Duration = 0.15 })
    end)
    button.MouseLeave:Connect(function()
        self._animation:Tween(button, { BackgroundColor3 = theme.Surface, BackgroundTransparency = 0.3 }, { Duration = 0.15 })
    end)
    if config.Callback then button.MouseButton1Click:Connect(config.Callback) end
    
    local control = { Frame = button, SetText = function(text) button.Text = text end }
    table.insert(self._components, control)
    return control
end

function Section:AddToggle(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    local accent = self._tab._console._config.Accent
    
    local container = Instance.new("Frame")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = self._content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.TextColor3 = theme.TextPrimary
    label.TextSize = 14
    label.Font = theme.FontMonospace
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 44, 0, 22)
    track.Position = UDim2.new(1, -48, 0.5, -11)
    track.BackgroundColor3 = theme.BackgroundTertiary
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 11)
    trackCorner.Parent = track
    
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(0, 2, 0.5, -9)
    handle.BackgroundColor3 = theme.TextMuted
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 9)
    handleCorner.Parent = handle
    
    local state = config.Default or false
    
    local function updateToggle()
        if state then
            self._animation:Tween(track, { BackgroundColor3 = accent }, { Duration = 0.2 })
            self._animation:Tween(handle, { Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = theme.TextPrimary }, { Duration = 0.2 })
        else
            self._animation:Tween(track, { BackgroundColor3 = theme.BackgroundTertiary }, { Duration = 0.2 })
            self._animation:Tween(handle, { Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = theme.TextMuted }, { Duration = 0.2 })
        end
    end
    
    updateToggle()
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
            if config.Callback then config.Callback(state) end
        end
    end)
    
    local control = {
        Frame = container,
        GetValue = function() return state end,
        SetValue = function(value) state = value updateToggle() end
    }
    table.insert(self._components, control)
    return control
end

function Section:AddSlider(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    local accent = self._tab._console._config.Accent
    
    local container = Instance.new("Frame")
    container.Name = "Slider"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self._content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = (config.Text or "Value") .. ": " .. tostring(config.Default or 50)
    label.TextColor3 = theme.TextPrimary
    label.TextSize = 14
    label.Font = theme.FontMonospace
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = theme.BackgroundTertiary
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or 50
    
    local function updateValue(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = (config.Text or "Value") .. ": " .. tostring(math.floor(value))
        if config.Callback then config.Callback(value) end
    end
    
    updateValue(value)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseX = UserInputService:GetMouseLocation().X
            local trackStart = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            local percent = math.clamp((mouseX - trackStart) / trackWidth, 0, 1)
            updateValue(min + (max - min) * percent)
        end
    end)
    
    local control = {
        Frame = container,
        GetValue = function() return value end,
        SetValue = function(newValue) updateValue(newValue) end
    }
    table.insert(self._components, control)
    return control
end

function Section:AddDropdown(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    
    local container = Instance.new("Frame")
    container.Name = "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = self._content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Select:"
    label.TextColor3 = theme.TextSecondary
    label.TextSize = 14
    label.Font = theme.FontMonospace
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownButton"
    dropdownBtn.Size = UDim2.new(1, -110, 1, 0)
    dropdownBtn.Position = UDim2.new(0, 110, 0, 0)
    dropdownBtn.BackgroundColor3 = theme.Surface
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = config.Default or config.Options[1] or "Select..."
    dropdownBtn.TextColor3 = theme.TextPrimary
    dropdownBtn.TextSize = 14
    dropdownBtn.Font = theme.FontMonospace
    dropdownBtn.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdownBtn
    
    local selected = config.Default or config.Options[1]
    
    dropdownBtn.MouseButton1Click:Connect(function()
        local currentIndex = 0
        for i, opt in ipairs(config.Options) do
            if opt == selected then currentIndex = i break end
        end
        local nextIndex = (currentIndex % #config.Options) + 1
        selected = config.Options[nextIndex]
        dropdownBtn.Text = selected
        if config.Callback then config.Callback(selected) end
    end)
    
    local control = {
        Frame = container,
        GetValue = function() return selected end,
        SetValue = function(value) selected = value dropdownBtn.Text = value end
    }
    table.insert(self._components, control)
    return control
end

function Section:AddTextbox(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    
    local textbox = Instance.new("TextBox")
    textbox.Name = "Textbox"
    textbox.Size = UDim2.new(1, 0, 0, 32)
    textbox.BackgroundColor3 = theme.Surface
    textbox.BorderSizePixel = 0
    textbox.Text = config.Default or ""
    textbox.PlaceholderText = config.Text or "Enter text..."
    textbox.TextColor3 = theme.TextPrimary
    textbox.PlaceholderColor3 = theme.TextMuted
    textbox.TextSize = 14
    textbox.Font = theme.FontMonospace
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.Parent = self._content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textbox
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = textbox
    
    textbox.FocusLost:Connect(function()
        if config.Callback then config.Callback(textbox.Text) end
    end)
    
    local control = {
        Frame = textbox,
        GetValue = function() return textbox.Text end,
        SetValue = function(value) textbox.Text = value end
    }
    table.insert(self._components, control)
    return control
end

function Section:AddKeybind(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    
    local container = Instance.new("Frame")
    container.Name = "Keybind"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = self._content
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Keybind:"
    label.TextColor3 = theme.TextPrimary
    label.TextSize = 14
    label.Font = theme.FontMonospace
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Name = "KeyButton"
    keyBtn.Size = UDim2.new(0, 70, 0, 28)
    keyBtn.Position = UDim2.new(1, -74, 0.5, -14)
    keyBtn.BackgroundColor3 = theme.Surface
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = config.Default and config.Default.Name or "None"
    keyBtn.TextColor3 = theme.TextSecondary
    keyBtn.TextSize = 12
    keyBtn.Font = theme.FontMonospace
    keyBtn.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = keyBtn
    
    local key = config.Default
    local accent = self._tab._console._config.Accent
    
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."
        keyBtn.TextColor3 = accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                keyBtn.Text = key.Name
                keyBtn.TextColor3 = theme.TextPrimary
                conn:Disconnect()
                if config.Callback then config.Callback(key) end
            end
        end)
    end)
    
    local control = {
        Frame = container,
        GetValue = function() return key end,
        SetValue = function(newKey) key = newKey keyBtn.Text = key.Name end
    }
    table.insert(self._components, control)
    return control
end

function Section:AddLabel(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Label"
    label.TextColor3 = self._theme:GetColor(config.Color or "TextPrimary")
    label.TextSize = 14
    label.Font = theme.FontMonospace
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = self._content
    
    return label
end

function Section:AddParagraph(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    local accent = self._tab._console._config.Accent
    
    local container = Instance.new("Frame")
    container.Name = "Paragraph"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = self._content
    
    if config.Title then
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = config.Title
        title.TextColor3 = accent
        title.TextSize = 14
        title.Font = theme.FontMonospace
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = container
    end
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, config.Title and 22 or 0)
    content.BackgroundTransparency = 1
    content.Text = config.Text or ""
    content.TextColor3 = theme.TextSecondary
    content.TextSize = 12
    content.Font = theme.FontMonospace
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextWrapped = true
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = container
    
    return container
end

function Section:Destroy()
    self._container:Destroy()
    self._components = {}
end

-- ═════════════════════════════════════════════════════════════════
-- TAB MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    Tab - Tab Component System
    
    Provides tab functionality with content panels.
]]

local Tab = {}
Tab.__index = Tab

function Tab.new(console, name)
    local self = setmetatable({}, Tab)
    self._console = console
    self._aurora = console._aurora
    self._theme = console._theme
    self._animation = console._animation
    self._name = name
    self._sections = {}
    self._isActive = false
    self:_createTabButton()
    self:_createContentPanel()
    return self
end

function Tab:_createTabButton()
    local theme = self._theme:GetActiveTheme()
    
    local button = Instance.new("TextButton")
    button.Name = "Tab_" .. self._name
    button.Size = UDim2.new(0, 80, 1, 0)
    button.BackgroundColor3 = theme.BackgroundTertiary
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 0
    button.Text = self._name
    button.TextColor3 = theme.TextSecondary
    button.TextSize = 12
    button.Font = theme.FontMonospace
    button.AutoButtonColor = false
    button.Parent = self._console._tabContainer
    self._button = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        self._console:SetActiveTab(self)
    end)
    
    button.MouseEnter:Connect(function()
        if not self._isActive then
            self._animation:Tween(button, { BackgroundTransparency = 0.2, TextColor3 = theme.TextPrimary }, { Duration = 0.15 })
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not self._isActive then
            self._animation:Tween(button, { BackgroundTransparency = 0.5, TextColor3 = theme.TextSecondary }, { Duration = 0.15 })
        end
    end)
end

function Tab:_createContentPanel()
    local theme = self._theme:GetActiveTheme()
    
    local panel = Instance.new("Frame")
    panel.Name = "TabPanel_" .. self._name
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Visible = false
    panel.Parent = self._console._scrollView
    self._panel = panel
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = panel
    self._layout = layout
end

function Tab:SetActive(active)
    self._isActive = active
    local theme = self._theme:GetActiveTheme()
    local accent = self._console._config.Accent
    
    if active then
        self._animation:Tween(self._button, { BackgroundColor3 = accent, BackgroundTransparency = 0.8, TextColor3 = theme.TextPrimary }, { Duration = 0.2 })
        self._panel.Visible = true
        self._animation:FadeIn(self._panel, { Duration = 0.15 })
    else
        self._animation:Tween(self._button, { BackgroundColor3 = theme.BackgroundTertiary, BackgroundTransparency = 0.5, TextColor3 = theme.TextSecondary }, { Duration = 0.2 })
        self._panel.Visible = false
    end
end

function Tab:CreateSection(name)
    local section = Section.new(self, name)
    table.insert(self._sections, section)
    return section
end

function Tab:Destroy()
    self._button:Destroy()
    self._panel:Destroy()
    for _, section in ipairs(self._sections) do section:Destroy() end
    self._sections = {}
end

-- ═════════════════════════════════════════════════════════════════
-- NOTIFICATION MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    Notification - Toast Notification System
    
    Non-intrusive notifications with multiple types.
]]

local NotificationTypes = {
    info = { Icon = "ℹ", ColorName = "Info" },
    success = { Icon = "✓", ColorName = "Success" },
    warning = { Icon = "⚠", ColorName = "Warning" },
    error = { Icon = "✕", ColorName = "Error" }
}

local Notification = {}
Notification.__index = Notification

function Notification.new(aurora)
    local self = setmetatable({}, Notification)
    self._aurora = aurora
    self._theme = aurora._ThemeManager
    self._animation = aurora._AnimationEngine
    self._notifications = {}
    self:_createContainer()
    return self
end

function Notification:_createContainer()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraNotifications"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self._screenGui = screenGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 350, 1, -20)
    container.Position = UDim2.new(1, -370, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    self._container = container
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container
    self._layout = layout
end

function Notification:Show(config)
    config = config or {}
    local theme = self._theme:GetActiveTheme()
    local notifType = NotificationTypes[config.Type or "info"]
    local accentColor = self._theme:GetColor(notifType.ColorName)
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 70)
    notification.BackgroundColor3 = theme.Surface
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Parent = self._container
    notification.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = accentColor
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = notification
    
    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.Size = UDim2.new(0, 3, 1, 0)
    accentLine.BackgroundColor3 = accentColor
    accentLine.BorderSizePixel = 0
    accentLine.Parent = notification
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 15, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = notifType.Icon
    icon.TextColor3 = accentColor
    icon.TextSize = 20
    icon.Font = theme.FontMonospace
    icon.Parent = notification
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = theme.TextPrimary
    title.TextSize = 14
    title.Font = theme.FontMonospace
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(1, -70, 0, 30)
    message.Position = UDim2.new(0, 50, 0, 32)
    message.BackgroundTransparency = 1
    message.Text = config.Message or ""
    message.TextColor3 = theme.TextSecondary
    message.TextSize = 12
    message.Font = theme.FontMonospace
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextWrapped = true
    message.Parent = notification
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = theme.TextMuted
    closeBtn.TextSize = 14
    closeBtn.Font = theme.FontMonospace
    closeBtn.Parent = notification
    
    notification.Position = UDim2.new(1, 20, 0, 0)
    notification.BackgroundTransparency = 1
    
    self._animation:Tween(notification, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1 }, { Duration = 0.3, Easing = "Snappy" })
    
    local notifData = { Frame = notification, Dismissed = false }
    table.insert(self._notifications, notifData)
    
    local function dismiss()
        if notifData.Dismissed then return end
        notifData.Dismissed = true
        self._animation:Tween(notification, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, {
            Duration = 0.2,
            Easing = "Smooth",
            Callback = function()
                notification:Destroy()
                for i, n in ipairs(self._notifications) do
                    if n == notifData then table.remove(self._notifications, i) break end
                end
            end
        })
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(config.Duration or 5, dismiss)
    
    return { Frame = notification, Dismiss = dismiss }
end

function Notification:Destroy()
    for _, notif in ipairs(self._notifications) do
        if notif.Frame and notif.Frame.Parent then notif.Frame:Destroy() end
    end
    self._notifications = {}
    if self._screenGui then self._screenGui:Destroy() end
end

-- ═════════════════════════════════════════════════════════════════
-- CONSOLE MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    Console - Main Terminal Window
    
    The primary UI container with minimize/restore, tabs, and content.
]]

local Console = {}
Console.__index = Console

function Console.new(aurora, config)
    local self = setmetatable({}, Console)
    self._aurora = aurora
    self._theme = aurora._ThemeManager
    self._animation = aurora._AnimationEngine
    self._state = aurora._GlobalState
    self._config = config
    self._tabs = {}
    self._activeTab = nil
    self._isMinimized = false
    self._isDestroyed = false
    
    self:_createUI()
    self:_setupDragging()
    self:_setupMinimizeKey()
    
    if config.ShowBootSequence then self:_showBootSequence() end
    
    return self
end

function Console:_createUI()
    local theme = self._theme:GetActiveTheme()
    local config = self._config
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AuroraConsole"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self._screenGui = screenGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, config.Size.X, 0, config.Size.Y)
    container.Position = config.Position
    container.BackgroundColor3 = theme.Background
    container.BorderSizePixel = 0
    container.Parent = screenGui
    self._container = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container
    
    local glow = Instance.new("UIStroke")
    glow.Color = config.Accent
    glow.Thickness = 1.5
    glow.Transparency = 0.6
    glow.Parent = container
    self._glow = glow
    
    self:_createHeader()
    self:_createContentArea()
    self:_createTabBar()
    
    self._animation:FadeIn(container, { Duration = 0.3 })
end

function Console:_createHeader()
    local theme = self._theme:GetActiveTheme()
    local config = self._config
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = theme.BackgroundSecondary
    header.BorderSizePixel = 0
    header.Parent = self._container
    self._header = header
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = header
    
    local mask = Instance.new("Frame")
    mask.Name = "BottomMask"
    mask.Size = UDim2.new(1, 0, 0, 10)
    mask.Position = UDim2.new(0, 0, 1, -10)
    mask.BackgroundColor3 = theme.BackgroundSecondary
    mask.BorderSizePixel = 0
    mask.Parent = header
    
    local glowLine = Instance.new("Frame")
    glowLine.Name = "GlowLine"
    glowLine.Size = UDim2.new(1, 0, 0, 2)
    glowLine.Position = UDim2.new(0, 0, 1, -2)
    glowLine.BackgroundColor3 = config.Accent
    glowLine.BorderSizePixel = 0
    glowLine.Parent = header
    
    local prefix = Instance.new("TextLabel")
    prefix.Name = "Prefix"
    prefix.Size = UDim2.new(0, 20, 1, 0)
    prefix.Position = UDim2.new(0, 12, 0, 0)
    prefix.BackgroundTransparency = 1
    prefix.Text = ">"
    prefix.TextColor3 = config.Accent
    prefix.TextSize = 16
    prefix.Font = theme.FontMonospace
    prefix.TextXAlignment = Enum.TextXAlignment.Left
    prefix.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -160, 1, 0)
    title.Position = UDim2.new(0, 32, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title
    title.TextColor3 = theme.TextPrimary
    title.TextSize = 14
    title.Font = theme.FontMonospace
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    self._title = title
    
    if config.Subtitle and config.Subtitle ~= "" then
        local subtitle = Instance.new("TextLabel")
        subtitle.Name = "Subtitle"
        subtitle.Size = UDim2.new(0, 100, 1, 0)
        subtitle.Position = UDim2.new(1, -150, 0, 0)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = config.Subtitle
        subtitle.TextColor3 = theme.TextMuted
        subtitle.TextSize = 12
        subtitle.Font = theme.FontMonospace
        subtitle.TextXAlignment = Enum.TextXAlignment.Right
        subtitle.Parent = header
    end
    
    self:_createControlButtons()
end

function Console:_createControlButtons()
    local theme = self._theme:GetActiveTheme()
    local config = self._config
    
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 70, 1, 0)
    controls.Position = UDim2.new(1, -80, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = self._header
    
    if config.Minimizable then
        local minimize = self:_createButton(controls, "─", theme.TextSecondary, 0)
        minimize.MouseButton1Click:Connect(function() self:Minimize() end)
    end
    
    if config.Closable then
        local close = self:_createButton(controls, "×", theme.Error, 30)
        close.MouseButton1Click:Connect(function() self:Destroy() end)
    end
end

function Console:_createButton(parent, text, color, offset)
    local theme = self._theme:GetActiveTheme()
    
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. text
    button.Size = UDim2.new(0, 24, 0, 24)
    button.Position = UDim2.new(0, offset, 0.5, -12)
    button.BackgroundColor3 = theme.Surface
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = color
    button.TextSize = 14
    button.Font = theme.FontMonospace
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        self._animation:Tween(button, { BackgroundTransparency = 0.2 }, { Duration = 0.15 })
    end)
    button.MouseLeave:Connect(function()
        self._animation:Tween(button, { BackgroundTransparency = 0.5 }, { Duration = 0.15 })
    end)
    
    return button
end

function Console:_createContentArea()
    local theme = self._theme:GetActiveTheme()
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -24, 1, -90)
    content.Position = UDim2.new(0, 12, 0, 42)
    content.BackgroundColor3 = theme.BackgroundSecondary
    content.BackgroundTransparency = 0.5
    content.BorderSizePixel = 0
    content.Parent = self._container
    self._content = content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = content
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.Size = UDim2.new(1, -16, 1, -16)
    tabContent.Position = UDim2.new(0, 8, 0, 8)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = content
    self._tabContent = tabContent
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollView"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = theme.Accent
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.Parent = tabContent
    self._scrollView = scrollFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scrollFrame
    self._contentLayout = layout
end

function Console:_createTabBar()
    local theme = self._theme:GetActiveTheme()
    
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, -24, 0, 36)
    tabBar.Position = UDim2.new(0, 12, 1, -48)
    tabBar.BackgroundColor3 = theme.BackgroundSecondary
    tabBar.BackgroundTransparency = 0.5
    tabBar.BorderSizePixel = 0
    tabBar.Parent = self._container
    self._tabBar = tabBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabBar
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "Tabs"
    tabContainer.Size = UDim2.new(1, -16, 1, 0)
    tabContainer.Position = UDim2.new(0, 8, 0, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = tabBar
    self._tabContainer = tabContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = tabContainer
    self._tabLayout = layout
end

function Console:_showBootSequence()
    local bootLines = {
        "Initializing Aurora...",
        "Loading modules...",
        "Connecting to services...",
        "Ready."
    }
    
    local overlay = Instance.new("Frame")
    overlay.Name = "BootOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = self._theme:GetActiveTheme().Background
    overlay.BackgroundTransparency = 0.2
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 50
    overlay.Parent = self._content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = overlay
    
    local bootText = Instance.new("Frame")
    bootText.Name = "BootText"
    bootText.Size = UDim2.new(1, -20, 1, -20)
    bootText.Position = UDim2.new(0, 10, 0, 10)
    bootText.BackgroundTransparency = 1
    bootText.Parent = overlay
    
    local yOffset = 0
    
    self._animation:BootSequence(bootLines, function(line, index)
        local lineLabel = Instance.new("TextLabel")
        lineLabel.Name = "BootLine_" .. index
        lineLabel.Size = UDim2.new(1, 0, 0, 22)
        lineLabel.Position = UDim2.new(0, 0, 0, yOffset)
        lineLabel.BackgroundTransparency = 1
        lineLabel.TextColor3 = self._theme:GetActiveTheme().TerminalText
        lineLabel.TextSize = 14
        lineLabel.Font = self._theme:GetActiveTheme().FontMonospace
        lineLabel.TextXAlignment = Enum.TextXAlignment.Left
        lineLabel.Parent = bootText
        
        lineLabel.TextTransparency = 1
        self._animation:Tween(lineLabel, { TextTransparency = 0 }, { Duration = 0.15 })
        self._animation:Typewriter(lineLabel, "> " .. line, { Speed = 50 })
        
        yOffset = yOffset + 24
    end, {
        LineDelay = 0.3,
        Callback = function()
            self._animation:FadeOut(overlay, {
                Duration = 0.3,
                Callback = function() overlay:Destroy() end
            })
        end
    })
end

function Console:CreateTab(name)
    local tab = Tab.new(self, name)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:SetActiveTab(tab) end
    return tab
end

function Console:SetActiveTab(tab)
    for _, t in ipairs(self._tabs) do t:SetActive(false) end
    tab:SetActive(true)
    self._activeTab = tab
end

function Console:_setupDragging()
    if not self._config.Draggable then return end
    local dragging = false
    local dragStart, startPos
    
    self._header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self._container.Position
        end
    end)
    
    self._header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self._container.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Console:_setupMinimizeKey()
    if not self._config.MinimizeKey then return end
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self._config.MinimizeKey then
            self:ToggleMinimize()
        end
    end)
end

function Console:Minimize()
    if self._isMinimized then return end
    self._isMinimized = true
    
    self._savedPosition = self._container.Position
    self._savedSize = self._container.Size
    
    self._animation:Morph(self._container, UDim2.new(0, 200, 0, 40), {
        Duration = 0.3,
        Easing = "Smooth",
        CornerRadius = UDim.new(0, 20)
    })
    
    self._animation:Tween(self._container, { Position = UDim2.new(0.5, -100, 0, 20) }, { Duration = 0.3, Easing = "Smooth" })
    
    self._content.Visible = false
    self._tabBar.Visible = false
    self._title.Size = UDim2.new(1, -60, 1, 0)
    self._title.Position = UDim2.new(0, 32, 0, 0)
end

function Console:Restore()
    if not self._isMinimized then return end
    self._isMinimized = false
    
    self._animation:Morph(self._container, self._savedSize, {
        Duration = 0.3,
        Easing = "Smooth",
        CornerRadius = UDim.new(0, 8)
    })
    
    self._animation:Tween(self._container, { Position = self._savedPosition }, { Duration = 0.3, Easing = "Smooth" })
    
    self._content.Visible = true
    self._tabBar.Visible = true
    self._title.Size = UDim2.new(1, -160, 1, 0)
    self._title.Position = UDim2.new(0, 32, 0, 0)
end

function Console:ToggleMinimize()
    if self._isMinimized then self:Restore() else self:Minimize() end
end

function Console:Destroy()
    if self._isDestroyed then return end
    self._isDestroyed = true
    
    self._animation:FadeOut(self._container, {
        Duration = 0.2,
        Callback = function() self._screenGui:Destroy() end
    })
    
    for _, tab in ipairs(self._tabs) do tab:Destroy() end
    self._tabs = {}
end

-- ═════════════════════════════════════════════════════════════════
-- AURORA MAIN MODULE
-- ═════════════════════════════════════════════════════════════════

--[[
    Aurora - Main Framework Entry Point
    
    Initialize, create consoles, manage themes, notifications, and system info.
]]

local Aurora = {}

Aurora.Version = "1.0.0"
Aurora.BuildType = "Release"
Aurora.Initialized = false

Aurora._Consoles = {}
Aurora._ActiveConsole = nil
Aurora._GlobalState = nil
Aurora._ThemeManager = nil
Aurora._AnimationEngine = nil
Aurora._Notifications = nil

-- ═════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═════════════════════════════════════════════════════════════════

function Aurora.Initialize()
    if Aurora.Initialized then
        warn("[Aurora] Framework already initialized. Skipping...")
        return Aurora
    end
    
    Aurora._GlobalState = StateManager.new({
        Theme = "TerminalDark",
        AnimationEnabled = true,
        ReducedMotion = false,
        DebugMode = false
    })
    
    Aurora._AnimationEngine = AnimationEngine.new()
    Aurora._ThemeManager = ThemeManager.new()
    Aurora._ThemeManager:SetActiveTheme("TerminalDark")
    Aurora._Notifications = Notification.new(Aurora)
    
    Aurora.Initialized = true
    
    if Aurora._GlobalState:Get("DebugMode") then
        print("[Aurora] Framework initialized successfully")
        print("[Aurora] Version:", Aurora.Version)
    end
    
    return Aurora
end

-- ═════════════════════════════════════════════════════════════════
-- CONSOLE CREATION
-- ═════════════════════════════════════════════════════════════════

function Aurora.CreateConsole(config)
    if not Aurora.Initialized then Aurora.Initialize() end
    
    config = config or {}
    
    local consoleConfig = {
        Title = config.Title or "Aurora Terminal",
        Subtitle = config.Subtitle or "",
        Size = config.Size or Vector2.new(600, 450),
        Position = config.Position or UDim2.new(0.5, -300, 0.5, -225),
        Accent = config.Accent or Color3.fromRGB(0, 255, 200),
        MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightControl,
        Draggable = config.Draggable ~= false,
        Minimizable = config.Minimizable ~= false,
        Closable = config.Closable ~= false,
        ShowBootSequence = config.ShowBootSequence ~= false
    }
    
    local console = Console.new(Aurora, consoleConfig)
    
    table.insert(Aurora._Consoles, console)
    Aurora._ActiveConsole = console
    
    return console
end

-- ═════════════════════════════════════════════════════════════════
-- THEME MANAGEMENT
-- ═════════════════════════════════════════════════════════════════

function Aurora.SetTheme(themeName)
    if not Aurora._ThemeManager then
        warn("[Aurora] Framework not initialized. Call Aurora.Initialize() first.")
        return Aurora
    end
    Aurora._ThemeManager:SetActiveTheme(themeName)
    Aurora._GlobalState:Set("Theme", themeName)
    return Aurora
end

function Aurora.GetTheme()
    if not Aurora._ThemeManager then return nil end
    return Aurora._ThemeManager:GetActiveTheme()
end

function Aurora.RegisterTheme(themeName, themeData)
    if not Aurora._ThemeManager then
        warn("[Aurora] Framework not initialized.")
        return Aurora
    end
    Aurora._ThemeManager:RegisterTheme(themeName, themeData)
    return Aurora
end

-- ═════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═════════════════════════════════════════════════════════════════

function Aurora.Notify(config)
    if not Aurora._Notifications then
        warn("[Aurora] Framework not initialized.")
        return nil
    end
    return Aurora._Notifications:Show(config)
end

-- ═════════════════════════════════════════════════════════════════
-- SYSTEM INFORMATION
-- ═════════════════════════════════════════════════════════════════

function Aurora.GetSystemInfo() return InfoProvider.GetFullInfo() end
function Aurora.GetExecutorInfo() return InfoProvider.GetExecutorInfo() end
function Aurora.GetGameInfo() return InfoProvider.GetGameInfo() end
function Aurora.GetPlayerInfo() return InfoProvider.GetPlayerInfo() end

-- ═════════════════════════════════════════════════════════════════
-- ANIMATION CONTROLS
-- ═════════════════════════════════════════════════════════════════

function Aurora.SetAnimationsEnabled(enabled)
    Aurora._GlobalState:Set("AnimationEnabled", enabled)
    return Aurora
end

function Aurora.SetReducedMotion(enabled)
    Aurora._GlobalState:Set("ReducedMotion", enabled)
    return Aurora
end

-- ═════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═════════════════════════════════════════════════════════════════

function Aurora.GetVersion() return Aurora.Version end

function Aurora.Destroy()
    for _, console in ipairs(Aurora._Consoles) do console:Destroy() end
    Aurora._Consoles = {}
    Aurora._ActiveConsole = nil
    if Aurora._Notifications then Aurora._Notifications:Destroy() end
    Aurora.Initialized = false
end

function Aurora.DumpState()
    if not Aurora._GlobalState:Get("DebugMode") then
        warn("[Aurora] Debug mode is disabled.")
        return nil
    end
    return {
        Version = Aurora.Version,
        Initialized = Aurora.Initialized,
        ActiveTheme = Aurora._GlobalState:Get("Theme"),
        ConsoleCount = #Aurora._Consoles,
        AnimationsEnabled = Aurora._GlobalState:Get("AnimationEnabled"),
        ReducedMotion = Aurora._GlobalState:Get("ReducedMotion")
    }
end

-- ═════════════════════════════════════════════════════════════════
-- EXPORT
-- ═════════════════════════════════════════════════════════════════

return Aurora
