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


IF !DEF(INTRO_ASM)
DEF INTRO_ASM EQU 1


INCLUDE "globals.asm"

    DEF_RGB555 FADE_0, 31, 31, 31
    DEF_RGB555 FADE_1, 30, 30, 30
    DEF_RGB555 FADE_2, 29, 29, 29
    DEF_RGB555 FADE_3, 28, 28, 28
    DEF_RGB555 FADE_4, 27, 27, 27
    DEF_RGB555 FADE_5, 26, 26, 26
    DEF_RGB555 FADE_6, 25, 25, 25
    DEF_RGB555 FADE_7, 24, 24, 24
    DEF_RGB555 FADE_8, 23, 23, 23
    DEF_RGB555 FADE_9, 22, 22, 22
    DEF_RGB555 FADE_10, 21, 21, 21
    DEF_RGB555 FADE_11, 20, 20, 20
    DEF_RGB555 FADE_12, 19, 19, 19
    DEF_RGB555 FADE_13, 18, 18, 18
    DEF_RGB555 FADE_14, 17, 17, 17
    DEF_RGB555 FADE_15, 16, 16, 16
    DEF_RGB555 FADE_16, 15, 15, 15
    DEF_RGB555 FADE_17, 14, 14, 14
    DEF_RGB555 FADE_18, 13, 13, 13
    DEF_RGB555 FADE_19, 12, 12, 12
    DEF_RGB555 FADE_20, 11, 11, 11
    DEF_RGB555 FADE_21, 10, 10, 10
    DEF_RGB555 FADE_22, 9, 9, 9
    DEF_RGB555 FADE_23, 8, 8, 8
    DEF_RGB555 FADE_24, 7, 7, 7
    DEF_RGB555 FADE_25, 6, 6, 6
    DEF_RGB555 FADE_26, 5, 5, 5
    DEF_RGB555 FADE_27, 4, 4, 4
    DEF_RGB555 FADE_28, 3, 3, 3
    DEF_RGB555 FADE_29, 2, 2, 2
    DEF_RGB555 FADE_30, 1, 1, 1
    DEF_RGB555 FADE_31, 0, 0, 0


SECTION "Intro Effect Trampoline", ROM0
DoIntroEffect::
    ld b, BANK_TITLE
    rst RSTSwitchBank
    ld a, [wInitialA]
    cp a, $11
    call nz, DoDMGEffect
    call z,  DoGBCEffect
    jp RSTRestoreBank


SECTION "Intro Effects Banked", ROMX, BANK[BANK_TITLE]
DoDMGEffect:
    ; Yeet the logo
    ld c, 10
.loop0
    call GetInput
    ldh a, [hStartState]
    ld hl, hAState
    or a, [hl]
    ld hl, hBState
    or a, [hl]
    ret nz
    wait_vblank
    ldh a, [rSCY]
    dec a
    ldh [rSCY], a
    wait_vblank_end
    dec c
    jr nz, .loop0

    ld c, 45
.loop1
    call GetInput
    ldh a, [hStartState]
    ld hl, hAState
    or a, [hl]
    ld hl, hBState
    or a, [hl]
    ret nz
    wait_vblank
    ldh a, [rSCY]
    inc a
    inc a
    ldh [rSCY], a
    wait_vblank_end
    dec c
    jr nz, .loop1

    ; Fade
    wait_vblank
    ld a, PALETTE_MONO_2
    ldh [rBGP], a

    ld c, 20
.loop2
    call GetInput
    ldh a, [hStartState]
    ld hl, hAState
    or a, [hl]
    ld hl, hBState
    or a, [hl]
    ret nz
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop2

    wait_vblank
    ld a, PALETTE_MONO_1
    ldh [rBGP], a

    ld c, 20
.loop3
    call GetInput
    ldh a, [hStartState]
    ld hl, hAState
    or a, [hl]
    ld hl, hBState
    or a, [hl]
    ret nz
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop3

    wait_vblank
    ld a, PALETTE_MONO_0
    ldh [rBGP], a

    ld c, 20
.loop4
    call GetInput
    ldh a, [hStartState]
    ld hl, hAState
    or a, [hl]
    ld hl, hBState
    or a, [hl]
    ret nz
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop4
    ret


DoGBCEffect:
    ; Fade the screen to black.
    FOR I, 31, 0, -1
        wait_vblank
        WRITEPAL_B 0, (I << 10 | I << 5 | I), (I << 10 | I << 5 | I), (I << 10 | I << 5 | I), (I << 10 | I << 5 | I)
        wait_vblank_end
        wait_vblank
        wait_vblank_end
        call GetInput
        ldh a, [hStartState]
        ld hl, hAState
        or a, [hl]
        ld hl, hBState
        or a, [hl]
        ret nz
    ENDR
    wait_vblank
    wait_vblank_end
    wait_vblank
    wait_vblank_end
    wait_vblank
    wait_vblank_end
    wait_vblank
    wait_vblank_end
    wait_vblank
    ret


ENDC
