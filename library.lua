-- [[ BITCODE LIBRARY HYBRID V3.5 - MOBILE & PC OPTIMIZED ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Library = {}

Library.Colors = {
    Main = Color3.fromRGB(255, 100, 0),
    Bg = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(255, 255, 255),
    DarkBg = Color3.fromRGB(5, 5, 5),
    ElementBg = Color3.fromRGB(20, 20, 20)
}

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

function Library:Init()
    local targetParent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    
    local old = targetParent:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    -- Calculo de Proporção Adaptável
    local screenSize = Camera.ViewportSize
    local isMobile = screenSize.X < 700
    local width = isMobile and 350 or 450
    local height = isMobile and 220 or 320

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "BitcodeLibrary"
    self.Gui.Parent = targetParent
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true

    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Name = "MainFrame"
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- Inicia fechado
    self.Main.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    self.Main.BackgroundColor3 = self.Colors.Bg
    self.Main.ClipsDescendants = true
    corner(self.Main, 10)
    makeDraggable(self.Main)

    local stroke = Instance.new("UIStroke", self.Main)
    stroke.Color = self.Colors.Main
    stroke.Thickness = 1.8

    -- Botão Flutuante (Toggle)
    local toggleBtn = Instance.new("TextButton", self.Gui)
    toggleBtn.Size = UDim2.new(0, 45, 0, 45)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
    toggleBtn.BackgroundColor3 = self.Colors.Bg
    toggleBtn.Text = "W"
    toggleBtn.TextColor3 = self.Colors.Main
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 18
    corner(toggleBtn, 25)
    Instance.new("UIStroke", toggleBtn).Color = self.Colors.Main

    local isOpen = false
    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, width, 0, height) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    -- Sidebar Adaptável
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, isMobile and 100 or 120, 1, 0)
    self.Sidebar.BackgroundColor3 = self.Colors.DarkBg
    
    local tabList = Instance.new("ScrollingFrame", self.Sidebar)
    tabList.Size = UDim2.new(1, 0, 1, -10)
    tabList.Position = UDim2.new(0, 0, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.CanvasSize = UDim2.new(0,0,0,0)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    self.Container = Instance.new("Frame", self.Main)
    self.Container.Position = UDim2.new(0, (isMobile and 105 or 125), 0, 10)
    self.Container.Size = UDim2.new(1, (isMobile and -110 or -135), 1, -20)
    self.Container.BackgroundTransparency = 1

    self._firstTab = true
end

function Library:CreateTab(name)
    local tabBtn = Instance.new("TextButton", self.Sidebar:FindFirstChildOfClass("ScrollingFrame"))
    tabBtn.Size = UDim2.new(0.9, 0, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    corner(tabBtn, 5)

    local page = Instance.new("ScrollingFrame", self.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = self.Colors.Main
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do v.Visible = false end
        for _, b in pairs(self.Sidebar:FindFirstChildOfClass("ScrollingFrame"):GetChildren()) do 
            if b:IsA("TextButton") then 
                TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20,20,20), TextColor3 = Color3.fromRGB(180,180,180)}):Play()
            end 
        end
        page.Visible = true
        TweenService:Create(tabBtn, TweenInfo.new(0.3), {BackgroundColor3 = self.Colors.Main, TextColor3 = self.Colors.Bg}):Play()
    end)

    if self._firstTab then
        self._firstTab = false
        page.Visible = true
        tabBtn.BackgroundColor3 = self.Colors.Main
        tabBtn.TextColor3 = self.Colors.Bg
    end

    local tab = {}

    function tab:CreateButton(text, cb)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(0.95, 0, 0, 32)
        b.BackgroundColor3 = self.Colors.ElementBg
        b.Text = text
        b.TextColor3 = Library.Colors.Accent
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        corner(b, 5)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text, cb)
        local state = false
        local tFrame = Instance.new("Frame", page)
        tFrame.Size = UDim2.new(0.95, 0, 0, 38)
        tFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(tFrame, 5)

        local label = Instance.new("TextLabel", tFrame)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("Frame", tFrame)
        box.Position = UDim2.new(0.85, 0, 0.25, 0)
        box.Size = UDim2.new(0, 18, 0, 18)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        corner(box, 4)

        tFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                state = not state
                TweenService:Create(box, TweenInfo.new(0.25), {BackgroundColor3 = state and Library.Colors.Main or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
        end)
    end

    function tab:CreateSlider(text, min, max, def, cb)
        local sFrame = Instance.new("Frame", page)
        sFrame.Size = UDim2.new(0.95, 0, 0, 45)
        sFrame.BackgroundColor3 = Library.Colors.ElementBg
        corner(sFrame, 5)

        local label = Instance.new("TextLabel", sFrame)
        label.Position = UDim2.new(0, 10, 0, 4)
        label.Size = UDim2.new(1, -20, 0, 15)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. def
        label.TextColor3 = Library.Colors.Accent
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", sFrame)
        bar.Position = UDim2.new(0.05, 0, 0.75, -3)
        bar.Size = UDim2.new(0.9, 0, 0, 5)
        bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        corner(bar, 3)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(math.clamp((def - min)/(max-min), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = Library.Colors.Main
        corner(fill, 3)

        local function update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. val
            cb(val)
        end

        local dragging = false
        bar.InputBegan:Connect(function(input)
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

    function tab:CreateDropdown(text, options, cb)
        local dFrame = Instance.new("Frame", page)
        dFrame.Size = UDim2.new(0.95, 0, 0, 32)
        dFrame.BackgroundColor3 = Library.Colors.ElementBg
        dFrame.ClipsDescendants = true
        corner(dFrame, 5)

        local btn = Instance.new("TextButton", dFrame)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundTransparency = 1
        btn.Text = text .. "  ▼"
        btn.TextColor3 = Library.Colors.Accent
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11

        local dropContent = Instance.new("Frame", dFrame)
        dropContent.Position = UDim2.new(0, 0, 0, 32)
        dropContent.Size = UDim2.new(1, 0, 0, #options * 28)
        dropContent.BackgroundTransparency = 1

        for i, v in ipairs(options) do
            local opt = Instance.new("TextButton", dropContent)
            opt.Size = UDim2.new(1, 0, 0, 28)
            opt.Position = UDim2.new(0, 0, 0, (i-1)*28)
            opt.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            opt.Text = v
            opt.TextColor3 = Color3.fromRGB(200, 200, 200)
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 11
            opt.BorderSizePixel = 0
            
            opt.MouseButton1Click:Connect(function()
                btn.Text = text .. ": " .. v
                dFrame.Size = UDim2.new(0.95, 0, 0, 32)
                cb(v)
            end)
        end

        local dropped = false
        btn.MouseButton1Click:Connect(function()
            dropped = not dropped
            local targetSize = dropped and UDim2.new(0.95, 0, 0, 32 + (#options * 28)) or UDim2.new(0.95, 0, 0, 32)
            TweenService:Create(dFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
        end)
    end

    return tab
end

function Library:Notify(text)
    local n = Instance.new("TextLabel")
    n.Parent = self.Gui
    n.Size = UDim2.new(0, 200, 0, 40)
    n.Position = UDim2.new(1, 10, 1, -60)
    n.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    n.TextColor3 = self.Colors.Main
    n.Text = "  ⚡ " .. text
    n.Font = Enum.Font.GothamBold
    n.TextSize = 12
    n.TextXAlignment = Enum.TextXAlignment.Left
    corner(n, 6)
    
    -- Notificação sem Stroke (Neon removido conforme solicitado)

    TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -215, 1, -60)}):Play()
    
    task.delay(3, function()
        if n then
            TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -60)}):Play()
            task.wait(0.5)
            n:Destroy()
        end
    end)
end

return Library
