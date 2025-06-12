/* ============================================== */
/* CineScript - Copyright © 2025 Emanuele Pippa   */
/* Licenza: CC BY-NC 4.0                          */
/* ============================================== */

%option noyywrap
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

"if"    {return IF;}
"se"    {return IF;}
"while"      {return WHILE;}   /* Non so fare i salti condizionali, quindi x ora funziona come un if */
"mentre"     {return WHILE;}

"azione"    {return AZIONE;}    /* dramma */
"dramma"    {return DRAMMA;}    /* string */
"scena"     {return SCENA;}     /* per stampare (come dire "mostrare") */
"riprendi"  {return RIPRENDI;}  /* riassegna */
"finale"    {return FINALE;}    /* output */
"cast"      {return CAST;}      /* print Symbol Table */
"zoom"      {return ZOOM;}      /* stampa float per intero */

\"[^"]*\" {yylval.lexeme = strdup(yytext + 1);              // Rimuove la prima virgolette
           yylval.lexeme[strlen(yylval.lexeme) - 1] = '\0'; // Rimuove l'ultima virgolette
           return STRING;}
{id}        {yylval.lexeme = strdup(yytext); return ID;}
{num}       {yylval.value = atof(yytext); return NUM;}
.           {/* ignora altri caratteri*/}
%%