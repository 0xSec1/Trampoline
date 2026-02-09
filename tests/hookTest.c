#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>
#include "../include/trampoline.h"

void targetFunction(){
    __asm__("nop;nop;nop;nop;nop;nop;");                                        //5 nop for JMP and 1 for NOP so we dont copy next instruction for trampoline
    printf("[TARGET] Original Function running normally\n");
}

void* create_trampoline(){
    size_t pageSize = sysconf(_SC_PAGESIZE);
    void* p = mmap(NULL, pageSize, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

    if(p == MAP_FAILED){
        perror("memory map failed");
        exit(1);
    }

    return p;
}

//makes code segment writable
void unprotect_memory(void* addr){
    size_t pageSize = sysconf(_SC_PAGESIZE);
    uintptr_t startPage = (uintptr_t)addr & ~(pageSize - 1);                    //page alignment for access control

    if(mprotect((void*)startPage , pageSize, PROT_READ | PROT_WRITE | PROT_EXEC) == -1){
        perror("mprotect failed");
        exit(1);
    }  //Read, Write and Exec permission
}

int main(){
    void* trampoline = create_trampoline();

    printf("Target Address: %p\n", targetFunction);
    printf("Payload Address: %p\n", my_hook);
    printf("Trampoline Address: %p\n\n", trampoline);

    printf("Target before hook:\n");
    targetFunction();

    unprotect_memory(targetFunction);

    printf("Installing Hook...\n");
    install_hook(targetFunction, my_hook, trampoline);

    printf("\nCalling target after hook:\n");
    targetFunction();

    printf("Back to Main\n");

    return 0;
}
