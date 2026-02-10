#ifndef TRAMPOLINE_H
#define TRAMPOLINE_H

void install_hook(void* targetAddr, void* payloadAddr, void* trampoline, int length);   //calculate jump and patch the bytes
void my_hook();                                                             //my assembly hook

#endif
