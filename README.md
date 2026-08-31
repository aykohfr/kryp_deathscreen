# Kryp Deathscreen

Deathscreen Garry's Mod / DarkRP entièrement dessiné en Lua, avec une interface compacte inspirée de l'univers SCP, compte à rebours serveur et respawn manuel.

## Fonctionnement

- Aucune image distante et aucune dépendance Imgur.
- Interface SCP native dessinée directement avec le HUD Garry's Mod.
- Fond fortement assombri tout en laissant le monde légèrement visible.
- Compte à rebours synchronisé avec le serveur.
- Bloque le respawn natif pendant le compte à rebours.
- À la fin du délai, affiche une autorisation de réanimation et demande d'appuyer sur une touche.
- Le serveur revalide le délai avant d'autoriser le respawn.
- Animation d'entrée à la mort et animation de sortie au respawn.
- Effet de désaturation et d'assombrissement du monde.

## Installation

Le dépôt correspond directement au dossier de l'addon :

```text
garrysmod/addons/kryp_deathscreen/
├── lua/
│   ├── autorun/
│   │   └── kryp_deathscreen.lua
│   └── kryp_deathscreen/
│       ├── sh_config.lua
│       ├── sv_deathscreen.lua
│       └── cl_deathscreen.lua
└── README.md
```

Redémarre le serveur après installation.

## Configuration

Tout se règle dans :

```text
lua/kryp_deathscreen/sh_config.lua
```

Le délai par défaut est de **45 secondes**.

Paramètres principaux :

- `BackgroundAlpha` : intensité du fond noir.
- `PanelScreenWidth` : largeur de la carte SCP.
- `AccentColor` : couleur principale de l'interface.
- `FadeInDuration` / `FadeOutDuration` : vitesse des animations.
- `WorldEffectStrength` : force de l'effet appliqué au monde.
- `UseDarkRPRespawnTime` : utilise le temps de respawn DarkRP lorsqu'il est disponible.
