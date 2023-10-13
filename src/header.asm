SECTION "Cartridge Header", ROM0[$100]
    nop
    jp Main
    ds $150 - @, 0
