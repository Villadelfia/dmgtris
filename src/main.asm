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
hSwapAB:: ds 1
hSimulationMode:: ds 1

SECTION "Globals", WRAM0
wInitialA:: ds 1
wInitialB:: ds 1
wInitialC:: ds 1
wInitialD:: ds 1
wInitialE:: ds 1
wInitialH:: ds 1
wInitialL:: ds 1


SECTION "Persistent Globals", SRAM
rMagic:: ds 3
rSwapAB:: ds 1
rSimulationMode:: ds 1


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

    ; Turn off LCD during initialization.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Set up stack
    ld sp, wStackEnd-1

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, _VRAM
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; Clear OAM.
    call ClearOAM
    call SetNumberSpritePositions
    call CopyOAMHandler

    ; Enable RAM. (Not actually needed since we don't ACTUALLY use an MBC, but without this emulators shit the bed.)
    ld hl, rRAMG
    ld a, CART_SRAM_ENABLE
    ld [hl], a

    ; Check for save data.
    ld a, [rMagic]
    cp a, "T"
    jr nz, .nosavedata
    ld a, [rMagic+1]
    cp a, "G"
    jr nz, .nosavedata
    ld a, [rMagic+1]
    cp a, "M"
    jr nz, .nosavedata

.savedata
    ld a, [rSwapAB]
    ldh [hSwapAB], a
    ld a, [rSimulationMode]
    ldh [hSimulationMode], a
    jr .otherinit

.nosavedata
    ld a, "T"
    ld [rMagic], a
    ld a, "G"
    ld [rMagic+1], a
    ld a, "M"
    ld [rMagic+2], a
    xor a, a
    ldh [hSwapAB], a
    ld [rSwapAB], a
    ld a, MODE_TGM2
    ldh [hSimulationMode], a
    ld [rSimulationMode], a

.otherinit
    ld hl, sSpeedCurve
    ld a, l
    ldh [hStartSpeed], a
    ld a, h
    ldh [hStartSpeed+1], a
    call TimeInit
    call IntrInit
    call InputInit
    call SFXInit

    ; Set up the interrupt handlers.
    call InitializeLCDCInterrupt

    ; Switch to gameplay state.
    call SwitchToTitle


EventLoop::
    ; Play the sound effect, if any.
    call SFXPlay

    ; Wrangle inputs and timers at the start of every frame.
    call GetInput
    call HandleTimers

    ; Call the current state's event handler.
    ld b, 0
    ldh a, [hGameState]
    cp a, b
    jp nz, GamePlayEventLoopHandler
    jp TitleEventLoopHandler
EventLoopPostHandler::

    ; Wait for vblank.
    wait_vblank

    ; Do OAM DMA.
    ; This will chain jump into the vblank handler.
    jp hOAMDMA

    ; The VBlank Handler is expected to end with jr EventLoop.


ENDC
