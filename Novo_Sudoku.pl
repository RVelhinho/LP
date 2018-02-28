/*==========================================================================================*/
/*==============================Ricardo Caetano Velhinho====================================*/
/*======================================86505===============================================*/
/*==========================================================================================*/

:-include('SUDOKU').


/*==========================================================================================*/
/*===================================PROJETO================================================*/
/*===================================3.1.1==================================================*/


tira_num_aux(Num,Puz,Pos,N_Puz):-
puzzle_ref(Puz,Pos,Cont),                                      /* Vai buscar o conteudo da posicao Pos */
member(Num,Cont),                                              /* Verifica se Num pertence ao conteudo */
subtract(Cont,[Num],Novo_Cont),                                /* Caso seja vai subtrair dessa lista e criar uma nova sem o Num */
puzzle_muda_propaga(Puz,Pos,Novo_Cont,N_Puz),!.                /* Vai chamar o predicado puzzle_muda_propaga de forma a propagar esta alteracao e o corte faz com que nao
                                                                va chamar o predicado seguinte do tira_num_aux */

tira_num_aux(_,Puz,_,N_Puz):-
N_Puz=Puz,!.                                                     /* Caso Num nao seja membro do conteudo de Pos nao vai haver alteracao */

/*===================================3.1.1==================================================*/

tira_num(Num,Puz,Posicoes,N_Puz):-
percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).       /* Vai realizar o predicado tira_num_aux para todas as posicoes dadas */

/*===================================3.1.2==================================================*/

puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-
length(Cont,X),X=\=1,                                          /* Vai verificar se o comprimento de Cont e diferente de 1 */
puzzle_muda(Puz,Pos,Cont,N_Puz),!.                               /* Caso seja vai substituir o conteudo de Pos */

puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-
length(Cont,1),                                                /* Vai verificar se o comprimento de Cont e igual a 1 */
puzzle_muda(Puz,Pos,Cont,Novo_Puz),                            /* Caso seja vai substituir o conteudo de Pos */
Cont=[Elemento|_],                                             /* Separa Cont do primeiro elemento de forma a nao ficar em forma de lista */
posicoes_relacionadas(Pos,Posicoes),                           /* Verifica as posicoes da mesma linha coluna e bloco de Pos */
tira_num(Elemento,Novo_Puz,Posicoes,N_Puz),!.                    /* Vai propagar a mudanca ou seja tirar o numero em Cont de todas as posicoes relacionadas */

/*===================================3.2.1==================================================*/

possibilidades(Pos,Puz,Poss):-
puzzle_ref(Puz,Pos,Cont),                                      /* Verifica o conteudo de Pos */
length(Cont,X),X=\=1,                                          /* Caso o conteudo seja diferente de 1 */
numeros(Lst),                                                  /* Vai se obter uma lista com todos os numeros possiveis */
posicoes_relacionadas(Pos,Posicoes),
conteudos_posicoes(Puz,Posicoes,Conteudos),
avalia_unitario(Conteudos,Conteudos1),                         /* Percorre a lista dos Conteudos das posicoes relacionadas e separa para uma nova lista Conteudos1
                                                               apenas as listas unitarias */
subtract(Lst,Conteudos1,Novo_Cont),                            /* Subtrai se da lista contendo todos os numeros possiveis os numeros contidos em Conteudos1
                                                               de forma a se livrar de todos os numeros das posicoes relacionadas */
append(Novo_Cont,Cont,Poss),!.                                   /* O append vai juntar o que ja se tem ao Conteudo da Pos inicial */

possibilidades(Pos,Puz,Poss):-
puzzle_ref(Puz,Pos,Cont),
length(Cont,1),                                               /* Caso o conteudo seja igual a 1 */
append(Cont,[],Poss),!.                                         /* Nao se faz nada e Poss fica igual ao conteudo de Pos */

avalia_unitario([P|Resto],Lista1):- avalia_unitario([P|Resto],Lista1,[]).     /* Este processo vai ser feito atraves da recursao iterativa */

avalia_unitario([],Aux,Aux):-!.                                                  /* Caso final */
avalia_unitario([P|Resto],Lista1,Aux):-
length(P,X),X=:=1,                                                            /* Caso o primeiro elemento seja uma lista unitaria */
append(P,Aux,Aux_Novo),                                                       /* Vai juntar a lista acumulativa */
avalia_unitario(Resto,Lista1,Aux_Novo),!.

avalia_unitario([_|Resto],Lista1,Aux):-                                       /* Caso contrario nao faz nada e percorre o resto da lista */
avalia_unitario(Resto,Lista1,Aux).

/*===================================3.2.2==================================================*/

inicializa_aux(Puz,Pos,N_Puz):-
puzzle_ref(Puz,Pos,Cont),
length(Cont,1),                                                /* Caso o comprimento do conteudo de Pos seja 1 */
puzzle_muda_propaga(Puz,Pos,Cont,N_Puz).                       /* Substitui se e propagase a mudanca */

inicializa_aux(Puz,Pos,N_Puz):-
puzzle_ref(Puz,Pos,Cont),
length(Cont,X),X=\=1,
possibilidades(Pos,Puz,Poss),                                  /* Caso contrario verificase primeiro as possibilidades primeiro */
puzzle_muda_propaga(Puz,Pos,Poss,N_Puz).                       /* E depois substituise o conteudo pelas possibilidades e proapgase a mundanca */

/*===================================3.2.2==================================================*/

inicializa(Puz,N_Puz):-
todas_posicoes(Posicoes),
percorre_muda_Puz(Puz,inicializa_aux,Posicoes,N_Puz),!.         /* Vai realizar o predicado anterior para todas as posicoes possiveis do puzzle */

/*===================================3.3.1==================================================*/

so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num):-conteudos_posicoes(Puz,Posicoes,Conteudos),          /* Vai primeiro buscar os conteudos em Posicoes */
                                             append(Conteudos,Conteudos1),                         /* Vai transformar a lista de listas em apenas uma lista */
                                             aparece_uma_vez(Num,Conteudos1),                      /* Vai utilizar o predicado auxiliar que foi usado
                                                                                                   mais a frente para verificar se um numero aparece
                                                                                                   apenas uma vez numa lista */
                                             puzzle_ref(Puz,Pos_Num,Cont),                         /* Caso apareca, Vai buscar o conteudo do Pos_Num que se quer */
                                             member(Num,Cont),member(Pos_Num,Posicoes),!.          /* E vai reduzir a procura da Pos_Num dando todas as
                                                                                                   informacoes necessarias para obter a esta Pos_Num */

/*===================================3.3.2==================================================*/

inspecciona_num(Posicoes,Puz,Num,N_Puz):-
so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num),                 /* Verifica primeiro se o Num aparece apenas uma vez */
puzzle_ref(Puz,Pos_Num,Cont),
length(Cont,X),X=\=1,                                         /* Caso o Conteudo de Pos_Num seja diferente de 1 */
puzzle_muda_propaga(Puz,Pos_Num,[Num],N_Puz),!.               /* Substitui pelo Num em forma de lista e propaga a mudanca */

inspecciona_num(_,Puz,_,N_Puz):-                              /* Caso contrario nao faz alteracao nenhuma */
N_Puz=Puz,!.

/*===================================3.3.2==================================================*/

inspecciona_grupo(Puz,Gr,N_Puz):-
numeros(L),
percorre_muda_Puz(Puz,inspecciona_num(Gr),L,N_Puz),!.           /* Vai realizar o predicado anterior para todos os numeros possiveis */

/*===================================3.3.2==================================================*/

inspecciona(Puz,N_Puz):-
grupos(Gr),
inspecciona_cada_grupo(Puz,Gr,N_Puz),!.                         /* Predicado auxiliar que permite verificar todas as linhas seguido de todas as colunas seguido de
                                                              todas os blocos relativamente ao preciado anterior */

inspecciona_cada_grupo(Puz,[],Puz):-!.                           /* Este predicado vai percorrer todos os grupos e inspeccionando cada um deles */
inspecciona_cada_grupo(Puz,[P|Resto],N_Puz):-
inspecciona_grupo(Puz,P,Puz1),
inspecciona_cada_grupo(Puz1,Resto,N_Puz),!.

/*===================================3.4==================================================*/

grupo_correcto(Puz,Nums,Gr):-conteudos_posicoes(Puz,Gr,Conteudos),              /* Verifica os conteudos das posicoes */
                             append(Conteudos,Cont),                            /* Torna a lista de listas em apenas uma lista compacta */
                             grupo_aux(Puz,Nums,Cont),!.                        /* Realiza o predicado auxiliar para verificar se cada um dos
                                                                                numeros aparece apenas uma vez em Cont */

grupo_aux(_,[],_):-!.
grupo_aux(Puz,[P|Resto],Lista):-
aparece_uma_vez(P,Lista),
grupo_aux(Puz,Resto,Lista).

aparece_uma_vez(P,Lista):-aparece_uma_vez(P,Lista,0,Contador_auxiliar),         /* Predicado que se aproveita da recursao iterativa para verificar se um numero
                                                                                aparece apenas uma vez */
                          Contador_auxiliar=:=1.

aparece_uma_vez(_,[],Contador_auxiliar,Contador_auxiliar):-!.
aparece_uma_vez(P,[P|Lista],Contador1,Contador2):-
Contador_Novo is Contador1 + 1,                                                 /* Caso o numero pertenca a cabeca da lista vai incrementar um valor no acumulador */
aparece_uma_vez(P,Lista,Contador_Novo,Contador2),!.

aparece_uma_vez(P,[_|Lista],Contador1,Contador2):-                              /* Caso contrario continua a percorrer a lista */
aparece_uma_vez(P,Lista,Contador1,Contador2).

/*===================================3.4==================================================*/

solucao(Puz):-
numeros(L),                                                   /* Vai buscar uma lista com todos os numeros possiveis */
grupos(Gr),                                                   /* Vai buscar a lista de listas com todos os grupos possiveis */
verifica_cada_grupo(Puz,L,Gr),!.                                /* Para cada grupo verifica se este e correto atraves de um predicado auxiliar */

verifica_cada_grupo(_,_,[]):-!.                                /* Caso final */
verifica_cada_grupo(Puz,L,[P|Resto]):-                        /* Predicado que percorre todos os grupos realizado o predicado grupo_correto */
grupo_correcto(Puz,L,P),
verifica_cada_grupo(Puz,L,Resto),!.                           /* Realiza a recursao */


/*===================================3.5==================================================*/

resolve(Puz,Sol):-                                            /* Caso em que apenas se precisa inspeccionar e nao inicializar o Puzzle
                                                              para o resolver */
inspecciona(Puz,Puz2),
procura_solucao(Puz2,Sol),!.

resolve(Puz,Sol):-
inicializa(Puz,Puz1),                                         /* Primeiro vai inicializar o Puzzle */
inspecciona(Puz1,Puz2),                                       /* Depois vai inspeccionar o Puzzle */
procura_solucao(Puz2,Sol),!.

procura_solucao(Puz,Sol):-                                        /* Predicado auxiliar recursivo que verifica
                                                              se existe solucao */
Sol=Puz,
solucao(Sol),!.

procura_solucao(Puz,Sol):-                                        /* Predicado auxiliar recursivo que caso nao encontre a solucao */
procura_sequencia_nao_unitaria(Puz,Pos_Num),                  /* Procura uma sequencia nao unitaria */
puzzle_ref(Puz,Pos_Num,Cont),                                 /* Verifica o conteudo dessa posicao */
escolhe_num(Cont,Num),                                        /* Escolhe um numero desse conteudo */
puzzle_muda_propaga(Puz,Pos_Num,[Num],Puz2),                  /* E vai substituir essa posicao nesse Puzzle
                                                              e propagar a mudanca */
procura_solucao(Puz2,Sol).                                        /* Vai repetir o predicado ate encontrar a solucao */

procura_sequencia_nao_unitaria(Puz,Pos_Num):-                /* Predicado auxiliar que procura uma sequencia nao unitaria */
puzzle_ref(Puz,Pos_Num,Cont),
length(Cont,X),X=\=1,!.

escolhe_num(Poss,Num):-                                    /* Predicado auxiliar que retira um numero de uma lista de numeros */
member(Num,Poss).

/*=============================================================================================*/

