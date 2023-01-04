AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.Zone = {
    MStart = 0,
    MEnd = 1,
    BStart = 2,
    BEnd = 3,
    AC = 4,
    Restart = 5
}

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "ZoneType" )
end
