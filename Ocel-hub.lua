-- =============================================
-- MM2 Auto Trader v4.3 (PERFECT SLOTS FILTER)
-- =============================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- [АВТО-ОЧИСТКА ВСЕХ СТАРЫХ ВЕРСИЙ]
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name:find("MM2TraderUI") or gui.Name == "MM2TraderDebug" then
        gui:Destroy()
    end
end

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local MIN_PROFIT_PERCENT  = 5       
local traderEnabled       = false   

-- =============================================
-- ТАБЛИЦА ЦЕН MM2
-- =============================================
local ItemValues = {
    ["Nik's Scythe"]            = 125000000, ["Blue Elderwood Blade"]    = 45000,
    ["Red Icecrusher"]          = 45000,     ["Red Icepiercer"]          = 45000,
    ["Blue Swirly Axe"]         = 40000,     ["Blue Synthwave"]          = 40000,
    ["Gingerscope"]             = 17800,     ["Traveler's Axe"]          = 8400,
    ["Celestial"]               = 2000,      ["Vampire's Axe"]           = 1200,
    ["Harvester"]               = 248,       ["Icepiercer"]              = 163,
    ["Batwing"]                 = 46,        ["Elderwood Scythe"]        = 44,
    ["Hallowscythe"]            = 34,        ["Icebreaker"]              = 69,
    ["Icewing"]                 = 15,        ["Logchopper"]              = 18,
    ["Swirly Axe"]              = 42,
    ["Chroma Traveler's Gun"]   = 220000,    ["Chroma Evergun"]          = 75000,
    ["Chroma Evergreen"]        = 59300,     ["Chroma Bauble"]           = 35000,
    ["Traveler's Gun"]          = 4900,      ["Evergun"]                 = 3500,
    ["Evergreen"]               = 2500,      ["Darkshot"]                = 1600,
    ["Darksword"]               = 1500,      ["Corrupt"]                 = 475,
    ["Watergun"]                = 248,       ["Candy"]                   = 83,
    ["Heartblade"]              = 69,        ["Bat"]                     = 61,
    ["Luger"]                   = 46,        ["Red Luger"]               = 44,
    ["Sugar"]                   = 39,        ["Shark"]                   = 22,
    ["Laser"]                   = 24,        ["Slasher"]                 = 19,
    ["Pixel"]                   = 19,        ["Iceflake"]                = 19,
    ["Ice Dragon"]              = 7,         ["Seer"]                    = 3,
    ["Pearl"]                   = 98,        ["Pearlshine"]              = 103,
    ["Yellow Seer"]             = 2,         ["Orange Seer"]             = 2,
    ["Red Seer"]                = 3,         ["Cyan Seer"]               = 3,
    ["Blue Seer"]               = 3,         ["Purple Seer"]             = 3,
    ["Predator"]                = 4,         ["Shaded"]                  = 2,
    ["Vampire (Gun)"]           = 48,        ["JD"]                      = 35,
    ["Cotton Candy"]            = 40,
}

-- =============================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (v4.3)
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI_v43"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 260)
mainFrame.Position = UDim2.new(0, 20, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = mainFrame
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(180, 0, 255) stroke.Thickness = 2 stroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(130, 0, 210)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 10) tc.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Auto Trader v4.3"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
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

local profitLabel = Instance.new("TextLabel")
profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
profitLabel.Size = UDim2.new(1, -20, 0, 20)
profitLabel.Position = UDim2.new(0, 10, 0, 115)
profitLabel.BackgroundTransparency = 1
profitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
profitLabel.TextSize = 13
profitLabel.Font = Enum.Font.Gotham
profitLabel.TextXAlignment = Enum.TextXAlignment.Left
profitLabel.Parent = mainFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Text = "−"
minusBtn.Size = UDim2.new(0, 45, 0, 28)
minusBtn.Position = UDim2.new(0, 10, 0, 138)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextSize = 14
minusBtn.Parent = mainFrame
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,4) mc.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 45, 0, 28)
plusBtn.Position = UDim2.new(0, 60, 0, 138)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.TextSize = 14
plusBtn.Parent = mainFrame
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,4) pc.Parent = plusBtn

local debugToggleBtn = Instance.new("TextButton")
debugToggleBtn.Text = "🔍 Показать панель анализа"
debugToggleBtn.Size = UDim2.new(1, -20, 0, 32)
debugToggleBtn.Position = UDim2.new(0, 10, 0, 175)
debugToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
debugToggleBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
debugToggleBtn.Font = Enum.Font.GothamBold
debugToggleBtn.BorderSizePixel = 0
debugToggleBtn.Parent = mainFrame
local dbc = Instance.new("UICorner") dbc.CornerRadius = UDim.new(0,6) dbc.Parent = debugToggleBtn

-- =============================================
-- ПАНЕЛЬ АНАЛИЗА СЛОТОВ
-- =============================================
local debugFrame = Instance.new("Frame")
debugFrame.Size = UDim2.new(0, 400, 0, 250)
debugFrame.Position = UDim2.new(0, 310, 0.35, 0)
debugFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
debugFrame.BorderSizePixel = 0
debugFrame.Active = true
debugFrame.Draggable = true
debugFrame.Visible = false
debugFrame.Parent = screenGui
local dbCorner = Instance.new("UICorner") dbCorner.CornerRadius = UDim.new(0, 10) dbCorner.Parent = debugFrame
local dbStroke = Instance.new("UIStroke") dbStroke.Color = Color3.fromRGB(130, 0, 210) dbStroke.Thickness = 2 dbStroke.Parent = debugFrame

local myCol = Instance.new("Frame")
myCol.Size = UDim2.new(0.5, -8, 1, -60)
myCol.Position = UDim2.new(0, 6, 0, 20)
myCol.BackgroundTransparency = 0.9
myCol.BackgroundColor3 = Color3.fromRGB(0,255,0)
myCol.Parent = debugFrame

local myItemsLabel = Instance.new("TextLabel")
myItemsLabel.Text = "Твои вещи: пусто"
myItemsLabel.Size = UDim2.new(1, -8, 1, -20)
myItemsLabel.Position = UDim2.new(0, 4, 0, 5)
myItemsLabel.BackgroundTransparency = 1
myItemsLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
myItemsLabel.TextSize = 11
myItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
myItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
myItemsLabel.Parent = myCol

local myTotalLabel = Instance.new("TextLabel")
myTotalLabel.Text = "Ты даешь: 0"
myTotalLabel.Size = UDim2.new(1, 0, 0, 20)
myTotalLabel.Position = UDim2.new(0, 0, 1, -20)
myTotalLabel.BackgroundTransparency = 1
myTotalLabel.Font = Enum.Font.GothamBold
myTotalLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
myTotalLabel.Parent = myCol

local theirCol = Instance.new("Frame")
theirCol.Size = UDim2.new(0.5, -8, 1, -60)
theirCol.Position = UDim2.new(0.5, 2, 0, 20)
theirCol.BackgroundTransparency = 0.9
theirCol.BackgroundColor3 = Color3.fromRGB(255,0,0)
theirCol.Parent = debugFrame

local theirItemsLabel = Instance.new("TextLabel")
theirItemsLabel.Text = "Вещи оппонента: пусто"
theirItemsLabel.Size = UDim2.new(1, -8, 1, -20)
theirItemsLabel.Position = UDim2.new(0, 4, 0, 5)
theirItemsLabel.BackgroundTransparency = 1
theirItemsLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
theirItemsLabel.TextSize = 11
theirItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
theirItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
theirItemsLabel.Parent = theirCol

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Text = "Тебе дают: 0"
theirTotalLabel.Size = UDim2.new(1, 0, 0, 20)
theirTotalLabel.Position = UDim2.new(0, 0, 1, -20)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
theirTotalLabel.Parent = theirCol

local resultLabel = Instance.new("TextLabel")
resultLabel.Text = "Ожидание открытия окна обмена..."
resultLabel.Size = UDim2.new(1, -12, 0, 30)
resultLabel.Position = UDim2.new(0, 6, 1, -35)
resultLabel.BackgroundTransparency = 1
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextSize = 12
resultLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
resultLabel.Parent = debugFrame

-- =============================================
-- СКАНИРОВАНИЕ И ФИЛЬТРАЦИЯ
-- =============================================
local function findTradeWindow()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "MM2TraderUI_v43" then
            local main = gui:FindFirstChild("Main", true)
            if main and main:FindFirstChild("Trade", true) then
                return main:FindFirstChild("Trade", true)
            end
        end
    end
    return nil
end

local function cleanItemName(text)
    if not text or text == "" or tonumber(text) or text == "Label" then return nil end
    local clean = text:match("^%s*(.-)%s*$")
    
    -- Защита от попадания системных слов и кнопок в массив предметов
    if clean:lower() == "accept" or clean:lower() == "decline" or clean:lower() == "your offer" or clean:lower() == "their offer" then 
        return nil 
    end
    
    if ItemValues[clean] then return clean end
    for name, _ in pairs(ItemValues) do
        if name:lower() == clean:lower() or clean:lower():find(name:lower(), 1, true) then
            return name
        end
    end
    return nil
end

-- Сбор предметов СТРОГО из контейнеров слотов
local function getItemsFromSlots(container)
    local found = {}
    if not container then return found end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local matched = cleanItemName(obj.Text)
            if matched then
                table.insert(found, matched)
            end
        end
    end
    return found
end

-- =============================================
-- ОСНОВНАЯ ЛОГИКА
-- =============================================
local function processTradeLogic()
    local tradeMain = findTradeWindow()
    
    if not tradeMain then
        resultLabel.Text = "⏳ Окно обмена MM2 закрыто или не найдено"
        resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end

    -- Находим точные контейнеры слотов внутри трейда MM2
    local yourSlotsFrame = tradeMain:FindFirstChild("YourSlots", true)
    local theirSlotsFrame = tradeMain:FindFirstChild("TheirSlots", true)

    -- Сканируем СТРОГО по контейнерам (теперь они никогда не перепутаются местами!)
    local myItems = getItemsFromSlots(yourSlotsFrame)
    local theirItems = getItemsFromSlots(theirSlotsFrame)

    -- Поиск кнопок и статуса
    local acceptBtn, declineBtn
    local opponentAccepted = false

    for _, obj in ipairs(tradeMain:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Visible then
            local name = obj.Name:lower()
            local text = obj.Text:lower()
            if name:find("accept") or text:find("accept") then acceptBtn = obj end
            if name:find("decline") or text:find("decline") then declineBtn = obj end
        end
        if obj:IsA("TextLabel") and obj.Visible then
            if obj.Text:upper():find("ACCEPTED") or obj.Text:upper():find("HAS ACCEPTED") then
                opponentAccepted = true
            end
        end
    end

    -- Подсчет стоимости трейда
    local myTotal, theirTotal = 0, 0
    local myLines, theirLines = {}, {}

    for _, n in ipairs(myItems) do
        local p = ItemValues[n] or 0
        myTotal = myTotal + p
        table.insert(myLines, n .. " (" .. p .. ")")
    end
    for _, n in ipairs(theirItems) do
        local p = ItemValues[n] or 0
        theirTotal = theirTotal + p
        table.insert(theirLines, n .. " (" .. p .. ")")
    end

    myItemsLabel.Text = #myLines > 0 and table.concat(myLines, "\n") or "Пусто"
    theirItemsLabel.Text = #theirLines > 0 and table.concat(theirLines, "\n") or "Пусто"
    myTotalLabel.Text = "Ты даешь: " .. myTotal
    theirTotalLabel.Text = "Тебе дают: " .. theirTotal

    if myTotal == 0 and theirTotal == 0 then
        resultLabel.Text = "Окна обмена пусты. Выставите предметы."
        resultLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        return
    end

    local profitValid = false
    local percent = 0
    if myTotal > 0 then
        local diff = theirTotal - myTotal
        percent = math.floor((diff / myTotal) * 100)
        profitValid = percent >= MIN_PROFIT_PERCENT
    else
        profitValid = theirTotal > 0
    end

    if traderEnabled then
        if profitValid then
            resultLabel.Text = "✅ Выгодно ("..percent.."%). Жму ACCEPT!"
            resultLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            if acceptBtn then
                pcall(function()
                    acceptBtn.MouseButton1Click:Fire()
                    local VIM = game:GetService("VirtualInputManager")
                    local pos = acceptBtn.AbsolutePosition + acceptBtn.AbsoluteSize / 2
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                end)
            end
        else
            resultLabel.Text = "❌ Убыток ("..percent.."%). Отклоняю!"
            resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            if declineBtn then
                pcall(function() declineBtn.MouseButton1Click:Fire() end)
            end
        end
    else
        if profitValid then
            resultLabel.Text = "Рекомендация: ЖМИ ACCEPT (Прибыль: +"..percent.."%)"
            resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            resultLabel.Text = "Рекомендация: ОТКЛОНЯЙ (Убыток: "..percent.."%)"
            resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

-- =============================================
-- ТАЙМЕРЫ И КНОПКИ
-- =============================================
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(processTradeLogic)
    end
end)

minusBtn.MouseButton1Click:Connect(function()
    if MIN_PROFIT_PERCENT > 0 then
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
