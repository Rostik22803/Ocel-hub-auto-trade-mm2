-- =============================================
-- MM2 Auto Trader v4.0 (REAL MM2 LAYOUT ADAPTED)
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
local AUTO_DECLINE_UNKNOWN = false  -- отклонять ли при неизвестных предметах

-- =============================================
-- ПОЛНАЯ ТАБЛИЦА ЦЕН MM2 ( game.guide )
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
    ["Chroma Bauble"]           = 35000,
    ["Chroma Vampire's Gun"]    = 29000,
    ["Chroma Constellation"]    = 27300,
    ["Chroma Alienbeam"]        = 23500,
    ["Chroma Raygun"]           = 14400,
    ["Chroma Sunrise"]          = 11500,
    ["Chroma Snowcannon"]       = 8600,
    ["Chroma Blizzard"]         = 7900,
    ["Chroma Sunset"]           = 6500,
    ["Chroma Heart Wand"]       = 4700,
    ["Chroma Snow Dagger"]      = 4400,
    ["Chroma Snowstorm"]        = 4300,
    ["Chroma Watergun"]         = 3400,
    ["Chroma Treat"]            = 2600,
    ["Chroma Sweet"]            = 2300,
    ["Chroma Ornament"]         = 1800,
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
    ["Yellow Seer"]             = 2,
    ["Orange Seer"]             = 2,
    ["Red Seer"]                = 3,
    ["Cyan Seer"]               = 3,
    ["Blue Seer"]               = 3,
    ["Purple Seer"]             = 3,

    -- ===== LEGENDARIES & RARE =====
    ["Predator"]                = 4,
    ["Shaded"]                  = 2,
    ["Vampire (Gun)"]           = 48,
    ["JD"]                      = 35,
    ["Cotton Candy"]            = 40,
}

-- =============================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (ПОВЕРХ ИГРЫ)
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI_v4"
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
titleLabel.Text = "MM2 Auto Trader v4.0"
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
-- ПАНЕЛЬ ОТЛАДКИ И СТАТИСТИКИ
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
-- АЛГОРИТМ ПОИСКА И СКАНИРОВАНИЯ MM2 GUI
-- =============================================
local function findMM2TradeWindow()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            -- Ищем блоки по текстам заголовков на скриншоте
            local yourOffer = gui:FindFirstChild("YOUR OFFER", true) or gui:FindFirstChild("Your Offer", true)
            local theirOffer = gui:FindFirstChild("THEIR OFFER", true) or gui:FindFirstChild("Their Offer", true)
            
            if yourOffer or theirOffer then
                -- Возвращаем корневой фрейм, в котором лежат эти надписи
                if yourOffer then return yourOffer.Parent end
            end
        end
    end
    return nil
end

local function cleanItemName(text)
    if not text or text == "" or tonumber(text) then return nil end
    local clean = text:match("^%s*(.-)%s*$") -- убираем пробелы
    if ItemValues[clean] then return clean end
    
    -- Нечеткий поиск
    for name, _ in pairs(ItemValues) do
        if name:lower() == clean:lower() or clean:lower():find(name:lower(), 1, true) then
            return name
        end
    end
    return nil
end

local function scanTradeSide(containerFrame)
    local items = {}
    if not containerFrame then return items end
    
    for _, obj in ipairs(containerFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local matched = cleanItemName(obj.Text)
            if matched then
                table.insert(items, matched)
            end
        end
    end
    return items
end

-- Основная функция проверки
local function processTradeLogic()
    local tradeMain = findMM2TradeWindow()
    
    if not tradeMain then
        resultLabel.Text = "❌ Окно обмена MM2 не обнаружено"
        resultLabel.TextColor3 = Color3.fromRGB(220, 100, 100)
        return
    end

    -- На скриншоте контейнеры называются прямо по тексту заголовков
    local yourOfferBox = tradeMain:FindFirstChild("YOUR OFFER") or tradeMain
    local theirOfferBox = tradeMain:FindFirstChild("THEIR OFFER") or tradeMain

    local myItems = scanTradeSide(yourOfferBox)
    local theirItems = scanTradeSide(theirOfferBox)

    -- Фильтруем пересечения (чтобы мои не считались чужими, если они в одном общем фрейме)
    -- Если скрипт нашел всё в одном месте, разделим по половинам экрана
    if #myItems == 0 or #theirItems == 0 then
        myItems = {}
        theirItems = {}
        local screenW = workspace.CurrentCamera.ViewportSize.X
        for _, obj in ipairs(tradeMain:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local matched = cleanItemName(obj.Text)
                if matched then
                    if obj.AbsolutePosition.Y < tradeMain.AbsolutePosition.Y + (tradeMain.AbsoluteSize.Y / 2) then
                        -- Верхняя часть ("YOUR OFFER")
                        table.insert(myItems, matched)
                    else
                        -- Нижняя часть ("THEIR OFFER")
                        table.insert(theirItems, matched)
                    end
                end
            end
        end
    end

    -- Считаем цены
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

    -- Ищем кнопки управления на самом окне MM2
    local acceptBtn, declineBtn
    for _, btn in ipairs(tradeMain:GetDescendants()) do
        if btn:IsA("TextButton") then
            local t = btn.Text:lower()
            if t:find("accept") or btn.Name:lower():find("accept") then acceptBtn = btn end
            if t:find("decline") or btn.Name:lower():find("decline") then declineBtn = btn end
        end
    end

    -- Проверка на надпись Оппонента "OTHER PLAYER HAS ACCEPTED."
    local opponentAccepted = false
    for _, textLabel in ipairs(tradeMain:GetDescendants()) do
        if textLabel:IsA("TextLabel") and textLabel.Text:upper():find("OTHER PLAYER HAS ACCEPTED") then
            opponentAccepted = true
            break
        end
    end

    -- Если трейд пустой
    if myTotal == 0 and theirTotal == 0 then
        resultLabel.Text = "Окна обмена пусты. Выставите предметы."
        resultLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        return
    end

    -- Логика выгоды
    local profitValid = false
    local percent = 0
    if myTotal > 0 then
        local diff = theirTotal - myTotal
        percent = math.floor((diff / myTotal) * 100)
        profitValid = percent >= MIN_PROFIT_PERCENT
    else
        profitValid = theirTotal > 0 -- Если мы ничего не даем, а нам дают — это выгодно
    end

    -- САМОЕ ГЛАВНОЕ: Если оппонент ЕЩЕ НЕ нажал Accept
    if not opponentAccepted then
        resultLabel.Text = "⏳ Жду, пока другой игрок нажмет ACCEPT..."
        resultLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
        return -- Выходим, ничего не нажимаем!
    end

    -- Если дошли сюда — значит другой игрок СОГЛАСЕН. Принимаем решение:
    if traderEnabled then
        if profitValid then
            resultLabel.Text = "✅ Выгодно ("..percent.."%). Подтверждаю!"
            resultLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            if acceptBtn then
                acceptBtn.MouseButton1Click:Fire()
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    local pos = acceptBtn.AbsolutePosition + acceptBtn.AbsoluteSize / 2
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                end)
            end
        else
            resultLabel.Text = "❌ Невыгодно ("..percent.."%). Отклоняю!"
            resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            if declineBtn then
                declineBtn.MouseButton1Click:Fire()
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
-- ЦИКЛ И КНОПКИ ИНТЕРФЕЙСА
-- =============================================
task.spawn(function()
    while true do
        task.wait(0.2) -- Быстрый отклик на нажатие кнопки игроком
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
