# Trampoline
A minimal inline hooking written mostly in NASM assembly and built purely out of curiosity while deepening my assembly skill — a small, educational side project to explore runtime function hooking, trampolines, and low-level x86 tricks.

## What it can do
- Detects Byte length that will be overwritten
- Trampoline
- Page permission handling

## Build & Run
**Prerequisites**: NASM, GCC
```bash
git clone https://github.com/0xSec1/Trampoline.git
cd Trampoline
make
```
