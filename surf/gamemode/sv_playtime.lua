
PLAYTIME_DELAY = 300

hook.Add("InitPostEntity","surf_playtime_db_init",function()
    sql.Query("CREATE TABLE IF NOT EXISTS surf_playtime (steamid TEXT, playtime INTEGER )")
end)

hook.Add("PlayerInitialSpawn","surf_playtime_load",function(ply)
    local playtime = sql.QueryValue("SELECT playtime FROM surf_playtime WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    ply:SetNWInt("playtime",0)
    if not playtime then
        sql.Query("INSERT INTO surf_playtime(steamid, playtime) VALUES("..sql.SQLStr(ply:SteamID())..",0)")
        return
    end
    ply:SetNWInt("playtime",tonumber(playtime))
    timer.Create(ply:SteamID().."_playtime",PLAYTIME_DELAY,0,function()
        ply:SetNWInt("playtime",ply:GetNWInt("playtime")+PLAYTIME_DELAY)
        local res = sql.Query("UPDATE surf_playtime SET playtime = "..ply:GetNWInt("playtime").." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
        if res == false then
            print("[surfDB] ERROR DURING PLAYTIME UPDATE!")
            print(sql.LastError())
        end
    end)
end)

hook.Add("PlayerInitialSpawn","surf_playtime_save",function(ply)
    if timer.Exists(ply:SteamID().."_playtime") then
        local playtimeLeft = timer.TimeLeft(ply:SteamID().."_playtime")
        local playtimeNow = ply:GetNWInt("playtime",0) + (PLAYTIME_DELAY - playtimeLeft)
        local res = sql.Query("UPDATE surf_playtime SET playtime = "..playtimeNow.." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
        if res == false then
            print("[surfDB] ERROR DURING PLAYTIME DISCONNECT UPDATE!")
            print(sql.LastError())
        end
    end
end)
