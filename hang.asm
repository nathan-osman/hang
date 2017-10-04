; The MIT License (MIT)
;
; Copyright (c) 2017 Nathan Osman
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

%define sys_write        0x01
%define sys_rt_sigaction 0x0d
%define sys_rt_sigreturn 0x0f
%define sys_pause        0x22
%define sys_exit         0x3c

%define SA_RESTORER 0x04000000

%define SIGTERM 0x0f

%define STDOUT 0x01


; Definition of sigaction struct for sys_rt_sigaction
struc sigaction
    .sa_handler  resq 1
    .sa_flags    resq 1
    .sa_restorer resq 1
    .sa_mask     resq 1
endstruc


section .data

    ; Message shown when a syscall fails
    error_msg     db  'syscall error', 0x0a
    error_msg_len equ $ - error_msg

    ; Message shown when SIGTERM is received
    sigterm_msg     db  'SIGTERM received', 0x0a
    sigterm_msg_len equ $ - sigterm_msg


act:
    istruc sigaction
    at sigaction.sa_handler,  dq handler
    at sigaction.sa_flags,    dq SA_RESTORER
    at sigaction.sa_restorer, dq restorer
    iend


section .bss
    val resd 1


section .text
global _start

_start:
    ; Set the handler
    mov rax, sys_rt_sigaction
    mov rdi, SIGTERM
    lea rsi, [act]
    mov rdx, 0x00
    mov r10, 0x08
    syscall

    ; Ensure the syscall succeeded
    cmp rax, 0
    jne error

    ; Pause until a signal is received
    mov rax, sys_pause
    syscall

    ; Upon success, jump to exit
    jmp exit

error:

    ; Display an error message
    mov rax, sys_write
    mov rdi, STDOUT
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall

    ; Set the return value to one
    mov dword [val], 0x01

exit:

    ; Terminate the application gracefully
    mov rax, sys_exit
    mov rdi, [val]
    syscall

handler:

    ; Display a message
    mov rax, sys_write
    mov rdi, STDOUT
    mov rsi, sigterm_msg
    mov rdx, sigterm_msg_len
    syscall

    ret

restorer:

    ; return from the signal handler
    mov rax, sys_rt_sigreturn
    syscall
