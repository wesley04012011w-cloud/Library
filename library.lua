-- [[ BitcodeLibrary v6.5 - Edição Ghz Beta v1 ]]
-- Especialista: bitcode assistente
-- Melhoria: Input Tracking (ID Filtering) para Mobile Precision

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

-- [ SISTEMA DRAGGABLE COM FILTRO DE INPUT ]
local function makeDraggable(frame, handle)
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if not dragInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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
        if input == dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    main.Name = "MainFrame"
    main.BackgroundColor3 = Library.Colors.BACKGROUND_BLACK
    main.Position = UDim2.new(0.5, -175, 0.5, -125)
    main.Size = UDim2.new(0, 350, 0, 250) 
    main.ClipsDescendants = true
    main.Active = true -- Garante detecção de input
    createCorner(main, 15)
    self.MainFrame = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Library.Colors.NEON_ORANGE
    stroke.Thickness = 2

    -- TopBar
    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 38)
    topBar.BackgroundColor3 = Library.Colors.TOPBAR
    topBar.Active = true 
    makeDraggable(main, topBar)
    
    local topBarTitle = Instance.new("TextLabel", topBar)
    topBarTitle.Size = UDim2.new(1, -60, 1, 0)
    topBarTitle.Position = UDim2.new(0, 15, 0, 0)
    topBarTitle.BackgroundTransparency = 1
    topBarTitle.Text = "Ghz betav1"
    topBarTitle.TextColor3 = Library.Colors.ACCENT_WHITE
    topBarTitle.Font = Enum.Font.GothamBold
    topBarTitle.TextSize = 14
    topBarTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- [ SISTEMA DE RESIZE OTIMIZADO ]
    local resizeBtn = Instance.new("TextButton", main)
    resizeBtn.Size = UDim2.new(0, 30, 0, 30)
    resizeBtn.Position = UDim2.new(1, -30, 1, -30)
    resizeBtn.BackgroundTransparency = 1
    resizeBtn.Text = "◢"
    resizeBtn.TextColor3 = Library.Colors.NEON_ORANGE
    resizeBtn.TextSize = 22
    resizeBtn.ZIndex = 10
    resizeBtn.Active = true

    local currentResizeInput = nil

    resizeBtn.InputBegan:Connect(function(input)
        if not currentResizeInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            currentResizeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == currentResizeInput then
            local mousePos = input.Position
            local absPos = main.AbsolutePosition
            local newSizeX = math.clamp(mousePos.X - absPos.X, 280, 800)
            local newSizeY = math.clamp(mousePos.Y - absPos.Y, 180, 600)
            main.Size = UDim2.new(0, newSizeX, 0, newSizeY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == currentResizeInput then
            currentResizeInput = nil
        end
    end)

    -- Layout Estrutural
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

    -- Holder pra cortar conteúdo (resolve borda bugada)
local contentHolder = Instance.new("Frame", main)
contentHolder.Position = UDim2.new(0, 105, 0, 38) -- alinhado com topbar
contentHolder.Size = UDim2.new(1, -105, 1, -38)
contentHolder.BackgroundTransparency = 1
contentHolder.ClipsDescendants = true

local container = Instance.new("Frame", contentHolder)
container.Size = UDim2.new(1, 0, 1, 0)
container.BackgroundTransparency = 1

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

local padding = Instance.new("UIPadding", content)
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.PaddingBottom = UDim.new(0, 5)

    content.Size = UDim2.new(1, -4, 1, -4)
    content.Position = UDim2.new(0, 2, 0, 2)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollBarThickness = 2
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        content.Visible = true
        for _, v in pairs(self.TabList:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Library.Colors.DARK_GREY end end
        btn.BackgroundColor3 = Library.Colors.NEON_ORANGE
    end)

    if not self._hasTab then self._hasTab = true content.Visible = true btn.BackgroundColor3 = Library.Colors.NEON_ORANGE end

    local tab = {}

    -- [ SLIDER COM FILTRO DE INPUT ]
    function tab:CreateSlider(text, min, max, default, cb)
        local sliderFrame = Instance.new("Frame", content)
        sliderFrame.Size = UDim2.new(1, -10, 0, 55)
        sliderFrame.BackgroundColor3 = Library.Colors.DARK_GREY
        sliderFrame.Active = true
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
        barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        barBg.Active = true
        createCorner(barBg, 4)

        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        barFill.BackgroundColor3 = Library.Colors.NEON_ORANGE
        createCorner(barFill, 4)

        local currentSliderInput = nil

        local function update(input)
            local inputPos = input.Position.X
            local barPos = barBg.AbsolutePosition.X
            local barSize = barBg.AbsoluteSize.X
            local delta = math.clamp((inputPos - barPos) / barSize, 0, 1)
            local value = math.floor(min + (max - min) * delta)
            barFill.Size = UDim2.new(delta, 0, 1, 0)
            title.Text = text .. ": " .. value
            cb(value)
        end

        barBg.InputBegan:Connect(function(input)
            if not currentSliderInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                currentSliderInput = input
                update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == currentSliderInput then
                update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input == currentSliderInput then
                currentSliderInput = nil
            end
        end)
    end

    -- [ OUTROS COMPONENTES MANTIDOS ]
    function tab:CreateToggle(text, cb)
        local state = false
        local f = Instance.new("TextButton", content)
        f.Size = UDim2.new(0.96, 0, 0, 42)
        f.BackgroundColor3 = Library.Colors.DARK_GREY
        f.Text = ""
        f.AutoButtonColor = false
        f.Active = true
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
            TweenService:Create(box, TweenInfo.new(0.25), {BackgroundColor3 = state and Library.Colors.NEON_ORANGE or Color3.fromRGB(40, 40, 40)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.25), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            cb(state)
        end)
    end

    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.96, 0, 0, 38)
        b.Text = text
        b.BackgroundColor3 = Library.Colors.HIGHLIGHT
        b.TextColor3 = Library.Colors.ACCENT_WHITE
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 13
        createCorner(b, 12)
        b.MouseButton1Click:Connect(cb)
    end

    return tab
end

return Library
