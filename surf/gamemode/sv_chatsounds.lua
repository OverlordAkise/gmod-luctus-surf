--this is purely for fun, not-required for the gamemode

util.AddNetworkString("surf_chatsound")

surf_chatsounds = {
    ["vineboom"] = "https://luctus.at/fastdl/csounds/vineboom.mp3",
}

concommand.Add("lsas", function(ply,cmd,args,argStr)
    if IsValid(ply) and not ply:IsAdmin() then return end
    local chatStr = args[1]
    local url = args[2]
    surf_chatsounds[chatStr] = url
end)

hook.Add("PlayerSay","surf_chatsounds",function(ply,text,team)
    if surf_chatsounds[text] then
        BroadcastChatsound(surf_chatsounds[text])
    end
end)

function BroadcastChatsound(text)
    net.Start("surf_chatsound")
        net.WriteString(text)
    net.Broadcast()
end
