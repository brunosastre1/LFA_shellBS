	
 /********************************************************************
 * Programa: 	
 * 
 * Descriçao:
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
"quit"		{return C_QUIT;}
"mkdir"		{return C_MKDIR;}
"rmdir"		{return C_RMDIR;}
"cd"		{return C_CD;}
"touch"		{return C_TOUCH;}
"ifconfig"	{return C_IFCONFIG;}
"start"		{return C_START;}

 %%