KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Temps avant de pouvoir réapparaitre.
Config.RespawnDelay = 45

-- Si activé, utilise GAMEMODE.Config.respawntime quand DarkRP le fournit.
Config.UseDarkRPRespawnTime = false

-- Fond de l'écran de mort.
-- 0 = invisible, 255 = noir complet.
Config.BackgroundAlpha = 218

-- Interface SCP compacte.
Config.PanelWidth = 560
Config.PanelHeight = 250
Config.PanelMinWidth = 430
Config.PanelMaxWidth = 620
Config.PanelScreenWidth = 0.36

-- Couleurs.
Config.AccentColor = Color(177, 45, 45)
Config.AccentSoftColor = Color(120, 34, 34)
Config.PanelColor = Color(13, 15, 17, 242)
Config.PanelInnerColor = Color(20, 22, 24, 238)
Config.TextColor = Color(236, 238, 240)
Config.MutedTextColor = Color(145, 151, 158)

-- Animations.
Config.FadeInDuration = 0.42
Config.FadeOutDuration = 0.32
Config.StartScale = 0.96
Config.EndScale = 1.025

-- Effet du monde derrière l'UI.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.72

-- Textes.
Config.HeaderText = "SCP FOUNDATION // MEDICAL PROTOCOL"
Config.DeathTitle = "PERSONNEL DÉCÉDÉ"
Config.DeathSubtitle = "RÉANIMATION AUTORISÉE DANS"
Config.ReadyMessage = "AUTORISATION ACCORDÉE — APPUYEZ SUR UNE TOUCHE"
Config.FooterText = "SECURE • CONTAIN • PROTECT"

-- Réseau.
KrypDeathScreen.Net = KrypDeathScreen.Net or {
    Start = "KrypDeathScreen.Start",
    Stop = "KrypDeathScreen.Stop",
    Respawn = "KrypDeathScreen.Respawn"
}
