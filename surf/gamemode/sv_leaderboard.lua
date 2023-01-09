
util.AddNetworkString("surf_leaderboard")

net.Receive("surf_leaderboard",function(len,ply)
    if not ply.lbspam then ply.lbspam = 0 end
    if ply.lbspam > CurTime() then
        SurfNotify(ply,"[leaderboard]","Please wait before opening the menu again!")
    return
    end
    ply.lbspam = CurTime() + 10
    local map = net.ReadString()
    --move this to sql:
    local res = sql.Query("SELECT * FROM surf_times WHERE map = "..sql.SQLStr(map).." ORDER BY time DESC LIMIT 50")
    if res == false then
        print("[surf][db] ERROR DURING GET LEADERBOARD!")
        ErrorNoHaltWithStack(sql.LastError())
        return nil
    end
    if not res then return nil end
    --return res
    --end of sql move
    net.Start("surf_leaderboard")
        net.WriteString(map)
        net.WriteTable(res)
    net.Send(ply)
end)
