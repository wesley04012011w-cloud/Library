-- BitcodeLibrary v2.1 (Fixed)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

Library.Colors = {
    NEON_ORANGE = Color3.fromRGB(255, 100, 0),
    BACKGROUND_BLACK = Color3.fromRGB(10, 10, 10),
    ACCENT_WHITE = Color3.fromRGB(255, 255, 255)
}

-- ===== UTILS =====
local function createCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 6)
end

local function makeDraggable(frame)
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ===== INIT =====
function Library:Init()
    local old = game:GetService("CoreGui"):FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui")
    screen.Name = "BitcodeLibrary"
    screen.Parent = game:GetService("CoreGui")
    screen.ResetOnSpawn = false
    self.ScreenGui = screen

    local cam = workspace.CurrentCamera
    local size = cam.ViewportSize

    local width = math.clamp(size.X * 0.45, 350, 550)
    local height = math.clamp(size.Y * 0.55, 250, 400)

    local main = Instance.new("Frame")
    main.Parent = screen
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.ClipsDescendants = true
    createCorner(main, 12)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 2

    makeDraggable(main)

    -- Toggle Button
    local toggle = Instance.new("TextButton")
    toggle.Parent = screen
    toggle.Size = UDim2.new(0, 50, 0, 50)
    toggle.Position = UDim2.new(0, 15, 0, 120)
    toggle.Text = "W"
    toggle.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    toggle.TextColor3 = Library.Colors.NEON_ORANGE
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    createCorner(toggle, 25)

    local stroke2 = Instance.new("UIStroke", toggle)
    stroke2.Color = Library.Colors.NEON_ORANGE

    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(5,5,5)

    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Size = UDim2.new(1, -10, 1, -20)
    tabList.Position = UDim2.new(0, 5, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", tabList)
    layout.Padding = UDim.new(0, 5)

    -- Container
    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 130, 0, 10)
    container.Size = UDim2.new(1, -140, 1, -20)
    container.BackgroundTransparency = 1

    self.TabList = tabList
    self.Container = container
    self.Width = width
    self.Height = height

    -- Toggle logic
    local open = false
    toggle.MouseButton1Click:Connect(function()
        open = not open
        main.Visible = true

        local target = open and UDim2.new(0, width, 0, height) or UDim2.new(0,0,0,0)

        local t = TweenService:Create(main, TweenInfo.new(0.3), {Size = target})
        t:Play()

        if not open then
            t.Completed:Connect(function()
                if not open then main.Visible = false end
            end)
        end
    end)
end

-- ===== TAB =====
function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabList)
    btn.Size = UDim2.new(1,0,0,35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.TextColor3 = Library.Colors.ACCENT_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    createCorner(btn, 6)

    local content = Instance.new("ScrollingFrame", self.Container)
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 3

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        content.Visible = true
    end)

    if not self._hasTab then
        self._hasTab = true
        content.Visible = true
    end

    local tab = {}

    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.95,0,0,35)
        b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(25,25,25)
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        createCorner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text, cb)
        local state = false

        local f = Instance.new("Frame", content)
        f.Size = UDim2.new(0.95,0,0,40)
        f.BackgroundColor3 = Color3.fromRGB(20,20,20)
        createCorner(f,6)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7,0,1,0)
        l.Position = UDim2.new(0,10,0,0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0,20,0,20)
        box.Position = UDim2.new(0.85,0,0.25,0)
        box.BackgroundColor3 = Color3.fromRGB(40,40,40)
        createCorner(box,4)

        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40,40,40)
                }):Play()
                cb(state)
            end
        end)
    end

    function tab:CreateSlider(text, min, max, def, cb)
        local f = Instance.new("Frame", content)
        f.Size = UDim2.new(0.95,0,0,50)
        f.BackgroundColor3 = Color3.fromRGB(20,20,20)
        createCorner(f,6)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1,-20,0,20)
        l.Position = UDim2.new(0,10,0,5)
        l.BackgroundTransparency = 1
        l.Text = text .. ": " .. def
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham

        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(0.9,0,0,6)
        bar.Position = UDim2.new(0.05,0,0.7,0)
        bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
        createCorner(bar,3)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createCorner(fill,3)

        local dragging = false

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local pos = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                pos = math.clamp(pos,0,1)

                local value = math.floor(min + (max-min)*pos)

                fill.Size = UDim2.new(pos,0,1,0)
                l.Text = text .. ": " .. value

                cb(value)
            end
        end)
    end

    return tab
end

return Library
