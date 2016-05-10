
 /********************************************************************
 * Programa: bs_shell.lex	
 * 
 * Descriçao: tokens que serao utilizados pelo bison
 *
 * Autor:  Bruno Sastre
 *
 *********************************************************************/

%{
#include <stdio.h> //cabecalho biblioteca padrao do C

#define YY_DECL int yylex() //yylex() eh o analisador lexico gerado pelo arquivo de definicao

#include "shell.tab.h"

%}

 /***********Comandos a serem implementados************/

%% 

\n		{return C_NOVALINHA;} //pula a linha
"ls"		{return C_LS;} //lista o conteudo do diretorio atual
"ps"		{return C_PS;} //lista todos os processos do usuario
"kill"		{return C_KILL;} //elimina o processo com determinado numero id
"mkdir"		{return C_MKDIR;} //cria um diretorio com o nome informado
"rmdir"		{return C_RMDIR;} //remove o diretorio
"cd"		{return C_CD;} //torna o diretorio como atual 
"touch"		{return C_TOUCH;} //cria um arquivo com um nome
"ifconfig"	{return C_IFCONFIG;} //exibe as infos de todas as interfaces de rede do sistema
"start"		{return C_START;} //invoca a execucao do programa
"quit"		{return C_QUIT;} //encerra o shell
"+"			{return OP_SOMA;} //operador de soma
"-"			{return OP_SUB;} //operador de subtracao
"*"			{return OP_MULT;} //operador de multiplicacao
"/"			{return OP_DIV;} //operador de divisao
[ \t]	; //ignora espaços em branco

[0-9]+		{yylval.integer = atoi(yytext); return N_NUMINT;} //identifica as cadeias com numeros inteiros
[0-9]+\.[0-9]+ 	{yylval.pfloat = atof(yytext); return N_NUMFLOAT;} //identificar cadeias c numeros c casas decimais

[a-zA-Z0-9./\()_-]+[.]?[a-zA-Z0-9]* {yylval.stringp = yytext; return N_ARGM; }///identificar cadeias com alfanumericos

[0-9a-zA-Z0-9/.~]+ 	{yylval.stringp = yytext; return N_PASTANAME; }//cadeias aceitas para nomes de pasta.


%%