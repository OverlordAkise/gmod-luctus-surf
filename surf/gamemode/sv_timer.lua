local PLAYER = FindMetaTable( "Player" )

Timer = {}

function PLAYER:IsSurfing()
    if self.isTraining then return false end
    if self.spectating then return false end
    return true
end

function PLAYER:SpawnAtSpawn()
    local plyAng = self:EyeAngles()
    plyAng.r = 0--fix surf_mesa bug
    self:SetEyeAngles(plyAng)
    if Zones.StartPoint then
        self:SetPos(Zones:GetSpawnPoint(Zones.StartPoint))
    end
    if self:GetMoveType() != MOVETYPE_WALK then
        self:SetMoveType(MOVETYPE_WALK)
    end
end

function PLAYER:StartTimer()
    if not self:IsSurfing() then return end
    local vel2d = self:GetVelocity():Length2D()
    if vel2d > LUCTUS_SURF_MAX_START_VEL then
        self:SetLocalVelocity(Vector(0, 0, 0))
        self:SpawnAtSpawn()
        self:PrintMessage(HUD_PRINTTALK, "[surf] You can't leave the zone with "..math.ceil( vel2d ).." u/s")
    end
    self:SetNWFloat("starttime",CurTime())
end

function PLAYER:ResetTimer()
    self:SetNWFloat("starttime",0)
end

function PLAYER:StopTimer()
    if not self:IsSurfing() then return end
    Timer:Finish( self, CurTime() - self:GetNWFloat("starttime",0))
    self:SetNWFloat("starttime",0)
end

function PLAYER:KillTimer()
    self:SetNWFloat("starttime",0)
end

function Timer:Finish( ply, nTime )
    local szMessage = "TimerFinish"
    local nDifference = ply:GetNWFloat( "record", 0 ) > 0 and nTime - ply:GetNWFloat( "record", 0 ) or nil
    local szSlower = nDifference and (" (" .. (nDifference < 0 and "-" or "+") .. string.ToMinutesSecondsMilliseconds( math.abs( nDifference ) ) .. ")") or ""
    PrintMessage(HUD_PRINTTALK, ply:Nick().." completed the map in "..string.ToMinutesSecondsMilliseconds(nTime).."!")
    LuctusDbAddMapPlay()
    if GiveCredit then
        GiveCredit(ply,1)
    end
    local oldRecord = ply:GetNWFloat( "record", 0 )
    if oldRecord ~= 0 and nTime >= oldRecord then return end
    
    ply:SetNWFloat( "record", nTime )
    print("[surf][timer] Player",ply,ply:SteamID(),"has achieved a new record time for map ",game.GetMap(),"with a time of",nTime)
    LuctusDbSavePlyRecord(ply,nTime,oldRecord)
end
