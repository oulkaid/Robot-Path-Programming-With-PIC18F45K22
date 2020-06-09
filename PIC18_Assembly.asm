    LIST	p = 18F45K22, r = dec  ;  Définition du µC utilisé
    #include    <p18f45k22.inc>	   ;  Définition des registres SFR et leurs bits
    #include    <config.inc>	   ;  Configuration des registres hardwares
    #include	<Temporisation.inc>	
                  ;  Contient les 3 sous programmes de temporisations suivantes: 
		  ;	TempoX1ms   = NFois * 1 ms	(La variable NFois est déjà déclarée)
		  ; TempoX10ms  = NFois * 10 ms	(La variable NFois est déjà déclarée)
		  ; TempoX100ms = NFois * 100 ms	(La variable NFois est déjà déclarée)
;*******************************************************************************
;*			Définition des Symboles avec EQU
;*******************************************************************************
MAX       EQU   20    ;nombre de mouvements maximal
;*******************************************************************************
;*			Réservation des variables avec res
;*******************************************************************************
uDataAccess udata_acs	0x00	; Adresse de uDataAccess = 0x00 (access page)
tab       res   MAX
tab_pas   res   MAX
i         res   1
ja        res   1
Xi        res   1
vr        res   1         ; tester si le nombre de pas est composé de plus d'un chiffre
br        res   1
tmp       res   1
tmp2      res   1
var_GO    res   1
uDataPage   udata	0x100		; Adresse de uDataPage = 0x100 (no access page)
;*******************************************************************************
;*			VECTEURS D'INTERRUPTIONS:
;*******************************************************************************					
    ORG	0x0000	          ; Adresse de départ après le RESET
    GOTO main
    ORG 00018h
    GOTO IT_INT1

;*******************************************************************************
;*			PROGRAMME PRINCIPAL:
;*******************************************************************************
    ORG	0x0100		  ; Adresse programme principale
main:
    CALL Init_Ports
    CALL Init_IT
    BSF INTCON,GIEH
    BSF INTCON,GIEL
    CLRF i
    CLRF ja
    CLRF vr
    LFSR FSR0,tab
    LFSR FSR2,tab_pas
Boucle0:                  ;initialisation de tab par 0
    INCF i
    MOVLW 0
    MOVWF POSTINC0
    MOVLW 0
    MOVWF POSTINC2
    MOVLW MAX
    CPFSEQ i
    GOTO Boucle0

Init_Boucle:
    CLRF i
    CLRF var_GO
    LFSR FSR0,tab
    LFSR FSR1,tab         ;1er pointeur vers le tableau de mouvements
    LFSR FSR2,tab_pas     ;2ème pointeur vers le tableau de pas
    
Boucle:
    MOVF var_GO,f
    BZ Boucle
    MOVF var_GO,f
    BZ Boucle
    CLRF var_GO
    CLRF vr
    CLRF i
    LFSR FSR0,tab
    LFSR FSR2,tab_pas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FCTi1:
    MOVF POSTINC1          ;signalisation pour le prochain mouvement (gauche/droit)
    MOVLW MAX 
    CPFSEQ i
    GOTO Continue
    GOTO Init_Boucle
Continue:
    MOVF INDF0,f           ;repète
    BZ Init_Boucle         ;//
    MOVF INDF0,W
    MOVWF tmp
    MOVLW 1
    CPFSEQ tmp
    GOTO FCTi2          
    CALL AHEAD_Action
    MOVLW 0
    MOVWF POSTINC0
    INCF i
    GOTO FCTi1
FCTi2:
    MOVF INDF0,W
    MOVWF tmp
    MOVLW 2
    CPFSEQ tmp
    GOTO FCTi3
    CALL LEFT_Action
    MOVLW 0
    MOVWF POSTINC0
    INCF i
    GOTO FCTi1
FCTi3:
    CALL RIGHT_Action
    MOVLW 0
    MOVWF POSTINC0
    INCF i
    GOTO FCTi1
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Saute:
    MOVLW 0
    MOVWF POSTINC2
    CALL STOP
    RETURN
    
AHEAD_Action:
    MOVF INDF2,W
    MOVWF ja
attente1:
    MOVF ja,f
    BZ Saute
    MOVLW 1
    CPFSEQ ja
    GOTO PLACEx
    CALL Allume_sign ;
PLACEx:
    DECF ja
    CALL AHEAD
    CALL TIMER0_1sec
    GOTO attente1
Allume_sign:
    MOVF INDF1,W                
    MOVWF tmp2                  
    MOVLW 2                     
    CPFSEQ tmp2                 
    GOTO FCT_test_right          
    CALL Signal_LEFT            
    RETURN
FCT_test_right:
    MOVLW 3
    CPFSEQ tmp2
    GOTO Saute
    CALL Signal_RIGHT
    RETURN
LEFT_Action:
    MOVLW 0
    MOVWF POSTINC2
    CALL LEFT
    CALL TIMER0_1sec
    CALL STOP
    RETURN
RIGHT_Action:
    MOVLW 0
    MOVWF POSTINC2
    CALL RIGHT
    CALL TIMER0_1sec
    CALL STOP
    RETURN
Signal_LEFT:
    BSF LATA,RA5
    CALL TIMER0_0.5sec
    BCF LATA,RA5
    RETURN
Signal_RIGHT:
    BSF LATA,RA4
    CALL TIMER0_0.5sec
    BCF LATA,RA4
    RETURN
;*******************************************************************************
;*			SOUS PROGRAMMES:
;*******************************************************************************
Init_Ports:					
    MOVLB 0x0F			
    CLRF ANSELA,1								
    CLRF LATA		
    CLRF PORTA
    CLRF TRISA
    
    CLRF ANSELB,1
    CLRF LATB
    CLRF PORTB
    BSF TRISB,RB1
    BSF TRISB,RB2
    
    CLRF ANSELC,1
    CLRF LATC
    CLRF PORTC
    MOVLW b'11111111'
    MOVWF TRISC
    RETURN
AHEAD:
    MOVLW b'00001111'
    MOVWF LATA
    RETURN
LEFT:
    MOVLW b'00000011'
    MOVWF LATA
    RETURN
RIGHT:
    MOVLW b'00001100'
    MOVWF LATA
    RETURN
STOP:
    CLRF LATA
    RETURN
TIMER0_1sec:
    MOVLW b'00000100'
    MOVWF T0CON
    MOVLW 0xBD
    MOVWF TMR0H
    MOVLW 0xC
    MOVWF TMR0L
    BCF INTCON,TMR0IF
    BSF T0CON,TMR0ON
AttenteTMR0IF:
    BTFSS INTCON,TMR0IF
    GOTO AttenteTMR0IF
    BCF T0CON,TMR0ON
    RETURN
TIMER0_0.5sec:
    MOVLW b'00000011'
    MOVWF T0CON
    MOVLW 0xBD
    MOVWF TMR0H
    MOVLW 0xC
    MOVWF TMR0L
    BCF INTCON,TMR0IF
    BSF T0CON,TMR0ON
AttenteTMR0IF_0.5:
    BTFSS INTCON,TMR0IF
    GOTO AttenteTMR0IF_0.5
    BCF T0CON,TMR0ON
    RETURN
Init_IT:
    BSF RCON,IPEN
    CLRF INTCON
    CLRF INTCON2
    MOVLW b'00001000'
    MOVWF INTCON3
    MOVLW b'00000010'
    MOVLW WPUB
    RETURN
IT_INT1:
    BTFSC PORTC,RC0
    GOTO TRAIT1
    BTFSC PORTC,RC1
    GOTO TRAIT2
    BTFSC PORTC,RC2
    GOTO TRAIT3
    BTFSC PORTC,RC3
    SETF var_GO
    BTFSC PORTC,RC4
    GOTO IT_INT2
    BTFSC PORTC,RC5
    GOTO IT_INT2
    BTFSC PORTC,RC6
    GOTO IT_INT2
    BTFSC PORTC,RC7
    GOTO IT_INT2
Suite:
    BCF INTCON3,INT1IF
    RETFIE
;............................................
TRAIT1:
    MOVLW MAX
    CPFSEQ i
    GOTO Next1
    GOTO Suite
Next1:
    CLRF vr
    MOVLW 1
    MOVWF POSTINC0
    INCF i
    GOTO Suite

TRAIT2:
    MOVLW MAX
    CPFSEQ i
    GOTO Next2
    GOTO Suite
Next2:
    CLRF vr
    MOVLW 2
    MOVWF POSTINC0
    INCF i
    MOVLW 0
    MOVWF POSTINC2
    GOTO Suite

TRAIT3:
    MOVLW MAX
    CPFSEQ i
    GOTO Next3
    GOTO Suite
Next3:
    CLRF vr
    MOVLW 3
    MOVWF POSTINC0
    INCF i
    MOVLW 0
    MOVWF POSTINC2
    GOTO Suite
    
IT_INT2:
    MOVF PORTC,W
    ANDLW b'11110000'
    MOVWF Xi
cmp1:
    MOVLW b'00010000'
    CPFSEQ Xi
    GOTO cmp2
    MOVF vr,f
    BZ vr_is_null_1
    CALL sp
    ADDLW 1          ;ajouter +1 au contenue de FSR2 (à travers 'br')
    GOTO spp
vr_is_null_1:
    SETF vr
    MOVLW 1
    MOVWF POSTINC2
    GOTO fin_int2
cmp2:
    MOVLW b'00100000'
    CPFSEQ Xi
    GOTO cmp3
    MOVF vr,f
    BZ vr_is_null_2
    CALL sp
    ADDLW 2
    GOTO spp
vr_is_null_2:
    SETF vr
    MOVLW 2
    MOVWF POSTINC2
    GOTO fin_int2
cmp3:
    MOVLW b'00110000'
    CPFSEQ Xi
    GOTO cmp4
    MOVF vr,f
    BZ vr_is_null_3
    CALL sp
    ADDLW 3
    GOTO spp
vr_is_null_3:
    SETF vr
    MOVLW 3
    MOVWF POSTINC2
    GOTO fin_int2
cmp4:
    MOVLW b'01000000'
    CPFSEQ Xi
    GOTO cmp5
    MOVF vr,f
    BZ vr_is_null_4
    CALL sp
    ADDLW 4
    GOTO spp
vr_is_null_4:
    SETF vr
    MOVLW 4
    MOVWF POSTINC2
    GOTO fin_int2
cmp5:
    MOVLW b'01010000'
    CPFSEQ Xi
    GOTO cmp6
    MOVF vr,f
    BZ vr_is_null_5
    CALL sp
    ADDLW 5
    GOTO spp
vr_is_null_5:
    SETF vr
    MOVLW 5
    MOVWF POSTINC2
    GOTO fin_int2
cmp6:
    MOVLW b'01100000'
    CPFSEQ Xi
    GOTO cmp7
    MOVF vr,f
    BZ vr_is_null_6
    CALL sp
    ADDLW 6
    GOTO spp
vr_is_null_6:
    SETF vr
    MOVLW 6
    MOVWF POSTINC2
    GOTO fin_int2
cmp7:
    MOVLW b'01110000'
    CPFSEQ Xi
    GOTO cmp8
    MOVF vr,f
    BZ vr_is_null_7
    CALL sp
    ADDLW 7
    GOTO spp
vr_is_null_7:
    SETF vr
    MOVLW 7
    MOVWF POSTINC2
    GOTO fin_int2
cmp8:
    MOVLW b'10000000'
    CPFSEQ Xi
    GOTO cmp9
    MOVF vr,f
    BZ vr_is_null_8
    CALL sp
    ADDLW 8
    GOTO spp
vr_is_null_8:
    SETF vr
    MOVLW 8
    MOVWF POSTINC2
    GOTO fin_int2
cmp9:
    MOVLW b'10010000'
    CPFSEQ Xi
    GOTO surement0
    MOVF vr,f
    BZ vr_is_null_9
    CALL sp
    ADDLW 9
    GOTO spp
vr_is_null_9:
    SETF vr
    MOVLW 9
    MOVWF POSTINC2
    GOTO fin_int2
surement0:             ; le cas échéant!
    MOVF vr,f
    BZ vr_is_null_0
    CALL sp
    ADDLW 0
    GOTO spp
vr_is_null_0:
    SETF vr
    MOVLW 0           ; enregistrement de la val 0 dans un tab qui sera 
                      ; -- utilisé comme compteur FSR2
    MOVWF POSTINC2
    GOTO fin_int2
fin_int2:
    BCF INTCON3, INT1IF
    RETFIE
multipX10:
    MOVF br,W         ;obligatoire pour mettre 'br' dans le registre 'W'
    MULLW 10          ;multiplication du contenue de FSR2 par x10 (à travers 'br') 
               	      ;--> resultat dans:: PRODH:PRODL
    MOVF PCL,W
    MOVF PRODL,W
    MOVWF br
    RETURN
sp:
    MOVLW 0 
    MOVWF POSTDEC2    ;--renancer
    MOVF INDF2,W
    MOVWF br          ;remplir 'br' par le contenue de FSR2
    CALL multipX10
    MOVF br,W
    RETURN
spp:
    MOVWF br       
    MOVF br,W
    MOVWF POSTINC2
    GOTO fin_int2
    
END