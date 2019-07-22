.386
.MODEL flat, stdcall
.stack 100h

GetStdHandle PROTO :DWORD
ExitProcess PROTO :DWORD
GetConsoleScreenBufferInfo PROTO :DWORD, :PTR DWORD
FillConsoleOutputCharacterA PROTO :DWORD, :BYTE, :DWORD, :DWORD, :PTR DWORD
FillConsoleOutputAttribute PROTO :DWORD, :WORD, :DWORD, :DWORD, :PTR DWORD
SetConsoleCursorPosition PROTO :DWORD, :DWORD
GetAsyncKeyState PROTO :DWORD

printf PROTO C :DWORD, :VARARG

cls PROTO
gotoxy PROTO

.data
	msg BYTE "X", 0
	current_position DWORD 0
	WND_handle DWORD ?
	
.code
main PROC
	invoke GetStdHandle, -11
	mov WND_handle, eax
	
	L1:
		;memeriksa tombol panah kiri
		invoke GetAsyncKeyState, 025h 
		and eax, 1
		cmp eax, 1
		jnz L1_check_up_arrow_key
			mov eax, current_position
			cmp ax, 0
			jz L1_continue

			sub ax, 1
			mov current_position, eax

			push WND_handle
			call cls
			add esp, 4

			push eax
			push WND_handle
			call gotoxy
			add esp, 8

			invoke printf, offset msg
			jmp L1_continue

		L1_check_up_arrow_key:
			invoke GetAsyncKeyState, 026h 
			and eax, 1
			cmp eax, 1
			jnz L1_check_right_arrow_key
				mov eax, current_position
				test eax, 0ffff0000h
				jz L1_continue

				sub eax, 010000h
				mov current_position, eax

				push WND_handle
				call cls
				add esp, 4

				push eax
				push WND_handle
				call gotoxy
				add esp, 8

				invoke printf, offset msg
				jmp L1_continue

		L1_check_right_arrow_key:
			invoke GetAsyncKeyState, 027h 
			and eax, 1
			cmp eax, 1
			jnz L1_check_down_arrow_key
				mov eax, current_position
				add ax, 1
				mov current_position, eax

				push WND_handle
				call cls
				add esp, 4

				push eax
				push WND_handle
				call gotoxy
				add esp, 8

				invoke printf, offset msg
				jmp L1_continue

		L1_check_down_arrow_key:
			invoke GetAsyncKeyState, 028h 
			and eax, 1
			cmp eax, 1
			jnz L1_check_escape
				mov eax, current_position
				add eax, 010000h
				mov current_position, eax

				push WND_handle
				call cls
				add esp, 4

				push eax
				push WND_handle
				call gotoxy
				add esp, 8

				invoke printf, offset msg
				jmp L1_continue

		L1_check_escape:
			invoke GetAsyncKeyState, 01bh
			and eax, 1
			cmp eax, 1
			jz exit

		L1_continue:
	jmp L1
	
	exit: 
		invoke ExitProcess, 0
main ENDP

gotoxy PROC
	push ebp
	mov ebp, esp
	;ebp + 8 = WND_handle
	;ebp + 12 = yx 

	invoke SetConsoleCursorPosition, DWORD PTR[ebp + 8], DWORD PTR[ebp + 12]

	mov esp, ebp
	pop ebp

	ret
gotoxy ENDP

cls PROC 
	push ebp
	mov ebp, esp
	sub esp, 26
	push eax
	push esi

	;ebp + 8 = WND_HANDLE
	;ebp - 4 = current_screen_size
	;ebp - 8 = byte_written
	;ebp - 26 = _CONSOLE_SCREEN_BUFFER_INFO

	lea esi, [ebp - 26]
	invoke GetConsoleScreenBufferInfo, [ebp + 8], esi
	mov eax, 0
	mov ax, WORD PTR [esi] ;dwSize.x
	mul WORD PTR [esi + 2] ;dwSize.x * dwSize.y

	mov DWORD PTR [ebp - 4], eax

	;32 ASCII untuk space
	invoke FillConsoleOutputCharacterA, DWORD PTR [ebp + 8], 32, DWORD PTR[ebp - 4], 0, [ebp - 8]
	invoke GetConsoleScreenBufferInfo, DWORD PTR [ebp + 8], esi

	;WORD PTR [esi + 8] untuk mengambil attribute
	invoke FillConsoleOutputAttribute, DWORD PTR [ebp + 8], WORD PTR [esi + 8], DWORD PTR [ebp - 4], 0, [ebp - 8]
	invoke SetConsoleCursorPosition, DWORD PTR [ebp + 8], 0
	
	pop esi
	pop eax
	mov esp, ebp
	pop ebp
	ret
cls ENDP
END main

COMMENT!
	_CONSOLE_SCREEN_BUFFER_INFO struct
		dwSize _COORD <?,?> 
		dwCursorPosition _COORD <?,?>
		wAttributes WORD ?
		srWindow DWORD ?
		dwMaximumWindowSize _COORD <?,?>
	_CONSOLE_SCREEN_BUFFER_INFO ends
!