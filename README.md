# Arredamenti – sito vetrina per negozio di arredamento (Flutter Web)

Sito vetrina + preventivi + gestionale completo, scritto in Flutter (solo web), responsive per telefono, tablet, PC e TV.

| Pagina | Percorso | Cosa fa |
|---|---|---|
| Home | `/#/` | Carosello a tutto schermo con dissolvenze e zoom lento, presentazione con i numeri, ambienti in sequenza (foto grande + descrizione, alternate), carosello "Dallo showroom", nastro dei marchi che scorre, metodo di lavoro, recensioni, invito al preventivo |
| Ambienti | `/#/ambienti` | Tutti gli ambienti; ogni ambiente (`/#/ambienti/<id>`) ha la sequenza di foto con descrizione, caratteristiche, marchi e ambiente successivo |
| Marchi | `/#/marchi` | Tutti i marchi, filtrabili per categoria (logo o nome in carattere elegante) |
| Biografia | `/#/biografia` | Storia, foto, tappe, persone e metodo |
| Preventivo | `/#/preventivo` | Modulo in tre passi: progetto (ambienti, stile, città, m², budget, tempi), formule e servizi, contatti |
| Gestionale | `/#/admin` | Gestione di tutto il sito, delle richieste e del calendario |

## Il pulsante "Cambia stile"

Lo stesso sito si può mostrare con **7 temi pronti** (Galleria calda, Notte e ottone, Atelier salvia, Bianco cemento, Blu Riviera, Terracotta, Ardesia): cambiano colori, carattere dei titoli e stile dei pulsanti, con una dissolvenza; le foto restano le stesse.

Dal gestionale → **Stile e temi**:

- scegli il **tema predefinito** (la stella);
- scegli **chi vede il pulsante**: tutti, solo con il link di prova (`/#/?prova=1`) oppure nessuno;
- scegli quali temi **proporre**;
- crea **temi tuoi** (nome, carattere, scuro/chiaro, 7 colori) con anteprima dal vivo;
- copia il **link per il cliente** (`/#/?tema=notte`): il sito si apre già con quel tema.

## Avvio

```bash
flutter pub get
flutter run -d chrome
```

Build di produzione: `flutter build web --release` (output in `build/web`).
Per provarla dal telefono sulla stessa Wi-Fi: `dart run tool/serve_release.dart` (porta 8080).

> Nota: usa `google_fonts` 8.x. La 9.x dipende dal nuovo pacchetto `material_ui` ed è incompatibile con il `material.dart` di Flutter 3.47.

## Gestionale

Al primo accesso (`/#/admin`) si crea la password. Sezioni:

- **Panoramica** – numeri e ultime richieste/appuntamenti
- **Richieste** – preventivi con ambienti, città, stile, budget, tempi; stato (nuova → contattata → sopralluogo → confermata → archiviata), ricerca, contatto rapido (telefono / WhatsApp / email), appunti interni, stima interna del totale, "Fissa appuntamento"
- **Calendario** – vista mensile + agenda, sincronizzato con Google Calendar
- **Recensioni** – quelle inviate dai clienti dal sito restano nascoste finché non le approvi
- **Ambienti** – foto con descrizione, caratteristiche, marchi collegati, ordine e visibilità
- **Marchi** – nome, logo (facoltativo), categoria, descrizione, sito
- **Servizi e prodotti** – le voci del preventivo; il prezzo è facoltativo e **solo interno**
- **Formule** – combinazioni pronte di servizi
- **Galleria e carosello** – foto del carosello dello showroom; con la stella anche nella prima schermata
- **Stile e temi** – vedi sopra
- **Pagina Home / Biografia / Identità e contatti** – tutti i testi, le immagini, i contatti e le opzioni del modulo preventivo
- **Impostazioni** – Client ID Google, password, backup/ripristino

## Google Calendar

Gli appuntamenti si scrivono nel **calendario principale** dell'account Google con cui si fa l'accesso.
Serve una sola volta un Client ID OAuth (Gestionale → Impostazioni spiega i passaggi e mostra l'indirizzo da autorizzare). Lo scope richiesto è solo `calendar.events`.

## Pubblicazione

A ogni push su `master` la GitHub Action `.github/workflows/deploy.yml` ricompila il sito e lo pubblica su GitHub Pages.

## Dove stanno i dati (importante)

Per ora **tutti i dati sono nel browser** (localStorage) tramite `LocalRepository`:

- le richieste di preventivo e le recensioni inviate dai visitatori restano nel *loro* browser, non arrivano al titolare;
- le modifiche fatte nel gestionale si vedono solo da quel browser;
- le foto caricate dal computer sono incorporate nei dati (limite ~5 MB totali).

Per un sito reale serve un archivio online condiviso: basta implementare i due metodi di `Repository` (`lib/data/repository.dart`) con Firebase/Supabase/API proprie e sostituire `LocalRepository` in `lib/main.dart`.

## Struttura

```
lib/
  main.dart, app.dart          avvio, temi animati, router (e link ?prova= / ?tema=)
  models/models.dart           contenuti, ambienti, marchi, servizi, formule, foto, recensioni, richieste, appuntamenti, stile
  data/                        Repository (+ implementazione locale) e dati di esempio
  state/app_state.dart         stato dell'app e operazioni
  services/                    Google Identity Services + API Calendar
  theme/site_theme.dart        i temi del sito (ThemeExtension con dissolvenza)
  theme/app_theme.dart         tema fisso del gestionale, misure responsive, scala per TV
  widgets/                     carosello, sezioni, nastro marchi, recensioni, pulsante temi, navigazione, footer
  pages/                       home, ambienti, marchi, biografia, preventivo
  pages/admin/                 gestionale
test/                          test di tutte le pagine su 7 misure di schermo, temi, preventivo, recensioni, backup
```

I contenuti di esempio (testi, foto Unsplash, contatti fittizi, marchi) vanno sostituiti dal gestionale.
