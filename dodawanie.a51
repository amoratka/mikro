;------------------------------------------------------------------------------- 
include     REG515.INC            ;Tabela predefinicyjna SFR. 
;------------------------------------------------------------------------------- 
                        
code    at 1000h            ;organizacja od adresu 1000h 


        ljmp    start       ;skok do poczatku programu 

code    at 2000h 


    MOV R4,#00h            ;przetworzona liczba 
    MOV R5,#00h            ;1 liczba 
    MOV R6,#00h            ;2 liczba 
    MOV R7,#00h            ;WYNIK!! 
start:
;;;; wczytywanie pierwszej liczby 
	 MOV DPTR, #4000h			
	 LCALL wczytaj				;wczytywanie 1 liczby   		   
    LCALL    liczb			;przetwarzanie 1 liczby
    CJNE R0,#2Bh,ujemna          
cos1:    
	 MOV A,R4 
    MOV R5,A 
;;;; wczytywanie drugiej liczby    
	 MOV DPTR, #4008h
	 LCALL wczytaj 			;wczytywanie 2 liczby
    LCALL    liczb    		;przetwarzanie 2 liczby
    CJNE R0,#2Bh,ujemna2          
cos2:  
    MOV A,R4         
    MOV R6,A 
;;;; dodawanie
    LCALL dod 			;dodaj
;;;; wypisywanie  
    LCALL wyp       ;wypisz
    ljmp cos
;   ljmp start 

wczytaj: MOVX A, @DPTR
			MOV R0, A
			INC DPTR

			MOVX A, @DPTR 
			CLR C  
			MOV R1, A    				;zapisuje cyfre 
			INC DPTR

			MOVX A, @DPTR
			CLR C 
			MOV R2, A 
			INC DPTR

			MOVX A, @DPTR
			CLR C 
			MOV R3, A  
			RET
			    
liczb: 
	 ;Przetwarza liczbe - odejmuje 30, zeby wartosc ASCI zamienic na wlasciwa liczbe
	 ;a nastepnie: mnozy wartosc w R1 razy 100 aby otrzymac liczbe setek i
	 ;wartosc R2 razy 10 aby otrzymac liczbe dziesiatek. Jednosci sa w R3
	 ;Nastepnie sumuje  R1, R2 i R3, aby otrzymac prawidlowa liczbe i umieszcza ja
	 ;w R4.
    
    ;Przetwarzanie setek(z ASCI)                                                                
    CLR C        ;Zeruj bit
    MOV A,R1 	  ;Do akumulatora, zeby mozna bylo odjac
    SUBB A,#30h  ;Zamiana ASCI na liczbe - trzeba odjac 30
    MOV R1,A 	  ;Spowrotem do R1
    
    ;Przetwarzanie dziesiatek(z ASCI)
    CLR C        ;Analogicznie jak wyzej
    MOV A,R2 
    SUBB A,#30h 
    MOV R2,A 
    
    ;Przetwarzanie jednosci (z ASCI)
    CLR C 
    MOV A,R3 
    SUBB A,#30h 
    MOV R3,A    

	;Mnozenie razy 100 dla liczby setek i umieszczenie w R4
    Mov    B,#100d 
    MOV    A,R1 
    MUL    AB 
    MOV    R4,A; 

    ;Mnozenie razy 10 dla liczby dziesiatek i dodaje do setek w R4 
    MOV    B,#10d 
    MOV    A,R2 
    MUL    AB; 
    ADD    A,R4             
    MOV    R4,A 
    
    ;Dodanie jednosci 
    MOV    A,R3 
    ADD    A,R4            
    MOV    R4,A  
    RET
;Zamiana liczby na ujemna - zgodnie z U2:
ujemna: 
    MOV    A,R4 		;1 - przenies liczbe z R4 do akumulatora
    CPL    A 			;2 - zaneguj bity
    ADD    A,#01h 	;3 - dodaj 1
    MOV    R4,A 		;4 - przenies przetworzona liczbe spowrotem do R4
    ljmp cos1
ujemna2: 
    MOV    A,R4 		;1 - przenies liczbe z R4 do akumulatora
    CPL    A 			;2 - zaneguj bity
    ADD    A,#01h 	;3 - dodaj 1
    MOV    R4,A 		;4 - przenies przetworzona liczbe spowrotem do R4
    ljmp cos2

    
dod: 
    MOV A,R5    ;Pierwsza liczba do akumulatora
    MOV B,R6    ;Druga liczba do rejestru B
    ADD A,B 	 ;Dodaj do akumulatora druga liczbe z B
    MOV R7,A    ;Umiesc wynik dodawania w R7
    RET 			 ;Koniec podprogramu
wyp:
;;;; wypisywanie podkreslenia
	 MOV DPTR, #4010h
	 MOV A, #2Dh
    MOVX @DPTR,A
    INC DPTR
    MOV A, #2Dh
    MOVX @DPTR,A
    INC DPTR
    MOV A, #2Dh
    MOVX @DPTR,A
    INC DPTR
    MOV A, #2Dh
    MOVX @DPTR,A
;;;; wypiswyanie w³asciwej liczby ze znakiem
;wypiswanie znaku     
	 MOV DPTR, #4018h 
    MOV A, #00h
    MOVX @DPTR,A 
    MOV A,R7 		 		;Wynik dodawania z R7 do akumulatora
    JNB ACC.7,plus 		;Jezeli 8my bit znaku jest 0, to znaczy ze liczba dodatnia
    							; i skok do podprogramu wypisania dla liczby dodatniej     
    							; jesli ujemna zamien na dodatnia, wypisz znak i dopiero wypisz liczbe juz jak dodatnia
    MOV    A,R7 		;Wynik dodawania do akumulatora
    CPL    A 			;U2 - negacja bitu
    ADD    A,#01h   ;i dodanie 1
    MOV    R7,A     ;Przenies liczbe po przetworzeniu na ujemna spowrotem do R7
    MOV DPTR, #4018h
    MOV A, #2Dh
    MOVX @DPTR,A 	
plus: 
    MOV B,#100d 			;Umiesc w rejestrze B wartosc 100
    MOV A,R7 				;Umiesc w A wynik z R7
    DIV AB 					;Podziel przez 100 - aby otrzymac liczbe setek. Do B idzie reszta z dzielenia
    ADD A,#30h 			;Przetworzenie spowrotem na ASCI (dodanie 30)
    INC DPTR
    MOVX @DPTR,A 				;Umiesc w odpowiedniej komorce pamieci liczbe setek
    
    MOV A,B 				;Umiesc w A zawartosc B
    MOV B,#10d 			;Umiesc w B wartosc 10
    DIV AB 					;Podziel A przez 10 aby otrzymac liczbe dziesiatek. Do B idzie reszta, czyli jednosci
    ADD A,#30h				;Przetworzenie spowrotem na ASCI
    INC DPTR 		
    MOVX @DPTR,A 			;Umiesc w odpowiedniej komorce pamieci liczbe dziesiatek
    
    MOV A,B 				;Umiesc w A zawartosc B - czyli jednosci
    ADD A,#30h 			;Przetworzenie na ASCI
    inc DPTR
    MOVX @DPTR,A 			;Umiesc w odpowiedniej komorce pamieci liczbe jednosci
    ljmp COS 
COS: nop
	nop
		nop
		ljmp COS
;-------------------------------------------------------------------------------    
            
END  
 

