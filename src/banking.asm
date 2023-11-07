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


SECTION "Banking Variables", WRAM0
wBankBackup: ds 4


SECTION "Banking Functions", ROM0
BankingInit::
    ld a, BANK_OTHER
    ld [wBankBackup], a
    ld [wBankBackup+1], a
    ld [wBankBackup+2], a
    ld [wBankBackup+3], a
    ret


SECTION "Switch Bank", ROM0[$08]
    ; Pushes the current bank to the stach, switches to bank in B.
RSTSwitchBank::
    ld a, [wBankBackup+2]
    ld [wBankBackup+3], a
    ld a, [wBankBackup+1]
    ld [wBankBackup+2], a
    ld a, [wBankBackup+0]
    ld [wBankBackup+1], a
    ld a, [rBANKID]
    ld [wBankBackup+0], a
    ld a, b
    ld [rROMB0], a
    ret

SECTION "Restore Bank", ROM0[$28]
    ; Pops a bank from the stack and switches to it.
RSTRestoreBank::
    ld a, [wBankBackup+0]
    ld b, a
    ld a, [wBankBackup+1]
    ld [wBankBackup+0], a
    ld a, [wBankBackup+2]
    ld [wBankBackup+1], a
    ld a, [wBankBackup+3]
    ld [wBankBackup+2], a
    ld a, b
    ld [rROMB0], a
    ret


ENDC
