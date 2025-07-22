; bootloader.asm
org 0x7C00

start:
    ; Set segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print welcome message
    mov si, welcome
.print_char:
    lodsb
    or al, al
    jz load_shell
    mov ah, 0x0E
    int 0x10
    jmp .print_char

load_shell:
    ; buffer at 0000:0600
    xor ax, ax        ; AX = 0
    mov es, ax        ; ES = 0          
    mov bx, 0x0600    ; offset

    mov ah, 0x02      ; read sectors
    mov al, 3
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    int 0x13
    jc  disk_error

    jmp 0x0000:0x0600 ; run the shell


disk_error:
    mov si, err_msg
.retry:
    lodsb
    or al, al
    jz $
    mov ah, 0x0E
    int 0x10
    jmp .retry

welcome db "Booting Custom Shell...", 0
err_msg db "Disk Read Error!", 0

times 510-($-$$) db 0
dw 0xAA55