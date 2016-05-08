all: shell

shell.tab.c shell.tab.h: shell.y
	bison -d shell.y

lex.yy.c: shell.lex shell.tab.h
	flex shell.lex

shell: lex.yy.c shell.tab.c shell.tab.h
	gcc -o shell shell.tab.c lex.yy.c -lfl

clean:
	rm shell shell.tab.c lex.yy.c shell.tab.h
