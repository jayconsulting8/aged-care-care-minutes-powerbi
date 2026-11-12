/*
    05_validation.sql
    Checks the Power BI report against the source data.

    Query 1: care minutes per resident per day and the gap to target,
             by home and month. Matches the "Minutes above or below target
             by month" matrix in the report.

    Query 2: falls and pressure injuries per 100 residents assessed,
             next to the gap to target, by home and month.

    Hours and occupancy are added up separately first. StaffHours has many
    rows per home per day (one per role and staff type), so joining it
    straight to DailyOccupancy would count the beds many times.
*/

USE CareMinutes;
GO

/* ---------- Query 1: care minutes against target ---------- */

WITH Hrs AS (
    SELECT
        HomeID,
        DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) AS MonthStart,
        SUM(Hours) AS CareHours
    FROM dbo.StaffHours
    GROUP BY HomeID, DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
),
Occ AS (
    SELECT
        HomeID,
        DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) AS MonthStart,
        AVG(OccupiedBeds * 1.0) AS AvgResidents,
        SUM(OccupiedBeds)       AS ResidentDays
    FROM dbo.DailyOccupancy
    GROUP BY HomeID, DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
)
SELECT
    h.HomeName,
    o.MonthStart,
    CAST(o.AvgResidents AS decimal(6,1))                          AS AvgResidents,
    CAST(hr.CareHours AS decimal(10,0))                           AS CareHours,
    CAST(hr.CareHours * 60.0 / o.ResidentDays AS decimal(6,1))    AS MinutesPerResidentPerDay,
    h.TotalMinutesTarget,
    CAST(hr.CareHours * 60.0 / o.ResidentDays
         - h.TotalMinutesTarget AS decimal(6,1))                  AS VsTarget
FROM Occ o
JOIN Hrs hr      ON hr.HomeID = o.HomeID AND hr.MonthStart = o.MonthStart
JOIN dbo.Homes h ON h.HomeID  = o.HomeID
ORDER BY h.HomeName, o.MonthStart;
GO

/* ---------- Query 2: quality indicators next to the gap to target ---------- */

WITH Hrs AS (
    SELECT HomeID,
           DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) AS MonthStart,
           SUM(Hours) AS CareHours
    FROM dbo.StaffHours
    GROUP BY HomeID, DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
),
Occ AS (
    SELECT HomeID,
           DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) AS MonthStart,
           SUM(OccupiedBeds) AS ResidentDays
    FROM dbo.DailyOccupancy
    GROUP BY HomeID, DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1)
),
QI AS (
    SELECT HomeID,
           [Month] AS MonthStart,
           SUM(CASE WHEN Indicator = 'Falls' THEN [Count] END) * 100.0
               / MAX(ResidentsAssessed) AS FallsPer100,
           SUM(CASE WHEN Indicator = 'Pressure injuries' THEN [Count] END) * 100.0
               / MAX(ResidentsAssessed) AS PressurePer100
    FROM dbo.QualityIndicators
    GROUP BY HomeID, [Month]
)
SELECT h.HomeName,
       o.MonthStart,
       CAST(hr.CareHours * 60.0 / o.ResidentDays
            - h.TotalMinutesTarget AS decimal(6,1)) AS VsTarget,
       CAST(q.FallsPer100    AS decimal(6,1))       AS FallsPer100,
       CAST(q.PressurePer100 AS decimal(6,1))       AS PressurePer100
FROM Occ o
JOIN Hrs hr      ON hr.HomeID = o.HomeID AND hr.MonthStart = o.MonthStart
JOIN QI q        ON q.HomeID  = o.HomeID AND q.MonthStart  = o.MonthStart
JOIN dbo.Homes h ON h.HomeID  = o.HomeID
ORDER BY h.HomeName, o.MonthStart;
GO
