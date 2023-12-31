local config <const> = require 'config.client.richpresence'.discord

if not config then return end

local AddStateBagChangeHandler <const> = AddStateBagChangeHandler
local SetRichPresence <const> = SetRichPresence
local GetGameTimer <const> = GetGameTimer
local richPresence = {}

---@param key string
---@param value any
function richPresence:set(key, value)
    if self[key] ~= value then self[key] = value end
    SetRichPresence(('Players: %s/%s\n[%s] - %s'):format(self.count--[[@as number]] or GlobalState.playersCount--[[@as number]], config.maxPlayers, cache.serverid, LocalPlayer.state.name or LocalPlayer.state.username or self.username))
end

CreateThread(function()
    local SetDiscordAppId <const> = SetDiscordAppId
    local SetDiscordRichPresenceAsset <const> = SetDiscordRichPresenceAsset
    local SetDiscordRichPresenceAssetText <const> = SetDiscordRichPresenceAssetText
    local SetDiscordRichPresenceAssetSmall <const> = SetDiscordRichPresenceAssetSmall
    local SetDiscordRichPresenceAssetSmallText <const> = SetDiscordRichPresenceAssetSmallText

    SetDiscordAppId(config.id)
    SetDiscordRichPresenceAsset(config.largeIcon)
    SetDiscordRichPresenceAssetText(config.largeIconText)
    SetDiscordRichPresenceAssetSmall(config.smallIcon)
    SetDiscordRichPresenceAssetSmallText(config.smallIconText)

    if config?.buttons[0] then
        local SetDiscordRichPresenceAction <const> = SetDiscordRichPresenceAction
        if #(config.buttons) > 1 then
            warn('Discord Rich Presence: You can only have 2 buttons')
        elseif #(config.buttons) > 0 then
            for i = 0, #(config.buttons) do
                local button <const> = config.buttons[i]
                SetDiscordRichPresenceAction(i, button.text, button.url)
            end
        else
            SetDiscordRichPresenceAction(0, config.buttons[0].text, config.buttons[0].url)
        end
    end


    local playerName <const> = GetPlayerName(cache.playerid) 
    richPresence:set('username', playerName--[[@as string]]) -- Used for the rich presence to avoid nil value
end)

AddStateBagChangeHandler('playersCount', 'global', function(bagName, key, value, reserved, replicated)
    local time <const>, timer <const> = GetGameTimer(), 4000
    while (time + timer) > GetGameTimer() do Wait(1000) end --- wait 4 seconds before updating the rich presence (to avoid spamming discord api & await playersCount update)
    richPresence:set('count', GlobalState.playersCount == value and value or GlobalState.playersCount)
end)