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


IF !DEF(STATE_TITLE_ASM)
DEF STATE_TITLE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Title Variables", WRAM0
wSelected:: ds 1


SECTION "Title Functions", ROM0
SwitchToTitle::
    ; Turn the screen off if it's on.
    ldh a, [rLCDC]
    and LCDCF_ON
    jr z, :+ ; Screen is already off.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Load the gameplay tilemap.
:   ld de, TitleScreenTilemap
    ld hl, $9800
    ld bc, TitleScreenTilemapEnd - TitleScreenTilemap
    call UnsafeMemCopy

    ; Title screen easter egg.
    ld a, [wInitialC]
    cp a, $14
    jr nz, .notsgb
    ld de, sEasterS0
    ld hl, EASTER_0
    ld bc, 5
    call UnsafeMemCopy
    ld de, sEasterS1
    ld hl, EASTER_1
    ld bc, 5
    call UnsafeMemCopy
    jr .oam

.notsgb
    ld a, [wInitialA]
    cp a, $FF
    jr nz, .notmgb
    ld de, sEasterM0
    ld hl, EASTER_0
    ld bc, 5
    call UnsafeMemCopy
    ld de, sEasterM1
    ld hl, EASTER_1
    ld bc, 5
    call UnsafeMemCopy
    jr .oam

.notmgb
    ld a, [wInitialA]
    cp a, $11
    jr nz, .noegg

    ld a, [wInitialB]
    bit 0, a
    jr nz, .agb
    ld de, sEasterC0
    ld hl, EASTER_0-1
    ld bc, 12
    call UnsafeMemCopy
    ld de, sEasterC1
    ld hl, EASTER_1-1
    ld bc, 12
    call UnsafeMemCopy
    jr .oam

.agb
    ld de, sEasterA0
    ld hl, EASTER_0-1
    ld bc, 12
    call UnsafeMemCopy
    ld de, sEasterA1
    ld hl, EASTER_1-1
    ld bc, 12
    call UnsafeMemCopy
    jr .oam
.noegg

    ; Clear OAM.
.oam
    call ClearOAM
    call SetNumberSpritePositions

    ; Set up the palettes.
    ld a, PALETTE_INVERTED
    set_bg_palette
    set_obj0_palette
    set_obj1_palette

    ; GBC init
    call GBCTitleInit

    ; Install the event loop handlers.
    ld a, 0
    ldh [hGameState], a
    ld [wSelected], a

    ; And turn the LCD back on before we start.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BLK01
    ldh [rLCDC], a

    ; Music start
    call SFXKill
    ld a, MUSIC_MENU
    call SFXEnqueue

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end
    ret


TitleEventLoopHandler::
    call GBCTitleProcess

    ; Start game?
.abstart
    ldh a, [hStartState]
    ld b, a
    ldh a, [hAState]
    ld c, a
    ldh a, [hBState]
    or a, b
    or a, c
    cp a, 1
    jr nz, .up
    call SwitchToGameplay
    jp EventLoopPostHandler

    ; Change menu selection?
.up
    ldh a, [hUpState]
    cp a, 1
    jr nz, .down
    ld a, [wSelected]
    cp a, 0
    jr z, :+
    dec a
    ld [wSelected], a
    jp EventLoopPostHandler
:   ld a, TITLE_OPTIONS-1
    ld [wSelected], a
    jp EventLoopPostHandler

.down
    ldh a, [hDownState]
    cp a, 1
    jr nz, .left
    ld a, [wSelected]
    cp a, TITLE_OPTIONS-1
    jr z, :+
    inc a
    ld [wSelected], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wSelected], a
    jp EventLoopPostHandler

.left
    ldh a, [hLeftState]
    cp a, 1
    jp z, DecrementOption
    cp a, 16
    jr c, .right
    ldh a, [hFrameCtr]
    and 3
    cp a, 3
    jr nz, .right
    jp DecrementOption

.right
    ldh a, [hRightState]
    cp a, 1
    jp z, IncrementOption
    cp a, 16
    jr c, .done
    ldh a, [hFrameCtr]
    and 3
    cp a, 3
    jr nz, .done
    jp IncrementOption

.done
    jp EventLoopPostHandler

DecrementOption:
.opt0
    ld a, [wSelected]
    cp a, 0
    jr nz, .opt1
    ld a, [wSwapABState]
    cp a, 0
    jr z, :+
    dec a
    ld [wSwapABState], a
    ld [rSwapABState], a
    jp EventLoopPostHandler
:   ld a, BUTTON_MODE_COUNT-1
    ld [wSwapABState], a
    ld [rSwapABState], a
    jp EventLoopPostHandler

.opt1
    cp a, 1
    jr nz, .opt2
    ld a, [wRNGModeState]
    cp a, 0
    jr z, :+
    dec a
    ld [wRNGModeState], a
    ld [rRNGModeState], a
    jp EventLoopPostHandler
:   ld a, RNG_MODE_COUNT-1
    ld [wRNGModeState], a
    ld [rRNGModeState], a
    jp EventLoopPostHandler

.opt2
    cp a, 2
    jr nz, .opt3
    ld a, [wRotModeState]
    cp a, 0
    jr z, :+
    dec a
    ld [wRotModeState], a
    ld [rRotModeState], a
    jp EventLoopPostHandler
:   ld a, ROT_MODE_COUNT-1
    ld [wRotModeState], a
    ld [rRotModeState], a
    jp EventLoopPostHandler

.opt3
    cp a, 3
    jr nz, .opt4
    ld a, [wDropModeState]
    cp a, 0
    jr z, :+
    dec a
    ld [wDropModeState], a
    ld [rDropModeState], a
    jp EventLoopPostHandler
:   ld a, DROP_MODE_COUNT-1
    ld [wDropModeState], a
    ld [rDropModeState], a
    jp EventLoopPostHandler

.opt4
    cp a, 4
    jr nz, .opt5
    ld a, [wSpeedCurveState]
    cp a, 0
    jr z, :+
    dec a
    ld [wSpeedCurveState], a
    ld [rSpeedCurveState], a
    call InitSpeedCurve
    jp EventLoopPostHandler
:   ld a, SCURVE_COUNT-1
    ld [wSpeedCurveState], a
    ld [rSpeedCurveState], a
    call InitSpeedCurve
    jp EventLoopPostHandler

.opt5
    cp a, 5
    jr nz, .opt6
    ld a, [wAlways20GState]
    cp a, 0
    jr z, :+
    dec a
    ld [wAlways20GState], a
    ld [rAlways20GState], a
    jp EventLoopPostHandler
:   ld a, HIG_MODE_COUNT-1
    ld [wAlways20GState], a
    ld [rAlways20GState], a
    jp EventLoopPostHandler

.opt6
    jr DecrementLevel
    jp EventLoopPostHandler

DecrementLevel:
    ; Decrement
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld bc, -12
    add hl, bc
    ld a, l
    ldh [hStartSpeed], a
    ld [rSelectedStartLevel], a
    ld a, h
    ldh [hStartSpeed+1], a
    ld [rSelectedStartLevel+1], a
    jp CheckLevelRange


IncrementOption:
.opt0
    ld a, [wSelected]
    cp a, 0
    jr nz, .opt1
    ld a, [wSwapABState]
    cp a, BUTTON_MODE_COUNT-1
    jr z, :+
    inc a
    ld [wSwapABState], a
    ld [rSwapABState], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wSwapABState], a
    ld [rSwapABState], a
    jp EventLoopPostHandler

.opt1
    cp a, 1
    jr nz, .opt2
    ld a, [wRNGModeState]
    cp a, RNG_MODE_COUNT-1
    jr z, :+
    inc a
    ld [wRNGModeState], a
    ld [rRNGModeState], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wRNGModeState], a
    ld [rRNGModeState], a
    jp EventLoopPostHandler

.opt2
    cp a, 2
    jr nz, .opt3
    ld a, [wRotModeState]
    cp a, ROT_MODE_COUNT-1
    jr z, :+
    inc a
    ld [wRotModeState], a
    ld [rRotModeState], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wRotModeState], a
    ld [rRotModeState], a
    jp EventLoopPostHandler

.opt3
    cp a, 3
    jr nz, .opt4
    ld a, [wDropModeState]
    cp a, DROP_MODE_COUNT-1
    jr z, :+
    inc a
    ld [wDropModeState], a
    ld [rDropModeState], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wDropModeState], a
    ld [rDropModeState], a
    jp EventLoopPostHandler

.opt4
    cp a, 4
    jr nz, .opt5
    ld a, [wSpeedCurveState]
    cp a, SCURVE_COUNT-1
    jr z, :+
    inc a
    ld [wSpeedCurveState], a
    ld [rSpeedCurveState], a
    call InitSpeedCurve
    jp EventLoopPostHandler
:   xor a, a
    ld [wSpeedCurveState], a
    ld [rSpeedCurveState], a
    call InitSpeedCurve
    jp EventLoopPostHandler

.opt5
    cp a, 5
    jr nz, .opt6
    ld a, [wAlways20GState]
    cp a, HIG_MODE_COUNT-1
    jr z, :+
    inc a
    ld [wAlways20GState], a
    ld [rAlways20GState], a
    jp EventLoopPostHandler
:   xor a, a
    ld [wAlways20GState], a
    ld [rAlways20GState], a
    jp EventLoopPostHandler

.opt6
    jr IncrementLevel
    jp EventLoopPostHandler

IncrementLevel:
    ; Increment
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld bc, 12
    add hl, bc
    ld a, l
    ldh [hStartSpeed], a
    ld [rSelectedStartLevel], a
    ld a, h
    ldh [hStartSpeed+1], a
    ld [rSelectedStartLevel+1], a
    jp CheckLevelRange

InitSpeedCurve:
    ld a, [wSpeedCurveState]
    call GetStart

.set
    ld a, l
    ldh [hStartSpeed], a
    ld [rSelectedStartLevel], a
    ld a, h
    ldh [hStartSpeed+1], a
    ld [rSelectedStartLevel+1], a
    ret



GetEnd:
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DMGT
    jr nz, :+
    ld bc, sSpeedCurveEnd
    ret
:   cp a, SCURVE_TGM1
    jr nz, :+
    ld bc, sTGM1SpeedCurveEnd
    ret
:   cp a, SCURVE_TGM3
    jr nz, :+
    ld bc, sTGM3SpeedCurveEnd
    ret
:   cp a, SCURVE_DEAT
    jr nz, :+
    ld bc, sDEATSpeedCurveEnd
    ret
:   cp a, SCURVE_SHIR
    jr nz, :+
    ld bc, sSHIRSpeedCurveEnd
    ret
:   ld bc, sCHILSpeedCurveEnd
    ret

GetStart:
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DMGT
    jr nz, :+
    ld hl, sSpeedCurve
    ret
:   cp a, SCURVE_TGM1
    jr nz, :+
    ld hl, sTGM1SpeedCurve
    ret
:   cp a, SCURVE_TGM3
    jr nz, :+
    ld hl, sTGM3SpeedCurve
    ret
:   cp a, SCURVE_DEAT
    jr nz, :+
    ld hl, sDEATSpeedCurve
    ret
:   cp a, SCURVE_SHIR
    jr nz, :+
    ld hl, sSHIRSpeedCurve
    ret
:   ld hl, sCHILSpeedCurve
    ret

CheckLevelRange:
    ; At end?
    call GetEnd
    ldh a, [hStartSpeed]
    cp a, c
    jr nz, .notatend
    ldh a, [hStartSpeed+1]
    cp a, b
    jr nz, .notatend
    call GetStart
    ld a, l
    ld [rSelectedStartLevel], a
    ldh [hStartSpeed], a
    ld a, h
    ld [rSelectedStartLevel+1], a
    ldh [hStartSpeed+1], a

.notatend
    ld de, -12

    call GetStart
    add hl, de
    ldh a, [hStartSpeed]
    cp a, l
    jr nz, .notatstart
    ldh a, [hStartSpeed+1]
    cp a, h
    jr nz, .notatstart

    call GetEnd
    ld h, b
    ld l, c
    add hl, de
    ld a, l
    ld [rSelectedStartLevel], a
    ldh [hStartSpeed], a
    ld a, h
    ld [rSelectedStartLevel+1], a
    ldh [hStartSpeed+1], a

.notatstart
    jp EventLoopPostHandler


TitleVBlankHandler::
    call ToATTR

    ld a, TILE_UNSELECTED
    ld hl, TITLE_OPTION_0
    ld [hl], a
    ld hl, TITLE_OPTION_1
    ld [hl], a
    ld hl, TITLE_OPTION_2
    ld [hl], a
    ld hl, TITLE_OPTION_3
    ld [hl], a
    ld hl, TITLE_OPTION_4
    ld [hl], a
    ld hl, TITLE_OPTION_5
    ld [hl], a
    ld hl, TITLE_OPTION_6
    ld [hl], a

    ld a, [wSelected]
    ld hl, TITLE_OPTION_0
    cp a, 0
    jr z, :+
    ld hl, TITLE_OPTION_1
    cp a, 1
    jr z, :+
    ld hl, TITLE_OPTION_2
    cp a, 2
    jr z, :+
    ld hl, TITLE_OPTION_3
    cp a, 3
    jr z, :+
    ld hl, TITLE_OPTION_4
    cp a, 4
    jr z, :+
    ld hl, TITLE_OPTION_5
    cp a, 5
    jr z, :+
    ld hl, TITLE_OPTION_6

:   ld a, TILE_SELECTED
    ld [hl], a

    ; Draw option 0.
    xor a, a
    ld b, a
    ld a, [wSwapABState]
    sla a
    sla a
    ld c, a
    ld hl, sOption0
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_0+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 1.
    xor a, a
    ld b, a
    ld a, [wRNGModeState]
    sla a
    sla a
    ld c, a
    ld hl, sOption1
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_1+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 2.
    xor a, a
    ld b, a
    ld a, [rRotModeState]
    sla a
    sla a
    ld c, a
    ld hl, sOption2
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_2+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 3.
    xor a, a
    ld b, a
    ld a, [rDropModeState]
    sla a
    sla a
    ld c, a
    ld hl, sOption3
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_3+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 5.
    xor a, a
    ld b, a
    ld a, [wSpeedCurveState]
    sla a
    sla a
    ld c, a
    ld hl, sOption4
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_4+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 5.
    xor a, a
    ld b, a
    ld a, [wAlways20GState]
    sla a
    sla a
    ld c, a
    ld hl, sOption5
    add hl, bc
    ld d, h
    ld e, l
    ld hl, TITLE_OPTION_5+TITLE_OPTION_OFFSET
    ld bc, 4
    call UnsafeMemCopy

    ; Draw option 6.
    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld a, [hl]
    swap a
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_OPTION_6+TITLE_OPTION_OFFSET+2
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    ld a, [hl]
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_OPTION_6+TITLE_OPTION_OFFSET+3
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    inc hl
    ld a, [hl]
    swap a
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_OPTION_6+TITLE_OPTION_OFFSET+0
    ld [hl], a

    ldh a, [hStartSpeed]
    ld l, a
    ldh a, [hStartSpeed+1]
    ld h, a
    inc hl
    ld a, [hl]
    and a, $0F
    ld b, a
    ld a, TILE_0
    add a, b
    ld hl, TITLE_OPTION_6+TITLE_OPTION_OFFSET+1
    ld [hl], a
    jp EventLoop


ENDC
