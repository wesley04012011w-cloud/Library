--[[
    BITCODE ENGINE v3 - RE-ENGINEERED EDITION
    - Layout Responsivo (80% Screen Fill)
    - Botão de Toggle Flutuante
    - Correção de Posicionamento (AnchorPoint Logic)
]]

local Library = {
    Colors = {
        ACCENT = Color3.fromRGB(0, 170, 255),
        BACKGROUND = Color3.fromRGB(12, 12, 12),
        SECONDARY = Color3.fromRGB(18, 18, 18),
        DARK_GREY = Color3.fromRGB(25, 25, 25),
        HIGHLIGHT = Color3.fromRGB(45, 45, 45),
        TEXT = Color3.fromRGB(255, 255, 255),
        TEXT_MUTED = Color3.fromRGB(165, 165, 165),
        SUCCESS = Color3.fromRGB(46, 204, 113),
        DANGER = Color3.fromRGB(231, 76, 60),
        WARNING = Color3.fromRGB(241, 196, 15),
    },
    Registry = {},
    Flags = {},
    ConfigName = "Bitcode_Configs.json",
    ToggleKey = Enum.KeyCode.RightShift,
    Open = true
}

-- [ SERVIÇOS ] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- [ UTILS ] --
local function create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

local function Ripple(obj)
    task.spawn(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local circle = create("ImageLabel", {
            Parent = obj, BackgroundTransparency = 1,
            Image = "rbxassetid://266543268", ImageTransparency = 0.8,
            ZIndex = 10, Size = UDim2.new(0, 0, 0, 0)
        })
        local pos = Vector2.new(mouse.X, mouse.Y) - obj.AbsolutePosition
        circle.Position = UDim2.new(0, pos.X, 0, pos.Y)
        TweenService:Create(circle, TweenInfo.new(0.5), {
            Size = UDim2.new(0, 200, 0, 200),
            Position = UDim2.new(0.5, -100, 0.5, -100),
            ImageTransparency = 1
        }):Play()
        task.wait(0.5)
        circle:Destroy()
    end)
end

-- [ SISTEMA DE CONFIG ] --
function Library:SaveConfig()
    local success, encoded = pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if success then pcall(function() writefile(self.ConfigName, encoded) end) end
end

function Library:LoadConfig()
    pcall(function()
        if isfile and isfile(self.ConfigName) then
            local decoded = HttpService:JSONDecode(readfile(self.ConfigName))
            if decoded then self.Flags = decoded end
        end
    end)
end

-- [ NOTIFICAÇÕES ] --
function Library:Notify(title, desc, type, duration)
    task.spawn(function()
        local color = self.Colors[type or "ACCENT"]
        local notifyGui = CoreGui:FindFirstChild("BitcodeNotifications") or create("ScreenGui", {Name = "BitcodeNotifications", Parent = CoreGui})
        
        local container = notifyGui:FindFirstChild("Holder") or create("Frame", {
            Name = "Holder", Parent = notifyGui,
            Size = UDim2.new(0, 280, 1, 0), Position = UDim2.new(1, -290, 0, 0),
            BackgroundTransparency = 1
        })
        
        if not container:FindFirstChild("Layout") then
            create("UIListLayout", {
                Name = "Layout", Parent = container, VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
        end

        local box = create("Frame", {
            Parent = container, Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = self.Colors.BACKGROUND, ClipsDescendants = true
        })
        create("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = box, Color = color, Thickness = 1.5})
        
        create("TextLabel", {
            Parent = box, Text = title, TextColor3 = color, 
            Font = Enum.Font.GothamBold, TextSize = 14,
            Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1, TextXAlignment = "Left"
        })
        create("TextLabel", {
            Parent = box, Text = desc, TextColor3 = self.Colors.TEXT, 
            Font = Enum.Font.Gotham, TextSize = 12,
            Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25),
            BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true
        })

        TweenService:Create(box, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 65)}):Play()
        task.wait(duration or 4)
        TweenService:Create(box, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4)
        box:Destroy()
    end)
end

-- [ MAIN INIT ] --
function Library:Init(config)
    self:LoadConfig()
    local name = config.Name or "BITCODE ENGINE"
    
    local screen = create("ScreenGui", {Name = "Bitcode_V3", Parent = CoreGui, ResetOnSpawn = false})
    
    -- Painel Principal (80% da Tela)
    local main = create("CanvasGroup", {
        Name = "Main", Parent = screen,
        Size = UDim2.new(0.8, 0, 0.8, 0), 
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Colors.BACKGROUND, 
        GroupTransparency = 0,
        Visible = self.Open
    })
    create("UICorner", {Parent = main, CornerRadius = UDim.new(0, 8)})
    create("UIStroke", {Parent = main, Color = self.Colors.ACCENT, Thickness = 2})

    -- Botão de Abrir/Fechar Flutuante
    local toggleBtn = create("TextButton", {
        Name = "MenuToggle", Parent = screen,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 1, -70),
        BackgroundColor3 = self.Colors.ACCENT,
        Text = "B", -- Logo ou letra inicial
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        ZIndex = 100
    })
    create("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(1, 0)})
    create("UIStroke", {Parent = toggleBtn, Color = Color3.new(1,1,1), Thickness = 2})

    local function toggleMenu()
        self.Open = not self.Open
        main.Visible = self.Open
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
            Rotation = self.Open and 0 or 180,
            BackgroundColor3 = self.Open and self.Colors.ACCENT or self.Colors.DARK_GREY
        }):Play()
    end

    toggleBtn.MouseButton1Click:Connect(toggleMenu)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.ToggleKey then toggleMenu() end
    end)

    -- Sidebar
    local sidebar = create("Frame", {
        Parent = main, Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = self.Colors.SECONDARY
    })
    create("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 8)})
    
    create("TextLabel", {
        Parent = sidebar, Text = name, Size = UDim2.new(1, 0, 0, 60),
        TextColor3 = self.Colors.TEXT, Font = Enum.Font.GothamBold, TextSize = 18,
        BackgroundTransparency = 1
    })

    local tabHold = create("ScrollingFrame", {
        Parent = sidebar, Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y"
    })
    create("UIListLayout", {Parent = tabHold, HorizontalAlignment = "Center", Padding = UDim.new(0, 8)})

    local container = create("Frame", {
        Parent = main, Size = UDim2.new(1, -200, 1, -20), Position = UDim2.new(0, 190, 0, 10),
        BackgroundTransparency = 1
    })

    local tabSystem = {ActiveTab = nil}

    function tabSystem:CreateTab(tName)
        local tabBtn = create("TextButton", {
            Parent = tabHold, Size = UDim2.new(0.9, 0, 0, 38),
            BackgroundColor3 = Library.Colors.DARK_GREY, Text = tName,
            TextColor3 = Library.Colors.TEXT_MUTED, Font = Enum.Font.GothamBold, TextSize = 13,
            AutoButtonColor = false
        })
        create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 6)})

        local page = create("ScrollingFrame", {
            Parent = container, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Colors.ACCENT, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y"
        })
        create("UIListLayout", {Parent = page, Padding = UDim.new(0, 10), SortOrder = "LayoutOrder"})

        tabBtn.MouseButton1Click:Connect(function()
            if tabSystem.ActiveTab then
                tabSystem.ActiveTab.Page.Visible = false
                TweenService:Create(tabSystem.ActiveTab.Btn, TweenInfo.new(0.2), {TextColor3 = Library.Colors.TEXT_MUTED, BackgroundColor3 = Library.Colors.DARK_GREY}):Play()
            end
            page.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {TextColor3 = Library.Colors.TEXT, BackgroundColor3 = Library.Colors.ACCENT}):Play()
            tabSystem.ActiveTab = {Page = page, Btn = tabBtn}
            Ripple(tabBtn)
        end)

        if not tabSystem.ActiveTab then
            page.Visible = true
            tabBtn.TextColor3 = Library.Colors.TEXT
            tabBtn.BackgroundColor3 = Library.Colors.ACCENT
            tabSystem.ActiveTab = {Page = page, Btn = tabBtn}
        end

        local elements = {}

        function elements:CreateButton(bText, callback)
            local btn = create("TextButton", {
                Parent = page, Size = UDim2.new(1, -15, 0, 40),
                BackgroundColor3 = Library.Colors.DARK_GREY, Text = bText,
                TextColor3 = Library.Colors.TEXT, Font = Enum.Font.GothamSemibold, TextSize = 14,
                AutoButtonColor = false
            })
            create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
            btn.MouseButton1Click:Connect(function() Ripple(btn) callback() end)
        end

        function elements:CreateToggle(tText, flag, callback)
            local state = Library.Flags[flag] or false
            local tFrame = create("TextButton", {
                Parent = page, Size = UDim2.new(1, -15, 0, 40),
                BackgroundColor3 = Library.Colors.DARK_GREY, Text = "  " .. tText,
                TextColor3 = Library.Colors.TEXT, Font = Enum.Font.Gotham, TextSize = 14,
                TextXAlignment = "Left", AutoButtonColor = false
            })
            create("UICorner", {Parent = tFrame, CornerRadius = UDim.new(0, 6)})

            local box = create("Frame", {
                Parent = tFrame, Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Library.Colors.HIGHLIGHT
            })
            create("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})

            local dot = create("Frame", {
                Parent = box, Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = state and Library.Colors.ACCENT or Color3.fromRGB(150,150,150)
            })
            create("UICorner", {Parent = dot, CornerRadius = UDim.new(1, 0)})

            local function toggle(s)
                state = s
                Library.Flags[flag] = state
                Library:SaveConfig()
                TweenService:Create(dot, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = state and Library.Colors.ACCENT or Color3.fromRGB(150,150,150)
                }):Play()
                callback(state)
            end

            tFrame.MouseButton1Click:Connect(function() toggle(not state) end)
            if state then task.spawn(callback, true) end
        end

        function elements:CreateSlider(sText, min, max, flag, callback)
            local val = Library.Flags[flag] or min
            local sFrame = create("Frame", {
                Parent = page, Size = UDim2.new(1, -15, 0, 55),
                BackgroundColor3 = Library.Colors.DARK_GREY
            })
            create("UICorner", {Parent = sFrame})

            local label = create("TextLabel", {
                Parent = sFrame, Text = "  " .. sText, Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1, TextColor3 = Library.Colors.TEXT, 
                Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Left"
            })
            local vLabel = create("TextLabel", {
                Parent = sFrame, Text = tostring(val) .. " ", Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1, TextColor3 = Library.Colors.ACCENT,
                Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = "Right"
            })

            local bar = create("Frame", {
                Parent = sFrame, Size = UDim2.new(0.94, 0, 0, 6), Position = UDim2.new(0.03, 0, 0.75, 0),
                BackgroundColor3 = Library.Colors.HIGHLIGHT
            })
            local fill = create("Frame", {
                Parent = bar, Size = UDim2.new((val-min)/(max-min), 0, 1, 0),
                BackgroundColor3 = Library.Colors.ACCENT
            })

            local dragging = false
            local function update()
                local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local current = math.floor(min + (max - min) * percent)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                vLabel.Text = tostring(current) .. " "
                Library.Flags[flag] = current
                callback(current)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false Library:SaveConfig() end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            
            task.spawn(callback, val)
        end

        return elements
    end
    
    return tabSystem
end

-- [ SCRIPT DE TESTE AUTOMÁTICO ] --
local Window = Library:Init({Name = "FLUXION ENGINE V3"})
local Tab1 = Window:CreateTab("Combate")
local Tab2 = Window:CreateTab("Configurações")

Tab1:CreateButton("Ativar Kill Aura", function()
    Library:Notify("Aviso", "Kill Aura não encontrou alvos próximos.", "WARNING")
end)

Tab1:CreateToggle("Infinite Ammo", "inf_ammo", function(s)
    print("Munição Infinita:", s)
end)

Tab2:CreateSlider("WalkSpeed", 16, 250, "speed_val", function(v)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

Tab2:CreateButton("Salvar Agora", function()
    Library:SaveConfig()
    Library:Notify("Sucesso", "Configurações salvas localmente!", "SUCCESS")
end)

return Library
