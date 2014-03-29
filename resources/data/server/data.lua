local protection_prefix = "U29031m4142930F"

addEventHandler( "onElementDataChange", root,
	function( key, old_value )
		if ( not client ) then return end
		local data = getElementData( source, key )
		local data_protected = getElementData( source, protection_prefix .. ":" .. key )
		if ( data_protected ) then
			setElementData( source, key, old_value, true )
		end
	end
)

function unprotect( element, key )
	setElementData( element, protection_prefix .. ":" .. key, false, true )
end

function protect( element, key )
	setElementData( element, protection_prefix .. ":" .. key, true, true )
end

addEventHandler( "onPlayerJoin", root,
	function( )
		protect( source, "client:loggedin" )
	end
)