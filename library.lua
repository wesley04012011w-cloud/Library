-- BitcodeLibrary v2
-- By Dark Quote

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- ===== CONFIG =====
Library.Colors = {
    NEON_ORANGE = Color3.fromRGB(255, 100, 0),
    BACKGROUND_BLACK = Color3.fromRGB(10, 10, 10),
    ACCENT_WHITE = Color3.fromRGB(255, 255, 255)
}

Library.MinSize = Vector2.new(350, 250)
Library.MaxSize = Vector2.new(550, 400)

-- ===== UTILS =====
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function createUICorner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 6)
end

-- ===== INIT GUI =====
function Library:Init()
    -- Limpar GUI antiga
    local oldGui = game:GetService("CoreGui"):FindFirstChild("BitcodeLibrary") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BitcodeLibrary")
    if oldGui then oldGui:Destroy() end

    -- Criar ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "BitcodeLibrary"
    self.ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true

    -- Tamanho responsivo
    local screenSize = workspace.CurrentCamera.ViewportSize
    self.Width = math.clamp(screenSize.X * 0.45, self.MinSize.X, self.MaxSize.X)
    self.Height = math.clamp(screenSize.Y * 0.55, self.MinSize.Y, self.MaxSize.Y)

    -- MainFrame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Position = UDim2.new(0.5, -self.Width/2, 0.5, -self.Height/2)
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0) -- começa fechado
    self.MainFrame.BackgroundColor3 = self.Colors.BACKGROUND_BLACK
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    createUICorner(self.MainFrame, 12)

    -- Main stroke
    local stroke = Instance.new("UIStroke", self.MainFrame)
    stroke.Color = self.Colors.NEON_ORANGE
    stroke.Thickness = 2

    -- Drag
    makeDraggable(self.MainFrame)

    -- ToggleButton
    self.ToggleButton = Instance.new("TextButton")
    self.ToggleButton.Name = "OpenClose"
    self.ToggleButton.Parent = self.ScreenGui
    self.ToggleButton.Position = UDim2.new(0, 15, 0, 120)
    self.ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    self.ToggleButton.BackgroundColor3 = self.Colors.BACKGROUND_BLACK
    self.ToggleButton.Text = "W"
    self.ToggleButton.TextColor3 = self.Colors.NEON_ORANGE
    self.ToggleButton.Font = Enum.Font.GothamBold
    self.ToggleButton.TextSize = 12
    createUICorner(self.ToggleButton, 25)

    local tbStroke = Instance.new("UIStroke", self.ToggleButton)
    tbStroke.Color = self.Colors.NEON_ORANGE
    tbStroke.Thickness = 1.5

    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Parent = self.MainFrame
    self.Sidebar.Size = UDim2.new(0, 120, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)

    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Parent = self.Sidebar
    self.TabList.Size = UDim2.new(1, -10, 1, -20)
    self.TabList.Position = UDim2.new(0, 5, 0, 10)
    self.TabList.BackgroundTransparency = 1
    self.TabList.ScrollBarThickness = 0
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout", self.TabList)
    layout.Padding = UDim.new(0, 5)

    -- Container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Parent = self.MainFrame
    self.Container.Position = UDim2.new(0, 130, 0, 10)
    self.Container.Size = UDim2.new(1, -140, 1, -20)
    self.Container.BackgroundTransparency = 1

    -- ToggleButton funcional
    self.isOpen = false
    self.ToggleButton.MouseButton1Click:Connect(function()
        self.isOpen = not self.isOpen
        self.MainFrame.Visible = true
        local targetSize = self.isOpen and UDim2.new(0, self.Width, 0, self.Height) or UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = targetSize})
        tween:Play()
        if not self.isOpen then
            tween.Completed:Connect(function()
                if not self.isOpen then self.MainFrame.Visible = false end
            end)
        end
    end)
end

-- ===== CREATE TAB =====
function Library:CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = self.TabList
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBtn.TextColor3 = self.Colors.ACCENT_WHITE
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    createUICorner(TabBtn, 6)

    local Content = Instance.new("ScrollingFrame")
    Content.Parent = self.Container
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = self.Colors.NEON_ORANGE
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", Content)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Função de ativar aba
    TabBtn.MouseButton1Click:Connect(function()
        for _, c in pairs(self.Container:GetChildren()) do
            if c:IsA("ScrollingFrame") then c.Visible = false end
        end
        for _, b in pairs(self.TabList:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                b.TextColor3 = self.Colors.ACCENT_WHITE
            end
        end
        Content.Visible = true
        TabBtn.BackgroundColor3 = self.Colors.NEON_ORANGE
        TabBtn.TextColor3 = self.Colors.BACKGROUND_BLACK
    end)

    -- Primeiro tab visível
    if not self.activeTab then
        self.activeTab = true
        Content.Visible = true
        TabBtn.BackgroundColor3 = self.Colors.NEON_ORANGE
        TabBtn.TextColor3 = self.Colors.BACKGROUND_BLACK
    end

    local tab = {}

    -- ===== ELEMENTOS =====
    function tab:CreateButton(text, cb)
        local B = Instance.new("TextButton")
        B.Parent = Content
        B.Size = UDim2.new(0.95, 0, 0, 35)
        B.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        B.TextColor3 = self.Colors.ACCENT_WHITE
        B.Text = text
        B.Font = Enum.Font.Gotham
        B.TextSize = 13
        createUICorner(B, 6)
        B.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text, cb)
        local state = false
        local T = Instance.new("Frame")
        T.Parent = Content
        T.Size = UDim2.new(0.95, 0, 0, 40)
        T.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        createUICorner(T, 6)

        local L = Instance.new("TextLabel")
        L.Parent = T
        L.Size = UDim2.new(0.7, 0, 1, 0)
        L.Position = UDim2.new(0, 10, 0, 0)
        L.BackgroundTransparency = 1
        L.Text = text
        L.TextColor3 = self.Colors.ACCENT_WHITE
        L.Font = Enum.Font.Gotham
        L.TextSize = 13
        L.TextXAlignment = Enum.TextXAlignment.Left

        local Box = Instance.new("Frame")
        Box.Parent = T
        Box.Position = UDim2.new(0.85, 0, 0.25, 0)
        Box.Size = UDim2.new(0, 20, 0, 20)
        Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createUICorner(Box, 4)

        T.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
        end)
    end

    function tab:CreateSlider(text, min, max, def, cb)
        local S = Instance.new("Frame")
        S.Parent = Content
        S.Size = UDim2.new(0.95, 0, 0, 50)
        S.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        createUICorner(S, 6)

        local L = Instance.new("TextLabel")
        L.Parent = S
        L.Position = UDim2.new(0, 10, 0, 5)
        L.Size = UDim2.new(1, -20, 0, 20)
        L.BackgroundTransparency = 1
        L.Text = text .. ": " .. def
        L.TextColor3 = self.Colors.ACCENT_WHITE
        L.Font = Enum.Font.Gotham
        L.TextSize = 12
        L.TextXAlignment = Enum.TextXAlignment.Left

        local Bar = Instance.new("Frame")
        Bar.Parent = S
        Bar.Position = UDim2.new(0.05, 0, 0.7, 0)
        Bar.Size = UDim2.new(0.9, 0, 0, 6)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createUICorner(Bar, 3)

        local Fill = Instance.new("Frame")
        Fill.Parent = Bar
        Fill.Size = UDim2.new((def - min)/(max-min),0,1,0)
        Fill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createUICorner(Fill, 3)

        local dragging = false
        local function update(input)
            local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * p)
            Fill.Size = UDim2.new(p,0,1,0)
            L.Text = text .. ": " .. v
            cb(v)
        end

        S.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
    end

    return tab
end

return Library