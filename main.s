.intel_syntax noprefix
.global _start
.section .text
_start:
        # socket(AF_INET, SOCK_STREAM, PROTOCOL) 
        mov rdi, 2; mov rsi, 1; mov rdx, 0; mov rax, 0x29;
        syscall

        mov rdi, rax
        cmp rax, 0
        jle exit_1 

        # bind(fd, addr, 16)
        mov rsi, OFFSET addr; mov rdx, 16; mov rax, 0x31;
        syscall

        cmp rax, 0
        jne exit_2

        # listen(fd, 0)
        mov rsi, 0; mov rax, 0x32;
        syscall

        cmp rax, 0
        jne exit_3

server_loop:
        # accept(fd, NULL, NULL)
        mov rsi, 0; mov rdx, 0; mov rax, 0x2b;
        syscall

        mov rbx, rax
        cmp rax, 0
        jg handle_client
        jmp server_loop

handle_client:
        # fork()
        mov rax, 0x39
        syscall

        cmp rax, 0
        je echo
        jmp server_loop

echo:
        push rbp
        mov rbp, rsp
        sub rsp, 1024

        mov rdi, rbx
        mov rsi, rbp
        sub rsi, 1024
read:
        mov rdx, 1024
        mov rax, 0
        syscall
        mov rbx, rax
        cmp rax, 0
        jg write
        jmp stop_reading
write:
        mov rdx, rbx
        mov rax, 1
        syscall
        jmp read

stop_reading:
        mov rsp, rbp
        pop rbp
        
exit_0:
        mov rdi, 0; mov rax, 60;
        syscall

exit_1:
        mov rdi, 1; mov rax, 60;
        syscall
exit_2:
        mov rdi, 2; mov rax, 60;
        syscall
exit_3:
        mov rdi, 3; mov rax, 60;
        syscall

.section .data
addr:
        .hword 2 # AF_INET
        .hword 0x901f # 8080 port
        .zero 12 # address and padding
