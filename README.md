# DMGTRIS
This is a block stacking game for the game boy using the TGM2 era ARS rotation rules (no floor kicks, but with sonic drop) for the original black and white game boy written in assembly.

It supports TLS (until 1G), IRS, IHS, ARE, Lock Delay, and other such buzz words.

Scoring is somewhat like TGM1 within the bounds of what the Z80 CPU can calculate quickly enough.

The speed curve starts at 1/16G, so slightly faster than TGM, and goes smoothly toward 20G at level 500. There is no speed drop at level 200, and the game doesn't end at level 999. 20G mode starts at TGM1 speeds, then transitions to TGM2 speeds, TGM3 speeds, and finally it goes beyond even shirase mode.

The game itself runs at a constant 60fps as well as at the traditional 20 row visible grid.


## Playing
You can build the game yourself, or use the binary [here](https://git.villadelfia.org/villadelfia/dmgtris/raw/branch/master/DMGTRIS.GB) or [here](https://github.com/Villadelfia/DMGTRIS/raw/master/DMGTRIS.GB).

The game should run in any accurate emulator. For Windows or Linux using Wine [bgb](https://bgb.bircd.org/) is generally regarded as the best option. For macOS [SameBoy](https://sameboy.github.io/) comes recommended.

Please do not try running it on older emulators such as VBA, since this game uses the semi-randomness of the initial game boy memory as one source of RNG entropy.


## Controls
### Menu
- A/B/Start — Start the game
- Left/Right — Switch A/B rotation direction
- Up/Down — Select starting level
- Select — Select amount of times a piece will be rerolled if it was given to you in the previous 4 pieces. TGM2 uses 6 for this value, TGM1 uses 4 for this value. You can set this to 0 (pure RNG except you'll never start with O, S, or Z), to 15 (F. Basically never get duplicates.)

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
