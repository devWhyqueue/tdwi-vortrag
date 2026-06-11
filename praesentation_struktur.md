# Lakehouse als Enabler für Machine Learning im Gesundheitswesen

## Gliederung für ca. 35 Folien

**Zielverteilung**

* Intro und Einordnung: ca. 5 Folien
* Lakehouse, Architektur und Orchestrierung: ca. 10 Folien
* ML und Haupt-Use-Case: ca. 15 Folien
* Lessons Learned und Outro: ca. 5 Folien

**Verwendete Quellen im Repo**

* `vortrag_info.md`
* `kvwl_lakehouse.pdf`
* `patient-linkeage/`
* `billing-anomalies/`

**Optionale externe Referenzpunkte für das Framing**

* Google/NeurIPS: [Hidden Technical Debt in Machine Learning Systems](https://research.google/pubs/hidden-technical-debt-in-machine-learning-systems/) - ML-Systeme bestehen nicht nur aus Modellcode; Datenabhängigkeiten und Pipeline-Komplexität sind zentrale Risiken.
* MIT Sloan / Andrew Ng: [Why it's time for data-centric artificial intelligence](https://mitsloan.mit.edu/ideas-made-to-matter/why-its-time-data-centric-artificial-intelligence) - Fokus auf Datenqualität statt nur auf Modellkomplexität.
* NIST: [AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework) - KI braucht Governance, Messbarkeit und kontrollierte Betriebsprozesse.
* DataHub: [What is DataHub?](https://docs.datahub.com/docs/features) - Data Catalog, Discovery, Lineage, Governance und Data Contracts als Governance-Komponente.

---

## 0. Einstieg und Einordnung

### Folie 1 - Titel

**Lakehouse als Enabler für Machine Learning im Gesundheitswesen**  
Open Source, On-Premise, Data Engineering und ML auf einer Plattform

**Kernaussage:** Der Vortrag zeigt keine abstrakte Lakehouse-Vision, sondern eine konkrete KVWL-Implementierung für produktives Data Engineering und ML.

**Inhalt**

* Titel, TDWI-Kontext
* Sprecher: Sebastian Gobst und Yannik Queisler
* Organisationen: DATA MART Consulting und KVWL
* Leitfrage: Welche Datenplattform braucht produktives Data Engineering und Machine Learning im Gesundheitswesen?

---

### Folie 2 - DATA MART Consulting und Sebastian Gobst

**Kernaussage:** DATA MART bringt die Perspektive aus DWH-, BI- und Datenarchitekturprojekten ein.

**Inhalt**

* DATA MART Consulting GmbH
* Sebastian Gobst, Principal Consultant Systemarchitektur
* Schwerpunkt: Optimierung von Datenlandschaften, BI/DWH, zunehmend Open Source Lakehouse
* Rolle im Vortrag: Architekturperspektive, Migrationslogik, Einordnung gegen klassische DWH-Muster

---

### Folie 3 - KVWL und Yannik Queisler

**Kernaussage:** Die KVWL bringt die konkrete On-Premise-Implementierung, den KI-/ML-Haupt-Use-Case und die Lessons Learned aus dem Aufbau ein.

**Inhalt**

* Kassenärztliche Vereinigung Westfalen-Lippe
* Yannik Queisler, Data Engineer
* Schwerpunkt: Spark, Airflow, Delta Lake, ML Engineering
* Rolle im Vortrag: KI-/ML-Teil, Patientenbildung als Haupt-Use-Case und Lessons Learned
* Kontext: KI ist in der KVWL ein neues Handlungsfeld und wird über greifbare Fachprozesse eingeführt
* Leitmotiv: erst Datenqualität, Plattform und konkrete Nutzenfälle - nicht zuerst ein großer unternehmensweiter Chatbot ohne belastbare Datenbasis

---

### Folie 4 - Warum dieses Thema?

**Kernaussage:** Produktive KI und produktives ML scheitern selten nur am Modell, sondern häufig an Datenhistorie, Datenqualität, Verantwortlichkeiten und Reproduzierbarkeit.

**Inhalt**

* Robuste DWH-Landschaften liefern stabile BI, aber Data Engineering und ML erzeugen neue Anforderungen
* Generative KI ist sichtbar, aber klassisches ML bleibt ein sehr direkter Werterzeuger für strukturierte Fachprozesse
* Typische Spannung:
  * Governance vs. Iterationsgeschwindigkeit
  * Reporting-Stabilität vs. Feature-Engineering
  * kuratierte Datenprodukte vs. rohe Historie
* Gesundheitsdaten verschärfen die Anforderungen an Nachvollziehbarkeit und Kontrolle
* Referenzframe: Data-centric AI und ML Technical Debt - Datenabhängigkeiten sind oft der eigentliche Hebel

---

### Folie 5 - Ablauf und Zielbild

**Kernaussage:** Wir gehen von der Architektur zur Umsetzung und dann zu einem validierbaren Haupt-Use-Case, an dem systematische KI-/ML-Einführung greifbar wird.

**Inhalt**

* Ausgangslage: SSIS-/DWH-Welt und uneinheitliche Lake-Zonen
* Zielarchitektur: Multi-Zone-Functional Lakehouse
* Orchestrierung und Technologieentscheidungen
* Haupt-Use-Case: Patientenbildung als Record Linkage und Survivorship
* Abgrenzung: Abrechnungsanomalien nur als weiterer Prototyp, nicht als validierter Schwerpunkt
* roter Faden: Nutzen früh greifbar machen, ohne die Datenplattform zu überspringen
* Lessons Learned: Was hat sich bewährt, was bleibt schwierig?

---

## 1. Lakehouse, Architektur und Orchestrierung

### Folie 6 - Ausgangslage: Von SSIS zu Lakehouse

**Kernaussage:** Der Umbau startet nicht bei Tools, sondern bei der Frage, wo welche Logik verantwortlich liegt.

**Inhalt**

* Übergeordnetes Ziel aus `kvwl_lakehouse.pdf`: Datentransformationen aus der alten SSIS-Welt ablösen
* Offene Leitfragen:
  * Wo wird Logik implementiert - im Projekt und im Layer?
  * Welche Technologie ist für welchen Schritt passend - PySpark, dbt, SQL?
  * Welche Garantien darf ein Downstream-Consumer von einem Dataset erwarten?

---

### Folie 7 - Problem der alten Zonenlogik

**Kernaussage:** Uneinheitliche Layer-Verantwortlichkeiten erzeugen kognitive Last, doppelte Logik und schwache Garantien.

**Inhalt**

* Landing Zone: gleichzeitig temporäre Ablage und Archiv
* Staging Zone: nur sporadisch genutzt, unterschiedliche Formate
* History Zone: teils Rohhistorie, teils Standardisierung, teils Fachlogik
* Analysis Zone: noch stark von SSIS-/Altprozessen geprägt
* Konsequenz: unklare Codelokalisierung, schweres Reprocessing, hoher Bus-Faktor

---

### Folie 8 - Lakehouse-Prinzip für die KVWL

**Kernaussage:** Lakehouse bedeutet hier: offene Speicherung plus Warehouse-Garantien für Data Engineering, Analytics und ML.

**Inhalt**

* einheitlicher Speicher für strukturierte, semi-strukturierte und perspektivisch weitere Datenformen
* ACID-Tabellen und paralleler Lese-/Schreibzugriff über Delta Lake
* Schema-Validierung, Metadatenkatalog, Lineage und Zugriffskontrolle
* DataHub als Governance-Komponente für Data Catalog, Discovery, Ownership, Lineage und Data Contracts
* Performance durch optimierte Dateiformate, Statistiken, Clustering/Compaction
* BI, Analytics und ML auf derselben Plattform ohne redundante Schatten-ETL

---

### Folie 9 - Zielarchitektur: Multi-Zone-Functional

**Kernaussage:** Die neue Architektur definiert Zonen über Funktionen und Verträge, nicht über historisch gewachsene Namen.

**Inhalt**

* Zielbild aus `kvwl_lakehouse.pdf`:
  * Landing Zone: optional und transient
  * Raw Zone: unveränderliche Rohdatenhistorie
  * Process Zone: technische Qualität und Standardisierung
  * Access Zone: fachliche Datenprodukte für BI, Analytics und ML
* Visualisierungsidee: horizontale Zonen mit klaren Verträgen und vertikalen Governance-/Ops-Aspekten

---

### Folie 10 - Landing und Raw Zone

**Kernaussage:** Rohdatenhistorie ist die Grundlage für Audits, Reprocessing und reproduzierbare ML-Datenstände.

**Inhalt**

* Landing Zone:
  * kurzlebig, optional, keine Transformationen
  * automatische Bereinigung nach kurzer Aufbewahrung
* Raw Zone:
  * langfristige Historisierung als System of Record
  * Append-only, quellnah, Schema-on-Read
  * technische Metadaten: Quelle, Pfad, Ladezeitpunkt, Dateigröße, Checksumme
  * nur minimale Validierung: Parsbarkeit, Existenz, Größe, technische Integrität

---

### Folie 11 - Process Zone

**Kernaussage:** In der Process Zone wird aus historisierten Rohdaten eine technisch verlässliche Grundlage.

**Inhalt**

* Standardisierung von Formaten und Datentypen
* Delta Lake als robustes Tabellenformat
* technische Bereinigung: fehlende Werte, Inkonsistenzen, Deduplikation, Schema-Evolution
* Provenienz und Laufmetadaten
* erlaubt: dataset-unabhängige Standardisierungslogik und Integration
* verboten: verbraucherspezifische Denormalisierung und fachliche Marts

---

### Folie 12 - Access Zone und Datenprodukte

**Kernaussage:** Die Access Zone ist der Ort für fachliche Semantik, konsumierbare Datenprodukte und Feature Sets.

**Inhalt**

* fachliche Transformationen, Aggregationen, Star Schemas, Wide Tables
* Feature Engineering und Serving-nahe Tabellen für ML
* dokumentierte Metrikdefinitionen, fachliche Granularität und SLOs
* Versionierung bei Breaking Changes, parallele Auslaufphasen
* Tests für Metrikkonsistenz, dimensionale Integrität und Freshness
* keine Rückkopplung in Raw oder Process außer dokumentierten Backfill-/Reconciliation-Verfahren

---

### Folie 13 - Technologieentscheidungen: PySpark, dbt, Delta, DataHub

**Kernaussage:** Der Stack trennt technische Datenverarbeitung und fachliche Modellierung klarer als vorher, ohne mit maximaler Infrastrukturkomplexität zu starten.

**Inhalt**

* PySpark:
  * Ingestion, technische Standardisierung, große Datenmengen
  * komplexe Algorithmen, die nicht sinnvoll in SQL/dbt abbildbar sind
* dbt:
  * fachliche Modelle in der Access Zone
  * Tests, Dokumentation, Lineage und SQL-nahe Analytics-Entwicklung
* Delta Lake:
  * ACID, Schema Enforcement, MERGE/Upserts, Time Travel
* Hive Metastore:
  * zentraler Tabellen- und Metadatenzugriff
* DataHub:
  * Data Catalog, Discovery, fachliche Dokumentation
  * Ownership, Lineage, Governance und Data Contracts
  * Brücke zwischen technischen Tabellen und fachlicher Nutzbarkeit
* Betriebsprinzip:
  * einfache, containerisierte Services zuerst
  * Architektur so schneiden, dass spätere Migration auf Kubernetes möglich bleibt

---

### Folie 14 - Orchestrierung, Governance und Pipeline-Verträge

**Kernaussage:** Reproduzierbarkeit entsteht erst, wenn Datenstände, Jobs, Abhängigkeiten, Qualitätschecks und Metadaten zusammengeführt werden.

**Inhalt**

* Airflow als Steuerungsschicht für Ingestion, Processing und Access-Produkte
* DAGs machen Abhängigkeiten, Wiederanläufe und Scheduling explizit
* Pipeline-Metadaten pro Lauf: Quelle, Zeitraum, Extraktzeitpunkt, Row Counts, Checksummen, Status
* DataHub als sichtbarer Governance-Layer für Ownership, Lineage, Dataset-Beschreibung und Data Contracts
* Quality Gates zwischen Layers statt unkontrollierter Transformationen
* kontrollierte Übergänge von explorativer Logik in produktive Pipelines

---

### Folie 15 - Betriebsmodell: einfach starten, sauber wachsen

**Kernaussage:** Enterprise-grade Lakehouse heißt nicht, dass man am ersten Tag ein unternehmensweites Kubernetes-Cluster oder einen großen Cloud-Anbieter braucht.

**Inhalt**

* Startpunkt KVWL:
  * drei Red-Hat-Umgebungen: dev, test, prod
  * Podman/systemctl für Containerisierung und Betrieb
  * Betrieb mit sehr kleinem Admin-Footprint
* Ergebnis:
  * Verarbeitung im Terabyte-Maßstab bereits mit einfachem Setup möglich
  * klare Umgebungen, reproduzierbare Container, kontrollierbarer Betrieb
* Weiterentwicklung:
  * inzwischen unternehmensweites Kubernetes vorhanden
  * schrittweiser Umzug der Architektur
  * dank Containerisierung kein großer Architekturbruch
* Lesson: so simpel wie möglich starten, technische Reife gezielt ausbauen

---

## 2. ML und Haupt-Use-Case Patientenbildung

### Folie 16 - Was produktives Data Engineering und ML vom Lakehouse brauchen

**Kernaussage:** Der Engpass ist selten der Modellaufruf selbst, sondern die Fähigkeit, Datenstände reproduzierbar, fachlich verstanden und governancefähig bereitzustellen.

**Inhalt**

* konsistente Trainings-, Validierungs- und Scoring-Daten
* nachvollziehbare Feature-Definitionen
* stabile Entitäten, z. B. Patient, Praxis, Honorargruppe, Quartal
* Datenqualitätschecks vor Modelltraining
* Daten- und Code-Versionierung
* Auditierbarkeit der Ergebnisse
* Data Catalog und Lineage, damit Teams Daten nicht nur finden, sondern verantwortbar nutzen können

---

### Folie 17 - Warum Patientenbildung als Haupt-Use-Case?

**Kernaussage:** Patientenbildung ist der bessere Haupt-Use-Case, weil fachlicher Nutzen, Datenqualitätsbezug und messbare Validierung zusammenkommen.

**Inhalt**

* Record Linkage über heterogene Quellen
* stabile Patient-Pseudo-IDs als Grundlage für Analysen und nachgelagerte ML-Use-Cases
* Golden Record über Survivorship
* klar messbar über Proxy-/synthetisches Dataset mit Ground Truth
* bessere Validierbarkeit als Abrechnungsanomalien:
  * dort fehlt aktuell noch fachlich validierter Erfolg der Erkennung
  * Patientenbildung erlaubt automatisierte Evaluation gegen bekannte Entitäten
* Gemeinsamer Nenner: Datenqualität vor Modellqualität
* bewusstes Framing: klassisches ML ist kein Rückschritt, sondern oft der kürzeste Weg zu messbarem Nutzen auf strukturierten Unternehmensdaten

---

### Folie 18 - Patientenbildung: Fachliches Problem

**Kernaussage:** Der Einstieg war ein konkreter KVWL-Prozess; der eigentliche Hebel war, ihn als bekanntes allgemeines Problem zu erkennen.

**Inhalt**

* Ausgangspunkt: aktueller fachlicher Prozess "Patientenbildung" und dessen bestehende Implementierung
* Abstraktion: Patientenbildung ist ein Record-Linkage-Problem mit nachgelagertem Survivorship
* Warum das wichtig ist:
  * aus einem KVWL-spezifisch wirkenden Prozess wird ein bekanntes Forschungs- und Engineering-Problem
  * Literatur, Standardbegriffe und Community-Erfahrung werden nutzbar
  * Evaluationsmetriken und typische Trade-offs werden klarer
* Heterogene Quellen: ABR1, ABR2, bearbeitete/unbearbeitete Daten, KVUEPP
* Identifikatoren und Attribute:
  * EGK-Versichertennummer
  * Vorname, Nachname
  * Geburtsdatum
  * PLZ
* Herausforderungen:
  * unvollständige Attribute
  * Schreibvarianten und Tippfehler
  * fehlende oder wechselnde Identifikatoren
  * historische Datenstände und Quartale

---

### Folie 19 - Patientenbildung: aktuelles deterministisches Modell

**Kernaussage:** Der erste Schritt war nicht Modellbau, sondern sauberes Verstehen und Dokumentieren des bestehenden fachlichen Algorithmus.

**Inhalt**

* Stored Procedure `M20_HIS_P_01AB000_PATIENTENBILDUNG`
* sequentielle Matching-Regeln:
  * EGK + Geburtsdatum
  * EGK + Vorname + Nachname
  * Vorname + Nachname + Geburtsdatum + PLZ
* bereits gematchte Records werden in späteren Phasen nicht erneut bewertet
* neue Patientencluster über transitive Closure
* Lookup-Tabelle speichert neue Attributkombinationen für zukünftige Läufe
* Ergebnis der Analyse:
  * Stärken des bestehenden Prozesses werden sichtbar
  * Grenzen lassen sich präzise formulieren
  * Vergleich mit wissenschaftlichen Record-Linkage-Ansätzen wird möglich

---

### Folie 20 - Patientenbildung: Recherche- und Evaluationsvorgehen

**Kernaussage:** Ausführliche Vorbereitung und Recherche lohnen sich, bevor man einen produktiven Fachprozess durch ML ersetzt oder ergänzt.

**Inhalt**

* Vorgehen:
  * fachlichen Prozess und SQL-Implementierung verstehen
  * Problem als Record Linkage abstrahieren
  * State-of-the-Art-Ansätze und Paper recherchieren
  * mehrere Verfahren implementieren und gegen den bestehenden Prozess evaluieren
* betrachtete Ansätze:
  * bestehende deterministische Kaskade
  * Hybrid Cascade mit fuzzy Fallbacks
  * probabilistisches FlexRL-Modell aus der Literatur
* Evaluationsfokus:
  * Precision und false merges
  * Recall und split entities
  * F1, Clusterqualität, Laufzeit und Erklärbarkeit
* Lesson: Naming früh an Community Standards ausrichten - dann sieht man schneller, welche Probleme bereits gut erforscht sind

---

### Folie 21 - Proxy-Dataset: Warum überhaupt synthetische Daten?

**Kernaussage:** Für Record Linkage braucht man Ground Truth - die existiert in Echtdaten oft nicht direkt und darf aus Datenschutzgründen nicht einfach geteilt werden.

**Inhalt**

* Echtdaten enthalten keinen perfekten, unabhängigen Wahrheitsdatensatz für alle Links
* Datenschutz: Patientendaten können nicht als Entwicklungs-/Benchmark-Dataset frei genutzt werden
* Proxy-Dataset ermöglicht:
  * kontrollierte Ground Truth über `entity_id`
  * realistische Fehler, Dubletten, fehlende Werte und historische Varianten
  * wiederholbare Evaluation verschiedener Ansätze
  * vergleichbare Metriken für Current Model, Hybrid Cascade und FlexRL
* Lakehouse-Bezug: synthetische Testdaten werden selbst zu einem reproduzierbaren Datenprodukt

---

### Folie 22 - Proxy-Dataset: Wie es erzeugt wurde

**Kernaussage:** Das Proxy-Dataset ist nicht frei erfunden, sondern aus aggregierten, privacy-preserving Statistiken der realen Daten abgeleitet.

**Inhalt**

* Analyse realer Daten nur aggregiert:
  * k-Anonymität `k >= 100`
  * gebinnte Verteilungen
  * gerundete Counts
  * keine Ausgabe individueller Patientendatensätze
* extrahierte Verteilungen:
  * Vor- und Nachnamen
  * Namenslängen und Zeichenmuster
  * KVNR-/EGK-Muster
  * PLZ-Regionen
  * Geburtsjahr-Bins, Monat und Tag
  * Geschlecht, VSDM-Verifikation, Fehlerprofile
* Generator erzeugt:
  * mehrere Records pro Entität
  * Typo- und Missing-Value-Muster
  * Adressänderungen über Quartale
  * Golden Records für Survivorship

---

### Folie 23 - Validierungsdesign und Metriken

**Kernaussage:** Die Proxy-Daten machen aus einer fachlichen Diskussion eine messbare Engineering-Frage.

**Inhalt**

* Ground Truth:
  * `entity_id` für wahre Personencluster
  * Golden-Record-Felder für Survivorship
* Record-Linkage-Metriken:
  * Pairwise Precision
  * Pairwise Recall
  * F1
  * perfect clusters
  * split entities / false negatives
  * merged clusters / false positives
* besonders wichtig bei Patientendaten:
  * false merges sind fachlich riskanter als false negatives
  * Schwellen müssen konservativ gewählt und begründet werden
* Fehleranalyse:
  * Export von false positives und false negatives
  * qualitative Prüfung typischer Fehlermuster

---

### Folie 24 - Ansatz 1: Aktuelles deterministisches Modell

**Kernaussage:** Das bestehende Modell ist ein starker konservativer Baseline-Ansatz, aber es verliert viele echte Links.

**Inhalt**

* implementiert aus bestehender SQL-Logik als validierbare Python-Variante
* deterministische Kaskade:
  * EGK + Geburtsdatum
  * EGK + Name
  * Name + Geburtsdatum + PLZ
* transitive Closure für neue Patientencluster
* Ergebnis auf Proxy-Dataset:
  * Precision: 100,00 %
  * Recall: 69,35 %
  * F1: 81,90 %
* Interpretation:
  * praktisch keine false merges
  * aber viele split entities
  * guter Safety-Baseline für alle Alternativen

---

### Folie 25 - Ansatz 2: Hybrid Cascade

**Kernaussage:** Ein deterministisch dominierter Ansatz kann durch fuzzy Fallbacks deutlich mehr echte Links finden, ohne die Precision stark zu beschädigen.

**Inhalt**

* Designprinzipien:
  * exakte Matches zuerst
  * fuzzy Matching nur als Fallback
  * adaptive Blocking-Grenzen gegen O(N²)-Explosion
  * hybride Ähnlichkeit: Edit Distance für kurze Namen, Q-Gram/Jaccard für längere Namen
* Kaskadenlevel:
  * EGK exact
  * Name + DOB exact
  * Name fuzzy + DOB exact
  * EGK + Nachname
  * Name fuzzy + PLZ + Geburtsjahr
* Ergebnis:
  * Precision: 99,91 %
  * Recall: 81,95 %
  * F1: 90,04 %
  * Recall-Verbesserung gegenüber Baseline: +12,60 Prozentpunkte

---

### Folie 26 - Ansatz 3: FlexRL als probabilistischer Ansatz

**Kernaussage:** Probabilistische Linkage macht Unsicherheit explizit und lernt Fehler-/Zufallsmuster aus den Daten.

**Inhalt**

* FlexRL nach Robach et al. als latent-variable model
* Partially Identifying Variables:
  * Vorname, Nachname, Geburtsdatum, PLZ, EGK
* EM-Algorithmus lernt:
  * Link-Wahrscheinlichkeit
  * Fehlerwahrscheinlichkeit je Variable
  * zufällige Übereinstimmungswahrscheinlichkeit je Variable
* Blocking über EGK, DOB, PLZ + Geburtsjahr, Namenspräfix
* konservativer Threshold `0,9`, weil false merges bei Patientendaten besonders kritisch sind

---

### Folie 27 - Ergebnisvergleich: Trade-off statt Modellhype

**Kernaussage:** Der beste Ansatz ist nicht automatisch der komplexeste, sondern der mit fachlich akzeptablem Trade-off.

**Inhalt**

* Current Model:
  * Precision: 100,00 %
  * Recall: 69,35 %
  * F1: 81,90 %
* Hybrid Cascade:
  * Precision: 99,91 %
  * Recall: 81,95 %
  * F1: 90,04 %
* FlexRL bei Threshold 0,9:
  * Precision: 99,89 %
  * Recall: 92,11 %
  * F1: 95,85 %
* fachliche Entscheidung:
  * Ist der Recall-Gewinn die wenigen false merges wert?
  * Welche Fälle müssen manuell reviewed werden?
  * Welche Schwelle ist für Produktivbetrieb vertretbar?

---

### Folie 28 - Survivorship: Vom Cluster zum Golden Record

**Kernaussage:** Record Linkage löst nur die Identität; nutzbar wird das Ergebnis erst durch konsolidierte Patientenstammdaten.

**Inhalt**

* Survivorship `M20_HIS_P_01AB000_BUILD_PATIENTEN_STAMM`
* Two-tier-Strategie:
  * Tier 1: VSDM-verifizierte Daten mit höchstem Vertrauen
  * Tier 2: zeitgewichtete Häufigkeit plus Vollständigkeit
* zusätzliche Normalisierung:
  * PLZ-/Ortsnormalisierung
  * Umlautnormalisierung
  * OKZ-/Regionen-Anreicherung
* Proxy-Dataset enthält Golden Records, damit auch Survivorship messbar wird
* Ergebnis: ein konsolidierter Patientenstamm pro Patient-Pseudo-ID

---

### Folie 29 - Vom Notebook in die Lakehouse-Pipeline

**Kernaussage:** Der Use Case zeigt den Weg von akademischer Evaluation zu produktionsnaher Data-Engineering-Arbeit.

**Inhalt**

* explorative Phase:
  * Prozess verstehen
  * Proxy-Dataset erzeugen
  * Ansätze evaluieren
  * Fehlermuster analysieren
* Produktionspfad:
  * Raw: historisierte Quellvarianten
  * Process: technische Standardisierung und Patientenbildung
  * Access: konsolidierter Patientenstamm und konsumierbare Patientendatenprodukte
* Pipeline-Anforderungen:
  * reproduzierbare Laufparameter
  * versionierte Schwellen und Modell-/Algorithmusversionen
  * Qualitätsmetriken je Lauf
  * Monitoring von Split-/Merge-Risiken

---

### Folie 30 - Abgrenzung: Warum nicht Abrechnungsanomalien als Hauptstory?

**Kernaussage:** Ein Use Case gehört erst in den Mittelpunkt, wenn Nutzen und Validierung belastbar genug sind.

**Inhalt**

* Abrechnungsanomalien bleibt ein interessanter Prototyp:
  * Feature Engineering, ECOD, Explainability, Review-App
  * gute technische Pipeline-Demonstration
* aber:
  * fachlicher Erfolg der Erkennung noch nicht ausreichend validiert
  * kein automatisiertes Ground-Truth-/Proxy-Dataset wie bei Patientenbildung
  * aktuell voraussichtlich keine direkte Weiterentwicklung
* Lesson:
  * Prototypen sind wertvoll, aber nicht jeder Prototyp ist bereits eine gute Hauptstory
  * Validierbarkeit ist ein zentrales Kriterium für Use-Case-Auswahl
  * Patientenbildung zeigt den vollständigeren Weg von Problemabstraktion zu messbarer Evaluation

---

## 3. Lessons Learned und Abschluss

### Folie 31 - Architektur-Lessons

**Kernaussage:** Die wichtigsten Architekturentscheidungen sind die klaren Layer-Verträge, nicht die Toolnamen.

**Inhalt**

* Raw muss wirklich raw bleiben, sonst wird Reprocessing schwach
* Process braucht technische Qualitätsgarantien
* Access braucht fachliche Semantik und konsumierbare Datenprodukte
* PySpark und dbt ergänzen sich, wenn ihre Rollen klar sind
* einfaches Betriebsmodell reicht für den Start, wenn Containerisierung und Umgebungen sauber geschnitten sind
* Kubernetes kann später kommen; gute Containerisierung macht die Migration beherrschbar

---

### Folie 32 - KI-/ML-Lessons

**Kernaussage:** Produktive KI beginnt vor dem Modell: bei Entitäten, Features, Historie, Governance und fachlicher Prüfbarkeit.

**Inhalt**

* stabile Entitäten sind zentrale ML-Infrastruktur
* Patientenbildung zeigt: false merges sind oft kritischer als false negatives
* fachliche Prozesse früh auf Community-Begriffe mappen: "Patientenbildung" wird als Record Linkage anschlussfähig an Forschung und Standards
* Recherche vor Implementierung spart Umwege, weil bekannte Problemklassen oft bereits gute Lösungs- und Evaluationsmuster haben
* Prototypen brauchen eine klare Validierungsstrategie, bevor sie zur Hauptstory werden
* Explainability ist kein Add-on, sondern Teil des Produktdesigns
* Modellmetriken reichen nicht; fachliche Validierung ist entscheidend
* systematische KI-Einführung heißt: konkrete Fachprozesse verbessern, Feedback aufnehmen und erst dann skalieren

---

### Folie 33 - Was wir wieder so machen würden

**Kernaussage:** Einige Muster haben sich als besonders tragfähig erwiesen.

**Inhalt**

* offene Formate und On-Premise-Open-Source-Stack
* Delta-Tabellen für robuste Pipelines
* Airflow-DAGs mit expliziten Abhängigkeiten und Metadaten
* DataHub früh als Katalog- und Governance-Komponente etablieren
* Feature Datasets als Datenprodukte denken
* schnelle Prototypen, aber klarer Pfad in produktive Pipelines
* Review- und Feedback-Oberflächen früh mitdenken

---

### Folie 34 - Was man vermeiden sollte

**Kernaussage:** Lakehouse-Projekte scheitern leicht an zu viel impliziter Logik und zu wenig Produktdenken.

**Inhalt**

* Layer ohne klare Verträge
* Landing-Zonen als dauerhaftes Schattenarchiv
* Notebook-Logik ohne Operationalisierungspfad
* Datenprodukte ohne fachliche Semantik
* ML ohne Datenqualitätsstrategie
* KI-Initiativen, die mit einem großen Chatbot starten, bevor Datenqualität, Ownership und Lineage geklärt sind
* Scores ohne Erklärbarkeit und ohne fachlichen Review-Prozess
* Toolfokus statt Architekturprinzipien

---

### Folie 35 - Schlussbild und Q&A

**Kernaussage:** Das Lakehouse ist kein Selbstzweck, sondern die Plattform, auf der Data Engineering, Governance und KI/ML produktiv zusammenarbeiten.

**Inhalt**

* eine Plattform von Rohdaten bis ML-Anwendung
* reproduzierbare Datenstände statt Ad-hoc-Extrakte
* klare Verantwortlichkeiten statt gewachsener Zonenlogik
* Datenqualität als Voraussetzung für Modellqualität
* systematische KI-Einführung über konkrete, validierbare Use Cases statt abstrakter Technologieprogramme
* Haupt-Use-Case: Patientenbildung; Abrechnungsanomalien als abgegrenzter, noch nicht validierter Prototyp
* Q&A und Diskussion
