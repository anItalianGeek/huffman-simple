.model huge
.stack
.data
    letters db 'P','R','M','A','I','E' ; letters of the alphabet (please don't input more than 6)
    frequencies db 9,9,10,16, 21, 35 ; frequencies of the letters that compose the alphabet
    dictionaryLetters db 'P','R','M','A','I','E' ; a copy of the letters that the program uses, please make sure that it is identical to the "letters" array
    updatedfrequencies db 9,9,10,16, 21, 35 ; a copy of the frequencies that the program uses, please make sure that it is identical to the "frequencies" array
    combinations db 0,0,0,0,0,0,'P',0,0,0,0,0,0,'R',0,0,0,0,0,0,'M',0,0,0,0,0,0,'A',0,0,0,0,0,0,'I',0,0,0,0,0,0,'E' ; array used to create the tree structure
    lastChar db 1 ; support variables
    boolean db 0
    fix_counter dw 1
    swapCounter1 db 0
    swapCounter2 db 0
    counterBefSpace db 0
    counterAftSpace db 0
    counter db 0
    indexRow dw 0
    counterInternalFor dw ?
    compositions db 42 dup(0) ;  
    dimensionCompositions db 6 dup(0)
    checker_alphabet_decoder db 6 dup(1)
    dictionaryEncodings db 36 dup(0)
    bufferInput db 20 dup(?) ; buffer for user input
    CRLF db 10,13,10,13,"$" ; strings that display useful messages
    string1 db "Letter $"
    string2 db " translated in binary is $"
    string3 db 10,13,10,13,"What do you want to do? Encoding('c') or Decoding('d')?",10,13,"$"
    string4 db 10,13,"The encoded message is $"
    string5 db 10,13,"The decoded message is $" 
.code
.startup
    mov bx, 6 ; resetting the registers
    mov si, 0 
    mov di, 0 
    mov dx, 0 
    mov cx, 0 
    mov ax, 0 
        
    grouping: 
        translateElement: 
            push bx
            mov ah, combinations[bx] ; move into the ah register the character to translate
            
            cmp lastChar, 1
            jne doNotAssign
            mov lastChar, ah
            
            doNotAssign:
            add bx, 7 ; set bx to the index of the "destination" of the char in the ah register

            setBxCorrectly: ; decrement bx to find an empty spot (else i will overwrite other characters!)
            dec bx
            cmp combinations[bx], 0
            jne setBxCorrectly
            
            mov combinations[bx], ah ; move the character
            pop bx ; reset bx to point to the next character to translate
            mov combinations[bx], 0 ; cancel the last character (it has been moved already)
            dec bx
            cmp combinations[bx], 0
            jne translateElement ; while i have characters to translate, keep moving them... 
            push bx
            
            setBxAgainForcompositions: ; make bx point to the next bunch of characters to translate
                inc bx
                cmp combinations[bx], 0
                je setBxAgainForcompositions
                
            fillcompositionsBefSpace: ; now, for each of the 2 blocks translated, fill the corresponding compositions block
            mov ah, combinations[bx]
            mov compositions[si], ah
            mov ah, lastChar ; put the "last character" into ah
            inc si
            inc bx
            cmp combinations[bx - 1], ah ; test if the program has copied the last character of the first block
            jne fillcompositionsBefSpace ; in that case, it is time to put in a space before copying the next block
            
            mov ah, combinations[bx]
            inc bx
            mov compositions[si], ' ' ; add the space
            inc si
            mov compositions[si], ah ; put in the first character before the space
            inc si
                                             
            fillcompositionsAftSpace: ; check if there are any other characters to move
            mov ax, bx
            mov dl, 7
            div dl
            cmp ah, 0
            je stopFillingcompositions
            
            mov ah, combinations[bx] ; if so then do it....
            inc bx
            mov compositions[si], ah
            inc si
            jmp fillcompositionsAftSpace 
            
            stopFillingcompositions: ; set the registers for the next operations
            mov ah, 0
            dec al
            mul dl
            mov si, ax
            pop bx
            
        mov al, updatedfrequencies[di] ; update the frequencies vector
        mov updatedfrequencies[di], 0
        inc di
        mov bp, di
        add updatedfrequencies[di], al
        
        pusha
        mov si, 0
        mov di, 1
        
        checkIfToReorder: ; the next 13 lines are used to check if the frequencies array is sorted in order
            mov ah, updatedfrequencies[di]
            cmp updatedfrequencies[si], ah
            jna next
            
            mov boolean, 1 ; if not then proceed to sort it using the selection sort algorithm
            jmp exitCheck
            next:
            inc si
            inc di
            cmp di, 6
            je terminateReorder
            jmp checkIfToReorder
        
        exitCheck:
        cmp boolean, 0
        je terminateReorder
        mov ax, 0 ; resetting the registers for the sorting algorithm
        mov bx, bp
        mov dx, 0
        mov si, 0
        mov di, 0
        externalFor: ; begin the sorting algorithm
            mov di, bx 
            inc di
        
            mov si, bx
            cmp bx, 5
            je terminateReorder
        
            internalFor:
                cmp di, 6
                je nextElement
        
                mov cl, updatedfrequencies[si]
                cmp cl, updatedfrequencies[di]
                ja true     
            
                inc di
                jmp internalFor
    
            true:
                mov si, di
                inc di
                jmp internalFor
    
            nextElement:
                mov al, updatedfrequencies[bx]
                mov ah, updatedfrequencies[si]
                mov updatedfrequencies[bx], ah
                mov updatedfrequencies[si], al
                
                push si 
                push bx  
                
                mov dl, 7
                mov ax, bx
                mul dl
                mov bx, ax
                mov ax, si
                mul dl
                mov si, ax
                mov di, bx
                add di, 6
                add si, 6
                mov swapCounter1, 0
                mov swapCounter2, 0
                swapLetters1:
                    inc swapCounter1
                    mov dl, combinations[si]
                    push dx
                    mov combinations[si], 0
                    dec si
                    cmp combinations[si], 0
                    jne swapLetters1

                swapLetters2:
                    inc swapCounter2
                    mov dl, combinations[di]
                    push dx
                    mov combinations[di], 0
                    dec di
                    cmp combinations[di], 0
                    jne swapLetters2
                
                mov ax, 0
                mov al, swapCounter1
                add si, ax
                mov al, swapCounter2
                add di, ax
                
                sub si, ax
                mov al, swapCounter1
                sub di, ax   
                inc si
                inc di
                   
                mov cx, 0
                mov cl, swapCounter2
                swapping1:
                    pop dx                                                      
                    mov combinations[si], dl
                    inc si
                    loop swapping1
               mov cl, swapCounter1
               swapping2:
                    pop dx
                    mov combinations[di], dl
                    inc di
                    loop swapping2                    
                
                pop bx
                pop si
        
                inc bx
                jmp externalFor
        
        terminateReorder:
        popa

        mov ax, fix_counter
        mov dl, 7
        mul dl
        mov si, ax
        
        mov bx, si
        add bx, 6
        inc fix_counter
        
        lookForNext: ; check if the grouping is done, the last element of the frequencies array must equal to 100
            cmp updatedfrequencies[5], 100
            je outGrouping
            mov lastChar, 1
            jmp translateElement
    
    outGrouping:
        mov cx, 0
        mov dl, 7      
        fixcompositionsVector: ; considering each block, i have the letters at the "beginning" of block while i need them at the end
            mov counter, 0 ; so, for each block
            mov ax, cx
            mul dl
            mov si, ax
            add ax, 6
            mov di, ax
            loadStack: ; get the characters in the block and put them in the stack
                mov dh, compositions[si]
                mov compositions[si], 0
                inc counter
                push dx
                inc si
                cmp compositions[si], 0
                jne loadStack
            
            mov bp, cx
            mov cl, counter
            unloadStack: ; unload the stack and put them at their place (the end of the block)
                pop dx
                mov compositions[di], dh
                dec di
                loop unloadStack
            mov cx, bp    
            
            inc cx
            cmp cx, 6
            jne fixcompositionsVector
         
        mov cx, 42
        mov si, 0
        mov dx, 7
        mov bx, 3
        countLengths: ; count the lengths of each string/block of compositions
            mov ax, bx
            div dl
            cmp ah, 0
            jne count
            inc si
            count:
                cmp compositions[bx], 0
                jne ok
                inc bx
                cmp bx, cx
                jne countLengths
                jmp stopCounting
                ok:
                inc dimensionCompositions[si]
                inc bx
                cmp bx, cx
                jne countLengths

        stopCounting:     
        pusha
        mov ax, 0
        mov bx, 0 
        mov si, 0 
        mov di, 0                                           
        externalFor_2: ; second sorting algorithm - applied on the compositions vector
            mov di, bx 
            inc di
        
            mov si, bx
            cmp bx, 5
            je terminateReorder_2
        
            internalFor_2:
                cmp di, 6
                je nextElement_2
        
                mov cl, dimensionCompositions[si]
                cmp cl, dimensionCompositions[di]
                jb true_2     
            
                inc di
                jmp internalFor_2
    
            true_2:
                mov si, di
                inc di
                jmp internalFor_2
    
            nextElement_2:
                mov al, dimensionCompositions[bx]
                mov ah, dimensionCompositions[si]
                mov dimensionCompositions[bx], ah
                mov dimensionCompositions[si], al
                
                push si 
                push bx  
                
                mov dl, 7
                mov ax, bx
                mul dl
                mov bx, ax
                mov ax, si
                mul dl
                mov si, ax
                mov di, bx
                add di, 6
                add si, 6
                mov swapCounter1, 0
                mov swapCounter2, 0
                mov cx, 0
                swapLetters1_1:
                    inc swapCounter1
                    mov dl, compositions[si]
                    push dx
                    mov compositions[si], 0
                    inc cx
                    cmp cx, 7
                    je next_1
                    dec si
                    cmp compositions[si], 0
                    jne swapLetters1_1
                
                inc si
                next_1:
                mov cx, 0
                swapLetters2_1:
                    inc swapCounter2
                    mov dl, compositions[di]
                    push dx
                    mov compositions[di], 0
                    inc cx
                    cmp cx, 7
                    je next_dos
                    dec di
                    cmp compositions[di], 0
                    jne swapLetters2_1
                
                inc di
                next_dos:
                mov ax, 0
                mov al, swapCounter1
                add si, ax
                mov al, swapCounter2
                add di, ax
                
                sub si, ax
                mov al, swapCounter1
                sub di, ax   
                   
                mov cx, 0
                mov cl, swapCounter2
                swapping1_1:
                    pop dx                                                      
                    mov compositions[si], dl
                    inc si
                    loop swapping1_1
               mov cl, swapCounter1
               swapping2_1:
                    pop dx
                    mov compositions[di], dl
                    inc di
                    loop swapping2_1                    
                
                pop bx
                pop si
                inc bx
                jmp externalFor_2
         
        popa
        terminateReorder_2: ; second phase of the sorting algorithm finishes...
            mov cx, 6
            mov bx, 0
            entryPoint: ; now i need to have the bigger block 
            mov counterBefSpace, 0
            mov counterAftSpace, 0
            countBeforeSpace: ; simply count the chars before the ' ' character
                cmp compositions[bx], 0
                jne conditionPass
                inc bx
                jmp countBeforeSpace
                conditionPass:
                    cmp compositions[bx], ' '
                    je exitCountingBefSpace 
                    inc bx
                    inc counterBefSpace
                    jmp conditionPass
            exitCountingBefSpace:
            inc bx
            countAfterSpace: ; same thing but count after the ' ' character
                inc counterAftSpace
                inc bx
                mov dl, 7
                mov ax, bx
                div dl
                cmp ah, 0
                jne countAfterSpace
                mov dh, counterAftSpace
                cmp dh, counterBefSpace
                jna skipSwap       
                
                push bx
                push cx
                
                ; summing up the next part of the code, there are 2 "general" blocks of code
                ; by this i mean that they work in a very similar manner with the only difference being that
                ; the first part works on the chars after the space (' ') and the second part works before it
                ; for both sides, the characters are loaded in the stack, then the pointer registers get set and
                ; the stack is unloaded.
                dec bx
                mov cx, 7
                loadStack_1:
                    mov dl, compositions[bx]
                    push dx
                    dec bx
                    cmp compositions[bx], 0
                    loopnz loadStack_1
                reloadBx:
                    inc bx
                    inc cx
                    cmp cx, 7
                    jne reloadBx
                    mov bp, bx
                
                reloadVector1:
                    pop dx
                    mov compositions[bx], dl
                    dec bx
                    loop reloadVector1
                
                mov bx, bp
                mov cx, 0
                loadAftSpace:
                    inc cx
                    mov dl, compositions[bx]
                    push dx
                    dec bx
                    cmp compositions[bx], ' '
                    jne loadAftSpace

                    mov bp, bx
                    add bx, cx
                    reloadAftSpace:
                    pop dx
                    mov compositions[bx], dl
                    dec bx
                    loop reloadAftSpace
                    mov bx, bp
                    dec bx
                
                mov cx, bp    
                loadBefSpace:
                    mov dl, compositions[bx]
                    push dx
                    dec bx
                    loop loadBefSpace
                mov bx, bp
                dec bx
                mov cx, bp
                reloadBefSpace:
                    pop dx
                    mov compositions[bx], dl
                    dec bx
                    loop reloadBefSpace
                    
                pop cx
                pop bx
                skipSwap:
                    loop entryPoint
        ; from here the program starts assigning the values to each character
        assignValues: 
        mov counter, 0 
        mov indexRow, 0 
        mov di, 0
        mov bx, 0
        externalFor_3:
            cmp indexRow, 6
            je exitAssignValues
          
            mov si, indexRow
            mov al, dictionaryLetters[si]
            internalFor_3:
                cmp counter, 6
                je getOutThere!
            
                mov cl, counter ; register reset
                mov si, cx
                mov dl, 7
                push ax
                mov ax, si
                mul dl
                mov bx, ax
                pop ax
                mov cx, 0
                push bx
                mov dx, 0FFFFh
                searchChar: ; from here to line 557 (jmp leavesearch) loop through each char of the block to see if it matches with the current one
                    cmp compositions[bx], al
                    jne skipCharCheck
                    mov dl, cl ; if the character is before the space save the index in 'dl'
                    
                    skipCharCheck:
                    cmp compositions[bx], ' '
                    jne skipSpaceCheck
                    mov dh, cl ; save the index of the space in dh
                    
                    skipSpaceCheck: ; check next element
                    inc bx
                    inc cx
                    
                    cmp cx, 7
                    je leaveSearch
                    jmp searchChar
                    
                leaveSearch:
                pop bx
                
                cmp dl, 0FFh ; don't perform any action if the character wasn't found here, proceed with the next block
                je keepGoing
                
                cmp dl, dh ; check if the character is before or after the space and based on its position assign a '0' or '1'
                ja assign1
                
                mov dictionaryEncodings[di], '0'
                inc di
                jmp skipAssign1
                
                assign1:
                mov dictionaryEncodings[di], '1'
                inc di
                
                skipAssign1:
                cmp dimensionCompositions[si], 3 ; but... if the char was found and there are only 3 elements in total in the current block then go for the next char, you surely won't find this one again...
                jne keepGoing
                
                getOutThere!: ; set the registers to look for the next char in the alphabet
                inc indexRow
                mov counter, 0
                mov ch, 6
                mov ax, 0
                mov ax, indexRow
                mul ch
                mov di, ax
                jmp externalFor_3
                
                keepGoing:
                inc counter
                jmp internalFor_3                           
    
    ; binary value assignment is finished, now the last part of the program, managing user input
    exitAssignValues: ; reset the registers
    mov cx, 6
    mov si, 0
    mov di, 0
    printValues: ; the code to line 641 has the task to print to screen the binary encoding of each letter of the alphabet
        mov ah, 9
        lea dx, string1
        int 21h
        
        mov ah, 2
        mov dl, letters[si]
        int 21h
        
        mov ah, 9
        lea dx, string2
        int 21h
        
        push cx
        mov dh, 6
        mov ax, si
        mul dh
        mov di, ax
        mov cx, 6
        mov ah, 2
        printHuffmanValue:
            mov dl, dictionaryEncodings[di]
            int 21h
            inc di
            cmp dictionaryEncodings[di], 0
            loopnz printHuffmanValue
    pop cx
    inc si
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    loop printValues   
    
    mov si, 0
    mov di, 0
    mov bx, 0
    
    repeatFromHere:
    mov ah, 9
    lea dx, CRLF
    int 21h
    lea dx, string3
    int 21h
    inputChoice: ; start the actual program by reading from user input which task has to be performed
    mov ah, 1
    int 21h
    cmp al, 'c' ; encoding
    je encodingProcess
    cmp al, 'd' ; decoding 
    je decodingProcess
    jmp inputChoice ; repeat the process if the user's input is not valid
    
    ; start here the encoding process
    encodingProcess: ; essential preparations....
        mov ah, 9
        lea dx, CRLF
        int 21h
        
        mov bx, 0 ; the decoding process will reset the values automatically by doing some operations but the encoding process will not so i have to reset the values if i want the program to work multiple times
        mov si, 0
        mov di, 0
        begin:
        mov ah, 1
        int 21h
        
        cmp al, 13
        je encode
        cmp bx, 10 ; maximum 10 letters per message, you can change this, but don't pass 20, i mean it is difficult to build words that make sense that are so long and with such few letters
        je encode
        
        mov bufferInput[bx], al
        inc bx
        inc cx
        jmp begin
    
        encode:
        mov ah, 9
        lea dx, string4
        int 21h
            
        beginEncoding: ; start encoding for real now
        mov dh, bufferInput[si] ; put the character to encode in 'dh'
        mov bx, 0       
        searchCharInMainVector: ; search the n-th character in the alphabet and get its binary char sequence
            cmp dh, dictionaryLetters[bx]
            je stopSearching
            inc bx
            jmp searchCharInMainVector
        stopSearching: ; when found, first get a few registers ready...
            mov ax, bx
            mov dl, 6
            mul dl
            mov di, ax
            mov ah, 2
            printCharEncoding: ; ...and then send to standard output the binary char sequence
                mov dl, dictionaryEncodings[di]
                int 21h
                inc di
                cmp dictionaryEncodings[di], 0 ; if a byte is null then that means that the printing is finished
                jne printCharEncoding
        stopPrinting:
        inc si
        loop beginEncoding ; repeat the process for the next char 
    jmp quitProgram
    
    ; start from here the decoding process
    decodingProcess: ; essential preparations....
    mov ah, 9
    lea dx, CRLF
    int 21h
    
    mov bx, 0    
    begin_2:
    mov ah, 1
    int 21h
    
    cmp al, 13
    je decode
    cmp bx, 20
    je decode
    
    mov bufferInput[bx], al
    inc bx
    inc cx
    jmp begin_2
    
    decode: 
    mov boolean, 1
    mov ah, 9
    lea dx, string5
    int 21h
    
    beginDecoding: ; start decoding from here now
        cmp boolean, 0
        je quitProgram
        
        mov di, 0
        mov bx, 0
        mov counter, 6
        push bx
        mov cx, 6        
        setBooleanVector: ; initialize the boolean vector with every value set to 'true'
            mov checker_alphabet_decoder[bx], 1
            inc bx
            loop setBooleanVector
        pop bx    
        
        determineChar: ; start looking for the character
            cmp counter, 1
            je writeChar
            
            mov dh, bufferInput[bx] ; move in 'dh' the n-th character of the user input
            mov counterInternalFor, 0
            externalFor_4: ; note: each element of the checker_alphabet_decoder is logically binded to a character of the alphabet
                cmp counterInternalFor, 6
                je exitFor
                
                mov di, counterInternalFor ; get a few registers ready for all the operations
                mov si, counterInternalFor
                mov ax, si
                mov dl, 6
                mul dl
                add ax, bx
                mov si, ax ; 'si' is the pointer used for the table of encodings while 'di' is used to iterate through 'C'
                
                cmp checker_alphabet_decoder[di], 1 ; if the current char has proved not to be the one then skip the checking process for it
                jne skipIt
                cmp dh, dictionaryEncodings[si] ; check if in the current position the character's binary encoding matches
                je skipIt ; if so fine
                dec counter
                mov checker_alphabet_decoder[di], 0 ; else mark it as the "wrong" character
                
                skipIt:
                    inc counterInternalFor ; proceed with next bit
                    jmp externalFor_4
                
            exitFor:
                inc bx ; bx loops through the user input, so here as said proceed with the next bit
                jmp determineChar
                
        writeChar: ; now check which character is the correct one, just loop through 'checker_alphabet_decoder' once again and look which position contains 'true'
            mov cx, 6
            mov di, 0
            findTrue:
                cmp checker_alphabet_decoder[di], 1
                je foundIt
                inc di
                loop findTrue
                   
            foundIt: ; when the index is found
            mov ah, 2
            mov dl, dictionaryLetters[di] ; get the corresponding character from the dictionary
            int 21h
            
            push bx
            dec bx
            mov cx, bx
            inc cx
            deleteElements: ; i have no idea why i did this however this part of code simply deletes the decoded part of the message 
                            ; i mean, every time i decode a character, look for the bits occupied in the 'bufferInput' and delete them
                mov bufferInput[bx], 0
                dec bx
                loop deleteElements
            pop bx
            getBxReady:
                cmp bx, 20
                je stopGettingBXReady
                cmp bufferInput[bx], 0
                je stopGettingBXReady
                inc bx 
                inc cx
                jmp getBxReady
                
            stopGettingBXReady:
                dec bx
                mov counter, 0
                loadStack_2:
                    mov dl, bufferInput[bx]
                    push dx
                    mov bufferInput[bx], 0
                    dec bx
                    inc counter
                    cmp bx, 0FFFFh
                    je quitProgram
                    loop loadStack_2
                mov bx, 0
                mov cl, counter
                fixString:
                    pop dx
                    mov bufferInput[bx], dl
                    inc bx
                    loop fixString
                
                mov si, 0
                mov cx, 20
                countLength:
                    cmp bufferInput[si], 0
                    je skip
                    inc dh
                    skip:
                    loop countLength
                    
                cmp dh, 0 ; while data exists, there are still characters to decode so move on with the next ones
                jne dontClose
                mov boolean, 0
                dontClose:
                jmp beginDecoding
                
    quitProgram:
        mov bx, 0
        mov cx, 20
        resetBuffer: ; i free the vector containing the input so that i can use it for another input
           mov bufferInput[bx], 0
           inc bx
           loop resetBuffer
            
    jmp repeatFromHere ; go on for another task
end 
