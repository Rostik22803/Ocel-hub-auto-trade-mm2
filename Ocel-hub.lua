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
-- ПОЛНАЯ ТАБЛИЦА ЦЕН MM2 (game.guide, July 2026)
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
    ["Chroma Fire Cat"]         = 4,
    ["Chroma Fire Bat"]         = 4,
    ["Chroma Fire Bear"]        = 4,
    ["Chroma Fire Dog"]         = 4,
    ["Chroma Fire Fox"]         = 4,
    ["Chroma Fire Pig"]         = 4,
    ["Chroma Fire Bunny"]       = 4,

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
    ["Eternal III"]             = 10,
    ["Saw"]                     = 8,
    ["Boneblade"]               = 8,
    ["Frostbite"]               = 7,
    ["Ghostblade"]              = 7,
    ["Ice Dragon"]              = 7,
    ["Prismatic"]               = 6,
    ["Winter's Edge"]           = 6,
    ["Flames"]                  = 6,
    ["Hallow's Edge"]           = 9,
    ["Hallow's Blade"]          = 8,
    ["Xmas"]                    = 9,
    ["Eternal"]                 = 9,
    ["Handsaw"]                 = 9,
    ["Ice Shard"]               = 8,
    ["Eternal II"]              = 8,
    ["Pumpking"]                = 8,
    ["Eggblade"]                = 5,
    ["Peppermint"]              = 4,
    ["Cookieblade"]             = 4,
    ["Red Seer"]                = 3,
    ["Purple Seer"]             = 3,
    ["Blue Seer"]               = 3,
    ["Orange Seer"]             = 2,
    ["Yellow Seer"]             = 2,
    ["Seer"]                    = 3,
    ["Pearl"]                   = 98,
    ["Pearlshine"]              = 103,

    -- ===== LEGENDARIES =====
    ["Flowerwood Knife"]        = 255,
    ["Bones Gun"]               = 245,
    ["Latte (Knife)"]           = 200,
    ["Latte (Gun)"]             = 200,
    ["Spectral (Knife)"]        = 90,
    ["Traveler (Gun)"]          = 90,
    ["Swirlyaxe"]               = 43,
    ["Cotton Candy"]            = 40,
    ["JD"]                      = 35,
    ["Beach"]                   = 33,
    ["Vampire (Gun)"]           = 48,
    ["Aurora (Gun)"]            = 44,
    ["Arctic (Gun)"]            = 11,
    ["Aurora (Knife)"]          = 9,
    ["Cavern (Knife)"]          = 9,
    ["Glitch 1"]                = 70,
    ["Glitch 2"]                = 40,
    ["Blue Pumpkin"]            = 185,
    ["Red Pumpkin"]             = 120,
    ["Green Pumpkin"]           = 70,
    ["Icedriller"]              = 6,
    ["Broken"]                  = 7,
    ["Skulls"]                  = 4,
    ["Blue Elite"]              = 4,
    ["Green Elite"]             = 4,
    ["Red Scratch"]             = 4,
    ["Witched"]                 = 4,
    ["Ripper (Knife)"]          = 4,
    ["Ripper (Gun)"]            = 3,
    ["Santa's Spirit"]          = 4,
    ["Santa's Magic"]           = 4,
    ["Ginger (Gun)"]            = 4,
    ["Ginger (Knife)"]          = 2,
    ["Spectral (Gun)"]          = 4,
    ["Splash (Gun)"]            = 3,
    ["Splash (Knife)"]          = 0,
    ["Bunnies"]                 = 3,
    ["Nightsky"]                = 3,
    ["Blue Scratch"]            = 3,
    ["Chromatic (Gun)"]         = 3,
    ["Chromatic (Knife)"]       = 3,
    ["Arctic (Knife)"]          = 3,
    ["Vampire (Knife)"]         = 3,
    ["Traveler (Knife)"]        = 3,
    ["Ghost (Knife)"]           = 5,
    ["Ghost (Gun)"]             = 2,
    ["Icecracker"]              = 2,
    ["Frostfade (Knife)"]       = 2,
    ["Energized (Gun)"]         = 2,
    ["Red Fire"]                = 2,
    ["Cupid"]                   = 1,
    ["Cavern (Gun)"]            = 1,

    -- ===== RARE =====
    ["Dungeon"]                 = 350,
    ["Cane Knife (2018)"]       = 313,
    ["Cane 2018 (Knife)"]       = 250,
    ["Darkknife"]               = 90,
    ["Zombified (Knife)"]       = 85,
    ["Makeshift (Knife)"]       = 50,
    ["Silent Night (Knife)"]    = 50,
    ["Zombified"]               = 48,
    ["Swirl"]                   = 25,
    ["Frosted (Knife)"]         = 25,
    ["Snowflakes (Gun)"]        = 25,
    ["Silent Night (Gun)"]      = 14,
    ["Darkgun"]                 = 2,
    ["Snowflake Knife"]         = 23,
    ["Swirlygun"]               = 23,
    ["Night Blade"]             = 23,
    ["RIP Gun"]                 = 18,
    ["Ice Wing"]                = 18,
    ["Battle Axe II"]           = 18,
    ["Luger Cane"]              = 18,
    ["Eternal Cane"]            = 17,
    ["Death Shard"]             = 15,
    ["Purple Pumpkin"]          = 15,
    ["Swirlyblade"]             = 13,
    ["Magma (Gun)"]             = 13,
    ["Log Chopper"]             = 20,
    ["Floral"]                  = 20,
    ["Pumpkin"]                 = 20,
    ["Brains 2019"]             = 110,
    ["Starry (Gun)"]            = 30,
    ["Starry (Knife)"]          = 2,
    ["Toxic (Knife)"]           = 8,
    ["Toxic (Gun)"]             = 2,
    ["Vampire (Gun) 2018"]      = 7,
    ["Ghastly (Gun)"]           = 6,
    ["Magma"]                   = 6,
    ["Magma (Knife)"]           = 3,
    ["Watcher (Gun)"]           = 10,
    ["Watcher (Knife)"]         = 3,
    ["Heart"]                   = 10,
    ["Nether"]                  = 3,
    ["Purple"]                  = 3,
    ["Galactic"]                = 3,
    ["Jack"]                    = 3,
    ["Damp"]                    = 3,
    ["Snakebite (Knife)"]       = 3,
    ["iRevolver"]               = 3,
    ["Korblox"]                 = 3,
    ["Portal (Knife)"]          = 3,
    ["Biogel"]                  = 3,
    ["Bats"]                    = 3,
    ["Abstract"]                = 3,
    ["Nova"]                    = 3,
    ["Nightfire"]               = 3,
    ["Musical"]                 = 3,
    ["Krypto"]                  = 3,
    ["Hacker"]                  = 3,
    ["Deep Sea"]                = 3,
    ["Green Marble"]            = 3,
    ["Spectrum"]                = 3,
    ["Spitfire"]                = 3,
    ["Space"]                   = 3,
    ["Vortex"]                  = 3,
    ["Squire"]                  = 3,
    ["Ace"]                     = 3,
    ["Imbued"]                  = 3,
    ["Bacon"]                   = 3,
    ["Galaxy"]                  = 3,
    ["Black"]                   = 4,
    ["Candy Swirl (Gun)"]       = 9,
    ["Candy Swirl (Knife)"]     = 1,
    ["Icicles (Gun)"]           = 9,
    ["Icicles (Knife)"]         = 1,
    ["Floral (Knife)"]          = 12,
    ["Molten (Gun)"]            = 2,
    ["Molten (Knife)"]          = 2,
    ["Orange Marble"]           = 2,
    ["Snowflakes"]              = 2,
    ["Mummy Gun"]               = 5,
    ["Sun"]                     = 5,
    ["Monster"]                 = 4,
    ["Nuclear"]                 = 2,
    ["Ice Camo"]                = 2,
    ["Gingerbread"]             = 2,
    ["Snakebite (Gun)"]         = 1,
    ["Cane (Knife)"]            = 2,
    ["Cane (Gun)"]              = 1,
    ["Mummy"]                   = 1,
    ["Wraith (Knife)"]          = 2,
    ["Wraith (Gun)"]            = 2,
    ["Rainbow (Knife)"]         = 0,
    ["Bones (Knife)"]           = 0,
    ["Curse"]                   = 0,
    ["Ghosts (Gun)"]            = 0,
    ["Cane 2018 (Gun)"]         = 0,

    -- ===== UNCOMMON =====
    ["Bones"]                   = 126,
    ["Zombified (Knife) UC"]    = 85,
    ["Sweater (Knife)"]         = 68,
    ["Brains"]                  = 63,
    ["Gingerbread (Knife)"]     = 63,
    ["Branches"]                = 40,
    ["Void"]                    = 12,
    ["Ghost Blade"]             = 8,
    ["Snowflake"]               = 5,
    ["Lights (Gun)"]            = 5,
    ["Potion (Knife)"]          = 5,
    ["Frozen (Gun)"]            = 5,
    ["Zombie (Gun)"]            = 10,
    ["Zombified (Gun)"]         = 15,
    ["Zombie (Knife)"]          = 2,
    ["Zombie"]                  = 2,
    ["Frozen (Knife)"]          = 2,
    ["Lights (Knife)"]          = 2,
    ["Holly (Gun)"]             = 2,
    ["Pumpkin Pie"]             = 2,
    ["Moons"]                   = 2,
    ["Vampire"]                 = 2,
    ["Wrap (Gun)"]              = 2,
    ["Wrap (Knife)"]            = 2,
    ["Steel (Gun)"]             = 2,
    ["Hazard Gun"]              = 4,
    ["Scratch"]                 = 4,
    ["Predator (Knife)"]        = 4,
    ["Snowflake Gun"]           = 4,
    ["Palms Knife"]             = 4,
    ["Mistletoe Knife"]         = 4,
    ["Overseer (Knife)"]        = 4,
    ["Overseer (Gun)"]          = 4,
    ["Gingercookie Gun"]        = 4,
    ["Gingerbread (Gun)"]       = 4,
    ["Emerald"]                 = 4,
    ["Predator (Gun)"]          = 4,
    ["Spearmint Knife"]         = 4,
    ["Frosty"]                  = 4,
    ["Cheesy"]                  = 3,
    ["Wooden"]                  = 3,
    ["Teddy"]                   = 3,
    ["Green Fire"]              = 3,
    ["Meadow"]                  = 3,
    ["Universe"]                = 3,
    ["Elite"]                   = 3,
    ["Red"]                     = 3,
    ["Fade"]                    = 3,
    ["Neon Gun"]                = 3,
    ["Melon"]                   = 3,
    ["Brush"]                   = 3,
    ["Bluesteel (Knife)"]       = 3,
    ["Hive"]                    = 3,
    ["Lil Alien"]               = 3,
    ["Steel Knife"]             = 3,
    ["Cats"]                    = 3,
    ["Treats Gun"]              = 3,
    ["Pink"]                    = 3,
    ["Potion"]                  = 3,
    ["Cookie Gun"]              = 3,
    ["Marble"]                  = 3,
    ["Bluesteel (Gun)"]         = 3,
    ["Jigsaw"]                  = 3,
    ["Painted Gun"]             = 3,
    ["Hazmat"]                  = 3,
    ["Soda"]                    = 3,
    ["Caution"]                 = 3,
    ["Paper"]                   = 3,
    ["Cheddar"]                 = 3,
    ["Marina"]                  = 3,
    ["Snowbear"]                = 3,
    ["Sparkle"]                 = 3,
    ["Graffiti"]                = 3,
    ["Stalker"]                 = 3,
    ["Gothic (Gun)"]            = 3,
    ["Adurite (Gun)"]           = 3,
    ["Adurite (Knife)"]         = 3,
    ["Wanwood"]                 = 3,
    ["Plasmite"]                = 3,
    ["Camo"]                    = 3,
    ["High Tech"]               = 3,
    ["Logcutter"]               = 3,
    ["Popsicle"]                = 3,
    ["Eyeball Knife"]           = 3,
    ["Eclipse"]                 = 3,
    ["Lucky"]                   = 3,
    ["Circuit"]                 = 3,
    ["Midnight"]                = 3,
    ["Cookie Knife"]            = 3,
    ["Wolf"]                    = 3,
    ["Viper"]                   = 3,
    ["Splash"]                  = 3,
    ["Wavy Gun"]                = 3,
    ["Wavy Knife"]              = 3,
    ["Shiny"]                   = 3,
    ["Frostfade Gun"]           = 3,
    ["Fusion"]                  = 3,
    ["Glowy"]                   = 3,
    ["Canes Knife"]             = 3,
    ["Igloo Gun"]               = 3,
    ["Biogun"]                  = 3,
    ["Webs"]                    = 3,
    ["Candycorn Gun"]           = 3,
    ["Pirate"]                  = 3,
    ["Tropical Knife"]          = 3,
    ["Butterflies"]             = 3,
    ["UFOs Knife"]              = 3,
    ["Xeno Gun"]                = 3,
    ["Eyes"]                    = 3,
    ["Blue"]                    = 3,
    ["Frostflame Knife"]        = 3,
    ["Wreaths 2024"]            = 3,
    ["Wrapped Knife 24"]        = 3,
    ["Tree Knife 2022"]         = 3,
    ["Tree Gun 2022"]           = 3,
    ["Stockings Gun 2022"]      = 3,
    ["Hologram Knife"]          = 3,
    ["Watcher Gun 2020"]        = 3,
    ["Candy Corn Knife 2020"]   = 3,
    ["Hot Chocolate"]           = 3,
    ["Gingerbread Gun 2022"]    = 3,
    ["Snowflake Gun 2022"]      = 3,
    ["Wraiths Knife"]           = 3,
    ["Tiger"]                   = 3,
    ["Rune"]                    = 3,
    ["Potion (2017)"]           = 3,
    ["Mummy (2017)"]            = 3,
    ["Soda (UC)"]               = 3,
    ["Tree Knife 23"]           = 3,
    ["Paws"]                    = 1,
    ["Mummy 2018 (Gun)"]        = 5,
    ["Mummy 2018 (Knife)"]      = 2,
    ["Ghastly Knife"]           = 3,

    -- ===== VINTAGE =====
    ["Ghost (Vintage)"]         = 10,
    ["Blood"]                   = 8,
    ["America"]                 = 8,
    ["Shadow (Vintage)"]        = 7,
    ["Prince"]                  = 6,
    ["Phaser"]                  = 6,
    ["Golden"]                  = 5,
    ["Cowboy"]                  = 4,
    ["Splitter"]                = 3,

    -- ===== COMMON (ценные) =====
    ["Bats (Knife)"]            = 160,
    ["Ghoulish"]                = 140,
    ["Glitch1"]                 = 75,
    ["Default Knife"]           = 75,
    ["Default Gun"]             = 75,
    ["Glitch2"]                 = 50,
    ["Pumpkin (2019)"]          = 26,
    ["CandyCorn 2017"]          = 20,
    ["Coal (Knife)"]            = 20,
    ["Swirl Knife"]             = 35,
    ["Sparkle9"]                = 30,
    ["Sparkle8"]                = 21,
    ["Sparkle10"]               = 21,
    ["Sparkle7"]                = 18,
    ["Sparkle6"]                = 13,
    ["Sparkle5"]                = 9,
    ["Sparkle4"]                = 11,
    ["Sparkle3"]                = 3,
    ["Sparkle2"]                = 3,
    ["Sparkle1"]                = 3,
    ["Gifts (Knife)"]           = 88,
    ["Pine (Knife)"]            = 80,
    ["Frosted (Knife) C"]       = 25,
    ["RIP"]                     = 15,
    ["Prism"]                   = 14,
    ["Ecto"]                    = 11,
    ["Combat II"]               = 11,
    ["Tailslide"]               = 9,
    ["Ollie"]                   = 8,
    ["Sidewinder"]              = 8,
    ["Skool"]                   = 8,
    ["Doge"]                    = 3,
    ["Turtle Knife"]            = 3,
    ["Popsicle Gun"]            = 3,
    ["Hologram Gun"]            = 3,
    ["Toy (Gun)"]               = 3,
    ["Toy (Knife)"]             = 2,
    ["Starry"]                  = 4,
    ["Ornaments (Knife)"]       = 3,
    ["Ornaments (Gun)"]         = 1,
    ["Stickers (Knife)"]        = 3,
    ["Stickers (Gun)"]          = 2,
    ["Gifts (Gun)"]             = 3,
    ["Carved (Knife)"]          = 3,
    ["Carved (Gun)"]            = 3,
    ["Darkness (Gun)"]          = 3,
    ["Darkness (Knife)"]        = 1,
    ["Pumpkin Patch"]           = 10,
    ["Ghosty"]                  = 3,
    ["Ribbons"]                 = 3,
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

-- =============================================
-- ПАНЕЛЬ ОТЛАДКИ — отдельный ScreenGui поверх ВСЕГО
-- DisplayOrder 999 гарантирует рендер поверх MM2 GUI
-- =============================================
local debugScreenGui = Instance.new("ScreenGui")
debugScreenGui.Name = "MM2TraderDebug"
debugScreenGui.ResetOnSpawn = false
debugScreenGui.DisplayOrder = 999
debugScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
debugScreenGui.IgnoreGuiInset = true
debugScreenGui.Parent = PlayerGui

local debugFrame = Instance.new("Frame")
debugFrame.Name = "DebugFrame"
debugFrame.Size = UDim2.new(0, 420, 0, 280)
-- Правый верхний угол — не мешает трейд-окну MM2 (обычно по центру)
debugFrame.Position = UDim2.new(1, -435, 0, 10)
debugFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
debugFrame.BorderSizePixel = 0
debugFrame.Active = true
debugFrame.Draggable = true
debugFrame.Visible = false
debugFrame.ZIndex = 999
debugFrame.Parent = debugScreenGui

local dbCorner = Instance.new("UICorner")
dbCorner.CornerRadius = UDim.new(0, 10)
dbCorner.Parent = debugFrame

local dbStroke = Instance.new("UIStroke")
dbStroke.Color = Color3.fromRGB(100, 100, 180)
dbStroke.Thickness = 2
dbStroke.Parent = debugFrame

-- Заголовок панели (тянуть за него)
local dbTitle = Instance.new("Frame")
dbTitle.Size = UDim2.new(1, 0, 0, 32)
dbTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
dbTitle.BorderSizePixel = 0
dbTitle.ZIndex = 999
dbTitle.Parent = debugFrame
local dbtc = Instance.new("UICorner") dbtc.CornerRadius = UDim.new(0,10) dbtc.Parent = dbTitle
local dbtfix = Instance.new("Frame")
dbtfix.Size = UDim2.new(1,0,0.5,0)
dbtfix.Position = UDim2.new(0,0,0.5,0)
dbtfix.BackgroundColor3 = Color3.fromRGB(35,35,70)
dbtfix.BorderSizePixel = 0
dbtfix.ZIndex = 999
dbtfix.Parent = dbTitle

local dbTitleLabel = Instance.new("TextLabel")
dbTitleLabel.Text = "📊 Анализ трейда  (тяни чтобы переместить)"
dbTitleLabel.Size = UDim2.new(1, -10, 1, 0)
dbTitleLabel.Position = UDim2.new(0, 10, 0, 0)
dbTitleLabel.BackgroundTransparency = 1
dbTitleLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
dbTitleLabel.TextSize = 13
dbTitleLabel.Font = Enum.Font.GothamBold
dbTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
dbTitleLabel.ZIndex = 999
dbTitleLabel.Parent = dbTitle

-- Левая колонка — МОИ предметы
local myCol = Instance.new("Frame")
myCol.Size = UDim2.new(0.5, -8, 1, -60)
myCol.Position = UDim2.new(0, 6, 0, 36)
myCol.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
myCol.BorderSizePixel = 0
myCol.ZIndex = 999
myCol.Parent = debugFrame
local mycc = Instance.new("UICorner") mycc.CornerRadius = UDim.new(0,7) mycc.Parent = myCol

local myColTitle = Instance.new("TextLabel")
myColTitle.Text = "👤 Ты отдаёшь"
myColTitle.Size = UDim2.new(1, 0, 0, 22)
myColTitle.Position = UDim2.new(0, 0, 0, 2)
myColTitle.BackgroundTransparency = 1
myColTitle.TextColor3 = Color3.fromRGB(100, 230, 100)
myColTitle.TextSize = 12
myColTitle.Font = Enum.Font.GothamBold
myColTitle.TextXAlignment = Enum.TextXAlignment.Center
myColTitle.ZIndex = 999
myColTitle.Parent = myCol

local myItemsLabel = Instance.new("TextLabel")
myItemsLabel.Text = "ожидание трейда..."
myItemsLabel.Size = UDim2.new(1, -8, 1, -52)
myItemsLabel.Position = UDim2.new(0, 4, 0, 26)
myItemsLabel.BackgroundTransparency = 1
myItemsLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
myItemsLabel.TextSize = 11
myItemsLabel.Font = Enum.Font.Gotham
myItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
myItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
myItemsLabel.TextWrapped = true
myItemsLabel.ZIndex = 999
myItemsLabel.Parent = myCol

local myTotalLabel = Instance.new("TextLabel")
myTotalLabel.Text = "Итого: —"
myTotalLabel.Size = UDim2.new(1, 0, 0, 24)
myTotalLabel.Position = UDim2.new(0, 0, 1, -26)
myTotalLabel.BackgroundTransparency = 1
myTotalLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
myTotalLabel.TextSize = 14
myTotalLabel.Font = Enum.Font.GothamBold
myTotalLabel.TextXAlignment = Enum.TextXAlignment.Center
myTotalLabel.ZIndex = 999
myTotalLabel.Parent = myCol

-- Правая колонка — ИХ предметы
local theirCol = Instance.new("Frame")
theirCol.Size = UDim2.new(0.5, -8, 1, -60)
theirCol.Position = UDim2.new(0.5, 2, 0, 36)
theirCol.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
theirCol.BorderSizePixel = 0
theirCol.ZIndex = 999
theirCol.Parent = debugFrame
local thcc = Instance.new("UICorner") thcc.CornerRadius = UDim.new(0,7) thcc.Parent = theirCol

local theirColTitle = Instance.new("TextLabel")
theirColTitle.Text = "🎯 Ты получаешь"
theirColTitle.Size = UDim2.new(1, 0, 0, 22)
theirColTitle.Position = UDim2.new(0, 0, 0, 2)
theirColTitle.BackgroundTransparency = 1
theirColTitle.TextColor3 = Color3.fromRGB(230, 100, 100)
theirColTitle.TextSize = 12
theirColTitle.Font = Enum.Font.GothamBold
theirColTitle.TextXAlignment = Enum.TextXAlignment.Center
theirColTitle.ZIndex = 999
theirColTitle.Parent = theirCol

local theirItemsLabel = Instance.new("TextLabel")
theirItemsLabel.Text = "ожидание трейда..."
theirItemsLabel.Size = UDim2.new(1, -8, 1, -52)
theirItemsLabel.Position = UDim2.new(0, 4, 0, 26)
theirItemsLabel.BackgroundTransparency = 1
theirItemsLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
theirItemsLabel.TextSize = 11
theirItemsLabel.Font = Enum.Font.Gotham
theirItemsLabel.TextXAlignment = Enum.TextXAlignment.Left
theirItemsLabel.TextYAlignment = Enum.TextYAlignment.Top
theirItemsLabel.TextWrapped = true
theirItemsLabel.ZIndex = 999
theirItemsLabel.Parent = theirCol

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Text = "Итого: —"
theirTotalLabel.Size = UDim2.new(1, 0, 0, 24)
theirTotalLabel.Position = UDim2.new(0, 0, 1, -26)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
theirTotalLabel.TextSize = 14
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextXAlignment = Enum.TextXAlignment.Center
theirTotalLabel.ZIndex = 999
theirTotalLabel.Parent = theirCol

-- Итоговая строка — вердикт + разница
local resultLabel = Instance.new("TextLabel")
resultLabel.Text = "Открой трейд чтобы увидеть анализ"
resultLabel.Size = UDim2.new(1, -12, 0, 24)
resultLabel.Position = UDim2.new(0, 6, 1, -28)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
resultLabel.TextSize = 13
resultLabel.Font = Enum.Font.GothamBold
resultLabel.TextXAlignment = Enum.TextXAlignment.Center
resultLabel.ZIndex = 999
resultLabel.Parent = debugFrame

-- Функция обновления панели отладки
local function updateDebugPanel(myItems, theirItems)
    debugFrame.Visible = true

    -- Формат: "Имя (цена)\n..."
    local function buildList(items)
        if #items == 0 then return "пусто" end
        local lines = {}
        for _, name in ipairs(items) do
            local v = getItemValue(name)
            if v > 0 then
                table.insert(lines, name .. " (" .. v .. ")")
            else
                table.insert(lines, name .. " (?)")
            end
        end
        return table.concat(lines, "\n")
    end

    local myVal,    myUnk    = calcTotal(myItems)
    local theirVal, theirUnk = calcTotal(theirItems)

    myItemsLabel.Text    = buildList(myItems)
    theirItemsLabel.Text = buildList(theirItems)
    myTotalLabel.Text    = "Итого: " .. myVal
    theirTotalLabel.Text = "Итого: " .. theirVal

    -- Прибыль/убыток
    if myVal > 0 then
        local diff    = theirVal - myVal
        local pct     = (diff / myVal) * 100
        local sign    = diff >= 0 and "+" or ""
        local verdict = ""
        if pct >= MIN_PROFIT_PERCENT then
            verdict = "✅ ПРИНЯТЬ"
            resultLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
        else
            verdict = "❌ ОТКЛОНИТЬ"
            resultLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        end
        resultLabel.Text = string.format(
            "%s  |  %s%d  (%s%.1f%%)",
            verdict, sign, diff, sign, pct
        )
    else
        resultLabel.Text = "⚠ Нет данных о ценах"
        resultLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end

    -- Подсветка колонок: зелёная у того кто выигрывает
    if theirVal >= myVal then
        myCol.BackgroundColor3    = Color3.fromRGB(20, 40, 20)
        theirCol.BackgroundColor3 = Color3.fromRGB(20, 55, 20)
    else
        myCol.BackgroundColor3    = Color3.fromRGB(55, 20, 20)
        theirCol.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    end
end

local function hideDebugPanel()
    debugFrame.Visible = false
end

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

-- Растягиваем главное меню чтобы влезла кнопка отладки
mainFrame.Size = UDim2.new(0, 280, 0, 232)

-- Кнопка показа/скрытия панели отладки
local debugToggleBtn = Instance.new("TextButton")
debugToggleBtn.Text = "🔍 Показать отладку"
debugToggleBtn.Size = UDim2.new(1, -20, 0, 28)
debugToggleBtn.Position = UDim2.new(0, 10, 0, 194)
debugToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 130)
debugToggleBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
debugToggleBtn.TextSize = 12
debugToggleBtn.Font = Enum.Font.GothamBold
debugToggleBtn.BorderSizePixel = 0
debugToggleBtn.Parent = mainFrame
local dbc = Instance.new("UICorner") dbc.CornerRadius = UDim.new(0,7) dbc.Parent = debugToggleBtn

debugToggleBtn.MouseButton1Click:Connect(function()
    debugFrame.Visible = not debugFrame.Visible
    debugToggleBtn.Text = debugFrame.Visible and "🔍 Скрыть отладку" or "🔍 Показать отладку"
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
        print("[Trader] Автотрейд выключен — только отладка")
        -- Автоклик не делаем, но отладку показываем дальше
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

    -- Обновляем панель отладки
    updateDebugPanel(myItems, theirItems)

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

    -- Кликаем только если автотрейд включён
    if traderEnabled then
        if isProfitable(myItems, theirItems) then
            print("[Trader] ✅ ПРИНИМАЕМ")
            clickButton(acceptBtn)
        else
            print("[Trader] ❌ ОТКЛОНЯЕМ")
            clickButton(declineBtn)
        end
    else
        print("[Trader] Автотрейд выключен — решение только в отладке, без клика")
    end

    task.wait(2)
    activeTradeGuis[tradeGui] = nil
    -- Не скрываем панель автоматически — игрок видит результат сам
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
