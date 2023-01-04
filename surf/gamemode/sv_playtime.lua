
hook.Add("PlayerInitialSpawn","surf_playtime_load",function(ply)
    ply:SetNWInt("playtime",0)
    LuctusDbPlaytimeLoad(ply)
    
    timer.Create(ply:SteamID().."_playtime",LUCTUS_SURF_PLAYTIME_INTERVAL,0,function()
        if not IsValid(ply) then return end
        ply:SetNWInt("playtime",ply:GetNWInt("playtime")+LUCTUS_SURF_PLAYTIME_INTERVAL)
        LuctusDbPlaytimeSave(ply:SteamID(),ply:GetNWInt("playtime"))
    end)
end)

hook.Add("PlayerDisconnect","surf_playtime_save",function(ply)
    if timer.Exists(ply:SteamID().."_playtime") then
        local playtimeLeft = timer.TimeLeft(ply:SteamID().."_playtime")
        local playtimeNew = ply:GetNWInt("playtime",0) + (LUCTUS_SURF_PLAYTIME_INTERVAL - playtimeLeft)
        LuctusDbPlaytimeSave(ply:SteamID(),playtimeNew)
    end
end)
