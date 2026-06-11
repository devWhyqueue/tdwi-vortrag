# Lakehouse als Enabler für Machine Learning im Gesundheitswesen

Klassische Data-Warehouse-Architekturen bremsen AI oft aus: getrennte Datenwelten, lange Zyklen und wenig Flexibilität. Wir zeigen unseren Umbau zu einem On-Premise-Lakehouse mit Open Source und wie dadurch Data Engineering und Data Science auf einer Plattform zusammenfinden. An Use Cases wie Patientenbildung (Record Linkage) und Anomalieerkennung, zum Beispiel Daten- und Prozessauffälligkeiten, demonstrieren wir, wie Datenqualität das Training erfolgreicher ML-Modelle ermöglicht.

## Eckdaten

| Kategorie       | Angabe                              |
| --------------- | ----------------------------------- |
| Zielpublikum    | Data Engineers & Scientists         |
| Voraussetzungen | Data-Lakehouse-Knowledge, ML-Basics |
| Level           | Advanced                            |

## Extended Abstract

Viele Unternehmen haben robuste Data-Warehouse-Landschaften etabliert. Doch sobald AI produktiv werden soll, zeigen sich strukturelle Grenzen: getrennte Datenplattformen für BI vs. Data Science, hoher Aufwand für Datenbereitstellung, lange Iterationszyklen und ein Trade-off zwischen Governance und Flexibilität.

Genau hier setzt die Lakehouse-Idee an: eine Architektur, die **Warehouse-Disziplin** — Qualität, Nachvollziehbarkeit, Metadaten und Zugriffskontrolle — mit **Data-Lake-Flexibilität** — skalierbare Verarbeitung, unterschiedliche Datentypen und iterative Entwicklung — verbindet.

In diesem Vortrag stellen wir unsere auf Open-Source-Technologien basierte Lakehouse-Architektur vor:

* **Apache Spark** als Compute-Engine
* **Delta Lake** für ACID-Tabellen und verlässliche Pipelines
* **Hive Metastore** für zentrale Metadaten- und Tabellenverwaltung
* **dbt** für modellgetriebene Transformationen, Testbarkeit und klare Verantwortlichkeiten

Wir beleuchten dabei nicht nur das Zielbild, sondern vor allem die konkreten Architekturentscheidungen und das Vorgehen in der Migration:

* Welche Datenzonen und Schichten haben sich bewährt?
* Wie schaffen wir verbindliche Datenprodukte?
* Wie bringen wir Data Engineering, Analytics und Data Science in einen gemeinsamen Prozess, ohne Governance zu verlieren?

Der Kernnutzen wird anschließend anhand von ML-Beispielen aus dem Gesundheitsumfeld sichtbar.

Ein Schwerpunkt ist **Patientenbildung als Record-Linkage-Problem**: Wie lassen sich Personen- und Fallbezüge über heterogene Quellen hinweg zuverlässig matchen, Dubletten erkennen und Daten konsistent zusammenführen — als Grundlage für nachgelagerte Analysen und Modelle?

Ergänzend zeigen wir einen Use Case zur **Anomalieerkennung**, bei dem auffällige Muster und Ausreißer in Daten und Prozessen identifiziert werden, zum Beispiel ungewöhnliche Verteilungen, Ausreißer oder seltene Kombinationen. Wir diskutieren, wie der Lakehouse-Stack die wiederholbare Pipeline vom Feature Engineering bis zum Training unterstützt.

Abgerundet wird der Vortrag durch Lessons Learned aus dem Projekt:

* typische Stolpersteine wie Metadaten-Disziplin, Datenqualität und Performance-Tuning
* bewährte Praktiken wie klare Schichten, Golden Datasets und reproducible ML
* ein pragmatischer Blick darauf, was sich wirklich lohnt — und was man besser weglässt

Ergebnis für Teilnehmende: ein klares Verständnis, warum Lakehouse-Architekturen ein starker Enabler für AI sind, wie man sie on premise mit Open Source umsetzt und welche Muster in echten Use Cases funktionieren.

---

# Speaker

## Sebastian Gobst

**DATA MART Consulting GmbH**
**Principal Consultant Systemarchitektur**

Ich arbeite seit 2014 im Bereich DWH und BI bei DATA MART und unterstütze Kunden bei der Optimierung von Datenlandschaften. Dabei liegt mein Schwerpunkt in der Datenarchitektur und Unterstützung von Prozessen mit Analysen. Bisher hauptsächlich im Microsoft-Bereich. Inzwischen aber vermehrt mit Open-Source-Technologien für die Entwicklung von Data-Lakehouse-Systemen. Fachliche Prozesse zu verstehen, um diese mit Daten zu optimieren, ist dabei eine spannende Herausforderung.

## Yannik Queisler

**Kassenärztliche Vereinigung Westfalen-Lippe**
**Data Engineer**

Ich bin Yannik Queisler, 27, und arbeite als Data Engineer bei der KVWL. Parallel studiere ich Machine Learning im Master an der TU Berlin. Mein Schwerpunkt liegt auf der Implementierung moderner Datenpipelines und Lakehouse-Technologien, zum Beispiel Spark, Airflow und Delta Lake, sowie auf ML Engineering — von der Datenbasis bis zur produktiven Anwendung.
