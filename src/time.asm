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


SECTION "High Time Variables", HRAM
hFrameCtr::  ds 1
hEvenFrame:: ds 1


SECTION "Time Variables", WRAM0
wMinutes:: ds 1
wSeconds:: ds 1
wFrames:: ds 1


SECTION "Time Functions", ROM0
    ; Zeroes all timers and gets the free-running timer ticking.
TimeInit::
    xor a, a
    ldh [rTMA], a
    ldh [hEvenFrame], a
    ldh [hFrameCtr], a
    ld [wMinutes], a
    ld [wSeconds], a
    ld [wFrames], a
    ld a, TACF_262KHZ | TACF_START
    ldh [rTAC], a
    ret


    ; Resets the minute-second timer.
ResetGameTime::
    xor a, a
    ld [wMinutes], a
    ld [wSeconds], a
    ld [wFrames], a
    ret

    ; Checks if the minute-second timer has reached a certain value.
    ; Call with max minutes in B and max seconds in C.
    ; A will be $FF if the torikan has succeeded, and $00 otherwise.
CheckTorikan::
    ; Okay if minutes are less than max minutes.
    ld a, [wMinutes]
    cp a, b
    jr c, .success

    ; Check seconds if minutes are equal.
    jr nz, .failure

    ; Okay if seconds are less than max seconds.
    ld a, [wSeconds]
    cp a, c
    jr c, .success

    ; Check frames if seconds are equal.
    jr nz, .failure

    ; Okay if frames are exactly 0.
    ld a, [wFrames]
    cp a, 0
    jr z, .success

.failure
    xor a, a
    ret

.success
    ld a, $FF
    ret


    ; Increments the global timer. Also saves whether we're on an even frame.
HandleTimers::
    ldh a, [hFrameCtr]
    inc a
    ldh [hFrameCtr], a
    and 1
    ldh [hEvenFrame], a

    ldh a, [hMode]
    cp a, MODE_PAUSED
    ret z
    cp a, MODE_GAME_OVER
    ret z
    cp a, MODE_PRE_GAME_OVER
    ret z

    ld a, [wFrames]
    inc a
    ld [wFrames], a
    cp a, 60
    ret nz

    xor a, a
    ld [wFrames], a
    ld a, [wSeconds]
    inc a
    ld [wSeconds], a
    cp a, 60
    ret nz

    xor a, a
    ld [wSeconds], a
    ld a, [wMinutes]
    inc a
    ld [wMinutes], a
    ret


ENDC
