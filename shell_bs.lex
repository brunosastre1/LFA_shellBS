	
 /********************************************************************
 * Programa: bs_shell.lex	
 * 
 * Descriçao: comandos que serao utilizados pelo shell
 *
 * Autor:  Bruno Sastre
 *
 *********************************************************************/

%{
	
#include <stdio.h>
#define YY_DECL int yylex()
#include "shell.tab.h"

%}


 /***********Comandos a serem implementados************/

 %% 

"ls"		{return C_LS;}
"ps"		{return C_PS;}
"kill"		{return C_KILL;}
"mkdir"		{return C_MKDIR;}
"rmdir"		{return C_RMDIR;}
"cd"		{return C_CD;}
"touch"		{return C_TOUCH;}
"ifconfig"	{return C_IFCONFIG;}
"start"		{return C_START;}
"quit"		{return C_QUIT;}
"+"			{return OP_SOMA;}
"-"			{return OP_SUB;}
"*"			{return OP_MULT;}
"/"			{return OP_DIV;}
[ \t]	; //comando q ignora espaços em branco
\n		{return C_NOVALINHA;} //pula a linha

 /**************Expressoes******************/
[0-9]+		{yylval.integer = atoi(yytext); return N_NUMINT;}
[0-9]+\.[0-9]+ 	{yylval.pfloat = atof(yytext); return N_NUMFLOAT;}

[a-zA-Z0-9./\()_-]+[.]?[a-zA-Z0-9]* {yylval.stringp = yytext; return N_ARGM; }
[a-zA-Z0-9/.~]+ 	{yylval.stringp = yytext; return N_PASTANAME; }

 %%