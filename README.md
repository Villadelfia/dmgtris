# DMGTRIS
DMGTRIS is a block stacking game for the original game boy written in assembly.

The game is heavily inspired by the TGM series of games and has the following features:
- TLS (ghost piece) until 1G speeds.
- IRS (initial rotation system).
- IHS (initial hold system) as well as holds.
- Faithful implementations of concepts such are lock delay, piece spawn delay and DAS.
- Several RNG options available. You can choose between pure RNG, 4 history with 4 retries, 4 history with 6 retries, 4 history with infinite retries, a 35bag with 4 history and 6 retries with drought prevention, NES style RNG, or pure RNG.
- A choice between sonic drop (pressing up grounds the piece but does not lock it), hard drop (pressing up locks the piece), or neither (pressing up does nothing at all.)
- A choice between traditional ARS for rotation, or TGM3 era ARS with extra kicks.
- Scoring is a hybrid between TGM1 and TGM2.
- A speed curve reminiscent of TGM, starting slightly faster and skipping the awkward speed reset. The game continues infinitely... But so does the speed increase.
- A rock solid 60FPS with a traditional 20x10 grid.


## Options
### Buttons
Switch between whether A or B rotates clockwise and vice versa.

### RNG Mode
Choose between a few randomizer options:
- TGM1: 4 history, 4 rerolls.
- TGM2: 4 history, 6 rerolls.
- TGM3: The TGM3 RNG system.
- HELL: Pure Random.
- NES: Reroll once if you get the same piece as the previous one.

### Rot Mode
Select the rotation rules:
- ARS1: Classic ARS from TGM1 and TGM2.
- ARS2: ARS from TGM3.

### Drop Mode
Select whether up performs a sonic drop, a hard drop, or nothing at all.

### Speed Curve
Select between several speed curves including the DMGTRIS default speed curve, TGM1, 2, and 3, as well as DEATH and SHIRASE mode. Note that all modes use the same scoring and they are all infinite.

### Always 20G
Whether you want instant-drop gravity to be active at any level.

### Start Level
Choose any of the speed breakpoints to start the game at.


## Scoring
After each piece is dropped, a check is made:

### No line clear
Combo is reset to 1 and no points are awarded.

### Lines were cleared
Lines = Lines cleared.

Level = The level before the lines were cleared.

Soft = Amount of frames the down button was held during this piece + 10 if the piece was sonic or hard dropped.

Combo = Old combo + (2 x Lines) - 2

Bravo = 1 if the field isn't empty, 4 if it is.

ScoreIncrement = ((Level + Lines) >> 4 + 1 + Soft) x Combo x Lines x Bravo.

ScoreIncrement points are then awarded.


## Playing
You can build the game yourself, or use the binary [here](https://git.villadelfia.org/villadelfia/dmgtris/raw/branch/master/DMGTRIS.GB) or [here](https://github.com/Villadelfia/DMGTRIS/raw/master/DMGTRIS.GB).

The game should run in any accurate emulator. For Windows or Linux using Wine [bgb](https://bgb.bircd.org/) is generally regarded as the best option. For macOS [SameBoy](https://sameboy.github.io/) comes recommended.

Please do not try running it on older emulators such as VBA, since this game uses the semi-randomness of the initial game boy memory as one source of RNG entropy.


## Controls
### Menu
- A/B/Start — Start the game
- Up/Down — Change which option is selected
- Left/Right — Change the value of the option

### Gameplay
- A — Rotate 1
- B — Rotate 2
- Select — Hold
- Start — Pause
- Up — Sonic/Hard drop
- Down — Soft drop/Lock
- Left/Right — Move

### Game Over
- A — Restart immediately
- B — Go back to title


## Building
The game can be built using gnu make and the RGBDS toolchain.


## Issues
- In very rare cases the frame time in TGM3 and TGW3 modes can be exceeded due to the way the RNG for those modes works. When this happens, the screen will appear slightly glitched for 1 frame but no frame drops will occur. This issues is fundamentally impossible to completely avoid though more optimization may cause it to occur less frequently.


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
