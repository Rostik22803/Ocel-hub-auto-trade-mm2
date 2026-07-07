-- =============================================
-- MM2 Auto Trader v3.5 (WAIT FOR PLAYER ACCEPT)
-- =============================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local MIN_PROFIT_PERCENT  = 5       -- % прибыли для принятия трейда
local traderEnabled       = false   -- включён ли автотрейд

-- =============================================
-- ТАБЛИЦА ЦЕН MM2
-- =============================================
local ItemValues = {
    -- ===== ANCIENTS =====
    ["Nik's Scythe"]            = 125000000,
    ["Blue Elderwood Blade"]    = 45000,
    ["Red Icecrusher"]          = 45000,
    ["Red Icepiercer"]          = 45000,
    ["Blue Swirly Axe"]         = 40000,
    ["Blue Synthwave"]          = 40000,
    ["Gingerscope"]             = 17800,
    ["Traveler's Axe"]          = 8400,
    ["Celestial"]               = 2000,
    ["Vampire's Axe"]           = 1200,
    ["Harvester"]               = 248,
    ["Icepiercer"]              = 163,
    ["Batwing"]                 = 46,
    ["Elderwood Scythe"]        = 44,
    ["Hallowscythe"]            = 34,
    ["Icebreaker"]              = 69,
    ["Icewing"]                 = 15,
    ["Logchopper"]              = 18,
    ["Swirly Axe"]              = 42,

    -- ===== CHROMA GODLYS =====
    ["Chroma Traveler's Gun"]   = 220000,
    ["Chroma Evergun"]          = 75000,
    ["Chroma Evergreen"]        = 59300,
    ["Chroma Darkbringer"]      = 70,
    ["Chroma Lightbringer"]     = 65,
    ["Chroma Luger"]            = 53,
    ["Chroma Swirly Gun"]       = 42,
    ["Chroma Candleflame"]      = 42,
    ["Chroma Laser"]            = 44,
    ["Chroma Cookiecane"]       = 38,

    -- ===== GODLYS =====
    ["Traveler's Gun"]          = 4900,
    ["Evergun"]                 = 3500,
    ["Evergreen"]               = 2500,
    ["Darkshot"]                = 1600,
    ["Darksword"]               = 1500,
    ["Corrupt"]                 = 475,
    ["Watergun"]                = 248,
    ["Candy"]                   = 83,
    ["Heartblade"]              = 69,
    ["Bat"]                     = 61,
    ["Luger"]                   = 46,
    ["Red Luger"]               = 44,
    ["Sugar"]                   = 39,
    ["Shark"]                   = 22,
    ["Laser"]                   = 24,
    ["Slasher"]                 = 19,
    ["Pixel"]                   = 19,
    ["Iceflake"]                = 19,
    ["Ice Dragon"]              = 7,
    ["Seer"]                    = 3,
    ["Pearl"]                   = 98,
    ["Pearlshine"]              = 103,
}

-- =============================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (DISPLAY ORDER ПОМАКСИМУМУ)
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 275)
mainFrame.Position = UDim2.new(0, 20, 0.4, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = mainFrame
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(0, 180, 255) stroke.Thickness = 2 stroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Auto Trader v3.5"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Статус: ВЫКЛЮЧЕН"
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 0, 44)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = "▶  Включить автотрейд"
toggleBtn.Size = UDim2.new(1, -20, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 72)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 6) btnCorner.Parent = toggleBtn

local scanBtn = Instance.new("TextButton")
scanBtn.Text = "🔄 РУЧНОЙ СКАН ТРЕЙДА"
scanBtn.Size = UDim2.new(1, -20, 0, 36)
scanBtn.Position = UDim2.new(0, 10, 0, 114)
scanBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 180)
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Font = Enum.Font.GothamBold
scanBtn.BorderSizePixel = 0
scanBtn.Parent = mainFrame
local sbc = Instance.new("UICorner") sbc.CornerRadius = UDim.new(0, 6) sbc.Parent = scanBtn

local profitLabel = Instance.new("TextLabel")
profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
profitLabel.Size = UDim2.new(1, -20, 0, 20)
profitLabel.Position = UDim2.new(0, 10, 0, 160)
profitLabel.BackgroundTransparency = 1
profitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
profitLabel.TextSize = 13
profitLabel.Font = Enum.Font.Gotham
profitLabel.TextXAlignment = Enum.TextXAlignment.Left
profitLabel.Parent = mainFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Text = "−"
minusBtn.Size = UDim2.new(0, 45, 0, 28)
minusBtn.Position = UDim2.new(0, 10, 0, 185)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextSize = 14
minusBtn.Parent = mainFrame
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,4) mc.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 45, 0, 28)
plusBtn.Position = UDim2.new(0, 60, 0, 185)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.TextSize = 14
plusBtn.Parent = mainFrame
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,4) pc.Parent = plusBtn

local debugToggleBtn = Instance.new("TextButton")
debugToggleBtn.Text = "🔍 Показать панель анализа"
debugToggleBtn.Size = UDim2.new(1, -20, 0, 32)
debugToggleBtn.Position = UDim2.new(0, 10, 0, 225)
debugToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
debugToggleBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
debugToggleBtn.Font = Enum.Font.GothamBold
debugToggleBtn.BorderSizePixel = 0
debugToggleBtn.Parent = mainFrame
local dbc = Instance.new("UICorner") dbc.CornerRadius = UDim.new(0,6) dbc.Parent = debugToggleBtn

-- =============================================
-- ПАНЕЛЬ ОТЛАДКИ (ИНФОРМАЦИОННАЯ)
-- =============================================
local debugFrame = Instance.new("Frame")
debugFrame.Name = "DebugFrame"
debugFrame.Size = UDim2.new(0, 420, 0, 280)
debugFrame.Position = UDim2.new(0, 310, 0.4, -100)
debugFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
debugFrame.BorderSizePixel = 0
debugFrame.Active = true
debugFrame.Draggable = true
debugFrame.Visible = false
debugFrame.Parent = screenGui
local dbCorner = Instance.new("UICorner") dbCorner.CornerRadius = UDim.new(0, 10) dbCorner.Parent = debugFrame
local dbStroke = Instance.new("UIStroke") dbStroke.Color = Color3.fromRGB(0, 180, 255) dbStroke.Thickness = 2 dbStroke.Parent = debugFrame

local dbTitleLabel = Instance.new("TextLabel")
dbTitleLabel.Text = "📊 Анализ слотов обмена"
dbTitleLabel.Size = UDim2.new(1, 0, 0, 32)
dbTitleLabel.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
dbTitleLabel.TextColor3 = Color3.fromRGB(225, 225, 255)
dbTitleLabel.TextSize = 13
dbTitleLabel.Font = Enum.Font.GothamBold
dbTitleLabel.Parent = debugFrame

local myCol = Instance.new("Frame")
myCol.Size = UDim2.new(0.5, -8, 1, -80)
myCol.Position = UDim2.new(0, 6, 0, 44)
myCol.BackgroundColor3 = Color3.fromRGB(15, 30, 15)
myCol.Parent = debugFrame

local myItemsLabel = Instance.new("TextLabel")
myItemsLabel.Text = "Твои предметы не добавлены"
myItemsLabel.Size = UDim2.new(1, -8, 1, -30)
myItemsLabel.Position = UDim2.new(0, 4, 0, 5)
myItemsLabel.BackgroundTransparency = 1
myItemsLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
myItemsLabel.TextSize = 11
myItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
myItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
myItemsLabel.Parent = myCol

local myTotalLabel = Instance.new("TextLabel")
myTotalLabel.Text = "Ты даешь: 0"
myTotalLabel.Size = UDim2.new(1, 0, 0, 24)
myTotalLabel.Position = UDim2.new(0, 0, 1, -24)
myTotalLabel.BackgroundTransparency = 1
myTotalLabel.Font = Enum.Font.GothamBold
myTotalLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
myTotalLabel.Parent = myCol

local theirCol = Instance.new("Frame")
theirCol.Size = UDim2.new(0.5, -8, 1, -80)
theirCol.Position = UDim2.new(0.5, 2, 0, 44)
theirCol.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
theirCol.Parent = debugFrame

local theirItemsLabel = Instance.new("TextLabel")
theirItemsLabel.Text = "Оппонент не добавил предметы"
theirItemsLabel.Size = UDim2.new(1, -8, 1, -30)
theirItemsLabel.Position = UDim2.new(0, 4, 0, 5)
theirItemsLabel.BackgroundTransparency = 1
theirItemsLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
theirItemsLabel.TextSize = 11
theirItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
theirItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
theirItemsLabel.Parent = theirCol

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Text = "Тебе дают: 0"
theirTotalLabel.Size = UDim2.new(1, 0, 0, 24)
theirTotalLabel.Position = UDim2.new(0, 0, 1, -24)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
theirTotalLabel.Parent = theirCol

local resultLabel = Instance.new("TextLabel")
resultLabel.Text = "Ожидание действий другого игрока..."
resultLabel.Size = UDim2.new(1, -12, 0, 24)
resultLabel.Position = UDim2.new(0, 6, 1, -28)
resultLabel.BackgroundTransparency = 1
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
resultLabel.Parent = debugFrame

-- =============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- =============================================
local function getCleanName(text)
    if not text or type(text) ~= "string" or text == "" then return nil end
    local clean = text:match("^%s*(.-)%s*$")
    if clean == "" or tonumber(clean) then return nil end
    if clean:lower() == "accept" or clean:lower() == "decline" or clean:lower():find("offer") then return nil end
    
    if ItemValues[clean] then return clean end
    for name, _ in pairs(ItemValues) do
        if name:lower() == clean:lower() then return name end
    end
    return nil
end

local function scanContainer(container)
    local items = {}
    if not container then return items end
    
    for _, slot in ipairs(container:GetDescendants()) do
        if slot:IsA("TextLabel") or slot:IsA("StringValue") then
            local text = slot:IsA("TextLabel") and slot.Text or slot.Value
            local matchedName = getCleanName(text)
            
            if matchedName then
                local count = 1
                local slotParent = slot.Parent
                if slotParent then
                    for _, sibling in ipairs(slotParent:GetChildren()) do
                        if sibling:IsA("TextLabel") and sibling.Text:match("^x%d+$") then
                            count = tonumber(sibling.Text:match("%d+")) or 1
                        end
                    end
                end
                for i = 1, count do
                    table.insert(items, matchedName)
                end
            end
        end
    end
    return items
end

-- Проверка: нажал ли второй игрок кнопку Accept?
local function isOpponentReady(mainTradeGui)
    -- В MM2 статус согласия обычно виден по цвету рамки или тексту кнопки оппонента
    local theirStatus = mainTradeGui:FindFirstChild("TheirStatus") or mainTradeGui:FindFirstChild("TheirOffer")
    if theirStatus then
        -- Проверка на наличие зеленой индикации или текста "Accepted"
        for _, child in ipairs(theirStatus:GetDescendants()) do
            if child:IsA("TextLabel") and (child.Text:lower():find("accepted") or child.Text:lower():find("ready")) then
                return true
            end
            if child:IsA("Frame") and (child.BackgroundColor3 == Color3.fromRGB(0, 255, 0) or child.Name:lower():find("green")) then
                return true
            end
        end
    end
    
    -- Запасной вариант: ищем общую кнопку подтверждения оппонента
    local theirAccept = mainTradeGui:FindFirstChild("TheirAccept") or mainTradeGui:FindFirstChild("RightAccept")
    if theirAccept and theirAccept:IsA("GuiObject") and theirAccept.Visible == true then
        return true
    end

    return false
end

-- =============================================
-- ОСНОВНОЙ ОДНОРАЗОВЫЙ АЛГОРИТМ ПРИНЯТИЯ РЕШЕНИЯ
-- =============================================
local function forceScanTrade()
    local mainTradeGui = nil
    
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:lower():find("trade") or gui:FindFirstChild("MainFrame")) then
            if gui:FindFirstChild("MainFrame") and (gui.MainFrame:FindFirstChild("MyOffer") or gui.MainFrame:FindFirstChild("TheirOffer")) then
                mainTradeGui = gui.MainFrame
                break
            end
        end
    end

    if not mainTradeGui then
        resultLabel.Text = "⏳ Окно обмена MM2 закрыто или не найдено"
        resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end

    local myOfferBox = mainTradeGui:FindFirstChild("MyOffer") or mainTradeGui:FindFirstChild("YourOffer")
    local theirOfferBox = mainTradeGui:FindFirstChild("TheirOffer")

    local myItems = scanContainer(myOfferBox)
    local theirItems = scanContainer(theirOfferBox)

    local myTotal, theirTotal = 0, 0
    local myDisplay, theirDisplay = {}, {}

    for _, name in ipairs(myItems) do
        local price = ItemValues[name] or 0
        myTotal = myTotal + price
        table.insert(myDisplay, name .. " [" .. price .. "]")
    end

    for _, name in ipairs(theirItems) do
        local price = ItemValues[name] or 0
        theirTotal = theirTotal + price
        table.insert(theirDisplay, name .. " [" .. price .. "]")
    end

    myItemsLabel.Text = #myDisplay > 0 and table.concat(myDisplay, "\n") or "Пусто"
    theirItemsLabel.Text = #theirDisplay > 0 and table.concat(theirDisplay, "\n") or "Пусто"
    myTotalLabel.Text = "Ты даешь: " .. myTotal
    theirTotalLabel.Text = "Тебе дают: " .. theirTotal

    -- Ищем кнопки действий
    local acceptBtn, declineBtn
    for _, obj in ipairs(mainTradeGui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local n = obj.Name:lower()
            local t = obj.Text:lower()
            if n:find("accept") or t:find("accept") or n:find("confirm") then
                acceptBtn = obj
            elseif n:find("decline") or t:find("decline") or n:find("cancel") then
                declineBtn = obj
            end
        end
    end

    if myTotal == 0 and theirTotal == 0 then
        resultLabel.Text = "Окна обмена пусты"
        resultLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end

    -- Рассчитываем выгоду для отображения в UI
    local actionAccept = false
    local percent = 0
    if myTotal > 0 then
        local diff = theirTotal - myTotal
        percent = math.floor((diff / myTotal) * 100)
        actionAccept = percent >= MIN_PROFIT_PERCENT
    else
        actionAccept = theirTotal > 0
    end

    -- Проверяем, нажал ли другой игрок кнопку готовности
    local opponentReady = isOpponentReady(mainTradeGui)

    if not opponentReady then
        resultLabel.Text = "⏳ Ожидание согласия второго игрока..."
        resultLabel.TextColor3 = Color3.fromRGB(240, 160, 20)
        return -- ОСТАНАВЛИВАЕМ СКРИПТ, ничего не нажимаем!
    end

    -- Ели игрок ГОТОВ, принимаем окончательное решение:
    if traderEnabled then
        if actionAccept then
            resultLabel.Text = "✅ ВЫГОДНО! Авто-принятие..."
            resultLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            if acceptBtn then
                acceptBtn.MouseButton1Click:Fire()
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    local pos = acceptBtn.AbsolutePosition + acceptBtn.AbsoluteSize / 2
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                    task.wait(0.01)
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                end)
            end
        else
            resultLabel.Text = "❌ НЕВЫГОДНО! Авто-отклонение..."
            resultLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            if declineBtn then
                declineBtn.MouseButton1Click:Fire()
            end
        end
    else
        -- Если автотрейд выключен, просто пишем подсказку на экране отладки
        if actionAccept then
            resultLabel.Text = string.format("Рекомендация: ПРИНЯТЬ (+%d%%)", percent)
            resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            resultLabel.Text = string.format("Рекомендация: ОТКЛОНИТЬ (%d%%)", percent)
            resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

-- =============================================
-- ПОТОКИ ОБНОВЛЕНИЙ
-- =============================================
task.spawn(function()
    while true do
        task.wait(0.3) -- Частое сканирование изменений статуса
        pcall(forceScanTrade)
    end
end)

scanBtn.MouseButton1Click:Connect(function()
    pcall(forceScanTrade)
end)

minusBtn.MouseButton1Click:Connect(function()
    if MIN_PROFIT_PERCENT > 1 then
        MIN_PROFIT_PERCENT = MIN_PROFIT_PERCENT - 1
        profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
    end
end)

plusBtn.MouseButton1Click:Connect(function()
    MIN_PROFIT_PERCENT = MIN_PROFIT_PERCENT + 1
    profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
end)

debugToggleBtn.MouseButton1Click:Connect(function()
    debugFrame.Visible = not debugFrame.Visible
    debugToggleBtn.Text = debugFrame.Visible and "🔍 Скрыть панель анализа" or "🔍 Показать панель анализа"
end)

toggleBtn.MouseButton1Click:Connect(function()
    traderEnabled = not traderEnabled
    if traderEnabled then
        toggleBtn.Text = "⏹  Выключить автотрейд"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        statusLabel.Text = "Статус: ВКЛЮЧЁН ✅"
        statusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
    else
        toggleBtn.Text = "▶  Включить автотрейд"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
        statusLabel.Text = "Статус: ВЫКЛЮЧЕН"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)
