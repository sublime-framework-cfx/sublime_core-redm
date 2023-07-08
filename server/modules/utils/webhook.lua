local PerformHttpRequest <const>, config <const> = PerformHttpRequest, sl:getConfig('webhook')
local toUpper <const> = require('imports.string.shared').firstToUpper
string.to_utf8 = require ('imports.utf8.shared').to_utf8
assert(os.setlocale(config.localization))

---@class WebhookDataProps
---@field bot_name? string
---@field avatar? string
---@field date_format? string
---@field footer_icon? string

---@class WebhookEmbedProps
---@field title? string
---@field description? string
---@field image? string
---@field color? integer

---@class WebhookMessageProps
---@field text string
---@field data WebhookDataProps

--- sl:webhook('embed')
---@param url string
---@param embeds WebhookEmbedProps
---@param data WebhookDataProps
local function embed(self, url, embeds, data)
    local date <const>, c <const> = {
        letter = ("\n%s %s"):format(toUpper(os.date("%A %d")), toUpper(os.date("%B %Y : [%H:%M:%S]"))):to_utf8(),
        numeric = ("\n%s"):format(os.date("[%d/%m/%Y] - [%H:%M:%S]"))
    }, config or self:getConfig('webhook')

    url = c.channel[url] or url

    local _embed = {
        {
			["color"] = data?.color or config.default.color,
			["title"] = embeds.title or '',
			["description"] = embeds.description or '',
			["footer"] = {
				["text"] = data?.date_format and date[data?.date_format] or c.default.date_format and date[c.default.date_format],
				["icon_url"] = data?.footer_icon or c.default.foot_icon,
			},
            ['image'] = {
                ['url'] = embeds.image or nil
            }
		},
    }

    PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({
        username = data?.bot_name or c.default.bot_name,
        embeds = _embed,
        avatar_url = data?.avatar or c.default.avatar,
    }), {['Content-Type'] = 'application/json'})
end

--- sl:webhook('message')
---@param url string
---@param text string
---@param data WebhookDataProps.bot_name
local function message(self, url, text, data)
    local c <const> = config or self:getConfig('webhook')

    url = c.channel[url] or url

    PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({
        username = data.bot_name or c.default.bot_name,
        content = text
    }), {['Content-Type'] = 'application/json', ['charset'] = 'utf-8'})
end

---@param types string
---@param ... any
---@return void
local function SendWebhookDiscord(self, types, ...)
    if types == 'embed' then
        return embed(self, ...)
    elseif types == 'message' then
        return message(self, ...)
    end
    return error("Invalid types of webhook", 1)
end

function sl:webhook(types, ...)
    return SendWebhookDiscord(self, types, ...)
end

if config.playing_from ~= 'shared' then return end

---@todo need more implementation about webhook send from client
sl:onNet('webhook:received', function (source, types, ...)
    warn(source, 'play webhook from client')
    sl:webhook(types, ...)
end)