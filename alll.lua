    -- LocalScript
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

-- CONFIG
local Config = {
    LoopCount = 10,       -- jumlah loop
    ReelIdleTime = 3,     -- durasi reel idle sebelum stop
    Direction = -0.75,    -- arah lemparan
    Power = 0.9923193947  -- power lemparan
}

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
	print("Animasi diputar:", animId)
	return track
end

-- MAIN LOOP
for i = 1, Config.LoopCount do
    print("=== Loop ke-", i, "===")
    
    -- STEP 1: ChargeFishingRod
    local args1 = {tick()}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RF/ChargeFishingRod")
        :InvokeServer(unpack(args1))

    -- Langsung play Reel Idle
    local reelTrack = playAnimation("rbxassetid://134965425664034")

    -- STEP 2: RequestFishingMinigameStarted
    local args2 = {Config.Direction, Config.Power}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RF/RequestFishingMinigameStarted")
        :InvokeServer(unpack(args2))
    print(">> RequestFishingMinigameStarted terkirim")

    -- Tunggu ReelIdleTime detik
    wait(Config.ReelIdleTime)

    -- Stop Reel Idle
    if reelTrack then
        reelTrack:Stop()
        print("Animasi dihentikan: rbxassetid://134965425664034")
    end

    -- STEP 3: FishingCompleted
    game:GetService("ReplicatedStorage"):WaitForChild("Packages")
        :WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net"):WaitForChild("RE/FishingCompleted")
        :FireServer()
    print(">> FishingCompleted terkirim")

    -- STEP 4: Animasi FishingRodCharacterIdle2
    playAnimation("rbxassetid://96586569072385")

    -- Optional delay antar loop (biar server aman)
    wait(1)
end


-- 2
loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()

loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()

-- 3
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    -- Print posisi aja (Vector3)
    print("Vector3:", root.Position)
    print("Vector3.new(" .. root.Position.X .. ", " .. root.Position.Y .. ", " .. root.Position.Z .. ")")
    
    -- Print full CFrame (posisi + arah)
    local cf = root.CFrame
    print("CFrame.new(" ..
        cf.X .. ", " .. cf.Y .. ", " .. cf.Z .. ", " ..
        cf:components() .. ")")

-- 4
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Lokasi teleport
local targetPos = Vector3.new(-25.679351806640625, 7.260000228881836, 2832.84033203125)

-- Teleport langsung (ditambah offset Y 5 studs supaya tidak nyangkut tanah)
hrp.CFrame = CFrame.new(targetPos)
print("Teleport ke:", targetPos)

-- 5
local player = game.Players.LocalPlayer
local eventsFrame = player:WaitForChild("PlayerGui"):WaitForChild("Events"):WaitForChild("Frame")

-- Loop sampai Label muncul (cek tiap 0.5 detik)
local locationLabel
repeat
    locationLabel = eventsFrame:FindFirstChild("Label")
    if not locationLabel then
        wait(0.5)
    end
until locationLabel

print("Label sudah muncul:", locationLabel.Text)

-- Ambil Vector3 dari teks
local x, y, z = string.match(locationLabel.Text, "(-?%d+%.?%d*),%s*(-?%d+%.?%d*),%s*(-?%d+%.?%d*)")
if x and y and z then
    local pos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
    print("Vector3 lokasi:", pos)
end
