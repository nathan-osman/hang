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
%use smartalign
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
align 16
    ; Message shown when a syscall fails
    error_msg     db  'syscall error', 0x0a
    error_msg_len equ $ - error_msg
    ; Message shown when SIGTERM is received
    sigterm_msg     db  'SIGTERM received', 0x0a
    sigterm_msg_len equ $ - sigterm_msg


align 16
act:
    istruc sigaction
    at sigaction.sa_handler,  dq handler
    at sigaction.sa_flags,    dq SA_RESTORER
    at sigaction.sa_restorer, dq restorer
    iend

section .text
global _start
align 16
_start:
    ; Set the handler
    xor edx, edx; rdx=0
    lea eax, [rdx+sys_rt_sigaction]
    lea edi, [rdx+SIGTERM]
    mov esi, act
    mov ebp, esi ; save offset into data section
    lea r10d,[rdx+0x08]
    syscall

    ; Ensure the syscall succeeded
    mov ebx, eax ; save syscall return
    test eax, eax
    jnz error

    ; Pause until a signal is received
    xor eax, eax
    mov al, sys_pause
    syscall

exit:

    ; Terminate the application gracefully
    xor eax, eax
    mov al, sys_exit
    mov edi, ebx ; ebx=0 -> syscall successfull
    syscall

handler:

    ; Display a message
    xor eax, eax
    lea esi, [rbp-(act-sigterm_msg)] ; offset to sigterm_msg from act
    lea edx, [rax+sigterm_msg_len]
    mov al, sys_write
    mov edi, eax ; set edi=1 STDOUT
;    mov al, sys_write 
    syscall

    ret

restorer:

    ; return from the signal handler
    xor eax, eax
    mov al, sys_rt_sigreturn
    syscall

    align 16
error:

    ; Display an error message
    xor eax, eax
    lea esi, [rbp-(act-error_msg)] ;offset to error_msg from act
    lea edx, [rax+error_msg_len]
    mov al, sys_write
    mov edi, eax; edi=1 STDOUT
    syscall
    jmp exit
