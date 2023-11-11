.MODEL SMALL

    PULALINHA MACRO
        PUSH AX
        PUSH DX
        MOV AH, 02
        MOV DL, 10
        INT 21H
        MOV DL, 13
        INT 21H
        POP DX
        POP AX
    ENDM

    PREP_NOTA3X MACRO
        PUSH CX                      ;CX ESTA EM USO MAS PRECISAREMOS UTILIZAR UM LOOP ABAIXO PARA RECEBER 3X NOTAS, PORTANTO SALVO SEU VALOR NA PILHA
        MOV CX, 3

        PUSH BX                  ;MESMA SITUAÇÃO DE CX, BX CONTEM A INFORMAÇÃO DE QUE LINHA ESTAMOS, PORTANTO NAO PODEMOS PERDER ESSE VALOR      
        MOV SI, 34      ;PARA PODER DEFINIR SI COMO ELEMENTO 34, PRECISAMOS DEFINIR POR MEIO DE BX COMO PONTEIRO BASE             

        POP BX                   
    ENDM

    PRINTSTRING MACRO
        PUSH AX
        MOV AH, 09
        INT 21H
        POP AX
    ENDM

    ESPACA MACRO
        PUSH AX
        PUSH DX

        LEA DX, ESPACO
        MOV AH, 09
        INT 21H

        POP DX
        POP AX
    ENDM
.STACK 100H
.DATA

    MSGNOME DB "Nome do aluno: $"

    MSGNOTA DB "NOTA DO ALUNO: $"

    TABELA DB 32, ?, 32 DUP('$'), 4 DUP(?)          ;QUANTIDADE DE CARACTERES DA STRING EM TABELA + 1 (NAO CONTA O ENTER)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)          ;STRING EM TABELA + 2 (MAX. 30 CARACTERES + ENTER + $)
           DB 32, ?, 32 DUP('$'), 4 DUP(?)          ;NOTAS EM  TABELA + 34, 35 E 36
           DB 32, ?, 32 DUP('$'), 4 DUP(?)          ;MEDIA EM  TABELA + 37
           DB 32, ?, 32 DUP('$'), 4 DUP(?)          ;NOVA LINHA DE 38 EM 38 (TABELA + 38) // DIRETAMENTE ABAIXO DO ELEMENTO QUE ESTA SENDO APONTADO

    MENUPRINC DB 'O QUE DESEJA FAZER?',10,13
        Q     DB '1 - VER TABELA',10,13
              DB '2 - EDITAR NOTAS',10,13
              DB '0 - SAIR',10,13,'$'

    MENUPESQ DB 'DESEJA PESQUISAR POR:',10,13
             DB '1 - NOMES',10,13
             DB '2 - NOTAS',10,13
             DB '0 - RETORNAR',10,13,'$'

    ESPACO DB ' $'

.CODE

    MAIN PROC
        MOV AX, @DATA               ;INICIA O SEGMENTO DE DADOS E O SEGMENTO EXTRA
        MOV DS, AX
        MOV ES, AX

        XOR BX, BX                  ;ZERA BX PARA TER CERTEZA QUE FOI INICIADO COM 0
        MOV CX, 5                   ;INICIA CONTADOR EM 5, POIS RECEBERA A INFORMAÇÃO DE 5 ESTUDANTES


    LOOPNOMES:   
        XOR SI, SI    
        PULALINHA

        LEA DX, MSGNOME                ;IMPRIME A MENSAGEM EM 'NOME'
        PRINTSTRING                   

        LEA DX, TABELA + BX          ;APONTA PARA TABELA + BX (BX INDICA QUAL NOME IRA RECEBER(1º, 2º, 3º...))(BX INICIA C/ 0 E SERA INCREMENTADO DE 38 EM 38)
        CALL RECEBE_NOME

        PULALINHA

        ;PREP_NOTA3X
                            PUSH CX                      ;CX ESTA EM USO MAS PRECISAREMOS UTILIZAR UM LOOP ABAIXO PARA RECEBER 3X NOTAS, PORTANTO SALVO SEU VALOR NA PILHA
                            MOV CX, 3

                            PUSH BX                  ;MESMA SITUAÇÃO DE CX, BX CONTEM A INFORMAÇÃO DE QUE LINHA ESTAMOS, PORTANTO NAO PODEMOS PERDER ESSE VALOR      
                            MOV SI, 34      ;PARA PODER DEFINIR SI COMO ELEMENTO 34, PRECISAMOS DEFINIR POR MEIO DE BX COMO PONTEIRO BASE             

                            POP BX                         
    RECEBENOTA:
        LEA DX, MSGNOTA             ;IMPRIME A MENSAGEM EM 'NOME'
        PRINTSTRING
        
        CALL ENTNOTAS

    LOOP RECEBENOTA
        POP CX

        CALL CALCMEDIA


        ADD BX, 37                  ;APONTA PARA A PROXIMA LINHA DA MATRIZ(PROXIMO ALUNO)
    LOOP LOOPNOMES

    RETURN:
        PULALINHA
        PULALINHA

        LEA DX, MENUPRINC
        PRINTSTRING

        MOV AH, 01
        SELECT_MENU:

        INT 21H                                     ;RECEBE OPÇÃO SELECINADA PELO USUÁRIO

        CMP AL, '1'                                 ;SE FOR 1
        JE VIEW                             ;PULA PARA BIN_ENTRADA

        CMP AL, '2'                                 ;SE FOR 2
        JE EDIT                              ;PULA PARA DEC_ENTRADA

        CMP AL, '0'                                 ;SE FOR 3
        JE EXIT                             ;PULA PARA HEX_ENTRADA

        JMP SELECT_MENU                          ;SE FOR QUALQUER OUTRA COISA ALÉM DE 1,2 OU 3, PEDE INPUT NOVAMENTE

    VIEW:
        
        CALL SAITABELA
        JMP RETURN

    EDIT:

        PULALINHA

        LEA DX, MENUPESQ
        PRINTSTRING

        MOV AH, 01
        SELECT_PESQ:

        INT 21H                                     ;RECEBE OPÇÃO SELECINADA PELO USUÁRIO

        CMP AL, '0'                                 ;SE FOR 3
        JE RETURN                             ;PULA PARA HEX_ENTRADA

        CMP AL, '1'                                 ;SE FOR 1
        JE PESQNOME                             ;PULA PARA BIN_ENTRADA

        CMP AL, '2'                                 ;SE FOR 2
        JE PESQNOTA                              ;PULA PARA DEC_ENTRADA

        JMP SELECT_PESQ                          ;SE FOR QUALQUER OUTRA COISA ALÉM DE 1,2 OU 3, PEDE INPUT NOVAMENTE

    PESQNOME:

    PESQNOTA:



    EXIT:

        mov ah,4ch          ; funcao de termino
        int 21h

    MAIN ENDP




    RECEBE_NOME PROC
        ;FUNÇÃO PERMITE O USUARIO DIGITAR UM NOME, EDITANDO O COM BACKSPACE, SEM PROBLEMAS
        ;NAO RECEBE PARAMETROS
        ;DEVOLVE A STRING DIGITADA E A QUANTIDADE DE CARACTERES DIGITADOS
        PUSH BX
        PUSH AX
        PUSH DX

        MOV AH, 0AH                 ;RECEBERA UM STRING
        INT 21H                     ;RECEBE A STRING DO USUÁRIO
        LEA BX, TABELA + BX ; BX = Número de caracteres digitados - 1 (não conta Enter)

        ; Move BX para o fim da string
        INC BX          ;aponta 1 casa depois do ultimo caracter *contado*(enter)
        MOV DL, [BX]    ;RECEBE N DE CARACTERES DIGITADOS - 1(ENTER)
        INC BX
        ADD BX, DX      ;APONTA BX PARA A MESMA POSIÇÃO PARA PODER INSERIR NA MEMORIA
        MOV DL, '$'

        ; troca enter por $
        MOV [BX], DL
        
        POP DX
        POP AX
        POP BX
        RET
    RECEBE_NOME ENDP




    ENTNOTAS PROC
        ;UTILIZA BX PARA APONTAR PARA A LINHA DO RESPECTIVO ALUNO NA MATRIZ, PRMITINDO A INSERÇAO DA NOTA NO LUGAR CORRETO (0, 38, ...)
        ;UTILIZA SI PARA APONTAR PARA O ELEMENTO CORRETO DAS NOTAS NA LINHA (34, 35, 36)
        ;CHAMA DENTRO DE SI A FUNÇÃO PARA RECEBER NOTAS, ENTDEC
        ;SI É DEVOLVIDO COM A POSIÇÃO DO ELEMENTO 37 NA MATRIZ, PARA FACILITAR A INSERÇÃO DAS MÉDIAS NESSA POSIÇÃO.
        PUSH BX
        
        LEA BX, TABELA + BX         ;APONTA PARA A LINHA DO RESPECTIVO ALUNO
        CALL ENTDEC

        MOV [BX + SI], AX
        INC SI

        POP BX
        RET                                         ;RETOMA O CONTROLE PARA A ROTINA
    ENTNOTAS ENDP




    ENTDEC PROC
        ;NAO RECEBE PARAMETROS
        ;FAZ O USUARIO INSERIR UM INPUT NUMERICO, NA FORMA DE CARACTERE, DEVOLVENDO O SEU RESPECTIVO VALOR EM AX, NA FORMA DE NUMERO
        ;CONVERTE O VALOR RECEBIDO PARA NUMERO POR MEIO DE MULTIPLICAÇÕES SUCESSIVAS POR 10
        PUSH BX
        XOR BX, BX                                  ;ZERA BX POIS ELE SERA UTILIZADO PARA A DIVISÃO NA FUNÇÃO

    RECEBEDEC:
        MOV AH, 01                                  ;COMO AH É LIMPO LOGO A FRENTE, REDEFINO ELE AQUI.
        INT 21H                                     

        CMP AL, 13                                  ;COMPARA VALOR RECEBIDO COM CARRIAGE RETURN
        JE ENTDECFIM                                ;SE FOR, FINALIZA O INPUT

        CMP AL, '0'                                 ;SE FOR MENOR QUE '0'
        JB RECEBEDEC                                ;PEDE NOVO INPUT, POIS VALOR É INVALIDO

        CMP AL, '9'                                 ;SE FOR MAIOR QUE '9'
        JA RECEBEDEC                                ;PEDE NOVO INPUT, POIS VALOR É INVALIDO

    DECPARABIN:
        XOR AH, AH                                  ;LIMPO AH, PARA EVITAR QUE BX MULTIPLIQUE UM LIXO INDESEJADO

        AND AL, 0FH                                 ;TRANSFORMA NUMERO(CARACTERE) EM BINARIO
        PUSH AX                                     ;SALVA NUMERO NA PILHA

        MOV AX, 10                                  ;AX RECEBE 10 PARA FAZER A CONTA (AX=10*BX+INPUT) OBS: O 10 É O AX
        MUL BX                                      ;REALIZA AX * BX E GUARDA VALOR EM AX (AX=AX*BX), ISSO ABRE ESPACO PARA JUNTAR OS NUMEROS
        POP BX                                      ;RECUPERA VALOR DE AX NA PILHA E COLOCA-O EM BX
        ADD BX, AX                                  ;SOMA BX + AX E GUARDA EM BX (BX=BX+AX)

        JMP RECEBEDEC                               ;RECEBE MAIS UM INPUT

    ENTDECFIM:
        MOV AX, BX                                  ;SALVA EM AX O VALOR FINAL NOVAMENTE, PARA RETORNÁ-LO À FUNÇÃO

        POP BX
        RET
    ENTDEC ENDP




    CALCMEDIA PROC
        PREP_NOTA3X

        XOR AX, AX              ;LIMPA A ULTIMA NOTA DE AX

        PUSH BX                 ;BX SERA MUITO UTILIZADO ABAIXO, PORTANTO SALVA-SE BX
        LEA BX, TABELA + BX     ;APONTA PARA A LINHA DO RESPECTIVO ALUNO

    LOOPSOMA:
        ADD AL, [BX + SI]       ;SOMA O VALOR DAS NOTAS, SALVANDO A SOMA EM AX
        INC SI                  ;APONTA PARA A PROXIMA NOTA A SER SOMADA

    LOOP LOOPSOMA

        PUSH BX                 ;SALVA BX NOVAMENTE POIS OCORRERA A DIVISÃO DA MEDIA
        XOR DX, DX              ;GARANTE QUE DX ESTA LIMPO PARA EVITAR OVERFLOW

        MOV BX, 3               ;DEFINE O VALOR DO DIVISOR
        DIV BX                  ;DIVIDE AX/3 E GUARDA EM AX O VALOR DO RESULTADO

        POP BX                  ;RECUPERA O VALOR DE BX QUE APONTA PARA A LINHA

        MOV [BX + SI], AX       ;COPIA PARA A POSIÇÃO DA MATRIZ(BX + 37) O VALOR DA MEDIA FINAL

        POP BX                  ;RECUPERA O VALOR DE BX ORIGINAL
        POP CX                  ;RETORNA O CONTADOR AO SEU VALOR ORIGINAL
        RET
    CALCMEDIA ENDP




    SAITABELA PROC
        LEA BX, TABELA
        MOV CX, 5
        PULALINHA
    SAILINHA:
        MOV SI, 34                         
        MOV DX, BX
        ADD DX, 2                


        MOV AH, 09
        INT 21H

        ESPACA

        PUSH CX
        MOV CX, 4

    SAINOTA:
        CALL SAIDEC
                                                MOV AX, [BX + SI]
                                                MOV DL, AL
                                                OR DL, 30H
                                                MOV AH, 02
                                                INT 21H

        ESPACA

        INC SI
    LOOP SAINOTA
        POP CX
        ADD BX, 37
        PULALINHA
    LOOP SAILINHA
        RET
    SAITABELA ENDP



            SAIDEC PROC
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
                ;RECEBE DA MAIN O ENDEREÇO MATRICIAL [BX+SI] COM O VALOR PARA SER IMPRESSO
                ;NAO DEVOLVE NADA PARA MAIN
                    MOV AX, [BX + SI]
                PREPARADIV:
                    XOR CX, CX                                  ;ZERA CX POIS ELE SERA USADO COMO CONTADOR
                    MOV BX, 10                                  ;DEFINE BX COMO 10, JÁ QUE AS DIVISÕES SERÃO POR 10

                SEPARADEC:
                    XOR DX, DX                                  ;ZERA DX, POIS DX CONTERÁ O RESTO E SE NÃO FOR LIMPADO A CADA DIVISÃO, PODE CAUSAR OVERFLOW
                    
                    DIV BX                                      ;DIVIDE AX POR BX E GUARDA EM AX O QUOCIENTE E, EM DX, O RESTO
                    PUSH DX                                     ;SALVA O VALOR DO RESTO NA PILHA, QUE SERÁ IMPRESSO DEPOIS
                    INC CX                                      ;INCREMENTA O CONTADOR, ESSE SERÁ O NUMERO DE VEZES QUE A PILHA DEVERÁ SER ACESSADA PARA RECUPERAR OS VALORES DE DX SALVOS
                    
                    OR AX, AX                                   ;SE AX = 0
                    JNZ SEPARADEC                               ;SE AX != 0, CONTINUA COM AS DIVISÕES

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