all:
	flex -l Cine-lex.l;
	bison -vd CineScripty.y;
	gcc calc-ambiguo.tab.c -ll -o lab2