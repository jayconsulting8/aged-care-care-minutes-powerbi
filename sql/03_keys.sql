/*
    03_keys.sql
    Adds the primary key on Homes and foreign keys from each fact table
    to the Homes and Date dimension tables.
    (The Roles foreign key is in 02_roles_table.sql.)
    If any of these fail, some fact rows do not match a home or a date.
*/

USE CareMinutes;
GO

-- Primary key on Homes
ALTER TABLE dbo.Homes
    ADD CONSTRAINT PK_Homes PRIMARY KEY (HomeID);
GO

-- DailyOccupancy
ALTER TABLE dbo.DailyOccupancy
    ADD CONSTRAINT FK_DailyOccupancy_Homes FOREIGN KEY (HomeID) REFERENCES dbo.Homes (HomeID),
        CONSTRAINT FK_DailyOccupancy_Date  FOREIGN KEY ([Date]) REFERENCES dbo.[Date] ([Date]);
GO

-- StaffHours
ALTER TABLE dbo.StaffHours
    ADD CONSTRAINT FK_StaffHours_Homes FOREIGN KEY (HomeID) REFERENCES dbo.Homes (HomeID),
        CONSTRAINT FK_StaffHours_Date  FOREIGN KEY ([Date]) REFERENCES dbo.[Date] ([Date]);
GO

-- QualityIndicators (Month holds the first day of each month)
ALTER TABLE dbo.QualityIndicators
    ADD CONSTRAINT FK_QualityIndicators_Homes FOREIGN KEY (HomeID)  REFERENCES dbo.Homes (HomeID),
        CONSTRAINT FK_QualityIndicators_Date  FOREIGN KEY ([Month]) REFERENCES dbo.[Date] ([Date]);
GO
