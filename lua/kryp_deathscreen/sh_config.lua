KrypDeathScreen = KrypDeathScreen or {}
KrypDeathScreen.Config = KrypDeathScreen.Config or {}

local Config = KrypDeathScreen.Config

-- Temps avant de pouvoir réapparaitre.
Config.RespawnDelay = 45

-- Si activé, utilise GAMEMODE.Config.respawntime quand DarkRP le fournit.
Config.UseDarkRPRespawnTime = false

-- Fond général.
Config.BackgroundAlpha = 235

-- Bloc central.
Config.PanelWidth = 760
Config.PanelHeight = 250
Config.PanelMinWidth = 520
Config.PanelMaxWidth = 860
Config.PanelScreenWidth = 0.52
Config.PanelRadius = 18

-- Couleurs.
Config.PanelColor = Color(8, 8, 10, 185)
Config.PanelSoftColor = Color(16, 16, 20, 160)
Config.TextColor = Color(255, 255, 255)
Config.MutedTextColor = Color(220, 220, 220)
Config.GlowColor = Color(255, 255, 255)

-- Animations.
Config.FadeInDuration = 0.42
Config.FadeOutDuration = 0.32
Config.StartScale = 0.97
Config.EndScale = 1.02

-- Effet du monde derrière l'UI.
Config.EnableWorldEffect = true
Config.WorldEffectStrength = 0.82

-- Textes.
Config.DeathTitle = "VOUS ÊTES MORT."
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
