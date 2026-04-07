-- [[ BitcodeLibrary v6.5 - FIXED CLEAN VERSION ]]

local Library = {}
Library.__index = Library

Library.Colors = {
    NEON_ORANGE = Color3.fromRGB(255, 100, 0),
    BACKGROUND_BLACK = Color3.fromRGB(12, 12, 12),
    ACCENT_WHITE = Color3.fromRGB(255, 255, 255),
    DARK_GREY = Color3.fromRGB(25, 25, 25),
    HIGHLIGHT = Color3.fromRGB(40, 40, 40),
    TOPBAR = Color3.fromRGB(18, 18, 18),
    RED = Color3.fromRGB(220, 50, 50)
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function createCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 12)
end

-- DRAG
local function makeDraggable(frame, handle)
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:Init()
    local old = CoreGui:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "BitcodeLibrary"
    screen.ResetOnSpawn = false

    local main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0, 350, 0, 250)
    main.Position = UDim2.new(0.5, -175, 0.5, -125)
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.Active = true
    createCorner(main, 15)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 2

    -- TOPBAR
    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 38)
    topBar.BackgroundColor3 = Library.Colors.TOPBAR
    topBar.Active = true
    makeDraggable(main, topBar)

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Ghz betav1"
    title.TextColor3 = Library.Colors.ACCENT_WHITE
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- SIDEBAR
    local sidebar = Instance.new("Frame", main)
    sidebar.Position = UDim2.new(0, 0, 0, 38)
    sidebar.Size = UDim2.new(0, 100, 1, -38)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Size = UDim2.new(1, -10, 1, -10)
    tabList.Position = UDim2.new(0, 5, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", tabList).Padding = UDim.new(0, 6)

    -- CONTAINER
    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 105, 0, 38)
    container.Size = UDim2.new(1, -110, 1, -40)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true

    self.Container = container
    self.TabList = tabList

    return self
end

function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabList)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Text = name
    btn.BackgroundColor3 = Library.Colors.DARK_GREY
    btn.TextColor3 = Library.Colors.ACCENT_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    createCorner(btn, 10)

    local content = Instance.new("ScrollingFrame", self.Container)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 2

    local inner = Instance.new("Frame", content)
    inner.Size = UDim2.new(1, 0, 1, 0)
    inner.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    inner.BorderSizePixel = 0
    inner.ClipsDescendants = true
    createCorner(inner, 15)

    local padding = Instance.new("UIPadding", inner)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout", inner)
    layout.Padding = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        content.Visible = true

        for _, v in pairs(self.TabList:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Library.Colors.DARK_GREY
            end
        end
        btn.BackgroundColor3 = Library.Colors.NEON_ORANGE
    end)

    if not self._hasTab then
        self._hasTab = true
        content.Visible = true
        btn.BackgroundColor3 = Library.Colors.NEON_ORANGE
    end

    local tab = {}

    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", inner)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.Text = text
        b.BackgroundColor3 = Library.Colors.HIGHLIGHT
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 13
        createCorner(b, 12)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text, cb)
        local state = false

        local f = Instance.new("TextButton", inner)
        f.Size = UDim2.new(1, 0, 0, 42)
        f.BackgroundColor3 = Library.Colors.DARK_GREY
        f.Text = ""
        f.AutoButtonColor = false
        createCorner(f, 12)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.Position = UDim2.new(0, 15, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0, 38, 0, 20)
        box.Position = UDim2.new(1, -50, 0.5, -10)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createCorner(box, 10)

        local dot = Instance.new("Frame", box)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(0, 2, 0.5, -8)
        dot.BackgroundColor3 = Color3.new(1,1,1)
        createCorner(dot, 8)

        f.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(box, TweenInfo.new(0.25), {
                BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40,40,40)
            }):Play()

            TweenService:Create(dot, TweenInfo.new(0.25), {
                Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
            }):Play()

            cb(state)
        end)
    end

    function tab:CreateSlider(text, min, max, default, cb)
        local sliderFrame = Instance.new("Frame", inner)
        sliderFrame.Size = UDim2.new(1, 0, 0, 55)
        sliderFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(sliderFrame, 12)

        local title = Instance.new("TextLabel", sliderFrame)
        title.Size = UDim2.new(1, -20, 0, 25)
        title.Position = UDim2.new(0, 15, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = text .. ": " .. default
        title.TextColor3 = Library.Colors.ACCENT_WHITE
        title.Font = Enum.Font.Gotham
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left

        local barBg = Instance.new("Frame", sliderFrame)
        barBg.Size = UDim2.new(0.9, 0, 0, 8)
        barBg.Position = UDim2.new(0.05, 0, 0.75, -5)
        barBg.BackgroundColor3 = Color3.fromRGB(35,35,35)
        createCorner(barBg, 4)

        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        barFill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createCorner(barFill, 4)

        local dragging = false

        local function update(input)
            local delta = math.clamp(
                (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X,
                0, 1
            )
            local value = math.floor(min + (max - min) * delta)
            barFill.Size = UDim2.new(delta,0,1,0)
            title.Text = text .. ": " .. value
            cb(value)
        end

        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging then update(input) end
        end)

        UserInputService.InputEnded:Connect(function()
            dragging = false
        end)
    end

    return tab
end

return Library
