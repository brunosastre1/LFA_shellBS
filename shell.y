	
 /********************************************************************
 * Programa: bs_shell.y	
 * 
 * Descriçao: calculadora e comandos especificados no projeto
 *
 * Autor:  Bruno Sastre
 *
 *********************************************************************/


%{

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void yyerror(const char* s);

void printLinha(){

	//Nome do Shell
	char nomeShell[4096] = "ShellBS:";

	//Caminho
	char caminho[2048];

	getcwd(caminho, sizeof(caminho));
	strcat(nomeShell,caminho);
	strcat(nomeShell,">> ");
	printf("%s",nomeShell); 
}

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
%token C_LS C_PS C_KILL C_MKDIR C_RMDIR C_CD C_TOUCH C_IFCONFIG C_START C_QUIT C_NOVALINHA C_INVALIDO

%token OP_SOMA OP_SUB OP_MULT OP_DIV
%left OP_SOMA OP_SUB OP_MULT OP_DIV

%type<string> comando
%type<integer> calcint
%type<pfloat> calcfloat

%start inicio

%%

inicio: { printLinha(); }
	   | inicio line { printLinha(); }
;

line: C_NOVALINHA 
    | comando C_NOVALINHA  
    | calcint C_NOVALINHA { 	
    						printf("Resultado: %i\n", $1);
    					}
    | calcfloat C_NOVALINHA { 
    						printf("Resultado: %f\n", $1);
						  }
    | C_QUIT C_NOVALINHA { printf("Fim!\n"); exit(0); }
;

comando: C_LS { system("/bin/ls"); }
	   | C_PS { system("/bin/ps"); }
	   | C_KILL N_NUMINT {  
	   					 char string[100], stringfinal[1000] = "/bin/kill ";
 	   					 int i, rem, len = 0, n;
					     n = $2;
					     while (n != 0)
					     {
					         len++;
					         n /= 10;
					     }
					     for (i = 0; i < len; i++)
					     {
					         rem = $2 % 10;
					         $2 = $2 / 10;
					         string[len - (i + 1)] = rem + '0';
					     }
					     string[len] = '\0';
					     strcat(stringfinal, string);
					     system(stringfinal); 
	   				 }
	   | C_MKDIR N_ARGM {
	   					 char stringfinal[1000] = "/bin/mkdir ";
	   					 strcat(stringfinal, $2);
	   					 system(stringfinal);
	   				   }
	   | C_RMDIR N_ARGM {
	   					 char stringfinal[1000] = "/bin/rmdir ";
	   					 strcat(stringfinal, $2);
	   					 system(stringfinal);
	   				   }
	   | C_CD N_PASTANAME {
						   	int ret = chdir($2);
						   	if(ret != 0){
						   		printf("Erro! Diretorio nao encontrado!\n");
						   	}
						  }
	   | C_CD N_ARGM {		
	   					int ret;
	   					char caminho[2048];
	   					getcwd(caminho, sizeof(caminho));
	   					strcat(caminho, "/");
	   					strcat(caminho, $2);
	   					printf("CD do arg");
						ret = chdir(caminho);
						if(ret != 0){
							printf("Erro! Diretorio nao encontrado!\n");
						}
					}
		| C_TOUCH N_ARGM {
						  char stringfinal[1000] = "/bin/touch ";
						  strcat(stringfinal, $2);
						  system(stringfinal);
						}
		| C_IFCONFIG { system("ifconfig"); }
		| C_START N_ARGM { 
							if(fork() == 0){
								system($2);
								exit(0);
							} 
						}
		| N_ARGM { yyerror("Arg found"); }
		| N_PASTANAME { yyerror("Arg found"); }
;

calcfloat: N_NUMFLOAT                  { $$ = $1; }
	  | calcfloat OP_SOMA calcfloat { $$ = $1 + $3; }
	  | calcfloat OP_SUB calcfloat { $$ = $1 - $3; }
	  | calcfloat OP_MULT calcfloat { $$ = $1 * $3; }
	  | calcfloat OP_DIV calcfloat  { $$ = $1 / $3; }
	  | calcint OP_SOMA calcfloat   { $$ = $1 + $3; }
	  | calcint OP_SUB calcfloat   { $$ = $1 - $3; }
	  | calcint OP_MULT calcfloat   { $$ = $1 * $3; }
	  | calcint OP_DIV calcfloat	   { $$ = $1 / $3; }
	  | calcfloat OP_SOMA calcint   { $$ = $1 + $3; }
	  | calcfloat OP_SUB calcint   { $$ = $1 - $3; }
	  | calcfloat OP_MULT calcint   { $$ = $1 * $3; }
	  | calcfloat OP_DIV calcint	   { $$ = $1 / $3; }
	  | calcint OP_DIV calcint	   { $$ = $1 / (float)$3; }
;

calcint: N_NUMINT				    { $$ = $1; }
	  | calcint OP_SOMA calcint	{ $$ = $1 + $3; }
	  | calcint OP_SUB calcint	{ $$ = $1 - $3; }
	  | calcint OP_MULT calcint	{ $$ = $1 * $3; }
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


