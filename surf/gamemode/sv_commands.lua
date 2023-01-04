surf_usercmds = {
    ["restart"] = function(ply,args)
        ply:SetLocalVelocity(Vector(0,0,0))
        SpawnPlyAtStart(ply)
        return ""
    end,
    ["spec"] = function(ply,args)
        ply.spectating = not ply.spectating
        if ply.spectating then
            LuctusTimerStop(ply)
            --start spectating
            ply.specmode = OBS_MODE_ROAMING
            ply:Spectate(ply.specmode)
            ply:StripWeapons()
            ply:SetNWBool("spectating",true)
        else
            --stop spectating
            ply:UnSpectate()
            ply:Spawn()
            ply:SetNWBool("spectating",false)
            if IsValid(player.GetAll()[ply.spectarget]) then
                spectatorKeys[player.GetAll()[ply.spectarget]] = math.max(spectatorKeys[player.GetAll()[ply.spectarget]]-1,0)
            end
            ply.spectarget = nil
        end
    end,
    ["spectate"] = surf_usercmds["spec"],
    ["s"] = surf_usercmds["spec"],
}

hook.Add("PlayerSay","surf_commands",function(ply,text,team)
    if string.StartWith(text,"/") or string.StartWith(text,"!") then
        local cmd = string.Right(text,string.len(text)-1)
        local argStr = cmd
        if string.find(cmd," ") then
            cmd = string.Split(argStr," ")[1]
            argStr = string.Split(text,cmd.." ")[2]
        end
        if surf_usercmds[cmd] then
            return surf_usercmds[cmd](ply,argStr)
        end
    end
end)
