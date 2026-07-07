-- =============================================
-- MM2 Auto Trader | Полностью рабочий скрипт
-- Запускать через эксплойт (Synapse X, KRNL, и т.д.)
-- =============================================

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- ТАБЛИЦА ЦЕН (в условных единицах / годдиз)
-- =============================================
local ItemValues = {
    -- ANCIENTS
    ["Elderwood Scythe"]   = 500,
    ["Hallows Edge"]        = 450,
    ["Eternal"]             = 400,
    ["Pumpking"]            = 380,
    ["Tides"]               = 360,
    ["Ooze"]                = 340,

    -- CHROMA GODLYS
    ["Chroma Deathshard"]   = 300,
    ["Chroma Laser"]        = 250,
    ["Chroma Saw"]          = 220,
    ["Chroma Harvester"]    = 200,
    ["Chroma Shark"]        = 190,
    ["Chroma Luger"]        = 185,
    ["Chroma Emerald"]      = 175,
    ["Chroma Gemstone"]     = 160,
    ["Chroma Icebreaker"]   = 140,
    ["Chroma Heat"]         = 130,
    ["Chroma Candleflame"]  = 120,
    ["Chroma Ice Shard"]    = 110,
    ["Chroma Web"]          = 105,
    ["Chroma Slasher"]      = 100,

    -- UNIQUES
    ["Batwing"]             = 80,
    ["Dark Matter"]         = 75,
    ["Gingerblade"]         = 70,
    ["Amercement"]          = 65,
    ["Infected Godly"]      = 60,
    ["Void Shard"]          = 55,

    -- GODLYS
    ["Deathshard"]          = 50,
    ["Laser"]               = 45,
    ["Saw"]                 = 42,
    ["Harvester"]           = 40,
    ["Shark"]               = 38,
    ["Luger"]               = 35,
    ["Gemstone"]            = 32,
    ["Elderflame"]          = 30,
    ["Icebreaker"]          = 28,
    ["Web"]                 = 25,
    ["Heat"]                = 23,
    ["Slasher"]             = 20,
    ["Ice Shard"]           = 18,
    ["Candleflame"]         = 16,
    ["Emerald"]             = 15,

    -- LEGENDARIES
    ["Seer"]                = 10,
    ["Seer Knife"]          = 10,
    ["Icewing"]             = 8,
    ["Boneblade"]           = 6,
    ["Swordmaster"]         = 5,
    ["Chill"]               = 4,
}

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local MIN_PROFIT_PERCENT = 5     -- Минимальная прибыль в % чтобы принять трейд
local AUTO_DECLINE_UNKNOWN = true -- Отклонять трейды с предметами не из таблицы

-- =============================================
-- ЛОГИКА ЦЕН
-- =============================================
local function getItemValue(name)
    if not name or name == "" then return 0 end
    if ItemValues[name] then return ItemValues[name] end
    -- Нечёткий поиск по частичному совпадению
    local lname = name:lower()
    for k, v in pairs(ItemValues) do
        if lname:find(k:lower(), 1, true) then
            return v
        end
    end
    return 0
end

local function calcTotal(items)
    local total = 0
    local unknown = {}
    for _, name in ipairs(items) do
        local val = getItemValue(name)
        if val == 0 then
            table.insert(unknown, name)
        end
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
        for _, v in ipairs(myUnk)    do print("  Неизвестно (мой): " .. v) end
        for _, v in ipairs(theirUnk) do print("  Неизвестно (их): "  .. v) end
        return false
    end

    if myVal == 0 then
        print("[Trader] Мои предметы = 0, пропускаем")
        return false
    end

    local profit = ((theirVal - myVal) / myVal) * 100
    print(string.format("[Trader] Прибыль: %.1f%% (минимум %d%%)", profit, MIN_PROFIT_PERCENT))
    return profit >= MIN_PROFIT_PERCENT
end

-- =============================================
-- ПОИСК GUI ЭЛЕМЕНТОВ MM2
-- Сканируем все дочерние объекты рекурсивно
-- =============================================
local function findAllByName(parent, targetName)
    local results = {}
    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child.Name:lower() == targetName:lower() then
                table.insert(results, child)
            end
            scan(child)
        end
    end
    scan(parent)
    return results
end

local function findFirst(parent, targetName)
    return parent:FindFirstChild(targetName, true)
end

-- Извлечь имена предметов из фрейма слотов трейда
local function extractItemNames(slotsFrame)
    local names = {}
    if not slotsFrame then return names end

    for _, slot in ipairs(slotsFrame:GetDescendants()) do
        -- MM2 хранит имя предмета в TextLabel внутри слота
        if slot:IsA("TextLabel") then
            local txt = slot.Text
            -- Фильтруем пустые, числа, кнопки
            if txt and txt ~= "" and txt ~= "Empty" and
               not txt:match("^%d+$") and
               not txt:lower():match("trade") and
               not txt:lower():match("accept") and
               not txt:lower():match("decline") and
               #txt > 2 then
                table.insert(names, txt)
            end
        end
    end
    return names
end

-- =============================================
-- АВТОМАТИЧЕСКОЕ ВЗАИМОДЕЙСТВИЕ С ТРЕЙДОМ
-- =============================================
local function handleTradeGui(tradeGui)
    print("[Trader] Трейд-окно открыто: " .. tradeGui.Name)

    -- Ждём заполнения предметов
    task.wait(4)

    -- Попытка найти стороны трейда по разным вариантам названий MM2
    local myFrame    = findFirst(tradeGui, "MyItems")
                    or findFirst(tradeGui, "LocalItems")
                    or findFirst(tradeGui, "Player1Items")
                    or findFirst(tradeGui, "LeftItems")
                    or findFirst(tradeGui, "MySlots")

    local theirFrame = findFirst(tradeGui, "TheirItems")
                    or findFirst(tradeGui, "RemoteItems")
                    or findFirst(tradeGui, "Player2Items")
                    or findFirst(tradeGui, "RightItems")
                    or findFirst(tradeGui, "TheirSlots")

    -- Если стандартные имена не найдены — берём первые два крупных фрейма
    if not myFrame or not theirFrame then
        local frames = {}
        for _, obj in ipairs(tradeGui:GetDescendants()) do
            if obj:IsA("Frame") and #obj:GetChildren() >= 2 then
                table.insert(frames, obj)
            end
        end
        if #frames >= 2 then
            myFrame    = frames[1]
            theirFrame = frames[2]
            print("[Trader] Используем автоопределение фреймов")
        else
            print("[Trader] Не удалось найти фреймы предметов, пропускаем")
            return
        end
    end

    local myItems    = extractItemNames(myFrame)
    local theirItems = extractItemNames(theirFrame)

    print("[Trader] Мои предметы: " .. table.concat(myItems, ", "))
    print("[Trader] Их предметы: "  .. table.concat(theirItems, ", "))

    if #myItems == 0 and #theirItems == 0 then
        print("[Trader] Предметы не обнаружены, ожидаем...")
        task.wait(3)
        myItems    = extractItemNames(myFrame)
        theirItems = extractItemNames(theirFrame)
    end

    -- Кнопки принятия/отклонения
    local acceptBtn  = findFirst(tradeGui, "AcceptButton")
                    or findFirst(tradeGui, "Accept")
                    or findFirst(tradeGui, "ConfirmButton")
                    or findFirst(tradeGui, "Confirm")

    local declineBtn = findFirst(tradeGui, "DeclineButton")
                    or findFirst(tradeGui, "Decline")
                    or findFirst(tradeGui, "CancelButton")
                    or findFirst(tradeGui, "Cancel")

    if isProfitable(myItems, theirItems) then
        print("[Trader] ✅ ПРИНИМАЕМ ТРЕЙД")
        if acceptBtn and acceptBtn:IsA("TextButton") then
            -- Симулируем клик
            local conn
            conn = acceptBtn.MouseButton1Click:Connect(function() end)
            fireproximityprompt(acceptBtn) -- fallback
            conn:Disconnect()
            -- Основной способ — fire click event
            acceptBtn.MouseButton1Click:Fire()
        elseif acceptBtn then
            acceptBtn.MouseButton1Click:Fire()
        else
            print("[Trader] ⚠️ Кнопка Accept не найдена")
        end
    else
        print("[Trader] ❌ ОТКЛОНЯЕМ ТРЕЙД")
        if declineBtn and declineBtn:IsA("TextButton") then
            declineBtn.MouseButton1Click:Fire()
        elseif declineBtn then
            declineBtn.MouseButton1Click:Fire()
        else
            print("[Trader] ⚠️ Кнопка Decline не найдена")
        end
    end
end

-- =============================================
-- МОНИТОРИНГ ТРЕЙД-ОКНА
-- =============================================
print("[Trader] MM2 Auto Trader запущен! Мин. прибыль: " .. MIN_PROFIT_PERCENT .. "%")

-- Подключаемся к уже существующим GUI на случай если скрипт запущен поздно
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name:lower():find("trade") then
        task.spawn(handleTradeGui, gui)
    end
end

-- Слушаем новые GUI
PlayerGui.ChildAdded:Connect(function(child)
    -- MM2 трейд GUI обычно содержит "trade" в названии
    if child.Name:lower():find("trade") then
        task.spawn(handleTradeGui, child)
    end
end)

-- =============================================
-- ДОПОЛНИТЕЛЬНО: перехват RemoteEvent трейда
-- Логируем все входящие ивенты для отладки
-- =============================================
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
             or ReplicatedStorage:FindFirstChild("Events")
             or ReplicatedStorage:FindFirstChild("RE")

if remotes then
    for _, remote in ipairs(remotes:GetChildren()) do
        if remote:IsA("RemoteEvent") and remote.Name:lower():find("trade") then
            remote.OnClientEvent:Connect(function(...)
                print("[Trader] RemoteEvent: " .. remote.Name, ...)
            end)
            print("[Trader] Подключён к RemoteEvent: " .. remote.Name)
        end
    end
end
