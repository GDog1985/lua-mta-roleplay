cegui.errors = { }
cegui.errors.hidden = false
cegui.errors.current = nil
cegui.errors.alternate = nil
cegui.errors.phrases = {
	{ "Username must contain at least 3 characters.", tocolor( 220, 55, 55, 185 ), 	"ERROR OCCURRED: " },
	{ "Password must contain at least 7 characters.", tocolor( 220, 55, 55, 185 ), 	"ERROR OCCURRED: " },
	{ "Username and/or password is incorrect.",		  tocolor( 220, 55, 55, 185 ), 	"ERROR OCCURRED: ",
		{ [ 2 ] = "ERROR OCCURRED: Seems like that account doesn't exist. Try register instead!" }
	},
	{ "That username appears to be taken already.",   tocolor( 220, 55, 55, 185 ), 	"ERROR OCCURRED: " },
	{ "Logging in right now...",  				 	  tocolor( 55, 120, 200, 175 ), "PROCESS: " },
	{ "Request timeout occurred, try again.",  		  tocolor( 220, 55, 55, 185 ), 	"PROCESS ERROR: " },
	{ "Please refrain from spamming the login form.", tocolor( 210, 120, 33, 185 ), "WARNING: " },
	{ "You have successfully registered. You can now log in.", tocolor( 30, 200, 45, 185 ), "SUCCESS: " },
	{ "Please select a character from the gridlist.", tocolor( 220, 55, 55, 185 ), "ERROR OCCURRED: " },
	{ "Selecting character right now...",  			  tocolor( 55, 120, 200, 175 ), "PROCESS: " },
	{ "Please stop screwing up my system right now.", tocolor( 220, 55, 55, 185 ), "ERROR OCCURRED: " }
}

function showNotificationBox( )
	if ( not cegui.errors.current ) or ( cegui.errors.hidden ) then return end
	local text = ( ( cegui.errors.alternate and cegui.errors.phrases[ cegui.errors.current ][ 4 ] and cegui.errors.phrases[ cegui.errors.current ][ 4 ][ cegui.errors.alternate ] ) and cegui.errors.phrases[ cegui.errors.current ][ 4 ][ cegui.errors.alternate ] or cegui.errors.phrases[ cegui.errors.current ][ 3 ] .. cegui.errors.phrases[ cegui.errors.current ][ 1 ] )
	local text_width, text_height = dxGetTextWidth( text ), dxGetFontHeight( )
	dxDrawRectangle( 0, screen_height - 40, screen_width, screen_height, cegui.errors.phrases[ cegui.errors.current ][ 2 ] )
	dxDrawText( text, ( screen_width - text_width ) / 2 + 1, screen_height - 40 + 16, text_width, text_height, tocolor( 4, 4, 4, 85 ) )
	dxDrawText( text, ( screen_width - text_width ) / 2, screen_height - 40 + 15, text_width, text_height, tocolor( 240, 240, 240, 200 ) )
end

addEvent( getResourceName( resource ) .. ":cegui:error:hide", true )
addEventHandler( getResourceName( resource ) .. ":cegui:error:hide", root,
	function( )
		cegui.errors.hidden = true
	end
)

addEvent( getResourceName( resource ) .. ":cegui:error:show", true )
addEventHandler( getResourceName( resource ) .. ":cegui:error:show", root,
	function( )
		cegui.errors.hidden = false
	end
)

addEvent( getResourceName( resource ) .. ":cegui:error", true )
addEventHandler( getResourceName( resource ) .. ":cegui:error", root,
	function( errorID, alternateErrorID, wasServer, cegui_element )
		cegui.errors.current = errorID
		cegui.errors.alternate = nil
		
		if ( errorID ~= nil ) then
			cegui.errors.alternate = alternateErrorID
			
			if ( errorID == 1 ) or ( errorID == 4 ) then
				guiLabelSetColor( cegui.windows.login.label.username, 220, 55, 55 )
			elseif ( errorID == 2 ) then
				guiLabelSetColor( cegui.windows.login.label.password, 220, 55, 55 )
			elseif ( errorID == 9 ) then
				guiLabelSetColor( cegui.windows.selection.label.header, 220, 55, 55 )
			end
			
			local cegui_element = cegui_element or "login"
			for _,type in pairs( cegui.windows[ cegui_element ] ) do
				for _,element in pairs( type ) do
					if ( isElement( element ) ) then
						guiSetEnabled( element, true )
					end
				end
			end
		end
		
		if ( wasServer ) then has_responded = true end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		addEventHandler( "onClientRender", root, showNotificationBox )
	end
)