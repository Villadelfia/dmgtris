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


IF !DEF(TIME_ASM)
DEF TIME_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Time Variables", HRAM
hFrameCtr::  ds 1
hEvenFrame:: ds 1


SECTION "Time Functions", ROM0
TimeInit::
    xor a, a
    ldh [rTMA], a
    ldh [hEvenFrame], a
    ldh [hFrameCtr], a
    ld a, TACF_262KHZ | TACF_START
    ldh [rTAC], a
    ret

HandleTimers::
    ldh a, [hFrameCtr]
    inc a
    ldh [hFrameCtr], a
    and 1
    ldh [hEvenFrame], a
    ret


ENDC
