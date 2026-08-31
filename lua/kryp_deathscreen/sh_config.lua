KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Temps avant de pouvoir réapparaitre.
Config.RespawnDelay = 45

-- Si activé, utilise GAMEMODE.Config.respawntime quand DarkRP le fournit.
Config.UseDarkRPRespawnTime = false

-- Fond de l'écran de mort.
-- 0 = invisible, 255 = noir complet.
Config.BackgroundAlpha = 232

-- Interface compacte.
Config.PanelWidth = 540
Config.PanelHeight = 220
Config.PanelMinWidth = 420
Config.PanelMaxWidth = 600
Config.PanelScreenWidth = 0.34

-- Couleurs : inspiration SCP discrète, sans surcharger les textes.
Config.AccentColor = Color(172, 42, 42)
Config.AccentSoftColor = Color(94, 28, 28)
Config.PanelColor = Color(10, 11, 13, 244)
Config.PanelInnerColor = Color(18, 19, 22, 238)
Config.TextColor = Color(240, 241, 243)
Config.MutedTextColor = Color(151, 155, 161)

-- Animations.
Config.FadeInDuration = 0.42
Config.FadeOutDuration = 0.32
Config.StartScale = 0.96
Config.EndScale = 1.025

-- Effet du monde derrière l'UI.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.78

-- Textes simples.
Config.DeathTitle = "Vous êtes mort.."
Config.DeathSubtitlePrefix = "Vous allez réapparaitre dans "
Config.DeathSubtitleSuffix = " secondes.."
Config.ReadyMessage = "APPUYEZ SUR UNE TOUCHE"
Config.CreditText = "Réalisateur : Kryp Studio"

-- Réseau.
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
