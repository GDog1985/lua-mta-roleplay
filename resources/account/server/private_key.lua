local private_key_characters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "_", ".", ",", ":", ";", "*", "/", "@", "%" }
local private_key_length = 32
local private_key = ""

local function generateFullServerPrivateKey( )
	local private_file = fileCreate( "@vault/server.private.mcrt" )
	if ( private_file ) then
		local string, private_temp_key, time = "", "", getRealTime( )
		for i=1,private_key_length do
			local random_case, character = math.random( 0, 3 ), private_key_characters[ math.random( #private_key_characters ) ]
			string = string .. ( random_case == 1 and character:upper( ) or character )
		end
		private_temp_key = teaEncode( md5( getServerName( ) .. getServerPort( ) ) .. sha512( string .. md5( time.timestamp ) .. time.monthday .. time.yearday ), md5( time.timestamp .. getDistanceBetweenPoints3D( math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ) ) ) )
		fileWrite( private_file, private_temp_key )
		fileClose( private_file )
		fileCopy( "@vault/server.private.mcrt", "@:__backup/account/vault/server.private." .. time.monthday .. time.month + 1 .. time.year .. time.hour .. time.minute .. time.second .. ".mcrt" )
		private_key = private_temp_key
		return true
	end
	return false
end

local function performProcedures( )
	if ( generateFullServerPrivateKey( ) ) then
		outputServerLog( "ACCOUNT: Generated a new server private key. Make sure to save and keep a copy of this file somewhere. If this file is lost, your accounts will become unusable." )
	else
		outputServerLog( "ACCOUNT: Something went wrong when creating a new server private key. Please verify that you have given full write permissions for this resource and its subfolders. Server must now be shut down, because server private key is required." )
		for _,resource in ipairs( getResources( ) ) do
			if ( getResourceState( resource ) == "running" ) then
				stopResource( resource )
			end
		end
		shutdown( "Something went wrong when creating a new server private key. Please verify that you have given full write permissions for this resource and its subfolders. Server must now be shut down, because server private key is required." )
	end
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if ( not fileExists( "vault/server.private.mcrt" ) ) then
			performProcedures( )
		else
			local private_file = fileOpen( "@vault/server.private.mcrt" )
			if ( not private_file ) or ( ( private_file ) and ( fileGetSize( private_file ) == 0 ) ) then
				fileClose( private_file )
				generateFullServerPrivateKey( )
			else
				local file_data = fileRead( private_file, fileGetSize( private_file ) )
				if ( #file_data >= 100 ) then
					private_key = file_data
					fileClose( private_file )
				else
					outputServerLog( "ACCOUNT: Something is wrong right now. Recreating server private key, consider migrating database accounts." )
					performProcedures( )
				end
			end
		end
	end
)