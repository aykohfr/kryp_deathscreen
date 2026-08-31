KrypDeathScreen = KrypDeathScreen or {}

if SERVER then
    AddCSLuaFile("kryp_deathscreen/sh_config.lua")
    AddCSLuaFile("kryp_deathscreen/cl_deathscreen.lua")
end

include("kryp_deathscreen/sh_config.lua")

if SERVER then
    include("kryp_deathscreen/sv_deathscreen.lua")
else
    include("kryp_deathscreen/cl_deathscreen.lua")
end
