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


IF !DEF(TILES_ASM)
DEF TILES_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Tile Functions", ROM0
LoadTitleTiles::
    ld b, BANK_OTHER
    rst RSTSwitchBank

    ld de, sSharedTiles
    ld hl, _VRAM
    ld bc, sSharedTilesEnd - sSharedTiles
    call SafeMemCopy

    ld de, sTitleTiles
    ld hl, _VRAM + (48*16)
    ld bc, sTitleTilesEnd - sTitleTiles
    call SafeMemCopy

    jp RSTRestoreBank

LoadGameplayTiles::
    ld b, BANK_OTHER
    rst RSTSwitchBank

    ld de, sSharedTiles
    ld hl, _VRAM
    ld bc, sSharedTilesEnd - sSharedTiles
    call SafeMemCopy

    ld a, [wInitialA]
    cp a, $11
    jr nz, .dmg

.gbc
    ld de, sGameplayTilesC
    ld hl, _VRAM + (48*16)
    ld bc, sGameplayTilesCEnd - sGameplayTilesC
    call SafeMemCopy
    jp RSTRestoreBank

.dmg
    ld de, sGameplayTilesM
    ld hl, _VRAM + (48*16)
    ld bc, sGameplayTilesMEnd - sGameplayTilesM
    call SafeMemCopy
    jp RSTRestoreBank


ENDC
