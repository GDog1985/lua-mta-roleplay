account = { }
account.__index = account

function account:new( username, password )
	if ( not username ) or ( not password ) then
		outputDebugString( "ACCOUNT: No " .. ( not username and ( not password and "username and password" or "username" ) or "password" ) .. " defined.", 1 )
		return false, 1
	end
	
	if ( exports.database:query( "SELECT NULL FROM `accounts` WHERE `username` = ? LIMIT 1", username ) ) then
		return false, 2
	else
		local id = exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", tostring( username ), tostring( password ) )
		return id
	end
	
	return false
end

function account:get( condition )
	if ( not condition ) then
		outputDebugString( "ACCOUNT: No condition defined.", 1 )
		return false, 1
	end
	
	if ( type( condition ) == "integer" ) then
		local result = exports.database:query( "SELECT `username` FROM `accounts` WHERE `id` = ? LIMIT 1", tonumber( condition ) )
		if ( result ) then
			return result
		else
			return false, 3
		end
	elseif ( type( condition ) == "string" ) then
		local result = exports.database:query( "SELECT `id` FROM `accounts` WHERE `username` = ? LIMIT 1", tostring( condition ) )
		if ( result ) then
			return result
		else
			return false, 2
		end
	end
	
	return false
end

function account:delete( user_id, permanently )
	if ( not user_id ) then
		outputDebugString( "ACCOUNT: No user ID defined.", 1 )
		return false, 1
	end
	
	if ( not permanently ) then
		if ( exports.database:execute( "UPDATE `accounts` SET `is_deleted` = ? WHERE `id` = ?", 1, tonumber( user_id ) ) ) then
			return true
		end
	else
		if ( exports.database:execute( "DELETE FROM `accounts` WHERE `id` = ?", tonumber( user_id ) ) ) then
			return true
		end
	end
	
	return false
end

function account:try( player, username, password )
	if ( not isElement( player ) ) or ( ( not username ) and ( not password ) ) then
		outputDebugString( "ACCOUNT: No arguments passed in.", 1 )
		return false, 1
	end
	
	if ( not password ) and ( type( username ) == "table" ) then
		password = username.password
		username = username.username
	end
	
	if ( password ) then
		local query = exports.database:query( "SELECT `id`, `username`, `admin` FROM `accounts` WHERE `username` = ? AND `password` = ? AND `is_deleted` = '0' LIMIT 1", username, password )
		if ( query ) then
			if ( exports.database:execute( "UPDATE `accounts` SET `last_login` = NOW(), `last_ip` = ? WHERE `id` = ?", getPlayerIP( player ), query.id ) ) then
				account.player[ player ] = {
					id = query.id,
					username = query.username,
					admin = query.admin,
					loggedin = true
				}
				
				return true
			else
				return false, 3
			end
		else
			return false, 2
		end
	end
	
	return false
end
addEvent( getResourceName( resource ) .. ":try", true )
addEventHandler( getResourceName( resource ) .. ":try", root, account:try )

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( )
		if ( client ~= source ) then return end
		if ( account:try( client, username, password ) ) then
			triggerClientEvent( client, getResourceName( resource ) .. ":finish", client )
		else
			-- Error
		end
	end
)