addEvent( "cegui:verify", true )
addEventHandler( "cegui:verify", root,
	function( input, loginOrRegister )
		if ( client ~= source ) or ( type( input ) ~= "table" ) or ( #input ~= 2 ) then return end
		if ( input.username:len( ) > 2 ) then
			if ( input.password:len( ) > 6 ) then
				triggerEvent( getResourceName( resource ) .. ":" .. ( loginOrRegister and "login" or "register" ), client, input )
			else
				triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 2 )
			end
		else
			triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 1 )
		end
	end
)