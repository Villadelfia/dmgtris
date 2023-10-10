SECTION "Build date", ROM0

    db "Built "
BuildDate::
    db __ISO_8601_UTC__
    db 0
