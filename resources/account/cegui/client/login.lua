cegui.windows.input.login = { }
cegui.windows.login = { }
cegui.windows.login.window = { }
cegui.windows.login.label = { }
cegui.windows.login.edit = { }
cegui.windows.login.button = { }

local window_width, window_height = 320, 320
local response_timeout, pending_tick, response_tick, has_responded = 10000, 0, 0, false

function showLoginWindow( )
	if ( isElement( cegui.windows.login ) ) then
		triggerEvent( getResourceName( resource ) .. ":cegui:close", localPlayer, "login" )
		return
	end
	
	if ( getElementData( localPlayer, "client:username" ) ) then return end
	
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
		has_responded = false
		local element = ( ( source ~= cegui.windows.login.button.login and source ~= cegui.windows.login.button.register ) and false or true )
		if ( not element ) then return end
		cegui.windows.input.login.username, cegui.windows.input.login.password = guiGetText( cegui.windows.login.edit.username ), guiGetText( cegui.windows.login.edit.password )
		
		local hasErrors
		if ( cegui.windows.input.login.password:len( ) <= 6 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 2 )
			hasErrors = true
		else
			guiLabelSetColor( cegui.windows.login.label.password, 255, 255, 255 )
		end
		
		if ( cegui.windows.input.login.username:len( ) <= 2 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 1 )
			hasErrors = true
		else
			guiLabelSetColor( cegui.windows.login.label.username, 255, 255, 255 )
		end
		
		if ( hasErrors ) then return end
		triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 5 )
		
		for _,type in pairs( cegui.windows.login ) do
			for _,element in pairs( type ) do
				if ( isElement( element ) ) then
					guiSetEnabled( element, false )
				end
			end
		end
		
		pending_tick = getTickCount( )
		triggerServerEvent( getResourceName( resource ) .. ":cegui:verify", localPlayer, cegui.windows.input.login, ( source == cegui.windows.login.button.login and true or false ) )
	end
	
	addEventHandler( "onClientGUIClick", cegui.windows.login.button.login, proceedFurther, false )
	addEventHandler( "onClientGUIClick", cegui.windows.login.button.register, proceedFurther, false )
	addEventHandler( "onClientRender", root, renderLoginProcedures )
	
	showCursor( true, true )
end

function renderLoginProcedures( )
	dxDrawRectangle( 0, 0, screen_width, screen_height, tocolor( 0, 0, 0, 0.15 * 255 ), false )
	if ( getTickCount( ) - pending_tick >= response_timeout ) and ( cegui.errors.current ~= 6 ) and ( not has_responded ) and ( pending_tick > 0 ) then
		triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 6 )
	end
end