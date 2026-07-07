-- =============================================
-- MM2 Auto Trader v5.3 (MOBILE POSITION & DRAG FIX)
-- =============================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- Полная очистка старых версий
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name:find("MM2TraderUI") or gui.Name == "MM2TraderDebug" then
        gui:Destroy()
    end
end

-- =============================================
-- НАСТРОЙКИ И ОБНОВЛЕННЫЕ ЦЕНЫ (Добавлены Sharky, Space, Splash)
-- =============================================
local MIN_PROFIT_PERCENT  = 5       
local traderEnabled       = false   

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
    ["Cotton Candy"]            = 40,        ["Starfish"]                = 2,
    ["Splash"]                  = 3,         ["Space"]                   = 2,
    ["Sharky"]                  = 5,         -- Добавлено по логам
}

-- =============================================
-- ИНТЕРФЕЙС GUI
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI_v53"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = PlayerGui

-- Функция для добавления перетаскивания (Drag) на мобилках
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 240)
mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = mainFrame
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(180, 0, 255) stroke.Thickness = 2 stroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(130, 0, 210)
titleBar.Parent = mainFrame
local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 10) tc.Parent = titleBar
makeDraggable(mainFrame, titleBar) -- Главное меню теперь таскается за шапку

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Trader v5.3"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = titleBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Статус: ВЫКЛЮЧЕН"
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 0, 44)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = "▶  Включить автотрейд"
toggleBtn.Size = UDim2.new(1, -20, 0, 34)
toggleBtn.Position = UDim2.new(0, 10, 0, 72)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 6) btnCorner.Parent = toggleBtn

local profitLabel = Instance.new("TextLabel")
profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
profitLabel.Size = UDim2.new(1, -20, 0, 20)
profitLabel.Position = UDim2.new(0, 10, 0, 112)
profitLabel.BackgroundTransparency = 1
profitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
profitLabel.Parent = mainFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Text = "−"
minusBtn.Size = UDim2.new(0, 45, 0, 28)
minusBtn.Position = UDim2.new(0, 10, 0, 134)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.Parent = mainFrame
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,4) mc.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 45, 0, 28)
plusBtn.Position = UDim2.new(0, 60, 0, 134)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.Parent = mainFrame
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,4) pc.Parent = plusBtn

local debugToggleBtn = Instance.new("TextButton")
debugToggleBtn.Text = "🔍 Панель анализа"
debugToggleBtn.Size = UDim2.new(1, -20, 0, 32)
debugToggleBtn.Position = UDim2.new(0, 10, 0, 175)
debugToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
debugToggleBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
debugToggleBtn.Parent = mainFrame
local dbc = Instance.new("UICorner") dbc.CornerRadius = UDim.new(0,6) dbc.Parent = debugToggleBtn

-- Панель анализа
local debugFrame = Instance.new("Frame")
debugFrame.Size = UDim2.new(0, 340, 0, 220)
debugFrame.Position = UDim2.new(0.05, 0, 0.50, 0) -- По дефолту пониже основного меню
debugFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
debugFrame.Active = true
debugFrame.Visible = true -- Сразу показываем, чтобы юзер видел, двигается ли оно
debugFrame.Parent = screenGui
local dbCorner = Instance.new("UICorner") dbCorner.CornerRadius = UDim.new(0, 10) dbCorner.Parent = debugFrame
local dbStroke = Instance.new("UIStroke") dbStroke.Color = Color3.fromRGB(130, 0, 210) dbStroke.Thickness = 2 dbStroke.Parent = debugFrame

local dbTitle = Instance.new("Frame")
dbTitle.Size = UDim2.new(1, 0, 0, 24)
dbTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dbTitle.Parent = debugFrame
makeDraggable(debugFrame, dbTitle) -- ПАНЕЛЬ АНАЛИЗА ТЕПЕРЬ СВОБОДНО ПЕРЕТАСКИВАЕТСЯ ЗА СВОЮ ШАПКУ

local dbTitleTxt = Instance.new("TextLabel")
dbTitleTxt.Text = " Нажмите сюда пальцем для перемещения"
dbTitleTxt.Size = UDim2.new(1, 0, 1, 0)
dbTitleTxt.BackgroundTransparency = 1
dbTitleTxt.TextColor3 = Color3.fromRGB(200, 255, 200)
dbTitleTxt.Font = Enum.Font.Gotham
dbTitleTxt.TextSize = 11
dbTitleTxt.Parent = dbTitle

local myCol = Instance.new("Frame")
myCol.Size = UDim2.new(0.5, -6, 1, -65)
myCol.Position = UDim2.new(0, 4, 0, 30)
myCol.BackgroundTransparency = 0.95
myCol.BackgroundColor3 = Color3.fromRGB(0,255,0)
myCol.Parent = debugFrame

local myItemsLabel = Instance.new("TextLabel")
myItemsLabel.Text = "Твои вещи: пусто"
myItemsLabel.Size = UDim2.new(1, -6, 1, -16)
myItemsLabel.Position = UDim2.new(0, 3, 0, 2)
myItemsLabel.BackgroundTransparency = 1
myItemsLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
myItemsLabel.TextSize = 11
myItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
myItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
myItemsLabel.Parent = myCol

local myTotalLabel = Instance.new("TextLabel")
myTotalLabel.Text = "Ты даешь: 0"
myTotalLabel.Size = UDim2.new(1, 0, 0, 16)
myTotalLabel.Position = UDim2.new(0, 0, 1, -16)
myTotalLabel.BackgroundTransparency = 1
myTotalLabel.Font = Enum.Font.GothamBold
myTotalLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
myTotalLabel.TextSize = 12
myTotalLabel.Parent = myCol

local theirCol = Instance.new("Frame")
theirCol.Size = UDim2.new(0.5, -6, 1, -65)
theirCol.Position = UDim2.new(0.5, 2, 0, 30)
theirCol.BackgroundTransparency = 0.95
theirCol.BackgroundColor3 = Color3.fromRGB(255,0,0)
theirCol.Parent = debugFrame

local theirItemsLabel = Instance.new("TextLabel")
theirItemsLabel.Text = "Вещи оппонента: пусто"
theirItemsLabel.Size = UDim2.new(1, -6, 1, -16)
theirItemsLabel.Position = UDim2.new(0, 3, 0, 2)
theirItemsLabel.BackgroundTransparency = 1
theirItemsLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
theirItemsLabel.TextSize = 11
theirItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
theirItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
theirItemsLabel.Parent = theirCol

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Text = "Тебе дают: 0"
theirTotalLabel.Size = UDim2.new(1, 0, 0, 16)
theirTotalLabel.Position = UDim2.new(0, 0, 1, -16)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
theirTotalLabel.TextSize = 12
theirTotalLabel.Parent = theirCol

local resultLabel = Instance.new("TextLabel")
resultLabel.Text = "Ожидание открытия окна обмена..."
resultLabel.Size = UDim2.new(1, -12, 0, 24)
resultLabel.Position = UDim2.new(0, 6, 1, -28)
resultLabel.BackgroundTransparency = 1
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextSize = 11
resultLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
resultLabel.Parent = debugFrame

-- =============================================
-- ЧИСТКА СТРОК С КОРРЕКЦИЕЙ
-- =============================================
local function cleanItemName(text)
    if not text or text == "" or tonumber(text) or text == "Label" then return nil end
    local clean = text:match("^%s*(.-)%s*$")
    
    if ItemValues[clean] then return clean end
    for name, _ in pairs(ItemValues) do
        if name:lower() == clean:lower() or clean:lower():find(name:lower(), 1, true) then
            return name
        end
    end
    return nil
end

-- =============================================
-- НАДЁЖНЫЙ СКАНЕР ДЛЯ МОБИЛОК
-- =============================================
local function processTradeLogic()
    local tradeFrame = nil
    
    -- Ищем окно по надписи "YOUR OFFER"
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "MM2TraderUI_v53" then
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text:upper() == "YOUR OFFER" then
                    tradeFrame = desc.Parent
                    break
                end
            end
        end
        if tradeFrame then break end
    end

    if not tradeFrame then
        resultLabel.Text = "⏳ Окно обмена MM2 не обнаружено"
        return
    end

    local myItems = {}
    local theirItems = {}
    local acceptBtn, declineBtn = nil, nil

    -- ВМЕСТО КРИВОГО ЦЕНТРА: Берем Х-координату самого фрейма и добавляем 42% от его ширины.
    -- Все элементы, чья позиция X меньше этой черты — ТВОИ. Всё, что правее — ОППОНЕНТА.
    local splitLineX = tradeFrame.AbsolutePosition.X + (tradeFrame.AbsoluteSize.X * 0.42)

    for _, obj in ipairs(tradeFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text ~= "" then
            local matched = cleanItemName(obj.Text)
            if matched and not obj.Text:upper():find("OFFER") then
                -- Сравниваем позицию текста с нашей разделительной линией
                if obj.AbsolutePosition.X < splitLineX then
                    table.insert(myItems, matched)
                else
                    table.insert(theirItems, matched)
                end
            end
        end

        -- Сбор кнопок
        if obj:IsA("TextButton") then
            local name = obj.Name:lower()
            local text = obj.Text:lower()
            if name:find("accept") or text:find("accept") then acceptBtn = obj end
            if name:find("decline") or text:find("decline") then declineBtn = obj end
        end
    end

    -- Вывод в панели
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
        resultLabel.Text = "Окна обмена пусты."
        resultLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        return
    end

    -- Логика подсчета выгоды
    local profitValid = false
    local percent = 0
    if myTotal > 0 then
        local diff = theirTotal - myTotal
        percent = math.floor((diff / myTotal) * 100)
        profitValid = percent >= MIN_PROFIT_PERCENT
    else
        profitValid = theirTotal > 0
    end

    -- Автокликер
    if traderEnabled then
        if profitValid then
            resultLabel.Text = "✅ Жму ACCEPT (Прибыль: "..percent.."%)"
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
            resultLabel.Text = "❌ Отклоняю (Убыток: "..percent.."%)"
            resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            if declineBtn then pcall(function() declineBtn.MouseButton1Click:Fire() end) end
        end
    else
        if profitValid then
            resultLabel.Text = "Рекомендация: ЖМИ ACCEPT (+"..percent.."%)"
            resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            resultLabel.Text = "Рекомендация: ОТКЛОНЯЙ ("..percent.."%)"
            resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

-- Воркер-раннер
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(processTradeLogic)
    end
end)

-- Ивенты кнопок управления
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
