IF !DEF(MEMORY_ASM)
DEF MEMORY_ASM EQU 1


SECTION "Memory Functions", ROM0
; Copies data from de to hl, bc bytes
UnsafeMemCopy::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, UnsafeMemCopy
    ret


; Copies data from de to hl, bc bytes
SafeMemCopy::
    wait_vram
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, SafeMemCopy
    ret

; Sets memory from hl to hl+bc to d
UnsafeMemSet::
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or a, c
    jp nz, UnsafeMemSet
    ret


ENDC
