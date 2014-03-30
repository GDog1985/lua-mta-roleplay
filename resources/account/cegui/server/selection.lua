addEvent( getResourceName( resource ) .. ":cegui:characters", true )
addEventHandler( getResourceName( resource ) .. ":cegui:characters", root,
	function( )
		if ( client ~= source ) or ( not getElementData( client, "client:id" ) ) then return end
		local result, num_rows = exports.database:query( "SELECT `name`, DATEDIFF(`last_login`, NOW()) AS `last_login` FROM `characters` WHERE `account_id` = ? AND `is_deleted` = '0'", getElementData( client, "client:id" ) )
		if ( result ) and ( num_rows > 0 ) then
			triggerClientEvent( client, getResourceName( resource ) .. ":cegui:characters", client, result )
		end
	end
)