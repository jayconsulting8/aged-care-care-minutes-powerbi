/*
    04_fix_data_types.sql
    Hours was imported as float, which stores some decimals inexactly
    (for example 37.40000153 instead of 37.4).
    Changing it to decimal(6,1) stores the values exactly.
*/

USE CareMinutes;
GO

-- Before: shows the long decimals
SELECT TOP 5 [Date], HomeID, Role, StaffType, Hours FROM dbo.StaffHours;
GO

ALTER TABLE dbo.StaffHours
    ALTER COLUMN Hours decimal(6,1) NOT NULL;
GO

-- After: values should show one decimal place
SELECT TOP 5 [Date], HomeID, Role, StaffType, Hours FROM dbo.StaffHours;
GO
