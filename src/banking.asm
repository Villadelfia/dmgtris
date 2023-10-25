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


IF !DEF(BANKING_ASM)
DEF BANKING_ASM EQU 1


INCLUDE "globals.asm"


SECTION "High Banking Variables", HRAM
hBankBackup: ds 1

; 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, and 0x38
SECTION "Switch Bank", ROM0[$08]
    ; Saves the current bank and switches to the bank in b.
RSTSwitchBank::
    ld a, [rBANKID]
    ldh [hBankBackup], a
    ld a, b
    ld [rROMB0], a
    ret

SECTION "Restore Bank", ROM0[$18]
    ; Restore the bank previously saved. The current one is not saved.
RSTRestoreBank::
    ld a, [hBankBackup]
    ld [rROMB0], a
    ret


ENDC
