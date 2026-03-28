--[[
    BITCODE LIBRARY - HYBRID EDITION (V2 DESIGN + V3.2 LOGIC)
    Especialista: bitcode (Assistente de Programação)
    Status: Sistema Operacional
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- ===== CONFIGURAÇÃO DE CORES (NEON TECH) =====
Library.Colors = {
    Main = Color3.fromRGB(255, 100, 0), -- Laranja Neon
    Bg = Color3.fromRGB(10, 10, 10),    -- Fundo Profundo
    Accent = Color3.fromRGB(255, 255, 255),
    DarkBg = Color3.fromRGB(5, 5, 5),   -- Sidebar
    ElementBg = Color3.fromRGB(20, 20, 20) -- Fundo de Botões/Toggles
}

-- ===== UTILITÁRIOS INTERNOS =====
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
end

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

-- ===== CORE ENGINE =====
function Library:Init()
    -- Limpeza de instâncias fantasmas
    local old = game:GetService("CoreGui"):FindFirstChild("BitcodeLibrary") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "BitcodeLibrary"
    self.Gui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    self.Gui.ResetOnSpawn = false

    -- Quadro Principal (MainFrame)
    self.Main = Instance.new("Frame")
    self.Main.Name = "MainFrame"
    self.Main.Parent = self.Gui
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- Inicia invisível para animação
    self.Main.Position = UDim2.new(0.5, -225, 0.5, -160)
    self.Main.BackgroundColor3 = self.Colors.Bg
    self.Main.ClipsDescendants = true
    corner(self.Main, 12)
    makeDraggable(self.Main)

    local stroke = Instance.new("UIStroke", self.Main)
    stroke.Color = self.Colors.Main
    stroke.Thickness = 2

    -- Botão de Alternância (Toggle HUD)
    local toggleBtn = Instance.new("TextButton", self.Gui)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 15, 0, 120)
    toggleBtn.BackgroundColor3 = self.Colors.Bg
    toggleBtn.Text = "W"
    toggleBtn.TextColor3 = self.Colors.Main
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    corner(toggleBtn, 25)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = self.Colors.Main

    local isOpen = false
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, 450, 0, 320) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    -- Barra Lateral (Sidebar)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 120, 1, 0)
    self.Sidebar.BackgroundColor3 = self.Colors.DarkBg
    
    local tabLayout = Instance.new("UIListLayout", self.Sidebar)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Container de Páginas
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Position = UDim2.new(0, 130, 0, 10)
    self.Container.Size = UDim2.new(1, -140, 1, -20)
    self.Container.BackgroundTransparency = 1

    self._firstTab = true
end

-- ===== SISTEMA DE ABAS =====
function Library:CreateTab(name)
    local tabBtn = Instance.new("TextButton", self.Sidebar)
    tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    tabBtn.BackgroundColor3 = self.Colors.ElementBg
    tabBtn.Text = name
    tabBtn.TextColor3 = self.Colors.Accent
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    corner(tabBtn, 6)

    local page = Instance.new("ScrollingFrame", self.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = self.Colors.Main
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do 
            if v:IsA("ScrollingFrame") then v.Visible = false end 
        end
        for _, b in pairs(self.Sidebar:GetChildren()) do 
            if b:IsA("TextButton") then b.BackgroundColor3 = self.Colors.ElementBg end 
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = self.Colors.Main
    end)

    if self._firstTab then
        self._firstTab = false
        page.Visible = true
        tabBtn.BackgroundColor3 = self.Colors.Main
    end

    local tab = {}

    -- Elemento: Botão
    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.Text = text
        b.TextColor3 = Library.Colors.Accent
        b.Font = Enum.Font.Gotham
        corner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end

    -- Elemento: Alternador (Toggle)
    function tab:CreateToggle(text, cb)
        local state = false
        local tFrame = Instance.new("Frame", page)
        tFrame.Size = UDim2.new(0.95, 0, 0, 40)
        tFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(tFrame, 6)

        local label = Instance.new("TextLabel", tFrame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", tFrame)
        box.Position = UDim2.new(0.85, 0, 0.25, 0)
        box.Size = UDim2.new(0, 20, 0, 20)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        corner(box, 4)

        tFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.Main or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
        end)
    end

    -- Elemento: Controle Deslizante (Slider)
    function tab:CreateSlider(text, min, max, def, cb)
        local sFrame = Instance.new("Frame", page)
        sFrame.Size = UDim2.new(0.95, 0, 0, 50)
        sFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(sFrame, 6)

        local label = Instance.new("TextLabel", sFrame)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. def
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", sFrame)
        bar.Position = UDim2.new(0.05, 0, 0.7, 0)
        bar.Size = UDim2.new(0.9, 0, 0, 6)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        corner(bar, 3)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((def - min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Library.Colors.Main
        corner(fill, 3)

        local dragging = false
        local function update()
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
            cb(val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging then update() end
        end)
    end

    -- Elemento: Menu Suspenso (Dropdown v3.2 Logic)
    function tab:CreateDropdown(text, options, cb)
        local dFrame = Instance.new("Frame", page)
        dFrame.Size = UDim2.new(0.95, 0, 0, 35)
        dFrame.BackgroundColor3 = Library.Colors.ElementBg
        dFrame.ClipsDescendants = true
        corner(dFrame, 6)

        local btn = Instance.new("TextButton", dFrame)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundTransparency = 1
        btn.Text = text .. "  [ + ]"
        btn.TextColor3 = Library.Colors.Accent
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12

        local dropContent = Instance.new("Frame", dFrame)
        dropContent.Position = UDim2.new(0, 0, 0, 35)
        dropContent.Size = UDim2.new(1, 0, 0, #options * 30)
        dropContent.BackgroundTransparency = 1

        for i, v in ipairs(options) do
            local opt = Instance.new("TextButton", dropContent)
            opt.Size = UDim2.new(1, 0, 0, 30)
            opt.Position = UDim2.new(0, 0, 0, (i-1)*30)
            opt.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            opt.Text = v
            opt.TextColor3 = Library.Colors.Accent
            opt.Font = Enum.Font.Gotham
            opt.BorderSizePixel = 0
            
            opt.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. v
                dFrame.Size = UDim2.new(0.95, 0, 0, 35)
                cb(v)
            end)
        end

        local dropped = false
        btn.MouseButton1Click:Connect(function()
            dropped = not dropped
            local targetSize = dropped and UDim2.new(0.95, 0, 0, 35 + (#options * 30)) or UDim2.new(0.95, 0, 0, 35)
            TweenService:Create(dFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
            btn.Text = dropped and text .. "  [ - ]" or text .. "  [ + ]"
        end)
    end

    return tab
end

-- ===== SISTEMA DE NOTIFICAÇÕES (v3.2 Logic) =====
function Library:Notify(text)
    local n = Instance.new("TextLabel")
    n.Parent = self.Gui
    n.Size = UDim2.new(0, 220, 0, 45)
    n.Position = UDim2.new(1, 20, 1, -70) -- Inicia fora da tela (Direita)
    n.BackgroundColor3 = self.Colors.Bg
    n.TextColor3 = self.Colors.Main
    n.Text = "  ⚡ " .. text
    n.Font = Enum.Font.GothamBold
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    corner(n, 8)
    
    local nStroke = Instance.new("UIStroke", n)
    nStroke.Color = self.Colors.Main
    nStroke.Thickness = 1.5

    -- Animação de Entrada
    TweenService:Create(n, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 1, -70)}):Play()
    
    -- Saída Automática
    task.delay(3.5, function()
        TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -70)}):Play()
        task.wait(0.5)
        n:Destroy()
    end)
end

return Library--[[
    BITCODE LIBRARY - HYBRID EDITION (V2 DESIGN + V3.2 LOGIC)
    Especialista: bitcode (Assistente de Programação)
    Status: Sistema Operacional
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- ===== CONFIGURAÇÃO DE CORES (NEON TECH) =====
Library.Colors = {
    Main = Color3.fromRGB(255, 100, 0), -- Laranja Neon
    Bg = Color3.fromRGB(10, 10, 10),    -- Fundo Profundo
    Accent = Color3.fromRGB(255, 255, 255),
    DarkBg = Color3.fromRGB(5, 5, 5),   -- Sidebar
    ElementBg = Color3.fromRGB(20, 20, 20) -- Fundo de Botões/Toggles
}

-- ===== UTILITÁRIOS INTERNOS =====
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
end

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

-- ===== CORE ENGINE =====
function Library:Init()
    -- Limpeza de instâncias fantasmas
    local old = game:GetService("CoreGui"):FindFirstChild("BitcodeLibrary") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "BitcodeLibrary"
    self.Gui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    self.Gui.ResetOnSpawn = false

    -- Quadro Principal (MainFrame)
    self.Main = Instance.new("Frame")
    self.Main.Name = "MainFrame"
    self.Main.Parent = self.Gui
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- Inicia invisível para animação
    self.Main.Position = UDim2.new(0.5, -225, 0.5, -160)
    self.Main.BackgroundColor3 = self.Colors.Bg
    self.Main.ClipsDescendants = true
    corner(self.Main, 12)
    makeDraggable(self.Main)

    local stroke = Instance.new("UIStroke", self.Main)
    stroke.Color = self.Colors.Main
    stroke.Thickness = 2

    -- Botão de Alternância (Toggle HUD)
    local toggleBtn = Instance.new("TextButton", self.Gui)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 15, 0, 120)
    toggleBtn.BackgroundColor3 = self.Colors.Bg
    toggleBtn.Text = "W"
    toggleBtn.TextColor3 = self.Colors.Main
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    corner(toggleBtn, 25)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = self.Colors.Main

    local isOpen = false
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, 450, 0, 320) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    -- Barra Lateral (Sidebar)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 120, 1, 0)
    self.Sidebar.BackgroundColor3 = self.Colors.DarkBg
    
    local tabLayout = Instance.new("UIListLayout", self.Sidebar)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Container de Páginas
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Position = UDim2.new(0, 130, 0, 10)
    self.Container.Size = UDim2.new(1, -140, 1, -20)
    self.Container.BackgroundTransparency = 1

    self._firstTab = true
end

-- ===== SISTEMA DE ABAS =====
function Library:CreateTab(name)
    local tabBtn = Instance.new("TextButton", self.Sidebar)
    tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    tabBtn.BackgroundColor3 = self.Colors.ElementBg
    tabBtn.Text = name
    tabBtn.TextColor3 = self.Colors.Accent
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    corner(tabBtn, 6)

    local page = Instance.new("ScrollingFrame", self.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = self.Colors.Main
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do 
            if v:IsA("ScrollingFrame") then v.Visible = false end 
        end
        for _, b in pairs(self.Sidebar:GetChildren()) do 
            if b:IsA("TextButton") then b.BackgroundColor3 = self.Colors.ElementBg end 
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = self.Colors.Main
    end)

    if self._firstTab then
        self._firstTab = false
        page.Visible = true
        tabBtn.BackgroundColor3 = self.Colors.Main
    end

    local tab = {}

    -- Elemento: Botão
    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(0.95, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.Text = text
        b.TextColor3 = Library.Colors.Accent
        b.Font = Enum.Font.Gotham
        corner(b, 6)
        b.MouseButton1Click:Connect(cb)
    end

    -- Elemento: Alternador (Toggle)
    function tab:CreateToggle(text, cb)
        local state = false
        local tFrame = Instance.new("Frame", page)
        tFrame.Size = UDim2.new(0.95, 0, 0, 40)
        tFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(tFrame, 6)

        local label = Instance.new("TextLabel", tFrame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", tFrame)
        box.Position = UDim2.new(0.85, 0, 0.25, 0)
        box.Size = UDim2.new(0, 20, 0, 20)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        corner(box, 4)

        tFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Colors.Main or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
        end)
    end

    -- Elemento: Controle Deslizante (Slider)
    function tab:CreateSlider(text, min, max, def, cb)
        local sFrame = Instance.new("Frame", page)
        sFrame.Size = UDim2.new(0.95, 0, 0, 50)
        sFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(sFrame, 6)

        local label = Instance.new("TextLabel", sFrame)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. def
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", sFrame)
        bar.Position = UDim2.new(0.05, 0, 0.7, 0)
        bar.Size = UDim2.new(0.9, 0, 0, 6)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        corner(bar, 3)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((def - min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Library.Colors.Main
        corner(fill, 3)

        local dragging = false
        local function update()
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = bar.AbsolutePosition.X
            local barSize = bar.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
            cb(val)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging then update() end
        end)
    end

    -- Elemento: Menu Suspenso (Dropdown v3.2 Logic)
    function tab:CreateDropdown(text, options, cb)
        local dFrame = Instance.new("Frame", page)
        dFrame.Size = UDim2.new(0.95, 0, 0, 35)
        dFrame.BackgroundColor3 = Library.Colors.ElementBg
        dFrame.ClipsDescendants = true
        corner(dFrame, 6)

        local btn = Instance.new("TextButton", dFrame)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundTransparency = 1
        btn.Text = text .. "  [ + ]"
        btn.TextColor3 = Library.Colors.Accent
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12

        local dropContent = Instance.new("Frame", dFrame)
        dropContent.Position = UDim2.new(0, 0, 0, 35)
        dropContent.Size = UDim2.new(1, 0, 0, #options * 30)
        dropContent.BackgroundTransparency = 1

        for i, v in ipairs(options) do
            local opt = Instance.new("TextButton", dropContent)
            opt.Size = UDim2.new(1, 0, 0, 30)
            opt.Position = UDim2.new(0, 0, 0, (i-1)*30)
            opt.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            opt.Text = v
            opt.TextColor3 = Library.Colors.Accent
            opt.Font = Enum.Font.Gotham
            opt.BorderSizePixel = 0
            
            opt.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. v
                dFrame.Size = UDim2.new(0.95, 0, 0, 35)
                cb(v)
            end)
        end

        local dropped = false
        btn.MouseButton1Click:Connect(function()
            dropped = not dropped
            local targetSize = dropped and UDim2.new(0.95, 0, 0, 35 + (#options * 30)) or UDim2.new(0.95, 0, 0, 35)
            TweenService:Create(dFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
            btn.Text = dropped and text .. "  [ - ]" or text .. "  [ + ]"
        end)
    end

    return tab
end

-- ===== SISTEMA DE NOTIFICAÇÕES (v3.2 Logic) =====
function Library:Notify(text)
    local n = Instance.new("TextLabel")
    n.Parent = self.Gui
    n.Size = UDim2.new(0, 220, 0, 45)
    n.Position = UDim2.new(1, 20, 1, -70) -- Inicia fora da tela (Direita)
    n.BackgroundColor3 = self.Colors.Bg
    n.TextColor3 = self.Colors.Main
    n.Text = "  ⚡ " .. text
    n.Font = Enum.Font.GothamBold
    n.TextSize = 13
    n.TextXAlignment = Enum.TextXAlignment.Left
    corner(n, 8)
    
    local nStroke = Instance.new("UIStroke", n)
    nStroke.Color = self.Colors.Main
    nStroke.Thickness = 1.5

    -- Animação de Entrada
    TweenService:Create(n, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -240, 1, -70)}):Play()
    
    -- Saída Automática
    task.delay(3.5, function()
        TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -70)}):Play()
        task.wait(0.5)
        n:Destroy()
    end)
end

return Library
