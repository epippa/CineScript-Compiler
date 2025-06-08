all:
	flex Cine-lex.l
	bison -d CineScripty.y
	gcc lex.yy.c CineScripty.tab.c -o cinescript -lm


