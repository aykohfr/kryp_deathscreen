if not SERVER then return end

local KDS = KrypDeathScreen
local Config = KDS.Config
local Net = KDS.Net

util.AddNetworkString(Net.Start)
util.AddNetworkString(Net.Stop)
util.AddNetworkString(Net.Respawn)

local deadPlayers = {}

local delayConVar = CreateConVar(
    "kryp_deathscreen_delay",
    tostring(Config.RespawnDelay or 45),
    FCVAR_ARCHIVE,
    "Temps minimum avant respawn avec Kryp Deathscreen.",
    0,
    600
)

local function getRespawnDelay()
    if Config.UseDarkRPRespawnTime and GAMEMODE and GAMEMODE.Config then
        local darkRPDelay = tonumber(GAMEMODE.Config.respawntime)
        if darkRPDelay and darkRPDelay >= 0 then
            return darkRPDelay
        end
    end

    return math.max(0, delayConVar:GetFloat())
end

local function sendStart(ply, delay)
    net.Start(Net.Start)
        net.WriteFloat(delay)
    net.Send(ply)
end

local function sendStop(ply)
    net.Start(Net.Stop)
    net.Send(ply)
end

hook.Add("PlayerDeath", "KrypDeathScreen.Start", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local delay = getRespawnDelay()

    deadPlayers[ply] = {
        readyAt = CurTime() + delay,
        respawning = false
    }

    sendStart(ply, delay)
end)

-- Un retour non-nil empêche le gamemode de gérer son respawn natif.
hook.Add("PlayerDeathThink", "KrypDeathScreen.BlockDefaultRespawn", function(ply)
    if deadPlayers[ply] then
        return false
    end
end)

net.Receive(Net.Respawn, function(_, ply)
    local state = deadPlayers[ply]
    if not state then return end
    if state.respawning then return end
    if ply:Alive() then return end
    if CurTime() < state.readyAt then return end

    state.respawning = true
    ply:UnSpectate()
    ply:Spawn()
end)

hook.Add("PlayerSpawn", "KrypDeathScreen.Stop", function(ply)
    if not deadPlayers[ply] then return end

    deadPlayers[ply] = nil

    timer.Simple(0, function()
        if IsValid(ply) then
            sendStop(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "KrypDeathScreen.Cleanup", function(ply)
    deadPlayers[ply] = nil
end)
