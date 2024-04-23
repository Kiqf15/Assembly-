; =============================================================================
; V�deo Aula de Engenharia Eletr�nica, a Cl�ssica de Sexta WR Kits
;
;
; LCD Hitachi no modo 4 bits com PIC e Assembly
;
; MPLAB IDE v8.92
; Compiler: MPASM v5.51
; 
; MCU: PIC16F628A
; Clock: 4MHz    Ciclo de m�quina = 1�s
;
; Autor: Eng. Wagner Rambo   Data: Mar�o de 2021
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
; - Sem programa��o em baixa tens�o, sem prote��o de c�digo, sem prote��o da mem�ria EEPROM
; - Master Clear habilitado
	__config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CP_OFF & _CPD_OFF & _MCLRE_ON


; =============================================================================
; --- Pagina��o de Mem�ria ---
	#define		bank0	bcf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 0 de mem�ria
	#define		bank1	bsf	STATUS,RP0		;Cria um mnem�nico para selecionar o banco 1 de mem�ria
	

; =============================================================================
; --- Mapeamento de Hardware ---
	#define		rsel	PORTB,0				;pino de register select do LCD
	#define     enable	PORTB,1				;pino de enable do LCD
	
	
; =============================================================================
; --- Registradores de Uso Geral ---
	cblock		H'20'						;in�cio da mem�ria do usu�rio no PIC16F628A
	
	cmd_st									;armazena comando
	char_st									;armazena caractere
	time1									;auxiliar para temporiza��o
	time2									;auxiliar para temporiza��o
	time3									;auxiliar para temporiza��o
	
	endc									;final da mem�ria do usu�rio
	
; =============================================================================
; --- Vetor de RESET ---
	org			H'0000'						;Origem no endere�o 00h de mem�ria
	goto		inicio						;Desvia para a label in�cio
	

; =============================================================================
; --- Vetor de Interrup��o ---
	org			H'0004'						;As interrup��es deste processador apontam para este endere�o
	retfie									;Retorna da interrup��o
	
; wrkits.com.br/canal 
; =============================================================================
; --- Programa Principal ---
inicio:

	bank1									;seleciona o banco 1 de mem�ria
	movlw		H'0C'						;w = 0Ch
	movwf		TRISB						;configura IOs no PORTB
	bank0									;seleciona o banco 0 de mem�ria
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
	movwf		char_st						;carrega conte�do de work para char_st
	movf		char_st,w					;salva char_st em work
	andlw		H'F0'						;w = w AND 11110000b, preserva nibble mais significativo
	movwf		PORTB						;move conte�do de work para PORTB
	bsf			rsel						;seta rs
	call		pulse_en					;pulsa enable
	rlf			char_st,f					;rota��o para esquerda de char_st, salva nele pr�prio
	rlf			char_st,f					;rota��o para esquerda de char_st, salva nele pr�prio
	rlf			char_st,f					;rota��o para esquerda de char_st, salva nele pr�prio
	rlf			char_st,w					;rota��o para esquerda de char_st, salva em work
	andlw		H'F0'						;w = w AND 11110000b, preserva nibble mais significativo
	movwf		PORTB						;move conte�do de work para PORTB
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
	movlw		H'00'						;modo de incremento de endere�o para direita 1/2 0h
	call		lcd_cmd						;envia comando
	movlw		H'60'						;modo de incremento de endere�o para direita 2/2 6h
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
	call		_600us						;aguarda 600�s
	call		_600us						;aguarda 600�s
	bcf			enable						;limpa enable
	call		_600us						;aguarda 600�s
	call		_600us						;aguarda 600�s
	return									;retorna


; =============================================================================
; --- Delay de 500ms ---
_500ms:
	movlw		D'200'						;move 200d para work
	movwf		time1						;armazena na mem�ria do usu�rio
											;4 ciclos de m�quina (1 call + 2 mov's)
a500ms1:
	movlw		D'250'						;move 250d para work
	movwf		time2						;armazena na mem�ria do usu�rio
											;2 ciclos de m�quina (2 mov's)
a500ms2:
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
	nop										;no operation 
											;7 ciclos de m�quina (7 nop's)

	decfsz		time2						;decrementa time2 e desvia se for zero. Chegou em 0?
	goto		a500ms2						;n�o. Desvia para a500ms2
											;3 ciclos de m�quina (1 dec + 1 goto)
											;250 x 10 ciclos de m�quina = 2500 ciclos

	decfsz		time1						;decrementa time1 e desvia se for zero. Chegou em 0?
	goto		a500ms1						;n�o. Desvia para a500ms1
											;3 ciclos de m�quina (1 dec + 1 goto)
											;2500 x 200 = 500000�s = 500ms
	return									;retorna
	
	
; =============================================================================
; --- Delay de 600�s ---
_600us:
	movlw		D'200'						;move 200d para work
	movwf		time3						;armazena na mem�ria do usu�rio
	
a600us:
	decfsz		time3						;decrementa time3 e desvia se for zero. Chegou em 0?
	goto		a600us						;n�o. Desvia para a600us
											;3 x 200 = 600�s
	return									;retorna
	

; =============================================================================
; --- Final do Programa ---
	end										;Final do Programa
	
	