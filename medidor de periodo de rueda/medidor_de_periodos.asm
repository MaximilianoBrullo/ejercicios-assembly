    LIST P=16F887
    #INCLUDE "P16F887.inc"
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _MCLRE_ON & _LVP_OFF
    ORG 0X00
    GOTO 0X05
    ORG 0X04
    GOTO ISR
    ORG 0X05
    

;CONTADORES PARA LOS DELAY DE 10mS
CONTADOR1_DELAY10mS EQU 0X20
CONTADOR2_DELAY10mS EQU 0X21

;CONTADORES PARA TENER REFERNECIA DE LAS UNIDADES Y DECENAS
CONTADORX10_UNIDAD EQU 0X22
CONTADORX10_DECENA EQU 0X23

;GUARDAN LA DIRECCION DE MEMORIA DE UNA POSICION ESPECIFICA (LA CUAL SERA CARGADA POR LA 
;SUBRUTINA, A PARTIR DE UNIDAD_TEMP Y DECENA_TEMP)DE LA TABLA PARA QUE LUEGO SEAN
;MOSTRADOS POR LA RUTINA PRINCIPAL
UNIDAD EQU 0X24
DECENA EQU 0X25
 
;UNIDA_TEMP Y DECENA_TEMP SON UTILIZADOS POR LA SUBRUTINA PARA IR CONTANDO
;LOS TIEMPO QUE PASAN DE LA RUTINA  
UNIDAD_TEMP EQU 0X26
DECENA_TEMP EQU 0X27
 
;W Y STATUS TEMPORALES PARA ULTILIZAR EN LA INTERRUPCION
W_TEMP EQU 0X28
STATUS_TEMP EQU 0X29

;TABLA DE NUMEROS
    MOVLW 0X3F;0
    MOVWF 0X70
    
    MOVLW 0X06;1
    MOVWF 0X71
    
    MOVLW 0X5B;2
    MOVWF 0X72
    
    MOVLW 0X4F;3
    MOVWF 0X73
    
    MOVLW 0X66;4
    MOVWF 0X74
    
    MOVLW 0X6D;5
    MOVWF 0X75
    
    MOVLW 0X7D;6
    MOVWF 0X76
    
    MOVLW 0X07;7
    MOVWF 0X77
    
    MOVLW 0X7F;8
    MOVWF 0X78
    
    MOVLW 0X67;9
    MOVWF 0x79
    
;CONFIGURACION DE PUERTOS E INTERRUPCIONES
    BANKSEL ANSEL
    CLRF ANSEL
    CLRF ANSELH
    BANKSEL TRISA
    MOVLW 0XFC
    MOVWF TRISA
    MOVLW 0X01
    MOVWF TRISB
    MOVLW 0X97
    MOVWF OPTION_REG
    BANKSEL INTCON
    MOVLW .98
    MOVWF TMR0
    MOVLW 0XB0
    MOVWF INTCON
    MOVLW 0X70
    MOVWF UNIDAD
    MOVWF DECENA
    
LOOP:
    MOVF UNIDAD, W
    MOVWF FSR
    MOVF INDF, W
    MOVWF PORTB
    BSF PORTA, 0
    CALL DELAY_10mS
    BCF PORTA, 0
    MOVF DECENA, W
    MOVWF FSR
    MOVF INDF, W
    MOVWF PORTB
    BSF PORTA, 1
    CALL DELAY_10mS
    BCF PORTA, 1
    GOTO LOOP
    
ISR:;SUBRUTINA
    ;GUARDO CONTEXTO----------
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
;----LOGICA DE SUBRUTINA------------
    BTFSS INTCON, T0IF
    GOTO PRUEBA_RB01
    GOTO PRUEBA_RB02

PRUEBA_RB01:
    BTFSS PORTB, 0
    GOTO ISR_END
    GOTO GUARDO_Y_SALGO
    
PRUEBA_RB02:
    BTFSS PORTB, 0
    GOTO ISR_END
    GOTO INCREMENTO_VALORES
    
GUARDO_Y_SALGO:
    MOVF DECENA_TEMP, W
    MOVWF DECENA
    MOVF UNIDAD_TEMP, W
    MOVWF UNIDAD
    MOVLW 0X70
    MOVWF UNIDAD_TEMP
    MOVWF DECENA_TEMP
    GOTO ISR_END
   
INCREMENTO_VALORES:
    INCF UNIDAD_TEMP, F
    DECFSZ CONTADORX10_UNIDAD, F
    GOTO ISR_END
    MOVLW .10
    MOVWF CONTADORX10_UNIDAD
    INCF DECENA_TEMP, F
    MOVLW 0X70
    MOVWF UNIDAD_TEMP
    DECFSZ CONTADORX10_DECENA, F
    GOTO ISR_END
    MOVLW 0X70
    MOVWF DECENA_TEMP
    MOVLW .10
    MOVWF CONTADORX10_DECENA

;LIMPIO BANDERAS, ACTIVO INTERRUPCIONES, RECUPERAMOS CONTEXTO Y SALIMOS DE LA INTERRUPCION
ISR_END:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
;------------delay de 10mS---------------------
DELAY_10mS:
    MOVLW .50
    MOVWF CONTADOR1_DELAY10mS
L1:
    MOVLW .50
    MOVWF CONTADOR2_DELAY10mS
L2:
    DECFSZ CONTADOR2_DELAY10mS, F
    GOTO L2
    DECFSZ CONTADOR1_DELAY10mS, F
    GOTO L1
    RETURN
;-------------------------------
    END