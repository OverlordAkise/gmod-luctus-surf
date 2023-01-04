
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


--temp config

LUCTUS_SURF_PLAYTIME_INTERVAL = 300
LUCTUS_SURF_RTV_PERCENT_NEEDED = 0.5 --50% needed to !rtv for it to kick in
LUCTUS_SURF_MAX_START_VEL = 350
LUCTUS_SURF_RTV_MAPCHANGE_DELAY = 10
LUCTUS_SURF_RTV_VOTE_DURATION = 30
LUCTUS_SURF_RTV_AUTO_TIME = 1800
LUCTUS_SURF_RTV_AUTO_ANTISPAM = 600
LUCTUS_SURF_RTV_VOTE_COOLDOWN = 5
LUCTUS_SURF_COL_ACCENT = Color(100, 100, 200, 255)
LUCTUS_SURF_COL_BG = Color(35, 35, 35)
LUCTUS_SURF_COL_FG = Color(42, 42, 42)
