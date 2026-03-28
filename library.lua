-- Bitcode Library V3 (Pro)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}

Library.Colors = {
    Main = Color3.fromRGB(255,100,0),
    Bg = Color3.fromRGB(10,10,10),
    Text = Color3.fromRGB(255,255,255)
}

-- ===== UTILS =====
local function corner(obj,r)
    local c = Instance.new("UICorner",obj)
    c.CornerRadius = UDim.new(0,r or 6)
end

-- ===== INIT =====
function Library:Init()
    local old = game.CoreGui:FindFirstChild("BitcodeLibrary")
    if old then old:Destroy() end

    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "BitcodeLibrary"

    self.Gui = sg

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0,0,0,0)
    main.Position = UDim2.new(0.5,-200,0.5,-150)
    main.BackgroundColor3 = self.Colors.Bg
    corner(main,10)
    self.Main = main

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = self.Colors.Main

    -- toggle button
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0,50,0,50)
    btn.Position = UDim2.new(0,15,0,120)
    btn.Text = "W"
    btn.BackgroundColor3 = self.Colors.Bg
    btn.TextColor3 = self.Colors.Main
    corner(btn,25)

    local open = false
    btn.MouseButton1Click:Connect(function()
        open = not open
        main.Visible = true

        TweenService:Create(main, TweenInfo.new(0.3), {
            Size = open and UDim2.new(0,400,0,300) or UDim2.new(0,0,0,0)
        }):Play()
    end)

    -- tabs
    self.Tabs = Instance.new("Frame", main)
    self.Tabs.Size = UDim2.new(0,120,1,0)

    self.Container = Instance.new("Frame", main)
    self.Container.Position = UDim2.new(0,130,0,0)
    self.Container.Size = UDim2.new(1,-130,1,0)

    self._first = true

    -- ===== SETTINGS TAB AUTO =====
    local settings = self:CreateTab("Settings")

    -- Speed built-in
    settings:CreateSlider("Speed",16,200,16,function(v)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end)

    -- ESP built-in
    local esp = false
    settings:CreateToggle("ESP Name", function(state)
        esp = state
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local old = p.Character:FindFirstChild("ESP")
                if old then old:Destroy() end

                if state then
                    local b = Instance.new("BillboardGui", p.Character)
                    b.Name = "ESP"
                    b.Adornee = p.Character.Head
                    b.Size = UDim2.new(0,100,0,40)
                    b.AlwaysOnTop = true

                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1,0,1,0)
                    t.BackgroundTransparency = 1
                    t.Text = p.Name
                    t.TextColor3 = Library.Colors.Main
                    t.TextScaled = true
                end
            end
        end
    end)
end

-- ===== TAB =====
function Library:CreateTab(name)
    local btn = Instance.new("TextButton", self.Tabs)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.TextColor3 = self.Colors.Text
    corner(btn,6)

    local page = Instance.new("Frame", self.Container)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,5)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Container:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        page.Visible = true
    end)

    if self._first then
        self._first = false
        page.Visible = true
    end

    local tab = {}

    function tab:CreateButton(text,cb)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1,0,0,30)
        b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(25,25,25)
        b.TextColor3 = Library.Colors.Text
        corner(b,6)
        b.MouseButton1Click:Connect(cb)
    end

    function tab:CreateToggle(text,cb)
        local state = false

        local f = Instance.new("TextButton", page)
        f.Size = UDim2.new(1,0,0,30)
        f.Text = text
        f.BackgroundColor3 = Color3.fromRGB(20,20,20)
        f.TextColor3 = Library.Colors.Text
        corner(f,6)

        f.MouseButton1Click:Connect(function()
            state = not state
            f.BackgroundColor3 = state and Library.Colors.Main or Color3.fromRGB(20,20,20)
            cb(state)
        end)
    end

    function tab:CreateSlider(text,min,max,def,cb)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1,0,0,40)
        f.BackgroundColor3 = Color3.fromRGB(20,20,20)
        corner(f,6)

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1,0,0,20)
        l.Text = text..": "..def
        l.BackgroundTransparency = 1
        l.TextColor3 = Library.Colors.Text

        local bar = Instance.new("Frame", f)
        bar.Position = UDim2.new(0,5,0,25)
        bar.Size = UDim2.new(1,-10,0,5)
        bar.BackgroundColor3 = Color3.fromRGB(40,40,40)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
        fill.BackgroundColor3 = Library.Colors.Main

        local dragging = false

        bar.InputBegan:Connect(function(i)
            if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name=="Touch" then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name=="Touch" then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging then
                local pos = (i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                pos = math.clamp(pos,0,1)
                local val = math.floor(min+(max-min)*pos)

                fill.Size = UDim2.new(pos,0,1,0)
                l.Text = text..": "..val
                cb(val)
            end
        end)
    end

    -- ===== DROPDOWN =====
    function tab:CreateDropdown(text, options, cb)
        local main = Instance.new("Frame", page)
        main.Size = UDim2.new(1,0,0,30)
        main.BackgroundColor3 = Color3.fromRGB(20,20,20)
        corner(main,6)

        local btn = Instance.new("TextButton", main)
        btn.Size = UDim2.new(1,0,1,0)
        btn.Text = text
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Library.Colors.Text

        local list = Instance.new("Frame", main)
        list.Size = UDim2.new(1,0,0,#options*25)
        list.Position = UDim2.new(0,0,1,0)
        list.Visible = false

        for i,v in pairs(options) do
            local opt = Instance.new("TextButton", list)
            opt.Size = UDim2.new(1,0,0,25)
            opt.Position = UDim2.new(0,0,0,(i-1)*25)
            opt.Text = v
            opt.BackgroundColor3 = Color3.fromRGB(30,30,30)

            opt.MouseButton1Click:Connect(function()
                btn.Text = text..": "..v
                list.Visible = false
                cb(v)
            end)
        end

        btn.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
        end)
    end

    return tab
end

-- ===== NOTIFICATION =====
function Library:Notify(text)
    local n = Instance.new("TextLabel", self.Gui)
    n.Size = UDim2.new(0,200,0,50)
    n.Position = UDim2.new(1,-210,1,-60)
    n.BackgroundColor3 = self.Colors.Bg
    n.TextColor3 = self.Colors.Main
    n.Text = text
    corner(n,8)

    TweenService:Create(n, TweenInfo.new(0.3), {
        Position = UDim2.new(1,-210,1,-100)
    }):Play()

    task.wait(2)

    n:Destroy()
end

return Library
