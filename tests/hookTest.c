#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>
#include "../include/trampoline.h"

void targetFunction(){
    printf("[TARGET] Original Function running normally\n");
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
    printf("Target Address: %p\n", targetFunction);
    printf("Payload Address: %p\n\n", my_hook);

    printf("Target before hook:\n");
    targetFunction();

    unprotect_memory(targetFunction);

    printf("Installing Hook...\n");
    install_hook(targetFunction, my_hook);

    printf("\nCalling target after hook:\n");
    targetFunction();

    return 0;
}
