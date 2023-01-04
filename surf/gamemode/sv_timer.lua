
function LuctusTimerCanPlySurf(ply)
    if ply.spectating then return false end
    return true
end

function SpawnPlyAtStart(ply)
    local plyAng = ply:EyeAngles()
    plyAng.r = 0--fix surf_mesa bug
    ply:SetEyeAngles(plyAng)
    if Zones.StartPoint then
        ply:SetPos(LuctusZonesGetSpawnpoint(Zones.StartPoint))
    end
    if ply:GetMoveType() != MOVETYPE_WALK then
        ply:SetMoveType(MOVETYPE_WALK)
    end
end

function LuctusTimerStart(ply)
    if not LuctusTimerCanPlySurf(ply) then return end
    local vel2d = ply:GetVelocity():Length2D()
    if vel2d > LUCTUS_SURF_MAX_START_VEL then
        ply:SetLocalVelocity(Vector(0, 0, 0))
        SpawnPlyAtStart(ply)
        SurfNotify(ply,"[surf]","You can't leave the zone with "..math.ceil( vel2d ).." u/s",true,"ambient/alarms/warningbell1.wav")
    end
    ply:SetNWFloat("starttime",CurTime())
end

function LuctusTimerStop(ply)
    ply:SetNWFloat("starttime",0)
end

function LuctusTimerFinish(ply)
    if not LuctusTimerCanPlySurf(ply) then return end
    local nTime = CurTime() - ply:GetNWFloat("starttime",0)
    
    local szMessage = "TimerFinish"
    local nDifference = ply:GetNWFloat( "record", 0 ) > 0 and nTime - ply:GetNWFloat( "record", 0 ) or nil
    local szSlower = nDifference and (" (" .. (nDifference < 0 and "-" or "+") .. string.ToMinutesSecondsMilliseconds( math.abs( nDifference ) ) .. ")") or ""
    SurfNotify(nil,"[surf]",ply:Nick().." completed the map in "..string.ToMinutesSecondsMilliseconds(nTime).."!",true)
    LuctusDbAddMapPlay()
    if GiveCredit then
        GiveCredit(ply,1)
    end
    local oldRecord = ply:GetNWFloat( "record", 0 )
    ply:SetNWFloat("starttime",0)
    if oldRecord ~= 0 and nTime >= oldRecord then return end
    
    ply:SetNWFloat( "record", nTime )
    print("[surf][timer] Player",ply,ply:SteamID(),"has achieved a new record time for map ",game.GetMap(),"with a time of",nTime)
    LuctusDbSavePlyRecord(ply,nTime,oldRecord)
end
