section .text
global install_hook
global my_hook

; rdi= original_func, rsi= hook, rdx= trampoline
install_hook:
    push rbx

    ;copy first 5 bytes of original_func to trampoline
    mov eax, dword[rdi]         ;read first 4 bytes
    mov dword[rdx], eax         ;write those bytes to trampoline addr
    mov al, byte[rdi + 4]       ;read 5th byte
    mov byte[rdx + 4], al       ;write to trampoline

    ;now jump after 5bytes trampoline-> [original_func + 5]
    ;return to = rdi + 5 from trampoline
    mov rbx, rdi                ;rbx = original_func
    add rbx, 5                  ;rbx + 5 here we have to land

    ;write jmp [RIP+0] (absolute indirect jump)
    mov byte[rdx + 5], 0xFF
    mov byte[rdx + 6], 0x25
    mov dword[rdx + 7], 0x00000000

    mov [rdx + 11], rbx
    mov [trampoline_addr], rdx  ;addr of trampoline

    ;calculate JMP offset
    mov rax, rsi                ;rax = Destination
    sub rax, rdi                ;rax = Destination - Source
    sub rax, 5                  ;rax = Destination - Source - 5 (5 is adjusting distance)

    mov byte [rdi], 0xE9        ;opcode E9(jump) at target[0]
    mov dword [rdi + 1], eax    ;write the 32bit offset at target[1]

    pop rbx
    ret

my_hook:
    ;save context
    pushfq
    push rax
    push rcx
    push rdx
    push rbx
    push rbp
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    ;sys_write(fd=1, buf=msg, count=msg_len)
    mov rax, 1                  ;syscall for write
    mov rdi, 1                  ;fd 1 = stdout
    lea rsi, [rel msg]          ;pointer to our string(rip-relative addressing)
    mov rdx, msg_len            ;length of string
    syscall

    pop r15                     ; Restore in reverse order
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rbp
    pop rbx
    pop rdx
    pop rcx
    pop rax
    popfq

    jmp [rel trampoline_addr]

section .data
msg db "[PAYLOAD] Hijacked!! Full control.", 0x0A
msg_len equ $ - msg

section .bss
trampoline_addr resq 1          ;reserve 8bytes for ptr to addr of trampoline
