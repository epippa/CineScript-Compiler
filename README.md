# CineScript 🎬

**CineScript** è un linguaggio di programmazione didattico ispirato alla sceneggiatura cinematografica. È stato sviluppato utilizzando **Flex** e **Bison** per illustrare i principi base dei compilatori, integrando anche concetti avanzati come gestione dello scope, tipi dinamici e strutture dati.

---

## 📚 Introduzione al progetto

CineScript consente di scrivere programmi usando una sintassi "narrativa", basata sul lessico del cinema. Il compilatore è in grado di interpretare ed eseguire dichiarazioni di variabili, operazioni aritmetiche, concatenazioni di stringhe, strutture condizionali (`if`) e comandi speciali come la stampa, la gestione della Symbol Table e l'accesso a funzioni matematiche.

---

## 🛠 Tecnologie utilizzate

- **Flex (Fast Lexical Analyzer)**: utilizzato per la generazione dell'analizzatore lessicale (`Cine-lex.l`), che trasforma l'input in token.
- **Bison (YACC-compatible parser generator)**: utilizzato per costruire il parser (`CineScripty.y`), che analizza la grammatica del linguaggio.
- **C**: per implementare la semantica, la Symbol Table, la gestione dello scope e le funzioni di runtime.

---

## 🧠 Funzionalità principali

- **Dichiarazione e riassegnazione di variabili**
  - `AZIONE ID = expr` → float
  - `DRAMMA ID = expr` → stringa
  - `RIPRENDI ID = expr` → riassegnazione

- **Stampa su output**
  - `SCENA expr`: stampa il valore.
  - `ZOOM ID`: stampa il valore numerico completo.

- **Strutture di controllo**
  - `IF (condizione) Ellipsis` o `SE (...) Ellipsis`
  - `WHILE (condizione) Ellipsis` o `MENTRE (...) Ellipsis`

- **Gestione dello scope**
  - Le variabili hanno un campo `scope` che ne regola la visibilità.
  - `currentScope` varia durante l'esecuzione per gestire blocchi `if`.

- **Funzioni matematiche**
  - `SOMMA(a,b)`, `DIFFERENZA(a,b)`, `PRODOTTO(a,b)`, `DIVISO(a,b)`
  - `PI`, `RADICEQ(x)`, `ABS(x)`, `POTENZA(x, y)`

- **Operatori**
  - Aritmetici: `+ - * / %`
  - Confronto: `== != > < >= <=`

- **Commenti**
  - Linee precedute da `@` vengono ignorate.

- **Visualizzazione Symbol Table**
  - `CAST`: stampa tutte le variabili salvate.

- **Aiuto**
  - `HELP` o `SCENEGGIATURA`: mostra tutti i comandi disponibili.

---

## 🧮 Symbol Table

- Implementata come **linked list**, tiene traccia di:
  - `ID`, `Tipo (float|string)`, `Scope`, `Valore o Stringa`
- Tutte le variabili, anche quelle nei blocchi condizionali, vengono salvate nella Symbol Table.
- Non esiste alcuna cancellazione: lo scope viene usato nel `lookup()` per selezionare la variabile corretta.

---

## 🧩 Grammatica del linguaggio

```ebnf
prog        → lista_stmt | lista_stmt FINALE
stmt        → AZIONE ID = expr
            | DRAMMA ID = expr
            | RIPRENDI ID = expr
            | SCENA expr
            | ZOOM ID
            | IF (compare) { lista_stmt }
            | WHILE (compare) { lista_stmt }
            | CAST
            | HELP
            | SCENEGGIATURA

expr        → ID | NUM | STRING
            | expr + expr
            | expr - expr
            | expr * expr
            | expr / expr
            | expr % expr
            | - expr
            | ( expr )
            | funzione(expr, expr)
            | costante

compare     → expr == expr | expr != expr | expr > expr | ...
```

---

## 💻 Come compilare ed eseguire

Assicurati di avere `flex`, `bison` e `gcc` installati. Poi, esegui:

```bash
make
```

Verrà generato l'eseguibile `cinescript`. Per eseguire uno script, puoi usare:

```bash
./cinescript < TEST.cinema
```

---

## 🧪 File di test

Il file `TEST.cinema` contiene esempi completi di input. È utile per verificare il funzionamento del compilatore.

---

## 📎 Decisioni progettuali

- **Symbol Table con linked list** per semplicità e flessibilità nella gestione dello scope.
- **currentScope variabile** per decidere se stampare o eseguire istruzioni (condizioni).
- **esegui_blocco flag** per evitare esecuzioni in blocchi falsi.
- **Gestione separata per float e string**: facilita l’implementazione e la semantica.
- **Rimozione dei `brace_statement`**: non viene più cancellata nessuna variabile.

---

## 📌 Esempi validi

```cinema
azione a = 5
azione b = 3.20
azione sum = somma(a, b)
scena sum
scena "------"

dramma s1 = "Ciao "
dramma s2 = "Mondo"
dramma saluto = s1 + s2
scena saluto

azione m = 4.5
azione n = 2
azione prodotto = prodotto(m, n)
scena prodotto

scena potenza(2,3)   @ 8
```

---

## ✅ Conforme alle richieste del docente

- Tutte le variabili sono salvate nella Symbol Table.
- Gestione dello scope corretta e persistente.
- Eliminato `brace_statement`.
- Nessuna cancellazione variabili.
- Aiuto/documentazione tramite `HELP` e `SCENEGGIATURA`.

---

## 👨‍🏫 Autore

Progetto sviluppato da **Emanuele Pippa** per il corso universitario sui compilatori.

---
