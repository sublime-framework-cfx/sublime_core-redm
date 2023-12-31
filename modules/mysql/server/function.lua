local mysql = {}

local update_characters <const> = 'UPDATE `characters` SET `x` = ?, `y` = ?, `z` = ?, `w` = ?, `instance` = ?, `status` = ?,`isDead` = ?, `isDead` = ?, `metadata` = ? WHERE charid = ?'
---@param parameters table
---@return any
function mysql.updateCharacters(parameters)
    MySQL.prepare.await(update_characters, {parameters})
end

local insert_new_char <const> = 'INSERT INTO `characters` (`user`, `firstname`, `lastname`, `sex`, `dateofbirth`, `height`, `model`) VALUES (?, ?, ?, ?, ?, ?, ?)'
---@param userId integer
---@param data table
---@return number -- insert id
function mysql.createNewCharacter(userId, data) -- used to create new character
    return MySQL.insert.await(insert_new_char, {userId, data.firstname, data.lastname, data.sex, data.dob, data.height, data.model})
end

local update_profile <const> = 'UPDATE profils SET user = ?, password = ?, stats = ?, metadata = ? WHERE id = ?' -- used to update profile (on disconnect & change password ...)
---@param user table
---@return number -- affected rows
function mysql.updateProfile(user)
    return MySQL.update.await(update_profile, { user.username, user.password, json.encode(user.stats or {}), json.encode(user.metadata or {}), user.id })
end

local load_characters <const> = 'SELECT * FROM characters WHERE user = ?' -- used to show character selection
---@param userId integer
---@return table
function mysql.loadCharacters(userId)
    return MySQL.query.await(load_characters, { userId })
end

local load_character <const> = 'SELECT * FROM characters WHERE charid = ?' -- used to load character
---@param charId integer
---@return table
function mysql.loadCharacter(charId)
    return MySQL.single.await(load_character, { charId })
end

local change_temp_id <const> = 'UPDATE profils SET tempId = ? WHERE id = ?' -- used to change temp id
---@param value? number
---@param userId integer
---@return unknown
function mysql.changeTempId(value, userId)
    return MySQL.update.await(change_temp_id, { value, userId })
end

local check_user_exist <const> = 'SELECT 1 FROM profils WHERE user = ?'
---@param user string username
---@return boolean
function mysql.checkUserExist(user)
    return MySQL.scalar.await(check_user_exist, { user })
end

local init_profile <const> = 'SELECT * FROM profils WHERE user = ? AND password = ?'
---@param username string
---@param password string
---@return table
function mysql.initProfile(username, password)
    return MySQL.single.await(init_profile, { username, password })
end

local create_profile <const> = 'INSERT INTO profils (user, password, createdBy) VALUES (?, ?, ?)'
---@param username string
---@param password string
---@param createdBy string
---@return boolean
function mysql.createProfile(username, password, createdBy)
    return MySQL.insert.await(create_profile, { username, password, createdBy })
end

local login_to_profile <const> = 'SELECT `id` FROM `profils` WHERE `user` = ? AND `password` = ?'
---@param username string
---@param number string
---@return number
function mysql.loginToProfile(username, password)
    return MySQL.scalar.await(login_to_profile, { username, password })
end

local update_profile_identifiers <const> = 'UPDATE profils SET identifiers = ? WHERE `id` = ?'
---@param identifiers string
---@param userId integer
function mysql.updateProfileIdentifiers(identifiers, userId)
    return MySQL.update.await(update_profile_identifiers, { identifiers, userId })
end

local update_character <const> = 'UPDATE characters SET x = ?, y = ?, z = ?, w = ?, instance = ?, status = ?, isDead = ?, metadata = ? WHERE charid = ?'
---@param parameters table
---@return any
function mysql.updateCharacter(parameters)
    return MySQL.prepare.await(update_character, { parameters })
end

---utils if you doesn't want rewrite same code in external resource, use it like this: 
---local mysql <const> = sl.mysql()
---local exist <const> = mysql.checkUserExist('sup2ak')
---@return table
function sl.mysql()
    return mysql
end

mysql.name = sl.databaseName

return mysql