AddCSLuaFile()

if SERVER then
    util.AddNetworkString("surf_setzone")
end

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "ZoneTan"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Author = "OverlordAkise"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "R to Save Zones, LMB to place start, RMB to place end"
SWEP.Category = "Skill Surf"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Zone = {}
SWEP.Zone.First = nil
SWEP.Zone.Second = nil

function SWEP:Reload()
    if CLIENT then
        if not self.r or not IsValid(self.r) then
            self.r = Derma_Query(
            "Before you click something here be sure to setup your Zone correctly with LMB and RMB!",
            "Admin Zone Gun",
            "Save Zone as Start", function()self:SendZone(0)end,
            "Save Zone as End", function()self:SendZone(1)end,
            "Reload Zones", function()self:SendZone(-1)end
            )
        end
    end
end

if CLIENT then
    function SWEP:SendZone(id)
        net.Start("surf_setzone")
            net.WriteInt(id,4)
        net.SendToServer()
    end
end

if SERVER then
    net.Receive("surf_setzone",function(len,ply)
        if not ply:IsAdmin() then return end
        if ply:GetActiveWeapon():GetClass() ~= "zone_gun" then return end
        local zones = ply:GetActiveWeapon().Zone
        if not zones.First or not zones.Second then return end
        zones.First = zones.First
        zones.Second = zones.Second + Vector(0,0,128)
        local action = net.ReadInt(4)
        if action ~= -1 and action ~= 1 and action ~= 0 then return end
        print("[surf] Got new Zone info! Updating...")
        local res = nil
        if action > -1 then
            sql.Query("DELETE FROM surf_zones WHERE map = "..sql.SQLStr(game.GetMap()).." AND type = "..action)
            res = sql.Query("INSERT INTO surf_zones VALUES ("..sql.SQLStr(game.GetMap())..","..action..", "..sql.SQLStr(zones.First)..", "..sql.SQLStr(zones.Second)..")")
            if res == false then
                print("[surfDB] ERROR DURING ZONE_GUN INSERT SURF_ZONES!")
                print(sql.LastError())
                return
            end
            print("[surf] New Zone for map "..game.GetMap().." (type "..action..") successfully inserted!")
            ply:PrintMessage(HUD_PRINTTALK, "[surfDB] Successfully saved new zone!")
        else
            Zones:Reload()
        end
    end)
end

function SWEP:Think()
end

function SWEP:Deploy()
    self:SetHoldType("pistol")
    if CLIENT then
        hook.Add("PostDrawOpaqueRenderables","surf_zone_display",function()
            if self.Zone and self.Zone.First then
                local Col = COLOR_BLACK
                local Start = self.Zone.First
                local End = self.Zone.Second or LocalPlayer():GetEyeTrace().HitPos
                local Min = Vector(math.min(Start.x, End.x), math.min(Start.y, End.y), math.min(Start.z, End.z))
                local Max = Vector(math.max(Start.x, End.x), math.max(Start.y, End.y), math.max(Start.z + 128, End.z + 128))
                local B1, B2, B3, B4 = Vector(Min.x, Min.y, Min.z), Vector(Min.x, Max.y, Min.z), Vector(Max.x, Max.y, Min.z), Vector(Max.x, Min.y, Min.z)
                local T1, T2, T3, T4 = Vector(Min.x, Min.y, Max.z), Vector(Min.x, Max.y, Max.z), Vector(Max.x, Max.y, Max.z), Vector(Max.x, Min.y, Max.z)
                render.DrawLine( B1, B2, Col, true )
                render.DrawLine( B2, B3, Col, true )
                render.DrawLine( B3, B4, Col, true )
                render.DrawLine( B4, B1, Col, true )

                render.DrawLine( T1, T2, Col, true )
                render.DrawLine( T2, T3, Col, true )
                render.DrawLine( T3, T4, Col, true )
                render.DrawLine( T4, T1, Col, true )

                render.DrawLine( B1, T1, Col, true )
                render.DrawLine( B2, T2, Col, true )
                render.DrawLine( B3, T3, Col, true )
                render.DrawLine( B4, T4, Col, true )
            end
        end)
    end
    return true
end

function SWEP:Holster()
    if CLIENT then
        hook.Remove("PostDrawOpaqueRenderables","surf_zone_display")
    end
    self.Zone = {}
    self.Zone.First = nil
    self.Zone.Second = nil
    return true
end

function SWEP:PrimaryAttack()
    self.Zone.First = self:GetOwner():GetEyeTrace().HitPos
end

function SWEP:SecondaryAttack()
    self.Zone.Second = self:GetOwner():GetEyeTrace().HitPos
end
