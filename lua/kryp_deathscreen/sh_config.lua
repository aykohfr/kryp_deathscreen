KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Temps avant de pouvoir réapparaitre.
Config.RespawnDelay = 45

-- Si activé, utilise GAMEMODE.Config.respawntime quand DarkRP le fournit.
Config.UseDarkRPRespawnTime = false

-- Fond de l'écran de mort.
-- 0 = invisible, 255 = noir complet.
Config.BackgroundAlpha = 238

-- Interface compacte.
Config.PanelWidth = 620
Config.PanelHeight = 245
Config.PanelMinWidth = 460
Config.PanelMaxWidth = 700
Config.PanelScreenWidth = 0.40
Config.PanelRadius = 14

-- Couleurs.
Config.AccentColor = Color(188, 48, 48)
Config.AccentSoftColor = Color(102, 27, 27)
Config.AccentGlowColor = Color(215, 64, 64)

Config.PanelColor = Color(10, 11, 13, 245)
Config.PanelInnerColor = Color(17, 19, 22, 240)
Config.PanelInnerSoftColor = Color(24, 26, 30, 220)

Config.TextColor = Color(242, 243, 245)
Config.MutedTextColor = Color(155, 160, 168)

-- Animations.
Config.FadeInDuration = 0.42
Config.FadeOutDuration = 0.32
Config.StartScale = 0.96
Config.EndScale = 1.025

-- Effet du monde derrière l'UI.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.82

-- Textes.
Config.DeathTitle = "Vous êtes mort.."
Config.DeathSubtitlePrefix = "Vous allez réapparaitre dans"
Config.DeathSubtitleSuffix = "secondes.."
Config.ReadyMessage = "APPUYEZ SUR UNE TOUCHE"
Config.CreditText = "Réalisateur : Kryp Studio"

-- Réseau.
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
