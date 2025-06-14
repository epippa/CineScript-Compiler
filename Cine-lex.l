/* ============================================== */
/* CineScript - Copyright © 2025 Emanuele Pippa   */
/* Licenza: CC BY-NC 4.0                          */
/* ============================================== */

%option noyywrap	/* disabilitare la funzione yywrap() per far terminare automaticamente all'EOF senza cercare altri input. */
%option case-insensitive

%{
#include "CineScripty.tab.h"
#include <stdlib.h>
#include <string.h>
%}

letter  [a-zA-Z]
digit   [0-9]
id      {letter}({letter}|{digit})*
num     {digit}+(\.{digit}+)?

%%

[ \t\r]+   { /* ignora spazi bianchi */ }
\n         {/* ignora nuove linee */}
"@"[^\n]*  { /* commento */ }

"=="    {return EQUAL;}
"<"     {return LESS;}
">"     {return GREAT;}
"<="    {return LESSQ;}
">="    {return GREATQ;}
"!="    {return NOTEQ;}
"%"     {return MOD;}
"="     {return '=';}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
"("     {return '(';}
")"     {return ')';}
"{"     {return '{';}
"}"     {return '}';}
","     {return ',';}   /*sennò non mi va somma(a,b) */

"piGreco"  {return PI;}
"radiceQ"  {return RADICEQ;}  /*radice quadrata*/
"abs"      {return ABS;}      /* per i numeri assoluti */
"potenza"  {return POW;}      /* potenza */

"if"    {return IF;}         /* senza ELSE perchè non ho usato i Jump */
"se"    {return IF;}
"while"    {return WHILE;}   /* Salti condizionali NON implementati, quindi x ora funziona come un if */
"mentre"   {return WHILE;}

"azione"    {return AZIONE;}    /* dramma */
"dramma"    {return DRAMMA;}    /* string */
"scena"     {return SCENA;}     /* per stampare (come dire "mostrare") */
"riprendi"  {return RIPRENDI;}  /* riassegna */
"finale"    {return FINALE;}    /* output */
"cast"      {return CAST;}      /* print Symbol Table */
"zoom"      {return ZOOM;}      /* stampa float per intero */

"help"      {return HELP;}      /* per sapere i comandi possibili */
"sceneggiatura" {return HELP;}  /* per sapere i comandi possibili */

\"[^"]*\" {yylval.lexeme = strdup(yytext + 1);	  	    /* Copia tutto il contenuto tra virgolette, escludendo la prima virgoletta (salta il primo carattere) */
           yylval.lexeme[strlen(yylval.lexeme) - 1] = '\0'; /* Rimuove l'ultima virgoletta sostituendola con terminatore di stringa */
           return STRING;}				    /* Ritorna il token STRING al parser */
{id}        {yylval.lexeme = strdup(yytext); return ID;}
{num}       {yylval.value = atof(yytext); return NUM;}
.           {/* ignora altri caratteri*/}
%%