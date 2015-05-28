  ;------------------------------------------------------------------------------- 
include     REG515.INC            ;Tabela predefinicyjna SFR. 
;------------------------------------------------------------------------------- 
                        
code    at 1000h            ;organizacja od adresu 1000h 


        ljmp    start       ;skok do poczatku programu 

code    at 2000h 


    MOV R4,#00h            ;przetworzona liczba 
    MOV R5,#00h            ;1 liczba 
    MOV R6,#00h            ;2 liczba 
  
start:
  mov 60h, #30h
  mov 61h, #30h
  mov 37h, #00h
  mov 31h, #00h
  mov 32h, #00h
  mov 33h, #00h
  mov 34h, #00h
  mov 35h, #00h
        
;;;ustalenie od którego adresu wczytwana jest pierwsza liczba 
	mov R1, #19h
;;;wczytywanie pierwszej liczby
	lcall wczytaj
;;;ustalanie znaku pierwszej liczby i przeszkok do zamiany na ujemn¹ jeœli minus
	mov R0, 18h 
	CJNE R0,#2Bh,ujemna  
	mov A, 60h
	inc A
	mov 60h, A 
powrot1:
;;;przepisanie pierwszej liczby do rejestrów R2 - L, R3 - H
	mov A, R6
	mov R2,A
	mov A, R7
	mov R3,A
;;;ustalenie od którego adresu wczytwana jest druga liczba 	
	mov R1, #21h
;;;wczytywanie drugiej liczby
	lcall wczytaj
;;;ustalanie znaku drugiej liczby i przeszkok do zamiany na ujemn¹ jeœli minus	
	mov R0, 20h 
	CJNE R0,#2Bh,ujemna2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;jeœli liczba nie jest na minusie trzeba pisaæ plus 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;inaczej wariuje :( to znaczy traktuje jak liczbe na minusie 
;;;przepisanie drugiej liczby do rejestrów R4- L, R5 - H	
	mov A, 60h
	inc A
	mov 60h, A 
powrot2:	
	mov A, R6
	mov R4,A
	mov A, R7
	mov R5,A

	lcall podkreslenie
	
	lcall dodawanie
;;;w razie restartu nie zostaje minus, z tym mia³am problem gdy mi minus zero wypisywa³o
	mov 30h, #00h
;;;sprawdzenie czy liczba po dodawaniu jest ujemna
	mov A,R3
	jb acc.7, czy_obie_dodatnie
	jnb acc.7, czy_obie_ujemne
	jc mieszane
powrot5:
	mov A, R7
	JNB ACC.7,plus 	
;;;jeœli tak to zamienia		
   clr C
	MOV    A,R6		
   CPL    A 			
   ADD    A,#01h 	
   MOV    R6,A 
   MOV    A,R7		
   CPL    A 			
   ADDC   A,#00h 	
   MOV    R7,A 						
;;;wypisuje minus
   MOV 30h, #2Dh
;;; wypisywanie liczby zamienionej lub po dodawaniu dodatniej
plus:	mov A, R7
	mov R2,A
	mov A, R6
	mov R3,A
	

	lcall wypisz
;;;NASZA NIEŒMIERTELNA PÊTLA :D	
	ljmp cos
czy_obie_dodatnie:
	mov A, 60h 	
;	jnc mieszane 
	cjne A, #32h, powrot5	
	mov 37h, #2Bh
	ljmp cos
czy_obie_ujemne:	
	mov A, 61h
;	jc mieszane
	cjne A, #32h, powrot5
	mov 37h,#2Dh	
	ljmp cos
mieszane:
	mov 37h, #2Fh
	ljmp cos

podkreslenie:
	mov 28h, #2Dh
	mov 29h, #2Dh
	mov 2Ah, #2Dh
	mov 2Bh, #2Dh
	mov 2Ch, #2Dh
	mov 2Dh, #2Dh
	RET
;;;zamiana pierwszej liczby na U2 jesli ujemna
ujemna :
	clr C
	MOV    A,R6		
   CPL    A 			
   ADD    A,#01h 	
   MOV    R6,A 
   MOV    A,R7		
   CPL    A 			
   ADDC   A,#00h 	
   MOV    R7,A
   mov A, 61h
	inc A
	mov 61h, A  
	ljmp powrot1
;;;zamiana drugiej liczby na U2 jeœli ujemna	
ujemna2 :
	clr C
	MOV    A,R6		
   CPL    A 			
   ADD    A,#01h 	
   MOV    R6,A 
   MOV    A,R7		
   CPL    A 			
   ADDC   A,#00h 	
   MOV    R7,A 
   mov A, 61h
	inc A
	mov 61h, A 
	ljmp powrot2

wczytaj :
;;;wczytywanie liczby dziesi¹tek tysiêcy 
	mov A,@ R1
	mov R0,A 
	CLR C        
   MOV A,R0 	  
   SUBB A,#30h  
   MOV R0,A 
 	  
	mov A, R0
	mov B, #40d
	mul AB
	mov B, #250d
	mul AB
	mov R6, A
	mov R7,B
 
;;;wczytywanie liczby tysiecy   	  
	inc R1
	mov A,@ R1
 	mov R0,A 	
	CLR C     
   MOV A,R0 	  
   SUBB A,#30h  
   MOV R0,A 
 	  
	mov A, R0
	mov B, #40d
	mul AB
	mov B, #25d
	mul AB
	mov R4, A
	mov R5,B
	
;;;dodawanie dziesi¹tek tysiecy i tysiêcy
 	clr C
 	mov A, R4
 	mov B, R6
 	add A,B
 	mov R6, A
 
 	mov A, R5
 	mov B, R7
 	addc A,B
 	mov R7, A
 	
;;;wczytywanie liczby setek
	inc R1
	mov A,@ R1
	mov R0,A
	CLR C        
   MOV A,R0 	  
   SUBB A,#30h  
   MOV R0,A 
 	  
	mov A, R0
	mov B, #100d
	mul AB
	mov R4, A
	mov R5,B

;;;dodawanie setek do poprzedniego wyniku    	
	clr C
 	mov A, R4
 	mov B, R6
 	add A,B
 	mov R6, A
 	
 	mov A, R5
 	mov B, R7
 	addc A,B
 	mov R7, A
 	
;;;wczytywanie liczby dziesi¹tek
	inc R1
	mov A,@ R1
 	mov R0,A
	CLR C       
	MOV A,R0 	  
   SUBB A,#30h  
   MOV R0,A 
 	  
	mov A, R0
	mov B, #10d
	mul AB
	mov R4, A
	mov R5,B
	
;;;dodawanie dziesi¹tek do poprzedniego wyniku
	clr C
 	mov A, R4
 	mov B, R6
 	add A,B
 	mov R6, A
 
 	mov A, R5
 	mov B, R7
 	addc A,B
 	mov R7, A
 	

;;;wczytywanie jednoœci
	inc R1
	mov A,@ R1
 	mov R0,A
	CLR C       
	MOV A,R0 	  
   SUBB A,#30h 
   MOV R0,A 
 	  
	mov A, R0
	mov B, #1d
	mul AB
	mov R4, A
	mov R5,B
;;;dodawanie jendostek do poprzedniego wyniku
	clr C
	mov A, R4
	mov B, R6
	add A,B
	mov R6, A
 
 	mov A, R5
 	mov B, R7
 	addc A,B
 	mov R7, A
 

 	RET
	
dodawanie:
 	clr C
 	mov A, R2
 	mov B, R4
 	add A,B
 	mov R6, A
 
 	mov A, R3
 	mov B, #00h
 	addc A,b
 	clr C
 	mov B, R5
 	add A,B
 	mov R7, A
;;;nadmiarowa zamiana ale nie chce  mi sie juz bawic w szukanie ktory rejestr powinnam podmienic gdzie 	

 	mov A, R6 
 	mov R2,A
 	mov A, R7
 	mov R3,A
 	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;jesli przepe³nienei na co komu taki kalkulator wiec nie wypisuje wyniku
;;to jest zleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

wypisz:
	
	

	; odzyskiwanie cyfry 10 tysiecy z pocz¹tkowej liczby
  ; MOV   R2, #0FDh  ; H-DZIELNA 
   ;MOV   R3, #80h  ; L-DZIELNA 
    
   ; DZIELNIK 10000 DZIESIETNIE 

	
	MOV   R4, #27h   ; H-DZIELNIK 
   MOV   R5, #10h   ; L-DZIELNIK 
    
   lcall   dzielenie16_16   
   
   ; przygotwoanie cyfry do wypisania w pamiêci
   mov A, R3
   add A, #30h
   mov R3, A
  	mov  31h, R3 
  	
  	;;przesuniêcie reszty z poprzedniego dzielenia do dzielnej  
   mov A, R0
   MOV   R2, A  ; H-DZIELNA 
   mov A, R1
   MOV   R3, A  ; L-DZIELNA 
    	

; DZIELNA tysiecy

    
   ; DZIELNIK 1000 DZIESIETNIE 
   MOV   R4, #03h   ; H-DZIELNIK 
   MOV   R5, #0E8h   ; L-DZIELNIK 
    
   lcall   dzielenie16_16 
 
   
   ;liczba do wypisania
    mov A, R3
    add A, #30h
    mov R3, A
  mov  32h, R3  
    
 ;dzielenie setek  ;
 ; od przesuniecia reszty do dzielnej 
    mov A, R0
       MOV   R2, A  ; H-DZIELNA 
       mov A, R1
   MOV   R3, A  ; L-DZIELNA 
    
   ; DZIELNIK 100 DZIESIETNIE 
   MOV   R4, #00h   ; H-DZIELNIK 
   MOV   R5, #64h   ; L-DZIELNIK 
    
   lcall   dzielenie16_16 
 
   
   
  
   ;wypisanie liczby
     mov A, R3
    add A, #30h
    mov R3, A
    mov  33h, R3
    ;;dzielenie dziesiatek
    ;przeusniecie reszty do dzielniej
        mov A, R0
       MOV   R2, A  ; H-DZIELNA 
       mov A, R1
   MOV   R3, A  ; L-DZIELNA 
    
   ; DZIELNIK 10 DZIESIETNIE 
   MOV   R4, #00h   ; H-DZIELNIK 
   MOV   R5, #0Ah   ; L-DZIELNIK 
    
   lcall   dzielenie16_16 
 
   
   ;wypisanie liczby
 mov A, R3
    add A, #30h
    mov R3, A
    mov  34h, R3
     
  ;  wypisanie reszty kór jest cyfr¹ dziesiatek  
      mov A, R1
    add A, #30h
    mov R1, A
    mov 35h, R1
   
   RET 
    
;==============================DIV16_16============================================= 
dzielenie16_16:      ;dzielenie 16 bitow przez 16 bitow 
         ;we: r2    - H dzielna 
         ;    r3    - L dzielna 
         ;    r4    - H dzielnik 
         ;    r5    - L dzielnik 
         ;wy: r2    - H czesc calkowita 
         ;    r3    - L czesc calkowita 
         ;    r0    - H reszta 
         ;    r1    - L reszta 
         ;zmienia: acc, psw, b 

   clr   a      ;r0,r1:=0,0 
   mov   r0,a 
   mov   r1,a 
   mov   b,#16 

dziel1:   clr   c      ;przesuniecie w lewo r0,r1,r2,r3 
   mov   a,r3      ;i tym samym pomnozenie wy*2 (wy=r2,r3) 
   rlc   a 
   mov   r3,a 
   mov   a,r2 
   rlc   a 
   mov   r2,a 
   mov   a,r1 
   rlc   a 
   mov   r1,a 
   mov   a,r0 
   rlc   a 
   mov   r0,a 

            ;czy Hi>=dzielnik (R0,R1>=r4,r5) 
   mov   a,r1 
   subb   a,r5 
   mov   a,r0 
   subb   a,r4 
   jc   dziel2 

   inc   r3      ;wy:=wy+1 




   clr   c      ;Hi:=Hi-dzielnik (R0,R1:=R0,R1-R4,R5) 
   mov   a,r1 
   subb   a,r5 
   mov   r1,a 
   mov   a,r0 
   subb   a,r4 
   mov   r0,a 

dziel2:   djnz   b,dziel1 

   ret 
	
	
	
COS: nop
	nop
	nop
	ljmp COS
;-------------------------------------------------------------------------------    
            
END
