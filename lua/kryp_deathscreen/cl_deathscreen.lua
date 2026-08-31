if not CLIENT then return end

local KDS = KrypDeathScreen
local Config = KDS.Config
local Net = KDS.Net

local deathMaterial
local imageAvailable = false
local imageDownloading = false

local state = {
    visible = false,
    leaving = false,
    requested = false,
    readyAt = 0,
    startedAt = 0,
    leaveAt = 0,
    sequence = 0
}

local function createFonts()
    surface.CreateFont("KrypDeathScreen.Countdown", {
        font = "Roboto",
        size = math.Clamp(math.floor(ScrH() * 0.036), 28, 52),
        weight = 800,
        antialias = true
    })

    surface.CreateFont("KrypDeathScreen.Ready", {
        font = "Roboto",
        size = math.Clamp(math.floor(ScrH() * 0.019), 18, 30),
        weight = 600,
        antialias = true
    })

    surface.CreateFont("KrypDeathScreen.FallbackTitle", {
        font = "Roboto",
        size = math.Clamp(math.floor(ScrH() * 0.042), 32, 58),
        weight = 900,
        antialias = true
    })
end

createFonts()
hook.Add("OnScreenSizeChanged", "KrypDeathScreen.Fonts", createFonts)

local function loadCachedImage()
    if not file.Exists(Config.CacheFile, "DATA") then return false end

    deathMaterial = Material("data/" .. Config.CacheFile, "smooth")
    imageAvailable = deathMaterial and not deathMaterial:IsError()

    return imageAvailable
end

local function downloadImage(force)
    if imageDownloading then return end

    if force then
        file.Delete(Config.CacheFile)
        deathMaterial = nil
        imageAvailable = false
    elseif loadCachedImage() then
        return
    end

    imageDownloading = true
    file.CreateDir("kryp_deathscreen")

    http.Fetch(Config.ImageURL,
        function(body, size, _, code)
            imageDownloading = false

            if code < 200 or code >= 300 or not body or size <= 0 then
                return
            end

            if not file.Write(Config.CacheFile, body) then
                return
            end

            deathMaterial = Material("data/" .. Config.CacheFile, "smooth")
            imageAvailable = deathMaterial and not deathMaterial:IsError()
        end,
        function()
            imageDownloading = false
        end
    )
end

downloadImage(false)

concommand.Add("kryp_deathscreen_refresh", function()
    downloadImage(true)
end)

local function clamp01(value)
    return math.Clamp(value, 0, 1)
end

local function easeOutCubic(value)
    value = clamp01(value)
    return 1 - ((1 - value) ^ 3)
end

local function getAnimation()
    if state.leaving then
        local duration = math.max(Config.FadeOutDuration, 0.01)
        local progress = easeOutCubic((RealTime() - state.leaveAt) / duration)
        return 1 - progress, Lerp(progress, 1, Config.EndScale)
    end

    local duration = math.max(Config.FadeInDuration, 0.01)
    local progress = easeOutCubic((RealTime() - state.startedAt) / duration)
    return progress, Lerp(progress, Config.StartScale, 1)
end

local function getImageRect(scaleAnimation)
    local width = math.Clamp(
        ScrW() * Config.ImageScreenWidth,
        Config.ImageMinWidth,
        Config.ImageMaxWidth
    )

    local nativeW = 1000
    local nativeH = 500

    if imageAvailable and deathMaterial then
        nativeW = math.max(deathMaterial:Width(), 1)
        nativeH = math.max(deathMaterial:Height(), 1)
    end

    local height = width * (nativeH / nativeW)
    width = width * scaleAnimation
    height = height * scaleAnimation

    return (ScrW() - width) * 0.5, (ScrH() - height) * 0.5, width, height
end

local function drawFallback(x, y, w, h, alpha, remaining)
    local boxW = math.min(w, 620)
    local boxH = 190
    local bx = x + (w - boxW) * 0.5
    local by = y + (h - boxH) * 0.5

    draw.RoundedBox(18, bx, by, boxW, boxH, Color(10, 10, 12, 225 * alpha))
    draw.SimpleText("VOUS ÊTES MORT", "KrypDeathScreen.FallbackTitle", ScrW() * 0.5, by + 55, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Dans " .. remaining .. " secondes", "KrypDeathScreen.Ready", ScrW() * 0.5, by + 118, Color(220, 220, 225, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "KrypDeathScreen.Draw", function()
    if not state.visible then return end

    local alpha, scaleAnimation = getAnimation()
    if alpha <= 0 then return end

    local x, y, w, h = getImageRect(scaleAnimation)
    local remaining = math.max(0, math.ceil(state.readyAt - CurTime()))

    if imageAvailable and deathMaterial then
        surface.SetDrawColor(255, 255, 255, 255 * alpha)
        surface.SetMaterial(deathMaterial)
        surface.DrawTexturedRect(x, y, w, h)

        local countdownX = x + (w * Config.CountdownX)
        local countdownY = y + (h * Config.CountdownY)

        draw.SimpleText(
            tostring(remaining),
            "KrypDeathScreen.Countdown",
            countdownX,
            countdownY,
            Color(255, 255, 255, 255 * alpha),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    else
        drawFallback(x, y, w, h, alpha, remaining)
    end

    if remaining <= 0 then
        local messageY = y + h + Config.ReadyMessageOffset

        draw.SimpleText(
            Config.ReadyMessage,
            "KrypDeathScreen.Ready",
            ScrW() * 0.5,
            messageY,
            Color(255, 255, 255, 255 * alpha),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
end)

hook.Add("RenderScreenspaceEffects", "KrypDeathScreen.WorldEffect", function()
    if not state.visible or not Config.EnableWorldEffect then return end

    local alpha = select(1, getAnimation()) * Config.WorldEffectStrength
    if alpha <= 0 then return end

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.055 * alpha,
        ["$pp_colour_contrast"] = 1 - (0.16 * alpha),
        ["$pp_colour_colour"] = 1 - (0.76 * alpha),
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)

local function requestRespawn()
    if not state.visible or state.leaving or state.requested then return end
    if CurTime() < state.readyAt then return end

    state.requested = true

    net.Start(Net.Respawn)
    net.SendToServer()
end

-- Détecte tous les BUTTON_CODE côté client en multijoueur.
hook.Add("PlayerButtonDown", "KrypDeathScreen.AnyButton", function(ply)
    if ply ~= LocalPlayer() then return end
    if not IsFirstTimePredicted() then return end
    requestRespawn()
end)

-- Fallback clavier, notamment utile lorsque PlayerButtonDown n'est pas disponible.
hook.Add("CreateMove", "KrypDeathScreen.AnyKeyboardKey", function()
    if not state.visible or state.leaving or state.requested then return end
    if CurTime() < state.readyAt then return end

    for key = KEY_FIRST + 1, KEY_LAST do
        if input.WasKeyPressed(key) then
            requestRespawn()
            return
        end
    end
end)

net.Receive(Net.Start, function()
    local delay = math.max(0, net.ReadFloat())

    state.sequence = state.sequence + 1
    state.visible = true
    state.leaving = false
    state.requested = false
    state.readyAt = CurTime() + delay
    state.startedAt = RealTime()
    state.leaveAt = 0

    if not imageAvailable then
        downloadImage(false)
    end
end)

net.Receive(Net.Stop, function()
    if not state.visible then return end

    state.sequence = state.sequence + 1
    local sequence = state.sequence

    state.leaving = true
    state.leaveAt = RealTime()

    timer.Simple(Config.FadeOutDuration + 0.05, function()
        if state.sequence ~= sequence then return end

        state.visible = false
        state.leaving = false
        state.requested = false
    end)
end)
