/*  Licenza: Creative Commons BY-NC 4.0 © 2025 Emanuele Pippa
    Uso consentito solo per scopi non commerciali, con attribuzione */

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
string  \"([^"]*)\"

%%

[ \t\r]+   { /* ignora spazi bianchi */ }
\n         {/* ignora nuove linee */}
@.*        {return COMMENT;}

"=="    {return EQUAL;}
"<"     {return LESS;}
">"     {return GREAT;}
"<="    {return LESSQ;}
">="    {return GREATQ;}
"!="    {return NOTEQ;}
"="     {return '=';}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
"("     {return '(';}
")"     {return ')';}
"{"     {return '{';}
"}"     {return '}';}
"["     {return '[';}
"]"     {return ']';}

"if"     {return IF;}
"se"     {return IF;}
"while"  {return WHILE;}
"mentre" {return WHILE;}

"film"      {return FUNZIONE;}
"azione"    {return AZIONE;}    /*float*/
"dramma"    {return DRAMMA;}    /*string*/
"scena"     {return SCENA;}     /*per stampare (come dire "mostrare")*/
"riprendi"  {return RIPRENDI;}  /*per assegnare*/
"taglia"    {return TAGLIA;}    /*quit*/
"finale"    {return FINALE;}    /*output*/
"registra"  {return REGISTRA;}  /*return*/

"string"    {yylval.lexeme = "string"; return STRING;}
"float"     {yylval.lexeme = "float"; return FLOAT;}

{id}        {yylval.lexeme = strdup(yytext); return ID;}
{num}       {yylval.value = atof(yytext); return NUM;}
.           {/* ignora altri caratteri*/}

%%