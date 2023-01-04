AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
    local BBOX = (self.max - self.min) / 2

    self:SetSolid( SOLID_BBOX )
    self:PhysicsInitBox( -BBOX, BBOX )
    self:SetCollisionBoundsWS( self.min, self.max )

    self:SetTrigger( true )
    self:DrawShadow( false )
    self:SetNotSolid( true )
    self:SetNoDraw( false )

    self.Phys = self:GetPhysicsObject()
    if self.Phys and self.Phys:IsValid() then
        self.Phys:Sleep()
        self.Phys:EnableCollisions( false )
    end

    self:SetZoneType( self.zonetype )
end

function ENT:StartTouch(ent)
    if IsValid(ent) and ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR then
        local zone = self:GetZoneType()
        if zone == self.Zone.MStart then
            LuctusTimerStop(ent)
        elseif zone == self.Zone.MEnd and ent:GetNWFloat("starttime",0) ~= 0 then
            LuctusTimerFinish(ent)
        elseif zone == self.Zone.AC then
            LuctusTimerStop(ent)
        elseif zone == self.Zone.Restart then
            LuctusTimerStop(ent)
            SpawnPlyAtStart(ent)
        end
    end
end

function ENT:EndTouch(ent)
    if IsValid(ent) and ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR then
        local zone = self:GetZoneType()
        if zone == self.Zone.MStart then
            LuctusTimerStart(ent)
        end
    end
end
