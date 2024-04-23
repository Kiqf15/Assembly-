; --- Mapeamento de Hardware (8051) ---
    RS      equ     P1.3    ;Reg Select ligado em P1.3
    EN      equ     P1.2    ;Enable ligado em P1.2


org 0000h
	
	ljmp START

org 0200h
;Colocando as Horas no LCD
START:
	
    ;Coloca as Horas no LCD
    mov R5, #22
	acall lcd_init
	mov A, #04h
	acall posicionaCursor   ; posiciona o cursor na coluna 04h da primeira linha
	mov A, R5
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 


    ;Colocando os Minutos no LCD
    mov R4, #59
	acall lcd_init
	mov A, #07h
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R4
	mov B, #10
	div AB  ; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 


    ;Colocando os Segundos no LCD
    mov R3, #00
	acall lcd_init
    mov A, #0Ah
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R3
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 

    ;Colocando as Horas para o alarme
    mov R7, #23
	acall lcd_init
	mov A, #44h
	acall posicionaCursor   ; posiciona o cursor na coluna 04h da primeira linha
	mov A, R7
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 	

    ;Colocando os Minutos para o alarme
    mov R6, #00
	acall lcd_init
	mov A, #47h
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R6
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 	
	mov A, B
	add A, #30h
	acall sendCharacter 		

    ;Colocando os Segundos para o alarme
    mov R3, #00
	acall lcd_init
    mov A, #04Ah
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R3
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 
	
;Função responsavel pelo loop do Relogio    
rodando:
	;Atualiza as horas do Relogio
    acall inicioTeclado
	lcall alarmou
	acall lcd_init
	mov A, #04h
	acall posicionaCursor   ; posiciona o cursor na coluna 04h da primeira linha
	mov A, R5
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 	

    ;Atualiza os Minutos do Relogio
	acall lcd_init
	mov A, #07h
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R4
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter

    ;Atualiza os Segundos do Relogio
    acall delayseg
	acall segundos
	acall lcd_init
    mov A, #0Ah
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R3
	mov B, #10
	div AB  				; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter 
	cjne r3, #59, Rodando
	acall minutos
    acall Horas
	
    ljmp Rodando

;Função que atuliza a hora no alarme
ExibHoraAlarm:
    mov A, #44h
	acall posicionaCursor   ; posiciona o cursor na coluna 44h na segunda linha
	mov A, R7
	mov B, #10
	div AB                  ; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter
    ACALL continue

;Função que atuliza a minuto no alarme
ExibMinAlarm:
    mov A, #47h
	acall posicionaCursor   ; posiciona o cursor na coluna 06 da primeira linha
	mov A, R6
	mov B, #10
	div AB  ; divide por 10 para extrair a dezena.
	add A, #30h
	acall sendCharacter 
	mov A, B
	add A, #30h
	acall sendCharacter
    ACALL continue



;Função para chamar o alarme quando o horario do relogio é = ao horario do alarme
alarmou:
	mov 60h, r7
	mov a, r5
	cjne a, 60h, alarmouaux
	mov 60h, r6
	mov a, r4
	cjne a, 60h, alarmouaux
	MOV P3, #0x00
    MOV P1, #80h 
    acall delayseg
    MOV P3, #0xff 
	MOV P1, #0xff 
	mov r0, #50
	djnz r0, alarmouaux
	ret
;Função Auxiliar do alarme
alarmouaux:
	ret

;Funções responsaveis pelo contador do relogio de horas
horas:
    inc r5
    cjne r5, #24, JumpRodando
    clr a
    mov r5, A
    ret

;Funções responsaveis pelo contador do relogio de Minutos
minutos:
    inc r4
    cjne r4, #60, JumpRodando
    clr a
    mov r4, A
    ret

JumpRodando:
	ljmp rodando


;Funções responsaveis pelo contador do relogio de segundos
segundos:
    inc r3
    cjne r3, #60, alarmouaux
    clr a
    mov r3, A
    ret

; Função para iniciar teclado
inicioTeclado: 
	MOV A, #0

	MOV P0, #11111110b
	CALL columVerify

	MOV P0, #11111101b
	CALL columVerify

	MOV P0, #11111011b
	CALL columVerify

	MOV P0, #11110111b
	CALL columVerify

	ret

;Reinicia para o loop Rodando
ReiniciaRodando: 
	MOV A, #00h
	ACALL posicionaCursor
	ACALL leituraTeclado
	MOV A, #40h
	ADD A, R0
	MOV R0, A
	MOV A, @R0
	ACALL HoraButton 

;Função do botão que realiza o incremento na hora
HoraButton: 
; if A == '1'
	CJNE A, #'1', MinButton
	inc r7
    cjne r7, #24, ExibHoraAlarmaux
    clr A
    mov r7, A
    acall ExibHoraAlarmaux	

ExibHoraAlarmaux:
    ljmp ExibHoraAlarm

;Função do botão que realiza o incremento no minuto
MinButton:
    ; if A == '2'
	CJNE A, #'2', HoraButtonDec
    inc r6
    cjne r6, #60, ExibMinAlarmaux
    clr A
    mov r6, A
    acall ExibMinAlarmaux

;Função que realiza o drecremento das horas para o alarme com o botão
HoraButtonDec: 
    ; if A == '4'
	CJNE A, #'4', MinButtonDec
	dec r7
    cjne r7, #255, ExibHoraAlarmaux
    mov r7, #23
    acall ExibHoraAlarmaux

;Função que realiza o drecremento do minuto para o alarme com o botão
MinButtonDec:
    ; if A == '5'
	CJNE A, #'5', ContinueButton
    dec r6
    cjne r6, #255, ExibMinAlarmaux
    mov r6, #59
	acall ExibMinAlarmaux

ExibMinAlarmaux:
    ljmp ExibMinAlarm

ContinueButton:
	CJNE A, #'9', ReiniciaRodando
	ACALL continue

continue:
	JNB P0.4, $
	JNB P0.5, $
	JNB P0.6, $
	CLR F0
	lJMP rodando

columVerify:
	JNB P0.4, ReiniciaRodando2
	INC A
	JNB P0.5, ReiniciaRodando2
	INC A
	JNB P0.6, ReiniciaRodando2
	INC A
	RET

ReiniciaRodando2:
	LJMP ReiniciaRodando

;Função responsavel por ler o Teclado
leituraTeclado:
	MOV R0, #0			

	; scan row0
	MOV P0, #0FFh	
	CLR P0.0			
	CALL colScan		
	JB F0, finish		
						
	; scan row1
	SETB P0.0			
	CLR P0.1			
	CALL colScan		
	JB F0, finish		
						
	; scan row2
	SETB P0.1			
	CLR P0.2			
	CALL colScan		
	JB F0, finish		
						
	; scan row3
	SETB P0.2			
	CLR P0.3			
	CALL colScan		
	JB F0, finish		
						

finish:
	RET

; column-scan subroutine
colScan:
	JNB P0.4, gotKey	
	INC R0					
	JNB P0.5, gotKey	
	INC R0					
	JNB P0.6, gotKey	
	INC R0					

	RET						

gotKey:
	SETB F0			
	
    RET					

; inicializar o LCD
lcd_init:
	clr RS  
	clr P1.7    
	clr P1.6    
	setb P1.5   
	clr P1.4   
	setb EN		
	clr EN		
	call delay			
	setb EN		
	clr EN	
	setb P1.7		
	setb EN		
	clr EN		
	call delay

    ; conjunto de modo de entrada
	clr P1.7		
	clr P1.6		
	clr P1.5		
	clr P1.4		
	setb EN		
	clr EN		
	setb P1.6		
	setb P1.5		
	setb EN		
	clr EN		
	call delay		

    ; exibir controle de ligar/desligar
    ; o visor está ativado, o cursor está ativado e o piscar está ativado
	clr P1.7		
	clr P1.6		
	clr P1.5		
	clr P1.4	
	setb EN		
	clr EN	
	setb P1.7		
	setb P1.6	
	setb P1.5	
	setb P1.4		
	setb EN		
	clr EN		
	call delay		
	ret

;Evia o Character para o LCD
sendCharacter:
	setb RS  		
	mov C, ACC.7		
	mov P1.7, C			
	mov C, ACC.6		
	mov P1.6, C			
	mov C, ACC.5		
	mov P1.5, C			
	mov C, ACC.4		
	mov P1.4, C			
	setb EN			
	clr EN			
	mov C, ACC.3		
	mov P1.7, C		
	mov C, ACC.2		
	mov P1.6, C			
	mov C, ACC.1		
	mov P1.5, C		
	mov C, ACC.0		
	mov P1.4, C			
	setb EN			
	clr EN			
	call delay			
	ret

;Posiciona o cursor na linha e coluna desejada.
posicionaCursor:
	clr RS	         
	setb P1.7		    
	mov C, ACC.6		
	mov P1.6, C			
	mov C, ACC.5		
	mov P1.5, C			
	mov C, ACC.4		
	mov P1.4, C			
	setb EN			
	clr EN			
	mov C, ACC.3		
	mov P1.7, C			
	mov C, ACC.2		
	mov P1.6, C			
	mov C, ACC.1		
	mov P1.5, C			
	mov C, ACC.0		
	mov P1.4, C			
	setb EN			
	clr EN			
	call delay			
	ret

;Delay para o Segundos
delayseg:
 	mov R0, #255
 	DJNZ R0, $
	mov R0, #250
 	DJNZ R0, $
	mov R0, #250
 	DJNZ R0, $
 	ret

;Delay das Funções principais
delay:
	mov R0, #50
	DJNZ R0, $
	ret