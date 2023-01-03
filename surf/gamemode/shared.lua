
GM.Name = "Luctus Surf"
GM.DisplayName = GM.Name
GM.ServerName = GM.Name
GM.Author = "OverlordAkise"
GM.Email = ""
GM.Website = "luctus.at"
GM.Version = 1.00
GM.FullPath = "gamemodes/"..GM.FolderName.."/gamemode/"

DeriveGamemode("base")
DEFINE_BASECLASS("gamemode_base")

function GM:PlayerNoClip(ply)
    return ply:IsAdmin()
end

local fl, fo, od, ot = math.floor, string.format, os.date, os.time
function PrettifyTime(ns)
    if ns > 3600 then
        return fo( "%d:%.2d:%.2d.%.3d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
    else
        return fo( "%.2d:%.2d.%.3d", fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 1000 % 1000 ) )
    end
end
