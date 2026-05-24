CC = i686-elf-gcc

CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -fno-pie -fno-stack-protector
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib -Wl,--build-id=none

OBJS = boot/boot.o kernel/kernel.o

all: kernel.bin

boot/boot.o: boot/boot.s
	$(CC) $(CFLAGS) -c boot/boot.s -o boot/boot.o

kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c kernel/kernel.c -o kernel/kernel.o

kernel.bin: $(OBJS) linker.ld
	$(CC) $(LDFLAGS) -o kernel.bin $(OBJS) -lgcc
	grub-file --is-x86-multiboot kernel.bin

iso: kernel.bin
	mkdir -p iso/boot/grub
	cp kernel.bin iso/boot/kernel.bin
	grub-mkrescue -o artemos.iso iso

run: iso
	qemu-system-i386 -cdrom artemos.iso

clean:
	rm -f boot/*.o kernel/*.o kernel.bin artemos.iso iso/boot/kernel.bin
