
# Pandora's Blocks
Pandora's Blocks (formerly DMGTRIS) is a block stacking game for the original game boy written in assembly.

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
- Game boy color mode.
- Invisible rolls, big mode, including big mode rolls, bone pieces, and even torikans!
- Grading systems that are inspired by, but do not exactly mimic, those in the TGM series of games in many of the speed curves.
- A challenging final challenge awaits you at the end of all the finite modes.
- High scores.


## Playing
Try the game online [here](https://villadelfia.org/dmgtris/). Controls are arrow keys, Z, X, Space, and Enter. The online version has no sound though, so the better thing would be to run it in an emulator locally.

You can build the game yourself, or use the binary [here](https://git.villadelfia.org/villadelfia/dmgtris/raw/branch/master/bin/PandorasBlocks.gbc) or [here](https://github.com/Villadelfia/DMGTRIS/raw/master/bin/PandorasBlocks.gbc).

The game should run in any accurate emulator. For Windows or Linux using Wine [bgb](https://bgb.bircd.org/) is generally regarded as the best option. For macOS [SameBoy](https://sameboy.github.io/) comes recommended.

Please do not try running it on older emulators such as VBA, since this game uses the semi-randomness of the initial game boy memory as one source of RNG entropy.


## Options
### Buttons
Switch between whether A or B rotates clockwise and vice versa.

### RNG Mode
Choose between a few randomizer options:
- TGM1: 4 history, 4 rerolls.
- TGM2: 4 history, 6 rerolls.
- TGM3: The TGM3 RNG system.
- HELL: Pure Random.
- 1ROL: Reroll once if you get the same piece as the previous one.

### Rot Mode
Select the rotation rules:
- ARS1: Classic ARS from TGM1 and TGM2.
- ARS2: ARS from TGM3.
- SEGA: No kicks.
- MYCO: Like ARS1, but without I, L, J and T restrictions.

### Drop Mode
Choose how the up and down buttons act:
- FIRM: Up drops to the bottom but does not lock until you are in neutral position. Down locks.
- SNIC: Like FIRM, but thre is no neutral lock.
- HARD: Up drops and locks. Down does not lock until you go neutral when the piece is grounded.
- LOCK: Like HARD but down locks.
- NONE: Up does nothing. Down locks.

### Speed Curve
Select between several speed curves including the DMGTRIS default speed curve, TGM1, TGM3, as well as DEATH and SHIRASE mode. In addition there's a "CHILL" curve for when you just want to enjoy some tetris. It doesn't speed up very fast at all. The MYCO speed curve mimics the excellent game Tromi by Mycophobia.

Note that all modes use the same scoring.

### Always 20G
Whether you want instant-drop gravity to be active at any level.

### Start Level
Choose any of the speed breakpoints to start the game at.

### D-Pad Filter
Choose which D-Pad buttons get priority.
- DLRU: Down > Left/Right > Up
- ULRD: Up > Left/Right > Down
- LRUD: Left/Right > Up/Down
- UDLR: Up/Down > Left/Right
- NONE: No filtering or priority.


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


## Controls
### Menu
- A/B/Start — Navigate the menus
- Up/Down — Change which option is selected
- Left/Right — Change the value of the option
- Select — Switch profiles while on the main menu, hold for 5 seconds to wipe the score table currently displayed when on the records screen.

### Gameplay
- A — Rotate 1
- B — Rotate 2
- Select — Hold
- Start — Pause
- Up — Sonic/Hard drop
- Down — Soft drop/Lock
- Left/Right — Move
- A+B+Select — Bail to main menu if paused

### Game Over
- A — Restart immediately
- B — Go back to title


## Screenshots
Original Game Boy | Game Boy Color
:-: | :-:
<img src="https://villadelfia.org/i/xAAHfqDw.png" width="160" height="144" /> | <img src="https://villadelfia.org/i/Hj2P8Pk5.png" width="160" height="144" />


## Videos
### Original Game Boy
Normal Mode | Big Mode
:-: | :-:
[VIDEO](https://villadelfia.org/dmgtris/demo-dmg-normal.mp4) | [VIDEO](https://villadelfia.org/dmgtris/demo-dmg-big.mp4)

### Game Boy Color
Normal Mode | Big Mode
:-: | :-:
[VIDEO](https://villadelfia.org/dmgtris/demo-gbc-normal.mp4) | [VIDEO](https://villadelfia.org/dmgtris/demo-gbc-big.mp4)

## Building and Development
The game can be built using gnu make and the RGBDS toolchain.

A few guidelines are in effect:
- If you add a bank, please add a section to `bankid.asm` and follow the existing format.
- Stuff that goes in the sram belongs in the `sram.asm` file, where there exists code to init SRAM to known defaults.


## Reporting Bugs
If you have found a bug, please follow the following steps *before* sending a bug report. The easier you make it for me to find and fix a bug, the more likely it is that I will do so.

0. I do not own a analogue pocket, the `.pocket` version is released on a best effort basis and I cannot help with bugs that *only* happen on the analogue pocket. If you find a bug, please reproduce the bug on the `.gbc` version.
1. Download the latest `.gbc`, `.map` and `.sym` files from this repository.
2. Use either emulicious or bgb to reproduce the bug on that version, documenting the exact steps taken to make it happen. Please also include what should be happening if the bug is subtle.
3. Make a save state at the moment the bug starts happening.
4. Send the `.gbc`, `.map`, `.sym`, and save state files as well as the documentation of the bug to me.

I will try to fix all bugs that I can, but please remember that this is free software and that I can not, and do not, guarantee fitness for purpose.


## Shoutouts and Thanks
Thanks for playtesting and debugging go to:

- CreeperCraftYT™
- AntonErgo
- Lindtobias
- \_Zaphod77\_
- bbbbbr


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

