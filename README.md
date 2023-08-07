# Compact Raid Frames

Compact Raid Frames is a World of Warcraft Vanilla (1.12) backport of raid frames introduced in the Cataclysm expansion.

> Only works with a party, raid support will be implemented in the future

## Overview

- Includes incoming heal prediction
- Tracks class buffs and dispellable debuffs (4 auras by default)
- Unitframes fade out when party members are out of range
- Mouseover macros implemented by other addons are supported
- Can be moved by holding down the control key and dragging the frame around (only works out of combat)
- The group frame and unitframes can be further customized using slash commands (`/crf`)
  - Changing the width of the unitframes also updates the amount of tracked auras. The amount of tracked auras is calculated as `floor(unitframe width / aura size)`

## Warning

If you want to replace your older version of the addon with the newest one, you will need to wipe the config first.

1. Open your World of Warcraft folder
2. Navigate to `WTF/Account/<your account name>/<realm name>/<character name>/SavedVairables`
3. Delete the `CRF.lua` and `CRF.lua.bak` files
