local prevent_form_spam = { }

addEvent( getResourceName( resource ) .. ":cegui:verify", true )
addEventHandler( getResourceName( resource ) .. ":cegui:verify", root,
	function( input, buttonID )
		if ( client ~= source ) or ( type( input ) ~= "table" ) then return end
		if ( ( input.username ) and ( input.password ) ) and ( getElementData( client, "client:username" ) ) then return end
		
		if ( prevent_form_spam[ client ] ) and ( prevent_form_spam[ client ].count >= 5 ) then
			triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 7, nil, true, ( input.character and "selection" or "login" ) )
			if ( isTimer( prevent_form_spam[ client ].reset ) ) then
				resetTimer( prevent_form_spam[ client ].reset )
			end
			return
		end
		
		if ( input.username ) and ( input.password ) then
			if ( input.username:len( ) > 2 ) then
				if ( input.password:len( ) > 6 ) then
					triggerEvent( getResourceName( resource ) .. ":" .. ( buttonID and "login" or "register" ), client, input )
				else
					triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 2, nil, true )
					return
				end
			else
				triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 1, nil, true )
				return
			end
		elseif ( input.character ) then
			if ( input.character:len( ) > 6 ) then
				triggerEvent( getResourceName( resource ) .. ":select", client, input.character )
			else
				triggerClientEvent( client, getResourceName( resource ) .. ":cegui:error", client, 1, nil, true, "selection" )
				return
			end
		else
			return
		end
		
		if ( prevent_form_spam[ client ] ) then
			prevent_form_spam[ client ].count = prevent_form_spam[ client ].count + 1
			if ( isTimer( prevent_form_spam[ client ].reset ) ) then
				resetTimer( prevent_form_spam[ client ].reset )
			end
		else
			prevent_form_spam[ client ] = { }
			prevent_form_spam[ client ].count = 1
			prevent_form_spam[ client ].reset = setTimer( function( player )
				if ( isElement( player ) ) then
					--[[
					-- If you want to hide the warning eventually, just uncomment this
					if ( prevent_form_spam[ player ].count >= 5 ) then
						triggerClientEvent( player, getResourceName( resource ) .. ":cegui:error", player, nil, nil, true, ( input.character and "selection" or "login" ) )
					end
					]]
					
					prevent_form_spam[ player ] = nil
				end
			end, 1100, 1, client )
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		if ( prevent_form_spam[ source ] ) then
			prevent_form_spam[ source ] = nil
		end
	end
)