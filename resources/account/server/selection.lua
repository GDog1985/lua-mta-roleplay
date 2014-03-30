function newCharacter( name, account_id )
	if ( not name ) or ( not account_id ) then
		outputDebugString( "ACCOUNT: No name or account ID defined.", 1 )
		return false, 1
	end
	
	if ( getCharacter( name ) ) then
		return false, 2
	else
		return exports.database:insert_id( "INSERT INTO `characters` (`name`, `account_id`) VALUES (?, ?)", exports.database:escape_string( name, "character" ):gsub( " ", "_" ), account_id )
	end
	
	return false
end

function getCharacter( parameter )
	if ( not parameter ) then
		outputDebugString( "ACCOUNT: No parameter passed in.", 1 )
		return false, 1
	end
	
	if ( type( parameter ) == "integer" ) then
		local parameter = exports.database:escape_string( parameter, "digit" )
		local result, num_rows = exports.database:query_single( "SELECT *, DATEDIFF(`last_login`, NOW()) AS `login_diff` FROM `characters` WHERE `id` = ? LIMIT 1", parameter )
		if ( result ) and ( num_rows > 0 ) then
			return result
		else
			return false, 2
		end
	elseif ( type( parameter ) == "string" ) then
		local result, num_rows = exports.database:query_single( "SELECT *, DATEDIFF(`last_login`, NOW()) AS `login_diff` FROM `characters` WHERE `name` = ? LIMIT 1", exports.database:escape_string( parameter, "character" ):gsub( " ", "_" ) )
		if ( result ) and ( num_rows > 0 ) then
			return result
		else
			return false, 2
		end
	elseif ( type( parameter ) == "userdata" ) and ( isElement( parameter ) ) and ( getElementType( parameter ) == "player" ) then
		if ( getElementData( parameter, "client:id" ) ) then
			local result, num_rows = exports.database:query_single( "SELECT *, DATEDIFF(`last_login`, NOW()) AS `login_diff` FROM `characters` WHERE `id` = ? LIMIT 1", getElementData( parameter, "client:id" ) )
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

function saveCharacter( player, wasAutomatic )
	if ( not isElement( player ) ) or ( getElementType( player ) ~= "player" ) then
		outputDebugString( "ACCOUNT: No player defined.", 1 )
		return false, 1
	end
	
	if ( getElementData( player, "client:character.id" ) ) then
		local x, y, z = getElementPosition( player )
		local _, _, rotation = getElementRotation( player )
		if ( exports.database:execute( "UPDATE `characters` SET `name` = ?, `pos_x` = ?, `pos_y` = ?, `pos_z` = ?, `rotation` = ?, `interior` = ?, `dimension` = ?, `health` = ?, `armor` = ? WHERE `id` = ?", getPlayerName( player ), x, y, z, rotation, getElementInterior( player ), getElementDimension( player ), getElementHealth( player ), getPedArmor( player ), getElementData( player, "client:character.id" ) ) ) then
			if ( not wasAutomatic ) then
				outputDebugString( "ACCOUNT: Saved character '" .. getPlayerName( player ) .. "' ('" .. getElementData( player, "client:username" ) .. "')." )
			end
			return true
		else
			return false, 3
		end
	end
	
	return false, 2
end

function deleteCharacter( characterID, queueDestroy )
	if ( not characterID ) then
		outputDebugString( "ACCOUNT: No character ID defined.", 1 )
		return false, 1
	end
	
	local characterID = exports.database:escape_string( characterID, "digit" )
	if ( not queueDestroy ) then
		if ( exports.database:execute( "UPDATE `characters` SET `is_deleted` = '1' WHERE `id` = ?", characterID ) ) then
			return true
		end
	else
		if ( exports.database:execute( "DELETE FROM `characters` WHERE `id` = ?", characterID ) ) then
			return true
		end
	end
	
	return false
end

addEvent( getResourceName( resource ) .. ":select", true )
addEventHandler( getResourceName( resource ) .. ":select", root,
	function( characterName )
		local data, error = getCharacter( characterName )
		if ( data ) then
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:close", source, "selection", true, true )
			fadeCamera( source, false, 2.5 )
			setTimer( function( player, data )
				for i=1,50 do
					outputChatBox( " ", player )
				end
				
				spawnPlayer( player, data.pos_x, data.pos_y, data.pos_z, data.rotation, data.model, data.interior, data.dimension )
				setElementHealth( player, data.health )
				setPedArmor( player, data.armor )
				
				setElementData( player, "client:character.id", data.id, true )
				setElementData( player, "client:loggedin", 1, true )
				
				fadeCamera( player, true, 3.0 )
				
				outputChatBox( "#D42F2F[Server] #EFEFEF Welcome" .. ( data.login_diff and " back" or "" ) .. ", " .. data.name:gsub( "_", " ") .. "!", player, 255, 255, 255, true )
				
				triggerClientEvent( player, getResourceName( resource ) .. ":roamer:pause", player )
				triggerClientEvent( player, getResourceName( resource ) .. ":roamer:camera", player, false )
				setCameraTarget( player, player )
				
				showChat( player, true )
				
				exports.database:execute( "UPDATE `characters` SET `last_login` = NOW() WHERE `id` = ?", data.id )
			end, 3000, 1, source, data )
		else
			triggerClientEvent( source, getResourceName( resource ) .. ":cegui:error", source, 11, error, true, "selection" )
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		saveCharacter( source, true )
	end
)