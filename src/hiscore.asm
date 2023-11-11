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


IF !DEF(HISCORE_ASM)
DEF HISCORE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Hi Score Data", ROM0
sHiscoreDefaultData::
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "GTR", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "ISD", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "MGT", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "RIS", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


SECTION "Hi Score Variables", WRAM0
wTargetHSTable:: ds 2
wWorkingIdx:: ds 1
wWorkingPtr:: ds 1
wWorkingCopy:: ds ((HISCORE_ENTRY_COUNT+1)*(HISCORE_ENTRY_SIZE))
wInsertTarget:: ds 1


SECTION "Hi Score Functions", ROM0
CheckAndAddHiscore::
    ; Get the table
    ld a, [wSpeedCurveState]
    call InitTargetHSTable

    ; Initialize loop at 0.
    xor a, a
    ld [wInsertTarget], a

.checkloop
    ; Load the score at position a.
    call GetHiScoreEntry

    ; HL is pointing to that score, make BC point to our current score.
    ld bc, hScore

    ; First digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Second digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Third digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Fourth digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Fifth digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Sixth digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Seventh digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better
    inc bc
    inc hl

    ; Eighth digit
    ld a, [bc]
    cp a, [hl]
    jr c, .notbetter
    jr nz, .better

    ; Loop or return if we didn't make the scores.
.notbetter
    ld a, [wInsertTarget]
    inc a
    ld [wInsertTarget], a
    cp a, 10
    ret z
    jr .checkloop

.better
    jr InsertHiScore


    ; Inserts the current score data into the table.
    ; Data will be saved and persisted.
InsertHiScore::
    ; Copy the entire table to working data, but one row down.
.copylower
    ld a, [wTargetHSTable]
    ld e, a
    ld a, [wTargetHSTable+1]
    ld d, a
    ld hl, wWorkingCopy+HISCORE_ENTRY_SIZE
    ld bc, (HISCORE_ENTRY_COUNT*HISCORE_ENTRY_SIZE)
    call UnsafeMemCopy

    ; Copy the top rows to the working data.
.copyupper
    ld a, [wInsertTarget]
    cp a, 0
    jr z, .findrow
    ld hl, 0
    ld bc, HISCORE_ENTRY_SIZE
:   add hl, bc
    dec a
    jr nz, :-
    ld b, h
    ld c, l
    ld a, [wTargetHSTable]
    ld e, a
    ld a, [wTargetHSTable+1]
    ld d, a
    ld hl, wWorkingCopy
    call UnsafeMemCopy

    ; Make HL point to the correct location to insert the new score
.findrow
    ld hl, wWorkingCopy
    ld bc, HISCORE_ENTRY_SIZE
    ld a, [wInsertTarget]
    cp a, 0
    jr z, .insert
:   add hl, bc
    dec a
    jr nz, :-

    ; And do the insertion
.insert
    ldh a, [hScore+0]
    ld [hl+], a
    ldh a, [hScore+1]
    ld [hl+], a
    ldh a, [hScore+2]
    ld [hl+], a
    ldh a, [hScore+3]
    ld [hl+], a
    ldh a, [hScore+4]
    ld [hl+], a
    ldh a, [hScore+5]
    ld [hl+], a
    ldh a, [hScore+6]
    ld [hl+], a
    ldh a, [hScore+7]
    ld [hl+], a
    ld a, [wProfileName+0]
    ld [hl+], a
    ld a, [wProfileName+1]
    ld [hl+], a
    ld a, [wProfileName+2]
    ld [hl+], a
    ld a, [wDisplayedGrade]
    ld [hl+], a
    ld a, [wRNGModeState]
    ld [hl+], a
    ld a, [wRotModeState]
    ld [hl+], a
    ld a, [wDropModeState]
    ld [hl+], a
    ld a, [wAlways20GState]
    ld [hl+], a

    ; 16 filler bytes.
    xor a, a
    REPT 16
        ld [hl+], a
    ENDR

    ; And copy it back.
.persist
    ld de, wWorkingCopy
    ld a, [wTargetHSTable]
    ld l, a
    ld a, [wTargetHSTable+1]
    ld h, a
    ld bc, HISCORE_ENTRY_COUNT*HISCORE_ENTRY_SIZE
    jp UnsafeMemCopy

    ; Updates the pointers for the current hi score to point to the index in register A.
    ; HL will be left pointing at said memory.
GetHiScoreEntry::
    ld [wWorkingIdx], a
    ld a, [wTargetHSTable]
    ld l, a
    ld a, [wTargetHSTable+1]
    ld h, a
    ld bc, HISCORE_ENTRY_SIZE
    ld a, [wWorkingIdx]
    cp a, 0
    jr z, .store
:   add hl, bc
    dec a
    jr nz, :-

.store
    ld a, l
    ld [wWorkingPtr], a
    ld a, h
    ld [wWorkingPtr+1], a
    ret

    ; Initializes all the pointers to point to the very first score in the table for the game mode passed in
    ; register A.
InitTargetHSTable::
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
    jr .store

.tgm1
    ld hl, rScoreTableTGM1
    jr .store

.tgm3
    ld hl, rScoreTableTGM3
    jr .store

.deat
    ld hl, rScoreTableDEAT
    jr .store

.shir
    ld hl, rScoreTableSHIR
    jr .store

.chil
    ld hl, rScoreTableCHIL
    jr .store

.myco
    ld hl, rScoreTableMYCO

.store
    ld a, l
    ld [wTargetHSTable], a
    ld [wWorkingPtr], a
    ld a, h
    ld [wTargetHSTable+1], a
    ld [wWorkingPtr+1], a
    xor a, a
    ld [wWorkingIdx], a
    ret

ENDC
