# Kryp Deathscreen

Deathscreen Garry's Mod / DarkRP avec UI distante Imgur, compte à rebours serveur et respawn manuel.

## Fonctionnement

- Affiche l'UI `https://i.imgur.com/Ba5xCtK.png` à la mort du joueur.
- Télécharge et met en cache le PNG côté client dans `garrysmod/data/kryp_deathscreen/`.
- Affiche le temps restant dans l'espace prévu après « Dans ».
- Bloque le respawn natif pendant le compte à rebours.
- Quand le délai est terminé, affiche : `Merci de cliquer sur une touche pour réapparaitre`.
- Une touche clavier déclenche alors la demande de respawn.
- Le serveur revalide le délai avant d'autoriser le respawn.
- Animation d'entrée à la mort et animation de sortie au respawn.
- Effet visuel léger sur le monde pendant la mort.

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

Le délai par défaut est de **45 secondes**. Tu peux aussi activer l'utilisation du `respawntime` DarkRP.

Les positions `CountdownX` et `CountdownY` sont exprimées en pourcentage de l'image et permettent d'ajuster très précisément le nombre dans l'espace entre « Dans » et « Secondes ».

## Commande client

```text
kryp_deathscreen_refresh
```

Supprime le cache local du PNG et le retélécharge depuis Imgur.
