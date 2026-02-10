section .text
global install_hook
global my_hook
; global copyInstruction
; global overwrite
; global nopWrite
; global complete

; rdi= original_func, rsi= hook, rdx= trampoline, rcx= length
install_hook:
    push rbx
    push r12

    mov r12, rcx
    xor rbx, rbx

copyInstruction:
    cmp rbx, r12                 ;if i>=length then break
    jge overwrite

    mov al, byte[rdi + rbx]     ;read from original function
    mov byte[rdx + rbx], al     ;write to trampoline

    inc rbx
    jmp copyInstruction

overwrite:
    ;now jump after n bytes trampoline-> [original_func + length]
    ;return to = rdi + length from trampoline
    mov rbx, rdi                ;rbx = original_func
    add rbx, r12                ;rbx + length here we have to land

    lea rax, [rdx + r12]        ;addr of trampoline where JMP will be written

    ;write jmp [RIP+0] (absolute indirect jump)
    mov byte[rax], 0xFF
    mov byte[rax + 1], 0x25
    mov dword[rax + 2], 0x00000000

    mov [rax + 6], rbx
    mov [trampoline_addr], rdx  ;addr of trampoline

    ;calculate JMP offset
    mov rax, rsi                ;rax = Destination
    sub rax, rdi                ;rax = Destination - Source
    sub rax, 5                  ;rax = Destination - Source - 5 (5 is adjusting distance)

    mov byte [rdi], 0xE9        ;opcode E9(jump) at target[0]
    mov dword [rdi + 1], eax    ;write the 32bit offset at target[1]
    mov rbx, 5                  ;write NOP after this offset

nopWrite:
    cmp rbx, r12
    jge complete

    mov byte[rdi + rbx], 0x90   ;write NOP
    inc rbx
    jmp nopWrite

complete:
    pop r12
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
