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


IF !DEF(DMGFX_ASM)
DEF DMGFX_ASM EQU 1


INCLUDE "globals.asm"


SECTION "DMG Intro Effect", ROM0
DoDMGEffect::
    ld a, [wInitialA]
    cp a, $11
    ret z

    ; Yeet the logo
    ld c, 10
.loop0
    wait_vblank
    ldh a, [rSCY]
    dec a
    ldh [rSCY], a
    wait_vblank_end
    dec c
    jr nz, .loop0

    ld c, 45
.loop1
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
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop2

    wait_vblank
    ld a, PALETTE_MONO_1
    ldh [rBGP], a

    ld c, 20
.loop3
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop3

    wait_vblank
    ld a, PALETTE_MONO_0
    ldh [rBGP], a

    ld c, 20
.loop4
    wait_vblank
    wait_vblank_end
    dec c
    jr nz, .loop4
    ret


ENDC
