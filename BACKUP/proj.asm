.MODEL SMALL
.DATA
    PULA_LINHA db 10D,13D,'$'   ;PULA LINHA
    NOME DB "Nome do aluno: $"
    MSGNOTA DB "NOTA DO ALUNO: $"
    NOMES DB 32, ?, 32 DUP('$'), 4 DUP(?)
          DB 32, ?, 32 DUP('$'), 4 DUP(?)
          DB 32, ?, 32 DUP('$'), 4 DUP(?)
          DB 32, ?, 32 DUP('$'), 4 DUP(?)
          DB 32, ?, 32 DUP('$'), 4 DUP(?)
.CODE
MAIN PROC
    MOV AX, @DATA               ;INICIA O SEGMENTO DE DADOS E O SEGMENTO EXTRA
    MOV DS, AX
    MOV ES, AX

    MOV CX, 5                   ;INICIA CONTADOR EM 5, POIS RECEBERA 5 NOMES
    LOOPNOMES:  

;PULA LINHA           
    mov dl,10                   
    mov ah,02
    int 21h

;IMPRIME A MENSAGEM EM 'NOME'
    LEA DX, NOME               ;APONTA DX PARA OFFSET NOME PARA IMPRIMIR SUA MENSAGEM
    MOV AH, 9                   ;PREPARA AH PARA A IMPRESSAO DE UMA STRING
    INT 21H                     ;IMPRIME A STRING NOME

;APONTA PARA NOMES + BX (BX INDICA QUAL NOME IRA RECEBER(1º, 2º 3º...))
    LEA DX, NOMES + BX              ;APONTA DX PARA O OFFSET NOMES, QUE VAI CAPTURAR UM INPUT DE STRING DO USUÁRIO
    CALL RECEBE_NOME
    ADD BX, 38                       ;aponta para o proximo nome(linha de baixo)
    
;PULA LINHA 
    lea dx, PULA_LINHA
    mov ah,09h
    int 21h

    CALL ENTNOTAS

    LEA BX, NOMES
    MOV AH, 02
    MOV DX, [BX + SI]
    OR DX, 30H
    INT 21H


    ;LOOP LOOPNOMES


    mov ah,4ch          ; funcao de termino
    int 21h



;CONFERE SE NOMES TEM A STRING
    ;mov dl,10
    ;mov ah,02
    ;int 21h
    ;lea DX, NOMES + BX
    ;mov ah, 09
    ;int 21h
    ;ADD BX, 32
    ;LOOP LOOPNOMES



    ;mov ah,4ch                  ; funcao de termino
    ;int 21h
MAIN ENDP

RECEBE_NOME PROC

    PUSH AX

    MOV AH, 0AH                 ;PREPARA AH PARA RECEBER UM STRING, ATÉ ENTER(13) SER CAPTURADO
    INT 21H                     ;RECEBE A STRING DO USUÁRIO

    POP AX

    RET
RECEBE_NOME ENDP

ENTNOTAS PROC
;printa msgnota
    LEA DX, MSGNOTA
    MOV AH, 09h
    INT 21H

;RECEBE NOTA EM DECIMAL E SALVA EM BINARIO
    CALL ENTDEC


    RET
ENTNOTAS ENDP

ENTDEC PROC
    ;NAO RECEBE NADA DA MAIN
    ;DEVOLVE BX COM O VALOR DIGITADO PRA MAIN
        XOR BX, BX                                  ;ZERA BX POIS ELE SERA UTILIZADO PARA DIVISÃO NA FUNÇÃO

    RECEBEDEC:
        MOV AH, 01                                  ;COMO AH É LIMPO LOGO A FRENTE, REDEFINO ELE AQUI
        INT 21H                                     ;RECEBE INPUT NÚMERICO

        CMP AL, 13                                  ;SE FOR CARRIAGE RETURN, O NUMERO FOI FINALIZADO
        JE ENTDECFIM                                ;PORTANTO PULA PARA O FIM DA FUNÇÃO

        CMP AL, '0'                                 ;SE FOR MENOR QUE '0'
        JB RECEBEDEC                                ;PEDE NOVO INPUT, POIS O ATUAL É INVALIDO

        CMP AL, '9'                                 ;SE FOR KAIOR QUE '9'
        JA RECEBEDEC                                ;PEDE NOVO INPUT, POIS O ATUAL É INVALIDO

    DECPARABIN:
        XOR AH, AH                                  ;LIMPO AH, PARA EVITAR QUE BX RECEBA UM LIXO INDESEJADO

        AND AL, 0FH                                 ;TRANSFORMA NUMERO(CARACTERE) EM BINARIO
        PUSH AX                                     ;SALVA NUMERO NA PILHA POIS AX RECEBERA 10

        MOV AX, 10                                  ;AX RECEBE 10 PARA FAZER A CONTA (AX=10*BX+INPUT) OBS: O 10 É O AX
        MUL BX                                      ;REALIZA AX * BX E GUARDA VALOR EM AX (AX=AX*BX)
        POP BX                                      ;RECUPERA VALOR DE AX NA PILHA E COLOCA-O EM BX
        ADD BX, AX                                  ;SOMA BX + AX E GUARDA EM BX (BX=BX+AX)

        JMP RECEBEDEC                               ;RECEBE MAIS UM INPUT

    ENTDECFIM:

        MOV AX, BX ;IGNORAR P/ ENQUANTO

        LEA BX, NOMES
        MOV SI, BX
        ADD SI, 34
        MOV [BX + SI], AX
        RET                                         ;RETOMA O CONTROLE PARA A ROTINA
ENTDEC ENDP

END MAIN