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


IF !DEF(MAIN_ASM)
DEF MAIN_ASM EQU 1


INCLUDE "globals.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"
INCLUDE "res/title_map.inc"


SECTION "High Globals", HRAM
hGameState:: ds 1


SECTION "Globals", WRAM0
wSwapABState:: ds 1
wRNGModeState:: ds 1
wRotModeState:: ds 1
wDropModeState:: ds 1
wSpeedCurveState:: ds 1
wAlways20GState:: ds 1
wInitialA:: ds 1
wInitialB:: ds 1
wInitialC:: ds 1
wInitialD:: ds 1
wInitialE:: ds 1
wInitialH:: ds 1
wInitialL:: ds 1


SECTION "Stack", WRAM0
wStack::
    ds STACK_SIZE + 1
wStackEnd::


SECTION "Code Entry Point", ROM0
Main::
    ; Load the initial registers. For reasons.
    ld [wInitialA], a
    ld a, b
    ld [wInitialB], a
    ld a, c
    ld [wInitialC], a
    ld a, d
    ld [wInitialD], a
    ld a, e
    ld [wInitialE], a
    ld a, h
    ld [wInitialH], a
    ld a, l
    ld [wInitialL], a

    ; Let the DMG have some fun with the initial screen.
    call DoDMGEffect

    ; Turn off LCD during initialization, but not on DMG.
    ld a, [wInitialA]
    cp a, $11
    jr nz, :+

    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Set up stack
:   ld sp, wStackEnd-1

    ; GBC? Double speed mode and set up palettes.
    ld a, [wInitialA]
    cp a, $11
    jr nz, .notgbc
    ld a, KEY1F_PREPARE
    ldh [rKEY1], a
    stop
.notgbc
    ; Initialize the mapper.
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    xor a, a
    ld [rRAMB], a
    ld a, BANK("Static Data")
    ld [rROMB0], a

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, _VRAM
    ld bc, TilesEnd - Tiles
    call SafeMemCopy

    ; Clear OAM.
    call ClearOAM
    call SetNumberSpritePositions
    call CopyOAMHandler

    ; Other initialization.
    call RestoreSRAM
    call TimeInit
    call IntrInit
    call InputInit
    call SFXInit

    ; Set up the interrupt handlers.
    ld a, [wInitialA]
    cp a, $11
    jr z, :+
    wait_vblank
:   call InitializeLCDCInterrupt

    ; Switch to gameplay state.
    call SwitchToTitle


EventLoop::
    ; Play the sound effect, if any.
    call SFXPlay

    ; Wrangle inputs and timers at the start of every frame.
    call GetInput
    call HandleTimers

    ; Call the current state's event handler.
    ld hl, .eventloopjumps
    ldh a, [hGameState]
    ld b, 0
    ld c, a
    add hl, bc
    jp hl

.eventloopjumps
    jp TitleEventLoopHandler
    jp GamePlayEventLoopHandler
EventLoopPostHandler::

    ; Wait for vblank.
    wait_vblank

    ; Do OAM DMA.
    call hOAMDMA

    ; Call the current state's vblank handler.
    ld hl, .vblankjumps
    ldh a, [hGameState]
    ld b, 0
    ld c, a
    add hl, bc
    jp hl

.vblankjumps
    jp TitleVBlankHandler
    jp BlitField
    ; The VBlank Handler is expected to end with jp EventLoop.


ENDC
