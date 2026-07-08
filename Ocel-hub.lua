-- ====================================================================
-- MM2 Auto Trader v6.7 (STRICT DECLINE FIX) + GITHUB DATABASE
-- ====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- Сетевые события
local TradeModules = ReplicatedStorage:WaitForChild("Trade", 5)
local AcceptRemote = TradeModules and TradeModules:WaitForChild("AcceptTrade", 2)
local DeclineRemote = TradeModules and TradeModules:WaitForChild("DeclineTrade", 2)

-- Очистка старых UI
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name:find("MM2TraderUI") or gui.Name == "MM2TraderDebug" or gui.Name == "MM2TraderUI_v67" then
        gui:Destroy()
    end
end

local MIN_PROFIT_PERCENT  = 5       
local traderEnabled       = false   
local lastActionTime      = 0      

-- Динамическая таблица цен
local ItemValues = {}
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/Rostik22803/Ocel-hub-auto-trade-mm2/refs/heads/main/mm2_values.json"

print("[Ocel Hub]: Подключение к удаленной базе данных GitHub...")

local success, response = pcall(function()
    return game:HttpGet(GITHUB_RAW_URL)
end)

if success and response then
    local decodeSuccess, decodedData = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if decodeSuccess and type(decodedData) == "table" then
        ItemValues = decodedData
        print("[Ocel Hub]: База цен успешно подтянута с твоего GitHub!")
    else
        warn("[Ocel Hub]: Кривой JSON файл на GitHub! Проверь синтаксис.")
    end
else
    warn("[Ocel Hub]: Не удалось загрузить базу данных из сети. Включен пустой дефолт.")
end

-- Настройка метатаблицы для авто-обнуления комонок/анкомонок/скрытых предметов
setmetatable(ItemValues, {
    __index = function(table, key)
        local itemName = tostring(key)
        print(string.format("[Ocel Hub] Комонка/Анкомонка/Предмет: \"%s\" -> Цена: 0", itemName))
        return 0
    end
})

-- Интерфейс управления
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI_v67"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = PlayerGui

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
makeDraggable(mainFrame, titleBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Trader v6.7"
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
debugFrame.Position = UDim2.new(0.05, 0, 0.50, 0)
debugFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
debugFrame.Active = true
debugFrame.Visible = true
debugFrame.Parent = screenGui
local dbCorner = Instance.new("UICorner") dbCorner.CornerRadius = UDim.new(0, 10) dbCorner.Parent = debugFrame
local dbStroke = Instance.new("UIStroke") dbStroke.Color = Color3.fromRGB(130, 0, 210) dbStroke.Thickness = 2 dbStroke.Parent = debugFrame

local dbTitle = Instance.new("Frame")
dbTitle.Size = UDim2.new(1, 0, 0, 24)
dbTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dbTitle.Parent = debugFrame
makeDraggable(debugFrame, dbTitle)

local dbTitleTxt = Instance.new("TextLabel")
dbTitleTxt.Text = " Зажмите здесь для перемещения панели"
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

-- Вспомогательные функции
local function isGloballyVisible(obj)
    local current = obj
    while current do
        if current:IsA("ScreenGui") then return current.Enabled end
        if current:IsA("GuiObject") then
            if not current.Visible then return false end
        end
        current = current.Parent
    end
    return true
end

local function cleanItemName(text)
    if not text or text == "" or tonumber(text) or text == "Label" then return nil end
    local clean = text:match("^%s*(.-)%s*$")
    
    local upperClean = clean:upper()
    if upperClean:find("ACCEPTED") or upperClean:find("OFFER") or upperClean:find("WAIT") or upperClean:find("ПОДОЖД") or upperClean:find("DECLINE") then
        return nil
    end
    
    if clean:find("%(") or clean:find("%)") then
        return nil
    end
    
    if rawget(ItemValues, clean) ~= nil then return clean end
    
    for name, _ in pairs(ItemValues) do
        if name:lower() == clean:lower() or clean:lower():find(name:lower(), 1, true) then
            return name
        end
    end
    
    return clean
end

local function isDescendantOf(obj, potentialAncestor)
    if not potentialAncestor then return false end
    local current = obj.Parent
    while current do
        if current == potentialAncestor then return true end
        current = current.Parent
    end
    return false
end

-- РЕМОУТЫ
local function triggerAcceptTrade()
    pcall(function()
        if AcceptRemote and AcceptRemote:IsA("RemoteEvent") then AcceptRemote:FireServer() end
    end)
end

local function triggerDeclineTrade()
    pcall(function()
        if DeclineRemote and DeclineRemote:IsA("RemoteEvent") then DeclineRemote:FireServer() end
    end)
end

-- Основной цикл парсинга v6.7
local function processTradeLogic()
    local myContainer = nil
    local theirContainer = nil
    local gameIsWaiting = false   
    local partnerAccepted = false 

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "MM2TraderUI_v67" then
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("TextLabel") and isGloballyVisible(desc) then
                    local txt = desc.Text:upper()
                    if txt == "YOUR OFFER" then
                        myContainer = desc.Parent
                    elseif txt:find("THEIR OFFER") or txt:find("PARTNER") or txt:find("OFFER") and desc.Position.X.Scale > 0.4 then
                        theirContainer = desc.Parent
                    end
                end
            end
        end
    end

    if not myContainer or not theirContainer or not isGloballyVisible(myContainer) then
        myItemsLabel.Text = "Пусто"
        theirItemsLabel.Text = "Пусто"
        myTotalLabel.Text = "Ты даешь: 0"
        theirTotalLabel.Text = "Тебе дают: 0"
        resultLabel.Text = "⏳ Окно обмена MM2 не обнаружено"
        resultLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        return
    end

    local myItems = {}
    local theirItems = {}
    local mainTradeWindow = myContainer.Parent

    -- Сканирование элементов
    for _, obj in ipairs(mainTradeWindow:GetDescendants()) do
        if obj:IsA("TextLabel") and isGloballyVisible(obj) then
            local txt = obj.Text:upper()
            
            if txt:find("WAIT") or txt:find("HOLD") or txt:find("ПОДОЖД") or txt:find("ПРИНЯТ") or txt:find("COUNT") then
                gameIsWaiting = true
            end
            
            -- ЖЕСТКИЙ ПЕРЕХВАТ ПЛАШКИ ПРИНЯТИЯ ТРЕЙДА
            if txt:find("HAS ACCEPTED") or txt:find("OTHER PLAYER HAS ACCEPTED") then
                partnerAccepted = true
            end
            
            if obj.Text ~= "" and not txt:find("OFFER") and not txt:find("WAIT") and not txt:find("ПОДОЖД") then
                local matched = cleanItemName(obj.Text)
                if matched then
                    if isDescendantOf(obj, myContainer) then
                        table.insert(myItems, matched)
                    elseif isDescendantOf(obj, theirContainer) then
                        table.insert(theirItems, matched)
                    end
                end
            end
        end
        
        -- Чтение статуса кнопок
        if obj:IsA("TextButton") and isGloballyVisible(obj) then
            local txt = obj.Text:upper()
            local name = obj.Name:lower()
            if txt:find("WAIT") or txt:find("ПОДОЖД") then
                gameIsWaiting = true
            end
            if name:find("partner") or name:find("accept") then
                if txt:find("READY") or txt:find("ACCEPTED") or (obj.BackgroundColor3.G > 0.4 and obj.BackgroundColor3.R < 0.3) then
                    partnerAccepted = true
                end
            end
        end
    end

    local myTotal, theirTotal = 0, 0
    local myLines, theirLines = {}, {}

    for _, n in ipairs(myItems) do
        local p = ItemValues[n] 
        myTotal = myTotal + p
        table.insert(myLines, n .. " (" .. p .. ")")
    end
    for _, n in ipairs(theirItems) do
        local p = ItemValues[n] 
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

    local profitValid = false
    local percent = 0
    if myTotal > 0 then
        local diff = theirTotal - myTotal
        percent = math.floor((diff / myTotal) * 100)
        profitValid = percent >= MIN_PROFIT_PERCENT
    else
        profitValid = theirTotal > 0
    end

    -- ЛОГИКА ДЕЙСТВИЙ (ОБНОВЛЕННАЯ)
    if traderEnabled and (os.clock() - lastActionTime > 1.2) then
        if profitValid then
            if not gameIsWaiting then
                lastActionTime = os.clock()
                resultLabel.Text = "✅ Всё ок! Принимаю трейд..."
                resultLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                triggerAcceptTrade()
            else
                resultLabel.Text = "🛑 Блокировка: игра просит подождать..."
                resultLabel.TextColor3 = Color3.fromRGB(255, 100, 50)
            end
        else
            -- Если челик принял плохой трейд (partnerAccepted теперь гарантированно поймает плашку)
            if partnerAccepted then
                lastActionTime = os.clock()
                resultLabel.Text = "❌ Челик принял плохой трейд. Отклоняю!"
                resultLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                triggerDeclineTrade()
            else
                resultLabel.Text = "⏳ Трейд невыгоден, но жду, вдруг докинет вещи..."
                resultLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
            end
        end
    else
        if not traderEnabled then
            if profitValid then
                resultLabel.Text = "Рекомендация: ПРИНИМАЙ (+"..percent.."%)"
                resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                resultLabel.Text = "Рекомендация: ОТКЛОНЯЙ ("..percent.."%)"
                resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
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
