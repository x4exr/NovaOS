clang -m32 -c "src/boot.s" -o "bin/boot.o" -march=i386
clang -m32 -c -ffreestanding "src/kernel32.c" -o "bin/krnl32.o" -Wall -Wextra -march=i386
ld -m elf_i386 -T linker.ld -o bin/Nova.bin -O2 -nostdlib bin/boot.o bin/krnl32.o

if grub-file --is-x86-multiboot bin/Nova.bin; then
	echo multiboot confirmed
	mkdir -p isodir/boot/grub

	cp bin/Nova.bin isodir/boot/Nova.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	cp a.txt isodir/a.txt

	grub-mkrescue -o bin/Nova.iso isodir
	qemu-img convert -f raw -O qcow2 bin/Nova.iso bin/Nova.qcow2
	qemu-system-x86_64 -m 256m -soundhw pcspk -debugcon stdio -drive file=bin/Nova.qcow2,format=qcow2
	echo ' done '
else
	echo the file is not multiboot
fi