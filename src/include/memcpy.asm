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
