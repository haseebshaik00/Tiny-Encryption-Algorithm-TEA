.model small
                   
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;                      Data Segment                             ;; 
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
                   
org 100h
.data
    SUM DW ?                    
    DELTA DW 02ACh              ;Universal Constant
    input DW 255 dup(?)         ;Input PLAIN TEXT - 64 bits (8bytes = 16characters = 8words)
    encstr DW 255 dup(?)        ;Encrypted data
    decstr DW 255 dup(?)        ;Decrypted data
    i1 DW 0     
    i2 DW 0                     ;no. of entered characters by the user (i2 = i3*2)
    i3 DW 0                     ;no. of entered words by the user
    A0 DW ?
    A1 DW ?
    k0 DW ?                     ;KEY - 128 bits (taken 8 bytes for simplification)
    k1 DW ?
    k2 DW ?
    k3 DW ?
    INPUTMSG    DB 'Enter the PLAIN TEXT to encrypt: $'
    KEYMSG      DB 0Dh,0Ah,'Enter the key: $'
    WAITMSG     DB 0Dh,0Ah,'Encrypting .... $'
    ENCMSG      DB 0Dh,0Ah,'Cypher Text : $'
    DECMSG      DB 0Dh,0Ah,'Decrypted Data: $'
    NULLMSG     DB 0Dh,0Ah,'No Data Entered!$'
    
    
.code

main proc   
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;           Take input from the user for plain text             ;; 
        ;;                  and store it in input variable               ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        
                                                                
    lea dx,INPUTMSG                                                  
    mov ah,09h                  ;Defines operation : write String (from dx)
    int 21h
    
    lea si,input
    mov ah,01h                  ;Defines operation : inputs data from user (into al)  
    
    entry:
    int 21H                     ;user inputs first char into al
    mov bh,al   
    cmp al, 0Dh                 ;compare to "ENTER"  
    je lab
    
    int 21H                     ;user inputs second char into al
    mov bl,al
    cmp al, 0Dh                 ;compare to "ENTER"
    je lab2
    
    mov [si],bx                 ;2bytes = 16 bits = 4characters = 1word (qqqq)
    add si,2
    inc i3  
    jmp entry
    
    lab:                        ;called when ENTER is pressed at higher byte
        mov ax,i3
        cmp ax,0                ;checks if any data is entered
        je no_data
        jmp exit
    
    lab2:                       ;called when ENTER is pressed as lower byte
        mov bl,1Fh              ;converts "ENTER" to " "
        mov [si],bx   
        add si,2
        inc i3
        jmp exit                  
    
    exit:                       ;made to make sure that number of words are even
        mov ax,i3
        mov dl,4
        div dl
        cmp ah,1                ;if number of words are odd , jump to lab3
        je lab3
        cmp ah,3    
        je lab3
        jmp exit2
    
    lab3:
        mov bh,1Fh
        mov bl,1Fh
        mov [si],bx             ;adds one more empty word "  "
        add si,2
        inc i3
        jmp exit2
    
    no_data:                    ;called when there is no data entered
        lea dx,NULLMSG
        mov ah,09h       
        int 21h
        ret
    
    exit2:                      ;end data entry
        
        mov ax,i3               ;sets i2 = i3*2
        mov bx,i3
        add ax,bx
        mov i2,ax
      
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;             Take input from the user for the key              ;; 
        ;;                  and store it in key variable                 ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        
    lea dx,KEYMSG
    mov ah,09
    int 21h

    mov ah, 01h
    int 21h         ;get K0
    MOV bx, 0000h        
    mov bl, al
    mov k0, bx
    
    mov ah, 01h
    int 21h         ;get k1
    MOV bx, 0000h        
    mov bl, al
    mov k1, bx
     
    mov ah, 01h
    int 21h         ;get k2
    MOV bx, 0000h
    mov bl, al
    mov k2, bx
     
    mov ah, 01h
    int 21h         ;get k3
    MOV bx, 0000h
    mov bl, al
    mov k3, bx                            
    
    
      
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;                          Main Module                          ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
    
    mov ah,09h
    lea dx,WAITMSG          ;wait message
    int 21h
    
    mov i1,0 
    mov bx,i1
    
    again:
    lea si,input
    add si ,i1
    mov ax,[si]
    mov A0,ax               ;Get data from input string
    mov ax,[si+2]
    mov A1,ax    
    
    call encrypt            ;call encrypt function to encrypt the input data
    
    lea si,encstr           ;put Encrypted data into encrypt string
    add si ,i1
    mov ax ,A0
    mov [si] ,ax      
    mov ax ,A1
    mov [si+2] ,ax 
    
    call decrypt            ;call decrypt function to decrypt the encrypted data
    
    lea si,decstr           ;put Decrypted data into decrypt string
    add si ,i1
    mov ax ,A0
    mov [si] ,ax      
    mov ax ,A1
    mov [si+2] ,ax
    
    mov ax, i1        
    add ax, 4
    mov i1, ax
    
    mov ax,i1
    mov bx,i2
    cmp bx,ax               ;checks if there is more data to encrypt
    je print                
    jmp again
    
    print:    
        call encprint    
        call decprint
     
    en:                     ;to end program
    mov ah, 4ch
    int 21h

main endp

       
       
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;                     Encryption Module                         ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


encrypt proc
    mov cx, 8               ; counter    
    
    encLoop:              
        ; sum += delta  
        mov bx, delta
        mov ax, sum
        add ax, bx
        mov sum, ax
        ; A0 += ((A1<<4) + k0) xor (A1 + sum) xor ((A1>>5) + k1)  sum = delta at first time 
        ; dx = ((A1<<4) + k0)
        mov ax, A1
        shl ax, 4
        mov bx, k0
        add ax, bx
        mov dx, ax
        ; dx ^= (A1 + sum)
        mov ax, A1
        mov bx, sum
        add ax, bx
        xor dx, ax
        ; dx ^= ((A1>>5) + k1)
        mov ax, A1
        shr ax, 5
        mov bx, k1
        add ax, bx
        xor dx, ax
        ; A0 += dx
        mov ax, A0
        add ax, dx
        mov A0, ax 
        ; A1 += ((A0<<4) + k2) ^ (A0 + sum) ^ ((A0>>5) + k3)
        ; dx = ((A0<<4) + k2)
        mov ax, A0
        shl ax, 4
        mov bx, k2
        add ax, bx
        mov dx, ax
        ; dx ^= (A0 + sum)
        mov ax, A0
        mov bx, sum
        add ax, bx
        xor dx, ax
        ; dx ^= ((A0>>5) + k3)
        mov ax, A0
        shr ax, 5
        mov bx, k3
        add ax, bx
        xor dx, ax
        ; A1 += dx
        mov ax, A1
        add ax, dx
        mov A1, ax 
    loop encLoop          ; dec cx     
    ret     
encrypt endp   

           
           
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;                    Decryption Module                          ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        
decrypt proc
    mov cx, 8       ; counter for "loop" instruction 
            
    decLoop:      
        ; A1 -= ((A0<<4) + k2) xor (A0 + sum) xor ((A0>>5) + k3)
        ; dx = ((A0<<4) + k2)
        mov ax, A0
        shl ax, 4
        mov bx, k2
        add ax, bx
        mov dx, ax
        ; dx ^= (A0 + sum)
        mov ax, A0
        mov bx, sum
        add ax, bx
        xor dx, ax
        ; dx ^= ((A0>>5) + k3)
        mov ax, A0
        shr ax, 5
        mov bx, k3
        add ax, bx
        xor dx, ax
        ; A1 -= dx
        mov ax, A1
        sub ax, dx
        mov A1, ax
        ; A0 -= ((A1<<4) + k0) xor (A1 + sum) xor ((A1>>5) + k1)    
        ; dx = ((A1<<4) + k0)
        mov ax, A1
        shl ax, 4
        mov bx, k0
        add ax, bx
        mov dx, ax
        ; dx ^= (A1 + sum)
        mov ax, A1
        mov bx, sum
        add ax, bx
        xor dx, ax
        ; dx ^= ((A1>>5) + k1)
        mov ax, A1
        shr ax, 5
        mov bx, k1
        add ax, bx
        xor dx, ax
        ; A0 -= dx
        mov ax, A0
        sub ax, dx
        mov A0, ax 
        ; sum -= delta  
        mov bx, delta
        mov ax, sum
        sub ax, bx
        mov sum, ax    
    loop decLoop             
    ret
decrypt endp 
              
                                                                   

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;                          Print Module                         ;;
        ;;                                                               ;;
        ;;                                                               ;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

encprint proc    
    mov ah,09h
    lea dx,ENCMSG
    int 21h
       
    lea si,encstr
    mov ax,i3
    mov cx,ax
    
    con:
        mov bx,[si]
        mov ah, 02h
        mov dl,bh
        int 21h
        mov dl,bl
        int 21h
        add si,2
    loop con
        
ret
encprint endp                  
                                                                    
decprint proc    
    mov ah,09h
    lea dx,DECMSG
    int 21h
    
    lea si,decstr
    mov ax,i3
    mov cx,ax
    
    con2:
        mov bx,[si]
        mov ah, 02h
        mov dl,bh
        int 21h
        mov dl,bl
        int 21h
        add si,2
    loop con2
ret
decprint endp 
ret




