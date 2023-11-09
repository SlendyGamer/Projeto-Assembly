.MODEL SMALL

    PULALINHA MACRO
    PUSHALL
    MOV AH, 02
    MOV DL, 10
    INT 21H
    MOV DL, 13
    INT 21H
    POPALL
    ENDM

    PUSHALL MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    ;PUSH SI
    ENDM

    POPALL MACRO
    ;POP SI
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    ENDM

.STACK 100H
.DATA

    NOME DB "Nome do aluno: $"

    MSGNOTA DB "NOTA DO ALUNO: $"

    TABELA DB 32, ?, 32 DUP('$'), 4 DUP(?)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)

.CODE

    MAIN PROC
        MOV AX, @DATA               ;INICIA O SEGMENTO DE DADOS E O SEGMENTO EXTRA
        MOV DS, AX
        MOV ES, AX


        XOR BX, BX
        MOV CX, 5                   ;INICIA CONTADOR EM 5, POIS RECEBERA A INFORMAÇÃO DE 5 ESTUDANTES


        LOOPNOMES:       


        PULALINHA
                                        ;PARA TESTE
                                        JMP SALTOU1
                                            JMPSALVA2:
                                            JMP LOOPNOMES
                                        SALTOU1:

        LEA DX, NOME                ;IMPRIME A MENSAGEM EM 'NOME'
        MOV AH, 9                   
        INT 21H                     


        LEA DX, TABELA + BX          ;APONTA PARA TABELA + BX (BX INDICA QUAL NOME IRA RECEBER(1º, 2º, 3º...))
        CALL RECEBE_NOME
        
                                                        PULALINHA
                                                        ADD DX, 2
                                                        MOV AH, 09    ;CONFERE SE NOME FOI SALVO
                                                        INT 21H

        PULALINHA

        PUSH CX
        MOV CX, 3

            PUSH BX                              
            LEA BX, TABELA + 34                          ;APENAS PARA INICIAR SI NO ELEMENTO CORRETO
            MOV SI, BX                                  ;APONTA SI PARA A MATRIZ DE DADOS
        POP BX
    RECEBENOTA:
        LEA DX, MSGNOTA             ;printa msgnota
        MOV AH, 09h
        INT 21H
        

                                            ;PARA TESTE
                                            JMP SALTOU2
                                                JMPSALVA1:
                                                JMP JMPSALVA2
                                            SALTOU2:

        CALL ENTNOTAS

                                                        PULALINHA
                                                        PUSH BX
                                                        MOV BX, DX
                                                        MOV AH, 02
                                                        DEC SI
                                                        MOV DX, [BX + SI]
                                                        INC SI
                                                        OR DX, 30H
                                                        INT 21H
                                                        POP BX

        PULALINHA

    LOOP RECEBENOTA
    POP CX

        CALL MEDIA
                                                        PULALINHA
                                                        PUSH BX
                                                        MOV BX, DX
                                                        MOV AH, 02
                                                        MOV DX, [BX + SI]
                                                        OR DX, 30H
                                                        INT 21H
                                                        POP BX




        ADD BX, 38                  ;aponta para o proximo nome(linha de baixo)
        DEC CX
        CMP CX, 0
        JNE JMPSALVA1




        ;CALL SAIDEC


        mov ah,4ch          ; funcao de termino
        int 21h

    MAIN ENDP






            ENTNOTAS PROC
                ;NAO RECEBE NADA DA MAIN
                ;DEVOLVE BX COM O VALOR DIGITADO PRA MAIN

                    PUSH BX
                    LEA BX, TABELA + BX
                    CALL ENTDEC
                    MOV [BX + SI], AX
                    INC SI
                                                                                            MOV DX, BX ;APENAS PARA TESTE
                    POP BX
                    RET                                         ;RETOMA O CONTROLE PARA A ROTINA
            ENTNOTAS ENDP






            MEDIA PROC
                PUSH CX
                PUSH BX
                LEA BX, TABELA + 34
                MOV SI, BX
                MOV CX, 3
                XOR AX, AX


                POP BX
                PUSH BX
                LEA BX, TABELA + BX
            LOOPSOMA:
                ADD AL, [BX + SI]       ;PORQUE AX TEM LIXO??
                INC SI
            LOOP LOOPSOMA
                PUSH BX
                XOR DX, DX
                MOV BX, 3
                DIV BX
                POP BX

                MOV [BX + SI], AX   ;ERRO??? NAO DEU UHUUUUUUUUUUUUUUU

                                                    MOV DX, BX ;APENAS PARA TESTE
                POP BX
                POP CX
                RET
            MEDIA ENDP






    RECEBE_NOME PROC

        PUSHALL
        ;PUSH AX

        MOV AH, 0AH                 ;PREPARA AH PARA RECEBER UM STRING, ATÉ ENTER(13) SER CAPTURADO
        INT 21H                     ;RECEBE A STRING DO USUÁRIO

        POPALL
        ;POP AX
        RET
    RECEBE_NOME ENDP






    ENTDEC PROC
        PUSH BX
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
            MOV AX, BX                                  ;SALVA EM AX, POIS BX SERA USADO COMO PONTEIRO PARA UM ENDEREÇO
            POP BX
            RET
    ENTDEC ENDP






            SAIDEC PROC
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                ;RECEBE DA MAIN O AX COM O VALOR PARA SER IMPRESSO
                ;NAO DEVOLVE NADA PARA MAIN

                PREPARADIV:
                    XOR CX, CX                                  ;ZERA CX POIS ELE SERA USADO COMO CONTADOR
                    MOV BX, 10                                  ;DEFINE BX COMO 10, JÁ QUE AS DIVISÕES SERÃO POR 10

                SEPARADEC:
                    XOR DX, DX                                  ;ZERA DX, POIS DX CONTERÁ O RESTO E SE NÃO FOR LIMPADO A CADA DIVISÃO, PODE CAUSAR OVERFLOW
                    
                    DIV BX                                      ;DIVIDE AX POR BX E GUARDA EM AX O QUOCIENTE E, EM DX, O RESTO
                    PUSH DX                                     ;SALVA O VALOR DO RESTO NA PILHA, QUE SERÁ IMPRESSO DEPOIS
                    INC CX                                      ;INCREMENTA O CONTADOR, ESSE SERÁ O NUMERO DE VEZES QUE A PILHA DEVERÁ SER ACESSADA PARA RECUPERAR OS VALORES DE DX SALVOS
                    
                    OR AX, AX                                   ;SE AX = 0
                    JZ RETORNADEC                               ;SAI DO LOOP, POIS AX INTEIRO JA FOI SALVO NA PILHA
                    JMP SEPARADEC                               ;SE AX != 0, CONTINUA COM AS DIVISÕES

                RETORNADEC:
                    MOV AH, 02                                  ;PREPARA PARA A IMPRESSÃO DO NUMERO DECIMAL

                RETORNALOOP:
                    POP DX                                      ;RECUPERA O VALOR DE DX DA PILHA
                    OR DX, 30H                                  ;TRANSFORMA O NUMERO EM SEU RESPECTIVO CARACTERE
                    INT 21H                                     ;IMPRIME OS NUMEROS, DA ESQUERDA PARA A DIREITA
                    LOOP RETORNALOOP                            ;CONTINUA A IMPRIMIR ATE CX = 0

                POP DX
                POP CX
                POP BX
                POP AX
                    RET                                         ;RETOMA O CONTROLE PARA A ROTINA
            SAIDEC ENDP

END MAIN