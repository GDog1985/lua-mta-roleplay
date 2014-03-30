local roamPoint, roamTick, roamProgress, roamCamera, roamStatus
local roamX, roamY, roamZ, roamAimX, roamAimY, roamAimZ
local roamPoints = {
	{
		name = "Farm",
		position = {
			x = 50,
			y = 140,
			z = 31,
		},
		aim = {
			x = 6,
			y = -5,
			z = 3
		},
		interior = 0,
		dimension = 0,
		transition = {
			speed = 6000,
			easing = {
				type = "InOutQuad",
				period = nil,
				amplitude = nil,
				overshoot = nil
			}
		},
		wait = 4750
	},
	{
		name = "Los Santos",
		position = {
			x = 1480,
			y = -1711,
			z = 122,
		},
		aim = {
			x = 1300,
			y = -1650,
			z = 85
		},
		interior = 0,
		dimension = 0,
		transition = {
			speed = 6000,
			easing = {
				type = "InOutQuad",
				period = nil,
				amplitude = nil,
				overshoot = nil
			}
		},
		wait = 4750
	},
	{
		name = "San Fierro",
		position = {
			x = -1900,
			y = 407,
			z = 135,
		},
		aim = {
			x = -1980,
			y = 500,
			z = 40,
		},
		interior = 0,
		dimension = 0,
		transition = {
			speed = 6000,
			easing = {
				type = "InOutQuad",
				period = nil,
				amplitude = nil,
				overshoot = nil
			}
		},
		wait = 4750
	}
}

local function roamRenderer( )
	if ( roamPoint ) and ( roamPoints[ roamPoint ] ) and ( roamStatus ) then
		local currentTick = getTickCount( )
		local targetPoint = roamPoints[ roamPoint + 1 ] and roamPoint + 1 or 1
		if ( currentTick - roamTick >= roamPoints[ roamPoint ].wait ) then
			local realRoamTick = roamTick + roamPoints[ roamPoint ].wait
			if ( currentTick - realRoamTick <= roamPoints[ roamPoint ].transition.speed ) then
				roamProgress = math.abs( currentTick - realRoamTick ) / roamPoints[ roamPoint ].transition.speed
				roamAimX, roamAimY, roamAimZ = interpolateBetween( roamPoints[ roamPoint ].aim.x, roamPoints[ roamPoint ].aim.y, roamPoints[ roamPoint ].aim.z, roamPoints[ targetPoint ].aim.x, roamPoints[ targetPoint ].aim.y, roamPoints[ targetPoint ].aim.z, roamProgress, roamPoints[ roamPoint ].transition.easing.type, roamPoints[ roamPoint ].transition.easing.period, roamPoints[ roamPoint ].transition.easing.amplitude, roamPoints[ roamPoint ].transition.easing.overshoot )
				roamX, roamY, roamZ = interpolateBetween( roamPoints[ roamPoint ].position.x, roamPoints[ roamPoint ].position.y, roamPoints[ roamPoint ].position.z, roamPoints[ targetPoint ].position.x, roamPoints[ targetPoint ].position.y, roamPoints[ targetPoint ].position.z, roamProgress, roamPoints[ roamPoint ].transition.easing.type, roamPoints[ roamPoint ].transition.easing.period, roamPoints[ roamPoint ].transition.easing.amplitude, roamPoints[ roamPoint ].transition.easing.overshoot )
			else
				roamTick = getTickCount( )
				roamPoint = targetPoint
			end
		end
		
		if ( roamCamera ) then
			setCameraMatrix( roamX, roamY, roamZ, roamAimX, roamAimY, roamAimZ )
		end
	end
end

local function initializeRoamer( )
	resetRoamer( )
	addEventHandler( "onClientPreRender", root, roamRenderer )
	return true
end

function pauseRoamer( )
	roamStatus = false
	return true
end

function playRoamer( )
	roamStatus = true
	return true
end

function resetRoamer( )
	roamPoint = 1
	roamTick, roamProgress = getTickCount( ), 0
	roamX, roamY, roamZ, roamAimX, roamAimY, roamAimZ = roamPoints[ roamPoint ].position.x, roamPoints[ roamPoint ].position.y, roamPoints[ roamPoint ].position.z, roamPoints[ roamPoint ].aim.x, roamPoints[ roamPoint ].aim.y, roamPoints[ roamPoint ].aim.z
	return true
end

function useCameraRoam( state )
	roamCamera = ( type( state ) == "boolean" and state or not roamCamera )
	return roamCamera
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		initializeRoamer( )
	end
)

addEvent( getResourceName( resource ) .. ":roamer:pause", true )
addEventHandler( getResourceName( resource ) .. ":roamer:pause", root,
	function( )
		pauseRoamer( )
	end
)

addEvent( getResourceName( resource ) .. ":roamer:play", true )
addEventHandler( getResourceName( resource ) .. ":roamer:play", root,
	function( )
		playRoamer( )
	end
)

addEvent( getResourceName( resource ) .. ":roamer:reset", true )
addEventHandler( getResourceName( resource ) .. ":roamer:reset", root,
	function( )
		resetRoamer( )
	end
)

addEvent( getResourceName( resource ) .. ":roamer:camera", true )
addEventHandler( getResourceName( resource ) .. ":roamer:camera", root,
	function( state )
		useCameraRoam( state )
	end
)