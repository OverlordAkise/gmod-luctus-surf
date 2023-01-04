--ULIB'S HOOK LIBRARY
--MADE BY ULYSSES AND BORROWED FOR PERFORMANCE
--https://github.com/TeamUlysses/ulib/blob/master/lua/ulib/shared/hook.lua

if hook.GetULibTable then return end

local gmod			= gmod
local pairs			= pairs
local isfunction	= isfunction
local isstring		= isstring
local isnumber		= isnumber
local math			= math
local IsValid		= IsValid

HOOK_MONITOR_HIGH = -2
HOOK_HIGH = -1
HOOK_NORMAL = 0
HOOK_LOW = 1
HOOK_MONITOR_LOW = 2

local OldHooks = hook.GetTable()

module( "hook" )

local Hooks = {}
local BackwardsHooks = {}

function GetTable() return BackwardsHooks end
function GetULibTable() return Hooks end

function Add( event_name, name, func, priority )
	priority = priority or 0
	if ( !isfunction( func ) ) then return end
	if ( !isstring( event_name ) ) then return end
	if ( !isnumber( priority ) ) then return end

	priority = math.floor( priority )
	if ( priority < -2 ) then priority = -2 end -- math.Clamp may not have been defined yet
	if ( priority > 2 ) then priority = 2 end

	Remove( event_name, name ) -- This keeps the event name unique, even among the priorities

	if (Hooks[ event_name ] == nil) then
		Hooks[ event_name ] = {[-2]={}, [-1]={}, [0]={}, [1]={}, [2]={}}
		BackwardsHooks[ event_name ] = {}
	end

	Hooks[ event_name ][ priority ][ name ] = { fn=func, isstring=isstring( name ) }
	BackwardsHooks[ event_name ][ name ] = func -- Keep the classic style too so we won't break anything
end

function Remove( event_name, name )

	if ( !isstring( event_name ) ) then return end
	if ( !Hooks[ event_name ] ) then return end

	for i=-2, 2 do
		Hooks[ event_name ][ i ][ name ] = nil
	end

	BackwardsHooks[ event_name ][ name ] = nil

end

function Run( name, ... )
	return Call( name, gmod and gmod.GetGamemode() or nil, ... )
end

function Call( name, gm, ... )

	local HookTable = Hooks[ name ]
	if ( HookTable != nil ) then

		for i=-2, 2 do

			for k, v in pairs( HookTable[ i ] ) do

				if ( v.isstring ) then

					--
					-- If it's a string, it's cool
					--
					local a, b, c, d, e, f = v.fn( ... )
					if ( a != nil && i > -2 && i < 2 ) then
						return a, b, c, d, e, f
					end

				else

					if ( IsValid( k ) ) then
						local a, b, c, d, e, f = v.fn( k, ... )
						if ( a != nil && i > -2 && i < 2 ) then
							return a, b, c, d, e, f
						end
					else
						HookTable[ i ][ k ] = nil
					end
				end
			end
		end
	end
	if ( !gm ) then return end

	local GamemodeFunction = gm[ name ]
	if ( GamemodeFunction == nil ) then return end

	return GamemodeFunction( gm, ... )

end

for event_name, t in pairs( OldHooks ) do
	for name, func in pairs( t ) do
		Add( event_name, name, func )
	end
end
