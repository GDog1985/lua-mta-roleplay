cegui.windows.input.selection = { }
cegui.windows.selection = { }
cegui.windows.selection.window = { }
cegui.windows.selection.label = { }
cegui.windows.selection.edit = { }
cegui.windows.selection.gridlist = { }
cegui.windows.selection.button = { }

local window_width, window_height = 320, 320

function showSelectionWindow( )
	if ( isElement( cegui.windows.selection ) ) then
		triggerEvent( getResourceName( resource ) .. ":cegui:close", localPlayer, "selection" )
		return
	end
	
	if ( not getElementData( localPlayer, "client:username" ) ) then return end
	
	cegui.windows.selection.window.base = guiCreateWindow( ( screen_width - window_width ) / 2, ( screen_height - window_height ) / 2, window_width, window_height, "Character Selection", false )
	guiWindowSetSizable( cegui.windows.selection.window.base, false )
	guiWindowSetMovable( cegui.windows.selection.window.base, false )
	
	cegui.windows.selection.label.header = guiCreateLabel( 30, 40, window_width - 60, 15, "Select a character", false, cegui.windows.selection.window.base )
	cegui.windows.selection.gridlist.characters = guiCreateGridList( 30, 65, window_width - 60, window_height - 180, false, cegui.windows.selection.window.base )
	guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Name", 0.475 )
	guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Last Used", 0.375 )
	
	cegui.windows.selection.button.select = guiCreateButton( 30, 225, window_width - 60, 30, "Select this character", false, cegui.windows.selection.window.base )
	cegui.windows.selection.button.create = guiCreateButton( 30, 270, window_width - 60, 30, "Create a character", false, cegui.windows.selection.window.base )
	
	showCursor( true, true )
end