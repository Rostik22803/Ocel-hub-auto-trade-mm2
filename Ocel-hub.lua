-- =============================================
-- MM2 Auto Trader v2.0
-- =============================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local MIN_PROFIT_PERCENT  = 5       -- % прибыли для принятия трейда
local AUTO_DECLINE_UNKNOWN = true   -- отклонять трейды с неизвестными предметами
local traderEnabled       = false   -- включён ли автотрейд (управляется из меню)

-- =============================================
-- ПОЛНАЯ ТАБЛИЦА ЦЕН MM2
-- =============================================
local ItemValues = {
    -- ===== ANCIENTS =====
    ["Elderwood Scythe"]        = 10000,
    ["Hallows Edge"]            = 8000,
    ["Eternal"]                 = 6000,
    ["Pumpking"]                = 5500,
    ["Tides"]                   = 5000,
    ["Ooze"]                    = 4500,
    ["Fang"]                    = 4000,
    ["Void"]                    = 3800,
    ["Minty"]                   = 3500,
    ["Seer Godly"]              = 3200,

    -- ===== CHROMA GODLYS =====
    ["Chroma Deathshard"]       = 3000,
    ["Chroma Laser"]            = 2500,
    ["Chroma Saw"]              = 2200,
    ["Chroma Harvester"]        = 2000,
    ["Chroma Shark"]            = 1900,
    ["Chroma Luger"]            = 1850,
    ["Chroma Emerald"]          = 1750,
    ["Chroma Gemstone"]         = 1600,
    ["Chroma Icebreaker"]       = 1400,
    ["Chroma Heat"]             = 1300,
    ["Chroma Candleflame"]      = 1200,
    ["Chroma Ice Shard"]        = 1100,
    ["Chroma Web"]              = 1050,
    ["Chroma Slasher"]          = 1000,
    ["Chroma Seer"]             = 950,
    ["Chroma Elderflame"]       = 900,
    ["Chroma Luger (Gun)"]      = 880,
    ["Chroma Dark Matter"]      = 850,
    ["Chroma Boneblade"]        = 820,

    -- ===== UNIQUES =====
    ["Batwing"]                 = 800,
    ["Dark Matter"]             = 750,
    ["Gingerblade"]             = 700,
    ["Amercement"]              = 650,
    ["Infected Godly"]          = 600,
    ["Void Shard"]              = 550,
    ["Logchopper"]              = 520,
    ["Clockwork"]               = 500,
    ["Stitches"]                = 480,
    ["Flames"]                  = 460,
    ["Lucky"]                   = 440,
    ["Eternalvoid"]             = 420,
    ["Party"]                   = 400,

    -- ===== GODLYS (ножи) =====
    ["Deathshard"]              = 500,
    ["Laser"]                   = 450,
    ["Saw"]                     = 420,
    ["Harvester"]               = 400,
    ["Shark"]                   = 380,
    ["Luger"]                   = 350,
    ["Gemstone"]                = 320,
    ["Elderflame"]              = 300,
    ["Icebreaker"]              = 280,
    ["Web"]                     = 250,
    ["Heat"]                    = 230,
    ["Slasher"]                 = 200,
    ["Ice Shard"]               = 180,
    ["Candleflame"]             = 160,
    ["Emerald"]                 = 150,
    ["Illumina"]                = 140,
    ["Ghostblade"]              = 130,
    ["Violet"]                  = 125,
    ["Peppermint"]              = 120,
    ["Uncommon Seer"]           = 115,
    ["Lucky Clover"]            = 110,
    ["Rainbow"]                 = 105,
    ["Fire"]                    = 100,
    ["Beekeeper"]               = 95,
    ["Ancient Shard"]           = 90,
    ["Heartblade"]              = 88,
    ["Penta"]                   = 85,
    ["Bioblade"]                = 83,
    ["Sleigh"]                  = 80,
    ["Heat Wave"]               = 78,
    ["Frostshard"]              = 75,
    ["Tentacle"]                = 73,
    ["Frozen"]                  = 70,
    ["Snowflake"]               = 68,
    ["Infected"]                = 65,
    ["Toxic"]                   = 63,
    ["Sunrise"]                 = 60,
    ["Darkblade"]               = 58,
    ["Plasma"]                  = 55,
    ["Corrupt"]                 = 53,
    ["Shard"]                   = 50,
    ["Eternal Darkness"]        = 48,

    -- ===== GODLYS (пушки) =====
    ["Luger (Gun)"]             = 350,
    ["Colt"]                    = 200,
    ["Revolver"]                = 180,
    ["Dartgun"]                 = 160,
    ["Sniper"]                  = 150,
    ["Minigun"]                 = 140,

    -- ===== LEGENDARIES =====
    ["Seer"]                    = 100,
    ["Seer Knife"]              = 100,
    ["Icewing"]                 = 80,
    ["Boneblade"]               = 60,
    ["Swordmaster"]             = 55,
    ["Chill"]                   = 50,
    ["Ninja"]                   = 48,
    ["Soul"]                    = 45,
    ["Teal"]                    = 43,
    ["Icicle"]                  = 40,
    ["Silence"]                 = 38,
    ["Candy"]                   = 35,
    ["Purple"]                  = 33,
    ["Jingle"]                  = 30,
    ["Coil"]                    = 28,
    ["Autumn"]                  = 25,
    ["Spooky"]                  = 23,
    ["Hallow"]                  = 20,
    ["Copper"]                  = 18,
    ["Radioactive"]             = 15,
    ["Serpent"]                 = 13,
    ["Thunder"]                 = 12,
    ["Bat"]                     = 10,
    ["Spike"]                   = 8,
    ["Frost"]                   = 7,
    ["Snowball"]                = 6,
    ["Crystal"]                 = 5,
    ["Shadow"]                  = 4,
}

-- =============================================
-- GUI МЕНЮ
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Скруглённые углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Обводка
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 0, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Фикс нижних углов заголовка
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Auto Trader"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Статус: ВЫКЛЮЧЕН"
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 0, 48)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

-- Кнопка вкл/выкл
local toggleBtn = Instance.new("TextButton")
toggleBtn.Text = "▶  Включить автотрейд"
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 80)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- Ползунок % прибыли
local profitLabel = Instance.new("TextLabel")
profitLabel.Text = "Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%"
profitLabel.Size = UDim2.new(1, -20, 0, 20)
profitLabel.Position = UDim2.new(0, 10, 0, 132)
profitLabel.BackgroundTransparency = 1
profitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
profitLabel.TextSize = 13
profitLabel.Font = Enum.Font.Gotham
profitLabel.TextXAlignment = Enum.TextXAlignment.Left
profitLabel.Parent = mainFrame

-- Кнопки - / +
local minusBtn = Instance.new("TextButton")
minusBtn.Text = "  −"
minusBtn.Size = UDim2.new(0, 40, 0, 28)
minusBtn.Position = UDim2.new(0, 10, 0, 158)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextSize = 16
minusBtn.Font = Enum.Font.GothamBold
minusBtn.BorderSizePixel = 0
minusBtn.Parent = mainFrame
local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,6) mc.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+  "
plusBtn.Size = UDim2.new(0, 40, 0, 28)
plusBtn.Position = UDim2.new(0, 58, 0, 158)
plusBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.TextSize = 16
plusBtn.Font = Enum.Font.GothamBold
plusBtn.BorderSizePixel = 0
plusBtn.Parent = mainFrame
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,6) pc.Parent = plusBtn

-- Подсказка
local tipLabel = Instance.new("TextLabel")
tipLabel.Text = "Тяни заголовок чтобы перемещать"
tipLabel.Size = UDim2.new(1, -20, 0, 16)
tipLabel.Position = UDim2.new(0, 10, 1, -22)
tipLabel.BackgroundTransparency = 1
tipLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
tipLabel.TextSize = 11
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.Parent = mainFrame

-- Кнопки управления прибылью
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

-- Кнопка включения/выключения
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
    print("[Trader] Автотрейд: " .. (traderEnabled and "ВКЛЮЧЁН" or "ВЫКЛЮЧЁН"))
end)

-- =============================================
-- ЛОГИКА ЦЕН
-- =============================================
local function getItemValue(name)
    if not name or name == "" then return 0 end
    if ItemValues[name] then return ItemValues[name] end
    local lname = name:lower()
    for k, v in pairs(ItemValues) do
        if lname:find(k:lower(), 1, true) then return v end
    end
    return 0
end

local function calcTotal(items)
    local total, unknown = 0, {}
    for _, name in ipairs(items) do
        local val = getItemValue(name)
        if val == 0 then table.insert(unknown, name) end
        total = total + val
    end
    return total, unknown
end

local function isProfitable(myItems, theirItems)
    local myVal,    myUnk    = calcTotal(myItems)
    local theirVal, theirUnk = calcTotal(theirItems)

    print("[Trader] Я отдаю: " .. myVal .. " | Я получаю: " .. theirVal)

    if AUTO_DECLINE_UNKNOWN and (#myUnk > 0 or #theirUnk > 0) then
        print("[Trader] Неизвестные предметы — отклоняем")
        for _, v in ipairs(myUnk)    do print("  ? (мой): " .. v) end
        for _, v in ipairs(theirUnk) do print("  ? (их): "  .. v) end
        return false
    end

    if myVal == 0 then return false end

    local profit = ((theirVal - myVal) / myVal) * 100
    print(string.format("[Trader] Прибыль: %.1f%% (мин: %d%%)", profit, MIN_PROFIT_PERCENT))
    return profit >= MIN_PROFIT_PERCENT
end

-- =============================================
-- КЛИК ПО КНОПКЕ (несколько методов)
-- =============================================
local function clickButton(btn)
    if not btn then return end
    -- Метод 1: fire click event
    btn.MouseButton1Click:Fire()
    task.wait(0.1)
    -- Метод 2: через VirtualInputManager если первый не сработал
    local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
    local VIM = game:GetService("VirtualInputManager")
    if VIM then
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end
end

-- =============================================
-- ПОИСК ПРЕДМЕТОВ В GUI
-- =============================================
local function extractItems(frame)
    local names = {}
    if not frame then return names end
    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local t = desc.Text
            if t and #t > 2
               and t ~= "Empty"
               and not t:match("^%d+$")
               and not t:lower():match("accept")
               and not t:lower():match("decline")
               and not t:lower():match("trade")
               and not t:lower():match("offer")
               and not t:lower():match("cancel") then
                -- Проверяем что предмет есть в нашей таблице (или хотя бы похож)
                if getItemValue(t) > 0 then
                    table.insert(names, t)
                end
            end
        end
    end
    return names
end

-- =============================================
-- ОБРАБОТЧИК ТРЕЙДА
-- =============================================
local activeTradeGuis = {}

local function handleTradeGui(tradeGui)
    if activeTradeGuis[tradeGui] then return end
    activeTradeGuis[tradeGui] = true

    print("[Trader] Трейд-окно: " .. tradeGui.Name)
    task.wait(3) -- ждём заполнения предметов

    if not traderEnabled then
        print("[Trader] Автотрейд выключен, пропускаем")
        activeTradeGuis[tradeGui] = nil
        return
    end

    -- Ищем все TextLabel с предметами
    local allLabels = {}
    for _, desc in ipairs(tradeGui:GetDescendants()) do
        if desc:IsA("TextLabel") and getItemValue(desc.Text) > 0 then
            table.insert(allLabels, desc)
        end
    end

    -- Разделяем на "мои" и "их" по позиции X на экране (левая / правая половина)
    local myItems, theirItems = {}, {}
    local screenWidth = workspace.CurrentCamera.ViewportSize.X

    for _, label in ipairs(allLabels) do
        local absX = label.AbsolutePosition.X
        if absX < screenWidth / 2 then
            table.insert(myItems, label.Text)
        else
            table.insert(theirItems, label.Text)
        end
    end

    -- Если разделение по X не дало результата — делим по порядку
    if #myItems == 0 and #theirItems == 0 then
        -- Попробуем просто все фреймы
        local frames = {}
        for _, child in ipairs(tradeGui:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                table.insert(frames, child)
            end
        end
        if #frames >= 2 then
            myItems    = extractItems(frames[1])
            theirItems = extractItems(frames[2])
        end
    end

    print("[Trader] Мои: "    .. (#myItems    > 0 and table.concat(myItems,    ", ") or "пусто"))
    print("[Trader] Их: "     .. (#theirItems > 0 and table.concat(theirItems, ", ") or "пусто"))

    -- Ищем кнопки
    local acceptBtn, declineBtn
    for _, desc in ipairs(tradeGui:GetDescendants()) do
        if desc:IsA("TextButton") then
            local n = desc.Name:lower()
            local t = desc.Text:lower()
            if n:find("accept") or t:find("accept") or n:find("confirm") or t == "yes" then
                acceptBtn = desc
            elseif n:find("decline") or t:find("decline") or n:find("cancel") or t == "no" then
                declineBtn = desc
            end
        end
    end

    print("[Trader] Accept кнопка: " .. (acceptBtn  and acceptBtn.Name  or "не найдена"))
    print("[Trader] Decline кнопка: " .. (declineBtn and declineBtn.Name or "не найдена"))

    if isProfitable(myItems, theirItems) then
        print("[Trader] ✅ ПРИНИМАЕМ")
        clickButton(acceptBtn)
    else
        print("[Trader] ❌ ОТКЛОНЯЕМ")
        clickButton(declineBtn)
    end

    task.wait(2)
    activeTradeGuis[tradeGui] = nil
end

-- =============================================
-- МОНИТОРИНГ GUI
-- =============================================
print("[Trader] Скрипт загружен. Открой меню и включи автотрейд.")

-- Проверяем существующие GUI
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name:lower():find("trade") then
        task.spawn(handleTradeGui, gui)
    end
end

-- Слушаем новые
PlayerGui.ChildAdded:Connect(function(child)
    if child.Name:lower():find("trade") then
        task.spawn(handleTradeGui, child)
    end
end)

-- =============================================
-- ДЕБАГ: логируем ВСЕ новые GUI для поиска имени трейда
-- =============================================
PlayerGui.ChildAdded:Connect(function(child)
    print("[DEBUG] Новый GUI: " .. child.Name)
end)
