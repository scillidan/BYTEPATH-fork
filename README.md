# BYTEPATH-fork

Original by [a327ex](https://github.com/a327ex/BYTEPATH) · Fork by scillidan · License: MIT

A replayable arcade shooter with build customization through passive skill trees, classes, and items.

## Requirements

- **LÖVE 11.5** (Mysterious Mysteries, 2023)

## Running

```bash
# Windows (using bundled runtime)
love/love.exe .

# Linux (requires love 11.5 installed)
love .
```

## Building

```bash
make all        # Build for all platforms (windows, linux, linux-arm)
make windows    # Build for Windows
make linux      # Build for Linux
make linux-arm  # Build for Linux ARM
```

Build outputs are placed in `dist/` directory.

## Changes from upstream

- Migrated from LÖVE 0.10.2 to 11.5
  - All color values converted from 0-255 to 0-1 range
  - Shader syntax updated (extern→uniform, number→float, Image→sampler2D)
  - Deprecated filesystem API replaced (exists/isFile/isDirectory → getInfo)
  - conf.lua updated (fsaa→msaa, fullscreentype, vsync)
- Added dynamic screen resizing with `love.resize` callback
- Added letterbox/pillarbox support for non-16:9 displays
- Added key rebinding system (`settings.lua` with persistent save)
- Added touch controls for mobile (virtual joystick + action buttons)
- Added Android config (`t.accelerometerjoystick`, `t.externalstorage`)
- Fixed shader bug in AchievementScreenshots (wrong uniform name)
- Added GitHub Actions CI (lint, build, release)
- Added Flathub/Scoop/F-Droid packaging manifests

## Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | WASD / Arrows | D-pad |
| Confirm | Enter | A/X |
| Back | Escape | Start/Select |

Key bindings can be customized and are saved automatically.
