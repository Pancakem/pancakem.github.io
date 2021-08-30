---
{
  "type": "page",
  "author": "Pancakem",
  "title": "Write-up: lockcode",
  "published": "2021-08-23",
}
---

## Lockcode

[Binary](https://github.com/Pancakem/metal-disco/blob/master/crackmes/lock-code/lockcode)

Code: wzJCPjBHBsHAkHbazmhYdflzLdhapPUE


In the disassembly, 
```asm
   0x0000555555555250 <+58>:	jmp    0x5555555552ef <main+217>
   0x0000555555555255 <+63>:	movabs rax,0x48426a50434a7a77
   0x000055555555525f <+73>:	movabs rdx,0x6162486b41487342
   0x0000555555555269 <+83>:	mov    QWORD PTR [rbp-0x40],rax
   0x000055555555526d <+87>:	mov    QWORD PTR [rbp-0x38],rdx
   0x0000555555555271 <+91>:	movabs rax,0x7a6c666459686d7a
   0x000055555555527b <+101>:	movabs rdx,0x455550706168644c
   0x0000555555555285 <+111>:	mov    QWORD PTR [rbp-0x30],rax
   0x0000555555555289 <+115>:	mov    QWORD PTR [rbp-0x28],rdx
   0x000055555555528d <+119>:	mov    BYTE PTR [rbp-0x20],0x0
=> 0x0000555555555291 <+123>:	lea    rax,[rbp-0x40]
   0x0000555555555295 <+127>:	mov    rdi,rax
   0x0000555555555298 <+130>:	call   0x555555555080 <strlen@plt>
   0x000055555555529d <+135>:	mov    edx,eax
   0x000055555555529f <+137>:	lea    rax,[rbp-0x40]
   0x00005555555552a3 <+141>:	mov    rsi,rax
   0x00005555555552a6 <+144>:	mov    edi,edx
   0x00005555555552a8 <+146>:	call   0x555555555189 <val>
   0x00005555555552ad <+151>:	mov    DWORD PTR [rbp-0x48],eax
```
lets inspect the memory address that is loaded in gdb,

```
(gdb) info registers
rax            0x7fffffffdcf0      140737488346352
rbx            0x555555555310      93824992236304
rcx            0x555555555310      93824992236304
rdx            0x455550706168644c  4995987805238223948
rsi            0x7fffffffde28      140737488346664
rdi            0x7fffffffdcf0      140737488346352
rbp            0x7fffffffdd30      0x7fffffffdd30
rsp            0x7fffffffdcd0      0x7fffffffdcd0
r8             0x0                 0
r9             0x7ffff7fe0d50      140737354009936
r10            0x3                 3
r11            0x2                 2
r12            0x5555555550a0      93824992235680
r13            0x7fffffffde20      140737488346656
r14            0x0                 0
r15            0x0                 0
rip            0x555555555298      0x555555555298 <main+130>
eflags         0x246               [ PF ZF IF ]
cs             0x33                51
ss             0x2b                43
ds             0x0                 0
es             0x0                 0
fs             0x0                 0
gs             0x0
```

Inspecting the contents of the address in rax,

```x/s 0x7fffffffdcf0
0x7fffffffdcf0:	"wzJCPjBHBsHAkHbazmhYdflzLdhapPUE"```

This is a null terminated string, looks promising. 
Lets try it:

`./lockcode wzJCPjBHBsHAkHbazmhYdflzLdhapPUE`
`you have unlocked the code: boom boom mathafuka`

That's it!
