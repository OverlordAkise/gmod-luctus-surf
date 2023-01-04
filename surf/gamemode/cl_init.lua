local ss = SysTime()

include("sh_hook.lua")
include("shared.lua")
include("sh_player_class.lua")
include("cl_hud.lua")
include("cl_scoreboard.lua")
include("cl_rtv.lua")
include("cl_spectate.lua")

local CPlayers = CreateClientConVar("ls_showothers", "1", true, false)
local CCrosshair = CreateClientConVar("ls_crosshair", "1", true, false)
local CTargetID = CreateClientConVar("ls_targetids", "0", true, false)

local HUDItems = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudSuitPower"] = true
}

function GM:HUDShouldDraw(element)
    return not HUDItems[element]
end

hook.Add("CreateMove", "surf_auto_jump", function(cmd)
    if not LocalPlayer():Alive() or LocalPlayer():GetMoveType() ~= MOVETYPE_WALK then return end
    if bit.band( cmd:GetButtons(), IN_JUMP ) ~= 0 then
        if not LocalPlayer():IsOnGround() then
            cmd:SetButtons( bit.band( cmd:GetButtons(), bit.bnot( IN_JUMP ) ) )
        end
    end
end)

hook.Add("OnSpawnMenuOpen","surf_reset_shortcut",function()
    RunConsoleCommand("say","!restart")
end)

cvars.AddChangeCallback("ls_crosshair", function(cvar, prev, new)
    HUDItems["CHudCrosshair"] = new == "0" and true or false
end)

function PlayerVisibility(nTarget)
    local nNew = -1
    if CPlayers:GetInt() == nTarget then
        RunConsoleCommand("ls_showothers", 1 - nTarget)
        timer.Simple( 1, function() RunConsoleCommand("ls_showothers", nTarget) end)
        nNew = nTarget
    elseif nTarget < 0 then
        nNew = 1 - CPlayers:GetInt()
        RunConsoleCommand( "ls_showothers", nNew )
    else
        nNew = nTarget
        RunConsoleCommand( "ls_showothers", nNew )
    end
    
    if nNew >= 0 then
        chat.AddText("You have set player visibility to " .. (nNew == 0 and "invisible" or "visible"))
    end
end

function ToggleChat()
    local nTime = GetConVar("hud_saytext_time"):GetInt()
    if nTime > 0 then
        chat.AddText("The chat has been hidden.")
        RunConsoleCommand( "hud_saytext_time", 0 )
    else
        chat.AddText("The chat has been restored.")
        RunConsoleCommand( "hud_saytext_time", 12 )
    end
end

hook.Add("ChatText", "surf_suppress_joinleavetext", function(nIndex, szName, szText, szID)
    if szID == "joinleave" then return true end
end)


cvars.AddChangeCallback("ls_showothers", function( cvar, prev, new)
    if tonumber(new) == 1 then
        for _,ent in pairs( ents.FindByClass("env_spritetrail") ) do
            ent:SetNoDraw(false)
        end
        for _,ent in pairs( ents.FindByClass("beam") ) do
            ent:SetNoDraw(false)
        end
    else
        for _,ent in pairs( ents.FindByClass("env_spritetrail") ) do
            ent:SetNoDraw(true)
        end
        for _,ent in pairs( ents.FindByClass("beam") ) do
            ent:SetNoDraw(true)
        end
    end
end)

hook.Add("PrePlayerDraw", "surf_player_nodraw", function(ply)
    ply:SetNoDraw(not CPlayers:GetBool())
    if not CPlayers:GetBool() then return true end
end)

hook.Add( "InitPostEntity", "surf_cl_init", function()
    --Optimization
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PreDrawHalos", "PropertiesHover")
    
    HUDItems["CHudCrosshair"] = false
end)

print("[luctus_surf] Loaded cl in "..(SysTime()-ss).."s")
