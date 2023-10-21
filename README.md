# DMGTRIS
This is a block stacking game for the game boy using the TGM2 era ARS rotation rules (no floor kicks, but with sonic drop) for the original black and white game boy written in assembly.

It supports TLS (until 1G), IRS, IHS, ARE, Lock Delay, and other such buzz words.

Scoring is somewhat like TGM1 within the bounds of what the Z80 CPU can calculate quickly enough.

The speed curve starts at 1/16G, so slightly faster than TGM, and goes smoothly toward 20G at level 500. There is no speed drop at level 200, and the game doesn't end at level 999. 20G mode starts at TGM1 speeds, then transitions to TGM2 speeds, TGM3 speeds, and finally it goes beyond even shirase mode.

The game itself runs at a constant 60fps as well as at the traditional 20 row visible grid.


## Controls
### Menu
- A/B/Start — Start the game
- Left/Right — Switch A/B rotation direction
- Up/Down — Select starting level

### Gameplay
- A — Rotate 1
- B — Rotate 2
- Select — Hold
- Up — Sonic drop
- Down — Soft drop/Lock
- Left/Right — Move

### Game Over
- A — Restart immediately
- B — Go back to title


## Building
This game was created using Game Boy assembly using the RGBDS toolchain and GNU make.
