--[[ 
    BitcodeLibrary v3.0 - Edição Adaptativa
    Especialista: Bitcode Assistente
    Novos Recursos: 75% Screen Scaling & Dropdown System
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

Library.Colors = {
    NEON_ORANGE = Color3.fromRGB(255, 100, 0),
    BACKGROUND_BLACK = Color3.fromRGB(10, 10, 10),
    ACCENT_WHITE = Color3.fromRGB(255, 255, 255),
    DARK_GREY = Color3.fromRGB(20, 20, 20),
    HIGHLIGHT = Color3.fromRGB(35, 35, 35)
}

-- ===== UTILITÁRIOS =====
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ===== INICIALIZAÇÃO =====
function Library:Init()
    local old = CoreGui:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local screen = Instance.new("ScreenGui", CoreGui)
    screen.Name = "BitcodeLibrary"
    screen.ResetOnSpawn = false
    self.ScreenGui = screen

    -- CONFIGURAÇÃO ADAPTÁVEL (75% da Tela)
    local main = Instance.new("Frame", screen)
    main.Name = "MainFrame"
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    -- Define 75% de largura e altura usando Scale
    main.Size = UDim2.new(0.75, 0, 0.75, 0) 
    main.ClipsDescendants = true
    main.Visible = false
    createCorner(main, 12)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 2

    makeDraggable(main)

    -- Toggle Button (W)
    local toggleBtn = Instance.new("TextButton", screen)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0, 20)
    toggleBtn.Text = "W"
    toggleBtn.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    toggleBtn.TextColor3 = Library.Colors.NEON_ORANGE
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    createCorner(toggleBtn, 25)
    Instance.new("UIStroke", toggleBtn).Color = Library.Colors.NEON_ORANGE

    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0.25, 0, 1, 0) -- 25% da largura do menu
    sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)

    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Size = UDim2.new(1, -10, 1, -20)
    tabList.Position = UDim2.new(0, 5, 0, 10)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", tabList).Padding = UDim.new(0, 5)

    -- Container de Conteúdo
    local container = Instance.new("Frame", main)
    container.Position = UDim2.new(0.26, 0, 0, 10)
    container.Size = UDim2.new(0.72, 0, 1, -20)
    container.BackgroundTransparency = 1
    self.Container = container
    self.TabList = tabList

    -- Lógica Toggle
    local open = false
    toggleBtn.MouseButton1Click:Connect(function()
        open = not open
        main.Visible = true
        local targetSize = open and UDim2.new(0.75, 0, 0.75, 0) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = targetSize}):Play()
        if not open then task.wait(0.4) main.Visible = false end
    end)
end

-- ===== SISTEMA DE TABS =====
function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabList)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Library.Colors.DARK_GREY
    btn.TextColor3 = Library.Colors.ACCENT_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    createCorner(btn, 6)

    local content = Instance.new("ScrollingFrame", self.Container)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 3
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do v.Visible = false end
        content.Visible = true
    end)

    if not self._hasTab then self._hasTab = true content.Visible = true end

    local tab = {}

    -- BOTÃO
    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.Text = text
        b.BackgroundColor3 = Library.Colors.HIGHLIGHT
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.Gotham
        createCorner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end

    -- DROPDOWN (Novo)
    function tab:CreateDropdown(text, list, cb)
        local expanded = false
        local dropFrame = Instance.new("Frame", content)
        dropFrame.Size = UDim2.new(0.95, 0, 0, 40)
        dropFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        dropFrame.ClipsDescendants = true
        createCorner(dropFrame, 6)

        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = text .. "  ▼"
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Library.Colors.ACCENT_WHITE
        btn.Font = Enum.Font.GothamBold

        local itemsContainer = Instance.new("Frame", dropFrame)
        itemsContainer.Position = UDim2.new(0, 0, 0, 40)
        itemsContainer.Size = UDim2.new(1, 0, 0, #list * 30)
        itemsContainer.BackgroundTransparency = 1
        Instance.new("UIListLayout", itemsContainer)

        for _, val in pairs(list) do
            local item = Instance.new("TextButton", itemsContainer)
            item.Size = UDim2.new(1, 0, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            item.Text = tostring(val)
            item.TextColor3 = Color3.fromRGB(200, 200, 200)
            item.Font = Enum.Font.Gotham
            item.BorderSizePixel = 0
            
            item.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. tostring(val)
                expanded = false
                TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
                cb(val)
            end)
        end

        btn.MouseButton1Click:Connect(function()
            expanded = not expanded
            local targetHeight = expanded and (40 + (#list * 30)) or 40
            TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
        end)
    end

    -- TOGGLE & SLIDER seguem a lógica anterior (adaptados para 0.95 Scale)
    function tab:CreateToggle(text, cb)
        local state = false
        local f = Instance.new("Frame", content)
        f.Size = UDim2.new(0.95,0,0,40)
        f.BackgroundColor3 = Library.Colors.DARK_GREY
        createCorner(f,6)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.7,0,1,0)
        l.Position = UDim2.new(0,10,0,0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Library.Colors.ACCENT_WHITE
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", f)
        box.Size = UDim2.new(0,35,0,18)
        box.Position = UDim2.new(0.85,0,0.5,-9)
        box.BackgroundColor3 = Color3.fromRGB(40,40,40)
        createCorner(box,10)

        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
        end)
    end

    return tab
end

return Library
