cegui = { }
cegui.windows = { }
cegui.windows.input = { }

screen_width, screen_height = guiGetScreenSize( )

function checkCEGUI( )
	if ( getElementData( localPlayer, "client:username" ) ) then
		if ( getElementData( localPlayer, "client:loggedin" ) == 0 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:show", localPlayer, "selection" )
			playRoamer( )
			useCameraRoam( true )
		end
		return
	end
	
	fadeCamera( true, 2.5 )
	showPlayerHudComponent( "all", false )
	showChat( false )
	triggerEvent( getResourceName( resource ) .. ":cegui:show", localPlayer, "login" )
	playRoamer( )
	useCameraRoam( true )
end
addEvent( getResourceName( resource ) .. ":cegui:check", true )
addEventHandler( getResourceName( resource ) .. ":cegui:check", root, checkCEGUI )
addEventHandler( "onClientResourceStart", resourceRoot, checkCEGUI )

addEvent( getResourceName( resource ) .. ":cegui:show", true )
addEventHandler( getResourceName( resource ) .. ":cegui:show", root,
	function( cegui_element )
		if ( cegui_element == "login" ) then
			showLoginWindow( )
		elseif ( cegui_element == "selection" ) then
			showSelectionWindow( )
		end
	end
)

addEvent( getResourceName( resource ) .. ":cegui:close", true)
addEventHandler( getResourceName( resource ) .. ":cegui:close", root,
	function( cegui_element, wasServer, clearErrors )
		for _,type in pairs( cegui.windows[ cegui_element ] ) do
			for _,element in pairs( type ) do
				if ( isElement( element ) ) then
					destroyElement( element, false )
					element = nil
				end
			end
			type = nil
		end
		
		cegui.windows[ cegui_element ] = nil
		showCursor( false, false )
		
		if ( wasServer ) then has_responded = true end
		if ( clearErrors ) then
			cegui.errors.current = nil
			cegui.errors.alternate = nil
		end
		
		if ( cegui_element == "login" ) then
			removeEventHandler( "onClientRender", root, renderLoginProcedures )
		end
	end
)