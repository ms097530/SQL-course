CREATE DATABASE DotNetCourseDatabase
GO

USE DotNetCourseDatabase
GO

SELECT *
FROM TutorialAppSchema.Users
GO

SELECT *
FROM TutorialAppSchema.UserJobInfo
GO

CREATE SCHEMA TutorialAppSchema
GO

CREATE TABLE TutorialAppSchema.Computer
(
    -- ID of type INT where IDENTITY() makes it increment on each additional insertion
    -- TableId INT IDENTITY(Starting, IncrementBy)
    -- PRIMARY KEY makes it unique and stores values sorted by this field
    ComputerId INT IDENTITY(1,1) PRIMARY KEY,
    -- Motherboard CHAR(10) store as 'x' results in 'x         '
    -- Motherboard VARCHAR(10) store as 'x' results in 'x'
    -- Motherboard NVARCHAR(10) can store non-unicode (symbols)
    -- NVARCHAR(255) is standard, unless have more info to narrow down size
    Motherboard NVARCHAR(50),
    CPUCores INT,
    -- no boolean, use BIT because it can only be 0 or 1 (binary like boolean)
    HasWifi BIT,
    HasLTE BIT,
    -- DATE is just year, month, and day... DATETIME includes time
    -- DATETIME2 takes slightly more space for accuracy
    ReleaseDate DATETIME,
    -- using DECIMAL for better accuracy, 18 digits 4 places after decimal
    Price DECIMAL(18,4),
    VideoCard NVARCHAR(50)
)



-- makes it so you can insert value for IDENTITY
-- make sure to turn off after done using
-- SET IDENTITY_INSERT TutorialAppSchema.Computer ON

INSERT INTO TutorialAppSchema.Computer
(
    -- NOTE: not inserting with primary key
    [Motherboard],
    [CPUCores],
    [HasWifi],
    [HasLTE],
    [ReleaseDate],
    [Price],
    [VideoCard]
) VALUES 
(
    'Sample-Motherboard',
    4,
    1,
    0,
    -- will fill in time with 00:00:00
    '2022-01-01',
    1000,
    'Sample-Videocard'
)

DELETE FROM TutorialAppSchema.Computer WHERE ComputerId = 119

SELECT [ComputerId],
[Motherboard],
-- use ISNULL to say if corresponding value is NULL, display 2nd arg as value
-- doesn't alter actual data
-- SQL Server no longer shows column name if using this, alias result to show a name
ISNULL([CPUCores], 4) AS CPUCores,
[HasWifi],
[HasLTE],
[ReleaseDate],
[Price],
[VideoCard] FROM TutorialAppSchema.Computer

-- use ORDER BY clause to sort returned data
-- sorts ASC by default, use DESC to invert
-- earlier vals for ORDER BY are sorted first
SELECT * FROM TutorialAppSchema.Computer ORDER BY HasWifi DESC, ReleaseDate

-- as is, this would set CPUCores to 4 for all rows, use WHERE clause to get specific
-- UPDATE TutorialAppSchema.Computer SET CPUCores = 4
UPDATE TutorialAppSchema.Computer SET CPUCores = 69 WHERE ComputerId = 118
-- update CPUCores for Computers with ReleaseDate before Jan 1 2017
UPDATE TutorialAppSchema.Computer SET CPUCores = 2 WHERE ReleaseDate < '2017-01-01'
UPDATE TutorialAppSchema.Computer SET CPUCores = NULL WHERE ReleaseDate > '2017-01-01'