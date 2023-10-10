section "RNG Functions", ROM0
NextByte::
    ; Load seed
    ld hl,wRNGSeed+3
    ld a,[hl-]
    ld b,a
    ld a,[hl-]
    ld c,a
    ld a,[hl-]

    ; Multiply by 0x01010101
    add [hl]
    ld d,a
    adc c
    ld c,a
    adc b
    ld b,a

    ; Add 0x31415927 and write back
    ld a,[hl]
    add $27
    ld [hl+],a
    ld a,d
    adc $59
    ld [hl+],a
    ld a,c
    adc $41
    ld [hl+],a
    ld c,a
    ld a,b
    adc $31
    ld [hl],a
    ld b,a
    ret
