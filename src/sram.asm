; DMGTRIS
; Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.


IF !DEF(SRAM_ASM)
DEF SRAM_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Persistent Globals", SRAM
rCheck:: ds 6
rSwapABState:: ds 1
rRNGModeState:: ds 1
rRotModeState:: ds 1
rDropModeState:: ds 1
rSpeedCurveState:: ds 1
rAlways20GState:: ds 1
rSelectedStartLevel:: ds 2


SECTION "SRAM Functions", ROM0
    ; Check if our SRAM is initialized and of the correct version.
    ; Restores it if so, otherwise initializes it.
RestoreSRAM::
    ld a, [rCheck]
    cp a, LOW(__UTC_YEAR__)
    jr nz, InitializeSRAM
    ld a, [rCheck+1]
    cp a, __UTC_MONTH__
    jr nz, InitializeSRAM
    ld a, [rCheck+2]
    cp a, __UTC_DAY__
    jr nz, InitializeSRAM
    ld a, [rCheck+3]
    cp a, __UTC_HOUR__
    jr nz, InitializeSRAM
    ld a, [rCheck+4]
    cp a, __UTC_MINUTE__
    jr nz, InitializeSRAM
    ld a, [rCheck+5]
    cp a, __UTC_SECOND__
    jr nz, InitializeSRAM

    ; SRAM is initialized and for this build, so we can load the data.
    ld a, [rSwapABState]
    ld [wSwapABState], a
    ld a, [rRNGModeState]
    ld [wRNGModeState], a
    ld a, [rRotModeState]
    ld [wRotModeState], a
    ld a, [rDropModeState]
    ld [wDropModeState], a
    ld a, [rSpeedCurveState]
    ld [wSpeedCurveState], a
    ld a, [rAlways20GState]
    ld [wAlways20GState], a

    ld a, [rSelectedStartLevel]
    ldh [hStartSpeed], a
    ld a, [rSelectedStartLevel+1]
    ldh [hStartSpeed+1], a
    ret

    ; Initializes SRAM with default values.
InitializeSRAM:
    ; Set the magic id.
    ld a, LOW(__UTC_YEAR__)
    ld [rCheck], a
    ld a, __UTC_MONTH__
    ld [rCheck+1], a
    ld a, __UTC_DAY__
    ld [rCheck+2], a
    ld a, __UTC_HOUR__
    ld [rCheck+3], a
    ld a, __UTC_MINUTE__
    ld [rCheck+4], a
    ld a, __UTC_SECOND__
    ld [rCheck+5], a

    ; Load defaults.
    ld a, BUTTON_MODE_NORM
    ld [rSwapABState], a
    ld [wSwapABState], a

    ld a, RNG_MODE_TGM3
    ld [rRNGModeState], a
    ld [wRNGModeState], a

    ld a, ROT_MODE_ARSTI
    ld [rRotModeState], a
    ld [wRotModeState], a

    ld a, DROP_MODE_FIRM
    ld [rDropModeState], a
    ld [wDropModeState], a

    ld a, SCURVE_DMGT
    ld [rSpeedCurveState], a
    ld [wSpeedCurveState], a

    ld a, HIG_MODE_OFF
    ld [rAlways20GState], a
    ld [wAlways20GState], a

    ; Set to the default start level.
    ld hl, sDMGTSpeedCurve
    ld a, l
    ldh [hStartSpeed], a
    ld [rSelectedStartLevel], a
    ld a, h
    ldh [hStartSpeed+1], a
    ld [rSelectedStartLevel+1], a
    ret


ENDC
