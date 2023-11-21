TITLE TABELA_DE_NOTAS
.MODEL SMALL
                                                        ;GABRIEL CAROTTI THEOTONIO RIOS --- RA: 23017015
    PULALINHA MACRO
        ;MACRO PARA IMPRIMIR UMA NOVA LINHA
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

    LINHAVERTICAL MACRO
        ;MACRO PARA IMPRIMIR UMA LINHA VERTICAL '|'
        PUSH DX
        PUSH AX
        MOV AH, 02
        MOV DL, '|'
        INT 21H
        POP AX
        POP DX
    ENDM

    ALTERACOR MACRO
        PUSH CX
        PUSH DX
        PUSH BX
        XOR BH, BH
        MOV AH, 09
        MOV AL, 0
        MOV CX, 2
        CMP BYTE PTR [BX + SI], 5
        JAE VERDE
        MOV BL, 12
        JMP RED
        VERDE:
        MOV BL,2
        RED:
        INT 10H
        POP BX
        POP DX
        POP CX
    ENDM

    PREP_NOTA3X MACRO
        ;MACRO PARA PREPARAR A RECEPÇÃO DE TRÊS NOTAS
        PUSH CX                      ;CX ESTA EM USO MAS PRECISAREMOS UTILIZAR UM LOOP ABAIXO PARA RECEBER 3X NOTAS, PORTANTO SALVO SEU VALOR NA PILHA
        MOV CX, 3

        PUSH BX                  ;MESMA SITUA??O DE CX, BX CONTEM A INFORMA??O DE QUE LINHA ESTAMOS, PORTANTO NAO PODEMOS PERDER ESSE VALOR      
        MOV SI, 34      ;PARA PODER DEFINIR SI COMO ELEMENTO 34, PRECISAMOS DEFINIR POR MEIO DE BX COMO PONTEIRO BASE             

        POP BX                   
    ENDM

    PRINTSTRING MACRO
        ; Macro para imprimir uma string
        PUSH AX
        MOV AH, 09
        INT 21H
        POP AX
    ENDM

    ESPACA MACRO
        ; Macro para imprimir um espaço
        PUSH AX
        PUSH DX

        LEA DX, ESPACO
        MOV AH, 09
        INT 21H

        POP DX
        POP AX
    ENDM
    
    LIMPAENTER MACRO
        ; Macro para limpar o caractere Enter de uma string
        PUSH BX
        PUSH DX
        ; Move BX para o fim da string
        INC BX          ;aponta 1 casa depois do ultimo caracter *contado*(enter)
        MOV DL, [BX]    ;RECEBE N DE CARACTERES DIGITADOS - 1(ENTER)
        INC BX
        ADD BX, DX      ;APONTA BX PARA A MESMA POSI??O PARA PODER INSERIR NA MEMORIA
        MOV DL, ' '

        ; troca enter por $
        MOV [BX], DL
        
        POP DX
        POP BX
    ENDM
.STACK 100H
.DATA
    MSGNOME DB "Nome do aluno: $"

    MSGNOTA DB "NOTA DO ALUNO: $"

    TABELA DB 5 DUP (31, ?, 31 DUP(' '), '$', 4 DUP(0))          ;QUANTIDADE DE CARACTERES DA STRING EM TABELA + 1 (NAO CONTA O ENTER). STRING EM TABELA + 2 (MAX. 30 CARACTERES + ENTER + $). NOTAS EM  TABELA + 34, 35 E 36.
                    ;31, ?, 31 DUP(' '), '$', 4 DUP(0)            ;MEDIA EM  TABELA + 37.NOVA LINHA DE 38 EM 38 (TABELA + 38) // DIRETAMENTE ABAIXO DO ELEMENTO QUE ESTA SENDO APONTADO.
                    ;31, ?, 31 DUP(' '), '$', 4 DUP(0)
                    ;31, ?, 31 DUP(' '), '$', 4 DUP(0)
                    ;31, ?, 31 DUP(' '), '$', 4 DUP(0)

    MENUPRINC DB 'O QUE DESEJA FAZER?',10,13
              DB '1 - VER TABELA',10,13
              DB '2 - EDITAR NOTAS',10,13
              DB '0 - SAIR',10,13,'$'

    MENUPESQ DB 'O QUE DESEJA EDITAR?:',10,13
             DB '1 - NOMES',10,13
             DB '2 - NOTAS',10,13
             DB '0 - RETORNAR',10,13,'$'
             
    PESQUISA DB 1 DUP(31, ?, 32 DUP(' '))
    
    FFLUSH DB 31 DUP(' ')

    ESPACO DB ' $'
    
    ERRO DB 'NAO HOUVE RESULTADOS CORRESPONDENTES.... REDIRECIONANDO AO MENU...',10,13,'$'
    
    MSGEDITNOTA DB 'QUAL NOTA DESEJA EDITAR?:',10,13
                DB '1 - P1',10,13
                DB '2 - P2',10,13
                DB '3 - P3',10,13,'$'
                
    PESQNOME DB 'Digite o nome de quem quer editar: $'
    
    NOVONOME DB 'Digite o novo nome: $'
    
    NOVANOTA DB 'Digite a nova nota: $'

    LEGENDA DB '|NOME',27 DUP (' '),'|P1','|P2','|P3', '|MF|$'

.CODE

MAIN PROC
        MOV AX, @DATA               ;INICIA O SEGMENTO DE DADOS E O SEGMENTO EXTRA
        MOV DS, AX
        MOV ES, AX

        MOV AX, 0003H               ;Necessario para poder utilizar cores no programa
        INT 10H

        XOR BX, BX                  ;ZERA BX PARA TER CERTEZA QUE FOI INICIADO COM 0
        MOV CX, 5                   ;INICIA CONTADOR EM 5, POIS RECEBERA A INFORMACAO DE 5 ESTUDANTES


    LOOPNOMES:   
        XOR SI, SI                  ;ZERA SI PARA QUE ELE VOLTE AO ELEMENTO ZERO TODA VEZ QUE PULAR UMA LINHA
        PULALINHA

        LEA DX, MSGNOME             ;IMPRIME A MENSAGEM EM 'NOME'
        PRINTSTRING                   

        LEA DX, TABELA + BX         ;APONTA PARA TABELA + BX (BX INDICA QUAL NOME IRA RECEBER(1o, 2o, 3o...))(BX INICIA C/ 0 E SERA INCREMENTADO DE 38 EM 38)
        CALL RECEBE_NOME            ;RECEBE NOME 5X
        
        PUSH BX
        LEA BX, TABELA + BX         ;BX = NUMERO DE CARACTERES DIGITADOS - 1 (NAO CONTA ENTER)
        LIMPAENTER
        POP BX
        

        PULALINHA

        PREP_NOTA3X                 ;INICIA ALGUMAS CONDIÇÕES PARA O TRECHO ABAIXO E CX = 3
                       
    RECEBENOTA:
        LEA DX, MSGNOTA             ;IMPRIME A MENSAGEM EM 'NOME'
        PRINTSTRING
        
        CALL ENTNOTAS               ;RECEBE NOTA 3X POR NOME
    LOOP RECEBENOTA
    
        POP CX                      ;CX FOI ALTERADO EM PREP_NOTA3X, PORTANTO RECUPERA-SE SEU VALOR ORIGINAL

        CALL CALCMEDIA              ;CALCULA MEDIA

        ADD BX, 38                  ;APONTA PARA A PROXIMA LINHA DA MATRIZ(PROXIMO ALUNO)
    LOOP LOOPNOMES

    RETURN:
        PULALINHA
        PULALINHA

        LEA DX, MENUPRINC           ;IMPRIME O MENU PRINCIPAL
        PRINTSTRING

        MOV AH, 01
        SELECT_MENU:

        INT 21H                                     ;OPCAO SELECINADA PELO USUARIO

        CMP AL, '0'                                 ;SE FOR 0
        JE EXIT                             ;FINALIZA O PROGRAMA

        CMP AL, '1'                                 ;SE FOR 1
        JE VIEW                             ;MOSTRA A TABELA

        CMP AL, '2'                                 ;SE FOR 2
        JE EDIT                              ;EDITA ALGUMA VARIAVEL(NOME//NOTA)

        JMP SELECT_MENU                          ;SE FOR QUALQUER OUTRA COISA ALEM DE 1,2 OU 0, PEDE INPUT NOVAMENTE
        
    EXIT:

        mov ah,4ch          ;FINALIZA O PROGRAMA
        int 21h

    VIEW:
        
        PULALINHA
        PULALINHA
        
        CALL SAITABELA      ;IMPRIME A TABELA
        JMP RETURN          ;RETORNA AO MENU APOS IMPRESSAO
        

    EDIT:

        PULALINHA

        LEA DX, MENUPESQ     ;IMPRIME O MENU DE SELECAO DE PESQUISA
        PRINTSTRING

        MOV AH, 01
        SELECT_PESQ:

        INT 21H                                     ;OPCAO SELECINADA PELO USUARIO

        CMP AL, '0'                                 ;SE FOR 0
        JE RETURN                             ;RETORNA AO MENU PRINCIPAL

        CMP AL, '1'                                 ;SE FOR 1
        JE EDITNOME                             ;EDITA UM NOME DA TABELA

        CMP AL, '2'                                 ;SE FOR 2
        JE EDITNOTA                              ;EDITA UMA NOTA DA TABELA

        JMP SELECT_PESQ                          ;SE FOR QUALQUER OUTRA COISA ALEM DE 1,2 OU 0, PEDE INPUT NOVAMENTE

    EDITNOME:
        PULALINHA
        LEA DX, PESQNOME                        ;PEDE POR UM NOME PARA CONSULTAR TABELA
        PRINTSTRING

        LEA DX, PESQUISA                        ;PEDE PELO NOME PARA SER SUBSTITUIDO
        CALL RECEBE_NOME                        ;RECEBE O NOME PARA CONSULTA

        PULALINHA
        INC DX                                  ;APONTA PARA O NUM DE CARACTERES DIGITADOS
 
        CALL PESQ_NOME
        JMP RETURN
        
    EDITNOTA:
        PULALINHA
        LEA DX, PESQNOME                        ;PEDE POR UM NOME PARA CONSULTAR TABELA
        PRINTSTRING

        LEA DX, PESQUISA                        ;PEDE PELO NOME PARA SER SUBSTITUIDO
        CALL RECEBE_NOME                        ;RECEBE O NOME PARA CONSULTA

        PULALINHA
        INC DX                                  ;APONTA PARA O NUM DE CARACTERES DIGITADOS

        CALL PESQ_NOTA                          ;RECEBE NOTA PARA SUBSTITUICAO 
        JMP RETURN

MAIN ENDP




RECEBE_NOME PROC
        ;FUNCAO PERMITE O USUARIO DIGITAR UM NOME, EDITANDO O COM BACKSPACE, SEM PROBLEMAS
        ;NAO RECEBE PARAMETROS
        ;DEVOLVE A STRING DIGITADA, COM ENTER NO FINAL E A QUANTIDADE DE CARACTERES DIGITADOS, SEM CONTAR O ENTER
        PUSH AX

        MOV AH, 0AH                 ;RECEBERA UM STRING
        INT 21H                     ;RECEBE A STRING DO USU?RIO

        POP AX

        RET
RECEBE_NOME ENDP




ENTNOTAS PROC
        ;UTILIZA BX PARA APONTAR PARA A LINHA DO RESPECTIVO ALUNO NA MATRIZ, PERMITINDO A INSERCAO DA NOTA NO LUGAR CORRETO (0, 38, ...)
        ;UTILIZA SI PARA APONTAR PARA O ELEMENTO CORRETO DAS NOTAS NA LINHA (34, 35, 36)
        ;ENTNOTAS CHAMA A FUNCAO PARA RECEBER NOTAS, ENTDEC
        ;SI EH DEVOLVIDO COM A POSICAO DO ELEMENTO 37 NA MATRIZ, PARA FACILITAR A INSERCAO DA MEDIA NESSA POSICAO.
        PUSH BX
        
        LEA BX, TABELA + BX         ;APONTA PARA A LINHA DO RESPECTIVO ALUNO
        CALL ENTDEC                 ;RECEBE DECIMAL, QUE DEVOLVE EM AL

        MOV [BX + SI], AL           ;JOGA O VALOR RECEBIDO E CONVERTIDO PARA A TABELA
        INC SI                      ;APONTA PARA O PROXIMO ELEMENTO DA TABELA

        POP BX
        RET                         ;RETOMA O CONTROLE PARA A ROTINA
ENTNOTAS ENDP




ENTDEC PROC
        ;NAO RECEBE PARAMETROS
        ;FAZ O USUARIO INSERIR UM INPUT NUMERICO, NA FORMA DE CARACTERE, DEVOLVENDO O SEU RESPECTIVO VALOR EM AX, NA FORMA DE NUMERO
        ;CONVERTE O VALOR RECEBIDO PARA NUMERO POR MEIO DE MULTIPLICACOES SUCESSIVAS POR 10
        PUSH SI
        PUSH BX
        PUSH CX

        XOR BX, BX                                  ;ZERA BX POIS ELE SERA UTILIZADO PARA A DIVIS?O NA FUNCAO
        MOV CX, 2

    RECEBEDEC:
        MOV AH, 01                                  ;COMO AH EH LIMPO LOGO A FRENTE, REDEFINO ELE AQUI.
        INT 21H                                     

        CMP AL, 13                                  ;COMPARA VALOR RECEBIDO COM CARRIAGE RETURN
        JE ENTDECFIM                                ;SE FOR, FINALIZA O INPUT

        CMP AL, '0'                                 ;SE FOR MENOR QUE '0'
        JB RECEBEDEC                                ;PEDE NOVO INPUT, POIS VALOR EH INVALIDO

        CMP AL, '9'                                 ;SE FOR MAIOR QUE '9'
        JA RECEBEDEC                                ;PEDE NOVO INPUT, POIS VALOR EH INVALIDO

    DECPARABIN:
        XOR AH, AH                                  ;LIMPO AH, PARA EVITAR QUE BX MULTIPLIQUE UM LIXO INDESEJADO

        AND AL, 0FH                                 ;TRANSFORMA NUMERO(CARACTERE) EM BINARIO
        PUSH AX                                     ;SALVA NUMERO NA PILHA

        MOV AX, 10                                  ;AX RECEBE 10 PARA FAZER A CONTA (AX=10*BX+INPUT)
        MUL BX                                      ;REALIZA AX * BX E GUARDA VALOR EM AX (AX=AX*BX), ISSO ABRE ESPACO PARA JUNTAR OS NUMEROS
        POP BX                                      ;RECUPERA VALOR DE AX NA PILHA E COLOCA-O EM BX
        ADD BX, AX                                  ;SOMA BX + AX E GUARDA EM BX (BX=BX+AX)

    LOOP RECEBEDEC                               ;RECEBE MAIS UM INPUT

        PULALINHA
    ENTDECFIM:
        MOV AX, BX                                  ;SALVA EM AX O VALOR FINAL NOVAMENTE, PARA RETORNA-LO A FUNCAO

        POP CX
        POP BX
        POP SI
        RET                                                     ;RETOMA O CONTROLE PARA A ROTINA
ENTDEC ENDP




CALCMEDIA PROC
        ;NAO DA PUSH EM CX POIS MACRO PREP_NOTA3X JA FAZ ISSO
        PREP_NOTA3X

        XOR AX, AX              ;LIMPA A ULTIMA NOTA DE AX

        PUSH BX                 ;BX SERA MUITO UTILIZADO ABAIXO, PORTANTO SALVA-SE BX
        LEA BX, TABELA + BX     ;APONTA PARA A LINHA DO RESPECTIVO ALUNO

    LOOPSOMA:
        ADD AL, [BX + SI]       ;SOMA O VALOR DAS NOTAS, SALVANDO A SOMA EM AX
        INC SI                  ;APONTA PARA A PROXIMA NOTA A SER SOMADA

    LOOP LOOPSOMA

        PUSH BX                 ;SALVA BX NOVAMENTE POIS OCORRERA A DIVISAO DA MEDIA
        XOR DX, DX              ;GARANTE QUE DX ESTA LIMPO PARA EVITAR OVERFLOW

        MOV BX, 3               ;DEFINE O VALOR DO DIVISOR
        DIV BX                  ;DIVIDE AX/3 E GUARDA EM AX O VALOR DO RESULTADO

        POP BX                  ;RECUPERA O VALOR DE BX QUE APONTA PARA A LINHA

        MOV [BX + SI], AL       ;COPIA PARA A POSICAO DA MATRIZ(BX + 37) O VALOR DA MEDIA FINAL

        POP BX                  ;RECUPERA O VALOR DE BX ORIGINAL
        POP CX                  ;RETORNA O CONTADOR AO SEU VALOR ORIGINAL
        RET
CALCMEDIA ENDP




SAITABELA PROC
        LEA BX, TABELA          ;APONTA PARA A MATRIZ CONTENDO TODOS OS DADOS
        MOV CX, 5               ;SERAO 5 LINHAS IMPRESSAS
        LEA DX, LEGENDA         ;IMPRIME |NOME     |P1|P2|P3|MF|

        PRINTSTRING
        PULALINHA

    SAILINHA:
        MOV SI, 34              ;APONTA SI NA PRIMEIRA NOTA, PARA REALIZAR A IMPRESSAO DELAS      
        MOV DX, BX              ;DEFINE DX NO OFFSET TABELA, PARA IMPRESSAO DOS NOMES
        ADD DX, 2               ;APONTA PARA O INICIO DA STRING

        LINHAVERTICAL

        PRINTSTRING              ;IMPRIME A STRING

        LINHAVERTICAL

        PUSH CX                  ;SALVA CONTADOR DE LINHA
        MOV CX, 4                ;INICIA CONTADOR DE COLUNAS(4 NOTAS)

    SAINOTA:
        
        ALTERACOR               ;SE NOTA =>5, VERDE, SE < 5, VERMELHO
        CALL SAIDEC             ;IMPRIME AS NOTAS E MEDIA

        LINHAVERTICAL

        INC SI                  ;APONTA PARA A PROXIMA NOTA DA LINHA
    LOOP SAINOTA

        POP CX                  ;RECUPERA O CONTATOR DE LINHAS
        ADD BX, 38              ;APONTA PARA ELEMENTO 0 DA LINHA DE BAIXO DA MATRIZ

        PULALINHA

    LOOP SAILINHA
        RET                     ;RETOMA O CONTROLE PARA A ROTINA
SAITABELA ENDP




SAIDEC PROC
        ;RECEBE DA MAIN O ENDERECO MATRICIAL [BX+SI] COM O CONTEUDO PARA SER IMPRESSO
        ;NAO DEVOLVE NADA PARA MAIN
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        XOR AX, AX                                  ;ZERA AX PARA RECEBER APENAS O VALOR DESEJADO EM AL
        MOV AL, [BX + SI]                           ;RECEBE VALOR A SER IMPRESSO

        CMP AL, 10                                  ;SE FOR 10 OU MAIOR, DA UM ESPACO A MAIS, PARA ALINHAR
        JAE NAO_UNICO
        ESPACA

    NAO_UNICO:
        PREPARADIV:
        XOR CX, CX                                  ;ZERA CX POIS ELE SERA USADO COMO CONTADOR
        MOV BX, 10                                  ;DEFINE BX COMO 10, JA QUE AS DIVISOES SERAO POR 10

        SEPARADEC:
        XOR DX, DX                                  ;ZERA DX, POIS DX IRA CONTER O RESTO E SE NAO FOR LIMPO A CADA DIVISAO, PODE CAUSAR OVERFLOW

        DIV BX                                      ;DIVIDE AX POR BX E GUARDA EM AX O QUOCIENTE E, EM DX, O RESTO
        PUSH DX                                     ;SALVA O VALOR DO RESTO NA PILHA, QUE SERA IMPRESSO DEPOIS
        INC CX                                      ;INCREMENTA O CONTADOR, ESSE SERA O NUMERO DE VEZES QUE A PILHA DEVERA SER ACESSADA PARA RECUPERAR OS VALORES DE DX SALVOS

        OR AX, AX                                   ;CHECA SE AX EH ZERO
        JNZ SEPARADEC                               ;SE AX != 0, CONTINUA COM AS DIVISOES

        MOV AH, 02                                  ;PREPARA PARA A IMPRESSAO DO NUMERO DECIMAL

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
            



PESQ_NOME PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI

        XOR AL, AL                              ;AL SERA CONTADOR PARA CASO NAO EXISTA O NOME NA TABELA

        MOV CX, 5                               ;5 LINHAS SERAO LIDAS   

        XOR BX, BX                              ;ZERA BX POIS ELE SERA USADO PARA APONTAR PARA AS LINHAS DA MATRIZ
    PESQNOMES:
        PUSH DX
        PUSH CX

        LEA SI, PESQUISA + 2                    ;APONTA PARA A STRING PESQUISADA
        LEA DI, TABELA + BX                     ;APONTA PARA A LINHA DA MATRIZ E VAI DESCENDO
        ADD DI, 2                               ;APONTA DI PARA O INICIO DO NOME

        PUSH BX
        MOV BX, DX                          ;PASSA DX, QUE CONTEM O ENDERECO DA LINHA+1(NUM DE CARACTERES DIGITADOS) PARA BX
        MOV CL, [BX]                        ;RECEBE O NUMERO DE CARACTERES DIGITADOS EM UM CONTADOR QUE PERCORRERA AS STRINGS
        POP BX  

        REPE CMPSB                              ;COMPARA ENQUANTO FOR IGUAL, SE ZF = 1, SAO IGUAIS
        JNZ NOT_EQUAL_NAME                      ;SE ZF = 0 SAO DIFERENTES, PORTANTO PULA A LINHA

        LEA SI, FFLUSH                      ;FFLUSH EM TABELA + 2 + BX(LIMPA O NOME DA MATRIZ, PARA SUBSTITUI-LO)
        LEA DI, TABELA + BX                 ;APONTA DI PARA A STRING
        ADD DI, 2

        PUSH BX
        MOV BX, DX                          ;PASSA DX, QUE CONTEM O ENDERECO DA LINHA+1(NUM DE CARACTERES DIGITADOS) PARA BX
        MOV CL, [BX]                        ;RECEBE O NUMERO DE CARACTERES DIGITADOS EM UM CONTADOR QUE PERCORRERA AS STRINGS
        POP BX

        REP MOVSB


        LEA DX, NOVONOME                    ;IMPRIME MENSAGEM PEDINDO NOVO NOME
        PRINTSTRING

        LEA DX, TABELA + BX
        CALL RECEBE_NOME                    ;RECEBE O NOME A SER SUBSTITUIDO

        PUSH BX
        LEA BX, TABELA + BX                 ;RETIRA O CR DO FINAL DA STRING
        LIMPAENTER
        POP BX


        JMP PESQNOMES_FIM

    NOT_EQUAL_NAME:
        INC AL                                  ;SE NAO FOREM IGUAIS, INC AL, SE AL = 5, NAO HOUVE RESULTADO CORRESPONDENTE

    PESQNOMES_FIM:
        ADD BX, 38                              ;VAI PARA A LINHA DE BAIXO
        POP CX                                  
        POP DX
    LOOP PESQNOMES

        CMP AL, 5                               ;SE AL = 5, IMPRIME ERRO
        JNE FIM
        PULALINHA

        LEA DX, ERRO                            ;IMPRIME ERRO
        PRINTSTRING
    FIM:

        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET                                          ;RETOMA O CONTROLE PARA A ROTINA
PESQ_NOME ENDP
            
            


PESQ_NOTA PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI

        XOR AL, AL                                      ;AL SERA CONTADOR PARA QUANDO NAO HA CORRESPONDENCIAS

        MOV CX, 5                                       ;5 LINHAS SERAO LIDAS

        XOR BX, BX                                      ;ZERA BX PARA APONTAR PARA O INICIO DA MATRIZ

    PESQNOTA:
        PUSH DX
        PUSH CX

        LEA SI, PESQUISA + 2                            ;APONTA PARA A STRING PESQUISADA
        LEA DI, TABELA + BX                             ;APONTA PARA A LINHA DA MATRIZ E VAI DESCENDO
        ADD DI, 2                                       ;APONTA DI PARA O INICIO DO NOME

        PUSH BX
        MOV BX, DX                                  ;PASSA DX, QUE CONTEM O ENDERECO DA LINHA+1(NUM DE CARACTERES DIGITADOS) PARA BX
        MOV CL, [BX]                                ;RECEBE O NUMERO DE CARACTERES DIGITADOS EM UM CONTADOR QUE PERCORRERA AS STRINGS
        POP BX

        REPE CMPSB                                      ;COMPARA ENQUANTO FOR IGUAL, SE ZF = 1, SAO IGUAIS
        JNZ NOT_EQUAL_NOME1                             

        PUSH BX
        LEA BX, TABELA + BX                          ;APONTA PARA A LINHA ONDE;APONTA BX PARA O INICIO DA LINHA DA MATRIZ
        lEA DX, MSGEDITNOTA                             ;IMPRIME MENU PARA ESCOLHER QUIAL PROVA ALTERAR
        PRINTSTRING

        MOV AH, 01
        XOR SI, SI                                  ;ZERA SI PARA EVITAR LIXO
    SELECT_PROVA:

        INT 21H                                     ;RECEBE OPCAO SELECINADA PELO USU?RIO

        CMP AL, '1'                                 ;SE FOR 1
        JE P1                             ;EDITA P1

        CMP AL, '2'                                 ;SE FOR 2
        JE P2                             ;EDITA P2

        CMP AL, '3'                                 ;SE FOR 3
        JE P3                              ;EDITA P3

        JMP SELECT_PROVA                          ;SE FOR QUALQUER OUTRA COISA ALEM DE 1,2 OU 3, PEDE INPUT NOVAMENTE

            PESQNOTA1:
            JMP PESQNOTA                ;SALTOS ESTAVAM MUITO DISTANTES, POR ISSO INSERI DOIS INTERMEDIARIOS
            
            NOT_EQUAL_NOME1:            
            JMP NOT_EQUAL_NOME

    P1:
        PULALINHA
        LEA DX, NOVANOTA            ;MENSAGEM PARA RECEBER NOVA NOTA
        PRINTSTRING

        ADD SI, 34              ;APONTA PARA P1
        JMP RECEBEPROVA

    P2:
        PULALINHA
        LEA DX, NOVANOTA            ;MENSAGEM PARA RECEBER NOVA NOTA
        PRINTSTRING

        ADD SI, 35              ;APONTA PARA P2
        JMP RECEBEPROVA

    P3:
        PULALINHA
        LEA DX, NOVANOTA            ;MENSAGEM PARA RECEBER NOVA NOTA
        PRINTSTRING

        ADD SI, 36              ;APONTA PARA P3

    RECEBEPROVA:
        CALL ENTDEC             ;RECEBE NOVA NOTA
        MOV [BX+SI], AL         ;GUARDA O VALOR NA POSIÇÃO CORRETA DA TABELA
        POP BX

        CALL CALCMEDIA          ;ATUALIZA A MEDIA

        JMP PESQNOTA_FIN

    NOT_EQUAL_NOME:
        INC AL                       ;SE AL = 5, ERRO SERA IMPRESSO

    PESQNOTA_FIN:
        ADD BX, 38                    ;PULA LINHA DA MATRIZ
        POP CX
        POP DX
    LOOP PESQNOTA1

        CMP AL, 5                       ;SE AL = 5, NAO EXISTE O NOME PESQUISADO
        JNE FIMNOTA
        PULALINHA

        LEA DX, ERRO                          ;IMPRIME ERRO
        PRINTSTRING

    FIMNOTA:

        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
PESQ_NOTA ENDP
                  
END MAIN