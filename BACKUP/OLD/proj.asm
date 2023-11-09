.MODEL SMALL
.DATA
    PULA_LINHA db 10D,13D,'$'   ;PULA LINHA
    BUFFER DB 32, ?, 32 dup ('$')                ;NUMERO DE CARACTERES QUE PODE SER LIDO, NUMERO DE CARACTERES LIDO, STRING
    NOME DB "Nome do aluno: $"
    MSGNOTA DB "NOTA DO ALUNO: $"
    NOMES DB 32 DUP(?)
          DB 32 DUP(?)
          DB 32 DUP(?)
          DB 32 DUP(?)
          DB 32 DUP(?)
.CODE
MAIN PROC
    MOV AX, @DATA               ;INICIA O SEGMENTO DE DADOS
    MOV DS, AX

    MOV CX, 5

    LOOPNOMES:
    mov dl,10
    mov ah,02
    int 21h
    LEA DX, NOME               ;APONTA DX PARA OFFSET NOME PARA IMPRIMIR SUA MENSAGEM
    MOV AH, 9                   ;PREPARA AH PARA A IMPRESSAO DE UMA STRING
    INT 21H                     ;IMPRIME A STRING NOME

    LEA DX, BUFFER              ;APONTA DX PARA O OFFSET BUFFER, QUE VAI CAPTURAR UM INPUT DE STRING DO USUÁRIO
    CALL RECEBE_NOME

    
;CONFERE SE BUFFER + 2 CONTEM A STRING
    lea dx, PULA_LINHA
    mov ah,09h
    int 21h

    lea dx, BUFFER + 2
    int 21h

    CALL COPIA

    CALL ENTNOTAS
;CONFERE SE NOMES TEM A STRING
    mov dl,10
    mov ah,02
    int 21h
    lea DX, NOMES + BX
    mov ah, 09
    int 21h
    ADD BX, 32
    LOOP LOOPNOMES



    mov ah,4ch                  ; funcao de termino
    int 21h
MAIN ENDP

RECEBE_NOME PROC

    PUSH AX

    MOV AH, 0AH                 ;PREPARA AH PARA RECEBER UM STRING, ATÉ ENTER(13) SER CAPTURADO
    INT 21H                     ;RECEBE A STRING DO USUÁRIO

    POP AX

    RET
RECEBE_NOME ENDP

COPIA PROC
    push cx
    push si
    push di
    push ax

    lea si, BUFFER + 2
    lea di, NOMES + BX
    MOV CX, 32
LOOPCOPIA:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    Loop LOOPCOPIA

    POP AX
    POP DI
    POP SI
    POP CX

    RET
COPIA ENDP

ENTNOTAS PROC
    LEA DX, MSGNOTA
    MOV AH, 09h
    INT 21H

    MOV AH, 01
    INT 21H

    RET
ENTNOTAS ENDP
END MAIN