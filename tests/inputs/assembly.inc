; simple Flat Assembler macros

SYS_EXIT = 60
SYS_WRITE = 1

EXIT_CODE = 255

SYS_STDOUT = 1

macro PRINT str_address, len {
	mov rax, SYS_WRITE
	mov rdi, SYS_STDOUT
	mov rsi, str_address
	mov rdx, len
	syscall
}

macro EXIT {
	mov rax, SYS_EXIT
	mov rdi, EXIT_CODE
	syscall
}
