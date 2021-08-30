---
{
  "type": "page",
  "author": "Pancakem",
  "title": "Write-up: ez",  
  "published": "2021-08-23",
}
---

## EZ

[Binary](https://github.com/Pancakem/metal-disco/blob/master/crackmes/ez/run.exe)

To start:
	strings --data run.exe
This reveals:
	P455w0rdYou Got This!
	Wrong!

P455w0rd looks like the obvious key:

./run.exe P455w0rd
gives the result: You Got This!

However on disassembly the compare is done with a dword, 4 bytes.
	0x08049008 <+8>:	cmp    eax,DWORD PTR [ebx]

./run.exe P455
gives the result: You Got This!


