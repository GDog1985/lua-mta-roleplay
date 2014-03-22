function cursor( player, cursorState, controlState )
	if ( not isElement( player ) ) or ( getElementType( player ) ~= "player" ) then
		outputDebugString( "GAMEPLAY: No player defined.", 1 )
		return false, 1
	elseif ( type( cursorState ) ~= "boolean" ) or ( type( controlState ) ~= "boolean" ) then
		outputDebugString( "GAMEPLAY: Invalid boolean values passed in.", 1 )
		return false, 2
	end
	
	showCursor( player, cursorState, controlState )
	return true
end