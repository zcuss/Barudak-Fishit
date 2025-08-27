-- InventoryModule.lua
local module = {}

local Replion = require(game:GetService("ReplicatedStorage").Packages.Replion)
local ClientData = Replion.Client:WaitReplion("Data")
local HttpService = game:GetService("HttpService")

module.FishList = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zcuss/Barudak-Fishit/refs/heads/master/fishlist.lua"
))()

local function DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = (type(v) == "table") and DeepCopy(v) or v
    end
    return copy
end

function module.SendWebhook(PROXY_URL, WEBHOOK_URL, MESSAGE_ID, content)
    local request = http_request or request or HttpPost or (syn and syn.request)
    if not request then return warn("Exploit tidak support request") end

    local payload = {
        webhook = WEBHOOK_URL,
        id = MESSAGE_ID,
        embeds = { { title = "🎣 INVENTORY IKAN", description = content, color = 3447003 } }
    }

    request({
        Url = PROXY_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

function module.SendInventory(items, PROXY_URL, WEBHOOK_URL, MESSAGE_ID, toggleValue)
    if not toggleValue then return end
    if not items then return end

    local grouped = {}
    for _, item in ipairs(items) do
        local id = tonumber(item.Id)
        if id and module.FishList[id] then
            grouped[id] = grouped[id] or { Name = module.FishList[id].Name, Tier = module.FishList[id].Tier, Count = 0 }
            grouped[id].Count += 1
        end
    end

    local sortedIds = {}
    for id in pairs(grouped) do table.insert(sortedIds, id) end
    table.sort(sortedIds)

    local lines = {}
    for _, id in ipairs(sortedIds) do
        local data = grouped[id]
        table.insert(lines, string.format("%-5s | %-25s | Tier: %s",
            "x"..tostring(data.Count), data.Name, tostring(data.Tier)))
    end

    module.SendWebhook(PROXY_URL, WEBHOOK_URL, MESSAGE_ID, table.concat(lines, "\n"))
end

function module.DetectChanges(newItems, lastItems, PROXY_URL, WEBHOOK_URL, MESSAGE_ID, toggleValue)
    if not newItems then return lastItems end

    local function CountMap(items)
        local map = {}
        for _, item in ipairs(items) do
            local id = tonumber(item.Id)
            if id then map[id] = (map[id] or 0) + 1 end
        end
        return map
    end

    local oldMap, newMap = CountMap(lastItems), CountMap(newItems)

    for id, newCount in pairs(newMap) do
        if newCount ~= (oldMap[id] or 0) then
            module.SendInventory(newItems, PROXY_URL, WEBHOOK_URL, MESSAGE_ID, toggleValue)
            return DeepCopy(newItems)
        end
    end

    for id in pairs(oldMap) do
        if not newMap[id] then
            module.SendInventory(newItems, PROXY_URL, WEBHOOK_URL, MESSAGE_ID, toggleValue)
            return DeepCopy(newItems)
        end
    end

    return lastItems
end

return module
