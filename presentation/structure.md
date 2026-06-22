# Lakehouse als Enabler für Machine Learning im Gesundheitswesen

## Gliederung

**Leitsatz des Vortrags (roter Faden)**

> Der Engpass für KI im Gesundheitswesen ist nicht das Modell, sondern eine Plattform, die reproduzierbare, validierbare Datenstände liefert - gezeigt an einem Problem, das man messen kann.

Dieser Satz wird auf [Folie 4](#folie-4---warum-dieses-thema-das-versprechen) als Versprechen gesetzt und auf [Folie 36](#folie-36---schlussbild-und-qa) wörtlich eingelöst.

**Hinweis zum Format**

Jede Folie ist nach demselben Schema beschrieben, damit daraus direkt ein Slide-Deck generiert werden kann:

* **Titel** - kurzer Folientitel.
* **Headline** - die eine Kernaussage als ganzer Satz; gehört sichtbar auf die Folie.
* **Inhalt** - folienfertige Bullets, bewusst knapp gehalten.
* **Visual** - Vorschlag für Diagramm, Bild oder Layout.
* **Sprechernotiz (Skript)** - der durchgängige gesprochene Text; gehört in die Notizen, nicht auf die Folie. Eckige Klammern sind Regieanweisungen. Sprecherwechsel sind markiert: [SG] = Sebastian Gobst (Architektur), [YQ] = Yannik Queisler (ML).

**Wiederkehrendes Leitmotiv:** Eine Zonen-Map (Raw → Process → Access) wird in Teil 1 aufgebaut und taucht im ML-Teil immer wieder mit einem „Wir sind hier"-Marker auf. So wandert der Use Case sichtbar durch dieselbe Architektur und verbindet beide Vortragshälften.

**Zielverteilung**

* Intro und Einordnung: ca. 5 Folien
* Lakehouse, Architektur und Orchestrierung: ca. 10 Folien
* ML am Beispiel Patient Record Linkage: ca. 16 Folien
* Lessons Learned und Outro: ca. 5 Folien

**Quellen zum Record-Linkage-Teil**

* FlexRL: Robach, K., van der Pas, S. L., van de Wiel, M. A. & Hof, M. H. (2024). *A Flexible Model for Record Linkage*. arXiv preprint. Implementierung: [github.com/robachowyk/FlexRL](https://github.com/robachowyk/FlexRL)
* Record-Linkage-Grundlagen für die Hybrid Cascade: Fellegi, I. P. & Sunter, A. B. (1969). *A Theory for Record Linkage*. JASA. Sowie Christen, P. (2012). *Data Matching* (Springer) für Blocking und String-Ähnlichkeit (Q-Gram/Jaccard, Edit Distance).

---

## 0. Einstieg und Einordnung

### Folie 1 - Titel

**Headline:** Eine konkrete KVWL-Implementierung für produktives Data Engineering und ML - keine abstrakte Lakehouse-Vision.

**Inhalt**

* Titel: Lakehouse als Enabler für Machine Learning im Gesundheitswesen
* Untertitel: Open Source, On-Premise, Data Engineering und ML auf einer Plattform
* Sprecher: Sebastian Gobst (DATA MART Consulting) und Yannik Queisler (KVWL)
* TDWI-Kontext
* Leitfrage: Welche Datenplattform braucht produktives Data Engineering und ML im Gesundheitswesen?

**Visual:** Titelfolie mit zwei Logos (DATA MART, KVWL), dezentes Hintergrundmotiv „Plattform/Schichten". Platz für die spätere Zonen-Map als Wiedererkennung.

**Sprechernotiz (Skript):** [SG] Herzlich willkommen, schön, dass Sie da sind. Unser Titel klingt erst einmal nach einem dieser großen Plattform-Versprechen - „Lakehouse als Enabler für Machine Learning". Genau das wollen wir aber nicht abstrakt halten. Wir zeigen Ihnen heute eine konkrete Implementierung, die bei der Kassenärztlichen Vereinigung Westfalen-Lippe produktiv läuft - Open Source, On-Premise, von den Rohdaten bis zum ML-Modell. [YQ] Und wir nehmen Sie an einem echten Fachproblem mit, an dem man am Ende sogar messen kann, ob sich der ganze Aufwand gelohnt hat. Die Leitfrage über allem: Welche Datenplattform braucht man eigentlich, damit Data Engineering und Machine Learning im Gesundheitswesen produktiv funktionieren? Dazu stellen wir uns kurz vor.

---

### Folie 2 - DATA MART Consulting und Sebastian Gobst

**Headline:** DATA MART bringt die Perspektive aus DWH-, BI- und Datenarchitekturprojekten ein.

**Inhalt**

* DATA MART Consulting GmbH
* Sebastian Gobst, Principal Consultant Systemarchitektur
* Schwerpunkt: Optimierung von Datenlandschaften, BI/DWH, zunehmend Open Source Lakehouse
* Rolle im Vortrag: Architekturperspektive, Migrationslogik, Einordnung gegen klassische DWH-Muster

**Visual:** Porträt + kurze Rollen-Chips (Architektur · Migration · BI/DWH).

**Sprechernotiz (Skript):** [SG] Mein Name ist Sebastian Gobst, ich bin Principal Consultant für Systemarchitektur bei der DATA MART Consulting. Wir kommen klassisch aus der Welt der Data Warehouses und Business Intelligence und begleiten Kunden dabei, ihre Datenlandschaften zu optimieren - und zunehmend eben auch in Richtung Open-Source-Lakehouse zu modernisieren. Meine Rolle heute ist die Architekturperspektive: Wie sieht das Zielbild aus, welche Migrationslogik steckt dahinter, und wie grenzt sich das Ganze von klassischen DWH-Mustern ab. Den zweiten Teil, das Machine Learning, übernimmt mein Kollege - stell dich gern vor.

---

### Folie 3 - KVWL und Yannik Queisler

**Headline:** Die KVWL bringt die On-Premise-Implementierung, das durchgängige KI-/ML-Beispiel und die Lessons Learned ein.

**Inhalt**

* Kassenärztliche Vereinigung Westfalen-Lippe
* Yannik Queisler, Data Engineer
* Schwerpunkt: Spark, Airflow, Delta Lake, ML Engineering
* Rolle im Vortrag: KI-/ML-Teil, Patientenbildung als durchgängiges Beispiel, Lessons Learned
* Kontext: KI ist in der KVWL ein neues Handlungsfeld und wird über greifbare Fachprozesse eingeführt
* Leitmotiv: erst Datenqualität, Plattform und konkrete Nutzenfälle - nicht zuerst ein großer unternehmensweiter Chatbot ohne belastbare Datenbasis

**Visual:** Porträt + Rollen-Chips (ML Engineering · Data Engineering · Healthcare).

**Sprechernotiz (Skript):** [YQ] Sehr gerne. Ich bin Yannik Queisler, Data Engineer bei der Kassenärztlichen Vereinigung Westfalen-Lippe. Mein Alltag ist Spark, Airflow, Delta Lake - und zunehmend ML Engineering. Ich bringe heute die konkrete On-Premise-Umsetzung mit, unser durchgängiges KI-Beispiel und die Lessons Learned aus dem Aufbau. Wichtig zum Kontext: KI ist bei uns ein neues Handlungsfeld. Wir führen das bewusst über greifbare Fachprozesse ein - nicht mit einem großen unternehmensweiten Chatbot, der auf einer wackeligen Datenbasis steht, sondern entlang der Reihenfolge erst Datenqualität, dann Plattform, dann konkrete Nutzenfälle. Warum diese Reihenfolge so entscheidend ist, dazu kommen wir direkt.

---

### Folie 4 - Warum dieses Thema? (Das Versprechen)

**Headline:** Produktive KI scheitert selten am Modell - sondern an Datenhistorie, Datenqualität, Verantwortlichkeiten und Reproduzierbarkeit.

**Inhalt**

* Robuste DWH-Landschaften liefern stabile BI, aber Data Engineering und ML erzeugen neue Anforderungen
* Generative KI ist sichtbar, aber klassisches ML bleibt ein sehr direkter Werterzeuger für strukturierte Fachprozesse
* Typische Spannung:
  * Governance vs. Iterationsgeschwindigkeit
  * Reporting-Stabilität vs. Feature-Engineering
  * kuratierte Datenprodukte vs. rohe Historie
* Gesundheitsdaten verschärfen die Anforderungen an Nachvollziehbarkeit und Kontrolle
* **Leitsatz (Versprechen):** Der Engpass ist nicht das Modell, sondern eine Plattform, die reproduzierbare, validierbare Datenstände liefert - gezeigt an einem Problem, das man messen kann.

**Visual:** Eisberg-Metapher: kleine Spitze „Modell", großer Unterwasserteil „Daten, Historie, Governance, Reproduzierbarkeit". Leitsatz als hervorgehobenes Zitat.

**Sprechernotiz (Skript):** [YQ] Wenn heute über KI gesprochen wird, geht es fast immer ums Modell. Unsere Erfahrung - und das deckt sich mit der Forschung zu Data-centric AI und Technical Debt in ML-Systemen - ist eine andere: Produktive KI scheitert selten am Modell. Sie scheitert an der Datenhistorie, an der Datenqualität, an unklaren Verantwortlichkeiten und an fehlender Reproduzierbarkeit. [auf den Eisberg zeigen] Das Modell ist die sichtbare Spitze; der große Teil unter Wasser sind die Daten, die Historie, die Governance. Robuste Data Warehouses liefern stabile Berichte - aber Machine Learning stellt neue Anforderungen, und es entstehen Spannungen: Governance gegen Iterationsgeschwindigkeit, Reporting-Stabilität gegen Feature-Engineering, kuratierte Datenprodukte gegen die rohe Historie. Bei Gesundheitsdaten kommt verschärfte Nachvollziehbarkeit dazu. [langsamer, das ist das Versprechen] Deshalb unser Leitsatz für die nächsten 40 Minuten: Der Engpass ist nicht das Modell, sondern eine Plattform, die reproduzierbare, validierbare Datenstände liefert - und das zeigen wir an einem Problem, das man tatsächlich messen kann. Auf genau diesen Satz kommen wir am Ende zurück.

---

### Folie 5 - Ablauf und Zielbild

**Headline:** Von der Architektur zur Umsetzung und dann zu einem validierbaren Leitbeispiel, an dem KI-/ML-Einführung greifbar wird.

**Inhalt**

* Ausgangslage: SSIS-/DWH-Welt und uneinheitliche Lake-Zonen
* Zielarchitektur: Multi-Zone-Functional Lakehouse
* Orchestrierung und Technologieentscheidungen
* Leitbeispiel: Patientenbildung als Patient Record Linkage und Survivorship
* Zweites Beispiel: Anomalieerkennung in Abrechnungsdaten als weiterer ML-Anwendungsfall
* roter Faden: Nutzen früh greifbar machen, ohne die Datenplattform zu überspringen
* Lessons Learned: Was hat sich bewährt, was bleibt schwierig?

**Visual:** Agenda als horizontaler Pfad mit vier Etappen; die spätere Zonen-Map als Mini-Vorschau andeuten.

**Sprechernotiz (Skript):** [YQ] Unser Weg durch den Vortrag folgt genau dieser Logik. Wir starten bei der Ausgangslage - einer klassischen SSIS- und DWH-Welt mit uneinheitlichen Lake-Zonen. Dann zeigt Sebastian die Zielarchitektur, das Multi-Zone-Functional Lakehouse, samt Orchestrierung und Technologieentscheidungen. Danach übernehme ich mit unserem Leitbeispiel: der Patientenbildung, die im Kern ein Record-Linkage- und Survivorship-Problem ist. Ein zweites Beispiel - Anomalieerkennung in Abrechnungsdaten - streifen wir bewusst kürzer, und ich sage Ihnen später auch, warum. Der rote Faden ist dabei immer: Nutzen früh greifbar machen, ohne die Datenplattform zu überspringen. Und ganz am Ende stehen die Lessons Learned - was sich bewährt hat und was schwierig bleibt. Sebastian, fang gern mit der Ausgangslage an.

---

## 1. Lakehouse, Architektur und Orchestrierung

### Folie 6 - Ausgangslage: Von SSIS zu Lakehouse

**Headline:** Der Umbau startet nicht bei Tools, sondern bei der Frage, wo welche Logik verantwortlich liegt.

**Inhalt**

* Übergeordnetes Ziel aus `kvwl_lakehouse.pdf`: Datentransformationen aus der alten SSIS-Welt ablösen
* Offene Leitfragen:
  * Wo wird Logik implementiert - im Projekt und im Layer?
  * Welche Technologie ist für welchen Schritt passend - PySpark, dbt, SQL?
  * Welche Garantien darf ein Downstream-Consumer von einem Dataset erwarten?

**Visual:** Links altes SSIS-/DWH-Symbolbild, rechts Fragezeichen-Wolke mit den drei Leitfragen; Pfeil „von … zu …".

**Sprechernotiz (Skript):** [SG] Danke, Yannik. Der Ausgangspunkt war eine gewachsene SSIS- und Data-Warehouse-Welt. Das übergeordnete Ziel war klar: Die Transformationen aus dieser alten Welt ablösen. Spannend ist aber, dass der Umbau gar nicht bei den Tools beginnt, sondern bei einer scheinbar simplen Frage - wo liegt welche Logik eigentlich verantwortlich? Drei Leitfragen haben uns durch das ganze Projekt begleitet: Erstens, wo wird Logik implementiert - in welchem Projekt und in welchem Layer? Zweitens, welche Technologie passt für welchen Schritt - PySpark, dbt oder einfaches SQL? Und drittens, eine oft unterschätzte Frage: Welche Garantien darf ein nachgelagerter Consumer von einem Datensatz überhaupt erwarten? Wenn man diese Fragen nicht beantwortet, bekommt man genau die Probleme, die wir vorher hatten.

---

### Folie 7 - Problem der alten Zonenlogik

**Headline:** Uneinheitliche Layer-Verantwortlichkeiten erzeugen kognitive Last, doppelte Logik und schwache Garantien.

**Inhalt**

* Landing Zone: Lebenszyklus nicht eindeutig
* Staging Zone: unregelmäßige Nutzung, wechselnde Formate
* History Zone: Rohdaten und Fachlogik statt klarer Historisierung
* Analysis Zone: SSIS-Altlogik und Auswertungen vermischt
* Konsequenz: unklare Codelokalisierung, schweres Reprocessing, hoher Bus-Faktor

**Visual:** Vier Zonen-Kästen mit überlappenden, durcheinander laufenden Pfeilen (bewusst „chaotisch") - Kontrast zur sauberen Zielarchitektur auf Folie 9.

**Sprechernotiz (Skript):** [SG] Schauen wir auf die alte Zonenlogik. Auf dem Papier gab es Zonen - aber ihre Verantwortlichkeiten waren unscharf. Die Landing Zone war gleichzeitig temporäre Ablage und Archiv. Die Staging Zone wurde nur sporadisch genutzt, in unterschiedlichsten Formaten. Die History Zone war ein Mischmasch aus Rohdaten und Fachlogik. Und genau dort lag die Logik oft verteilt: in Source-SQLs der SSIS-Pakete, im SSIS-Datenfluss, in Stored Procedures oder in Views auf der History-Schicht. Die Analysis Zone war ebenfalls von SSIS-Altlogik und Auswertungen durchmischt. [auf die chaotischen Pfeile zeigen] Die Konsequenz sehen Sie an diesen Pfeilen: Man weiß nicht, wo eine bestimmte Logik liegt, Reprocessing wird zur Qual, und der Bus-Faktor ist hoch - es hängt zu viel an einzelnen Köpfen. Genau das wollten wir auflösen. Bevor ich zeige, wie, kurz das Prinzip dahinter.

---

### Folie 8 - Lakehouse-Prinzip für die KVWL

**Headline:** Lakehouse heißt hier: offene Speicherung plus Warehouse-Garantien für Data Engineering, Analytics und ML.

**Inhalt**

* einheitlicher Speicher für strukturierte, semi-strukturierte und perspektivisch weitere Datenformen
* ACID-Tabellen und paralleler Lese-/Schreibzugriff über Delta Lake
* Schema-Validierung, Metadatenkatalog, Lineage und Zugriffskontrolle
* DataHub als Governance-Komponente für Data Catalog, Discovery, Ownership, Lineage und Data Contracts
* Performance durch optimierte Dateiformate, Statistiken, Clustering/Compaction
* BI, Analytics und ML auf derselben Plattform ohne redundante Schatten-ETL

**Visual:** Zwei-Spalten-Vergleich „Data Lake | Data Warehouse" verschmilzt zu einer Box „Lakehouse" mit Garantie-Icons (ACID, Schema, Lineage).

**Sprechernotiz (Skript):** [SG] Der Begriff Lakehouse wird viel benutzt, deshalb sage ich, was wir konkret darunter verstehen. Auf der einen Seite die Offenheit eines Data Lake - ein einheitlicher Speicher für strukturierte, semi-strukturierte und perspektivisch weitere Datenformen. Auf der anderen Seite die Garantien eines Warehouse. Konkret heißt das bei uns: ACID-Tabellen und paralleler Lese- und Schreibzugriff über Delta Lake, Schema-Validierung, ein Metadatenkatalog, Lineage und Zugriffskontrolle. Für die Governance setzen wir DataHub ein - als Katalog, für Discovery, Ownership, Lineage und Data Contracts. Performance holen wir über optimierte Dateiformate, Statistiken und Compaction. Und der entscheidende Effekt: BI, Analytics und ML laufen auf derselben Plattform - ohne dass jeder sich seine eigene Schatten-ETL nebenbei baut. Wie das räumlich aussieht, zeigt das Zielbild.

---

### Folie 9 - Zielarchitektur: Multi-Zone-Functional (Die Zonen-Map)

**Headline:** Die neue Architektur definiert Zonen über Funktionen und Verträge, nicht über historisch gewachsene Namen.

**Inhalt**

* Zielbild aus `kvwl_lakehouse.pdf`:
  * Landing Zone: optional und transient
  * Raw Zone: unveränderliche Rohdatenhistorie
  * Process Zone: technische Qualität und Standardisierung
  * Access Zone: fachliche Datenprodukte für BI, Analytics und ML
* horizontale Zonen mit klaren Verträgen, vertikale Governance-/Ops-Aspekte

**Visual:** DIES IST DIE KANONISCHE ZONEN-MAP. Vier horizontale Schichten Landing → Raw → Process → Access, von links nach rechts; darüber/daneben vertikale Balken „Orchestrierung" und „Governance/DataHub". Genau dieses Bild kehrt im ML-Teil mit einem „Wir sind hier"-Marker wieder.

**Sprechernotiz (Skript):** [SG] Das hier ist das zentrale Bild des Vortrags - merken Sie es sich, es kommt später im ML-Teil immer wieder. Wir definieren Zonen jetzt über ihre Funktion und über klare Verträge, nicht mehr über historisch gewachsene Namen. Von links nach rechts: Die Landing Zone ist optional und transient. Die Raw Zone ist die unveränderliche Rohdatenhistorie. Die Process Zone sorgt für technische Qualität und Standardisierung. Und die Access Zone enthält die fachlichen Datenprodukte - für BI, Analytics und eben auch für ML. Horizontal also die Zonen mit klaren Verträgen, und vertikal ziehen sich Orchestrierung und Governance durch alle Schichten. [kurze Pause] Der Trick ist: Jede Zone hat eine klar definierte Aufgabe und ein Versprechen an die nächste. Gehen wir die wichtigen Zonen einzeln durch.

---

### Folie 10 - Landing und Raw Zone

**Headline:** Rohdatenhistorie ist die Grundlage für Audits, Reprocessing und reproduzierbare ML-Datenstände.

**Inhalt**

* Landing Zone:
  * kurzlebig, optional, keine Transformationen
  * automatische Bereinigung nach kurzer Aufbewahrung
* Raw Zone:
  * langfristige Historisierung als System of Record
  * Append-only, quellnah, Schema-on-Read
  * technische Metadaten: Quelle, Pfad, Ladezeitpunkt, Dateigröße, Checksumme
  * nur minimale Validierung: Parsbarkeit, Existenz, Größe, technische Integrität

**Visual:** Zonen-Map mit Markierung auf Landing + Raw; Detail-Callout „append-only Historie = jederzeit denselben Stand reproduzierbar".

**Sprechernotiz (Skript):** [SG] Beginnen wir links. Die Landing Zone ist bewusst kurzlebig: keine Transformationen, nur Anlieferung, und nach kurzer Aufbewahrung automatisch bereinigt. Das eigentlich Wichtige ist die Raw Zone. Sie ist unser System of Record - langfristig historisiert, append-only, quellnah, mit Schema-on-Read. Wir schreiben technische Metadaten mit: Quelle, Pfad, Ladezeitpunkt, Dateigröße, Checksumme. Und wir validieren hier nur minimal - Parsbarkeit, Existenz, Größe, technische Integrität, mehr nicht. [auf den Callout zeigen] Warum ist das so streng? Weil eine unveränderliche, append-only Historie bedeutet: Wir können jederzeit exakt denselben Datenstand wiederherstellen. Das ist die Grundlage für Audits, für Reprocessing - und, das wird im ML-Teil entscheidend, für reproduzierbare Datenstände. Yannik wird später drei verschiedene Algorithmen gegen exakt denselben Raw-Stand testen. Das geht nur, weil Raw wirklich raw bleibt.

---

### Folie 11 - Process Zone

**Headline:** In der Process Zone wird aus historisierten Rohdaten eine technisch verlässliche Grundlage.

**Inhalt**

* Standardisierung von Formaten und Datentypen
* Delta Lake als robustes Tabellenformat
* technische Bereinigung: fehlende Werte, Inkonsistenzen, Deduplikation, Schema-Evolution
* Provenienz und Laufmetadaten
* erlaubt: dataset-unabhängige Standardisierungslogik und Integration
* verboten: verbraucherspezifische Denormalisierung und fachliche Marts

**Visual:** Zonen-Map mit Markierung auf Process; kleine „erlaubt / verboten"-Gegenüberstellung.

**Sprechernotiz (Skript):** [SG] Eine Zone weiter: die Process Zone. Hier wird aus der historisierten Rohmasse eine technisch verlässliche Grundlage. Wir standardisieren Formate und Datentypen, nutzen Delta Lake als robustes Tabellenformat, und wir bereinigen technisch - fehlende Werte, Inkonsistenzen, Deduplikation, Schema-Evolution. Provenienz und Laufmetadaten laufen mit. Entscheidend sind aber die Verträge: Was ist hier erlaubt, was nicht? Erlaubt ist dataset-unabhängige Standardisierung und Integration. Verboten ist verbraucherspezifische Denormalisierung und das Bauen fachlicher Marts. Denn sobald man Fachlogik in die Process Zone schmuggelt, hat man wieder den Mischmasch von vorhin. Fachlichkeit gehört eine Zone weiter.

---

### Folie 12 - Access Zone und Datenprodukte

**Headline:** Die Access Zone ist der Ort für fachliche Semantik, konsumierbare Datenprodukte und Feature Sets.

**Inhalt**

* fachliche Transformationen, Aggregationen, Star Schemas, Wide Tables
* Feature Engineering und Serving-nahe Tabellen für ML
* dokumentierte Metrikdefinitionen, fachliche Granularität und SLOs
* Versionierung bei Breaking Changes, parallele Auslaufphasen
* Tests für Metrikkonsistenz, dimensionale Integrität und Freshness
* keine Rückkopplung in Raw oder Process außer dokumentierten Backfill-/Reconciliation-Verfahren

**Visual:** Zonen-Map mit Markierung auf Access; Datenprodukt-Karten (Star Schema, Wide Table, Feature Set) als Output-Symbole.

**Sprechernotiz (Skript):** [SG] Und damit die Access Zone - der Ort, an dem Fachlichkeit lebt. Hier entstehen fachliche Transformationen, Aggregationen, Star Schemas, Wide Tables. Hier passiert Feature Engineering und es entstehen serving-nahe Tabellen für ML. Wichtig ist, dass das echte Datenprodukte sind: mit dokumentierten Metrikdefinitionen, fachlicher Granularität und Service-Level-Objectives. Bei Breaking Changes versionieren wir und lassen alte Stände parallel auslaufen. Wir testen auf Metrikkonsistenz, dimensionale Integrität und Freshness. Und eine klare Regel: keine Rückkopplung zurück in Raw oder Process - außer über dokumentierte Backfill- und Reconciliation-Verfahren. Damit das in der Praxis funktioniert, braucht es die richtigen Werkzeuge je Zone.

---

### Folie 13 - Technologieentscheidungen: PySpark, dbt, Delta, DataHub

**Headline:** Der Stack trennt technische Verarbeitung und fachliche Modellierung klarer als vorher - ohne mit maximaler Infrastrukturkomplexität zu starten.

**Inhalt**

* PySpark: Ingestion, technische Standardisierung, große Datenmengen, komplexe Algorithmen jenseits von SQL/dbt
* dbt: fachliche Modelle in der Access Zone, Tests, Dokumentation, Lineage, SQL-nahe Analytics
* Delta Lake: ACID, Schema Enforcement, MERGE/Upserts, Time Travel
* Hive Metastore: zentraler Tabellen- und Metadatenzugriff
* DataHub: Catalog, Discovery, Ownership, Lineage, Governance, Data Contracts - Brücke zwischen technischen Tabellen und fachlicher Nutzbarkeit
* Betriebsprinzip: einfache, containerisierte Services zuerst; Architektur migrationsfähig Richtung Kubernetes schneiden

**Visual:** Zonen-Map, in jede Zone die passenden Tool-Logos eingeblendet (PySpark in Raw/Process, dbt in Access, Delta durchgehend, DataHub als Governance-Balken).

**Sprechernotiz (Skript):** [SG] Jetzt zu den Werkzeugen - und Sie sehen, sie ordnen sich sauber den Zonen zu. PySpark nutzen wir für Ingestion, technische Standardisierung, große Datenmengen und für komplexe Algorithmen, die man in SQL nicht sinnvoll abbildet - das wird im ML-Teil wichtig. dbt setzen wir für die fachlichen Modelle in der Access Zone ein, inklusive Tests, Dokumentation und Lineage. Delta Lake zieht sich als Tabellenformat durch alle Zonen - ACID, Schema Enforcement, MERGE-Upserts, Time Travel. Der Hive Metastore gibt uns zentralen Tabellen- und Metadatenzugriff. Und DataHub ist die Brücke zwischen technischen Tabellen und fachlicher Nutzbarkeit - Katalog, Ownership, Lineage, Data Contracts. Ein Prinzip dabei, das uns viel gespart hat: erst einfache, containerisierte Services - und die Architektur trotzdem so schneiden, dass eine spätere Migration Richtung Kubernetes möglich bleibt. Wie wir das orchestrieren, sehen Sie als Nächstes.

---

### Folie 14 - Orchestrierung, Governance und Pipeline-Verträge

**Headline:** Reproduzierbarkeit entsteht erst, wenn Datenstände, Jobs, Abhängigkeiten, Qualitätschecks und Metadaten zusammengeführt werden.

**Inhalt**

* Airflow als Steuerungsschicht für Ingestion, Processing und Access-Produkte
* DAGs machen Abhängigkeiten, Wiederanläufe und Scheduling explizit
* Pipeline-Metadaten pro Lauf: Quelle, Zeitraum, Extraktzeitpunkt, Row Counts, Checksummen, Status
* DataHub als sichtbarer Governance-Layer für Ownership, Lineage, Dataset-Beschreibung, Data Contracts
* Quality Gates zwischen Layers statt unkontrollierter Transformationen
* kontrollierte Übergänge von explorativer Logik in produktive Pipelines

**Visual:** Airflow-DAG als Graph über der Zonen-Map; an den Zonenübergängen kleine „Quality Gate"-Schlösser.

**Sprechernotiz (Skript):** [SG] Eine Architektur allein macht noch keine Reproduzierbarkeit. Die entsteht erst, wenn man Datenstände, Jobs, Abhängigkeiten, Qualitätschecks und Metadaten zusammenführt. Dafür nutzen wir Airflow als Steuerungsschicht über Ingestion, Processing und Access-Produkte. Die DAGs machen Abhängigkeiten, Wiederanläufe und Scheduling explizit - nichts läuft mehr im Verborgenen. Pro Lauf schreiben wir Pipeline-Metadaten mit: Quelle, Zeitraum, Extraktzeitpunkt, Row Counts, Checksummen, Status. DataHub bleibt der sichtbare Governance-Layer. Und zwischen den Layern sitzen Quality Gates - [auf die Schlösser zeigen] -, sodass keine Transformation unkontrolliert von einer Zone in die nächste rutscht. Das gibt uns kontrollierte Übergänge von explorativer Logik hin zu produktiven Pipelines. Bevor Yannik übernimmt, eine Frage, die uns oft gestellt wird: Braucht man dafür nicht riesige Infrastruktur?

---

### Folie 15 - Betriebsmodell: einfach starten, sauber wachsen

**Headline:** Enterprise-grade Lakehouse heißt nicht, dass man am ersten Tag Kubernetes oder einen großen Cloud-Anbieter braucht.

**Inhalt**

* Startpunkt KVWL:
  * drei Red-Hat-Umgebungen: dev, test, prod
  * Podman/systemctl für Containerisierung und Betrieb
  * Betrieb mit sehr kleinem Admin-Footprint
* Ergebnis:
  * Verarbeitung im Terabyte-Maßstab bereits mit einfachem Setup
  * klare Umgebungen, reproduzierbare Container, kontrollierbarer Betrieb
* Weiterentwicklung:
  * inzwischen unternehmensweites Kubernetes vorhanden
  * schrittweiser Umzug ohne großen Architekturbruch dank Containerisierung
* Lesson: so simpel wie möglich starten, technische Reife gezielt ausbauen

**Visual:** Reifegrad-Pfeil von „Podman, 3 VMs" zu „Kubernetes"; darunter Hinweis „gleiche Container, kein Bruch".

**Sprechernotiz (Skript):** [SG] Die klare Antwort ist: nein. Enterprise-grade Lakehouse heißt nicht, dass man am ersten Tag ein Kubernetes-Cluster oder einen großen Cloud-Anbieter braucht. Wir sind bei der KVWL mit drei Red-Hat-Umgebungen gestartet - dev, test, prod -, mit Podman und systemctl für Containerisierung und Betrieb, und das mit einem sehr kleinen Admin-Footprint. Das Ergebnis: Wir verarbeiten bereits mit diesem einfachen Setup Daten im Terabyte-Maßstab, mit klaren Umgebungen und reproduzierbaren Containern. Und die Weiterentwicklung gibt uns recht - inzwischen gibt es ein unternehmensweites Kubernetes, und wir ziehen Schritt für Schritt um, ohne großen Architekturbruch, weil eben alles sauber containerisiert war. Die Lesson, die wir Ihnen mitgeben: so simpel wie möglich starten und die technische Reife gezielt ausbauen. [kurze Pause] Damit steht die Plattform. Und jetzt wird es spannend - Yannik, was lässt sich darauf bauen?

---

## 2. ML am Beispiel Patientenbildung (Patient Record Linkage)

> **Übergabe der Sprecherrolle (Sebastian → Yannik):** Als bewussten Beat inszenieren, nicht nur „und jetzt mein Kollege". Anknüpfen: „Die Plattform steht - jetzt zeigen wir an einem echten Fachproblem, was sie ermöglicht."

### Folie 16 - Was produktives Data Engineering und ML vom Lakehouse brauchen

**Headline:** Der Engpass ist selten der Modellaufruf, sondern reproduzierbare, fachlich verstandene, governancefähige Datenstände.

**Inhalt**

* konsistente Trainings-, Validierungs- und Scoring-Daten
* nachvollziehbare Feature-Definitionen
* stabile Entitäten, z. B. Patient, Praxis, Honorargruppe, Quartal
* Datenqualitätschecks vor Modelltraining
* Daten- und Code-Versionierung
* Auditierbarkeit der Ergebnisse
* Data Catalog und Lineage, damit Teams Daten nicht nur finden, sondern verantwortbar nutzen

**Visual:** Checkliste „Was ML braucht" links, daneben die Zonen-Map - jede Anforderung mit einer Zone verbunden. Brücke vom Architektur- in den ML-Teil.

**Sprechernotiz (Skript):** [YQ] Danke, Sebastian. Die Plattform steht - jetzt zeigen wir an einem echten Fachproblem, was sie ermöglicht. Und ich will direkt an unseren Leitsatz von vorhin anknüpfen: Der Engpass ist selten der Modellaufruf. Was Machine Learning wirklich braucht, ist all das hier - und Sie sehen, jede Anforderung hängt an einer Zone der Architektur, die Sebastian gerade gezeigt hat. Wir brauchen konsistente Trainings-, Validierungs- und Scoring-Daten. Wir brauchen nachvollziehbare Feature-Definitionen. Wir brauchen stabile Entitäten - Patient, Praxis, Honorargruppe, Quartal. Wir brauchen Datenqualitätschecks vor dem Training, Daten- und Code-Versionierung, Auditierbarkeit der Ergebnisse. Und wir brauchen Katalog und Lineage, damit Teams Daten nicht nur finden, sondern verantwortbar nutzen. Genau diese Liste lösen wir jetzt an einem konkreten Beispiel ein - und das stabilste Element ganz oben, „stabile Entitäten", ist unser Einstieg.

---

### Folie 17 - Patientenbildung als Patient Record Linkage

**Headline:** Patientenbildung ist im Kern ein bekanntes Problem aus der Literatur - „Patient Record Linkage" - und verbindet fachlichen Nutzen mit messbarer Validierung.

**Inhalt**

* Patientenbildung = Patient-Record-Linkage-Problem; etablierter Begriff in der Forschung
* Ziel: stabile Patient-Pseudo-IDs als Grundlage für Analysen und nachgelagerte ML-Use-Cases
* Golden Record über Survivorship
* gut messbar über Proxy-/synthetisches Dataset mit Ground Truth (`entity_id`)
* zweites Beispiel später: Anomalieerkennung in Abrechnungsdaten auf derselben Plattform
* gemeinsamer Nenner: Datenqualität vor Modellqualität
* Framing: klassisches ML ist kein Rückschritt, sondern oft der kürzeste Weg zu messbarem Nutzen auf strukturierten Unternehmensdaten

**Visual:** Mehrere Quell-Datensätze mit leicht abweichenden Namen/Schreibweisen fließen zu einer „Person". Zonen-Map als kleine Randmarkierung (Quellen → Raw).

**Sprechernotiz (Skript):** [YQ] Unser Leitbeispiel heißt intern „Patientenbildung". Der entscheidende Schritt war zu erkennen: Das ist kein KVWL-Sonderfall, sondern ein bekanntes Problem aus der Forschung - „Patient Record Linkage". [auf das Visual zeigen] Wir haben dieselbe Person in mehreren Quellen, mit leicht abweichenden Schreibweisen, und wollen sie sicher zu einer Person zusammenführen. Das Ziel sind stabile Patient-Pseudo-IDs - die Grundlage für Analysen und für jeden nachgelagerten ML-Use-Case. Anschließend bauen wir über Survivorship einen Golden Record. Das Schöne daran: Dieses Problem ist messbar - über ein synthetisches Dataset mit echter Ground Truth, einer `entity_id`. Ein zweites Beispiel, Anomalieerkennung in Abrechnungsdaten, zeige ich später kurz auf derselben Plattform. Der gemeinsame Nenner bleibt: Datenqualität vor Modellqualität. Und ein bewusstes Framing: Das hier ist klassisches ML, kein Deep-Learning-Hype - und genau das ist oft der kürzeste Weg zu messbarem Nutzen auf strukturierten Unternehmensdaten. Bevor wir technisch werden, müssen Sie verstehen, warum dieses Problem so heikel ist.

---

### Folie 18 - Patientenbildung: Fachliches Problem und was auf dem Spiel steht

**Headline:** Ein false merge heißt: zwei verschiedene Menschen werden fälschlich verschmolzen und ihre Datenspuren falsch zusammengeführt - das ist der Grund, warum dieses Problem präzise gelöst werden muss.

**Inhalt**

* Ausgangspunkt: bestehender KVWL-Prozess „Patientenbildung"
* Abstraktion: Record Linkage mit nachgelagertem Survivorship - aus einem KVWL-Prozess wird ein bekanntes Forschungsproblem
* Warum die Abstraktion zählt: Literatur, Standardbegriffe, Evaluationsmetriken und typische Trade-offs werden nutzbar
* Heterogene Quellen: ABR1, ABR2, bearbeitete/unbearbeitete Daten, KVUEPP
* Identifikatoren/Attribute: EGK-Versichertennummer, Vorname, Nachname, Geburtsdatum, PLZ
* Herausforderungen: unvollständige Attribute, Schreibvarianten/Tippfehler, fehlende oder wechselnde Identifikatoren, historische Stände und Quartale
* **Stakes:** false merge = verschiedene Personen verschmolzen (falsche Zusammenführung von Personendaten); split = eine Person zerfällt in mehrere Datensätze

**Visual:** Zwei Karteikarten verschiedener Personen, die fälschlich zu einer verschmelzen - rotes Warnsymbol. Diese menschliche Konsequenz ist der emotionale Kern des ML-Teils.

**Sprechernotiz (Skript):** [YQ, langsamer werden] Ich möchte, dass Sie eine Sache wirklich mitnehmen. [auf die verschmelzenden Karteikarten zeigen] Wenn wir zwei Datensätze fälschlich zusammenführen, die zu zwei verschiedenen Menschen gehören - das nennen wir einen false merge -, dann erzeugen wir eine falsche Personenzuordnung in unseren Systemen. Das ist nicht nur eine Zahl in einer Metrik, das ist der kritischste Fehler. Der umgekehrte Fehler, der split, ist, dass eine Person in mehrere Datensätze zerfällt - unschön für Auswertungen, aber deutlich weniger kritisch. [Tempo wieder normal] Diese Asymmetrie ist der Grund, warum wir das Problem präzise lösen müssen. Konkret: Wir haben heterogene Quellen - ABR1, ABR2, bearbeitete und unbearbeitete Daten, KVUEPP. Wir haben Identifikatoren und Attribute: die EGK-Versichertennummer, Vorname, Nachname, Geburtsdatum, PLZ. Und wir haben jede Menge Realität: unvollständige Attribute, Schreibvarianten und Tippfehler, fehlende oder wechselnde Nummern, historische Stände über viele Quartale. Die gute Nachricht: Indem wir das als Record Linkage abstrahieren, können wir auf Literatur, Standardbegriffe und etablierte Evaluationsmetriken zugreifen. Der erste Schritt war aber nicht, etwas Neues zu bauen.

---

### Folie 19 - Das bestehende deterministische Modell verstehen

**Headline:** Der erste Schritt war nicht Modellbau, sondern sauberes Verstehen und Dokumentieren des bestehenden Algorithmus.

**Inhalt**

* Stored Procedure `M20_HIS_P_01AB000_PATIENTENBILDUNG`
* sequentielle Matching-Kaskade (kanonische Regeln, kehren als Baseline auf Folie 25 wieder):
  * EGK + Geburtsdatum
  * EGK + Vorname + Nachname
  * Vorname + Nachname + Geburtsdatum + PLZ
* bereits gematchte Records werden in späteren Phasen nicht erneut bewertet
* neue Patientencluster über transitive Closure
* Lookup-Tabelle speichert neue Attributkombinationen für zukünftige Läufe
* Ergebnis der Analyse: Stärken sichtbar, Grenzen präzise benennbar, Vergleich mit wissenschaftlichen Ansätzen möglich

**Visual:** Kaskade als Treppen-/Flussdiagramm (Regel 1 → 2 → 3), rechts ein Cluster-Graph mit transitiver Verknüpfung. Diese Regeldarstellung ist die einzige vollständige im Deck.

**Sprechernotiz (Skript):** [YQ] Der erste Schritt war also nicht Modellbau, sondern Verstehen. Es gab bereits einen Prozess - eine Stored Procedure mit dem schönen Namen `M20_HIS_P_01AB000_PATIENTENBILDUNG`. [auf die Treppe zeigen] Im Kern ist das eine sequentielle Matching-Kaskade mit drei Regeln: Erst EGK plus Geburtsdatum. Dann EGK plus Vor- und Nachname. Und schließlich Vorname, Nachname, Geburtsdatum und PLZ. Wer einmal gematcht ist, wird in späteren Phasen nicht erneut bewertet. Neue Patientencluster entstehen über transitive Closure - wenn A zu B passt und B zu C, dann gehören alle drei zusammen. Und eine Lookup-Tabelle merkt sich neue Attributkombinationen für künftige Läufe. Diese drei Regeln sind wichtig, merken Sie sie sich kurz - sie kommen gleich als unsere Baseline zurück. Indem wir den bestehenden Prozess sauber dokumentiert haben, wurden seine Stärken sichtbar, aber auch seine Grenzen präzise benennbar - und damit der Vergleich mit wissenschaftlichen Ansätzen überhaupt erst möglich. Wie wir bei diesem Vergleich vorgegangen sind, zeige ich jetzt.

---

### Folie 20 - Recherche- und Evaluationsvorgehen

**Headline:** Ausführliche Recherche lohnt sich, bevor man einen produktiven Fachprozess durch ML ersetzt oder ergänzt.

**Inhalt**

* Vorgehen: Prozess + SQL verstehen → als Record Linkage abstrahieren → State-of-the-Art recherchieren → mehrere Verfahren implementieren und gegen den Bestand evaluieren
* betrachtete Ansätze: bestehende deterministische Kaskade, Hybrid Cascade mit fuzzy Fallbacks, probabilistisches FlexRL aus der Literatur
* Evaluationsfokus: Precision und false merges, Recall und split entities, F1, Clusterqualität, Laufzeit, Erklärbarkeit
* Lesson: Naming früh an Community Standards ausrichten - dann sieht man schneller, was bereits gut erforscht ist

**Visual:** Vorgehens-Pfeil in vier Schritten; rechts drei „Verdächtige" (Ansatz 1/2/3) als Teaser für die kommende Detektivgeschichte.

**Sprechernotiz (Skript):** [YQ] Unser Vorgehen war bewusst gründlich, bevor wir einen produktiven Fachprozess anfassen. Vier Schritte: erst Prozess und SQL verstehen, dann das Problem als Record Linkage abstrahieren, dann den State-of-the-Art recherchieren, und schließlich mehrere Verfahren implementieren und gegen den Bestand evaluieren. [auf die drei „Verdächtigen" zeigen] Drei Ansätze treten gleich gegeneinander an: unsere bestehende deterministische Kaskade als Titelverteidiger, eine Hybrid Cascade mit Fuzzy-Fallbacks, und ein probabilistisches Modell aus der Literatur namens FlexRL. Bewertet haben wir nicht nur nach einer Zahl, sondern nach Precision und false merges, Recall und split entities, F1, Clusterqualität, Laufzeit und Erklärbarkeit. Eine Lesson schon hier: Wer sein Problem früh auf die Begriffe der Community ausrichtet, sieht viel schneller, was bereits gut erforscht ist. Aber bevor wir vergleichen können, brauchen wir etwas, das überraschend schwierig ist: Wahrheit.

---

### Folie 21 - Proxy-Dataset: Warum überhaupt synthetische Daten?

**Headline:** Für Record Linkage braucht man Ground Truth - die existiert in Echtdaten oft nicht und darf aus Datenschutzgründen nicht geteilt werden.

**Inhalt**

* Echtdaten enthalten keinen perfekten, unabhängigen Wahrheitsdatensatz für alle Links
* Datenschutz: Patientendaten nicht als Entwicklungs-/Benchmark-Dataset frei nutzbar
* Proxy-Dataset ermöglicht: kontrollierte Ground Truth über `entity_id`, realistische Fehler/Dubletten/Lücken/historische Varianten, wiederholbare Evaluation, vergleichbare Metriken für Current Model, Hybrid Cascade und FlexRL
* **Lakehouse-Enabler:** das synthetische Testset ist selbst ein versioniertes, reproduzierbares Datenprodukt in der Plattform

**Visual:** Echtdaten (Schloss-Symbol, „nicht teilbar") → Aggregat-Statistiken → generiertes Proxy-Dataset mit sichtbarem `entity_id`-Label als Ground Truth.

**Sprechernotiz (Skript):** [YQ] Um zu messen, welcher Ansatz besser ist, brauche ich die Wahrheit - ich muss wissen, welche Records wirklich zur selben Person gehören. Und genau die habe ich in den Echtdaten nicht: Es gibt keinen perfekten, unabhängigen Wahrheitsdatensatz für alle Verknüpfungen. Dazu kommt der Datenschutz - echte Patientendaten kann ich nicht als Entwicklungs- oder Benchmark-Dataset frei verwenden. Die Lösung ist ein synthetisches Proxy-Dataset. [auf den Ablauf zeigen] Das gibt mir kontrollierte Ground Truth über eine `entity_id`, dazu realistische Fehler, Dubletten, Lücken und historische Varianten - und damit eine wiederholbare, vergleichbare Evaluation für alle drei Ansätze. Und jetzt der Bezug zu unserem Leitsatz: Dieses Testset ist selbst ein versioniertes, reproduzierbares Datenprodukt in der Plattform. Ohne die Plattform-Disziplin - Versionierung, klare Datenprodukte - wäre mein Benchmark nicht reproduzierbar. Genau das meinen wir mit „die Plattform ist der Enabler". Wie dieses Dataset entsteht, ohne dass es frei erfunden ist, zeige ich kurz.

---

### Folie 22 - Proxy-Dataset: Wie es erzeugt wurde

**Headline:** Das Proxy-Dataset ist nicht frei erfunden, sondern aus aggregierten, privacy-preserving Statistiken realer Daten abgeleitet.

**Inhalt**

* Analyse realer Daten nur aggregiert: k-Anonymität `k >= 100`, gebinnte Verteilungen, gerundete Counts, keine individuellen Datensätze
* extrahierte Verteilungen: Vor-/Nachnamen, Namenslängen und Zeichenmuster, KVNR-/EGK-Muster, PLZ-Regionen, Geburtsjahr-Bins/Monat/Tag, Geschlecht, VSDM-Verifikation, Fehlerprofile
* Generator erzeugt: mehrere Records pro Entität, Typo- und Missing-Value-Muster, Adressänderungen über Quartale, Golden Records für Survivorship

**Visual:** Pipeline „Aggregat-Statistiken → Generator → synthetische Records"; Beispieltabelle mit absichtlich eingestreuten Tippfehlern und fehlenden Werten.

**Sprechernotiz (Skript):** [YQ] Wichtig ist mir: Die Daten sind synthetisch, aber nicht aus der Luft gegriffen. Wir haben die echten Daten ausschließlich aggregiert analysiert - mit k-Anonymität von mindestens 100, gebinnten Verteilungen, gerundeten Counts, und niemals einzelne Datensätze ausgegeben. Aus diesen Aggregaten haben wir Verteilungen extrahiert: Vor- und Nachnamen, Namenslängen und Zeichenmuster, die Muster der Versichertennummern, PLZ-Regionen, Geburtsjahr, Monat und Tag, Geschlecht, die VSDM-Verifikation und typische Fehlerprofile. Der Generator baut daraus dann mehrere Records pro Person - mit realistischen Tippfehlern, fehlenden Werten, Adressänderungen über Quartale hinweg. Und er erzeugt gleich die Golden Records mit, damit wir später auch das Survivorship messen können. So bekommen wir realistische Daten mit bekannter Wahrheit. Damit ist die Bühne bereit - aber vorher müssen wir uns einigen, woran wir „besser" eigentlich festmachen.

---

### Folie 23 - Validierungsdesign

**Headline:** Die Proxy-Daten machen aus einer fachlichen Diskussion eine messbare Engineering-Frage.

**Inhalt**

* Ground Truth: `entity_id` für wahre Personencluster, Golden-Record-Felder für Survivorship
* besonders wichtig bei Patientendaten: false merges sind fachlich riskanter als false negatives - Schwellen konservativ wählen und begründen
* Fehleranalyse: Export von false positives und false negatives, qualitative Prüfung typischer Fehlermuster

**Visual:** Schema „Vorhersage vs. Ground Truth" mit den vier Quadranten (TP/FP/FN/TN); FP rot hervorgehoben (Bezug zu den Stakes von Folie 18).

**Sprechernotiz (Skript):** [YQ] Genau das leisten die Proxy-Daten: Sie machen aus einer fachlichen Diskussion - „welcher Ansatz ist besser?" - eine messbare Engineering-Frage. Als Ground Truth haben wir die `entity_id` für die wahren Personencluster und die Golden-Record-Felder für das Survivorship. [auf den rot markierten Quadranten zeigen] Und hier sehen Sie die Stakes von eben wieder: Der false positive, der false merge, ist rot - er ist bei Patientendaten fachlich riskanter als ein verpasster Match. Das heißt für uns: Schwellen konservativ wählen und diese Wahl begründen. Und wir lassen es nicht bei Zahlen - wir exportieren false positives und false negatives und schauen sie uns qualitativ an, um typische Fehlermuster zu verstehen. Für alle, die nicht täglich mit Record Linkage zu tun haben, lohnt sich an dieser Stelle ein kurzer Exkurs, was diese Metriken eigentlich bedeuten.

---

### Folie 24 - Exkurs: Evaluationsmetriken für Record Linkage

**Headline:** Record Linkage wird paarweise bewertet - Precision, Recall und F1 auf Record-Paaren erlauben einen fairen Vergleich aller Ansätze.

**Inhalt**

* Grundidee: jedes Paar von Records ist entweder „gleiche Person" (Link) oder nicht
* Begriffe: True Positive (korrekt verknüpft), False Positive (= false merge), False Negative (übersehener Link = split)
* Precision = TP / (TP + FP) - misst false merges
* Recall = TP / (TP + FN) - misst split entities
* F1 = harmonisches Mittel aus Precision und Recall
* Clusterebene: perfect / split / merged clusters als anschauliche Ergänzung
* bei Patientendaten: Precision (false merges) ist besonders kritisch → konservative Schwellen

**Visual:** Konfusionsmatrix + zwei kompakte Formeln (Precision, Recall); Mini-Beispiel mit ein paar Paaren. Bewusst didaktisch für DWH-/BI-Publikum ohne ML-Hintergrund.

**Sprechernotiz (Skript):** [YQ] Ganz kurz und konkret, damit gleich alle die Zahlen lesen können. Die Grundidee: Wir betrachten jedes Paar von Records und fragen - gleiche Person oder nicht? Daraus ergeben sich drei Fälle. Ein True Positive ist ein korrekt verknüpftes Paar. Ein False Positive ist ein false merge - zwei verschiedene Personen fälschlich verbunden. Ein False Negative ist ein übersehener Link - ein split. Daraus zwei Kennzahlen: Precision ist der Anteil korrekter unter den von uns vorhergesagten Links - sie misst also unsere false merges. Recall ist der Anteil gefundener unter den echten Links - sie misst die splits. F1 ist einfach das harmonische Mittel aus beiden. Ergänzend schauen wir auf Clusterebene - perfekte, gesplittete, verschmolzene Cluster. Und merken Sie sich für die nächsten Folien: Bei Patientendaten ist die Precision die kritische Größe, weil sie die gefährlichen false merges abbildet. Mit diesem Rüstzeug schauen wir uns die drei Ansätze an - und starten mit dem amtierenden Modell.

---

### Folie 25 - Ansatz 1: Aktuelles deterministisches Modell (Baseline)

**Headline:** Das bestehende Modell ist ein starker, konservativer Baseline-Ansatz - aber es verliert viele echte Links.

**Inhalt**

* aus bestehender SQL-Logik als validierbare Python-Variante implementiert
* deterministische Kaskade (Regeln siehe Folie 19): EGK + DOB, EGK + Name, Name + DOB + PLZ; transitive Closure
* Ergebnis auf Proxy-Dataset:
  * Precision: 100,00 %
  * Recall: 69,35 %
  * F1: 81,90 %
* Interpretation: praktisch keine false merges, aber viele split entities; guter Safety-Baseline für alle Alternativen

**Visual:** Zonen-Map mit Markierung auf Process („Patientenbildung läuft hier"). Ergebnis als erste Säule eines Balkendiagramms, das auf Folie 28 vervollständigt wird.

**Sprechernotiz (Skript):** [YQ] Ansatz eins ist unser bestehendes Modell. [auf die Zonen-Map zeigen] Kurz zur Orientierung: Wir sind jetzt in der Process Zone - hier läuft die Patientenbildung. Wir haben die SQL-Logik als validierbare Python-Variante nachgebaut, die deterministische Kaskade mit den drei Regeln von eben. Und das Ergebnis auf dem Proxy-Dataset ist bemerkenswert: Precision 100 Prozent. Kein einziger false merge. Aber - und das ist die Kehrseite - der Recall liegt nur bei 69 Prozent, der F1 bei knapp 82. Das heißt: Das Modell ist extrem sicher, macht praktisch keine gefährlichen Fehler, aber es verliert fast ein Drittel der echten Verknüpfungen in splits. Ein sehr guter, konservativer Safety-Baseline - aber mit Luft nach oben. [Enabler-Callback] Übrigens: Dass ich alle drei Ansätze gleich gegen exakt denselben Datenstand teste, ermöglicht erst die unveränderliche Raw-Historie, die Sebastian gezeigt hat. Können wir mehr Links finden, ohne diese perfekte Precision zu opfern? Das war die Frage für Ansatz zwei.

---

### Folie 26 - Ansatz 2: Hybrid Cascade

**Headline:** Ein deterministisch dominierter Ansatz findet durch fuzzy Fallbacks deutlich mehr echte Links, ohne die Precision stark zu beschädigen.

**Inhalt**

* Designprinzipien: exakte Matches zuerst, fuzzy nur als Fallback, adaptive Blocking-Grenzen gegen O(N²), hybride Ähnlichkeit (Edit Distance für kurze, Q-Gram/Jaccard für längere Namen)
* Kaskadenlevel: EGK exact → Name + DOB exact → Name fuzzy + DOB exact → EGK + Nachname → Name fuzzy + PLZ + Geburtsjahr
* Ergebnis:
  * Precision: 99,91 %
  * Recall: 81,95 %
  * F1: 90,04 %
  * Recall ggü. Baseline: +12,60 Prozentpunkte
* Quellen/Grundlagen: eigene Kombination etablierter Bausteine - Fellegi & Sunter (1969) für die Linkage-Grundlogik, Christen, *Data Matching* (2012) für Blocking und String-Ähnlichkeit

**Visual:** Zonen-Map mit Markierung auf Process. Kaskade als Treppe; zweite Säule im Vergleichs-Balkendiagramm, Recall-Zuwachs als Pfeil nach oben.

**Sprechernotiz (Skript):** [YQ] Ansatz zwei nennen wir Hybrid Cascade. Die Idee: exakte Matches zuerst, so wie bisher - aber dort, wo das Modell vorher aufgegeben hat, ein fuzzy Fallback. Damit fangen wir Tippfehler und Schreibvarianten ab. Methodisch ist das eine Kombination etablierter Bausteine - die klassische Linkage-Grundlogik von Fellegi und Sunter aus 1969 und, für Blocking und String-Ähnlichkeit, Christens Standardwerk „Data Matching". Konkret: Wir nutzen Edit Distance für kurze Namen und Q-Gram-Jaccard für längere, und adaptive Blocking-Grenzen, damit uns die Paarvergleiche nicht explodieren. Die Kaskade hat jetzt fünf Stufen, von EGK exakt bis hin zu fuzzy Name plus PLZ plus Geburtsjahr. [auf den Pfeil nach oben zeigen] Und das Ergebnis: Der Recall springt von 69 auf fast 82 Prozent - plus zwölfeinhalb Prozentpunkte. Und die Precision? Bleibt bei 99,91 Prozent - praktisch unverändert. Wir finden also deutlich mehr echte Links und bezahlen kaum etwas dafür. Geht es noch besser - mit einem grundlegend anderen Ansatz?

---

### Folie 27 - Ansatz 3: FlexRL als probabilistischer Ansatz

**Headline:** Probabilistische Linkage macht Unsicherheit explizit und lernt Fehler- und Zufallsmuster aus den Daten.

**Inhalt**

* FlexRL als latent-variable model
* Partially Identifying Variables: Vorname, Nachname, Geburtsdatum, PLZ, EGK
* EM-Algorithmus lernt: Link-Wahrscheinlichkeit, Fehlerwahrscheinlichkeit je Variable, zufällige Übereinstimmungswahrscheinlichkeit je Variable
* Blocking über EGK, DOB, PLZ + Geburtsjahr, Namenspräfix
* konservativer Threshold `0,9`, weil false merges bei Patientendaten besonders kritisch sind
* Quelle: Robach et al. (2024), *A Flexible Model for Record Linkage* (arXiv); Implementierung: [github.com/robachowyk/FlexRL](https://github.com/robachowyk/FlexRL)

**Visual:** Zonen-Map mit Markierung auf Process. Schematische Verteilung „Link vs. Non-Link" mit Threshold-Linie bei 0,9; dritte Säule im Vergleichsdiagramm.

**Sprechernotiz (Skript):** [YQ] Ansatz drei ist methodisch der spannendste: FlexRL, ein probabilistisches Modell aus einem Paper von Robach und Kollegen aus 2024. Statt fester Regeln macht es Unsicherheit explizit. Vereinfacht gesagt: Es betrachtet unsere Attribute - Vorname, Nachname, Geburtsdatum, PLZ, EGK - als teilweise identifizierende Variablen und lernt mit einem EM-Algorithmus aus den Daten selbst drei Dinge: wie wahrscheinlich ein Paar überhaupt ein Link ist, wie fehleranfällig jede einzelne Variable ist, und wie oft sie rein zufällig übereinstimmt. [optional kürzen, falls Zeit knapp: einfach sagen „es lernt Wahrscheinlichkeiten, statt feste Schwellen zu setzen" und weiter] Ein Beispiel: Ein Geburtsdatum stimmt auch mal zufällig überein, eine Versichertennummer fast nie - genau das lernt das Modell. Wir setzen einen bewusst konservativen Schwellenwert von 0,9, weil uns false merges bei Patientendaten besonders wehtun. Wie schlägt sich dieser dritte Ansatz im direkten Vergleich? Das ist der Moment, auf den alles zugelaufen ist.

---

### Folie 28 - Ergebnisvergleich: Trade-off statt Modellhype (Climax)

**Headline:** Mehr echte Patienten korrekt verknüpft - praktisch ohne neue Fehlverschmelzungen.

**Inhalt**

* Current Model: Precision 100,00 % · Recall 69,35 % · F1 81,90 %
* Hybrid Cascade: Precision 99,91 % · Recall 81,95 % · F1 90,04 %
* FlexRL (Threshold 0,9): Precision 99,89 % · Recall 92,11 % · F1 95,85 %
* Kernbeobachtung: Recall steigt von 69 % auf 92 %, während die Precision nahezu bei 100 % bleibt
* fachliche Entscheidung: Ist der Recall-Gewinn die wenigen false merges wert? Welche Fälle gehen ins manuelle Review? Welche Schwelle ist produktiv vertretbar?

**Visual:** Gruppiertes Balkendiagramm Precision/Recall/F1 über die drei Ansätze - der Recall-Balken wächst sichtbar, der Precision-Balken bleibt fast voll. Das ist der visuelle Höhepunkt; ihm volle Folienfläche geben.

**Sprechernotiz (Skript):** [YQ, das ist der Höhepunkt - Tempo rausnehmen] Hier ist das Gesamtbild. [auf die Balken zeigen] Schauen Sie auf die Precision-Balken - alle drei stehen quasi bei 100 Prozent: 100, 99,91, 99,89. Der gefährliche Fehler bleibt über alle Ansätze hinweg praktisch ausgeschlossen. Und jetzt der Recall: 69 Prozent beim bestehenden Modell, 82 bei der Hybrid Cascade, und 92 Prozent bei FlexRL. [Pause] Lassen Sie das kurz wirken. Wir verknüpfen deutlich mehr echte Patienten korrekt zusammen - der Recall steigt um über zwanzig Prozentpunkte - und das praktisch ohne neue Fehlverschmelzungen. Der F1 geht von 82 auf fast 96. Aber - und das ist die eigentliche Botschaft - die Entscheidung ist trotzdem keine rein technische. Sie ist fachlich: Sind uns die wenigen zusätzlichen false merges den großen Recall-Gewinn wert? Welche unsicheren Fälle schicken wir ins manuelle Review? Welche Schwelle ist im Produktivbetrieb vertretbar? Nicht der komplexeste Ansatz gewinnt automatisch, sondern der mit dem fachlich akzeptablen Trade-off. Doch eine gefundene Verknüpfung allein reicht noch nicht.

---

### Folie 29 - Survivorship: Vom Cluster zum Golden Record

**Headline:** Record Linkage löst nur die Identität - nutzbar wird das Ergebnis erst durch konsolidierte Patientenstammdaten.

**Inhalt**

* Survivorship `M20_HIS_P_01AB000_BUILD_PATIENTEN_STAMM`
* VSDM = Versichertenstammdatenmanagement: beim Einlesen der eGK wird online gegen das zentrale Versichertenregister geprüft, ob die Kartendaten mit dem maßgeblichen Register übereinstimmen → bestätigter Abgleich = vertrauenswürdigste Quelle
* Two-tier-Strategie: Tier 1 = VSDM-verifizierte Daten mit höchstem Vertrauen; Tier 2 = zeitgewichtete Häufigkeit plus Vollständigkeit
* zusätzliche Normalisierung: PLZ-/Ortsnormalisierung, Umlautnormalisierung, OKZ-/Regionen-Anreicherung
* Proxy-Dataset enthält Golden Records, damit auch Survivorship messbar wird
* Ergebnis: ein konsolidierter Patientenstamm pro Patient-Pseudo-ID

**Visual:** Zonen-Map mit Markierung auf Access. Cluster mehrerer Records → ein Golden Record; Tier-1/Tier-2-Auswahl als zweistufiger Filter mit VSDM-Badge.

**Sprechernotiz (Skript):** [YQ] Record Linkage sagt uns nur: Diese Records gehören zur selben Person. Aber welche Adresse, welche Schreibweise des Namens ist jetzt die richtige? Das löst das Survivorship - und damit wandern wir in der Architektur eine Zone weiter, in die Access Zone. [auf die Zonen-Map zeigen] Wir bauen pro Person einen konsolidierten Patientenstamm, einen Golden Record. Dafür nutzen wir eine zweistufige Strategie. Tier 1 stützt sich auf VSDM-verifizierte Daten. Kurz erklärt, weil die Abkürzung nicht jedem geläufig ist: VSDM steht für Versichertenstammdatenmanagement. Wenn die elektronische Gesundheitskarte beim Arzt eingelesen wird, prüft das System online gegen das zentrale Versichertenregister, ob die Kartendaten korrekt sind. Dieser bestätigte Abgleich ist unsere vertrauenswürdigste Quelle. Wo es keine VSDM-Bestätigung gibt, kommt Tier 2 - eine zeitgewichtete Häufigkeit kombiniert mit Vollständigkeit. Dazu normalisieren wir PLZ und Ort, Umlaute, und reichern Regionen an. Und weil unser Proxy-Dataset die echten Golden Records mitbringt, können wir sogar diesen Survivorship-Schritt messen. Das Ergebnis: ein sauberer Patientenstamm pro Pseudo-ID. So weit die Evaluation - aber ein Notebook ist noch keine Produktion.

---

### Folie 30 - Vom Notebook in die Lakehouse-Pipeline

**Headline:** Der Use Case zeigt den Weg von akademischer Evaluation zu produktionsnaher Data-Engineering-Arbeit.

**Inhalt**

* explorative Phase: Prozess verstehen, Proxy-Dataset erzeugen, Ansätze evaluieren, Fehlermuster analysieren
* Produktionspfad entlang der Zonen: Raw (historisierte Quellvarianten) → Process (Standardisierung + Patientenbildung) → Access (konsolidierter Patientenstamm und Datenprodukte)
* **Lakehouse-Enabler:** reproduzierbare Laufparameter, versionierte Schwellen und Algorithmusversionen, Qualitätsmetriken je Lauf, Monitoring von Split-/Merge-Risiken

**Visual:** Vollständige Zonen-Map, der gesamte Patientenbildungs-Pfad als durchgehende Linie von Raw bis Access hervorgehoben - die Zusammenführung des Leitmotivs.

**Sprechernotiz (Skript):** [YQ] Und hier schließt sich der Kreis zur Architektur. [auf die durchgehende Linie zeigen] Was als Exploration im Notebook begann - Prozess verstehen, Proxy-Dataset bauen, Ansätze evaluieren, Fehler analysieren -, wandert jetzt als produktiver Pfad durch genau die Zonen, die Sebastian zu Beginn gezeigt hat: In Raw liegen die historisierten Quellvarianten. In Process passiert Standardisierung und die eigentliche Patientenbildung. Und in Access entsteht der konsolidierte Patientenstamm als konsumierbares Datenprodukt. Und jetzt sehen Sie, was die Plattform liefert, das ein Notebook allein nie könnte: reproduzierbare Laufparameter, versionierte Schwellen und Algorithmusversionen, Qualitätsmetriken bei jedem Lauf, und ein Monitoring der Split- und Merge-Risiken. Das ist unser Leitsatz in Aktion - die Plattform macht aus einem klugen Modell einen verantwortbaren, wiederholbaren Prozess. So viel zu unserem Leitbeispiel. Wir haben aber noch ein zweites - und das erzählt eine andere, ebenso lehrreiche Geschichte.

---

### Folie 31 - Brücke: zweites Beispiel Abrechnungsanomalien

**Headline:** Gleiche Plattform, andere Reifestufe - und genau daran zeigt sich, warum Validierbarkeit über die Auswahl entscheidet.

**Inhalt**

* zweiter ML-Anwendungsfall auf derselben Architektur: Anomalieerkennung in Abrechnungsdaten
* Bausteine: Feature Engineering, ECOD als Anomaliemodell, Explainability, Review-App
* gute Demonstration der Pipeline von Process über Access bis zu einer ML-Anwendung mit Review-Oberfläche
* Unterschied zur Patientenbildung: noch kein automatisiertes Ground-Truth-/Proxy-Dataset, fachliche Validierung der Treffer läuft noch; genau deshalb ist es das nächste Projekt und noch nicht die tragende Hauptstory
* leitet die Lesson ein: Validierbarkeit entscheidet, wann aus einem Prototyp eine tragende Story wird

**Visual:** Zwei Beispiel-Kacheln nebeneinander auf derselben Zonen-Map: „Patientenbildung - validiert" (grün, mit kleinem Hinweis „KI-/Ethik-Prüfung ausstehend" unten rechts im weißen Kartenbereich) vs. „Abrechnungsanomalien - nächstes Projekt" (gelb).

**Sprechernotiz (Skript):** [YQ, bewusst zügig - nur ein kurzer Beat] Ganz kurz, weil es eine wichtige Pointe hat: Wir haben auf derselben Plattform einen zweiten ML-Use-Case gebaut - Anomalieerkennung in Abrechnungsdaten. Technisch alles dran: Feature Engineering, ein Anomaliemodell namens ECOD, Explainability und sogar eine Review-App. Als Demonstration der Pipeline von Process bis zur fertigen ML-Anwendung ist das richtig schön. [auf die gelbe Kachel zeigen] Der Unterschied zur Patientenbildung ist aber entscheidend: Hier haben wir noch kein automatisiertes Ground-Truth-Dataset, die fachliche Validierung der Treffer läuft noch, und genau das macht es zum nächsten Projekt statt zur heutigen Hauptstory. Deshalb steht die Patientenbildung im Mittelpunkt und dieser Fall zeigt, was als Nächstes validierbar gemacht werden muss. Und das führt uns direkt zu unserer wichtigsten Lesson: Validierbarkeit entscheidet, wann aus einem interessanten Prototyp eine tragende Story wird. Damit zu dem, was wir insgesamt gelernt haben.

---

## 3. Lessons Learned und Abschluss

### Folie 32 - Architektur-Lessons

**Headline:** Die wichtigsten Architekturentscheidungen sind die klaren Layer-Verträge, nicht die Toolnamen.

**Inhalt**

* Raw muss wirklich raw bleiben, sonst wird Reprocessing schwach
* Process braucht technische Qualitätsgarantien
* Access braucht fachliche Semantik und konsumierbare Datenprodukte
* PySpark und dbt ergänzen sich, wenn ihre Rollen klar sind
* einfaches Betriebsmodell reicht für den Start, wenn Containerisierung und Umgebungen sauber geschnitten sind
* Kubernetes kann später kommen; gute Containerisierung macht die Migration beherrschbar

**Visual:** Zonen-Map ein letztes Mal, jede Zone mit ihrem „Vertrag" als Stempel. Schließt den visuellen Bogen.

**Sprechernotiz (Skript):** [SG] Lassen Sie uns das Gelernte verdichten, erst auf der Architekturseite. Die wichtigste Erkenntnis: Entscheidend sind nicht die Toolnamen, sondern die klaren Verträge zwischen den Layern. [auf die Zonen-Map zeigen] Raw muss wirklich raw bleiben - in dem Moment, wo Sie dort Fachlogik einschmuggeln, wird Reprocessing schwach, und genau das hat uns Yanniks Benchmark erst ermöglicht. Process braucht technische Qualitätsgarantien. Access braucht fachliche Semantik und echte Datenprodukte. PySpark und dbt ergänzen sich hervorragend - aber nur, wenn ihre Rollen klar getrennt sind. Und der Betrieb: Ein einfaches Modell reicht für den Start völlig, solange Containerisierung und Umgebungen sauber geschnitten sind. Kubernetes kann später kommen. Yannik, deine Seite.

---

### Folie 33 - KI-/ML-Lessons

**Headline:** Produktive KI beginnt vor dem Modell: bei Entitäten, Features, Historie, Governance und fachlicher Prüfbarkeit.

**Inhalt**

* stabile Entitäten sind zentrale ML-Infrastruktur
* Patientenbildung zeigt: false merges sind oft kritischer als false negatives
* Fachprozesse früh auf Community-Begriffe mappen: „Patientenbildung" → Record Linkage, anschlussfähig an Forschung und Standards
* Recherche vor Implementierung spart Umwege, weil bekannte Problemklassen oft schon gute Lösungs- und Evaluationsmuster haben
* Prototypen brauchen eine klare Validierungsstrategie, bevor sie zur Hauptstory werden
* Explainability ist kein Add-on, sondern Teil des Produktdesigns
* Modellmetriken reichen nicht; fachliche Validierung ist entscheidend
* systematische KI-Einführung: konkrete Fachprozesse verbessern, Feedback aufnehmen, erst dann skalieren

**Visual:** Sieben Lesson-Karten; die zwei wichtigsten („false merges kritischer", „Validierbarkeit vor Hauptstory") visuell hervorgehoben.

**Sprechernotiz (Skript):** [YQ] Und auf der KI-Seite. Die Kernlesson deckt sich genau mit unserem Leitsatz: Produktive KI beginnt vor dem Modell - bei Entitäten, Features, Historie, Governance und fachlicher Prüfbarkeit. Stabile Entitäten sind nicht nur Stammdaten, sie sind zentrale ML-Infrastruktur. Die Patientenbildung hat uns gelehrt, dass nicht alle Fehler gleich sind - false merges sind oft kritischer als verpasste Matches, und das muss man bewusst in die Schwellen einbauen. Es hat sich extrem gelohnt, den Fachprozess früh auf Community-Begriffe zu mappen - aus „Patientenbildung" wurde Record Linkage und damit anschlussfähig an Forschung und Standards. Recherche vor der Implementierung spart Umwege. Explainability ist kein Add-on, sondern Teil des Produktdesigns. Modellmetriken allein reichen nicht - die fachliche Validierung entscheidet. Und genau deshalb sind die Abrechnungsanomalien das nächste Projekt: Ein Prototyp braucht eine klare Validierungsstrategie, bevor er zur Hauptstory wird. Was davon würden wir wieder so machen?

---

### Folie 34 - Was wir wieder so machen würden

**Headline:** Einige Muster haben sich als besonders tragfähig erwiesen.

**Inhalt**

* offene Formate und On-Premise-Open-Source-Stack
* Delta-Tabellen für robuste Pipelines
* Airflow-DAGs mit expliziten Abhängigkeiten und Metadaten
* DataHub früh als Katalog- und Governance-Komponente etablieren
* Feature Datasets als Datenprodukte denken
* schnelle Prototypen, aber klarer Pfad in produktive Pipelines
* Review- und Feedback-Oberflächen früh mitdenken

**Visual:** Grüne „Daumen hoch"-Liste; Gegenstück zu Folie 35.

**Sprechernotiz (Skript):** [SG] Ganz pragmatisch - das hier würden wir sofort wieder so machen. Offene Formate und einen On-Premise-Open-Source-Stack, das hat uns Unabhängigkeit und volle Kontrolle gegeben. Delta-Tabellen für robuste Pipelines. Airflow-DAGs mit expliziten Abhängigkeiten und Metadaten. [YQ] Und aus der ML-Sicht: DataHub früh als Katalog- und Governance-Komponente etablieren, nicht erst nachträglich. Feature-Datasets konsequent als Datenprodukte denken. Schnelle Prototypen erlauben - aber immer mit einem klaren Pfad in produktive Pipelines. Und Review- und Feedback-Oberflächen früh mitdenken, nicht am Ende drangeschraubt. Genauso ehrlich ist die andere Seite.

---

### Folie 35 - Was man vermeiden sollte

**Headline:** Lakehouse-Projekte scheitern leicht an zu viel impliziter Logik und zu wenig Produktdenken.

**Inhalt**

* Layer ohne klare Verträge
* Landing-Zonen als dauerhaftes Schattenarchiv
* Notebook-Logik ohne Operationalisierungspfad
* Datenprodukte ohne fachliche Semantik
* ML ohne Datenqualitätsstrategie
* KI-Initiativen, die mit einem großen Chatbot starten, bevor Datenqualität, Ownership und Lineage geklärt sind
* Scores ohne Erklärbarkeit und ohne fachlichen Review-Prozess
* Toolfokus statt Architekturprinzipien

**Visual:** Rote „Anti-Pattern"-Liste, gespiegeltes Layout zu Folie 34.

**Sprechernotiz (Skript):** [SG] Und die Anti-Patterns - das, was wir gesehen haben und was wir Ihnen ersparen wollen. Layer ohne klare Verträge - das war unser Ausgangsproblem. Landing-Zonen, die heimlich zum Dauerarchiv werden. [YQ] Notebook-Logik ohne Pfad in die Produktion. Datenprodukte ohne fachliche Semantik. ML ohne Datenqualitätsstrategie. KI-Initiativen, die mit einem großen Chatbot starten, bevor Datenqualität, Ownership und Lineage überhaupt geklärt sind - das ist genau die Reihenfolge, vor der wir am Anfang gewarnt haben. Scores ohne Erklärbarkeit und ohne fachlichen Review. Und der Klassiker: Toolfokus statt Architekturprinzipien. Damit sind wir am Ende - und kommen zurück zum Anfang.

---

### Folie 36 - Schlussbild und Q&A

**Headline:** Das Lakehouse ist kein Selbstzweck, sondern die Plattform, auf der Data Engineering, Governance und KI/ML produktiv zusammenarbeiten.

**Inhalt**

* eine Plattform von Rohdaten bis ML-Anwendung
* reproduzierbare Datenstände statt Ad-hoc-Extrakte
* klare Verantwortlichkeiten statt gewachsener Zonenlogik
* Datenqualität als Voraussetzung für Modellqualität
* systematische KI-Einführung über konkrete, validierbare Use Cases statt abstrakter Technologieprogramme
* durchgängiges Beispiel: Patientenbildung als Patient Record Linkage; Abrechnungsanomalien als nächstes Projekt auf derselben Plattform
* **Abschluss (ein Satz):** Der Engpass für KI im Gesundheitswesen ist nicht das Modell, sondern eine Plattform, die reproduzierbare, validierbare Datenstände liefert - gezeigt an einem Problem, das man messen kann.

**Visual:** Vollständige Zonen-Map mit dem hervorgehobenen Patientenbildungs-Pfad als Schlussbild; der Leitsatz groß darunter. Liste oben, der eine Satz zuletzt und allein.

**Sprechernotiz (Skript):** [YQ] Fassen wir zusammen. Wir haben Ihnen eine Plattform gezeigt, die von den Rohdaten bis zur ML-Anwendung trägt - mit reproduzierbaren Datenständen statt Ad-hoc-Extrakten, mit klaren Verantwortlichkeiten statt gewachsener Zonenlogik, und mit Datenqualität als Voraussetzung für Modellqualität. Wir haben KI nicht als abstraktes Technologieprogramm eingeführt, sondern über konkrete, validierbare Use Cases - die Patientenbildung als Record Linkage im Zentrum, die Abrechnungsanomalien als nächstes Projekt auf derselben Plattform. [SG] Und damit schließt sich die Klammer zum Anfang. [Pause, den Leitsatz langsam und betont] Der Engpass für KI im Gesundheitswesen ist nicht das Modell, sondern eine Plattform, die reproduzierbare, validierbare Datenstände liefert - gezeigt an einem Problem, das man messen kann. [YQ] Vielen Dank für Ihre Aufmerksamkeit - wir freuen uns jetzt auf Ihre Fragen und die Diskussion.
