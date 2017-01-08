; boot.s
; setup a temporary stack
; and jump into c


section .text

global boot
extern kmain

boot:
  mov esp, temp_kstack + 4096         ; move stack pointer to top of stack
  push ebx

  call kmain

.loop:
  ;xchg	bx, bx								; Enter debug through magic Bochs breakpoint
  jmp .loop                   ; loop forever


section .bss

  align 4
temp_kstack:
  resb 4096                           ; reserve 4kb for a temporary stack
