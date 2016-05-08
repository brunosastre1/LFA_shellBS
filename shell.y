	
 /********************************************************************
 * Programa: bs_shell.y	
 * 
 * Descriçao: calculadora e comandos especificados no projeto
 *
 * Autor:  Bruno Sastre
 *
 *********************************************************************/

%{

#include <stdio.h> //cabecalho biblioteca padrao do C
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void yyerror(const char* s);

void imprimeLinha(); //funcao que imprime a linha com nome do shell, assim como o caminho das pastas etc
%}

%union {

//tipos que serao utilizados para "tipar" os tokens criados no lex
	int integer; 
	float pfloat;
	char string;
	char * stringp;
}

//Atribuiçao dos tipos aos tokens

%token <integer> N_NUMINT
%token <pfloat> N_NUMFLOAT
%token <stringp> N_ARGM
%token <stringp> N_PASTANAME

//tokens dos comandos
%token C_LS
C_PS 
C_KILL 
C_MKDIR 
C_RMDIR 
C_CD 
C_TOUCH 
C_IFCONFIG 
C_START 
C_QUIT 
C_NOVALINHA 
C_INVALIDO

//tokens da calculadora
%token 
OP_SOMA 
OP_SUB 
OP_MULT 
OP_DIV

%left 
OP_SOMA 
OP_SUB 
OP_MULT 
OP_DIV

%type<string> comando
%type<integer> calculo_int
%type<pfloat> calculo_float

%start inicio

%%
inicio: { imprimeLinha(); }
	   | inicio line { imprimeLinha(); }
;

%%

int main() {
	yyin = stdin;

	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Comando/Argumento nao valido. Erro: %s\n", s);
}

void imprimeLinha(){

	//Nome do Shell
	char nomeShell[4096] = "ShellBS:";

	//Caminho da pasta
	char caminho[2048];

	getcwd(caminho, sizeof(caminho));
	strcat(nomeShell,caminho);
	strcat(nomeShell,">> ");
	printf("%s",nomeShell); 
}
