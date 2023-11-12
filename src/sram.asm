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


MACRO PROFILE
UNION
rProfileData\1:: ds 64
NEXTU
rProfileName\1:: ds 3
rSwapABState\1:: ds 1
rRNGModeState\1:: ds 1
rRotModeState\1:: ds 1
rDropModeState\1:: ds 1
rSpeedCurveState\1:: ds 1
rAlways20GState\1:: ds 1
rSelectedStartLevel\1:: ds 2
rUnused\1:: ds (64-11)
ENDU
ENDM


SECTION "Persistent Globals", SRAM
rCheck:: ds 6
rLastProfile:: ds 1
UNION
rProfileData:: ds PROFILE_SIZE
NEXTU
rProfileName:: ds 3
rSwapABState:: ds 1
rRNGModeState:: ds 1
rRotModeState:: ds 1
rDropModeState:: ds 1
rSpeedCurveState:: ds 1
rAlways20GState:: ds 1
rSelectedStartLevel:: ds 2
rUnused:: ds (PROFILE_SIZE - 11) ; 11 = sum of the above
ENDU
    PROFILE 0
    PROFILE 1
    PROFILE 2
    PROFILE 3
    PROFILE 4
    PROFILE 5
    PROFILE 6
    PROFILE 7
    PROFILE 8
    PROFILE 9
rScoreTableDMGT:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableTGM1:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableTGM3:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableDEAT:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableSHIR:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableCHIL:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
rScoreTableMYCO:: ds (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)


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
    cp a, 4
    jp nz, InitializeSRAM

    ; SRAM is initialized and for this build, so we can load the data.
TrustedLoad:
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
    ld b, BANK_OTHER
    rst RSTSwitchBank

    ld a, [rSelectedStartLevel]
    ld c, a
    ld a, [rSelectedStartLevel+1]
    ld b, a

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
    ld a, 4
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
    ld hl, rProfileData3
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData4
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData5
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData6
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData7
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData8
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld hl, rProfileData9
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    ld a, "1"
    ld [rProfileName1+2], a
    ld a, "2"
    ld [rProfileName2+2], a
    ld a, "3"
    ld [rProfileName3+2], a
    ld a, "4"
    ld [rProfileName4+2], a
    ld a, "5"
    ld [rProfileName5+2], a
    ld a, "6"
    ld [rProfileName6+2], a
    ld a, "7"
    ld [rProfileName7+2], a
    ld a, "8"
    ld [rProfileName8+2], a
    ld a, "9"
    ld [rProfileName9+2], a

    ld a, 6
    ld [wSelected], a
    call ResetScores
    ld a, 5
    ld [wSelected], a
    call ResetScores
    ld a, 4
    ld [wSelected], a
    call ResetScores
    ld a, 3
    ld [wSelected], a
    call ResetScores
    ld a, 2
    ld [wSelected], a
    call ResetScores
    ld a, 1
    ld [wSelected], a
    call ResetScores
    xor a, a
    ld [wSelected], a

    ; Set the default scores.
ResetScores::
    ld a, [wSelected]
    ld b, a
    add a, b
    add a, b
    ld c, a
    ld b, 0
    ld hl, .jumps
    add hl, bc
    jp hl

.jumps
    jp .dmgt
    jp .tgm1
    jp .tgm3
    jp .deat
    jp .shir
    jp .chil
    jp .myco

.dmgt
    ld hl, rScoreTableDMGT
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.tgm1
    ld hl, rScoreTableTGM1
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.tgm3
    ld hl, rScoreTableTGM3
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.deat
    ld hl, rScoreTableDEAT
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.shir
    ld hl, rScoreTableSHIR
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.chil
    ld hl, rScoreTableCHIL
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

.myco
    ld hl, rScoreTableMYCO
    ld de, sHiscoreDefaultData
    ld bc, (HISCORE_ENTRY_COUNT * HISCORE_ENTRY_SIZE)
    jp UnsafeMemCopy

NextProfile::
    ld a, [rLastProfile]
    inc a
    cp a, 10
    jr nz, .update
    xor a, a
.update
    jp ChangeProfile

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
    cp a, 3
    jr z, .fourth
    cp a, 4
    jr z, .fifth
    cp a, 5
    jr z, .sixth
    cp a, 6
    jr z, .seventh
    cp a, 7
    jr z, .eighth
    cp a, 8
    jr z, .ninth
    cp a, 9
    jr z, .tenth
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

.fourth
    ld hl, rProfileData3
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.fifth
    ld hl, rProfileData4
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.sixth
    ld hl, rProfileData5
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.seventh
    ld hl, rProfileData6
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.eighth
    ld hl, rProfileData7
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.ninth
    ld hl, rProfileData8
    ld de, rProfileData
    ld bc, 64
    call UnsafeMemCopy
    jr .restore

.tenth
    ld hl, rProfileData9
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
    cp a, 3
    jr z, .lfourth
    cp a, 4
    jr z, .lfifth
    cp a, 5
    jr z, .lsixth
    cp a, 6
    jr z, .lseventh
    cp a, 7
    jr z, .leighth
    cp a, 8
    jr z, .lninth
    cp a, 9
    jp z, .ltenth
    ret

.lfirst
    ld hl, rProfileData
    ld de, rProfileData0
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lsecond
    ld hl, rProfileData
    ld de, rProfileData1
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lthird
    ld hl, rProfileData
    ld de, rProfileData2
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lfourth
    ld hl, rProfileData
    ld de, rProfileData3
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lfifth
    ld hl, rProfileData
    ld de, rProfileData4
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lsixth
    ld hl, rProfileData
    ld de, rProfileData5
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lseventh
    ld hl, rProfileData
    ld de, rProfileData6
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.leighth
    ld hl, rProfileData
    ld de, rProfileData7
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.lninth
    ld hl, rProfileData
    ld de, rProfileData8
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad

.ltenth
    ld hl, rProfileData
    ld de, rProfileData9
    ld bc, 64
    call UnsafeMemCopy
    jp TrustedLoad


ResetProfile::
    ld a, "P"
    ld [rProfileName], a
    ld [wProfileName], a
    ld a, "R"
    ld [rProfileName+1], a
    ld [wProfileName+1], a
    ld a, [rLastProfile]
    add a, "0"
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
    ret

ENDC
