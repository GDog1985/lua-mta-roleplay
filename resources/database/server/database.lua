local database_type = get( "connection_type" ) or "mysql"
local database_file = get( "database_file" ) or "database"
local database_batch = get( "database_batch" ) or 0
local database_log = get( "database_log" ) or 1
local database_tag = get( "database_tag" ) or "script"

local hostname = get( "hostname" ) or "127.0.0.1"
local username = get( "username" ) or "root"
local password = get( "password" ) or "root"
local database = get( "database" ) or "mta_server"

local connection = nil

local function connect( )
	connection = dbConnect( database_type, ( database_type == "sqlite" and database_file or "dbname=" .. database .. ";host=" .. hostname ), ( database_type == "sqlite" and "" or username ), ( database_type == "sqlite" and "" or password ), "share=1;batch=" .. database_batch .. ";log=" .. database_log .. ";tag=" .. database_tag )
	
	if ( connection ) then
		outputDebugString( "DATABASE: Database connection initialized." )
		return true, connection
	end
	
	outputDebugString( "DATABASE: Database connection could not be initialized.", 2 )
	return false
end
addEventHandler( "onResourceStart", resourceRoot, connect )

local function disconnect( restart_requested )
	if ( connection ) then
		destroyElement( connection )
		outputDebugString( "DATABASE: Database connection destroyed." )
		
		if ( restart_requested ) then
			outputDebugString( "DATABASE: Database connection restart pending." )
			connect( )
		end
		
		return true
	end
	
	outputDebugString( "DATABASE: Database connection is not alive and could not be destroyed.", 2 )
	return false
end

function ping( )
	if ( connection ) then
		if ( query( "SELECT NULL" ) ) then
			return true
		end
	end
	
	return false
end

function query( query_string, ... )
	if ( not query_string ) then
		outputDebugString( "DATABASE: Database query string missing.", 1 )
		return false, 1
	end
	
	if ( connection ) then
		local query = dbQuery( connection, query_string, ... )
		if ( query ) then
			local result, num_affected_rows, last_insert_id = dbPoll( query, -1 )
			if ( result == false ) then
				local error_code, error_msg = num_affected_rows, last_insert_id
				dbFree( query )
				outputDebugString( "DATABASE: Database query failed - (errno " .. error_code .. "; error: " .. error_msg .. ").", 1 )
				return false
			else
				return result, num_affected_rows, last_insert_id
			end
			return true
		end
	end
	return false
end

function execute( query_string, ... )
	if ( not query_string ) then
		outputDebugString( "DATABASE: Database query string missing.", 1 )
		return false, 1
	end
	
	if ( connection ) then
		local parameters = { ... }
		local query = dbExec( connection, query_string, parameters )
		if ( query ) then
			return true
		end
	end
	
	return false
end

function insert_id( query_string, ... )
	if ( not query_string ) then
		outputDebugString( "DATABASE: Database query string missing.", 1 )
		return false, 1
	end
	
	if ( connection ) then
		local parameters = { ... }
		local query = dbQuery( connection, query_string, parameters )
		if ( query ) then
			local result, num_affected_rows, last_insert_id = dbPoll( query, -1 )
			if ( result == false ) then
				local error_code, error_msg = num_affected_rows, last_insert_id
				dbFree( query )
				outputDebugString( "DATABASE: Database query failed - (errno " .. error_code .. "; error: " .. error_msg .. ").", 1 )
				return false
			else
				return last_insert_id
			end
			return true
		end
	end
	
	return false
end

function free_result( query )
	if ( not query ) then
		outputDebugString( "DATABASE: Database query handler missing.", 1 )
		return false, 1
	end
	
	if ( dbFree( query ) ) then
		return true
	end
	
	return false
end