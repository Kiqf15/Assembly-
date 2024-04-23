; =============================================================================
; Vídeo Aula de Engenharia Eletrônica, a Clássica de Sexta WR Kits
;
;
; LCD Hitachi no modo 4 bits com PIC e Assembly
;
; MPLAB IDE v8.92
; Compiler: MPASM v5.51
; 
; MCU: PIC16F628A
; Clock: 4MHz    Ciclo de máquina = 1µs
;
; Autor: Eng. Wagner Rambo   Data: Março de 2021
;
; =============================================================================


; =============================================================================
; --- Listagem do Processador Utilizado ---
	list	p=16F628A						;Utilizado PIC16F628A
	

; =============================================================================
; --- Arquivos Inclusos no Projeto ---
	#include <p16F628a.inc>					;inclui o arquivo do PIC 16F628A
	

; =============================================================================
; --- FUSE Bits ---
; - Oscilador interno 4MHz
; - Watch Dog Timer desabilitado
; - Power Up Timer habilitado
; - Brown Out desabilitado
; - Sem programação em baixa tensão, sem proteção de código, sem proteção da memória EEPROM
; - Master Clear habilitado
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CP_OFF & _CPD_OFF & _MCLRE_ON


; =============================================================================
; --- Paginação de Memória ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 0 de memória
	#define		bank1	bsf	STATUS,RP0		;Cria um mnemônico para selecionar o banco 1 de memória
	

; =============================================================================
; --- Mapeamento de Hardware ---
	#define		rsel	PORTB,0				;pino de register select do LCD
	#define     enable	PORTB,1				;pino de enable do LCD
	
	
; =============================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;início da memória do usuário no PIC16F628A
	
	cmd_st									;armazena comando
	char_st									;armazena caractere
	time1									;auxiliar para temporização
	time2									;auxiliar para temporização
	time3									;auxiliar para temporização
	
	endc									;final da memória do usuário
	
; =============================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endereço 00h de memória
	goto		inicio						;Desvia para a label início
	

; =============================================================================
; --- Vetor de Interrupção ---
	org			H'0004'						;As interrupções deste processador apontam para este endereço
	retfie									;Retorna da interrupção
	
; wrkits.com.br/canal 
; =============================================================================
; --- Programa Principal ---
inicio:

	bank1									;seleciona o banco 1 de memória
	movlw		H'0C'						;w = 0Ch
	movwf		TRISB						;configura IOs no PORTB
	bank0									;seleciona o banco 0 de memória
	clrf		PORTB						;limpa PORTB
	call		_500ms						;aguarda 500ms para estabilizar VDD
	call		lcd_init					;inicializa LCD
	clrf		PORTB						;limpa PORTB

	
; =============================================================================
; --- Loop Infinito ---
loop:
	movlw		'H'							;move byte de 'H' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
	movlw		'e'							;move byte de 'e' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
	movlw		'l'							;move byte de 'l' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
	movlw		'l'							;move byte de 'l' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
	movlw		'o'							;move byte de 'o' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
	movlw		'!'							;move byte de '!' para work
	call		lcd_write					;escreve no LCD
	call		_500ms						;aguarda 500ms
    call		lcd_clear					;limpa LCD
    call		_500ms						;aguarda 500ms

	goto		loop						;desvia para loop
	
	
; =============================================================================
; --- Sub-Rotinas ---


; =============================================================================
; --- Envia comando para o LCD ---
lcd_cmd:
	movwf		cmd_st						;armazena comando recebido
	bcf			rsel						;limpa register select
	movf		cmd_st,w					;envia comando para work
	movwf		PORTB						;envia comando para LCD
	call		pulse_en					;pulso em enable
	retlw		H'00'						;retorna com work limpo
	

; =============================================================================
; --- Escreve um caractere no LCD ---	
lcd_write:
	movwf		char_st						;carrega conteúdo de work para char_st
	movf		char_st,w					;salva char_st em work
	andlw		H'F0'						;w = w AND 11110000b, preserva nibble mais significativo
	movwf		PORTB						;move conteúdo de work para PORTB
	bsf			rsel						;seta rs
	call		pulse_en					;pulsa enable
	rlf			char_st,f					;rotação para esquerda de char_st, salva nele próprio
	rlf			char_st,f					;rotação para esquerda de char_st, salva nele próprio
	rlf			char_st,f					;rotação para esquerda de char_st, salva nele próprio
	rlf			char_st,w					;rotação para esquerda de char_st, salva em work
	andlw		H'F0'						;w = w AND 11110000b, preserva nibble mais significativo
	movwf		PORTB						;move conteúdo de work para PORTB
	bsf			rsel						;seta rs
	call		pulse_en					;pulsa enable
	return									;retorna


; =============================================================================
; --- Inicializa LCD ---
lcd_init:
	movlw		H'20'						;modo de 4 bits
	call		lcd_cmd						;envia comando
	call		lcd_cmd						;repete envio 3 vezes...
	call		lcd_cmd						;...para configurar 5x8 pontos por caracter
	movlw		H'00'						;liga o display e o cursor 1/2 0h
	call		lcd_cmd						;envia comando
	movlw		H'E0'						;liga o display e o cursor 2/2 Eh
	call		lcd_cmd						;envia comando
	movlw		H'00'						;modo de incremento de endereço para direita 1/2 0h
	call		lcd_cmd						;envia comando
	movlw		H'60'						;modo de incremento de endereço para direita 2/2 6h
	call		lcd_cmd						;envia comando
	call		lcd_clear					;limpa LCD
	return									;retorna


; =============================================================================
; --- Limpa LCD ---
lcd_clear:
	movlw		H'00'						;return home display 1/2 0h
	call		lcd_cmd						;envia comando
	movlw		H'20'						;return display 2/2 1h
	call		lcd_cmd						;envia comando
	movlw		H'00'						;limpa display 1/2 0h
	call		lcd_cmd						;envia comando
	movlw		H'10'						;limpa display 2/2 1h
	call		lcd_cmd						;envia comando
	retlw		H'00'						;retorna com work em 00h
	

; =============================================================================
; --- pulsa o enable do LCD ---
pulse_en:
	bsf			enable						;seta enable
	call		_600us						;aguarda 600µs
	call		_600us						;aguarda 600µs
	bcf			enable						;limpa enable
	call		_600us						;aguarda 600µs
	call		_600us						;aguarda 600µs
	return									;retorna


; =============================================================================
; --- Delay de 500ms ---
_500ms:
	movlw		D'200'						;move 200d para work
	movwf		time1						;armazena na memória do usuário
											;4 ciclos de máquina (1 call + 2 mov's)
a500ms1:
	movlw		D'250'						;move 250d para work
	movwf		time2						;armazena na memória do usuário
											;2 ciclos de máquina (2 mov's)
a500ms2:
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
											;7 ciclos de máquina (7 nop's)

	decfsz		time2						;decrementa time2 e desvia se for zero. Chegou em 0?
	goto		a500ms2						;não. Desvia para a500ms2
											;3 ciclos de máquina (1 dec + 1 goto)
											;250 x 10 ciclos de máquina = 2500 ciclos

	decfsz		time1						;decrementa time1 e desvia se for zero. Chegou em 0?
	goto		a500ms1						;não. Desvia para a500ms1
											;3 ciclos de máquina (1 dec + 1 goto)
											;2500 x 200 = 500000µs = 500ms
	return									;retorna
	
	
; =============================================================================
; --- Delay de 600µs ---
_600us:
	movlw		D'200'						;move 200d para work
	movwf		time3						;armazena na memória do usuário
	
a600us:
	decfsz		time3						;decrementa time3 e desvia se for zero. Chegou em 0?
	goto		a600us						;não. Desvia para a600us
											;3 x 200 = 600µs
	return									;retorna
	

; =============================================================================
; --- Final do Programa ---
	end										;Final do Programa
	
	