account = { }
account.player = { }

function new( username, password )
	if ( not username ) or ( not password ) then
		outputDebugString( "ACCOUNT: No " .. ( not username and ( not password and "username and password" or "username" ) or "password" ) .. " defined.", 1 )
		return false, 1
	end
	
	local username, password = base64Encode( exports.database:escape_string( username, "account" ) ), base64Encode( sha512( exports.database:escape_string( password, "account" ) ) )
	if ( exports.database:query( "SELECT 1 FROM `accounts` WHERE `username` = ? LIMIT 1", username ) ) then
		return false, 2
	else
		return exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, password )
	end
	
	return false
end

function get( parameter )
	if ( not parameter ) then
		outputDebugString( "ACCOUNT: No parameter passed in.", 1 )
		return false, 1
	end
	
	if ( type( parameter ) == "integer" ) then
		local parameter = exports.database:escape_string( parameter, "digit" )
		local result, num_rows = exports.database:query( "SELECT `username` FROM `accounts` WHERE `id` = ? LIMIT 1", parameter )
		if ( result ) and ( num_rows > 0 ) then
			return result
		else
			return false, 2
		end
	elseif ( type( parameter ) == "string" ) then
		local result, num_rows = exports.database:query( "SELECT `id` FROM `accounts` WHERE `username` = ? LIMIT 1", base64Encode( exports.database:escape_string( parameter ) ) )
		if ( result ) and ( num_rows > 0 ) then
			return result
		else
			return false, 2
		end
	elseif ( type( parameter ) == "userdata" ) and ( isElement( parameter ) ) and ( getElementType( parameter ) == "player" ) then
		local preAccount = account.currents[ parameter ]
		if ( preAccount ) then
			local result, num_rows = exports.database:query( "SELECT `username` FROM `accounts` WHERE `id` = ? LIMIT 1", preAccount.id )
			if ( result ) and ( num_rows > 0 ) then
				return result
			else
				return false, 2
			end
		else
			return false, 1.5
		end
	end
	
	return false
end

function save( player, wasAutomatic )
	if ( not isElement( player ) ) or ( getElementType( player ) ~= "player" ) then
		outputDebugString( "ACCOUNT: No player defined.", 1 )
		return false, 1
	end
	
	if ( account.player[ player ] ) then
		if ( exports.database:execute( "UPDATE `accounts` SET `username` = ?, `admin` = ? WHERE `id` = ?", account.player[ player ].username, account.player[ player ].admin, account.player[ player ].id ) ) then
			if ( not wasAutomatic ) then
				outputDebugString( "ACCOUNT: Saved account '" .. account.player[ player ].username .. "'." )
			end
			return true
		else
			return false, 3
		end
	end
	
	return false, 2
end

function delete( userID, queueDestroy )
	if ( not userID ) then
		outputDebugString( "ACCOUNT: No user ID defined.", 1 )
		return false, 1
	end
	
	local userID = exports.database:escape_string( userID, "digit" )
	if ( not queueDestroy ) then
		if ( exports.database:execute( "UPDATE `accounts` SET `is_deleted` = '1' WHERE `id` = ?", userID ) ) then
			return true
		end
	else
		if ( exports.database:execute( "DELETE FROM `accounts` WHERE `id` = ?", userID ) ) then
			return true
		end
	end
	
	return false
end

function is_on_already( username )
	for player,values in pairs( account.player ) do
		if ( values.username == username ) then
			return player
		end
	end
	return false
end

function try( player, username, password )
	if ( not isElement( player ) ) or ( not username ) or ( not password ) then
		outputDebugString( "ACCOUNT: Invalid argument(s) passed in.", 1 )
		return false, 1
	end
	
	local query, num_rows = exports.database:query( "SELECT `id`, `username`, `admin` FROM `accounts` WHERE `username` = ? AND `password` = ? AND `is_deleted` = '0' LIMIT 1", exports.database:escape_string( username, "account" ), exports.database:escape_string( password, "account" ) )
	if ( query ) and ( num_rows > 0 ) then
		if ( not is_on_already( query.username ) ) then
			if ( exports.database:execute( "UPDATE `accounts` SET `last_login` = NOW(), `last_ip` = ? WHERE `id` = ?", getPlayerIP( player ), query.id ) ) then
				account.player[ player ] = {
					id = query.id,
					username = query.username,
					admin = query.admin,
					loggedin = true
				}
				
				return true
			else
				return false, 4
			end
		else
			return false, 3
		end
	else
		return false, 2
	end
	
	return false
end
addEvent( getResourceName( resource ) .. ":try", true )
addEventHandler( getResourceName( resource ) .. ":try", root, try )

addEvent( getResourceName( resource ) .. ":login", true )
addEventHandler( getResourceName( resource ) .. ":login", root,
	function( input )
		local try, error = try( source, input.username, input.password )
		if ( try ) then
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:close", source )
		else
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:error", source, 3, error )
		end
	end
)

addEvent( getResourceName( resource ) .. ":register", true )
addEventHandler( getResourceName( resource ) .. ":register", root,
	function( input )
		if ( not get( input.username ) ) then
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:close", source )
		else
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:error", source, 4 )
		end
	end
)