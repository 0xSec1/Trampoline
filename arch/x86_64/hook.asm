section .text
global install_hook
global my_hook

install_hook:
    ;calculate JMP offset
    mov rax, rsi                ;rax = Destination
    sub rax, rdi                ;rax = Destination - Source
    sub rax, 5                  ;rax = Destination - Source - 5 (5 is adjusting distance)

    mov byte [rdi], 0xE9        ;opcode E9(jump) at target[0]
    mov dword [rdi + 1], eax    ;write the 32bit offset at target[1]

    ret

my_hook:
    ;sys_write(fd=1, buf=msg, count=msg_len)
    mov rax, 1                  ;syscall for write
    mov rdi, 1                  ;fd 1 = stdout
    lea rsi, [rel msg]          ;pointer to our string(rip-relative addressing)
    mov rdx, msg_len            ;length of string
    syscall

    ;trampoline not implemented yet so, exit normally
    mov rax, 60                 ;syscall for exit
    xor rdi, rdi                ;exit 0
    syscall

section .data
msg db "[PAYLOAD] Hijacked!! Full control.", 0x0A
msg_len equ $ - msg
