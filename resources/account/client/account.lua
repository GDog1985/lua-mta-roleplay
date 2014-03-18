addEvent( getResourceName( resource ) .. ":finish", true )
addEventHandler( getResourceName( resource ) .. ":finish", root,
	function( )
		triggerEvent( getResourceName( resource ) .. ":cegui:close", localPlayer )
	end
)