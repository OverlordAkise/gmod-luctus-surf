local PLAYER = FindMetaTable( "Player" )

Timer = {}

function PLAYER:IsSurfing()
    if self.isTraining then return false end
    if self.spectating then return false end
    return true
end

function PLAYER:LoadBestTime()
    self:SetNWInt( "style", 1 )
    self:SetNWFloat( "record", 0 )
    local res = sql.Query("SELECT * FROM surf_times WHERE sid = "..sql.SQLStr(self:SteamID()).." AND map = "..sql.SQLStr(game.GetMap()))
    if res == false then
        print("[surfDB] ERROR DURING Player:LoadBestTime!")
        print(sql.LastError())
        return
    end
    if res and res[1] then
        self:SetNWFloat("record",tonumber(res[1]["time"]))
        print("[surfDB] Successfully set record time for player "..self:Nick())
    end
end

function PLAYER:SpawnAtSpawn()
    local plyAng = self:EyeAngles()
    plyAng.r = 0--fix surf_mesa bug
    self:SetEyeAngles(plyAng)
    if Zones.StartPoint then
        self:SetPos(Zones:GetSpawnPoint(Zones.StartPoint))
    end
    if self:GetMoveType() != MOVETYPE_WALK then
        self:SetMoveType( MOVETYPE_WALK )
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

function PLAYER:StopAnyTimer()
    if not self:IsSurfing() then return end
    self:SetNWFloat("starttime",0)
end

function Timer:Finish( ply, nTime )
    local szMessage = "TimerFinish"
    local nDifference = ply:GetNWFloat( "record", 0 ) > 0 and nTime - ply:GetNWFloat( "record", 0 ) or nil
    local szSlower = nDifference and (" (" .. (nDifference < 0 and "-" or "+") .. string.ToMinutesSecondsMilliseconds( math.abs( nDifference ) ) .. ")") or ""
    PrintMessage(HUD_PRINTTALK, ply:Nick().." completed the map in "..string.ToMinutesSecondsMilliseconds(nTime).."!")
    Timer:AddPlay()
    if GiveCredit then
        GiveCredit(ply,1)
    end
    local OldRecord = ply:GetNWFloat( "record", 0 )
    if OldRecord ~= 0 and nTime >= OldRecord then return end
    
    ply:SetNWFloat( "record", nTime )

    Timer:AddRecord( ply, nTime, OldRecord )
end


-- Records

function Timer:AddRecord( ply, newtime, oldtime )
    local res = sql.Query( "DELETE FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()).." AND sid = "..sql.SQLStr(ply:SteamID()))
    res = sql.Query("INSERT INTO surf_times(sid, nick, map, style, time, date) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:Nick())..","..sql.SQLStr(game.GetMap())..",1,"..newtime..",datetime('now'))")
    if res == false then
        print("[surfDB] ERROR DURING TIMER:ADDRECORD ADDING")
        print(sql.LastError())
        return
    end
    ply:PrintMessage(HUD_PRINTTALK, "You completed the map in a new personal record time!")
    place_one = sql.Query("SELECT COUNT(*) AS c FROM surf_times WHERE time > "..newtime.." AND map = "..sql.SQLStr(game.GetMap()))
    place_all = sql.Query("SELECT COUNT(*) AS c FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()))
    if place_one == false or place_all == false then
        print("[surfDB] ERROR DURING TIMER:ADDRECORD COUNTING")
        print(sql.LastError())
        return
    end
    ply:PrintMessage(HUD_PRINTTALK, "Your time is place "..(1-place_one[1]["c"]).."/"..place_all[1]["c"].." on this map!")
end

function Timer:AddPlay()
    sql.Query("UPDATE surf_map SET runs = runs + 1 WHERE map = "..sql.SQLStr(game.GetMap()))
end
