local Players = game:GetService("Players")
local player = Players.LocalPlayer
local myHRP = player.Character:WaitForChild("HumanoidRootPart")

-- Fungsi teleport ke player tanpa case-sensitive
local function teleportToPlayerIgnoreCase(targetName)
    targetName = targetName:lower()
    
    for _, p in pairs(workspace.Characters:GetChildren()) do
        if p.Name:lower() == targetName and p:FindFirstChild("HumanoidRootPart") then
            local targetHRP = p.HumanoidRootPart
            myHRP.CFrame = CFrame.new(targetHRP.Position))
            print("Teleport ke:", p.Name, "Posisi:", targetHRP.Position)
            return
        end
    end
    
    warn("Player tidak ditemukan:", targetName)
end

-- Contoh penggunaan
teleportToPlayerIgnoreCase("zcus_ghx")  -- bisa ketik "Mivorapx_5" juga
