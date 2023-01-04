surf_usercmds = {
    ["restart"] = function(ply,args)
        ply:SetLocalVelocity(Vector(0,0,0))
        ply:SpawnAtSpawn()
        return ""
    end,
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
