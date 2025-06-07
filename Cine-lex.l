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
