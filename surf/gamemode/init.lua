local ss = SysTime()

include("sh_hook.lua")
include("shared.lua")
include("sh_player_class.lua")
include("sv_defaultzones.lua")
include("sv_sql.lua")
include("sv_timer.lua")
include("sv_zones.lua")
include("sv_commands.lua")
include("sv_admin.lua")
include("sv_rtv.lua")
include("sv_spectate.lua")
include("sv_playtime.lua")

AddCSLuaFile("sh_hook.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_player_class.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_rtv.lua")
AddCSLuaFile("cl_spectate.lua")

function GM:Initialize()
    --im stuff
end

hook.Add( "InitPostEntity", "surf_sv_init", function()
    SQL:InitDB()
    Zones:Setup()
    RunConsoleCommand("sv_airaccelerate","1000")
    RunConsoleCommand("sv_accelerate","10")
    RunConsoleCommand("sv_friction","8")
    RunConsoleCommand("sv_sticktoground","0")
    RunConsoleCommand("sv_maxvelocity", "90000")
    RunConsoleCommand("sv_gravity", "525")
    --Optimization
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PreDrawHalos", "PropertiesHover")
end)

function GM:PlayerSpawn(ply)
    player_manager.SetPlayerClass(ply, "player_surf")
    self.BaseClass:PlayerSpawn(ply)
    ply:SetTeam(1)
    ply:SetModel("models/player/group01/male_01.mdl")
    ply:SetNoCollideWithTeammates(true)
    ply:SetAvoidPlayers(false)
    ply:ResetTimer()
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SpawnAtSpawn()
    ply:Give("hands")
end

function GM:PlayerInitialSpawn(ply)
    ply:LoadBestTime()
end

function GM:CanPlayerSuicide() return true end
function GM:PlayerShouldTakeDamage() return false end
function GM:GetFallDamage() return false end
function GM:PlayerCanHearPlayersVoice(listener, talker)
    if talker.ismuted then return false end
    return true
end
function GM:IsSpawnpointSuitable() return true end
function GM:PlayerDeathThink(ply) end

function GM:PlayerCanPickupWeapon(ply, weapon)
    if ply.WeaponStripped then return false end
    return true
end

function GM:EntityTakeDamage(ent, dmg)
    if ent:IsPlayer() then return false end
    return self.BaseClass:EntityTakeDamage(ent, dmg)
end

function GM:PlayerUse(ply)
    if not ply:Alive() then return false end
    if ply.isSpectating then return false end
    if ply:GetMoveType() ~= MOVETYPE_WALK then return false end
    return true
end

print("[luctus_surf] Loaded sv in "..(SysTime()-ss).."s")
