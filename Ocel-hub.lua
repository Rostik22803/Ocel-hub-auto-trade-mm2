-- =============================================
-- MM2 Auto Trader v2.7 (ANTI-BUG & VALUES FIX)
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
local AUTO_DECLINE_UNKNOWN = true   -- отклонять трейды, если есть неизвестные пушки
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
    ["Chroma Swirlygun"]        = 42,
    ["Chroma Elderwood Blade"]  = 42,
    ["Chroma Candleflame"]      = 42,
    ["Chroma Deathshard"]       = 35,
    ["Chroma Heat"]             = 33,
    ["Chroma Fang"]             = 33,
    ["Chroma Gemstone"]         = 33,
    ["Chroma Shark"]            = 33,
    ["Chroma Gingerblade"]      = 32,
    ["Chroma Seer"]             = 32,
    ["Chroma Tides"]            = 30,
    ["Chroma Saw"]              = 29,
    ["Chroma Boneblade"]        = 25,
    ["Chroma Slasher"]          = 39,
    ["Chroma Laser"]            = 44,
    ["Chroma Cookiecane"]       = 38,

    -- ===== GODLYS =====
    ["Traveler's Gun"]          = 4900,
    ["Evergun"]                 = 3500,
    ["Constellation"]           = 2700,
    ["Evergreen"]               = 2500,
    ["Turkey"]                  = 2500,
    ["Alienbeam"]               = 2000,
    ["Vampire's Gun"]           = 1700,
    ["Darkshot"]                = 1600,
    ["Darksword"]               = 1500,
    ["Raygun"]                  = 1300,
    ["Sakura"]                  = 1300,
    ["Sunrise"]                 = 1000,
    ["Bauble"]                  = 900,
    ["Snowcannon"]              = 813,
    ["Blossom"]                 = 633,
    ["Soul"]                    = 523,
    ["Spirit"]                  = 513,
    ["Corrupt"]                 = 475,
    ["Flora"]                   = 410,
    ["Bloom"]                   = 400,
    ["Heart Wand"]              = 333,
    ["Ocean"]                   = 280,
    ["Waves"]                   = 275,
    ["Xenoshot"]                = 270,
    ["Xenoknife"]               = 270,
    ["Sunset"]                  = 263,
    ["Flowerwood Gun"]          = 260,
    ["Snow Dagger"]             = 260,
    ["Flowerwood"]              = 255,
    ["Snowstorm"]               = 250,
    ["Blizzard"]                = 250,
    ["Watergun"]                = 248,
    ["Rainbow Gun"]             = 212,
    ["Rainbow"]                 = 207,
    ["Treat"]                   = 163,
    ["Sweet"]                   = 158,
    ["Borealis"]                = 155,
    ["Australis"]               = 150,
    ["Candy"]                   = 83,
    ["Heartblade"]              = 69,
    ["Bat"]                     = 61,
    ["Luger"]                   = 46,
    ["Red Luger"]               = 44,
    ["Elderwood Revolver"]      = 39,
    ["Candleflame"]             = 39,
    ["Iceblaster"]              = 39,
    ["Makeshift"]               = 39,
    ["Spectre"]                 = 39,
    ["Elderwood Blade"]         = 39,
    ["Darkbringer"]             = 39,
    ["Lightbringer"]            = 37,
    ["Sugar"]                   = 39,
    ["Shark"]                   = 22,
    ["Icebeam"]                 = 22,
    ["Laser"]                   = 24,
    ["Amerilaser"]              = 24,
    ["Slasher"]                 = 19,
    ["Old Glory"]               = 19,
    ["Blaster"]                 = 19,
    ["Pixel"]                   = 19,
    ["Ginger Luger"]            = 19,
    ["Plasmabeam"]              = 19,
    ["Iceflake"]                = 19,
    ["Plasmablade"]             = 18,
    ["Jinglegun"]               = 17,
    ["Battleaxe II"]            = 17,
    ["Virtual"]                 = 17,
    ["Cookiecane"]              = 16,
    ["Gingermint"]              = 16,
    ["Minty"]                   = 16,
    ["Lugercane"]               = 15,
    ["Nebula"]                  = 15,
    ["Vampire's Edge"]          = 15,
    ["Eternalcane"]             = 15,
    ["Swirly Blade"]            = 15,
    ["Gemstone"]                = 15,
    ["Gingerblade"]             = 15,
    ["Ornament"]                = 15,
    ["Deathshard"]              = 13,
    ["Battleaxe"]               = 13,
    ["Swirly Gun"]              = 20,
    ["Nightblade"]              = 20,
    ["Hallowgun"]               = 24,
    ["Phantom"]                 = 25,
    ["Green Luger"]             = 27,
    ["Tides"]                   = 11,
    ["Spider"]                  = 11,
    ["Chill"]                   = 11,
    ["Clockwork"]               = 11,
    ["Heat"]                    = 11,
    ["Fang"]                    = 11,
    ["Eternal IV"]              = 10,
    ["Bioblade"]                = 10,
    ["Frostsaber"]              = 10,
    ["Darksword"]               = 1500,
    ["Pearl"]                   = 98,
    ["Pearlshine"]              = 103,
}

-- =============================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2TraderUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 232)
mainFrame.Position = UDim2.new(0, 20, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = mainFrame
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(180, 0, 255) stroke.Thickness = 2 stroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "MM2 Auto Trader v2.7"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

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
local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 8) btnCorner.Parent = toggleBtn

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

local minusBtn = Instance.new("TextButton")
minusBtn.Text = "  −"
minusBtn.Size = UDim2.new(0, 40, 0, 28)
minusBtn.Position = UDim2.new(0, 10, 0, 158)
minusBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.TextSize = 16
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
plusBtn.BorderSizePixel = 0
plusBtn.Parent = mainFrame
local pc = Instance.new("UICorner") pc.CornerRadius = UDim.new(0,6) pc.Parent = plusBtn

-- =============================================
-- ПАНЕЛЬ ОТЛАДКИ
-- =============================================
local debugScreenGui = Instance.new("ScreenGui")
debugScreenGui.Name = "MM2TraderDebug"
debugScreenGui.ResetOnSpawn = false
debugScreenGui.DisplayOrder = 999
debugScreenGui.Parent = PlayerGui

local debugFrame = Instance.new("Frame")
debugFrame.Name = "DebugFrame"
debugFrame.Size = UDim2.new(0, 420, 0, 300)
debugFrame.Position = UDim2.new(1, -435, 0, 10)
debugFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
debugFrame.BorderSizePixel = 0
debugFrame.Active = true
debugFrame.Draggable = true
debugFrame.Visible = false
debugFrame.Parent = debugScreenGui
local dbCorner = Instance.new("UICorner") dbCorner.CornerRadius = UDim.new(0, 10) dbCorner.Parent = debugFrame
local dbStroke = Instance.new("UIStroke") dbStroke.Color = Color3.fromRGB(100, 100, 180) dbStroke.Thickness = 2 dbStroke.Parent = debugFrame

local dbTitleLabel = Instance.new("TextLabel")
dbTitleLabel.Text = "📊 Анализ трейда MM2"
dbTitleLabel.Size = UDim2.new(1, 0, 0, 32)
dbTitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
dbTitleLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
dbTitleLabel.TextSize = 13
dbTitleLabel.Font = Enum.Font.GothamBold
dbTitleLabel.Parent = debugFrame

local myCol = Instance.new("Frame")
myCol.Size = UDim2.new(0.5, -8, 1, -90)
myCol.Position = UDim2.new(0, 6, 0, 64)
myCol.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
myCol.Parent = debugFrame

local myItemsLabel = Instance.new("TextLabel")
myItemsLabel.Text = "ожидание трейда..."
myItemsLabel.Size = UDim2.new(1, -8, 1, -40)
myItemsLabel.Position = UDim2.new(0, 4, 0, 10)
myItemsLabel.BackgroundTransparency = 1
myItemsLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
myItemsLabel.TextSize = 11
myItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
myItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
myItemsLabel.Parent = myCol

local myTotalLabel = Instance.new("TextLabel")
myTotalLabel.Text = "Итого: —"
myTotalLabel.Size = UDim2.new(1, 0, 0, 24)
myTotalLabel.Position = UDim2.new(0, 0, 1, -24)
myTotalLabel.BackgroundTransparency = 1
myTotalLabel.Font = Enum.Font.GothamBold
myTotalLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
myTotalLabel.Parent = myCol

local theirCol = Instance.new("Frame")
theirCol.Size = UDim2.new(0.5, -8, 1, -90)
theirCol.Position = UDim2.new(0.5, 2, 0, 64)
theirCol.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
theirCol.Parent = debugFrame

local theirItemsLabel = Instance.new("TextLabel")
theirItemsLabel.Text = "ожидание трейда..."
theirItemsLabel.Size = UDim2.new(1, -8, 1, -40)
theirItemsLabel.Position = UDim2.new(0, 4, 0, 10)
theirItemsLabel.BackgroundTransparency = 1
theirItemsLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
theirItemsLabel.TextSize = 11
theirItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
theirItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
theirItemsLabel.Parent = theirCol

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Text = "Итого: —"
theirTotalLabel.Size = UDim2.new(1, 0, 0, 24)
theirTotalLabel.Position = UDim2.new(0, 0, 1, -24)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
theirTotalLabel.Parent = theirCol

local resultLabel = Instance.new("TextLabel")
resultLabel.Text = "Открой трейд чтобы увидеть анализ"
resultLabel.Size = UDim2.new(1, -12, 0, 24)
resultLabel.Position = UDim2.new(0, 6, 1, -28)
resultLabel.BackgroundTransparency = 1
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
resultLabel.Parent = debugFrame

local debugToggleBtn = Instance.new("TextButton")
debugToggleBtn.Text = "🔍 Показать отладку"
debugToggleBtn.Size = UDim2.new(1, -20, 0, 28)
debugToggleBtn.Position = UDim2.new(0, 10, 0, 194)
debugToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 130)
debugToggleBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
debugToggleBtn.Font = Enum.Font.GothamBold
debugToggleBtn.BorderSizePixel = 0
debugToggleBtn.Parent = mainFrame
local dbc = Instance.new("UICorner") dbc.CornerRadius = UDim.new(0,7) dbc.Parent = debugToggleBtn

-- =============================================
-- ЗАЩИЩЕННАЯ СИСТЕМА ПРОВЕРКИ ИМЕН И ЦЕН
-- =============================================
local function getItemRealName(text)
    if not text or type(text) ~= "string" or text == "" then return nil end
    local clean = text:match("^%s*(.-)%s*$") -- Чистим пробелы
    
    if clean == "" or tonumber(clean) then return nil end -- Отсекаем чистые цифры и пустоту
    if clean:lower() == "accept" or clean:lower() == "decline" then return nil end

    -- Проверка на точное совпадение
    if ItemValues[clean] then return clean end
    
    -- Проверка регистра
    for k, v in pairs(ItemValues) do
        if k:lower() == clean:lower() then return k end
    end
    return nil
end

local function getItemValue(name)
    if not name then return 0 end
    return ItemValues[name] or 0
end

local function calcTotal(items)
    local total = 0
    local unknownCount = 0
    local list = {}
    
    for _, name in ipairs(items) do
        local val = getItemValue(name)
        if val > 0 then
            total = total + val
            table.insert(list, name .. " (" .. val .. ")")
        else
            unknownCount = unknownCount + 1
            table.insert(list, "❓ " .. name .. " (Нет в базе)")
        end
    end
    return total, unknownCount, list
end

local function smartGetItems(tradeGui)
    local myItems, theirItems = {}, {}
    local screenW = workspace.CurrentCamera.ViewportSize.X

    for _, obj in ipairs(tradeGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("StringValue") then
            local text = obj:IsA("TextLabel") and obj.Text or obj.Value
            local realName = getItemRealName(text)
            
            if realName then
                -- Фикс фантомного подбора Nik's Scythe из пустых строк
                if realName == "Nik's Scythe" and not text:lower():find("nik") then
                    continue
                end

                local amount = 1
                local parent = obj.Parent
                if parent then
                    for _, child in ipairs(parent:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text:match("^x%d+$") then
                            amount = tonumber(child.Text:match("%d+")) or 1
                        end
                    end
                end

                local posX = 0
                if obj:IsA("TextLabel") then posX = obj.AbsolutePosition.X else 
                    if parent and parent:IsA("GuiObject") then posX = parent.AbsolutePosition.X end
                end
                
                local pName = parent and parent.Name:lower() or ""
                local isMine = pName:find("my") or pName:find("local") or pName:find("left") or (posX > 0 and posX < screenW / 2)

                for i = 1, amount do
                    if isMine then table.insert(myItems, realName) else table.insert(theirItems, realName) end
                end
            end
        end
    end
    return myItems, theirItems
end

local function clickButton(btn)
    if not btn then return end
    local oldZIndex = btn.ZIndex
    btn.ZIndex = 9999
    btn.MouseButton1Click:Fire()
    
    local ok, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    if ok and VIM then
        local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end
    btn.ZIndex = oldZIndex
end

-- =============================================
-- ОБРАБОТЧИК С КОРРЕКТНЫМ РАСЧЕТОМ
-- =============================================
local function handleTradeGui(tradeGui)
    local myItems, theirItems = smartGetItems(tradeGui)
    local myVal, myUnkCount, myTextList = calcTotal(myItems)
    local theirVal, theirUnkCount, theirTextList = calcTotal(theirItems)
    
    myItemsLabel.Text = #myTextList > 0 and table.concat(myTextList, "\n") or "пусто"
    theirItemsLabel.Text = #theirTextList > 0 and table.concat(theirTextList, "\n") or "пусто"
    myTotalLabel.Text = "Итого: " .. myVal
    theirTotalLabel.Text = "Итого: " .. theirVal

    local acceptBtn, declineBtn
    for _, desc in ipairs(tradeGui:GetDescendants()) do
        if desc:IsA("TextButton") then
            local n = desc.Name:lower()
            local t = desc.Text:lower()
            if n:find("accept") or t:find("accept") or n:find("confirm") or t == "yes" or desc.BackgroundColor3 == Color3.fromRGB(0, 200, 0) then
                acceptBtn = desc
            elseif n:find("decline") or t:find("decline") or n:find("cancel") or t == "no" or desc.BackgroundColor3 == Color3.fromRGB(200, 0, 0) then
                declineBtn = desc
            end
        end
    end

    if myVal == 0 and theirVal == 0 then
        resultLabel.Text = "Ждем добавления оружия..."
        resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end

    local isProfitable = false
    if myVal > 0 then
        local diff = theirVal - myVal
        local pct = math.floor((diff / myVal) * 100)
        isProfitable = pct >= MIN_PROFIT_PERCENT
        
        if isProfitable then
            resultLabel.Text = string.format("✅ ПРИНЯТЬ (+%d%%)", pct)
            resultLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
        else
            resultLabel.Text = string.format("❌ ОТКЛОНИТЬ (%d%%)", pct)
            resultLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        end
    else
        isProfitable = theirVal > 0
        resultLabel.Text = "✅ ПРИНЯТЬ (Бесплатный подарок)"
        resultLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
    end

    if traderEnabled then
        -- Если включен авто-отклон при неизвестных предметах
        if AUTO_DECLINE_UNKNOWN and (myUnkCount > 0 or theirUnkCount > 0) then
            resultLabel.Text = "❌ ОТКЛОНЕНО: Есть неизвестные вещи"
            resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            clickButton(declineBtn)
            return
        end
        
        if isProfitable then clickButton(acceptBtn) else clickButton(declineBtn) end
    end
end

-- =============================================
-- СЛУШАТЕЛИ GUI
-- =============================================
local function isTradeGui(gui)
    local name = gui.Name:lower()
    if name:find("trade") or name:find("trading") then return true end
    if gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("Accept") then return true end
    return false
end

PlayerGui.ChildAdded:Connect(function(child)
    if isTradeGui(child) then task.wait(0.5) handleTradeGui(child) end
end)

task.spawn(function()
    while true do
        task.wait(1)
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if isTradeGui(gui) then handleTradeGui(gui) end
        end
    end
end)

-- Логика кнопок
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
    debugToggleBtn.Text = debugFrame.Visible and "🔍 Скрыть отладку" or "🔍 Показать отладку"
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

print("[Trader] Исправленный скрипт успешно загружен!")
