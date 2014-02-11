local default_charset = get( "default_charset" ) or "latin1"
local default_engine = get( "default_engine" ) or "InnoDB"
local tables = {
	-- name, type, length, default, is_unsigned, is_null, is_auto_increment, key_type
	accounts = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "username", type = "varchar", length = 30, default = "UNd3F1N3D" },
		{ name = "password", type = "varchar", length = 1000, default = "VU5kM0YxTjNE" }
	},
	vehicles = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "model_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rot_x", type = "float", default = 0 },
		{ name = "rot_y", type = "float", default = 0 },
		{ name = "rot_z", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "respawn_pos_x", type = "float", default = 0 },
		{ name = "respawn_pos_y", type = "float", default = 0 },
		{ name = "respawn_pos_z", type = "float", default = 0 },
		{ name = "respawn_rot_x", type = "float", default = 0 },
		{ name = "respawn_rot_y", type = "float", default = 0 },
		{ name = "respawn_rot_z", type = "float", default = 0 },
		{ name = "respawn_interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "respawn_dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "numberplate", type = "varchar", length = 10, default = "UNd3F1N3D" },
		{ name = "variant_1", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "variant_2", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "character_id", type = "int", length = 11, default = 0, is_unsigned = true },
		{ name = "health", type = "smallint", length = 4, default = 1000, is_unsigned = true },
		{ name = "color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0], [ 0, 0, 0 ] ]" },
		{ name = "headlight_color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ] ]" },
		{ name = "headlight_state", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "door_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "panel_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "is_locked", type = "tinyint", length = 1, default = 1, is_unsigned = true },
		{ name = "is_engine_on", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_deleted", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_broken", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_bulletproof", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "created_time", type = "datetime", default = "0000-00-00 00:00:00" },
		{ name = "created_by", type = "int", length = 11, default = 0, is_unsigned = true }
	}
}

local keys = { unique = true, primary = true, index = true }
local function getFormattedKeyType( column_name, key )
	if ( column_name ) and ( keys[ key ] ) then
		return "\r\n" .. ( key ~= "index" and key:upper( ) .. " " or "" ) .. "KEY (`" .. column_name .. "`),"
	end
	return ""
end

function verify_database( table_name )
	if ( table_name ) and ( tables[ table_name ] ) then
		local query = query( "SELECT 1 FROM `??`", table_name )
		if ( query ) then
			return true, 1
		else
			local query_string = "CREATE TABLE IF NOT EXISTS `" .. table_name .. "` ("
			for columnID, columnData in pairs( tables[ table_name ] ) do
				query_string = query_string .. "\r\n`" .. columnData.name .. "` " .. columnData.type .. ( columnData.length and "(" .. columnData.length .. ")" or "" ) .. ( columnData.is_unsigned and " unsigned" or "" ) .. " " .. ( columnData.is_null and "NULL" or "NOT NULL" ) .. ( columnData.default and " DEFAULT '" .. columnData.default .. "'" or "" ) .. ( columnData.is_auto_increment and " AUTO_INCREMENT" or "" ) .. ( #tables[ table_name ] ~= columnID and "," or "" ) .. getFormattedKeyType( columnData.name, columnData.key_type )
			end
			query_string = query_string .. "\r\n) ENGINE=" .. default_engine .. " DEFAULT CHARSET=" .. default_charset .. ";"
			if ( execute( query_string ) ) then
				outputDebugString( "DATABASE: Created table '" .. table_name .. "'." )
				return true, 2
			else
				outputDebugString( "DATABASE: Unable to create table '" .. table_name .. "'.", 2 )
				return false, 2
			end
		end
	end
	return false, 1
end