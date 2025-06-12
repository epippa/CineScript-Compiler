/* ============================================== */
/* CineScript - Copyright © 2025 Emanuele Pippa   */
/* Licenza: CC BY-NC 4.0                          */
/* ============================================== */
// CineScript - Linguaggio di programmazione basato sulla sceneggiatura

/* definitions */
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define CHAR_MAX 256

typedef struct Variable Variable;

//Symbol Table
struct Variable {
    char* type; //float o string
    char* id;   //nome della variabile
    int scope;  //livello profondità dentro IF
    union { 
        float floatValue;
        char* stringValue;
    } value;
    struct Variable* next;
};

//variabili globali
int currentScope = 0;
int esegui_blocco = 1;  //se è 1, esegue le azioni semantiche
Variable* head = NULL;
Variable* tail = NULL;
char* output;

void yyerror(const char *s);
int yylex(void);
Variable* lookup(char* s);
Variable varOp(Variable a, Variable b, char op);
Variable toVar(char* s, float f);
Variable getValue(Variable v);
void addVariable(char* type, char* name, float numero, char* stringa, int scope);
void changeValue(Variable* v, Variable newVal);
void printValue(Variable* var);
void printComplete(Variable* var);
float getFloatValue(Variable v);
char* getStringValue(Variable temp);
void printSymbolTable(void);
Variable* eseguiFunzione(char* nome, Variable* a, Variable* b);
%}

%union{
    char* lexeme;   //id, string
    float value;    //num
    struct Variable* variabile;
}

//dichiazione token riconosciuti dal lexer
%token IF DRAMMA RIPRENDI SCENA FINALE AZIONE ZOOM CAST WHILE
%token <value> NUM
%token <lexeme> ID STRING

//Non terminali
%type <value> com_expr compare
%type <variabile> expr

%left '+' '-'
%left '*' '/'
%left GREAT LESS EQUAL GREATQ LESSQ NOTEQ MOD

%start prog

%%      
/* Sintactic Rules */
/* CFG
 <non_term> : <body> {<action>}
            | <body> {<sction>}
            ;
*/

prog : stmtLi
     | stmtLi FINALE  {printf("\n### Fine Copione ###\n\n"); exit(0);}
     ;

stmtLi : lista_stmt ;

lista_stmt : stmt lista_stmt
           |
           ;
                                                                             
//confronto
compare : expr EQUAL expr   {$$=(getFloatValue(*$1) == getFloatValue(*$3));}
        | expr NOTEQ expr   {$$=(getFloatValue(*$1) != getFloatValue(*$3));}
        | expr GREAT expr   {$$=(getFloatValue(*$1) > getFloatValue(*$3));}
        | expr GREATQ expr  {$$=(getFloatValue(*$1) >= getFloatValue(*$3));}
        | expr LESS expr    {$$=(getFloatValue(*$1) < getFloatValue(*$3));}
        | expr LESSQ expr   {$$=(getFloatValue(*$1) <= getFloatValue(*$3));}
        ;

//istruzioni
//$$ :   $1   $2  $3  $4
stmt : AZIONE ID '=' expr   {addVariable("float", $2, getFloatValue(*$4), NULL, currentScope);}     //assegnazione variabile float
     | DRAMMA ID '=' expr   {addVariable("string", $2, 0.0, getStringValue(*$4), currentScope);}    //assegnazione variabile stringa
     | SCENA expr           {if (esegui_blocco == 1) printValue($2);}       //stampa stringa 
     | RIPRENDI ID '=' expr {Variable* temp = lookup($2); if (temp && esegui_blocco) changeValue(temp, *$4);}   //riassegnazione variabili
     | ZOOM ID              {Variable* temp = lookup($2); if (temp && esegui_blocco) printComplete(temp);}      //stampa variabile per intero
     | IF com_expr '{' lista_stmt '}'     {currentScope--; esegui_blocco = 1;}  //esegui_blocco serve per decidere se eseguire o meno le azioni semantiche all'interno di un blocco
     | WHILE com_expr '{' lista_stmt '}'  {currentScope--; esegui_blocco = 1;}  //currentScope serve per tenere traccia della profondità dello scope (per scegliere nella Symbol Table la variabile da prendere)
     | CAST                               {if (esegui_blocco == 1) printSymbolTable();}
     ;


com_expr : '(' compare ')' {
    currentScope++;               // Entriamo sempre in un nuovo scope
    esegui_blocco = $2;           // Ma eseguiamo solo se condizione vera
    $$ = $2;
};
                                                                                                                                                              
//expressions
expr : ID              {Variable* temp = lookup($1); $$ = malloc(sizeof(Variable));
                            if(temp == NULL){if (esegui_blocco == 1) //Siamo in un blocco e non ho trovato la variabile
                                yyerror("Variabile non trovata"); *$$ = toVar(NULL, 0.0); //cerco la variabile nella Symbol Table. Se assente: errore, restituisco puntatore fittizio per evitare crash.
                            } else {*$$ = *temp;}}    //Se esiste, ne ritorno il puntatore
     | NUM             {Variable temp = toVar(NULL, $1); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | STRING          {Variable temp = toVar($1, 0.0); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '+' expr   {Variable temp = varOp(*$1, *$3, '+'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '-' expr   {Variable temp = varOp(*$1, *$3, '-'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '*' expr   {Variable temp = varOp(*$1, *$3, '*'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr '/' expr   {Variable temp = varOp(*$1, *$3, '/'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | expr MOD expr   {Variable temp = varOp(*$1, *$3, '%'); $$ = malloc(sizeof(temp)); *$$ = temp;}
     | '(' expr ')'    {$$ = $2;} //espressione tra parentesi
     | ID '(' expr ',' expr ')'     {$$ = eseguiFunzione($1, $3, $5);} //somma(a,b)
           
%%   /* routines */

//trova variabile nella symbol table (con lo scope più alto possibile)
Variable* lookup(char* ID) {
    Variable* current = head;
    Variable* matched = NULL;
    int maxScope = -1;

    while (current != NULL) {
        if (strcmp(current->id, ID) == 0 && current->scope <= currentScope) {
            if (current->scope > maxScope) {
                matched = current;
                maxScope = current->scope;
            }
        }
        current = current->next;
    }
    return matched;
}


char* floatToString(float f);

//crea una variabile temporanea usata solo per calcoli o valori letterali
Variable toVar(char* stringa, float number) {
    Variable var;
    var.id = strdup("");    //temporaneo
    var.scope = 0;          //non ha scope
    if (stringa != NULL){
        var.type = "string";    //se è stringa, risultato è stringa
        var.value.stringValue = strdup(stringa);
    } else {
        var.type = "float";     //se è un numero
        var.value.floatValue = number;
    }
    var.next = NULL;
    return var;
}

Variable varOp(Variable a, Variable b, char op) {
    Variable result;
    result.id = "";

    //Se uno dei 2 è stringa, funziona solo la concatenazione +
    if (strcmp(a.type, "string") == 0 || strcmp(b.type, "string") == 0) {
        if (op != '+') {
            yyerror("Errore: con stringhe va solo il + per concatenare");
        }
        // Se uno dei due è float, lo converte in stringa
        char* aStr = (strcmp(a.type, "float") == 0) ? floatToString(a.value.floatValue) : a.value.stringValue;
        char* bStr = (strcmp(b.type, "float") == 0) ? floatToString(b.value.floatValue) : b.value.stringValue;

        result.type = "string";
        result.value.stringValue = malloc(strlen(aStr) + strlen(bStr) + 1);
        strcpy(result.value.stringValue, aStr);
        strcat(result.value.stringValue, bStr);

        if (strcpy(a.type, "float") == 0) free(aStr);  //libera la memoria se era float (memoria allocata da floatToString)
        if (strcmp(b.type, "float") == 0) free(bStr);  //se era string, non libera la memoria 
        return result;
    }

    //Se entrambi float fa operazioni aritmetiche
    if (strcmp(a.type, "float") == 0 && strcmp(b.type, "float") == 0) {
        result.type = "float";
        switch(op) {
            case '+':
                result.value.floatValue = a.value.floatValue + b.value.floatValue;
                break;
            case '-':
                result.value.floatValue = a.value.floatValue - b.value.floatValue;
                break;
            case '*':
                result.value.floatValue = a.value.floatValue * b.value.floatValue;
                break;
            case '/':
                if (b.value.floatValue == 0)
                    yyerror("Errore: divisione per zero");
                result.value.floatValue = a.value.floatValue / b.value.floatValue;
                break;
            case '%':
                    result.value.floatValue = fmod(a.value.floatValue, b.value.floatValue);
                break;
            default:
                yyerror("Errore: operatore non valido. Scegli tra +, -, *, /");
        }
        return result;
    }

    //Se non è ne float ne string
    yyerror("Errore: tipi non compatibili");    //per evitare possibili errori
    return result;
}

Variable getValue(Variable val) {
    return val;
}

//aggiunge una variabile alla Symbol Table
void addVariable(char* type, char* name, float numero, char* stringa, int scope) {
    //assegna memoria per la nuova variabile
    Variable* nuova = malloc(sizeof(Variable));
    if (!nuova) {
        yyerror("Errore: allocazione fallita");
        exit(1);
    }

    //Assegna tipo, nome e scope
    nuova->type = strdup(type);
    nuova->id = strdup(name);
    nuova->scope = scope;
    nuova->next = NULL;

    //Assegna il valore in base al tipo (float o string)
    if (strcmp(type, "float") == 0) {
        nuova->value.floatValue = numero;
    } else if (strcmp(type, "string") == 0) {
        nuova->value.stringValue = strdup(stringa);
    } else {
        yyerror("Errore: tipo non riconosciuto, dev'essere float o string");
    }

    nuova->next = NULL;

    //aggiunge la variabile alla fine della lista / Symbol Table
    if (head == NULL) {
    head = nuova;
    tail = nuova;
    } else {
        tail->next = nuova;
        tail = nuova;
    }
}

void changeValue(Variable* oldValue, Variable newValue) {
    if (oldValue == NULL) {
        yyerror("Errore: variabile inesistente");
        return;
    }

    if (strcmp(oldValue->type, newValue.type) != 0) {
        yyerror("Errore: variabile di tipo diverso");
        return;
    }

    //se è float, lo sovrascrive
    if (strcmp(oldValue->type, "float") == 0) {
        oldValue->value.floatValue = newValue.value.floatValue;
    } else if (strcmp(oldValue->type, "string") == 0) {
        //se è string, cancella quella vecchia e assegna la nuova
        free(oldValue->value.stringValue);
        oldValue->value.stringValue = strdup(newValue.value.stringValue);
    }
}

float getFloatValue(struct Variable v) {
    if (strcmp(v.type, "float") == 0) {
        return v.value.floatValue;
    }
    yyerror("Errore: variabile non float");
    return 0.0;
}

char* getStringValue(Variable temp) {
    return temp.value.stringValue;
}

void printValue(Variable* var) {
    if (var == NULL) {
        yyerror("Errore: variabile inesistente");
        return;
    } else if (strcmp(var->type, "float") == 0){
        if (var->value.floatValue == (int)var->value.floatValue)    //se è un numero intero
                printf("%d\n", (int)var->value.floatValue);
        else printf("%.2f\n", var->value.floatValue);   //se è float
    }else{ 
        printf("%s\n", var->value.stringValue);     //se è stringa
    }
}

void printComplete(Variable* var) {
    if (strcmp(var->type, "float") == 0)
        printf("%f\n", var->value.floatValue);
    else{
        yyerror("Errore: command ZOOM usable only for numbers!");
        return;
    }
}

void printSymbolTable(void) {
    printf("\n\n### Symbol Table ###\n");
    Variable* current = head;
    while (current != NULL) {
        printf("ID: %s (Type: %s, Scope: %d, ", current->id, current->type, current->scope);

        if (strcmp(current->type, "float") == 0) {
            printf("Value: %.2f)\n", current->value.floatValue);    //float, lo stampa con 2 cifre decimali
        } else {
            printf("Text: %s)\n", current->value.stringValue); //string, lo stampa tra virgolette
        }
        current = current->next;
    }
}

Variable* eseguiFunzione(char* nome, Variable* a, Variable* b) {
    if (strcmp(nome, "somma") == 0) {       //somma(a, b)...
        if(!a || !b) {
            yyerror("Manca un argomento");
            return NULL;
        }
        float first = getFloatValue(*a);
        float second = getFloatValue(*b);
        Variable* res = malloc(sizeof(Variable));
        *res = toVar(NULL, first + second);
        return res;
    }

    if (strcmp(nome, "differenza") == 0) {
        if(!a || !b) {
            yyerror("Manca un argomento");
            return NULL;
        }
        float first = getFloatValue(*a);
        float second = getFloatValue(*b);
        Variable* res = malloc(sizeof(Variable));
        *res = toVar(NULL, first - second);
        return res;
    }

    if (strcmp(nome, "prodotto") == 0) {
        if(!a || !b) {
            yyerror("Manca un argomento");
            return NULL;
        }
        float first = getFloatValue(*a);
        float second = getFloatValue(*b);
        Variable* res = malloc(sizeof(Variable));
        *res = toVar(NULL, first * second);
        return res;
    }

    if (strcmp(nome, "diviso") == 0) {
        if(!a || !b) {
            yyerror("Manca un argomento");
            return NULL;
        }
        float first = getFloatValue(*a);
        float second = getFloatValue(*b);
        Variable* res = malloc(sizeof(Variable));
        *res = toVar(NULL, first / second);
        return res;
    }

    yyerror("Funzione non trovata");
    return NULL;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

char* floatToString(float f) {
    char* buffer = malloc(32);
    snprintf(buffer, 32, "%.2f", f);
    return buffer;
}

int main() {
    int currentScope = 0;
    output = malloc(CHAR_MAX);
    strcpy(output, "");
    yyparse();
    return 0;
}}