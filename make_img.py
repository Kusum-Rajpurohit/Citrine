def pad(file, size):
    with open(file, "ab") as f:
        f.write(b'\x00' * (size - f.tell()))

with open("os.img", "wb") as img:
    img.write(b"\x00" * 512 * 2880)

with open("bootloader.bin", "rb") as b:
    boot = b.read()
with open("os.img", "r+b") as img:
    img.write(boot)

with open("shell.bin", "rb") as s:
    shell = s.read()
with open("os.img", "r+b") as img:
    img.seek(512 * 1)  # Sector 2
    img.write(shell)