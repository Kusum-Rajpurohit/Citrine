@echo off
nasm -f bin bootloader.asm -o bootloader.bin
nasm -f bin shell.asm -o shell.bin
python make_img.py
qemu-system-i386 -fda os.img
pause