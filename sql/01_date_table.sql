/*
    01_date_table.sql
    Builds the Date dimension table: one row per day from 1 Jul 2025 to 30 Jun 2026.
    Weeks start on Monday.
*/

USE CareMinutes;
GO

CREATE TABLE dbo.[Date] (
    [Date]          date        NOT NULL PRIMARY KEY,
    [Year]          int         NOT NULL,
    [Month Number]  int         NOT NULL,
    [Month]         varchar(8)  NOT NULL,   -- e.g. Jul 2025
    [Month Sort]    int         NOT NULL,   -- e.g. 202507, used to sort months in Power BI
    [Week Start]    date        NOT NULL    -- Monday of the week
);
GO

INSERT INTO dbo.[Date] ([Date], [Year], [Month Number], [Month], [Month Sort], [Week Start])
SELECT
    d,
    YEAR(d),
    MONTH(d),
    FORMAT(d, 'MMM yyyy', 'en-US'),
    YEAR(d) * 100 + MONTH(d),
    DATEADD(day, -(DATEDIFF(day, '19000101', d) % 7), d)   -- 1 Jan 1900 was a Monday
FROM (
    SELECT DATEADD(day, value, '20250701') AS d
    FROM GENERATE_SERIES(0, DATEDIFF(day, '20250701', '20260630'))
) AS days;
GO

-- Check: 365 rows, and 1 Jul 2025 has Week Start 30 Jun 2025
SELECT COUNT(*) AS DaysInTable FROM dbo.[Date];
SELECT TOP 3 * FROM dbo.[Date] ORDER BY [Date];
GO
