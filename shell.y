	
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
#define TAM_MAXIMO 128

extern int yylex();
extern int yyparse();
extern FILE* yyin;


void yyerror(const char* s);
void imprimir_logo(FILE *fptr); //imprime logo do shell
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


%type<integer> calculo_int //calcula operacoes que retornam int
%type<pfloat> calculo_float //calcula operacoes que retornam float
%type<string> comando

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


//Correçao para precedencia das operacoes
%left 
OP_SOMA 
OP_SUB 


//Correcao para precedencia das operacoes
%left
OP_MULT 
OP_DIV



%start inicio

%%

//definicao dos tokens

//impressao da linha no começo, antes dos comandos
inicio: { imprimeLinha(); }
	   | inicio line {imprimeLinha();}
;

//C_NOVALINHA pula a linha (\n), comando executa os comandos(LS,PS...), calculo_int recebe os valores e realiza operacoes com numeros inteiros, calculo_float realiza operacoes com numeros c casas decimais  
line: C_NOVALINHA 
    | comando C_NOVALINHA  
    | calculo_int C_NOVALINHA {printf("%i\n", $1);}
    | calculo_float C_NOVALINHA {printf("%f\n", $1);}
    | C_QUIT C_NOVALINHA { printf("ShellBS finalizado.\n"); exit(0); }
;

/*********************************CALCULADORA***********************************/
calculo_float: N_NUMFLOAT { $$ = $1; } //retorna o primeiro valor
	  | calculo_int OP_DIV calculo_int	   { $$ = $1 / (float)$3; } //retorna a divisao entre dois inteiros. o retorno pode ser em float, dados os valores
	  | calculo_float OP_DIV calculo_float  { $$ = $1 / $3; } //retorna a divisao entre o primeiro e o segundo valor(floats)
	  | calculo_int OP_SOMA calculo_float   { $$ = $1 + $3; } //retorna a soma entre um inteiro e um float
	  | calculo_int OP_SUB calculo_float   { $$ = $1 - $3; } //retorna a subtracao entre um inteiro e um float
	  | calculo_int OP_MULT calculo_float   { $$ = $1 * $3; } //retorna a multiplicacao entre um inteiro e um float
	  | calculo_int OP_DIV calculo_float	   { $$ = $1 / $3; } //retorna a divisao de um inteiro e um float
	  | calculo_float OP_SOMA calculo_float { $$ = $1 + $3; } //retorna a soma de floats
	  | calculo_float OP_SUB calculo_float { $$ = $1 - $3; } //retorna a subtraçao entre floats
	  | calculo_float OP_MULT calculo_float { $$ = $1 * $3; } //retorna a multiplicacao entre o primeiro e o segundo valor
	  | calculo_float OP_SOMA calculo_int   { $$ = $1 + $3; } //retorna a soma entre um float e um inteiro
	  | calculo_float OP_SUB calculo_int   { $$ = $1 - $3; } //retorna a subtracao entre um float e um inteiro
	  | calculo_float OP_MULT calculo_int   { $$ = $1 * $3; } //retorna a multiplicacao entre um float e um int
	  | calculo_float OP_DIV calculo_int	   { $$ = $1 / $3;}//retorna a divisao entre um float e um inteiro 
	  ;

calculo_int: N_NUMINT { $$ = $1; } //retorna o inteiro
	  | calculo_int OP_SOMA calculo_int	{ $$ = $1 + $3; } //retorna a soma de dois inteiros
	  | calculo_int OP_SUB calculo_int	{ $$ = $1 - $3; } //retorna a subtracao de dois inteiros
	  | calculo_int OP_MULT calculo_int	{ $$ = $1 * $3; } //retorna a multiplicacao de dois inteiros
;
/*****************************************FIM CALC***********************************/

//comando pode executar um dos comandos por vez especificados abaixo
comando: C_LS { 
			system("/bin/ls"); //system realiza a chamada de sistema para o ls do linux
}

	   | C_PS { system("/bin/ps"); } //system realiza a chamada de sistema para o ps do linux
	   | C_KILL N_NUMINT {  
	   					 //nao consegui converter int para string usando sprintf
					     /*char stringFim[] = "/bin/kill ";
					     char buffer[FILENAME_MAX];
					     int num = $2;
					    	
					     sprintf(buffer, "%s%d", stringFim, num); //corrigir
					   
						 system(stringFim);*/ 

					     
	   				 }		 
	   | C_MKDIR N_ARGM {
	   					 char stringFim[1000] = "/bin/mkdir ";
	   					 strcat(stringFim, $2);//concatena a instruçao para a chamada de sistema com o argumentotus
	   					 system(stringFim); //realiza a chamada de sistema
	   				   }
	   | C_RMDIR N_ARGM {
	   					 char stringFim[1000] = "/bin/rmdir ";
	   					 strcat(stringFim, $2);//concatena a instruçao para a chamada de sistema com o argumento
	   					 system(stringFim);//realiza a chamada de sistema
	   				   }
	  
	   /*******CD pode conter a sintaxe de N_PASTANAME ou N_ARG ************/				   
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
						ret = chdir(caminho);
						if(ret != 0){
							printf("Erro: diretorio nao encontrado! Verifique o caminho e tente novamente. \n");
						}
					}
		| C_TOUCH N_ARGM {
						  char stringFim[1000] = "/bin/touch ";
						  strcat(stringFim, $2);//concatena a instruçao para a chamada de sistema com o argumento
						  system(stringFim);//realiza a chamada de sistema
						}
		| C_IFCONFIG {system("ifconfig");} //realiza a chamada de sistema
		| C_START N_ARGM { 
							if(fork() == 0){
								system($2);
								exit(0);
							} 
						}
		| N_ARGM { yyerror("Argumento encontrado sem comando associado"); }
		| N_PASTANAME { yyerror("Argumento invalido"); }
;



%%

int main() {
    
    char *filename = "image.txt";
    FILE *fptr = NULL;
 
    if((fptr = fopen(filename,"r")) == NULL)
    {
        fprintf(stderr,"error opening %s\n",filename);
        return 1;
    }
 
    imprimir_logo(fptr);
 
    fclose(fptr);
	yyin = stdin;
	
	do { 
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) { //funcao que retorna mensagem de erro caso algo alguma entrada seja invalida
	fprintf(stderr, "Argumento ou comando invalido. Msg Erro: %s\n", s);
}


void imprimeLinha(){

	//Nome do Shell
	char nomeShell[4096] = "ShellBS:";

	//Caminho da pasta
	char caminho[2048];

	getcwd(caminho, sizeof(caminho));
	
	//concatena nome do shell+caminho
	strcat(nomeShell,caminho);

	//concatena o nome do shell com o "">>'', seguindo as especificacoes do projeto
	strcat(nomeShell,">> ");

	printf("%s",nomeShell); 
}


	void imprimir_logo(FILE *fptr)
{
    char read_string[TAM_MAXIMO];
 
    while(fgets(read_string,sizeof(read_string),fptr) != NULL)
        printf("%s",read_string);
}
