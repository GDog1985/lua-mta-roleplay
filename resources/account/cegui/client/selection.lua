cegui.windows.input.selection = { }
cegui.windows.selection = { }
cegui.windows.selection.window = { }
cegui.windows.selection.label = { }
cegui.windows.selection.edit = { }
cegui.windows.selection.gridlist = { }
cegui.windows.selection.gridlist_c = { }
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
	cegui.windows.selection.gridlist_c.name = guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Name", 0.475 )
	cegui.windows.selection.gridlist_c.last_used = guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Last Used", 0.375 )
	
	cegui.windows.selection.button.select = guiCreateButton( 30, 225, window_width - 60, 30, "Select this character", false, cegui.windows.selection.window.base )
	cegui.windows.selection.button.create = guiCreateButton( 30, 270, window_width - 60, 30, "Create a character", false, cegui.windows.selection.window.base )
	
	triggerServerEvent( getResourceName( resource ) .. ":cegui:characters", localPlayer )
	
	showCursor( true, true )
end

addEvent( getResourceName( resource ) .. ":cegui:characters", true )
addEventHandler( getResourceName( resource ) .. ":cegui:characters", root,
	function( _characters )
		for _,character in pairs( _characters ) do
			local row = guiGridListAddRow( cegui.windows.selection.gridlist.characters )
			guiGridListSetItemText( cegui.windows.selection.gridlist.characters, row, cegui.windows.selection.gridlist_c.name, character.name:gsub( "_", " " ), false, false )
			guiGridListSetItemText( cegui.windows.selection.gridlist.characters, row, cegui.windows.selection.gridlist_c.last_used, ( math.abs( character.last_login ) == 0 and "Today" or math.abs( character.last_login ) .. " day" .. ( math.abs( character.last_login ) == 1 and "" or "s" ) .. " ago" ), false, false )
		end
	end
)