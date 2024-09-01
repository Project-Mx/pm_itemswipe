local ESX = exports['es_extended']:getSharedObject()


local function isAdmin(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        for _, group in ipairs(Config.AdminGroups) do
            if playerGroup == group then
                return true
            end
        end
    end
    return false
end

local function clearItemsFromOnlinePlayers()
    local players = GetPlayers()

    for _, player in pairs(players) do
        local playerId = tonumber(player)

        for _, item in ipairs(Config.ItemsToRemove) do
            while exports.ox_inventory:RemoveItem(playerId, item, 1) do
            end
        end

        for _, ammo in ipairs(Config.AmmoToRemove) do
            while exports.ox_inventory:RemoveItem(playerId, ammo, 1) do
            end
        end
    end
end

local function clearItemsFromOfflinePlayers()
    local sql = "SELECT identifier, inventory FROM users"
    local result = MySQL.Sync.fetchAll(sql, {})

    local updates = {}
    for _, user in ipairs(result) do
        local identifier = user.identifier
        local inventory = json.decode(user.inventory) or {}

        local updatedInventory = {}
        local inventoryChanged = false
        for _, item in ipairs(inventory) do
            if not (item.name and (table.contains(Config.ItemsToRemove, item.name:upper()) or table.contains(Config.AmmoToRemove, item.name:lower()))) then
                table.insert(updatedInventory, item)
            else
                print("Removed " .. item.name .. " from offline player " .. identifier)
                inventoryChanged = true
            end
        end

        if inventoryChanged then
            table.insert(updates, {inventory = json.encode(updatedInventory), identifier = identifier})
        end
    end

    for _, update in ipairs(updates) do
        local sqlUpdate = "UPDATE users SET inventory = @inventory WHERE identifier = @identifier"
        MySQL.Sync.execute(sqlUpdate, update)
    end
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

lib.addCommand('clearitems', {
    help = 'Clear items from all players online or offline',
    restricted = 'group.admin',
}, function(source, args)
    if isAdmin(source) then
        clearItemsFromOnlinePlayers()
        clearItemsFromOfflinePlayers()
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[!]", "Successfully removed specified items and ammo from all inventories."}
        })
    else
   end
end)
