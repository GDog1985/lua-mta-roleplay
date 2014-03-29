cegui = { }
cegui.windows = { }
cegui.windows.input = { }

screen_width, screen_height = guiGetScreenSize( )

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( getElementData( localPlayer, "client:loggedin" ) == 1 ) then return end
		fadeCamera( true, 2.5 )
		showPlayerHudComponent( "all", false )
		showChat( false )
		showLoginWindow( )
	end
)