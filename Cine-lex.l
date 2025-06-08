// Licenza: Creative Commons BY-NC 4.0 © 2025 Emanuele Pippa
// Uso consentito solo per scopi non commerciali, con attribuzione

%option noyywrap
%option case-insensitive
%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
%}

letter [a-zA-Z]
digit [0-9]
id {letter}({letter}|{digit})*
num {digit}+(\.{digit}+)?
string \"([^\\\"]*)\"

%%
[ \t\r]+   { /* ignora spazi bianchi */ }
\n      { return '\\n'; }
@.*     { return COMMENT; }

"=="    {return EQUAL;}
"<"     {return LESS;}
">"     {return GREAT;}
"<="    {return LESSEQ;}
">="    {return GREATEQ;}
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
"["	{return '[';}
"]"	{return ']';}

"if"     {return IF;}
"se"     {return IF;}
"while"  {return WHILE;}
"mentre" {return WHILE;}

"film"	    {return FUNZIONE;}
"azione"    {return AZIONE;}
"dramma"    {return DRAMMA;}
"scena"     {return SCENA;}
"riprendi"  {return RIPRENDI;}
"finale"    {return FINALE;}
"taglia"    {return TAGLIA;}
"ritorna"   {return RETURN;}
"string"    {yylval.lexeme = "string"; return STRING;}
"float"     {yylval.lexeme = "float"; return FLOAT;}

{id}        {yylval.lexeme = strdup(yytext); return ID;}
{num}       {yylval.value = atof(yytext); return NUM;}
.           {/* ignora altri caratteri*/}

%%