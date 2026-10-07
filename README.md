# My-printf-in-asm

A simplified printf written in NASM for x86-64 Linux. It follows the System V AMD64 calling convention, so it can be called directly from C. It prints through putc only, one character at a time.

The problem

The goal is to reimplement the core of printf: a function that receives a format string followed by a variable number of arguments, and writes the formatted text to standard output.

The function is called as:

void my_printf(const char *format, ...);

The format string is read character by character:

an ordinary character is printed as it is
a % starts a format specifier, which consumes the next argument

Supported specifiers:

%c: prints one character
%s: prints a null-terminated string
%lu: prints an unsigned 64-bit number in decimal

The difficulty is that everything the C library normally hides has to be done by hand:

finding the arguments: the first five after the format string arrive in rsi, rdx, rcx, r8 and r9, and the rest are on the stack
converting a number to text without any library help
preserving the registers the caller expects to be untouched, and keeping the stack 16-byte aligned at every call
Design
The format string pointer is kept in rbx and the current position in r12. A counter in r14 tracks how many specifiers have been seen, which decides where the next argument is read from.
Arguments 1 to 5 are read from the five argument registers. From the 6th on, the argument is read from the stack at rsp + 64 + 8 * (n - 6). The 64 skips the saved rbp, the five callee-saved registers and the extra slot pushed in the prologue, plus the return address.
Every call to putc is wrapped in pushes and pops of rsi, rdx, rcx, r8 and r9, because putc is allowed to overwrite them and they may still hold arguments that have not been printed.
Strings are printed in a loop until the terminating zero byte.
Numbers are converted by repeated division by 10. Each remainder is pushed on the stack, and the digits are then popped back, which reverses them into the correct order. Every digit is pushed twice so the stack stays 16-byte aligned.
rbp and the callee-saved registers rbx and r12 to r15 are restored before returning.
