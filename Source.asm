; This is a modified version of a hello world program
; that displays to the console that worked very nicely for my purposes
; for outputting disks for Tower of Hanoi

TITLE Towers of Hanoi x86

.386
.MODEL flat, stdcall
.STACK 4096

; ----------------------------------------------------------------------------
; These are prototypes for functions that we use
; from the Microsoft library Kernel32.lib.
; ----------------------------------------------------------------------------

; Win32 Console handle
STD_OUTPUT_HANDLE EQU -11		        ; predefined Win API constant (magic)

GetStdHandle PROTO,                 ; get standard handle
	nStdHandle:DWORD  		             ; type of console handle

WriteConsole EQU <WriteConsoleA>    ; alias

WriteConsole PROTO,		              ; write a buffer to the console
	handle:DWORD,		                   ; output handle
	lpBuffer:PTR BYTE,		             ; pointer to buffer
	nNumberOfBytesToWrite:DWORD, 	     ; size of buffer
	lpNumberOfBytesWritten:PTR DWORD,  ; num bytes written
	lpReserved:DWORD		               ; (not used)

ExitProcess PROTO,                  ; exit program
	dwExitCode:DWORD		               ; return code
	
; ----------------------------------------------------------------------------




; ----------------------------------------------------------------------------
; global data
; ----------------------------------------------------------------------------

.data
consoleOutHandle dd ?     	      ; DWORD: handle to standard output device
bytesWritten     dd ?     	      ; DWORD: number of bytes written
message db "Starting Output, if number of disks is even Destination is Pole 1, Otherwise Destination is Pole 2",13,10,0  ; BYTE: string, with \r, \n, \0 at the end
message2 db "Move from ? to ? ",13,10,0
done db "Done.",13,10,0 
moves dd 1
acc dd 1
that dd 3
; ----------------------------------------------------------------------------




.code

; ----------------------------------------------------------------------------
procStrLength PROC USES edi,
	ptrString:PTR BYTE	; pointer to string
;
; walk the null terminated string at ptrString
; incrementing eax. The value in eax is the string length 
;
; parameters: ptrString - a string pointer
; returns: EAX = length of string prtString
; ----------------------------------------------------------------------------
	mov edi,ptrString
	mov eax,0     	            ; character count
L1:                             ; loop
	cmp byte ptr [edi],0	     ; found the null end of string?
	je  L2	                     ; yes: jump to L2 and return
	inc edi	                     ; no: increment to next byte
	inc eax	                     ; increment counter
	jmp L1                       ; next iteration of loop
L2: ret                         ; jump here to return
procStrLength ENDP
; ----------------------------------------------------------------------------




; ----------------------------------------------------------------------------
procWriteString proc
;
; Writes a null-terminated string pointed to by EDX to standard
; output using windows calls.
; ----------------------------------------------------------------------------
	pushad

	INVOKE procStrLength,edx   	   ; return length of string in EAX
	cld                            ; clear the direction flag
	                               ; must do this before WriteConsole

	INVOKE WriteConsole,
	    consoleOutHandle,     	   ; console output handle
	    edx,	                   ; points to string
	    eax,	                   ; string length
	    offset bytesWritten,  	   ; returns number of bytes written
	    0


	popad
	ret
procWriteString endp
; ----------------------------------------------------------------------------




; ----------------------------------------------------------------------------
main PROC
;
; Main procedure. Just initializes stdout, dumps the string, and exits.
; ----------------------------------------------------------------------------
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; use Win32 to put 
	                                        ; stdout handle in EAX
	                                        
	mov [consoleOutHandle],eax             ; Put the address of the handle in 
	                                        ; our variable

	mov edx,offset message                 ; load the address of the message 
	                                        ; into edx for procWriteString
	
	INVOKE procWriteString                 ; invoke our write string method. 

										   ;This declares how many disks we have
	shl moves, 3						   ;48 seconds for 31 disks without output
calc:
	mov edx, 0
	mov eax, acc				;Start calculating where disk is coming from
	dec eax
	and eax, acc
	mov ecx, 3
	div ecx
	add dl, 30h					;Converts number into ascii equivalent
	mov [message2+10], dl		;Puts the number into our string
	mov edx, 0
	mov eax, acc				;Starting calculating where to place disk
	dec eax
	or eax, acc
	add eax, 1
	mov ecx, 3
	div ecx
	add dl, 30h	                                        
	mov [message2+15], dl
	mov edx,offset message2
	INVOKE procWriteString
	inc acc
	mov ecx, acc
	cmp ecx, moves
	jne calc 
	mov edx,offset done
	INVOKE procWriteString
	INVOKE ExitProcess,0                   ; Windows method to quit

main ENDP
; ----------------------------------------------------------------------------

END main