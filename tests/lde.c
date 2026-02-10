#include <stdint.h>

//length of common prologue instructions
int GetInstructionLength(uint8_t* code){
    //push rbp (55) -> 1byte
    if(code[0] == 0x55){
        return 1;
    }
    //mov rbp, rsp (48 89 E5) -> 3byte
    if(code[0] == 0x48 && code[1] == 0x89 && code[2] == 0xE5){
        return 3;
    }
    //sub rsp, imm8 (48 83 EC XX) -> 4byte
    if(code[0] == 0x48 && code[1] == 0x83 && code[2] == 0xEC){
        return 4;
    }
    //sub rsp, imm32 (48 81 EC XX XX XX XX) -> 7byte
    if(code[0] == 0x48 && code[1] == 0x81 && code[2] == 0xEC){
        return 7;
    }

    //default fallback(risky!!)
    return 1;
}

//counts length
int CountLength(uint8_t* target){
    uint8_t* code = target;
    int totalLen = 0;

    //atleast 5byte
    while(totalLen < 5){
        int len = GetInstructionLength(code + totalLen);
        totalLen += len;
    }

    return totalLen;
}
