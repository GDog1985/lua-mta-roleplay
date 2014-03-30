cegui.windows.input.selection = { }
cegui.windows.selection = { }
cegui.windows.selection.window = { }
cegui.windows.selection.label = { }
cegui.windows.selection.edit = { }
cegui.windows.selection.gridlist = { }
cegui.windows.selection.gridlist_c = { }
cegui.windows.selection.button = { }

local window_width, window_height = 320, 320
local response_timeout, pending_tick, response_tick, has_responded = 10000, 0, 0, false

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
	cegui.windows.selection.gridlist.characters = guiCreateGridList( 30, 65, window_width - 60, window_height - 165, false, cegui.windows.selection.window.base )
	cegui.windows.selection.gridlist_c.name = guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Name", 0.475 )
	cegui.windows.selection.gridlist_c.last_used = guiGridListAddColumn( cegui.windows.selection.gridlist.characters, "Last Used", 0.375 )
	
	cegui.windows.selection.button.select = guiCreateButton( 30, 235, window_width - 60, 30, "Select this character", false, cegui.windows.selection.window.base )
	cegui.windows.selection.button.create = guiCreateButton( 30, 275, window_width - 60, 30, "Create a character", false, cegui.windows.selection.window.base )
	
	local function proceedFurther( )
		has_responded = false
		local element = ( ( source ~= cegui.windows.selection.button.select and source ~= cegui.windows.selection.button.create ) and false or true )
		if ( not element ) then return end
		
		local hasErrors
		if ( guiGridListGetSelectedItem( cegui.windows.selection.gridlist.characters ) == -1 ) then
			triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 9, nil, nil, "selection" )
			hasErrors = true
		else
			guiLabelSetColor( cegui.windows.selection.label.header, 255, 255, 255 )
		end
		
		if ( hasErrors ) then return end
		triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 10, nil, nil, "selection" )
		cegui.windows.input.selection.character = guiGridListGetItemText( cegui.windows.selection.gridlist.characters, guiGridListGetSelectedItem( cegui.windows.selection.gridlist.characters ), 1 )
		
		for _,type in pairs( cegui.windows.selection ) do
			for _,element in pairs( type ) do
				if ( isElement( element ) ) then
					guiSetEnabled( element, false )
				end
			end
		end
		
		pending_tick = getTickCount( )
		triggerServerEvent( getResourceName( resource ) .. ":cegui:verify", localPlayer, cegui.windows.input.selection, ( source == cegui.windows.selection.button.select and true or false ) )
	end
	
	addEventHandler( "onClientGUIClick", cegui.windows.selection.button.select, proceedFurther, false )
	--addEventHandler( "onClientGUIClick", cegui.windows.selection.button.create, proceedFurther, false )
	addEventHandler( "onClientRender", root, renderSelectionProcedures )
	triggerServerEvent( getResourceName( resource ) .. ":cegui:characters", localPlayer )
	
	showCursor( true, true )
end

function renderSelectionProcedures( )
	dxDrawRectangle( 0, 0, screen_width, screen_height, tocolor( 0, 0, 0, 0.15 * 255 ), false )
	if ( getTickCount( ) - pending_tick >= response_timeout ) and ( cegui.errors.current ~= 6 ) and ( not has_responded ) and ( pending_tick > 0 ) then
		triggerEvent( getResourceName( resource ) .. ":cegui:error", localPlayer, 6, nil, nil, "selection" )
	end
end

addEvent( getResourceName( resource ) .. ":cegui:characters", true )
addEventHandler( getResourceName( resource ) .. ":cegui:characters", root,
	function( _characters )
		for _,character in pairs( _characters ) do
			local row = guiGridListAddRow( cegui.windows.selection.gridlist.characters )
			guiGridListSetItemText( cegui.windows.selection.gridlist.characters, row, cegui.windows.selection.gridlist_c.name, character.name:gsub( "_", " " ), false, false )
			guiGridListSetItemText( cegui.windows.selection.gridlist.characters, row, cegui.windows.selection.gridlist_c.last_used, ( character.last_login and ( math.abs( character.last_login ) == 0 and "Today" or math.abs( character.last_login ) .. " day" .. ( math.abs( character.last_login ) == 1 and "" or "s" ) .. " ago" ) or "Never" ), false, false )
		end
	end
)