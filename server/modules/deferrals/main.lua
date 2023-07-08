local cards <const> = require(('server.modules.deferrals.cards.%s'):format(sl.lang))
local mysql <const> = require 'server.modules.main.mysql'

local function RegisterCard(d, cb, _source)
    Wait(50)
    d.presentCard(cards.register, function(rdata, raw)
        if rdata.submit_type == 'cancel' then cb(d) end
        if rdata.submit_type == 'register' then
            local username, password, cpassword = rdata.username, rdata.password, rdata.confirm_password

            if not username or not password or not cpassword then
                d.update(translate('d_missing_fields'))
                Wait(3000)
                return RegisterCard(d, cb, _source)
            end

            password = joaat(password:gsub('%s+', '_'))
            cpassword = joaat(cpassword:gsub('%s+', '_'))
            username = username:gsub('%s+', '-')

            if password ~= cpassword then
                d.update(translate('d_passwords_not_match'))
                Wait(3000)
                return RegisterCard(d, cb, _source)
            end

            ---@todo SQL: Add more security checks about identifier want create multiple account if you don't authorized to do that
            local user_exist <const> = mysql.checkUserExist(username)
            if user_exist then
                d.update(translate('d_user_already_exist'))
                Wait(3000)
                return RegisterCard(d, cb)
            end

            local success = MySQL.insert.await('INSERT INTO profils (user, password, createdBy) VALUES (?, ?, ?)', {username, tostring(password), sl:getIdentifiersFromId(_source, true)})
            if success then
                d.update(translate('d_account_created'))
                Wait(3000)
                return cb(d, _source)
            end
        end
    end)
end

local function HomeCard(d, _source)
    Wait(100)
    d.presentCard(cards.home, function(data, raw)
        if not data or data.submitId == 'quit' then
            d.done(translate('d_see_you_soon'))
            return CancelEvent()
        end

        if data.submitId == 'login' then
            local username, password = data.username, data.password
            if not username or not password then
                d.update(translate('d_missing_fields'))
                Wait(3000)
                return HomeCard(d, _source)
            end

            password = tostring(joaat(password:gsub('%s+', '_')))
            username = username:gsub('%s+', '-')

            local user_exist = MySQL.scalar.await('SELECT 1 FROM `profils` WHERE `user` = ? AND `password` = ?', {username, password})
            if not user_exist then
                d.update(translate('d_user_not_exist'))
                Wait(3000)
                return HomeCard(d, _source)
            end

            MySQL.update.await('UPDATE profils SET identifiers = ? WHERE `user` = ? AND `password` = ?', {sl:getIdentifiersFromId(_source, true), username, password})
            sl.tempId[_source] = _source
            sl:createProfileObj(_source, username, data.password)
            Wait(500)
            d.done()
        elseif data.submitId == 'register' then
            Wait(50)
            RegisterCard(d, HomeCard, _source)
        end
    end)
end

return function(_source, name, setKickReason, d)
    d.defer()
    Wait(500)
    HomeCard(d, _source)
end
