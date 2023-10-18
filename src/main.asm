IF !DEF(MAIN_ASM)
DEF MAIN_ASM EQU 1


INCLUDE "globals.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"


SECTION "Globals", HRAM
hGameState:: ds 1


SECTION "Stack", WRAM0
wStack::
    ds STACK_SIZE
wStackEnd::


SECTION "Code Entry Point", ROM0
Main::
    ; Turn off LCD during initialization.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Set up stack
    ld sp, wStackEnd

    ; We use a single set of tiles for the entire game, so we copy it at the start.
    ld de, Tiles
    ld hl, _VRAM
    ld bc, TilesEnd - Tiles
    call UnsafeMemCopy

    ; Make sure both sprites and bg use the same tile data.
    ldh a, [rLCDC]
    or LCDCF_BLK01
    ldh [rLCDC], a

    ; Clear OAM.
    call ClearOAM
    call CopyOAMHandler

    ; Zero out the ram where needed.
    call TimeInit
    call IntrInit
    call InputInit
    call SFXInit

    ; Set up the interrupt handlers.
    call InitializeLCDCInterrupt

    ; Switch to gameplay state.
    call SwitchToGameplay


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
EventLoopPostHandler::

    ; Wait for vblank.
    wait_vblank

    ; Do OAM DMA.
    ; This will chain jump into the vblank handler.
    jp hOAMDMA

    ; The VBlank Handler is expected to end with jp EventLoop.


ENDC
