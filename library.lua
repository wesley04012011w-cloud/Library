-- [[ BitcodeLibrary v4.0 - Estável & Completa ]]
-- Especialista: bitcode assistente
-- Inclui: Buttons, Toggles, Dropdowns, Sliders e Responsividade

local Library = {}
Library.__index = Library

Library.Colors = {
    NEON_ORANGE = Color3.fromRGB(255, 100, 0),
    BACKGROUND_BLACK = Color3.fromRGB(12, 12, 12),
    ACCENT_WHITE = Color3.fromRGB(255, 255, 255),
    DARK_GREY = Color3.fromRGB(25, 25, 25),
    HIGHLIGHT = Color3.fromRGB(40, 40, 40)
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function createCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function Library:Init()
    local old = CoreGui:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "BitcodeLibrary"
    screen.ResetOnSpawn = false
    self.ScreenGui = screen

    local main = Instance.new("Frame", screen)
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 350, 0.75, 0) 
    main.ClipsDescendants = true
    main.Visible = false
    createCorner(main, 10)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 1.8

    makeDraggable(main)

    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 100, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    sidebar.BorderSizePixel = 0

    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Size = UDim2.new(1, -10, 1, -20)
    tabList.Position = UDim2.new(0, 5, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", tabList)
    layout.Padding = UDim.new(0, 6)

    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 110, 0, 10)
    container.Size = UDim2.new(1, -120, 1, -20)
    container.BackgroundTransparency = 1
    self.Container = container
    self.TabList = tabList

    local tBtn = Instance.new("TextButton", screen)
    tBtn.Size = UDim2.new(0, 45, 0, 45)
    tBtn.Position = UDim2.new(0, 15, 0.5, 0)
    tBtn.Text = "W"
    tBtn.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    tBtn.TextColor3 = Library.Colors.NEON_ORANGE
    tBtn.Font = Enum.Font.GothamBold
    createCorner(tBtn, 22)
    Instance.new("UIStroke", tBtn).Color = Library.Colors.NEON_ORANGE

    local open = false
    tBtn.MouseButton1Click:Connect(function()
        open = not open
        main.Visible = true
        local targetSize = open and UDim2.new(0, 350, 0.75, 0) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        if not open then task.wait(0.4) if not open then main.Visible = false end end
    end)
    
    return self
end

function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabList)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = name
    btn.BackgroundColor3 = Library.Colors.DARK_GREY
    btn.TextColor3 = Library.Colors.ACCENT_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    createCorner(btn, 4)

    local content = Instance.new("ScrollingFrame", self.Container)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Library.Colors.NEON_ORANGE
    local contentLayout = Instance.new("UIListLayout", content)
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do 
            if v:IsA("ScrollingFrame") then v.Visible = false end 
        end
        content.Visible = true
    end)

    if not self._hasTab then self._hasTab = true content.Visible = true end

    local tab = {}

    -- FUNÇÃO BOTÃO
    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.95, 0, 0, 32)
        b.Text = text
        b.BackgroundColor3 = Library.Colors.HIGHLIGHT
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        createCorner(b, 5)
        b.MouseButton1Click:Connect(cb)
    end

    -- FUNÇÃO TOGGLE
    function tab:CreateToggle(text, cb)
        local state = false
        local f = Instance.new("Frame", content)
        f.Size = UDim2.new(0.95, 0, 0, 38)
        f.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(f, 5)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0, 32, 0, 16)
        box.Position = UDim2.new(1, -42, 0.5, -8)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createCorner(box, 8)

        local dot = Instance.new("Frame", box)
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        createCorner(dot, 6)

        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                cb(state)
            end
        end)
    end

    -- FUNÇÃO SLIDER (Corrigida e Integrada)
    function tab:CreateSlider(text, min, max, default, cb)
        local sliderFrame = Instance.new("Frame", content)
        sliderFrame.Size = UDim2.new(0.95, 0, 0, 45)
        sliderFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(sliderFrame, 5)

        local title = Instance.new("TextLabel", sliderFrame)
        title.Size = UDim2.new(1, 0, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = text .. ": " .. default
        title.TextColor3 = Library.Colors.ACCENT_WHITE
        title.Font = Enum.Font.Gotham
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left

        local barBg = Instance.new("Frame", sliderFrame)
        barBg.Size = UDim2.new(0.9, 0, 0, 4)
        barBg.Position = UDim2.new(0.05, 0, 0.75, 0)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createCorner(barBg, 2)

        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        barFill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createCorner(barFill, 2)

        local dragging = false
        local function update(input)
            local delta = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * delta)
            barFill.Size = UDim2.new(delta, 0, 1, 0)
            title.Text = text .. ": " .. value
            cb(value)
        end

        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- FUNÇÃO DROPDOWN
    function tab:CreateDropdown(text, list, cb)
        local expanded = false
        local dropFrame = Instance.new("Frame", content)
        dropFrame.Size = UDim2.new(0.95, 0, 0, 35)
        dropFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        dropFrame.ClipsDescendants = true
        createCorner(dropFrame, 5)

        local dBtn = Instance.new("TextButton", dropFrame)
        dBtn.Size = UDim2.new(1, 0, 0, 35)
        dBtn.Text = text .. "  ▼"
        dBtn.BackgroundTransparency = 1
        dBtn.TextColor3 = Library.Colors.ACCENT_WHITE
        dBtn.Font = Enum.Font.GothamBold
        dBtn.TextSize = 12

        local items = Instance.new("Frame", dropFrame)
        items.Position = UDim2.new(0, 0, 0, 35)
        items.Size = UDim2.new(1, 0, 0, #list * 30)
        items.BackgroundTransparency = 1
        Instance.new("UIListLayout", items)

        for _, v in pairs(list) do
            local item = Instance.new("TextButton", items)
            item.Size = UDim2.new(1, 0, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            item.Text = v
            item.TextColor3 = Color3.fromRGB(200, 200, 200)
            item.Font = Enum.Font.Gotham
            item.TextSize = 11
            item.BorderSizePixel = 0
            item.MouseButton1Click:Connect(function()
                dBtn.Text = text .. ": " .. v
                expanded = false
                TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
                cb(v)
            end)
        end

        dBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            local target = expanded and (35 + (#list * 30)) or 35
            TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, target)}):Play()
        end)
    end

    return tab
end

return Library
