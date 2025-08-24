-- Load Fluent Lib
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Window
local Window = Fluent:CreateWindow({
    Title = "Fishing Hub",
    SubTitle = "by You",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Fish = Window:AddTab({ Title = "Fish", Icon = "" }),
    Wtp = Window:AddTab({ Title = "World TP", Icon = "" }),
    Weather = Window:AddTab({ Title = "Weather Machine", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
local AutoFishSection = Tabs.Fish:AddSection("Auto Fish")
local AutoSellSection = Tabs.Fish:AddSection("Auto Sell")


local Options = Fluent.Options

-- ======================================
-- Fishing Script
-- ======================================
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

-- Config
local Config = {
    ReelIdleTime = 3,
    AutoSellDelay = 10,
    Direction = -0.75,
    Power = 0.9923193947
}

local AutoFishing = false -- toggle state

-- Helper stop semua animasi
local function stopAll()
    for _, t in pairs(animator:GetPlayingAnimationTracks()) do
        t:Stop()
    end
end

-- Helper play animasi
local function playAnimation(animId)
    stopAll()
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    local track = animator:LoadAnimation(animation)
    track:Play()
    return track
end

-- Fishing Function (sekali eksekusi)
local function doFishingOnce()
    -- STEP 1: ChargeFishingRod
    local args1 = {tick()}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RF/ChargeFishingRod")
        :InvokeServer(unpack(args1))

    -- Reel Idle
    local reelTrack = playAnimation("rbxassetid://134965425664034")

    -- STEP 2: RequestFishingMinigameStarted
    local args2 = {Config.Direction, Config.Power}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RF/RequestFishingMinigameStarted")
        :InvokeServer(unpack(args2))

    task.wait(Config.ReelIdleTime)

    -- Stop Reel Idle
    if reelTrack then
        reelTrack:Stop()
    end

    -- STEP 3: FishingCompleted
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RE/FishingCompleted")
        :FireServer()

    -- STEP 4: Idle Animasi
    playAnimation("rbxassetid://96586569072385")
end

-- AutoFishing Loop
task.spawn(function()
    while true do
        if AutoFishing then
            doFishingOnce()
            task.wait(1) -- delay antar mancing (bisa diatur)
        else
            task.wait(0.2)
        end
    end
end)

-- ======================================
-- UI Controls
-- ======================================

-- Input Delay Config
local InputDelay = AutoFishSection:AddInput("ReelIdleTime", {
    Title = "Auto Fish Delay [Sec]",
    Default = tostring(Config.ReelIdleTime),
    Placeholder = "Dont Change it",
    Numeric = true,
    Callback = function(Value)
        Config.ReelIdleTime = tonumber(Value) or Config.ReelIdleTime
    end
})

-- Toggle Auto Fishing
local ToggleAuto = AutoFishSection:AddToggle("AutoFishingToggle", {
    Title = "Auto Fishing",
    Default = false,
    Callback = function(Value)
        AutoFishing = Value
        if Value then
            Fluent:Notify({ Title = "Fishing", Content = "Auto Fishing ON", Duration = 4 })
        else
            Fluent:Notify({ Title = "Fishing", Content = "Auto Fishing OFF", Duration = 4 })
        end
    end
})

-- section auto Sell
-- Input Auto Sell Delay (dalam menit)
local InputDelay = AutoSellSection:AddInput("AutoSellDelay", {
    Title = "Auto Sell Delay [Min]",
    Default = tostring(Config.AutoSellDelay),
    Placeholder = "Dont Change it",
    Numeric = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            Config.AutoSellDelay = num
            Fluent:Notify({
                Title = "AutoSell",
                Content = "Delay set to "..Config.AutoSellDelay.." minute(s)",
                Duration = 4
            })
        else
            Fluent:Notify({
                Title = "AutoSell",
                Content = "Invalid input!",
                Duration = 4
            })
        end
    end
})

-- Toggle Auto Sell
local AutoSell = false
local ToggleAutoSell = AutoSellSection:AddToggle("AutoSellToggle", {
    Title = "Auto Sell",
    Default = false,
    Callback = function(Value)
        AutoSell = Value
        if Value then
            Fluent:Notify({
                Title = "AutoSell",
                Content = "Auto Sell ON (Delay: "..Config.AutoSellDelay.." min)",
                Duration = 4
            })

            -- jalankan loop AutoSell
            task.spawn(function()
                while AutoSell do
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_net@0.2.0")
                            :WaitForChild("net")
                            :WaitForChild("RF/SellAllItems")
                            :InvokeServer()
                    end)
                    if success then
                        Fluent:Notify({
                            Title = "AutoSell",
                            Content = "Auto Sell Active",
                            Duration = 2
                        })
                    else
                        warn("AutoSell Error: " .. tostring(err))
                    end
                    task.wait(Config.AutoSellDelay * 60) -- konversi menit ke detik
                end
            end)
        else
            Fluent:Notify({
                Title = "AutoSell",
                Content = "Auto Sell OFF",
                Duration = 4
            })
        end
    end
})





local Players = game:GetService("Players")
local player = Players.LocalPlayer
local root = player.Character or player.CharacterAdded:Wait()
root = root:WaitForChild("HumanoidRootPart")

-- === DAFTAR LOKASI ===
-- =======================
-- Daftar teleport CFrame (urut sesuai list)
-- =======================
local teleportList = {
    ["Stingray Shores"] = CFrame.new(-13.2640066, 4.29577065, 2821.48682, 0.99168092, 0, -0.12872076, 0, 1.00000012, 0, 0.12872076, 0, 0.99168092),
    ["Tropical Grove"] = CFrame.new(-2164.48804, 6.37770081, 3626.59277, -0.656722546, 0, -0.75413233, 0, 1, 0, 0.75413233, 0, -0.656722546),
    ["Winter Fest"] = CFrame.new(),
    ["Kohana"] = CFrame.new(-683.985474, 3.0354929, 799.907593, -0.999713778, 0, 0.0239262339, 0, 1.00000012, 0, -0.0239262339, 0, -0.999713778),
    ["Kohana Volcano"] = CFrame.new(-601.147522, 59.0000572, 108.313446, -0.900374651, 0, 0.435115576, 0, 1, 0, -0.435115576, 0, -0.900374651),
    ["Esoteric Island"] = CFrame.new(),
    ["Esoteric Depths"] = CFrame.new(3207.48438, -1302.85486, 1409.95032, 0.935428143, 0, 0.353516877, 0, 1, 0, -0.353516877, 0, 0.935428143),
    ["Crystal Island"] = CFrame.new(),
    ["Coral Reefs"] = CFrame.new(-3153.79346, 2.40465546, 2127.73804, 0.978023469, 0, -0.208495244, 0, 1.00000012, 0, 0.208495274, 0, 0.97802335),
    ["Sisyphus Statue"] = CFrame.new(-3744.00195, -135.074417, -1010.22461, -0.983183146, 0, -0.182622537, 0, 1.00000012, 0, 0.182622537, 0, -0.983183146),
    ["Crater Island"] = CFrame.new(995.165283, 2.99178267, 5009.90039, -0.999866247, 0, -0.0163552333, 0, 1, 0, 0.0163552333, 0, -0.999866247),
    ["Treasure Room"] = CFrame.new(-3555.62085, -279.074219, -1673.78723, -0.697831035, 0, 0.71626246, 0, 1, 0, -0.71626246, 0, -0.697831035),
    ["Ocean"] = CFrame.new(-1499.17981, 3.49999976, 1912.60535, -0.850566864, 0, 0.525867045, 0, 1, 0, -0.525867105, 0, -0.850566745),
}

-- =======================
-- Buat list urut untuk dropdown
-- =======================
local locationNames = {
    "Stingray Shores",
    "Tropical Grove",
    "Winter Fest",
    "Kohana",
    "Kohana Volcano",
    "Esoteric Island",
    "Esoteric Depths",
    "Crystal Island",
    "Coral Reefs",
    "Sisyphus Statue",
    "Crater Island",
    "Treasure Room",
    "Ocean"
}

-- =======================
-- Dropdown Fluent
-- =======================
local Dropdown = Tabs.Wtp:AddDropdown("Dropdown", {
    Title = "Teleport Location",
    Values = locationNames,
    Multi = false,
    Default = 1
})

Dropdown:OnChanged(function(Value)
    selectedLocation = Value
    print("Selected:", Value)
end)

Tabs.Wtp:AddButton({
    Title = "Teleport",
    Description = "Teleport ke lokasi terpilih",
    Callback = function()
        if selectedLocation and teleportList[selectedLocation] then
            root.CFrame = teleportList[selectedLocation] + Vector3.new(0,3,0) -- sedikit naik biar ga nyangkut
            print("Teleported to:", selectedLocation)
        else
            warn("Lokasi tidak ditemukan!")
        end
    end
})

local weatherTypes = {
    "Wind",
    "Cloudy",
    "Snow",
    "Storm",
    "Radiant",
    "Shark Hunt"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local netModule = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RF/PurchaseWeatherEvent")

local AutoWeatherToggles = {} -- simpan toggle per weather

for _, weather in ipairs(weatherTypes) do
    -- Button manual beli weather
    Tabs.Weather:AddButton({
        Title = weather,
        Description = "Purchase weather: " .. weather,
        Callback = function()
            pcall(function()
                netModule:InvokeServer(weather)
                print("Purchased weather:", weather)
            end)
        end
    })

    -- Toggle auto beli per weather
    AutoWeatherToggles[weather] = Tabs.Weather:AddToggle("Auto_" .. weather, {
        Title = "Auto " .. weather,
        Default = false,
        Callback = function(Value)
            if Value then
                Fluent:Notify({
                    Title = "Weather",
                    Content = "Auto purchasing " .. weather .. " ON",
                    Duration = 4
                })
                -- spawn auto loop
                task.spawn(function()
                    while AutoWeatherToggles[weather].Value do
                        pcall(function()
                            netModule:InvokeServer(weather)
                            print("Auto purchased weather:", weather)
                        end)
                        -- tunggu 10 menit
                        for i = 1, 600 do
                            if not AutoWeatherToggles[weather].Value then break end
                            task.wait(1)
                        end
                    end
                end)
            else
                Fluent:Notify({
                    Title = "Weather",
                    Content = "Auto purchasing " .. weather .. " OFF",
                    Duration = 4
                })
            end
        end
    })
end



-- SaveManager & Interface
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FishingHub")
SaveManager:SetFolder("FishingHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fishing Hub",
    Content = "Script loaded!",
    Duration = 6
})
