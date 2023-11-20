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
wSectionMinutes:: ds 1
wSectionSeconds:: ds 1
wSectionFrames:: ds 1
wCountDown:: ds 2
wCountDownZero:: ds 1
wSectionTimerReset:: ds 1


SECTION "Time Data", ROM0
sFramesToCS::
    db $00, $02, $03, $05, $07, $10
    db $12, $13, $15, $17, $18, $20
    db $22, $23, $25, $27, $28, $30
    db $32, $33, $35, $37, $38, $40
    db $42, $43, $45, $47, $48, $50
    db $52, $53, $55, $57, $58, $60
    db $62, $63, $65, $67, $68, $70
    db $72, $73, $75, $77, $78, $80
    db $82, $83, $85, $87, $88, $90
    db $92, $93, $95, $97, $98, $00


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
    ld [wCountDown], a
    ld [wCountDown+1], a
    ld [wSectionMinutes], a
    ld [wSectionSeconds], a
    ld [wSectionFrames], a
    ld a , $FF
    ld [wCountDownZero], a
    ld a, TACF_262KHZ | TACF_START
    ldh [rTAC], a
    ret


    ; Set the countdown timer (in frames) to start at the number in BC.
StartCountdown::
    xor a, a
    ld [wCountDownZero], a
    dec bc
    ld a, c
    ld [wCountDown], a
    ld a, b
    ld [wCountDown+1], a
    ret


    ; Resets the minute-second timer.
ResetGameTime::
    xor a, a
    ld [wMinutes], a
    ld [wSeconds], a
    ld [wFrames], a
    ld [wSectionMinutes], a
    ld [wSectionSeconds], a
    ld [wSectionFrames], a
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
    or a, a
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

    ; Get countdown in BC
    ld a, [wCountDown]
    ld c, a
    ld a, [wCountDown+1]
    ld b, a

    ; Is it zero?
    or a, c
    jr nz, .reduce
    ld a , $FF
    ld [wCountDownZero], a
    jr .clock

.reduce
    xor a, a
    ld [wCountDownZero], a
    dec bc
    ld a, c
    ld [wCountDown], a
    ld a, b
    ld [wCountDown+1], a

.clock
    ld a, [wKillScreenActive]
    cp a, $FF
    ret z

    ld a, [wMinutes]
    cp a, 99
    jr nz, .go
    ld a, [wSeconds]
    cp a, 59
    jr nz, .go
    ld a, [wFrames]
    cp a, 59
    ret z

.go
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


CheckCOOL_REGRET::
    ; Okay if minutes are less than max minutes.
    ld a, [wSectionMinutes]
    cp a, b
    jr c, .success

    ; Check seconds if minutes are equal.
    jr nz, .failure

    ; Okay if seconds are less than max seconds.
    ld a, [wSectionSeconds]
    cp a, c
    jr c, .success

    ; Check frames if seconds are equal.
    jr nz, .failure

    ; Okay if frames are exactly 0.
    ld a, [wSectionFrames]
    cp a, 0
    jr z, .success

.failure
    xor a, a
    ret

.success
    ld a, $FF
    ret


HandleSectionTimers::
    ldh a, [hMode]
    cp a, MODE_PAUSED
    ret z
    cp a, MODE_GAME_OVER
    ret z
    cp a, MODE_PRE_GAME_OVER
    ret z

    ld a, [wKillScreenActive]
    cp a, $FF
    ret z

    ld a, [hCLevel+CLEVEL_ONES]
    cp a, 6
    jr c, .continue
    xor a, a
    ld [wSectionTimerReset], a
.continue

    ld a, [wSectionMinutes]
    cp a, 99
    jr nz, .sectiongo
    ld a, [wSectionSeconds]
    cp a, 59
    jr nz, .sectiongo
    ld a, [wSectionFrames]
    cp a, 59
    ret z

.sectiongo
    ld a, [wSectionFrames]
    inc a
    ld [wSectionFrames], a
    cp a, 60
    ret nz

    xor a, a
    ld [wSectionFrames], a
    ld a, [wSectionSeconds]
    inc a
    ld [wSectionSeconds], a
    cp a, 60
    ret nz

    xor a, a
    ld [wSectionSeconds], a
    ld a, [wSectionMinutes]
    inc a
    ld [wSectionMinutes], a
    ret


ENDC
