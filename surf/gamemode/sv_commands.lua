
hook.Add("PlayerSay","surf_chat_commands",function(ply,text,team)
    if text == "!r" then
        ply:SetLocalVelocity(Vector(0,0,0))
        ply:SpawnAtSpawn()
        return ""
    end
    if text == "!zonegun" and ply:IsAdmin() then
        ply:Give("weapon_crowbar")
        ply:Give("zone_gun")
    end

    if string.StartWith("!resethighscore",text) and ply:IsAdmin() then
        local sid = string.split(text," ")[2]
        if not sid or not string.find(sid,"STEAM_") then
            ply:PrintMessage(HUD_PRINTTALK, "[admin] Usage: !resethighscore <steamid>")
            return ""
        end
        local res = sql.Query( "DELETE FROM surf_times WHERE map = "..sql.SQLStr(game.GetMap()).." AND sid = "..sql.SQLStr(sid))
        if res == false then
            print("[surfDB] ERROR DURING ADMIN:RESETHIGHSCORE")
            print(sql.LastError())
            return
        end
        local target = player.GetBySteamID(sid)
        target:SetNWFloat( "record", 0 )
        PrintMessage(HUD_PRINTTALK, "[admin] High Score of "..sid.." successfully deleted!")
        return
    end
end)
