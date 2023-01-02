AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

local Zone = {
    MStart = 0,
    MEnd = 1,
    BStart = 2,
    BEnd = 3,
    AC = 4,
    Restart = 5
}

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
        if zone == Zone.MStart then
            ent:ResetTimer()
        elseif zone == Zone.MEnd and ent:GetNWFloat("starttime",0) ~= 0 then
            ent:StopTimer()
        elseif zone == Zone.AC then
            ent:StopAnyTimer()
        elseif zone == Zone.Restart then
            ent:RestartPlayer()
        end
    end
end

function ENT:EndTouch(ent)
    if IsValid(ent) and ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR then
        local zone = self:GetZoneType()
        if zone == Zone.MStart then
            ent:StartTimer()
        end
    end
end
