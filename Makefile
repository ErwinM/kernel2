OBJECTS = \
	boot.o\
	kmain.o\

CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
         -nostartfiles -nodefaultlibs -Wall -Wextra -c
LDFLAGS = -T link.ld -melf_i386
AS = nasm
ASFLAGS = -f elf

all: kernel.elf
	#-nostdinc -I. -c

ULIB = ulib.o usys.o printf.o umalloc2.o

init: init.o $(ULIB)
	ld -T ulink.ld -m elf_i386 -Ttext 0 -o init.elf init.o $(ULIB)
	./mk_ramdsk init.elf init.elf sh sh ls ls

sh: sh.o $(ULIB)
	ld -T ulink.ld -m elf_i386 -Ttext 0 -o sh sh.o $(ULIB)
	./mk_ramdsk init.elf init.elf sh sh ls ls

ls: ls.o $(ULIB)
	ld -T ulink.ld -m elf_i386 -Ttext 0 -o ls ls.o $(ULIB)
	./mk_ramdsk init.elf init.elf sh sh ls ls

initcode:
	nasm initcode.s -o initcode.out
	ld -e start -r -b binary -m elf_i386 -Ttext 0 -o initcode.o initcode.out
	#objcopy -S -O binary initcode.out initcode


kernel.elf: $(OBJECTS)
	ld -T link.ld -m elf_i386 -o kernel.elf $(OBJECTS)

mk_ramdsk: mk_ramdsk.c
	gcc -o mk_ramdsk mk_ramdsk.c


os.iso: kernel.elf
	cp kernel.elf iso/boot/kernel.elf
	cp initrd.img iso/boot/initrd.img
	genisoimage -R                              \
                -b boot/grub/stage2_eltorito    \
                -no-emul-boot                   \
                -boot-load-size 4               \
                -A os                           \
                -input-charset utf8             \
                -quiet                          \
                -boot-info-table                \
                -o os.iso                       \
                iso

run: os.iso
	bochs -f bochsrc.txt -q

%.o: %.c
	$(CC) $(CFLAGS)  $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf *.o kernel.elf os.iso initcode initcode.out
