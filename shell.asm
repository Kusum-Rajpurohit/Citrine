org 0x0600

start:
    ; Print welcome message 
    mov si, msg
print_msg:
    lodsb
    or al, al
    jz after_msg
    mov ah, 0x0E
    int 0x10
    jmp print_msg

after_msg:
    jmp prompt

prompt:
    call print_prompt
    call read_input
    call parse_input

    ; Compare command_buffer with "help"
    mov si, command_buffer
    mov di, cmd_help
    call strcmp
    cmp al, 0
    je show_help

    ; Compare command_buffer with "clear"
    mov si, command_buffer
    mov di, cmd_clear
    call strcmp
    cmp al, 0
    je clear_screen

    ; Compare command_buffer with "echo"
    mov si, command_buffer
    mov di, cmd_echo
    call strcmp
    cmp al, 0
    je do_echo

    ; Unknown command
    call print_unknown
    jmp prompt


; -----------------------
; Subroutine: print_prompt
; -----------------------
print_prompt:
    mov ah, 0x0E
    mov al, '>'
    int 0x10
    mov al, ' '
    int 0x10
    ret

; -----------------------
; Subroutine: read_input
; -----------------------
read_input:
    mov di, input_buffer
    xor cx, cx

read_char:
    mov ah, 0
    int 0x16              ; read key → AL
    cmp al, 0x0D
    je done_input

    cmp al, 0x08
    jne store_char

    ; Handle backspace
    cmp cx, 0
    je read_char
    dec cx
    dec di
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp read_char

store_char:
    mov ah, 0x0E
    int 0x10
    mov [di], al
    inc di
    inc cx
    cmp cx, 127
    jae done_input
    jmp read_char

done_input:
    mov al, 0
    mov [di], al
    ; newline
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

; -----------------------
; Subroutine: strcmp
; Compares SI and DI strings
; Returns AL=0 if equal, AL=1 if not
; -----------------------
strcmp:
strcmp_loop:
    lodsb                ; AL ← [SI], SI++
    mov bl, [di]         ; BL ← [DI]
    inc di

    ; Convert both to lowercase if they are Uppercase
    cmp al, 'A'
    jb skip_lower_al
    cmp al, 'Z'
    ja skip_lower_al
    or al, 0x20           ; convert to lowercase
skip_lower_al:

    cmp bl, 'A'
    jb skip_lower_bl
    cmp bl, 'Z'
    ja skip_lower_bl
    or bl, 0x20
skip_lower_bl:

    cmp al, bl
    jne strcmp_not_equal

    or al, al             ; check for null terminator
    jnz strcmp_loop

    mov al, 0             ; equal
    ret

strcmp_not_equal:
    mov al, 1
    ret

; -----------------------
; Subroutine: show_help
; -----------------------
show_help:
    mov si, help_msg
    call print_string
    jmp prompt

; -----------------------
; Subroutine: clear_screen
; -----------------------
clear_screen:
    mov ah, 0
    mov al, 3            ; video mode 3 
    int 0x10
    jmp prompt

; -----------------------
; Subroutine: do_echo
; -----------------------
do_echo:
    mov si, arg_buffer
    call print_string

    ; add newline after echo
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    
    jmp prompt

; -----------------------
; Subroutine: print_unknown
; -----------------------
print_unknown:
    mov si, unknown_cmd
    call print_string
    ret

; -----------------------
; Subroutine: print_string
; -----------------------
print_string:
print_string_next:
    lodsb
    or al, al
    jz print_string_done
    mov ah, 0x0E
    int 0x10
    jmp print_string_next

print_string_done:
    ret

; -----------------------
; Subroutine: parse_input
; Splits input_buffer into command and arg
; -----------------------
parse_input:
    ; SI = source (input_buffer)
    ; DI = command_buffer
    mov si, input_buffer
    mov di, command_buffer

copy_command:
    lodsb
    cmp al, 0
    je done
    cmp al, ' '
    je done
    stosb
    jmp copy_command

done:
    mov byte [di], 0        ; null-terminate command

    ; Skip space
    cmp al, ' '
    jne skip_arg_copy
    ; AL was ' ', SI is now at argument
    mov di, arg_buffer
copy_arg:
    lodsb
    stosb
    cmp al, 0
    jne copy_arg

skip_arg_copy:
    ret

; -----------------------
; Data Section
; -----------------------
msg         db 0x0D, 0x0A, "Welcome to the Shell!", 0x0D, 0x0A, 0
help_msg    db "Supported commands: clear, echo, help", 0x0D, 0x0A, 0
unknown_cmd db "Unknown command.", 0x0D, 0x0A, 0
cmd_help    db "help", 0
cmd_clear   db "clear", 0
cmd_echo    db "echo", 0
input_buffer db 128 dup(0)
command_buffer db 32 dup(0)
arg_buffer     db 96 dup(0)
