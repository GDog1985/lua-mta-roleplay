local vehicles = { }

function new( vehicle_id, model_id, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, interior, dimension, respawn_pos_x, respawn_pos_y, respawn_pos_z, respawn_rot_x, respawn_rot_y, respawn_rot_z, respawn_interior, respawn_dimension, numberplate, variant_1, variant_2, character_id )
	local vehicle_id, model_id, pos_x, pos_y, pos_z, vehicle_data = tonumber( vehicle_id ), tonumber( model_id ), tonumber( pos_x ), tonumber( pos_y ), tonumber( pos_z ), { }
	
	if ( not vehicle_id ) and ( ( not model_id ) or ( not pos_x ) or ( not pos_y ) or ( not pos_z ) ) then
		outputDebugString( "Missing arguments.", 1 )
		return false, 1
	end
	
	if ( vehicle_id ) then
		if ( vehicle_id > 0 ) then
			local data = exports.database:query( "SELECT * FROM `vehicles` WHERE `id` = ? LIMIT 1", vehicle_id )
			if ( data ) then
				vehicle_data = {
					id = data.id,
					model_id = data.model_id,
					pos_x = data.pos_x,
					pos_y = data.pos_y,
					pos_z = data.pos_z,
					rot_x = data.rot_x,
					rot_y = data.rot_y,
					rot_z = data.rot_z,
					interior = data.interior,
					dimension = data.dimension,
					respawn_pos_x = data.respawn_pos_x,
					respawn_pos_y = data.respawn_pos_y,
					respawn_pos_z = data.respawn_pos_z,
					respawn_rot_x = data.respawn_rot_x,
					respawn_rot_y = data.respawn_rot_y,
					respawn_rot_z = data.respawn_rot_z,
					respawn_interior = data.respawn_interior,
					respawn_dimension = data.respawn_dimension,
					numberplate = data.numberplate,
					variant_1 = data.variant_1,
					variant_2 = data.variant_2,
					character_id = data.character_id
				}
			end
		else
			outputDebugString( "Invalid vehicle ID " .. vehicle_id .. ".", 1 )
			return false, 2
		end
	else
		if ( getVehicleNameFromModel( model_id ) ) then
			local numberplate = ( numberplate or exports.utility:generate( ) )
			local id = exports.database:insert_id( "INSERT INTO `vehicles` ( `model_id`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `interior`, `dimension`, `respawn_pos_x`, `respawn_pos_y`, `respawn_pos_z`, `respawn_rot_x`, `respawn_rot_z`, `respawn_interior`, `respawn_dimension`, `numberplate`, `variant_1`, `variant_2`, `character_id`, `created_time` ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW( ) )", model_id, pos_x, pos_y, pos_z, ( rot_x or 0 ), ( rot_y or 0 ), ( rot_z or 0 ), ( interior or 0 ), ( dimension or 0 ), ( respawn_pos_x or pos_x ), ( respawn_pos_y or pos_y ), ( respawn_pos_z or pos_z ), ( respawn_rot_x or ( rot_x or 0 ) ), ( respawn_rot_y or ( rot_y or 0 ) ), ( respawn_rot_z or ( rot_z or 0 ) ), ( respawn_interior or ( interior or 0 ) ), ( respawn_dimension or ( dimension or 0 ) ), numberplate, ( variant_1 or 255 ), ( variant_2 or 255 ), ( character_id or 0 ) )
			if ( id ) then
				vehicle_data = {
					id = id,
					model_id = model_id,
					pos_x = pos_x,
					pos_y = pos_y,
					pos_z = pos_z,
					rot_x = ( rot_x or 0 ),
					rot_y = ( rot_y or 0 ),
					rot_z = ( rot_z or 0 ),
					interior = ( interior or 0 ),
					dimension = ( dimension or 0 ),
					respawn_pos_x = ( respawn_pos_x or ( pos_x or 0 ) ),
					respawn_pos_y = ( respawn_pos_y or ( pos_y or 0 ) ),
					respawn_pos_z = ( respawn_pos_z or ( pos_z or 0 ) ),
					respawn_rot_x = ( respawn_rot_x or ( rot_x or 0 ) ),
					respawn_rot_y = ( respawn_rot_y or ( rot_y or 0 ) ),
					respawn_rot_z = ( respawn_rot_z or ( rot_z or 0 ) ),
					respawn_interior = ( respawn_interior or ( interior or 0 ) ),
					respawn_dimension = ( respawn_dimension or ( dimension or 0 ) ),
					numberplate = numberplate,
					variant_1 = ( variant_1 or 255 ),
					variant_2 = ( variant_2 or 255 ),
					character_id = ( character_id or 0 )
				}
			else
				outputDebugString( "Unable to insert vehicle to database.", 1 )
				return false, 4
			end
		else
			outputDebugString( "Invalid model ID " .. model_id .. ".", 1 )
			return false, 3
		end
	end
	
	if ( #vehicle_data > 0 ) then
		vehicles[ vehicle_data.id ] = vehicle_data
		vehicles[ vehicle_data.id ].vehicle = createVehicle( vehicle_data.model_id, vehicle_data.pos_x, vehicle_data.pos_y, vehicle_data.pos_z, vehicle_data.rot_x, vehicle_data.rot_y, vehicle_data.rot_z, vehicle_data.numberplate, false, vehicle_data.variant_1, vehicle_data.variant_2 )
		return vehicles[ vehicle_data.id ]
	end
	
	return false
end

function get( vehicle_id )
	local vehicle_id = tonumber( vehicle_id )
	
	if ( not vehicle_id ) then
		outputDebugString( "No vehicle ID defined.", 1 )
		return false, 1
	end
	
	return ( vehicles[ vehicle_id ] or false )
end

function delete( vehicle_id, permanently )
	if ( not vehicle_id ) then
		outputDebugString( "No vehicle ID defined.", 1 )
		return false, 1
	end
	
	if ( vehicles[ vehicle_id ] ) then
		if ( not permanently ) then
			if ( exports.database:execute( "UPDATE `vehicles` SET `is_deleted` = ? WHERE `id` = ?", 1, tonumber( vehicle_id ) ) ) then
				return true
			end
		else
			if ( exports.database:execute( "DELETE FROM `vehicles` WHERE `id` = ?", tonumber( vehicle_id ) ) ) then
				return true
			end
		end
		
		if ( isElement( vehicles[ vehicle_id ].vehicle ) ) then
			destroyElement( vehicles[ vehicle_id ].vehicle )
		end
		
		vehicles[ vehicle_id ] = nil
	end
	
	return false
end