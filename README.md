# DMGTRIS
This is a block stacking game for the game boy using the TGM2 era ARS rotation rules (no floor kicks, but with sonic drop) for the original black and white game boy written in assembly.

It supports TLS (until 1G), IRS, IHS, ARE, Lock Delay, and other such buzz words.

Scoring is somewhat like TGM1 within the bounds of what the Z80 CPU can calculate quickly enough.

The speed curve starts at 1/16G, so slightly faster than TGM, and goes smoothly toward 20G at level 500. There is no speed drop at level 200, and the game doesn't end at level 999. 20G mode starts at TGM1 speeds, then transitions to TGM2 speeds, TGM3 speeds, and finally it goes beyond even shirase mode.

The Randomizer uses a TGM2-style 4-history randomizer preloaded with SSZZ, and with 4 rerolls by default. This number can be changed and is shown at the top right of the playfield.

The game itself runs at a constant 60fps as well as at the traditional 20 row visible grid.

There are five available game modes:
- TGM1: 4 history w/ 4 rerolls, never start with O, S or Z.
- TGM2: 4 history w/ 6 rerolls, never start with O, S or Z. Sonic drop.
- TGM3: 4 history w/ 6 rerolls and drought protection, never start with O, S or Z. Sonic drop. Extra floor and wall kicks for I and T pieces.
- HELL: Pure random piece generation.
- EASY: 4 history w/ 256 rerolls, never start with O, S or Z. Sonic drop.
- TGW2: TGM2 but with hard drop.
- TGW3: TGM3 but with hard drop.
- EAWY: EASY but with hard drop.


## Playing
You can build the game yourself, or use the binary [here](https://git.villadelfia.org/villadelfia/dmgtris/raw/branch/master/DMGTRIS.GB) or [here](https://github.com/Villadelfia/DMGTRIS/raw/master/DMGTRIS.GB).

The game should run in any accurate emulator. For Windows or Linux using Wine [bgb](https://bgb.bircd.org/) is generally regarded as the best option. For macOS [SameBoy](https://sameboy.github.io/) comes recommended.

Please do not try running it on older emulators such as VBA, since this game uses the semi-randomness of the initial game boy memory as one source of RNG entropy.


## Controls
### Menu
- A/B/Start — Start the game
- Left/Right — Switch A/B rotation direction
- Up/Down — Select starting level
- Select — Select game mode

### Gameplay
- A — Rotate 1
- B — Rotate 2
- Select — Hold
- Start — Pause
- Up — Sonic drop
- Down — Soft drop/Lock
- Left/Right — Move

### Game Over
- A — Restart immediately
- B — Go back to title


## Building
This game was created using Game Boy assembly using the RGBDS toolchain and GNU make.


## Issues
- In very rare cases the frame time in TGM3 and TGW3 modes can be exceeded due to the way the RNG for those modes works. When this happens, the screen will appear slightly glitched for 1 frame but no frame drops will occur. This issues is fundamentally impossible to completely avoid though more optimization may cause it to occur less frequently.
- In frames where both rotation and translation happens at the same time, the ghost piece may be drawn one space too high or too low. Fixing this would require calculating the distance-to-stack twice and that wouldn't be possible on the original game boy. This issue is only a visual glitch and only for one frame sometimes. It will not be fixed.


## Future Goals
- Improve main menu.
- Add 20G mode.
- Multiplayer.
- Multiplayer with items.
- Colorization.
- Three previews for TGM3 modes.
- ...

## License
Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
