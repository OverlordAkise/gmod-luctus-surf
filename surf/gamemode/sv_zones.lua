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

function Zones:Setup()
    local zones = sql.Query( "SELECT type, posone, postwo FROM surf_zones WHERE map = "..sql.SQLStr(game.GetMap()))
    if zones == false then
        print("[surfDB] ERROR DURING LOADZONES SQL")
        print(sql.LastError())
        return
    end
    if not zones then
        print("[surfDB] No zones saved in DB!")
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

function Zones:Reload()
    for _,zone in pairs( Zones.Entities ) do
        if IsValid( zone ) then
            zone:Remove()
            zone = nil
        end
    end
    
    Zones.Entities = {}
    
    Zones:Setup()
end

function Zones:GetSpawnPoint( data )
    local vx, vy, vz = 8, 8, 0
    local dx, dy, dz = data[ 2 ].x - data[ 1 ].x, data[ 2 ].y - data[ 1 ].y, data[ 2 ].z - data[ 1 ].z
    
    if dx > 96 then vx = dx - 32 - ((data[ 2 ].x - data[ 1 ].x) / 2) end
    if dy > 96 then vy = dy - 32 - ((data[ 2 ].y - data[ 1 ].y) / 2) end
    if dz > 32 then vz = 16 end
    
    local center = Vector( data[ 3 ].x, data[ 3 ].y, data[ 1 ].z )
    local out = center + Vector( math.random( -vx, vx ), math.random( -vy, vy ), vz )
    
    return out
end
