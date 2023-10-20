IF !DEF(MAIN_ASM)
DEF MAIN_ASM EQU 1


INCLUDE "globals.asm"
INCLUDE "res/tiles.inc"
INCLUDE "res/gameplay_map.inc"
INCLUDE "res/title_map.inc"


SECTION "Globals", HRAM
hGameState:: ds 1


SECTION "Stack", WRAM0
wStack::
    ds STACK_SIZE + 1
wStackEnd::


SECTION "Code Entry Point", ROM0
Main::
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

    ; Zero out the ram where needed.
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

    ; The VBlank Handler is expected to end with jp EventLoop.


ENDC
