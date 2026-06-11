CREATE PROC [dbo].[M20_HIS_P_01AB000_BUILD_PATIENTEN_STAMM] @Quartal [INT] AS

DECLARE @LoadDate datetime = CURRENT_TIMESTAMP;

IF @Quartal IS NULL 
    SET @Quartal = CONCAT(DATEPART(YEAR, CURRENT_TIMESTAMP), DATEPART(QUARTER, CURRENT_TIMESTAMP));

-- =============================================================================
-- STEP 1: VSDM-Verified Records (Highest Trust)
-- VSDM = Versichertenstammdatenmanagement (insurance card online verification)
-- =============================================================================

IF OBJECT_ID(N'tempdb..#PatStammNeuVSDM') IS NOT NULL DROP TABLE #PatStammNeuVSDM;

WITH VSDM AS (
    SELECT SCHEINID, DWH_ZEITRAUM, MAX(ONLINEPRUEFUNGSDATUM) ONLINEPRUEFUNGSDATUM
    FROM M20_HIS_T_01AB100_VSDMPRUEFUNGSNACHWEISE
    WHERE ERGEBNISONLINEPRUEFUNG IN (1,2) 
        AND (ERRORCODE IS NULL OR ERRORCODE = 0)
    GROUP BY SCHEINID, DWH_ZEITRAUM
),
VSDM_UNB AS (
    SELECT SCHEINID, DWH_ZEITRAUM, MAX(ONLINEPRUEFUNGSDATUM) ONLINEPRUEFUNGSDATUM
    FROM M20_HIS_T_01AB100_VSDMPRUEFUNGSNACHWEISE_UNB
    WHERE ERGEBNISONLINEPRUEFUNG IN (1,2) 
        AND (ERRORCODE IS NULL OR ERRORCODE = 0)
    GROUP BY SCHEINID, DWH_ZEITRAUM
),
PlzStadt AS (
    SELECT 
        PLZ, Stadt,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(Stadt), 'ß', 'SS'), 'Ä', 'AE'), 'Ö', 'OE'), 'Ü', 'UE') AS Stadt_Korr,
        Bundeslandcode, Kennziffer,
        Bundeslandcode + Kennziffer AS ORTSKENNZAHL,
        ISNULL(OKZ, Bundeslandcode + Kennziffer + '000') AS OKZ,
        COUNT(*) OVER (PARTITION BY PLZ) AS Num
    FROM dbo.M20_HIS_T_02SIC00_PLZ_STADT
),
scheine AS (
    -- BEARBEITET (processed) records with VSDM verification
    SELECT 
        map.Pat_pseudo_ID,
        VSDM.ONLINEPRUEFUNGSDATUM,
        schein.EGKVERSICHERTENNUMMER,
        schein.NACHNAME,
        schein.VORNAME,
        TRY_CONVERT(DATE, CASE 
            WHEN schein.GEBURTSDATUM LIKE '%0000' THEN CONCAT(LEFT(schein.GEBURTSDATUM,5), '101')
            WHEN schein.GEBURTSDATUM LIKE '%00' THEN CONCAT(LEFT(schein.GEBURTSDATUM,7), '1')
            ELSE schein.GEBURTSDATUM END, 112) AS GEBURTSDATUM,
        schein.GESCHLECHT,
        schein.PLZ,
        schein.WOHNORT,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(schein.WOHNORT), 'ß', 'SS'), 'Ä', 'AE'), 'Ö', 'OE'), 'Ü', 'UE') AS WOHNORT_Korr,
        schein.STRASSE + ' ' + ISNULL(schein.HAUSNUMMER,'') AS STRASSE,
        LAENDERCODE,
        schein.SCHEINID,
        schein.DWH_ZEITRAUM
    FROM M20_HIS_T_01AB100_SCHEINE schein
        INNER JOIN VSDM ON schein.scheinid = VSDM.SCHEINID AND schein.DWH_ZEITRAUM = VSDM.DWH_ZEITRAUM
        INNER JOIN dbo.M20_HIS_T_01AB100_PATID_MAPPING map
            ON map.scheinid = schein.SCHEINID AND map.mengenid = schein.MENGENID
            AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.Datenkoerper = 'BEARBEITET'
    WHERE schein.DWH_ZEITRAUM <= @Quartal
    
    UNION ALL
    
    -- UNBEARBEITET (unprocessed) records with VSDM verification
    SELECT 
        map.Pat_pseudo_ID,
        VSDM_UNB.ONLINEPRUEFUNGSDATUM,
        schein.EGKVERSICHERTENNUMMER,
        schein.NACHNAME,
        schein.VORNAME,
        TRY_CONVERT(DATE, CASE 
            WHEN schein.GEBURTSDATUM LIKE '%0000' THEN CONCAT(LEFT(schein.GEBURTSDATUM,5), '101')
            WHEN schein.GEBURTSDATUM LIKE '%00' THEN CONCAT(LEFT(schein.GEBURTSDATUM,7), '1')
            ELSE schein.GEBURTSDATUM END, 112) AS GEBURTSDATUM,
        schein.GESCHLECHT,
        schein.PLZ,
        schein.WOHNORT,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(schein.WOHNORT), 'ß', 'SS'), 'Ä', 'AE'), 'Ö', 'OE'), 'Ü', 'UE') AS WOHNORT_Korr,
        schein.STRASSE + ' ' + ISNULL(schein.HAUSNUMMER,'') AS STRASSE,
        LAENDERCODE,
        schein.SCHEINID,
        schein.DWH_ZEITRAUM
    FROM M20_HIS_T_01AB100_SCHEINE_UNB schein
        INNER JOIN VSDM_UNB ON schein.scheinid = VSDM_UNB.SCHEINID AND schein.DWH_ZEITRAUM = VSDM_UNB.DWH_ZEITRAUM
        INNER JOIN dbo.M20_HIS_T_01AB100_PATID_MAPPING map
            ON map.scheinid = schein.SCHEINID AND map.mengenid = schein.MENGENID
            AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.Datenkoerper = 'UNBEARBEITET'
    WHERE schein.DWH_ZEITRAUM <= @Quartal
),
lastCheck AS (
    SELECT Pat_pseudo_ID, MAX(ONLINEPRUEFUNGSDATUM) AS MaxOnlinepruefungsdatum
    FROM scheine
    GROUP BY Pat_pseudo_ID
),
bestPatient AS (
    SELECT 
        scheine.Pat_pseudo_ID,
        scheine.EGKVERSICHERTENNUMMER,
        scheine.NACHNAME,
        scheine.VORNAME,
        scheine.GEBURTSDATUM,
        scheine.GESCHLECHT,
        scheine.PLZ,
        scheine.WOHNORT,
        scheine.WOHNORT_Korr,
        scheine.STRASSE,
        scheine.LAENDERCODE,
        -- If multiple records have same VSDM date, pick one arbitrarily (should have same data)
        ROW_NUMBER() OVER (PARTITION BY scheine.Pat_pseudo_ID ORDER BY scheine.DWH_Zeitraum DESC) AS [Rank]
    FROM lastCheck
        INNER JOIN scheine
            ON lastCheck.Pat_pseudo_ID = scheine.Pat_pseudo_ID
            AND lastCheck.MaxOnlinepruefungsdatum = scheine.ONLINEPRUEFUNGSDATUM
    WHERE lastCheck.Pat_pseudo_ID NOT IN (0,-1)
)

SELECT
    Pat_pseudo_ID,
    CONVERT(varchar(10), EGKVERSICHERTENNUMMER) AS EGKVERSICHERTENNUMMER,
    CONVERT(varchar(255), NACHNAME) AS NACHNAME,
    CONVERT(varchar(255), VORNAME) AS VORNAME,
    GEBURTSDATUM,
    CASE WHEN dGeschlecht.GESCHLECHT_ID IS NULL THEN 0 ELSE dGeschlecht.GESCHLECHT_ID END AS GESCHLECHT,
    CONVERT(varchar(5), bestPatient.PLZ) AS PLZ,
    -- Progressive PLZ-City matching: exact → 15 chars → 11 chars → 7 chars → 3 chars
    ISNULL(UniquePLZs.Stadt, ISNULL(mapPLZ.Stadt, ISNULL(mapPLZ2.Stadt, 
        ISNULL(mapPLZ3.Stadt, ISNULL(mapPLZ4.Stadt, ISNULL(mapPLZ5.Stadt, bestPatient.WOHNORT)))))) AS WOHNORT,
    CONVERT(varchar(300), STRASSE) AS STRASSE,
    LAENDERCODE,
    ISNULL(UniquePLZs.ORTSKENNZAHL, ISNULL(mapPLZ.ORTSKENNZAHL, ISNULL(mapPLZ2.ORTSKENNZAHL, 
        ISNULL(mapPLZ3.ORTSKENNZAHL, ISNULL(mapPLZ4.ORTSKENNZAHL, mapPLZ5.ORTSKENNZAHL))))) AS ORTSKENNZAHL,
    ISNULL(UniquePLZs.OKZ, ISNULL(mapPLZ.OKZ, ISNULL(mapPLZ2.OKZ, 
        ISNULL(mapPLZ3.OKZ, ISNULL(mapPLZ4.OKZ, mapPLZ5.OKZ))))) AS OKZ,
    NULL AS GEO_X,
    NULL AS GEO_Y
INTO #PatStammNeuVSDM
FROM bestPatient
    LEFT JOIN dbo.M20_HIS_T_80ALL00_GESCHLECHT dGeschlecht ON bestPatient.GESCHLECHT = dGeschlecht.GESCHLECHT_BESCHREIBUNG
    -- PLZ with unique city mapping
    LEFT JOIN PlzStadt UniquePLZs ON bestPatient.PLZ = UniquePLZs.PLZ AND UniquePLZs.Num = 1
    -- Progressive fuzzy city matching by prefix length
    LEFT JOIN (SELECT PLZ, Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, Stadt ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ
        ON bestPatient.PLZ = mapPLZ.PLZ AND bestPatient.WOHNORT_Korr = mapPLZ.Stadt AND UniquePLZs.PLZ IS NULL AND mapPLZ.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 15) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 15) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ2
        ON bestPatient.PLZ = mapPLZ2.PLZ AND LEFT(bestPatient.WOHNORT_Korr, 15) = mapPLZ2.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 11) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 11) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ3
        ON bestPatient.PLZ = mapPLZ3.PLZ AND LEFT(bestPatient.WOHNORT_Korr, 11) = mapPLZ3.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 7) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 7) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ4
        ON bestPatient.PLZ = mapPLZ4.PLZ AND LEFT(bestPatient.WOHNORT_Korr, 7) = mapPLZ4.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.PLZ IS NULL AND mapplz4.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 3) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 3) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ5
        ON bestPatient.PLZ = mapPLZ5.PLZ AND LEFT(bestPatient.WOHNORT_Korr, 3) = mapPLZ5.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.PLZ IS NULL AND mapplz4.PLZ IS NULL AND mapplz5.RowNum = 1
WHERE [Rank] = 1;

-- =============================================================================
-- STEP 2: Score-Based Selection (Fallback for non-VSDM patients)
-- Uses time-weighted frequency + completeness scoring
-- =============================================================================

DECLARE @now INT = CONCAT(DATEPART(YEAR, CURRENT_TIMESTAMP), DATEPART(QUARTER, CURRENT_TIMESTAMP));

IF OBJECT_ID(N'tempdb..#PatStammNeuScore') IS NOT NULL DROP TABLE #PatStammNeuScore;

WITH ScheineUnion AS (
    -- BEARBEITET records
    SELECT
        map.Pat_pseudo_ID,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.EGKVERSICHERTENNUMMER ELSE PatStamm.EGKVNR END AS EGKVERSICHERTENNUMMER,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.VORNAME ELSE PatStamm.VORNAME_AKT END AS VORNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.NACHNAME ELSE PatStamm.NAME_AKT END AS NACHNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN TRY_CONVERT(DATE, CASE 
            WHEN schein.GEBURTSDATUM LIKE '%0000' THEN CONCAT(LEFT(schein.GEBURTSDATUM,5), '101')
            WHEN schein.GEBURTSDATUM LIKE '%00' THEN CONCAT(LEFT(schein.GEBURTSDATUM,7), '1')
            ELSE schein.GEBURTSDATUM END, 112) ELSE PatStamm.GEB_DATUM_AKT END AS GEBURTSDATUM,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN 
            CASE WHEN dGeschlecht.GESCHLECHT_ID IS NULL THEN 0 ELSE dGeschlecht.GESCHLECHT_ID END 
            ELSE PatStamm.Geschlecht_Akt END AS GESCHLECHT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.PLZ ELSE PatStamm.PLZ_AKT END AS PLZ,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.WOHNORT ELSE PatStamm.ORT_AKT END AS WOHNORT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.STRASSE + ' ' + ISNULL(schein.HAUSNUMMER,'') ELSE PatStamm.STRASSE_AKT END AS STRASSE,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.LAENDERCODE ELSE PatStamm.LAENDERCODE_AKT END AS LAENDERCODE,
        schein.DWH_ZEITRAUM
    FROM dbo.M20_HIS_T_01AB100_PATID_MAPPING map
        INNER JOIN dbo.M20_HIS_T_01AB100_SCHEINE schein
            ON map.scheinid = schein.SCHEINID AND map.mengenid = schein.MENGENID
            AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.Datenkoerper = 'BEARBEITET'
        LEFT JOIN #PatStammNeuVSDM ON map.Pat_pseudo_ID = #PatStammNeuVSDM.Pat_pseudo_ID
        LEFT JOIN dbo.M20_HIS_TD_01AB000_PATID_MASTER PatStamm ON map.PAT_PSEUDO_ID = PatStamm.PAT_ID
        LEFT JOIN dbo.M20_HIS_T_80ALL00_GESCHLECHT dGeschlecht ON schein.GESCHLECHT = dGeschlecht.GESCHLECHT_BESCHREIBUNG
    WHERE #PatStammNeuVSDM.Pat_pseudo_ID IS NULL AND schein.DWH_ZEITRAUM <= @Quartal
    
    UNION ALL
    
    -- UNBEARBEITET records
    SELECT
        map.Pat_pseudo_ID,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.EGKVERSICHERTENNUMMER ELSE PatStamm.EGKVNR END AS EGKVERSICHERTENNUMMER,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.VORNAME ELSE PatStamm.VORNAME_AKT END AS VORNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.NACHNAME ELSE PatStamm.NAME_AKT END AS NACHNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN TRY_CONVERT(DATE, CASE 
            WHEN schein.GEBURTSDATUM LIKE '%0000' THEN CONCAT(LEFT(schein.GEBURTSDATUM,5), '101')
            WHEN schein.GEBURTSDATUM LIKE '%00' THEN CONCAT(LEFT(schein.GEBURTSDATUM,7), '1')
            ELSE schein.GEBURTSDATUM END, 112) ELSE PatStamm.GEB_DATUM_AKT END AS GEBURTSDATUM,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN 
            CASE WHEN dGeschlecht.GESCHLECHT_ID IS NULL THEN 0 ELSE dGeschlecht.GESCHLECHT_ID END 
            ELSE PatStamm.Geschlecht_Akt END AS GESCHLECHT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.PLZ ELSE PatStamm.PLZ_AKT END AS PLZ,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.WOHNORT ELSE PatStamm.ORT_AKT END AS WOHNORT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.STRASSE + ' ' + ISNULL(schein.HAUSNUMMER,'') ELSE PatStamm.STRASSE_AKT END AS STRASSE,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.LAENDERCODE ELSE PatStamm.LAENDERCODE_AKT END AS LAENDERCODE,
        schein.DWH_ZEITRAUM
    FROM dbo.M20_HIS_T_01AB100_PATID_MAPPING map
        INNER JOIN dbo.M20_HIS_T_01AB100_SCHEINE_UNB schein
            ON map.scheinid = schein.SCHEINID AND map.mengenid = schein.MENGENID
            AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.Datenkoerper = 'UNBEARBEITET'
        LEFT JOIN #PatStammNeuVSDM ON map.Pat_pseudo_ID = #PatStammNeuVSDM.Pat_pseudo_ID
        LEFT JOIN dbo.M20_HIS_TD_01AB000_PATID_MASTER PatStamm ON map.PAT_PSEUDO_ID = PatStamm.PAT_ID
        LEFT JOIN dbo.M20_HIS_T_80ALL00_GESCHLECHT dGeschlecht ON schein.GESCHLECHT = dGeschlecht.GESCHLECHT_BESCHREIBUNG
    WHERE #PatStammNeuVSDM.Pat_pseudo_ID IS NULL AND schein.DWH_ZEITRAUM <= @Quartal
    
    UNION ALL
    
    -- KVUEPP records
    SELECT
        map.Pat_pseudo_ID,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.EGKVERSICHERTENNUMMER ELSE PatStamm.EGKVNR END AS EGKVERSICHERTENNUMMER,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.VORNAME ELSE PatStamm.VORNAME_AKT END AS VORNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.NACHNAME ELSE PatStamm.NAME_AKT END AS NACHNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN TRY_CONVERT(DATE, CASE 
            WHEN schein.GEBURTSDATUM LIKE '%0000' THEN CONCAT(LEFT(schein.GEBURTSDATUM,5), '101')
            WHEN schein.GEBURTSDATUM LIKE '%00' THEN CONCAT(LEFT(schein.GEBURTSDATUM,7), '1')
            ELSE schein.GEBURTSDATUM END, 112) ELSE PatStamm.GEB_DATUM_AKT END AS GEBURTSDATUM,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN 
            CASE WHEN dGeschlecht.GESCHLECHT_ID IS NULL THEN 0 ELSE dGeschlecht.GESCHLECHT_ID END 
            ELSE PatStamm.Geschlecht_Akt END AS GESCHLECHT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.PLZ ELSE PatStamm.PLZ_AKT END AS PLZ,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.WOHNORT ELSE PatStamm.ORT_AKT END AS WOHNORT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.STRASSE + ' ' + ISNULL(schein.HAUSNUMMER,'') ELSE PatStamm.STRASSE_AKT END AS STRASSE,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.LAENDERCODE ELSE PatStamm.LAENDERCODE_AKT END AS LAENDERCODE,
        schein.DWH_ZEITRAUM
    FROM dbo.M20_HIS_T_01AB100_PATID_MAPPING map
        INNER JOIN dbo.M20_HIS_T_01AB100_SCHEINE_UNB_KVUEPP schein
            ON map.scheinid = schein.SCHEINID AND map.mengenid = schein.MENGENID
            AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.Datenkoerper = 'KVUEPP'
        LEFT JOIN #PatStammNeuVSDM ON map.Pat_pseudo_ID = #PatStammNeuVSDM.Pat_pseudo_ID
        LEFT JOIN dbo.M20_HIS_TD_01AB000_PATID_MASTER PatStamm ON map.PAT_PSEUDO_ID = PatStamm.PAT_ID
        LEFT JOIN dbo.M20_HIS_T_80ALL00_GESCHLECHT dGeschlecht ON schein.GESCHLECHT = dGeschlecht.GESCHLECHT_BESCHREIBUNG
    WHERE #PatStammNeuVSDM.Pat_pseudo_ID IS NULL AND schein.DWH_ZEITRAUM <= @Quartal
    
    UNION ALL
    
    -- KS_SK_PATIENT records (different schema)
    SELECT
        map.Pat_pseudo_ID,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.EGKVNR ELSE PatStamm.EGKVNR END AS EGKVERSICHERTENNUMMER,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.VORNAME ELSE PatStamm.VORNAME_AKT END AS VORNAME,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.NAME ELSE PatStamm.NAME_AKT END AS [NAME],
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN TRY_CONVERT(date, schein.GEB_DATUM, 120) ELSE PatStamm.GEB_DATUM_AKT END AS GEBURTSDATUM,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN ISNULL(TRY_CONVERT(int, schein.Geschlecht), ISNULL(dGeschlecht.GESCHLECHT_ID, 0))
            ELSE PatStamm.Geschlecht_Akt END AS GESCHLECHT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.PLZ ELSE PatStamm.PLZ_AKT END AS PLZ,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.ORT ELSE PatStamm.ORT_AKT END AS WOHNORT,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.STRASSE ELSE PatStamm.STRASSE_AKT END AS STRASSE,
        CASE WHEN schein.DWH_ZEITRAUM > 20200 THEN schein.LAENDERCODE ELSE PatStamm.LAENDERCODE_AKT END AS LAENDERCODE,
        schein.DWH_ZEITRAUM
    FROM dbo.M20_HIS_T_01AB200_PATID_MAPPING map
        LEFT JOIN dbo.M20_HIS_T_01AB200_KS_SK_PATIENT schein
            ON map.SK_IDENT = schein.SK_IDENT AND map.DWH_ZEITRAUM = schein.DWH_ZEITRAUM AND map.AUSFUHR_ID = schein.AUSFUHR_ID
        LEFT JOIN #PatStammNeuVSDM ON map.Pat_pseudo_ID = #PatStammNeuVSDM.Pat_pseudo_ID
        LEFT JOIN dbo.M20_HIS_TD_01AB000_PATID_MASTER PatStamm ON map.PAT_PSEUDO_ID = PatStamm.PAT_ID
        LEFT JOIN dbo.M20_HIS_T_80ALL00_GESCHLECHT dGeschlecht ON schein.GESCHLECHT = dGeschlecht.GESCHLECHT_BESCHREIBUNG
    WHERE #PatStammNeuVSDM.Pat_pseudo_ID IS NULL AND map.DWH_ZEITRAUM <= @Quartal
),
Scores AS (
    SELECT
        Pat_pseudo_ID, EGKVERSICHERTENNUMMER, VORNAME, NACHNAME, GEBURTSDATUM, GESCHLECHT, PLZ, WOHNORT, STRASSE, LAENDERCODE,
        MIN(DWH_ZEITRAUM) minZeitraum,
        MAX(DWH_ZEITRAUM) maxZeitraum,
        -- Time-decay score: recent records weighted higher (exponential decay λ=0.25)
        ROUND(SUM(EXP(-0.25 * ((@now - DWH_ZEITRAUM) / 10 * 4 + (@now - DWH_ZEITRAUM) % 10))), 4) AS Score,
        -- Completeness penalty: count of NULL columns
        AVG(CASE WHEN EGKVERSICHERTENNUMMER IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN VORNAME IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN NACHNAME IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN GEBURTSDATUM IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN PLZ IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN WOHNORT IS NULL THEN 1 ELSE 0 END + 
            CASE WHEN STRASSE IS NULL THEN 1 ELSE 0 END +
            CASE WHEN LAENDERCODE IS NULL THEN 1 ELSE 0 END) AS NullCols,
        COUNT(*) Anzahl
    FROM ScheineUnion
    WHERE Pat_pseudo_ID NOT IN (0,-1)
    GROUP BY Pat_pseudo_ID, EGKVERSICHERTENNUMMER, VORNAME, NACHNAME, GEBURTSDATUM, GESCHLECHT, PLZ, WOHNORT, STRASSE, LAENDERCODE
),
OrderedVariants AS (
    SELECT *,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(WOHNORT), 'ß', 'SS'), 'Ä', 'AE'), 'Ö', 'OE'), 'Ü', 'UE') AS WOHNORT_Korr,
        -- Rank by: highest score → fewest nulls → most recent
        ROW_NUMBER() OVER (PARTITION BY Pat_pseudo_ID ORDER BY Score DESC, NullCols ASC, maxZeitraum DESC) [Rank]
    FROM Scores
),
PlzStadt AS (
    SELECT 
        PLZ, Stadt,
        REPLACE(REPLACE(REPLACE(REPLACE(UPPER(Stadt), 'ß', 'SS'), 'Ä', 'AE'), 'Ö', 'OE'), 'Ü', 'UE') AS Stadt_Korr,
        Bundeslandcode, Kennziffer,
        Bundeslandcode + Kennziffer AS ORTSKENNZAHL,
        ISNULL(OKZ, Bundeslandcode + Kennziffer + '000') AS OKZ,
        COUNT(*) OVER (PARTITION BY PLZ) AS Num
    FROM dbo.M20_HIS_T_02SIC00_PLZ_STADT
)

SELECT 
    Pat_pseudo_ID,
    CONVERT(varchar(10), EGKVERSICHERTENNUMMER) AS EGKVERSICHERTENNUMMER,
    CONVERT(varchar(255), NACHNAME) AS NACHNAME,
    CONVERT(varchar(255), VORNAME) AS VORNAME,
    GEBURTSDATUM,
    GESCHLECHT,
    CONVERT(varchar(5), OrderedVariants.PLZ) AS PLZ,
    ISNULL(UniquePLZs.Stadt, ISNULL(mapPLZ.Stadt, ISNULL(mapPLZ2.Stadt, 
        ISNULL(mapPLZ3.Stadt, ISNULL(mapPLZ4.Stadt, ISNULL(mapPLZ5.Stadt, OrderedVariants.WOHNORT)))))) AS WOHNORT,
    CONVERT(varchar(300), STRASSE) AS STRASSE,
    LAENDERCODE,
    ISNULL(UniquePLZs.ORTSKENNZAHL, ISNULL(mapPLZ.ORTSKENNZAHL, ISNULL(mapPLZ2.ORTSKENNZAHL, 
        ISNULL(mapPLZ3.ORTSKENNZAHL, ISNULL(mapPLZ4.ORTSKENNZAHL, mapPLZ5.ORTSKENNZAHL))))) AS ORTSKENNZAHL,
    ISNULL(UniquePLZs.OKZ, ISNULL(mapPLZ.OKZ, ISNULL(mapPLZ2.OKZ, 
        ISNULL(mapPLZ3.OKZ, ISNULL(mapPLZ4.OKZ, mapPLZ5.OKZ))))) AS OKZ,
    NULL AS GEO_X,
    NULL AS GEO_Y
INTO #PatStammNeuScore
FROM OrderedVariants
    LEFT JOIN PlzStadt UniquePLZs ON OrderedVariants.PLZ = UniquePLZs.PLZ AND UniquePLZs.Num = 1
    LEFT JOIN (SELECT PLZ, Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, Stadt ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ
        ON OrderedVariants.PLZ = mapPLZ.PLZ AND OrderedVariants.WOHNORT_Korr = mapPLZ.Stadt AND UniquePLZs.PLZ IS NULL AND mapPLZ.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 15) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 15) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ2
        ON OrderedVariants.PLZ = mapPLZ2.PLZ AND LEFT(OrderedVariants.WOHNORT_Korr, 15) = mapPLZ2.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 11) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 11) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ3
        ON OrderedVariants.PLZ = mapPLZ3.PLZ AND LEFT(OrderedVariants.WOHNORT_Korr, 11) = mapPLZ3.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 7) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 7) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ4
        ON OrderedVariants.PLZ = mapPLZ4.PLZ AND LEFT(OrderedVariants.WOHNORT_Korr, 7) = mapPLZ4.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.PLZ IS NULL AND mapplz4.RowNum = 1
    LEFT JOIN (SELECT PLZ, LEFT(Stadt_Korr, 3) AS Stadt_Korr, Stadt, ORTSKENNZAHL, OKZ, ROW_NUMBER() OVER (PARTITION BY PLZ, LEFT(Stadt_Korr, 3) ORDER BY Kennziffer) AS RowNum FROM PlzStadt) mapPLZ5
        ON OrderedVariants.PLZ = mapPLZ5.PLZ AND LEFT(OrderedVariants.WOHNORT_Korr, 3) = mapPLZ5.Stadt_Korr AND UniquePLZs.PLZ IS NULL AND mapplz.PLZ IS NULL AND mapplz2.PLZ IS NULL AND mapplz3.PLZ IS NULL AND mapplz4.PLZ IS NULL AND mapplz5.RowNum = 1
WHERE [Rank] = 1;

-- =============================================================================
-- STEP 3: Final Insert into PATIENTEN_STAMM
-- =============================================================================

DELETE FROM dbo.M20_HIS_T_01AB000_PATIENTEN_STAMM WHERE Quartal = @Quartal;

-- Dummy records for unknown patients
INSERT INTO dbo.M20_HIS_T_01AB000_PATIENTEN_STAMM
    ([PAT_ID], EGKVNR, [NAME], [VORNAME], GEB_DATUM, GESCHLECHT, PLZ, ORT, STRASSE, LAENDERCODE, ORTSKENNZAHL, OKZ, GEO_X, GEO_Y, Quartal, [DWH_LOAD_DATE])
VALUES 
    (0, '_unbekannt', '_unbekannt', '_unbekannt', '1800-01-01', 0, '00000', '_unbekannt', '_unbekannt', 'AAA', '-1', '-1', 0, 0, @Quartal, @LoadDate),
    (-1, '_unbekannt', '_unbekannt', '_unbekannt', '1800-01-01', 0, '00000', '_unbekannt', '_unbekannt', 'AAA', '-1', '-1', 0, 0, @Quartal, @LoadDate);

-- Insert consolidated patient records
INSERT INTO dbo.M20_HIS_T_01AB000_PATIENTEN_STAMM
    ([PAT_ID], EGKVNR, [NAME], [VORNAME], GEB_DATUM, GESCHLECHT, PLZ, ORT, STRASSE, LAENDERCODE, ORTSKENNZAHL, OKZ, GEO_X, GEO_Y, Quartal, [DWH_LOAD_DATE])
SELECT *, @Quartal, @LoadDate FROM #PatStammNeuVSDM
UNION ALL
SELECT *, @Quartal, @LoadDate FROM #PatStammNeuScore;
