/*
    02_roles_table.sql
    Builds the Roles dimension table and links it to StaffHours.
    RoleDescription is shown in the Power BI charts instead of the short codes.
    SortOrder keeps the roles in a fixed order (RN, EN, PCW).
*/

USE CareMinutes;
GO

CREATE TABLE dbo.Roles (
    Role             nvarchar(50)  NOT NULL PRIMARY KEY,
    RoleDescription  nvarchar(100) NOT NULL,
    SortOrder        int           NOT NULL
);
GO

INSERT INTO dbo.Roles (Role, RoleDescription, SortOrder)
VALUES
    ('RN',  'Registered Nurse',     1),
    ('EN',  'Enrolled Nurse',       2),
    ('PCW', 'Personal Care Worker', 3);
GO

-- Every role in StaffHours must exist in Roles
ALTER TABLE dbo.StaffHours
    ADD CONSTRAINT FK_StaffHours_Roles
    FOREIGN KEY (Role) REFERENCES dbo.Roles (Role);
GO

-- Check: should list RN, EN, PCW only
SELECT DISTINCT Role FROM dbo.StaffHours;
SELECT * FROM dbo.Roles ORDER BY SortOrder;
GO
