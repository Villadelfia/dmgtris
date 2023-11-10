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
rLastProfile:: ds 1
UNION
rProfileData:: ds 64
NEXTU
rProfileName:: ds 3
rSwapABState:: ds 1
rRNGModeState:: ds 1
rRotModeState:: ds 1
rDropModeState:: ds 1
rSpeedCurveState:: ds 1
rAlways20GState:: ds 1
rSelectedStartLevel:: ds 2
rUnused:: ds (64-11)
ENDU
UNION
rProfileData0:: ds 64
NEXTU
rProfileName0:: ds 3
rSwapABState0:: ds 1
rRNGModeState0:: ds 1
rRotModeState0:: ds 1
rDropModeState0:: ds 1
rSpeedCurveState0:: ds 1
rAlways20GState0:: ds 1
rSelectedStartLevel0:: ds 2
rUnused0:: ds (64-11)
ENDU
UNION
rProfileData1:: ds 64
NEXTU
rProfileName1:: ds 3
rSwapABState1:: ds 1
rRNGModeState1:: ds 1
rRotModeState1:: ds 1
rDropModeState1:: ds 1
rSpeedCurveState1:: ds 1
rAlways20GState1:: ds 1
rSelectedStartLevel1:: ds 2
rUnused1:: ds (64-11)
ENDU
UNION
rProfileData2:: ds 64
NEXTU
rProfileName2:: ds 3
rSwapABState2:: ds 1
rRNGModeState2:: ds 1
rRotModeState2:: ds 1
rDropModeState2:: ds 1
rSpeedCurveState2:: ds 1
rAlways20GState2:: ds 1
rSelectedStartLevel2:: ds 2
rUnused2:: ds (64-11)
ENDU

SECTION "SRAM Variables", WRAM0
wTarget:: ds 1


SECTION "SRAM Functions", ROM0
    ; Check if our SRAM is initialized and of the correct version.
    ; Restores it if so, otherwise initializes it.
RestoreSRAM::
    ld a, [rCheck]
    cp a, "D"
    jp nz, InitializeSRAM
    ld a, [rCheck+1]
    cp a, "M"
    jp nz, InitializeSRAM
    ld a, [rCheck+2]
    cp a, "G"
    jp nz, InitializeSRAM
    ld a, [rCheck+3]
    cp a, "T"
    jp nz, InitializeSRAM
    ld a, [rCheck+4]
    cp a, 0
    jp nz, InitializeSRAM
    ld a, [rCheck+5]
    cp a, 0
    jp nz, InitializeSRAM

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
    ld a, [rProfileName]
    ld [wProfileName], a
    ld a, [rProfileName+1]
    ld [wProfileName+1], a
    ld a, [rProfileName+2]
    ld [wProfileName+2], a

    ; Restore the start level.
    ld a, [rSelectedStartLevel]
    ld c, a
    ld a, [rSelectedStartLevel+1]
    ld b, a

    ld b, BANK_OTHER
    rst RSTSwitchBank

    ld a, [rSpeedCurveState]
    ld d, a
    add a, d
    add a, d
    ld e, a
    ld d, 0
    ld hl, .jumps
    add hl, de
    ld de, SCURVE_ENTRY_SIZE
    jp hl

.jumps
    jp .dmgt
    jp .tgm1
    jp .tgm3
    jp .deat
    jp .shir
    jp .chil
    jp .myco
    jp .fallback

.dmgt
    ld hl, sDMGTSpeedCurve
    jp .search
.tgm1
    ld hl, sTGM1SpeedCurve
    jp .search
.tgm3
    ld hl, sTGM3SpeedCurve
    jp .search
.deat
    ld hl, sDEATSpeedCurve
    jp .search
.shir
    ld hl, sSHIRSpeedCurve
    jp .search
.chil
    ld hl, sCHILSpeedCurve
    jp .search
.myco
    ld hl, sMYCOSpeedCurve
    jp .search

.search
    ; HL = Speed curve table
    ; BC = Start level
    ; DE = Speed curve entry size

    ld a, [hl+]
    cp a, c
    jr nz, .notfound
    ld a, [hl]
    cp a, b
    jr nz, .notfound

    ; Found it!
    dec hl
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a
    jp RSTRestoreBank

.notfound
    dec hl
    add hl, de
    ld a, [hl]
    cp a, $FF
    jr nz, .search

.fallback
    ld a, SCURVE_DMGT
    ld [rSpeedCurveState], a
    ld [wSpeedCurveState], a
    ld hl, sDMGTSpeedCurve
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a
    xor a, a
    ld [rSelectedStartLevel], a
    ld [rSelectedStartLevel+1], a
    jp RSTRestoreBank

    ; Initializes SRAM with default values.
InitializeSRAM:
    ; Set the magic id.
    ld a, "D"
    ld [rCheck], a
    ld a, "M"
    ld [rCheck+1], a
    ld a, "G"
    ld [rCheck+2], a
    ld a, "T"
    ld [rCheck+3], a
    ld a, 0
    ld [rCheck+4], a
    ld a, 0
    ld [rCheck+5], a

    xor a, a
    ld [rLastProfile], a

    ; Load defaults.
    ld a, "P"
    ld [rProfileName], a
    ld [wProfileName], a
    ld a, "R"
    ld [rProfileName+1], a
    ld [wProfileName+1], a
    ld a, "0"
    ld [rProfileName+2], a
    ld [wProfileName+2], a

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
    ld a, h
    ldh [hStartSpeed+1], a

    xor a, a
    ld [rSelectedStartLevel], a
    ld [rSelectedStartLevel+1], a

    ; Copy this profile to the other two.
    ld hl, rProfileData0
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData1
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData2
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld a, "1"
    ld [rProfileName1+2], a
    ld a, "2"
    ld [rProfileName2+2], a
    ret


    ; Change to profile number in A.
ChangeProfile::
.backup
    ld [wTarget], a
    ld a, [rLastProfile]
    cp a, 0
    jr z, .first
    cp a, 1
    jr z, .second
    cp a, 2
    jr z, .third
    ret

.first
    ld hl, rProfileData0
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.second
    ld hl, rProfileData1
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.third
    ld hl, rProfileData2
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.restore
    ld a, [wTarget]
    ld [rLastProfile], a
    cp a, 0
    jr z, .lfirst
    cp a, 1
    jr z, .lsecond
    cp a, 2
    jr z, .lthird
    ret

.lfirst
    ld hl, rProfileData
    ld de, rProfileData0
    ld bc, 64
    jp UnsafeMemCopy

.lsecond
    ld hl, rProfileData
    ld de, rProfileData1
    ld bc, 64
    jp UnsafeMemCopy

.lthird
    ld hl, rProfileData
    ld de, rProfileData2
    ld bc, 64
    jp UnsafeMemCopy


ENDC
