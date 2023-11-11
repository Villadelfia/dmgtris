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


IF !DEF(HISCORE_ASM)
DEF HISCORE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Hi Score Data", ROM0
sHiscoreDefaultData::
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "GTR", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "ISD", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "MGT", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "RIS", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "DMG", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "TRI", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, "SDM", GRADE_NONE, RNG_MODE_TGM3, ROT_MODE_ARSTI, DROP_MODE_FIRM, HIG_MODE_OFF
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


SECTION "Hi Score Variables", WRAM0
wTargetHSTable:: ds 2
wWorkingCopy:: ds ((HISCORE_ENTRY_COUNT+1)*(HISCORE_ENTRY_SIZE))


SECTION "Hi Score Functions", ROM0
CheckAndAddHiscore::
    ret

GetTargetHSTable:
    ret

ENDC
