addEventHandler( "onResourceStart", resourceRoot,
	function( )
		outputDebugString( "VEHICLE: Loading vehicles in 10,000 ms." )
		setTimer( loadVehicles, 10000, 1 )
	end
)

function loadVehicles( )
	local query, num_affected_rows = exports.database:query( "SELECT * FROM `vehicles` WHERE `is_deleted` = ?", 0 )
	if ( query ) then
		for rowID,row in pairs( query ) do
			new( row.id )
		end
		outputDebugString( "VEHICLE: Loaded " .. num_affected_rows .. " " .. ( num_affected_rows == 1 and "vehicle" or "vehicles" ) .. " from the database." )
	end
end