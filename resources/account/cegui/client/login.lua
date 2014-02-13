cegui = { }
cegui.__index = cegui
cegui.windows = { }
cegui.windows.login = { }
cegui.windows.login.input = { }
cegui.windows.login.window = { }
cegui.windows.login.label = { }
cegui.windows.login.edit = { }
cegui.windows.login.button = { }

local screen_width, screen_height = guiGetScreenSize( )
local window_width, window_height = 320, 320

local logged_in = false

function cegui:showLoginWindow( )
	if ( isElement( cegui.windows.login ) ) then
		showCursor( false, false )
		destroyElement( cegui.windows.login )
		return
	end
	
	if ( logged_in ) then return end
	
	cegui.windows.login.window = guiCreateWindow( ( screen_width - window_width ) / 2, ( screen_height - window_height ) / 2, window_width, window_height, "Log In or Register", false )
	guiWindowSetSizable( cegui.windows.login.window, false )
	guiWindowSetMovable( cegui.windows.login.window, false )
	
	cegui.windows.login.label.username = guiCreateLabel( 30, 50, window_width - 60, 15, "Username", false, cegui.windows.login.window )
	cegui.windows.login.edit.username = guiCreateEdit( 30, 75, window_width - 60, 30, "", false, cegui.windows.login.window )
	
	cegui.windows.login.label.password = guiCreateLabel( 30, 120, window_width - 60, 15, "Password", false, cegui.windows.login.window )
	cegui.windows.login.edit.password = guiCreateEdit( 30, 145, window_width - 60, 30, "", false, cegui.windows.login.window )
	guiEditSetMasked( cegui.windows.login.edit.password, true )
	
	cegui.windows.login.button.login = guiCreateButton( 30, 215, window_width - 60, 30, "Log in", false, cegui.windows.login.window )
	cegui.windows.login.button.register = guiCreateButton( 30, 260, window_width - 60, 30, "Register", false, cegui.windows.login.window )
	
	addEventHandler( "onClientGUIClick", guiRoot,
		function( )
			local element = ( ( source ~= cegui.windows.login.button.login and source ~= cegui.windows.login.button.register ) and false or true )
			if ( not element ) then return end
			cegui.windows.login.input.username, cegui.windows.login.input.password = guiGetText( cegui.windows.login.edit.username ), guiGetText( cegui.windows.login.edit.password )
			if ( cegui.windows.login.input.username:len( ) > 2 ) then
				if ( cegui.windows.login.input.password:len( ) > 6 ) then
					for _,element in pairs( cegui.windows.login ) do
						guiSetEnabled( element, false )
					end
					
					triggerServerEvent( getResourceName( resource ) .. ":cegui:verify", localPlayer, cegui.windows.login.input, ( source == cegui.windows.login.button.login and true or false ) )
				else
					triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 2 )
				end
			else
				triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 1 )
			end
		end, false
	)
	
	showCursor( true, true )
end

addEvent( getResourceName( resource ) .. ":cegui:error", true)
addEventHandler( getResourceName( resource ) .. ":cegui:error", root,
	function( errorID )
		if ( errorID == 1 ) then
			guiLabelSetColor( cegui.windows.login.label.username, 220, 55, 55 )
		elseif ( errorID == 2 ) then
			guiLabelSetColor( cegui.windows.login.label.password, 220, 55, 55 )
		end
	end
)

addEvent( getResourceName( resource ) .. ":cegui:close", true)
addEventHandler( getResourceName( resource ) .. ":cegui:close", root,
	function( )
		if ( isElement( cegui.windows.login ) ) then
			showCursor( false, false )
			destroyElement( cegui.windows.login )
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( logged_in ) then return end
		
		fadeCamera( true, 2.5 )
		showPlayerHudComponent( "all", false )
		showChat( false )
		
		cegui:showLoginWindow( )
	end
)