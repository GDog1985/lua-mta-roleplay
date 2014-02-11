function new( username, password )
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

function get( condition )
	if ( not condition ) then
		outputDebugString( "ACCOUNT: No condition defined.", 1 )
		return false, 1
	end
	
	if ( type( condition ) == "integer" ) then
		local result = exports.database:query( "SELECT `username` FROM `accounts` WHERE `id` = ? LIMIT 1", tonumber( condition ) )
		if ( result ) then
			return result
		else
			return false, 2
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

function delete( user_id, permanently )
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