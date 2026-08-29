---
title: "Un contenuto, due percorsi: man e posts"
description: "Come ho separato la documentazione tecnica dal diario cronologico senza duplicare i contenuti"
date: 2026-08-29T22:46:00+02:00
---

Il sito ora ha due modi diversi di raggiungere ciò che scrivo.

`man` è la struttura permanente: un manuale gerarchico nel quale gli argomenti
sono organizzati come directory e ogni documento conserva accanto a sé immagini
e altre risorse.

`posts` è invece la linea temporale: mostra in ordine cronologico sia i post
editoriali sia le pagine del manuale che scelgo di annunciare.

## Una sola sorgente

Inizialmente, pubblicare un nuovo appunto tecnico avrebbe richiesto due file: il
documento nel manuale e una sua copia nei post. Oltre al lavoro aggiuntivo, le
due versioni avrebbero potuto divergere.

Ora il contenuto resta soltanto nella sua posizione canonica. Per esempio, gli
appunti sul modello ISO/OSI vivono in
[`/man/network/00-osi-model/`](/man/network/00-osi-model/), insieme alle loro
immagini. La timeline legge direttamente quella pagina e collega lo stesso URL.

Per annunciare una pagina del manuale sono sufficienti due proprietà nel front
matter:

```yaml
date: 2026-08-29T22:44:00+02:00
show_in_posts: true
```

Titolo, descrizione, testo e immagini non vengono copiati.

## Page bundle per le risorse

Le pagine tecniche sono leaf bundle Hugo. Ogni articolo ha una directory con
`index.md` e le proprie risorse:

```text
00-osi-model/
├── index.md
├── network-graph.png
├── osi-vs-tcp-ip.png
└── encapsulation-decapsulation.png
```

Questa organizzazione rende più semplice importare gli export di Notion e
mantiene i riferimenti alle immagini locali e leggibili.

## Il risultato

Il manuale rimane consultabile per argomento, mentre la home e `posts` rendono
visibili gli aggiornamenti più recenti. Sono due viste della stessa raccolta di
contenuti, non due copie.

La documentazione tecnica dell'implementazione è disponibile nella pagina
[`/man/labs/software/blog/`](/man/labs/software/blog/).
