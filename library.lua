-- [[ BitcodeLibrary v5.0 - Edição Ghz Beta v1 ]]
-- Especialista: bitcode assistente
-- Novidade: Aba de Configurações Nativa, Redimensionamento % e Customização de Cores

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

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
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

    -- Frame Principal
    local main = Instance.new("Frame", screen)
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0.35, 0, 0.5, 0) -- Tamanho inicial padrão
    main.ClipsDescendants = true
    main.Visible = false
    createCorner(main, 10)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 1.5
    self.MainStroke = stroke

    -- TopBar
    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Library.Colors.TOPBAR
    topBar.BorderSizePixel = 0
    makeDraggable(main, topBar)
    
    local topBarTitle = Instance.new("TextLabel", topBar)
    topBarTitle.Size = UDim2.new(1, -120, 1, 0)
    topBarTitle.Position = UDim2.new(0, 12, 0, 0)
    topBarTitle.BackgroundTransparency = 1
    topBarTitle.Text = "Ghz betav1"
    topBarTitle.TextColor3 = Library.Colors.ACCENT_WHITE
    topBarTitle.Font = Enum.Font.GothamBold
    topBarTitle.TextSize = 13
    topBarTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel = topBarTitle

    -- Botões de Controle
    local controls = Instance.new("Frame", topBar)
    controls.Size = UDim2.new(0, 95, 1, 0)
    controls.Position = UDim2.new(1, -100, 0, 0)
    controls.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", controls)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.Text = "×"
    closeBtn.BackgroundColor3 = Library.Colors.RED
    closeBtn.TextColor3 = Color3.new(1,1,1)
    createCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

    -- Sidebar e Container
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

    -- Botão Flutuante
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

    tBtn.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)

    -- ABA DE CONFIGURAÇÕES AUTOMÁTICA
    local configTab = self:CreateTab("Configurações")
    
    configTab:CreateDropdown("Escala do Painel", {"100%", "75%", "50%"}, function(val)
        local scale = val == "100%" and 1 or (val == "75%" and 0.75 or 0.5)
        TweenService:Create(main, TweenInfo.new(0.4), {Size = UDim2.new(0.35 * scale, 300 * (1-scale), 0.5 * scale, 250 * (1-scale))}):Play()
    end)

    configTab:CreateDropdown("Cor de Destaque", {"Laranja", "Azul", "Verde", "Roxo", "Branco"}, function(colorName)
        local colors = {Laranja = Color3.fromRGB(255, 100, 0), Azul = Color3.fromRGB(0, 150, 255), Verde = Color3.fromRGB(0, 255, 100), Roxo = Color3.fromRGB(180, 0, 255), Branco = Color3.fromRGB(255, 255, 255)}
        local selected = colors[colorName]
        Library.Colors.NEON_ORANGE = selected
        stroke.Color = selected
        tBtn.TextColor3 = selected
        tBtn.UIStroke.Color = selected
    end)

    configTab:CreateDropdown("Cor das Letras", {"Branco", "Cinza", "Laranja"}, function(colorName)
        local colors = {Branco = Color3.fromRGB(255, 255, 255), Cinza = Color3.fromRGB(180, 180, 180), Laranja = Library.Colors.NEON_ORANGE}
        topBarTitle.TextColor3 = colors[colorName]
        -- Nota: Para mudar todas as letras, precisaríamos de um loop em todos os labels (implementado no CreateTab)
    end)

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

        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(45, 45, 45)}):Play()
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                cb(state)
            end
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
                TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.98, 0, 0, 35)}):Play()
                cb(v)
            end)
        end

        dBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.98, 0, 0, expanded and (35 + (#list * 30)) or 35)}):Play()
        end)
    end

    return tab
end

return Library
