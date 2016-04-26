all: shell

shell.tab.c shell.tab.h:	bs_shell.y
	bison -d bs_shell.y

lex.yy.c: shell_bs.lex shell.tab.h
	flex shell_bs.lex

shell: lex.yy.c shell.tab.c shell.tab.h
	gcc -o shell shell.tab.c lex.yy.c -lfl

clean:
	rm shell shell.tab.c lex.yy.c shell.tab.h
