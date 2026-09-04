/* HavenOS-core boot sector. Original 16-bit real mode. */
.code16
.global _start
_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7C00, %sp
    sti
    movb %dl, boot_drive
    movw $msg_load, %si
    call puts
    movb $0x02, %ah
    movb $32, %al
    movb $0x00, %ch
    movb $0x02, %cl
    movb $0x00, %dh
    movb boot_drive, %dl
    movw $0x8000, %bx
    int $0x13
    jc load_fail
    jmp $0x0000, $0x8000
load_fail:
    movw $msg_fail, %si
    call puts
halt:
    hlt
    jmp halt
puts:
    lodsb
    testb %al, %al
    jz 1f
    movb $0x0E, %ah
    movw $0x0007, %bx
    int $0x10
    jmp puts
1:  ret
boot_drive:
    .byte 0
msg_load:
    .asciz "HavenOS-core loading...\r\n"
msg_fail:
    .asciz "Disk read failed.\r\n"
    .org 510
    .word 0xAA55
