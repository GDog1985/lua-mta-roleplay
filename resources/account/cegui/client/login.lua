cegui = { }
cegui.windows = { }
cegui.windows.input = { }
cegui.windows.input.login = { }
cegui.windows.login = { }
cegui.windows.login.window = { }
cegui.windows.login.label = { }
cegui.windows.login.edit = { }
cegui.windows.login.button = { }
cegui.errors = { }
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
	{ "Please refrain from spamming the login form.", tocolor( 210, 120, 33, 185 ), "WARNING: " }
}

local screen_width, screen_height = guiGetScreenSize( )
local window_width, window_height = 320, 320

local logged_in = false
local response_timeout, pending_tick, response_tick, has_responded = 10000, 0, 0, false

function showLoginWindow( )
	if ( isElement( cegui.windows.login ) ) then
		triggerEvent( getResourceName( resource ) .. ":cegui:close", localPlayer )
		removeEventHandler( "onClientRender", root, showNotificationBox )
		return
	end
	
	if ( logged_in ) then return end
	
	cegui.windows.login.window.base = guiCreateWindow( ( screen_width - window_width ) / 2, ( screen_height - window_height ) / 2, window_width, window_height, "Log In or Register", false )
	guiWindowSetSizable( cegui.windows.login.window.base, false )
	guiWindowSetMovable( cegui.windows.login.window.base, false )
	
	cegui.windows.login.label.username = guiCreateLabel( 30, 50, window_width - 60, 15, "Username", false, cegui.windows.login.window.base )
	cegui.windows.login.edit.username = guiCreateEdit( 30, 75, window_width - 60, 30, "", false, cegui.windows.login.window.base )
	
	cegui.windows.login.label.password = guiCreateLabel( 30, 120, window_width - 60, 15, "Password", false, cegui.windows.login.window.base )
	cegui.windows.login.edit.password = guiCreateEdit( 30, 145, window_width - 60, 30, "", false, cegui.windows.login.window.base )
	guiEditSetMasked( cegui.windows.login.edit.password, true )
	
	cegui.windows.login.button.login = guiCreateButton( 30, 215, window_width - 60, 30, "Log in", false, cegui.windows.login.window.base )
	cegui.windows.login.button.register = guiCreateButton( 30, 260, window_width - 60, 30, "Register", false, cegui.windows.login.window.base )
	
	local function proceedFurther( )
		local element = ( ( source ~= cegui.windows.login.button.login and source ~= cegui.windows.login.button.register ) and false or true )
		if ( not element ) then return end
		cegui.windows.input.login.username, cegui.windows.input.login.password = guiGetText( cegui.windows.login.edit.username ), guiGetText( cegui.windows.login.edit.password )
		
		local hasErrors
		if ( cegui.windows.input.login.password:len( ) <= 6 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 2 )
			hasErrors = true
			cegui.errors.current = 2
		else
			guiLabelSetColor( cegui.windows.login.label.password, 255, 255, 255 )
		end
		
		if ( cegui.windows.input.login.username:len( ) <= 2 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 1 )
			hasErrors = true
			cegui.errors.current = 1
		else
			guiLabelSetColor( cegui.windows.login.label.username, 255, 255, 255 )
		end
		
		if ( hasErrors ) then return end
		cegui.errors.current = 5
		
		for _,type in pairs( cegui.windows.login ) do
			for _,element in pairs( type ) do
				if ( isElement( element ) ) then
					guiSetEnabled( element, false )
				end
			end
		end
		
		triggerServerEvent( getResourceName( resource ) .. ":cegui:verify", localPlayer, cegui.windows.input.login, ( source == cegui.windows.login.button.login and true or false ) )
		pending_tick = getTickCount( )
		
		addEventHandler( "onClientRender", root,
			function( )
				if ( has_responded ) then return end
				if ( getTickCount( ) - pending_tick >= response_timeout ) then
					cegui.errors.current = 6
				end
			end
		)
	end
	addEventHandler( "onClientGUIClick", cegui.windows.login.button.login, proceedFurther, false )
	addEventHandler( "onClientGUIClick", cegui.windows.login.button.register, proceedFurther, false )
	
	showCursor( true, true )
	addEventHandler( "onClientRender", root, showNotificationBox )
end

function showNotificationBox( )
	if ( not isElement( cegui.windows.login.window.base ) ) or ( logged_in ) or ( not cegui.errors.current ) then return end
	local text = ( cegui.errors.alternate and cegui.errors.phrases[ cegui.errors.current ][ 4 ][ cegui.errors.alternate ] or cegui.errors.phrases[ cegui.errors.current ][ 3 ] .. cegui.errors.phrases[ cegui.errors.current ][ 1 ] )
	local text_width, text_height = dxGetTextWidth( text ), dxGetFontHeight( )
	dxDrawRectangle( 0, screen_height - 40, screen_width, screen_height, cegui.errors.phrases[ cegui.errors.current ][ 2 ] )
	dxDrawText( text, ( screen_width - text_width ) / 2 + 1, screen_height - 40 + 16, text_width, text_height, tocolor( 4, 4, 4, 85 ) )
	dxDrawText( text, ( screen_width - text_width ) / 2, screen_height - 40 + 15, text_width, text_height, tocolor( 240, 240, 240, 200 ) )
end

addEvent( getResourceName( resource ) .. ":cegui:error", true)
addEventHandler( getResourceName( resource ) .. ":cegui:error", root,
	function( errorID, alternateErrorID )
		cegui.errors.current = errorID
		cegui.errors.alternate = nil
		
		if ( errorID ~= nil ) then
			cegui.errors.alternate = ( not alternateErrorID and nil or alternateErrorID )
			
			if ( errorID == 1 ) or ( errorID == 4 ) then
				guiLabelSetColor( cegui.windows.login.label.username, 220, 55, 55 )
			elseif ( errorID == 2 ) then
				guiLabelSetColor( cegui.windows.login.label.password, 220, 55, 55 )
			end
			
			for _,type in pairs( cegui.windows.login ) do
				for _,element in pairs( type ) do
					if ( isElement( element ) ) then
						guiSetEnabled( element, true )
					end
				end
			end
			
			has_responded = true
		end
	end
)

addEvent( getResourceName( resource ) .. ":cegui:close", true)
addEventHandler( getResourceName( resource ) .. ":cegui:close", root,
	function( )
		for _,type in pairs( cegui.windows.login ) do
			for _,element in pairs( type ) do
				if ( isElement( element ) ) then
					destroyElement( element, false )
					element = nil
				end
			end
			type = nil
		end
		
		cegui.windows.login = nil
		showCursor( false, false )
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( logged_in ) then return end
		fadeCamera( true, 2.5 )
		showPlayerHudComponent( "all", false )
		showChat( false )
		showLoginWindow( )
	end
)