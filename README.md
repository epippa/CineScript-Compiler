# 🎬 CineScript

**CineScript** è un linguaggio di programmazione minimalista ispirato al mondo del cinema. L'intero linguaggio è costruito attorno a metafore cinematografiche, rendendo la programmazione simile alla scrittura di un copione.

## 📜 Descrizione del Progetto

CineScript supporta:

- Dichiarazione e gestione di variabili `float` e `string`
- Operazioni aritmetiche con priorità e parentesi
- Concatenazione di stringhe
- Blocchi condizionali `if` (`se`) e cicli `while` (`mentre`)
- Scope management (variabili valide solo all’interno di un blocco)
- Funzioni predefinite come `somma(x, y)`
- Comandi speciali per stampare e analizzare variabili

Tutti i comandi utilizzano una sintassi che richiama la terminologia cinematografica, rendendolo unico e didattico.

## 🧠 Comandi Supportati

| Comando      | Descrizione                                       |
|--------------|----------------------------------------------------|
| `azione`     | Dichiara una variabile `float`                    |
| `dramma`     | Dichiara una variabile `string`                   |
| `riprendi`   | Riassegna il valore a una variabile già dichiarata |
| `scena`      | Stampa il contenuto di una variabile              |
| `zoom`       | Stampa il contenuto `float` in formato esteso     |
| `cast`       | Stampa la Symbol Table                            |
| `finale`     | Termina il programma con messaggio finale         |
| `taglia`     | Interrompe immediatamente l’esecuzione            |

## ✍️ Sintassi di Base

### Dichiarazione

```
azione x = 5
dramma saluto = "Ciao"
```

### Operazioni

```
azione somma = x + 3 * 2
azione media = (x + y) / 2
dramma messaggio = saluto + " mondo"
```

### Riassegnazione

```
riprendi x = x + 1
```

### Blocchi

```
se (x > 5) {
    scena "Maggiore di 5"
}

mentre (x > 0) {
    scena x
    riprendi x = x - 1
}
```

## 🧮 Funzioni Predefinite

Attualmente è disponibile:

```
azione risultato = somma(3.0, 4.5)
```

Le funzioni accettano variabili o numeri. In futuro è possibile aggiungerne altre.

## 🛠️ Compilazione

```
flex Cine-lex.l
bison -d CineScripty.y
gcc lex.yy.c CineScripty.tab.c -o cinescript -lm
```

## ▶️ Esecuzione

```
./cinescript < test.cinema
```

## 🧪 Esempio di Test (test.cinema)

```
azione a = 5
azione b = 3.2
azione somma = somma(a, b)
scena somma

dramma s1 = "Ciao "
dramma s2 = "Mondo"
dramma saluto = s1 + s2
scena saluto

azione x = 9
azione y = 2
azione z = (x + y) / 2
scena z

se (a > b) {
    scena "Condizione vera"
}

mentre (x > 0) {
    scena x
    riprendi x = x - 2
}

cast
finale
```

## 📦 Struttura Interna

### Symbol Table

Una lista concatenata di variabili definite nel programma, ognuna contenente:

- Tipo (`float` o `string`)
- Nome identificatore
- Scope
- Valore (numerico o stringa)

### Scope

Ogni blocco `{}` crea un nuovo livello di scope. Le variabili dichiarate al suo interno vengono rimosse al termine del blocco.

## ✅ Funzionalità Implementate

- [x] Dichiarazione e riassegnazione variabili
- [x] Operazioni aritmetiche e concatenazioni
- [x] Gestione dello scope
- [x] Blocchi `if` e `while`
- [x] Funzione `somma(x, y)`
- [x] Stampa semplice e completa
- [x] Stampa della Symbol Table

## 👤 Autore

**Emanuele Pippa**  
Progetto universitario basato su *Compilers - Principles, Techniques, and Tools (Dragon Book)*  
Libera Università di Bolzano - Corso Compilatori e Linguaggio Formale