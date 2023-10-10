; MIT License
;
; Copyright (c) 2018-2022 Eldred Habert and contributors
; Originally hosted at https://github.com/ISSOtm/rgbds-structs
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.



DEF STRUCTS_VERSION equs "3.0.1"
MACRO structs_assert
    assert (\1), "rgbds-structs {STRUCTS_VERSION} bug. Please report at https://github.com/ISSOtm/rgbds-structs, and share the above stack trace *and* your code there!"
ENDM


; Call with the expected RGBDS-structs version string to ensure your code
; is compatible with the INCLUDEd version of RGBDS-structs.
; Example: `rgbds_structs_version 2.0.0`
MACRO rgbds_structs_version ; version_string
    DEF CURRENT_VERSION EQUS STRRPL("{STRUCTS_VERSION}", ".", ",")

    ; Undefine `EXPECTED_VERSION` if it does not match `CURRENT_VERSION`
    DEF EXPECTED_VERSION EQUS STRRPL("\1", ".", ",")
    check_ver {EXPECTED_VERSION}, {CURRENT_VERSION}

    IF !DEF(EXPECTED_VERSION)
        FAIL "rgbds-structs version \1 is required, which is incompatible with current version {STRUCTS_VERSION}"
    ENDC

    PURGE CURRENT_VERSION, EXPECTED_VERSION
ENDM

; Checks whether trios of version components match.
; Used internally by `rgbds_structs_version`.
MACRO check_ver ; expected major, minor, patch, current major, minor, patch
    IF (\1) != (\4) || (\2) > (\5) || (\3) > (\6)
        PURGE EXPECTED_VERSION
    ENDC
ENDM


; Begins a struct declaration.
MACRO struct ; struct_name
    IF DEF(STRUCT_NAME) || DEF(NB_FIELDS)
        FAIL "Please close struct definitions using `end_struct`"
    ENDC

    ; Define two internal variables for field definitions
    DEF STRUCT_NAME EQUS "\1"
    DEF NB_FIELDS = 0
    DEF NB_NONALIASES = 0

    ; Initialize _RS to 0 for defining offset constants
    RSRESET
ENDM

; Ends a struct declaration.
MACRO end_struct
    ; Define the number of fields and size in bytes
    DEF {STRUCT_NAME}_nb_fields EQU NB_FIELDS
    DEF {STRUCT_NAME}_nb_nonaliases EQU NB_NONALIASES
    DEF sizeof_{STRUCT_NAME}    EQU _RS

    IF DEF(STRUCTS_EXPORT_CONSTANTS)
        EXPORT {STRUCT_NAME}_nb_fields, sizeof_{STRUCT_NAME}
    ENDC

    ; Purge the internal variables defined by `struct`
    PURGE STRUCT_NAME, NB_FIELDS, NB_NONALIASES
ENDM


; Defines a field of N bytes.
DEF bytes equs "new_field rb,"
DEF words equs "new_field rw,"
DEF longs equs "new_field rl,"
DEF alias equs "new_field rb, 0,"

; Extends a new struct by an existing struct, effectively cloning its fields.
MACRO extends ; struct_type[, sub_struct_name]
    IF !DEF(\1_nb_fields)
        FAIL "Struct \1 isn't defined!"
    ENDC
    IF _NARG != 1 && _NARG != 2
        FAIL "Invalid number of arguments, expected 1 or 2"
    ENDC
    FOR FIELD_ID, \1_nb_fields
        DEF EXTENDS_FIELD EQUS "\1_field{d:FIELD_ID}"
        get_nth_field_info {STRUCT_NAME}, NB_FIELDS

        IF _NARG == 1
            DEF {STRUCT_FIELD_NAME} EQUS "{{EXTENDS_FIELD}_name}"
        ELSE
            DEF {STRUCT_FIELD_NAME} EQUS "\2_{{EXTENDS_FIELD}_name}"
        ENDC
        DEF {STRUCT_FIELD} RB {EXTENDS_FIELD}_size
        IF DEF(STRUCTS_EXPORT_CONSTANTS)
            EXPORT {STRUCT_FIELD}
        ENDC
        DEF {STRUCT_NAME}_{{STRUCT_FIELD_NAME}} EQU {STRUCT_FIELD}
        DEF {STRUCT_FIELD_SIZE} EQU {EXTENDS_FIELD}_size
        DEF {STRUCT_FIELD_TYPE} EQUS "{{EXTENDS_FIELD}_type}"

        purge_nth_field_info

        DEF NB_FIELDS += 1
        IF {EXTENDS_FIELD}_size != 0
            DEF NB_NONALIASES += 1
        ENDC
        PURGE EXTENDS_FIELD
    ENDR
ENDM


; Defines EQUS strings pertaining to a struct's Nth field.
; Used internally by `new_field` and `dstruct`.
MACRO get_nth_field_info ; struct_name, field_id
    DEF STRUCT_FIELD      EQUS "\1_field{d:\2}"       ; prefix for other EQUS
    DEF STRUCT_FIELD_NAME EQUS "{STRUCT_FIELD}_name"  ; field's name
    DEF STRUCT_FIELD_TYPE EQUS "{STRUCT_FIELD}_type"  ; type ("b", "l", or "l")
    DEF STRUCT_FIELD_SIZE EQUS "{STRUCT_FIELD}_size"  ; sizeof(type) * nb_el
ENDM

; Purges the variables defined by `get_nth_field_info`.
; Used internally by `new_field` and `dstruct`.
DEF purge_nth_field_info equs "PURGE STRUCT_FIELD, STRUCT_FIELD_NAME, STRUCT_FIELD_TYPE, STRUCT_FIELD_SIZE"

; Defines a field with a given RS type (`rb`, `rw`, or `rl`).
; Used internally by `bytes`, `words`, and `longs`.
MACRO new_field ; rs_type, nb_elems, field_name
    IF !DEF(STRUCT_NAME) || !DEF(NB_FIELDS)
        FAIL "Please start defining a struct, using `struct`"
    ENDC

    get_nth_field_info {STRUCT_NAME}, NB_FIELDS

    ; Set field name
    DEF {STRUCT_FIELD_NAME} EQUS "\3"
    ; Set field offset
    DEF {STRUCT_FIELD} \1 (\2)
    IF DEF(STRUCTS_EXPORT_CONSTANTS)
        EXPORT {STRUCT_FIELD}
    ENDC
    ; Alias this in a human-comprehensible manner
    DEF {STRUCT_NAME}_\3 EQU {STRUCT_FIELD}
    ; Compute field size
    DEF {STRUCT_FIELD_SIZE} EQU _RS - {STRUCT_FIELD}
    ; Set properties
    DEF {STRUCT_FIELD_TYPE} EQUS STRSUB("\1", 2, 1)

    purge_nth_field_info

    DEF NB_FIELDS += 1
    IF \2 != 0
        DEF NB_NONALIASES += 1
    ENDC
ENDM


; Strips whitespace from the left of a string.
; Used internally by `dstruct`.
MACRO lstrip ; string_variable
    FOR START_POS, 1, STRLEN("{\1}") + 1
        IF !STRIN(" \t", STRSUB("{\1}", START_POS, 1))
            BREAK
        ENDC
    ENDR
    REDEF \1 EQUS STRSUB("{\1}", START_POS)
    PURGE START_POS
ENDM

; Allocates space for a struct in memory.
; If no further arguments are supplied, the space is allocated using `ds`.
; Otherwise, the data is written to memory using the appropriate types.
; For example, a struct defined with `bytes 1, Field1` and `words 3, Field2`
; could take four extra arguments, one byte then three words.
; Each such argument would have an equal sign between the name and value.
MACRO dstruct ; struct_type, instance_name[, ...]
    IF !DEF(\1_nb_fields)
        FAIL "Struct \1 isn't defined!"
    ELIF _NARG != 2 && _NARG != 2 + \1_nb_nonaliases
        ; We must have either a RAM declaration (no data args)
        ; or a ROM one (RAM args + data args)
        FAIL STRFMT("Expected 2 or %u args to `dstruct`, but got {d:_NARG}", 2 + \1_nb_nonaliases)
    ENDC

    ; RGBASM always expands macro args, so `IF _NARG > 2 && STRIN("\3", "=")`
    ; would error out when there are only two args.
    ; Therefore, the condition is checked here (we can't nest the `IF`s over
    ; there because that would require a duplicated `ELSE`).
    DEF IS_NAMED_INSTANTIATION = 0
    IF _NARG > 2
        REDEF IS_NAMED_INSTANTIATION = STRIN("\3", "=")
    ENDC

    IF IS_NAMED_INSTANTIATION
        ; This is a named instantiation; translate that to an ordered one.
        ; This is needed because data has to be laid out in order, so some translation is needed anyway.
        ; And finally, I believe it's better to re-use the existing code at the cost of a single nested macro.

        FOR ARG_NUM, 3, _NARG + 1
            ; Remove leading whitespace to obtain something like ".name=value"
            ; (this enables a simple check for starting with a period)
            REDEF CUR_ARG EQUS "\<ARG_NUM>"
            lstrip CUR_ARG

            ; Ensure that the argument has a name and a value,
            ; separated by an equal sign
            DEF EQUAL_POS = STRIN("{CUR_ARG}", "=")
            IF !EQUAL_POS
                FAIL "\"{CUR_ARG}\" is not a named initializer!"
            ELIF STRCMP(STRSUB("{CUR_ARG}", 1, 1), ".")
                FAIL "\"{CUR_ARG}\" does not start with a period!"
            ENDC

            ; Find out which field the current argument is
            FOR FIELD_ID, \1_nb_fields
                IF !STRCMP(STRSUB("{CUR_ARG}", 2, EQUAL_POS - 2), "{\1_field{d:FIELD_ID}_name}")
                    IF \1_field{d:FIELD_ID}_size == 0
                        FAIL "Cannot initialize an alias"
                    ENDC
                    BREAK ; Match found!
                ENDC
            ENDR

            IF FIELD_ID == \1_nb_fields
                FAIL "\"{CUR_ARG}\" does not match any member of \1"
            ELIF DEF(FIELD_{d:FIELD_ID}_INITIALIZER)
                FAIL "\"{CUR_ARG}\" conflicts with \"{FIELD_{d:FIELD_ID}_ARG}\""
            ENDC

            ; Save the argument to report in case a later argument conflicts with it
            DEF FIELD_{d:FIELD_ID}_ARG EQUS "{CUR_ARG}"

            ; Escape any commas in a multi-byte argument initializer so it can
            ; be passed as one argument to the nested ordered instantiation
            DEF FIELD_{d:FIELD_ID}_INITIALIZER EQUS STRRPL(STRSUB("{CUR_ARG}", EQUAL_POS + 1), ",", "\\,")
        ENDR
        PURGE ARG_NUM, CUR_ARG

        ; Now that we matched each named initializer to their order,
        ; invoke the macro again but without names
        DEF ORDERED_ARGS EQUS "\1, \2"
        FOR FIELD_ID, \1_nb_fields
            IF \1_field{d:FIELD_ID}_size != 0
                REDEF ORDERED_ARGS EQUS "{ORDERED_ARGS}, {FIELD_{d:FIELD_ID}_INITIALIZER}"
                PURGE FIELD_{d:FIELD_ID}_ARG, FIELD_{d:FIELD_ID}_INITIALIZER
            ENDC
        ENDR
        PURGE FIELD_ID

        ; Do the nested ordered instantiation
        dstruct {ORDERED_ARGS} ; purges IS_NAMED_INSTANTIATION
        PURGE ORDERED_ARGS

    ELSE
        ; This is an ordered instantiation, not a named one.

        ; Define the struct's root label
        \2::

        IF DEF(STRUCT_SEPARATOR)
            DEF DSTRUCT_SEPARATOR equs "{STRUCT_SEPARATOR}"
        ELSE
            DEF DSTRUCT_SEPARATOR equs "_"
        ENDC
        ; Define each field
        DEF ARG_NUM = 3
        FOR FIELD_ID, \1_nb_fields
            get_nth_field_info \1, FIELD_ID

            ; Define the label for the field
            \2_{{STRUCT_FIELD_NAME}}::

            IF STRUCT_FIELD_SIZE != 0 ; Skip aliases
                ; Declare the space for the field
                IF ARG_NUM <= _NARG
                    ; ROM declaration; use `db`, `dw`, or `dl`
                    d{{STRUCT_FIELD_TYPE}} \<ARG_NUM>
                    REDEF ARG_NUM = ARG_NUM + 1
                ENDC
                ; Add padding as necessary after the provided initializer
                ; (possibly all of it, especially for RAM use)
                IF {STRUCT_FIELD_SIZE} < @ - \2_{{STRUCT_FIELD_NAME}}
                    FAIL STRFMT("Initializer for %s is %u bytes, expected %u at most", "\2_{{STRUCT_FIELD_NAME}}", @ - \2_{{STRUCT_FIELD_NAME}}, {STRUCT_FIELD_SIZE})
                ENDC
                ds {STRUCT_FIELD_SIZE} - (@ - \2_{{STRUCT_FIELD_NAME}})
            ENDC

            purge_nth_field_info
        ENDR
        PURGE FIELD_ID, ARG_NUM, DSTRUCT_SEPARATOR

        ; Define instance's properties from struct's
        DEF \2_nb_fields EQU \1_nb_fields
        DEF sizeof_\2    EQU @ - (\2)
        structs_assert sizeof_\1 == sizeof_\2

        IF DEF(STRUCTS_EXPORT_CONSTANTS)
            EXPORT \2_nb_fields, sizeof_\2
        ENDC

        PURGE IS_NAMED_INSTANTIATION
    ENDC
ENDM


; Allocates space for an array of structs in memory.
; Each struct will have the index appended to its name **as decimal**.
; For example: `dstructs 32, NPC, wNPC` will define `wNPC0`, `wNPC1`, and so on until `wNPC31`.
; This is a change from the previous version of rgbds-structs, where the index was uppercase hexadecimal.
; Does not support data declarations because I think each struct should be defined individually for that purpose.
MACRO dstructs ; nb_structs, struct_type, instance_name
    IF _NARG != 3
        FAIL "`dstructs` only takes 3 arguments!"
    ENDC

    FOR STRUCT_ID, \1
        dstruct \2, \3{d:STRUCT_ID}
    ENDR
    PURGE STRUCT_ID
ENDM
