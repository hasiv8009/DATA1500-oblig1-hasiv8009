# Besvarelse - Refleksjon og Analyse

**Student:** Harald Stople Sivertsen

**Studentnummer:** hasiv8009

**Dato:** 20. feb 2026

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**
Utleietilfeller (rentals)
Sykler (bikes)
Kunder (customers)
Utleiestasjoner (rental_stations)

**Attributter for hver entitet:**
Utleietilfeller:
    unik id
    Hvilken sykkel gjelder det
    Kunde-ID
    Stasjon og tid for uttak av sykkelen
    Stasjon og tid for tilbakelevering
    Har også lagt til et attributt for "fakturert dato", jeg tenker dette kan være nyttig å oppdatere når man henter ut data for fakturering. Blir enklere å feilsøke, eventuelt overføre på nytt de utleieforhold som har blitt overført til økonomisystemet i et gitt tidsrom.

Sykler:
    unik ID
    modell
    status på sykkelen (ledig, eller forklaring på hvorfor den ikke er ledig. Utleid, til service, tatt ut av bruk etc.)
    Hvilken utleiestasjon er sykkelen på nå?
    Dato for når sykkelen ble lagt inn i systemet

Kunder:
    unik ID
    Fornavn, etternavn, telefonnummer, epost, og registreringsdato

Utleiestasjoner
    unik Id, navn, adresse

### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

For serienummmer-id har jeg valgt int. Det gir en hard limit på litt over 2 milliarder. Anser at BIGINT er unødvendig.
For dato/tid har jeg valgt TIMESTAMPTZ. Det er en grei grunnregel å lagre timestamps som UTC. Vi har kun en tidssone i Norge, men vi har sommertid som kan skape problemer hvis vi lagrer tider i lokal tid.
For tekstfeltene har jeg valgt VARCHAR(x). Jeg har holdt makslengden på strengene nede fordi lange fritekstfelt skaper flere problemer enn de løser. Jeg tenker på layout i apper, på nettsider, fakturaer osv. Det er 1 av 100 000 brukere som har epostadresse lenger enn 50 tegn. Den personen får bruke en annen adresse til å registrere seg med.

**`CHECK`-constraints:**

endTime IS NULL OR endTime > startTime
Uten denne kan vi få umulige leieforhold som slutter før de har begynt

startStationId IS NOT NULL
Når vi oppretter et nytt leieforhold, må det starte et sted.

currentStatus IN ('available','rented','maintenance','retired')
Liste over mulige status på syklene. Dette kan ikke bare være fritekst (med sjanse for stavefeil), da blir det vanskelig å kjøre queries som SELECT FROM bikes WHERE status = 'available'


**ER-diagram:**
erDiagram
    direction TB

    rental_stations {
        int stationId PK ""  
        varchar(20) stationName  ""  
        varchar(50) stationAddress  ""  
        }

	bikes {
		int bikeId PK ""  
		varchar(20) bikeModel  ""  
		varchar(20) currentStatus  ""  
		int stationId  ""  
		TIMESTAMPTZ bikeAddedDate  ""  
	}

	customers {
		int customerId PK ""  
		varchar(20) firstName  ""  
		varchar(30) lastName  ""  
		varchar(20) phoneNumber  ""  
		varchar(50) email  ""  
		TIMESTAMPTZ registeredDate  ""  
	}

	rentals {
		int rentalId PK ""  
		int bikeId FK ""  
		int customerId FK ""  
		int startStationId  ""  
		int endStationId  ""  
		TIMESTAMPTZ startTime  ""  
		TIMESTAMPTZ endTime  ""  
		TIMESTAMPTZ invoiceDate  ""  
	}

	rentals}o--||bikes:"  "
	rentals}o--||customers:"  "
	rentals}o--||rental_stations:"startStation"
	rentals}o--||rental_stations:"endStation"
	rental_stations ||--o{ bikes : "currentStation"
---

### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**
int stationId
int bikeId
int customerId
int rentalid


**Naturlige vs. surrogatnøkler:**
Alle primærnøkler er surrogatnøkler (int serial). Jeg har ikke vurdert naturlige nøkler, fordi jeg ikke stoler på at noen av datafeltene i tabellene, med unntak av timestamps, ikke kan endres. Kunder kan endre navn, epost, telefonnummer, navn og adresse på utleiesteder kan endres. Det kan være mange sykler av hver type. Serial int er enkelt å bruke og uproblematisk.

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

Et utleieforhold må ha en og kun en kunde-ID, en og kun en sykkel-ID, ett og kun ett startsted for utleien
Andre veien kan det være null eller mange. En kunde kan ha null eller mange leieforhold, en sykkel kan ha null eller mange leieforhold osv.

**Fremmednøkler:**

i "rentals": Fremmednøkler bikeId og customerId, fordi det ikke kan opprettes eller finnes noe leieforhold uten disse to relasjonene.
**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

[Skriv ditt svar her - forklar om datamodellen din tilfredsstiller 1NF og hvorfor]

Datamodellen tilfredsstiller 1NF. Data er atomære, hvert attributt inneholder kun en verdi.

**Vurdering av 2. normalform (2NF):**

Datamodellen tilfredsstiller 2NF. Det finnes ingen delvise avhengigheter fra sammensatt nøkkel. (Alle nøkler er surrogatnøkler)

[Skriv ditt svar her - forklar om datamodellen din tilfredsstiller 2NF og hvorfor]

**Vurdering av 3. normalform (3NF):**

Datamodellen tilfredstiller 3NF. I tillegg til kravene i 2NF, krever 3NF at det ikke finnes transitive avhengiheter innen entitetene. Det gjør det ikke i denne modellen, alle atributter i entitetene relaterer direkte til PK.

**Eventuelle justeringer:**

[Skriv ditt svar her - hvis modellen ikke var på 3NF, forklar hvilke justeringer du har gjort]

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

[Bekreft at du har lagt SQL-skriptet i `init-scripts/01-init-database.sql`]

**Antall testdata:**

- Kunder: [antall]
- Sykler: [antall]
- Sykkelstasjoner: [antall]
- Låser: [antall]
- Utleier: [antall]

---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

[Skriv ditt svar her - f.eks. skjermbilder eller output fra terminalen som viser at databasen ble opprettet uten feil]

**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

```
"bikes"
"customers"
"rental_stations"
"rentals"
```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
CREATE ROLE kunde;
```

**SQL for å opprette bruker:**

```sql
CREATE USER kunde_1 WITH PASSWORD 'kunde1';
```

**SQL for å tildele rettigheter:**

```sql
GRANT CONNECT ON DATABASE bike_rental TO kunde;
GRANT kunde TO kunde_1;
GRANT USAGE ON SCHEMA kunde_views TO kunde_1;
GRANT SELECT ON kunde_views.kunde1_view TO kunde_1;

REVOKE ALL ON SCHEMA public FROM kunde_1;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM kunde_1;
              
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
CREATE SCHEMA kunde_views;
CREATE VIEW kunde_views.kunde1_view AS
SELECT
    r.bike_id,
    b.bike_model,
    r.start_time,
    rs_end.station_name AS til_stasjon,
    r.end_time - r.start_time AS varighet
FROM rentals r
    JOIN bikes b
      ON r.bike_id = b.bike_id
    INNER JOIN rental_stations rs_start
      ON r.start_station_id = rs_start.station_id
    INNER JOIN rental_stations rs_end
      ON r.end_station_id = rs_end.station_id
WHERE r.customer_id = 1; --
```

**Ulempe med VIEW vs. POLICIES:**

Generelt så vil man ikke gi kundene tilgang direkte til databasen i det hele tatt. Dette gjøres normalt gjennom en applikasjonsserver. 

I det tenkte tilfellet der 1000 kunder kobler seg opp mot databasen og kjører en query på et view, 
vil dette bli praktisk uhåndterlig, fordi hver kunde må ha sitt eget view.

Mange views vil kunne gi dårligere ytelse.

Dersom noe man endrer noe i tabellene, kan man måtte oppdatere alle 1000 views



---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

5 måneder x 20k = 100k

4 måneder x 5k = 20k

3 måneder x 500 = 1.5k

Totalt per år: 121 500 utleietilfeller.


**Estimat for lagringskapasitet:**

Entiteten som har mange tupler er tabellen for utleietilfeller (rentals). Denne inneholder: 5 INT og 3 TIMESTAMPTZ. Int er 4 byte, TIMESTAMPTZ er 8 byte. Så totalt blir det 44 byte per tuppel. Vet ikke nøyaktig overhead for Postgres, men la oss si det er 40 bytes? Da havner vi på 84 byte per tuppel.

Ganger vi dette med 121 500 får vi: .084 x 121500 = 10206 kB.

La oss si at vi har 10 000 tupler med brukere. Denne entiteten er 1 INT 4B, 1 TIMESTAMPTZ 8B, 4 VARCHAR. Jeg har ikke gjort analyse av hvor mye plass navn, telefonnummer og epostadresse tar, men en kvalifisert gjetting er 100 B. Så vi kan si 112 B totalt for kunderegisteret.

Ganger vi dette med 10 000 får vi 1 120 kB.

De andre entitetene inneholder sammenligningsvis svært få tupler. La oss si at de tar 1 000 kB til sammen.
**Totalt for første år:**

Sum av det som er regnet ut over: 10 MB + 1 MB + 1 MB = 12 MB.

Eventuelle indekser vil også ta plass. La oss si at indekser tar opp like mye plass som dataene. Da havner vi på 12 + 12 = 24 MB.

I tillegg kommer logging. Men logging kan og bør gjøres i en annen database, da datamengdene er store, og antall lesinger, samgt kravene til søketid og ytelse, er mye lavere.


---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

[Skriv ditt svar her - gi konkrete eksempler fra CSV-filen som viser redundans]
De lange tekstfeltene epost og adresse (og mange andre attributter) blir lagret på nytt for hvert utleietilfelle, i stedet for å lagres som en relasjon til bruker-id.

**Problem 2: Inkonsistens**

[Skriv ditt svar her - forklar hvordan redundans kan føre til inkonsistens med eksempler]
Denne modellen (en enkelt flat fil) gjør at det er vanskelig å unngå selvmotsigelser, dobbeltoppføringer

**Problem 3: Oppdateringsanomalier**

[Skriv ditt svar her - diskuter slette-, innsettings- og oppdateringsanomalier]
Dersom man ønsker å sette inn en ny bruker, blir man stående med en ufullstendig tuppel som har veldig mange null-verdier. Når man senere skal registrere e

**Fordeler med en indeks:**

[Skriv ditt svar her - forklar hvorfor en indeks ville gjort spørringen mer effektiv]

**Case 1: Indeks passer i RAM**

[Skriv ditt svar her - forklar hvordan indeksen fungerer når den passer i minnet]

**Case 2: Indeks passer ikke i RAM**

[Skriv ditt svar her - forklar hvordan flettesortering kan brukes]

**Datastrukturer i DBMS:**

[Skriv ditt svar her - diskuter B+-tre og hash-indekser]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

LSM-tre eller heap. LSM-tre er best for logging, men det har lite å si med den relativt lave skrivefrekvensen i dette caset.

**Begrunnelse:**

Logging medfører mye sekvensiell skriving, ingen oppdatering av allerede skrevne data, og sjelden lesing.

**Skrive-operasjoner:**

LSM-tre har svært høy skriveytelse. Skriveoperasjoner blir cachet i RAM og det skrives mange logghendelser samtidig til disk.

**Lese-operasjoner:**

[Skriv ditt svar her - forklar hvordan datastrukturen håndterer sjeldne lese-operasjoner]

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**


Validering bør gjøres i både klientlag, applikasjonslag og database.

**Validering i nettleseren:**


Fordeler: umiddelbar respons og interaktivitet. Avlasting av applikasjonslaget. Feil rettes opp så tidlig som mulig, ved bruk av kundens ressurser. Sparer ressurser (båndbredde, cpu, ram) i applikasjonslaget.

Ulemper: Utsatt for manipulasjon, f.eks curl. Sikkerhetsrisiko. Noe validering krever databasespørringer (for eksempel hvorvidt brukeren allerede er registrert). Kan være mange ulike klienter (apper, nettleser, andre klienter). Klientene kan være av gammel versjon. Nettleser kan ha cachet dataene.

Brukes til: Validering av inputformat, feltlengde, forbudte tegn, gyldig epostadresse osv.

**Validering i applikasjonslaget:**


Fordeler: Sikrere. Vanskelig å manipulere. Raskt å endre. Kan bruke databasen til å validere input (f.eks bruker eksisterer allerede)

Ulemper: Bruker serverressurser. Kan gi tregere respons til brukeren.

Brukes til: Bør alltid brukes som en ekstra sikkerhet/ekstra validering. Bør også foreta spørringer til databasen i henhold til forretningslogikk (ikke tillatt med to brukere med samme epostadresse). Bør håndtere de aller fleste mulige feil, da håndtering av feil i applikasjonslaget kan gi en bedre tilpasset feilmelding til brukeren.

**Validering i databasen:**

Fordeler: Hindrer at bugs eller dårlig kode i applikasjonslaget fører til feil i databasen. 

Ulemper: Feilmeldinger er i et språk som ikke er brukervennlig. Tar opp ressurser dersom databasen må håndtere mange unødvendige feil som kan fanges opp i applikasjonslaget.

Brukes til: Dette er "siste skanse", og kan fange opp feil implementasjon av forretningslogikk eller rett og slett bugs i applikasjonslaget. 

**Konklusjon:**


Validering bør gjøres i alle tre lag (klient, applikasjonslag og database). Enkle ting som "epost ikke utfylt", "format på telefonnummer feil", gjøres i nettleseren/appen. Feil som krever databaseoppslag (sjekk om bruker allerede er registrert) må gjøres i applikasjonslaget. I tillegg bør applikasjonslaget validere alt som allerede er validert i nettleseren.

Validering i databasen er en sikkerhetsforanstaltning, og i utgangspunktet bør feil fanges opp før de kommer til databasen.

Når det gjelder ytelse, medfører validering i nettleser/app massiv parallellisering. Også applikasjonslaget kan paralelliseres/skaleres horisontalt. Databaser derimot er vanskelig å skalere horisontalt. Det bør derfor være et mål å "bry databasen minst mulig", siden det er "dyrt".

Disse tingene har lite å si i små implementasjoner, men får svært stor betydning når man arbeider med store datamengder og hundrevis av db IO pr sekund.

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

ER-modellering, hva normalisering betyr (jeg gjør det intuitivt siden jeg har jobbet med databaser),
oppsett av Postgres i Docker, bruk av CLI til oppgaver jeg vanligvis har gjort med admin-vertøy


**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

Det er bra å gjøre en større oppgave med samme tema / samme database, siden man bedre ser den store sammenhengen.
Øvingsoppgavene generelt har vært gode i dette faget.

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

Lage testdata. Lage rutiner for import av tabeller fra excel til databasen. Jeg endte med å ikke bruke disse metodene i besvarelsen, men lærte mye av det.

**Hva har du lært om databasedesign:**

Jeg har jobbet mye med databaser tidligere, så det kom ikke akkurat som et sjokk.
Jeg har lært teorien om normalisering og naturlige, sammensatte primærnøkler. Tidligere har jeg nesten utelukende sett surrogatnøkler bli brukt


---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

[Bekreft at du har lagt SQL-spørringene i `test-scripts/queries.sql`]


**Eventuelle feil og rettelser:**

[Skriv ditt svar her - hvis noen tester feilet, forklar hva som var feil og hvordan du rettet det]

---

## Del 6: Bonusoppgaver (Valgfri)

### Oppgave 6.1: Trigger for lagerbeholdning

**SQL for trigger:**

```sql
[Skriv din SQL-kode for trigger her, hvis du har løst denne oppgaven]
```

**Forklaring:**

[Skriv ditt svar her - forklar hvordan triggeren fungerer]

**Testing:**

[Skriv ditt svar her - vis hvordan du har testet at triggeren fungerer som forventet]

---

### Oppgave 6.2: Presentasjon

**Lenke til presentasjon:**

[Legg inn lenke til video eller presentasjonsfiler her, hvis du har løst denne oppgaven]

**Hovedpunkter i presentasjonen:**

[Skriv ditt svar her - oppsummer de viktigste punktene du dekket i presentasjonen]

---

**Slutt på besvarelse**
