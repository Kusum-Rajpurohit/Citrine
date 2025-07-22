; shell.asm
org 0x0600

start:
    mov si, msg
.print:
    lodsb
    or al, al
    jz .input_loop
    mov ah, 0x0E
    int 0x10
    jmp .print

.input_loop:
    mov ah, 0x0E
    mov al, '>'
    int 0x10
    mov al, ' '
    int 0x10

.wait_key:
    mov ah, 0
    int 0x16       ; wait for key
    mov ah, 0x0E
    int 0x10       ; print the key
    jmp .input_loop

msg db 0x0D, 0x0A, "Welcome to the Shell!", 0x0D, 0x0A, 0