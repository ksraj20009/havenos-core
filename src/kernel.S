/* HavenOS-core kernel. Original 16-bit real-mode shell. */
.code16
.global kstart
kstart:
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw $0x9000, %ax
    movw %ax, %ss
    movw $0xFFFE, %sp
    call clear
    movw $banner, %si
    call puts
    jmp prompt
prompt:
    movw $prompt_s, %si
    call puts
    call read_line
    call handle
    jmp prompt
read_line:
    movw $cmdbuf, %di
    xorw %cx, %cx
rl:
    xorw %ax, %ax
    int $0x16
    cmpb $0x0D, %al
    je rl_done
    cmpb $0x08, %al
    je rl_bs
    cmpb $0x20, %al
    jb rl
    cmpw $78, %cx
    jae rl
    stosb
    incw %cx
    movb $0x0E, %ah
    movw $0x0007, %bx
    int $0x10
    jmp rl
rl_bs:
    testw %cx, %cx
    jz rl
    decw %di
    decw %cx
    movw $bs_s, %si
    call puts
    jmp rl
rl_done:
    movb $0, (%di)
    movw $nl, %si
    call puts
    ret
handle:
    movw $cmdbuf, %si
    call skip_sp
    movw %si, %bx
    movw $c_help, %di
    call cmd_eq
    jc 1f
    movw $help_txt, %si
    call puts
    ret
1:
    movw %bx, %si
    movw $c_about, %di
    call cmd_eq
    jc 2f
    movw $about_txt, %si
    call puts
    ret
2:
    movw %bx, %si
    movw $c_clear, %di
    call cmd_eq
    jc 3f
    call clear
    ret
3:
    movw %bx, %si
    movw $c_echo, %di
    call cmd_eq
    jc 4f
    call skip_word
    call skip_sp
    call puts
    movw $nl, %si
    call puts
    ret
4:
    movw %bx, %si
    movw $c_mem, %di
    call cmd_eq
    jc 5f
    int $0x12
    movw $mem_pre, %si
    call puts
    call print_dec
    movw $mem_post, %si
    call puts
    ret
5:
    movw %bx, %si
    movw $c_reboot, %di
    call cmd_eq
    jc 6f
    int $0x19
    ret
6:
    movw %bx, %si
    movw $c_halt, %di
    call cmd_eq
    jc 7f
    movw $bye, %si
    call puts
    cli
    hlt
    jmp .
7:
    movw %bx, %si
    cmpb $0, (%si)
    je 8f
    movw $unk, %si
    call puts
8:
    ret
cmd_eq:
    pushw %si
ce:
    movb (%di), %al
    testb %al, %al
    jz ce_end
    movb (%si), %ah
    orb $0x20, %ah
    orb $0x20, %al
    cmpb %al, %ah
    jne ce_no
    incw %si
    incw %di
    jmp ce
ce_end:
    movb (%si), %al
    cmpb $0, %al
    je ce_yes
    cmpb $' ', %al
    je ce_yes
ce_no:
    popw %si
    stc
    ret
ce_yes:
    popw %dx
    clc
    ret
skip_sp:
    movb (%si), %al
    cmpb $' ', %al
    jne 1f
    incw %si
    jmp skip_sp
1:  ret
skip_word:
    movb (%si), %al
    testb %al, %al
    jz 1f
    cmpb $' ', %al
    je 1f
    incw %si
    jmp skip_word
1:  ret
clear:
    movb $0x00, %ah
    movb $0x03, %al
    int $0x10
    ret
puts:
    lodsb
    testb %al, %al
    jz 1f
    movb $0x0E, %ah
    movw $0x0007, %bx
    int $0x10
    jmp puts
1:  ret
print_dec:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    xorw %cx, %cx
    movw $10, %bx
pd1:
    xorw %dx, %dx
    divw %bx
    pushw %dx
    incw %cx
    testw %ax, %ax
    jnz pd1
pd2:
    popw %dx
    addb $'0', %dl
    movb $0x0E, %ah
    movb %dl, %al
    movw $0x0007, %bx
    int $0x10
    loop pd2
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret
banner:
    .ascii "HavenOS-core 0.1\r\n"
    .asciz "Original boot + kernel. Type help\r\n\r\n"
prompt_s:
    .asciz "haven> "
nl:
    .asciz "\r\n"
bs_s:
    .asciz "\b \b"
unk:
    .asciz "Unknown command. Type help.\r\n"
bye:
    .asciz "Halted.\r\n"
c_help: .asciz "help"
c_about: .asciz "about"
c_clear: .asciz "clear"
c_echo: .asciz "echo"
c_mem: .asciz "mem"
c_reboot: .asciz "reboot"
c_halt: .asciz "halt"
help_txt:
    .ascii "help about echo clear mem reboot halt\r\n"
    .asciz ""
about_txt:
    .asciz "HavenOS-core is an original tiny kernel. Not a renamed tree.\r\n"
mem_pre:
    .asciz "BIOS reports "
mem_post:
    .asciz " KB base memory.\r\n"
cmdbuf:
    .space 82
