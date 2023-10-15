# Compact Raid Frames

Compact Raid Frames is a World of Warcraft Vanilla (1.12) backport of raid frames introduced in the Cataclysm expansion.

> Works with a party. Raid support (or a basic version of it) is now available!

## Overview

- Includes incoming heal prediction
- Tracks class buffs and dispellable debuffs (4 auras by default)
- Unitframes fade out when party members are out of range
- Mouseover macros implemented by other addons are supported
- Can be moved by holding down the control key and dragging the frame around (only works out of combat)
- The group frame and unitframes can be further customized using slash commands (`/crf`)
  - Changing the width of the unitframes also updates the amount of tracked auras. The amount of tracked auras is calculated as `floor(unitframe width / aura size)`

## Installation

1. Download the addon
2. Extract the ZIP file
3. Rename the extracted folder to `CRF` (remove `-master` from the name)
4. Move the folder to your AddOns folder

> If you are updating from an older version and you get errors in-game, try typing `/crf reset` in the chat