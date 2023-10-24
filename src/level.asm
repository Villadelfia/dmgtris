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


IF !DEF(LEVEL_ASM)
DEF LEVEL_ASM EQU 1


INCLUDE "globals.asm"


SECTION "High Level Variables", HRAM
hCurrentDAS:: ds 1
hCurrentARE:: ds 1
hCurrentLockDelay:: ds 1
hCurrentLineClearDelay:: ds 1
hCurrentGravityPerTick:: ds 1
hCurrentFramesPerGravityTick:: ds 1
hNextSpeedUp:: ds 2
hSpeedCurvePtr:: ds 2
hStartSpeed:: ds 2
hRequiresLineClear:: ds 1
hLevel:: ds 2
hCLevel:: ds 4
hNLevel:: ds 6 ; The extra 2 bytes will be clobbered by the sprite drawing functions.
hPrevHundreds:: ds 1


SECTION "Level Functions", ROM0
LevelInit::
    xor a, a
    ldh [hLevel], a
    ldh [hLevel+1], a
    ldh [hCLevel], a
    ldh [hCLevel+1], a
    ldh [hCLevel+2], a
    ldh [hCLevel+3], a
    ldh [hNLevel], a
    ldh [hNLevel+2], a ; Note +1 is inited later.
    ldh [hNLevel+3], a
    ldh [hRequiresLineClear], a

    ld a, 1
    ldh [hNLevel+1], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a

    ; CLevel
    ld a, [hl+]
    ld b, a
    and a, $0F
    ldh [hCLevel+3], a
    ld a, b
    swap a
    and a, $0F
    ldh [hCLevel+2], a
    ld a, [hl+]
    ld b, a
    and a, $0F
    ldh [hCLevel+1], a
    ld a, b
    swap a
    and a, $0F
    ldh [hCLevel], a

    ld a, l
    ldh [hSpeedCurvePtr], a
    ld a, h
    ldh [hSpeedCurvePtr+1], a

    ; Binary level.
    ld a, [hl+]
    ldh [hLevel], a
    ld a, [hl+]
    ldh [hLevel+1], a

    ; NLevel
    ld a, [hl+]
    ld b, a
    and a, $0F
    ldh [hNLevel+3], a
    ld a, b
    swap a
    and a, $0F
    ldh [hNLevel+2], a
    ld a, [hl+]
    ld b, a
    and a, $0F
    ldh [hNLevel+1], a
    ld a, b
    swap a
    and a, $0F
    ldh [hNLevel], a

    call DoSpeedUp
    ret

    ; Increment level and speed up if necessary. Level increment in E.
    ; Levels may only increment by single digits.
LevelUp::
    ; Return if we're maxed out.
    ld hl, hCLevel
    ld a, $09
    and a, [hl]
    inc hl
    and a, [hl]
    inc hl
    and a, [hl]
    inc hl
    and a, [hl]
    ld c, [hl]
    cp a, $09
    ret z

    ; Binary addition
    ldh a, [hLevel]
    ld l, a
    ldh a, [hLevel+1]
    ld h, a
    ld a, e
    add a, l
    ld l, a
    adc a, h
    sub l
    ldh [hLevel+1], a
    ld l, a
    ldh [hLevel], a

    ; Save the current hundred digit.
    ldh a, [hCLevel+1]
    ldh [hPrevHundreds], a

    ; Increment LSD.
.doit
    ld hl, hCLevel+3
    ld a, [hl]
    add a, e
    ld [hl], a
    cp a, $0A
    jr c, .checknlevel
    sub a, 10
    ld [hl], a

    ; Carry the one...
    dec hl
    ld a, [hl]
    inc a
    ld [hl], a
    cp a, $0A
    jr c, .checknlevel
    xor a, a
    ld [hl], a

    ; Again...
    dec hl
    ld a, [hl]
    inc a
    ld [hl], a
    cp a, $0A
    jr c, .checknlevel
    xor a, a
    ld [hl], a

    ; Once more...
    dec hl
    ld a, [hl]
    inc a
    ld [hl], a
    cp a, $0A
    jr c, .checknlevel

    ; We're maxed out. Both levels should be set to 9999.
    ld a, 9
    ldh [hCLevel], a
    ldh [hCLevel+1], a
    ldh [hCLevel+2], a
    ldh [hCLevel+3], a
    call DoSpeedUp
    ld a, SFX_RANK_UP
    call SFXEnqueue
    ret

.checknlevel
    ; Make wNLevel make sense.
    ld hl, hCLevel
    ld a, $09
    and a, [hl]
    inc hl
    and a, [hl]
    cp a, $09
    ; If wCLevel begins 99, wNLevel should be 9999.
    jr nz, :+
    ld a, 9
    ldh [hNLevel], a
    ldh [hNLevel+1], a
    ldh [hNLevel+2], a
    ldh [hNLevel+3], a
    ; If the last two digits of wCLevel are 98, play the bell.
    ld hl, hCLevel+2
    ld a, [hl+]
    cp a, 9
    jr nz, .checkspeedup
    ld a, [hl]
    cp a, 8
    jr nz, .checkspeedup
    ld a, $FF
    ldh [hRequiresLineClear], a
    ld a, SFX_BELL
    call SFXEnqueue
    jr .leveljinglemaybe

    ; Otherwise check the second digit of wCLevel.
:   ld hl, hCLevel+1
    ld a, [hl]
    ; If it's 9, wNLevel should be y0xx. With y being the first digit of wCLevel+1
    cp a, 9
    jr nz, :+
    ld hl, hNLevel+1
    xor a, a
    ld [hl], a
    ld hl, hCLevel
    ld a, [hl]
    inc a
    ld hl, hNLevel
    ld [hl], a
    jr .bellmaybe

    ; Otherwise just set the second digit of wNLevel to the second digit of wCLevel + 1.
:   ld hl, hCLevel+1
    ld a, [hl]
    inc a
    ld hl, hNLevel+1
    ld [hl], a

.bellmaybe
    ; If the last two digits of wCLevel are 99, play the bell.
    ld hl, hCLevel+2
    ld a, [hl+]
    and a, [hl]
    cp a, 9
    jr nz, .leveljinglemaybe
    ld a, $FF
    ldh [hRequiresLineClear], a
    ld a, SFX_BELL
    call SFXEnqueue

.leveljinglemaybe
    ldh a, [hPrevHundreds]
    ld b, a
    ldh a, [hCLevel+1]
    cp a, b
    jr z, .checkspeedup
    ld a, SFX_LEVEL_UP
    call SFXEnqueue

.checkspeedup
    ldh a, [hNextSpeedUp]
    and a, $F0
    jr z, :+
    swap a
    and a, $0F
    ld hl, hCLevel
    cp a, [hl]
    jr z, :+
    ret nc

:   ldh a, [hNextSpeedUp]
    and a, $0F
    jr z, :+
    ld hl, hCLevel+1
    cp a, [hl]
    jr z, :+
    ret nc

:   ldh a, [hNextSpeedUp+1]
    and a, $F0
    jr z, :+
    swap a
    and a, $0F
    ld hl, hCLevel+2
    cp a, [hl]
    jr z, :+
    ret nc

:   ldh a, [hNextSpeedUp+1]
    and a, $0F
    jr z, :+
    ld hl, hCLevel+3
    cp a, [hl]
    jr z, :+
    ret nc

:   call DoSpeedUp
    ret


DoSpeedUp:
    ; Load curve ptr.
    ldh a, [hSpeedCurvePtr]
    ld l, a
    ldh a, [hSpeedCurvePtr+1]
    ld h, a

    ; There's 4 bytes we don't care about.
    inc hl
    inc hl
    inc hl
    inc hl

    ; Get all the new data.
    ld a, [hl+]
    ldh [hCurrentGravityPerTick], a
    ld a, [hl+]
    ldh [hCurrentFramesPerGravityTick], a
    ld a, [hl+]
    ldh [hCurrentARE], a
    ld a, [hl+]
    ldh [hCurrentDAS], a
    ld a, [hl+]
    ldh [hCurrentLockDelay], a
    ld a, [hl+]
    ldh [hCurrentLineClearDelay], a
    ld a, [hl+]
    ldh [hNextSpeedUp+1], a
    ld a, [hl+]
    ldh [hNextSpeedUp], a

    ; Save the new pointer.
    ld a, l
    ldh [hSpeedCurvePtr], a
    ld a, h
    ldh [hSpeedCurvePtr+1], a

    ; Do we want to force 20G?
    ld a, [wAlways20GState]
    cp a, 0
    ret z
    ld a, 20
    ldh [hCurrentGravityPerTick], a
    ld a, 1
    ldh [hCurrentFramesPerGravityTick], a
    ret


ENDC
