section .note.GNU-stack

section .text

global my_printf

extern putc
extern stdout

my_printf:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push r12
	push r13
	push r14
	push r15
	push rbx
	push rax
	mov rbx, rdi
	xor r12, r12 ;number of characters from input string
	xor r14, r14 ;number of arguments after string
	jmp for_loop_string

for_loop_string:
	movzx r13, byte[rbx + r12] ;take each character from input string
	cmp r13, 0 ;see if we reached \0 so the string ended
	je done
	cmp r13, '%' ; if character is % we have a new format to print
	je argument
	push rsi ;save to stack any register that can be altered by call
	push rdx
	push rcx
	push r8
	push r9
	push rax
	mov rdi, r13 ;this is a normal character so we print it
	mov rsi, [stdout]
	call putc
	pop rax
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	inc r12
	jmp for_loop_string

argument:
	inc r14 ;new argument found
	cmp r14, 1 ;see if the thing to print is in second argument/rsi
	je first_arg
	cmp r14, 2 ;see if the thing to print is in third argument/rdx
	je second_arg
	cmp r14, 3 ;see if the thing to print is in second argument/rcx
	je third_arg
	cmp r14, 4 ;see if the thing to print is in second argument/r8
	je fourth_arg
	cmp r14, 5 ;see if the thing to print is in second argument/r9
	je fifth_arg
	jmp stack_argument; we reached the stack for arguments

first_arg:
	inc r12 ;move to the next character after % to see what type data print
	movzx r13, byte[rbx + r12]
	mov r15, rsi ;we store the thing we need to store in r15 for simplity
	cmp r13, 'c' ;format is chat
	je print_char
	cmp r13, 's' ; format is string
	je print_string
	cmp r13, 'l' ;format is lu
	je print_long

second_arg:
	;for any argument type function the logic is the same as for first one
	inc r12
	movzx r13, byte[rbx + r12]
	mov r15, rdx
	cmp r13, 'c'
	je print_char
	cmp r13, 's'
	je print_string
	cmp r13, 'l'
	je print_long

third_arg:
	inc r12
	movzx r13, byte[rbx + r12]
	mov r15, rcx
	cmp r13, 'c'
	je print_char
	cmp r13, 's'
	je print_string
	cmp r13, 'l'
	je print_long

fourth_arg:
	inc r12
	movzx r13, byte[rbx + r12]
	mov r15, r8
	cmp r13, 'c'
	je print_char
	cmp r13, 's'
	je print_string
	cmp r13, 'l'
	je print_long

fifth_arg:
	inc r12
	movzx r13, byte[rbx + r12]
	mov r15, r9
	cmp r13, 'c'
	je print_char
	cmp r13, 's'
	je print_string
	cmp r13, 'l'
	je print_long

stack_argument:
	inc r12
	movzx r13, byte[rbx + r12]
	mov rax, r14
	sub rax, 6 ;remove from count the 6 arguments that are on registers
	imul rax, 8 ;calculate the position the long u will start
	add rax, 64 ;jumps over the registers pushed by me on stack in function
	mov r15, [rsp + rax]
	cmp r13, 'c'
	je print_char
	cmp r13, 's'
	je print_string
	cmp r13, 'l'
	je print_long

print_char:
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push rax
	;pass the arguments for putc functions and save on stack registers
	;the registers saved ar the one used and the one that could be modified by call
	mov rdi, r15 
	mov rsi, [stdout] 
	call putc
	pop rax
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	inc r12 ;go to th next character from first argument of function
	jmp for_loop_string

print_string:
	xor r13, r13
	jmp print_loop

print_loop:
	;print the strig char by char
	movzx r10, byte[r15 + r13]
	cmp r10, 0 ;did we reach end of string
	je prepare_next
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push rax
	mov rdi, r10
	mov rsi, [stdout]
	call putc ;print the char from the string
	pop rax
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	inc r13
	jmp print_loop

prepare_next:
	inc r12
	jmp for_loop_string

print_long:
	inc r12
	inc r12
	cmp r15, 0 ;see if the number is 0
	je number_0
	push rax
	push rbx
	push rcx
	push rdx
	push r11
	push r13
	push rdi
	push rsi
	push r8
	push r9
	xor r11, r11
	xor rcx, rcx ;number of ciphers
	jmp take_number

take_number:
	;the number is not 0 we take each cipher for it
	cmp r15, 0;see if we finished the number's cyphers
	je printing_number
	inc rcx ;
	xor rdx, rdx
	mov rax, r15
	mov rbx, 10 ;make number /10 and mod 10
	div rbx
	mov r15, rax
	push rdx ;push the cipher obtained on stack
	push rdx ;push again to keep stack alligned
	jmp take_number

printing_number:
	cmp rcx, 0 ;there are no more ciphers to print
	je repair_stack
	dec rcx
	pop rdx
	pop rdx ;remove the buffer and take the cipher
	add rdx, '0' ;transform to char
	mov rdi, rdx
	mov rsi, [stdout]
	push rcx ;save the number of ciphers
	sub rsp, 8 ;allign the stack
	call putc
	add rsp, 8 ;restore stack
	pop rcx ;take the number again
	jmp printing_number

repair_stack:
	pop r9
	pop r8
	pop rsi
	pop rdi
	pop r13
	pop r11
	pop rdx
	pop rcx
	pop rbx
	pop rax
	jmp for_loop_string

number_0:
	push rsi
	push rdx
	push rcx
	push r8
	push r9
	push rax
	mov rdi, '0' ;print 0
	mov rsi, [stdout]
	call putc
	pop rax
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi

done:
	pop rax
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret
