Zones = {}
Zones.Type = {
    ["Normal Start"] = 0,
    ["Normal End"] = 1,
    ["Bonus Start"] = 2,
    ["Bonus End"] = 3,
    ["Anticheat"] = 4,
    ["Restart"] = 5
}

Zones.StartPoint = nil

Zones.Cache = {}
Zones.Entities = {}

function LuctusZonesSetup()
    local zones = sql.Query( "SELECT type, posone, postwo FROM surf_zones WHERE map = "..sql.SQLStr(game.GetMap()))
    if zones == false then
        print("[surf][db] ERROR DURING LOADZONES SQL")
        print(sql.LastError())
        return
    end
    if not zones then
        print("[surf][db] No zones saved in DB, no zones spawned!")
        return
    end
    
    Zones.Cache = {}
    for _,data in pairs( zones ) do
        table.insert( Zones.Cache, {
            Type = tonumber( data[ "type" ] ),
            P1 = util.StringToType( tostring( data[ "posone" ] ), "Vector" ),
            P2 = util.StringToType( tostring( data[ "postwo" ] ), "Vector" )
        } )
    end
    Zones.StartPoint = nil
    Zones.BonusPoint = nil

    for _,zone in pairs( Zones.Cache ) do
        local ent = ents.Create( "game_timer" )
        ent:SetPos( (zone.P1 + zone.P2) / 2 )
        ent.min = zone.P1
        ent.max = zone.P2
        ent.zonetype = zone.Type
        
        if zone.Type == Zones.Type["Normal Start"] then
            Zones.StartPoint = { zone.P1, zone.P2, (zone.P1 + zone.P2) / 2 }
        end
        
        ent:Spawn()
        table.insert( Zones.Entities, ent )
    end
end

function LuctusZonesReload()
    for _,zone in pairs( Zones.Entities ) do
        if IsValid( zone ) then
            zone:Remove()
            zone = nil
        end
    end
    
    Zones.Entities = {}
    
    LuctusZonesSetup()
end

function LuctusZonesGetSpawnpoint(data)
    local vx, vy, vz = 8, 8, 0
    local dx, dy, dz = data[ 2 ].x - data[ 1 ].x, data[ 2 ].y - data[ 1 ].y, data[ 2 ].z - data[ 1 ].z
    
    if dx > 96 then vx = dx - 32 - ((data[ 2 ].x - data[ 1 ].x) / 2) end
    if dy > 96 then vy = dy - 32 - ((data[ 2 ].y - data[ 1 ].y) / 2) end
    if dz > 32 then vz = 16 end
    
    local center = Vector( data[ 3 ].x, data[ 3 ].y, data[ 1 ].z )
    local out = center + Vector( math.random( -vx, vx ), math.random( -vy, vy ), vz )
    
    return out
end

--Zonegun sends new zone
net.Receive("surf_setzone",function(len,ply)
    print("[surf][zones] Received new message!")
    if not ply:IsAdmin() then return end
    if ply:GetActiveWeapon():GetClass() ~= "zone_gun" then return end
    local action = net.ReadInt(4) --action = zonetype, if -1 = reload zones
    if action == -1 then
        LuctusZonesReload()
        SurfNotify(ply,"[zones]","Zones reloaded!")
        return
    end
    local zones = ply:GetActiveWeapon().Zone
    if not zones.First or not zones.Second then
        SurfNotify(ply,"[zones]","Error: First or Second zone point missing!")
        return
    end
    zones.First = zones.First
    zones.Second = zones.Second + Vector(0,0,128)
    
    if action ~= -1 and action ~= 1 and action ~= 0 then return end
    print("[surf][zones] Checks done, Got new Zone info! Updating...")
    local res = nil
    if action > -1 then
        LuctusDbDeleteZone(action)
        local success = LuctusDbInsertZone(action, zones.First, zones.Second)
        if success then
            print("[surf][zones] New Zone for map "..game.GetMap().." (type "..action..") successfully inserted!")
            SurfNotify(ply,"[zones]","Successfully saved new zone!")
        else
            print("[surf][zones] Error: New Zone for map "..game.GetMap().." (type "..action..") not saved!")
            SurfNotify(ply,"[zones]","Error during saving!")
        end
    end
end)
