-- [[ BitcodeLibrary v5.5 - Edição Ghz Beta v1 ]]
-- Especialista: bitcode assistente
-- Upgrade: Resize Manual (◢), Toggles/Sliders Estabilizados

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
    c.CornerRadius = UDim.new(0, r or 8)
end

-- Função de Arrastar (TopBar)
local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

function Library:Init()
    local old = CoreGui:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "BitcodeLibrary"
    screen.ResetOnSpawn = false
    self.ScreenGui = screen

    -- Frame Principal
    local main = Instance.new("Frame", screen)
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.Position = UDim2.new(0.5, -200, 0.5, -150)
    main.Size = UDim2.new(0, 400, 0, 300) 
    main.ClipsDescendants = true
    main.Visible = false
    createCorner(main, 10)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 1.5

    -- TopBar
    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Library.Colors.TOPBAR
    topBar.BorderSizePixel = 0
    makeDraggable(main, topBar)
    
    local topBarTitle = Instance.new("TextLabel", topBar)
    topBarTitle.Size = UDim2.new(1, -60, 1, 0)
    topBarTitle.Position = UDim2.new(0, 12, 0, 0)
    topBarTitle.BackgroundTransparency = 1
    topBarTitle.Text = "Ghz betav1"
    topBarTitle.TextColor3 = Library.Colors.ACCENT_WHITE
    topBarTitle.Font = Enum.Font.GothamBold
    topBarTitle.TextSize = 13
    topBarTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão Fechar
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.Text = "×"
    closeBtn.BackgroundColor3 = Library.Colors.RED
    closeBtn.TextColor3 = Color3.new(1,1,1)
    createCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

    -- Grip de Redimensionamento (◢)
    local resizeBtn = Instance.new("TextButton", main)
    resizeBtn.Size = UDim2.new(0, 20, 0, 20)
    resizeBtn.Position = UDim2.new(1, -20, 1, -20)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Text = "◢"
    resizeBtn.TextColor3 = Library.Colors.NEON_ORANGE
    resizeBtn.TextSize = 18
    resizeBtn.ZIndex = 10

    local resizing = false
    resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = main.AbsolutePosition
            local newSizeX = math.max(300, mousePos.X - absPos.X)
            local newSizeY = math.max(200, mousePos.Y - absPos.Y - 36) -- 36 compensa a TopBar
            main.Size = UDim2.new(0, newSizeX, 0, newSizeY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    -- Layout Estrutural
    local sidebar = Instance.new("Frame", main)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.Size = UDim2.new(0, 110, 1, -35)
    sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    sidebar.BorderSizePixel = 0

    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Size = UDim2.new(1, -10, 1, -10)
    tabList.Position = UDim2.new(0, 5, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", tabList).Padding = UDim.new(0, 5)

    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0, 120, 0, 45)
    container.Size = UDim2.new(1, -130, 1, -55)
    container.BackgroundTransparency = 1
    self.Container = container
    self.TabList = tabList

    -- Botão Toggle Geral (G)
    local tBtn = Instance.new("TextButton", screen)
    tBtn.Size = UDim2.new(0, 45, 0, 45)
    tBtn.Position = UDim2.new(0, 20, 0.5, 0)
    tBtn.Text = "G"
    tBtn.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    tBtn.TextColor3 = Library.Colors.NEON_ORANGE
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 18
    createCorner(tBtn, 22)
    Instance.new("UIStroke", tBtn).Color = Library.Colors.NEON_ORANGE
    tBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

    return self
end

function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabList)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = name
    btn.BackgroundColor3 = Library.Colors.DARK_GREY
    btn.TextColor3 = Library.Colors.ACCENT_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    createCorner(btn, 6)

    local content = Instance.new("ScrollingFrame", self.Container)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = Library.Colors.NEON_ORANGE
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        content.Visible = true
        for _, v in pairs(self.TabList:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Library.Colors.DARK_GREY end end
        btn.BackgroundColor3 = Library.Colors.NEON_ORANGE
    end)

    if not self._hasTab then self._hasTab = true content.Visible = true btn.BackgroundColor3 = Library.Colors.NEON_ORANGE end

    local tab = {}

    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.98, 0, 0, 35)
        b.Text = text
        b.BackgroundColor3 = Library.Colors.HIGHLIGHT
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 12
        createCorner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text, cb)
        local state = false
        local f = Instance.new("Frame", content)
        f.Size = UDim2.new(0.98, 0, 0, 40)
        f.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(f, 6)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0, 36, 0, 18)
        box.Position = UDim2.new(1, -48, 0.5, -9)
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        createCorner(box, 9)

        local dot = Instance.new("Frame", box)
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0, 2, 0.5, -7)
        dot.BackgroundColor3 = Color3.new(1,1,1)
        createCorner(dot, 7)

        local clickBtn = Instance.new("TextButton", f)
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""

        clickBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(45, 45, 45)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            cb(state)
        end)
    end

    function tab:CreateSlider(text, min, max, default, cb)
        local sliderFrame = Instance.new("Frame", content)
        sliderFrame.Size = UDim2.new(0.98, 0, 0, 50)
        sliderFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(sliderFrame, 6)

        local title = Instance.new("TextLabel", sliderFrame)
        title.Size = UDim2.new(1, -20, 0, 25)
        title.Position = UDim2.new(0, 12, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = text .. ": " .. default
        title.TextColor3 = Library.Colors.ACCENT_WHITE
        title.Font = Enum.Font.Gotham
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left

        local barBg = Instance.new("Frame", sliderFrame)
        barBg.Size = UDim2.new(0.92, 0, 0, 6)
        barBg.Position = UDim2.new(0.04, 0, 0.75, -5)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        createCorner(barBg, 3)

        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        barFill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createCorner(barFill, 3)

        local function update(input)
            local delta = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * delta)
            barFill.Size = UDim2.new(delta, 0, 1, 0)
            title.Text = text .. ": " .. value
            cb(value)
        end

        local dragging = false
        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    function tab:CreateDropdown(text, list, cb)
        local expanded = false
        local dropFrame = Instance.new("Frame", content)
        dropFrame.Size = UDim2.new(0.98, 0, 0, 35)
        dropFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        dropFrame.ClipsDescendants = true
        createCorner(dropFrame, 6)

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
        local layout = Instance.new("UIListLayout", items)

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
                TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.98, 0, 0, 35)}):Play()
                cb(v)
            end)
        end

        dBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            local targetSize = expanded and (35 + (#list * 30)) or 35
            TweenService:Create(dropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.98, 0, 0, targetSize)}):Play()
        end)
    end

    return tab
end

return Library
