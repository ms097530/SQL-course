USE DotNetCourseDatabase
GO

SELECT [Users].[UserId],
    -- Field/Value alias
    [Users].[FirstName] + ' ' + [Users].[LastName] AS FullName,
    [Users].[Email],
    [Users].[Gender],
    -- Table alias
    [Users].[Active]
FROM TutorialAppSchema.Users AS Users
-- Put WHERE clause BEFORE ORDER BY clause
-- WHERE SUBSTRING(FirstName, 1, 1) = 'S' -- <- checking if first character of name is 'S'
WHERE Users.Active = 1
ORDER BY Users.UserId DESC

-- JOIN demo - each User has a single UserJobInfo entry
SELECT [Users].[UserId],
    -- Field/Value alias
    [Users].[FirstName] + ' ' + [Users].[LastName] AS FullName,
    [Users].[Email],
    [Users].[Gender],
    [Users].[Active],
    [UserJobInfo].[JobTitle],
    [UserJobInfo].[Department]
FROM TutorialAppSchema.Users AS Users -- Table alias
    -- INNER JOIN - default is INNER JOIN
    JOIN TutorialAppSchema.UserJobInfo
    ON Users.UserId = UserJobInfo.UserId
WHERE Users.Active = 1 AND UserJobInfo.JobTitle = 'Nurse'
ORDER BY Users.UserId DESC

-- BETWEEN is inclusive of lower and upper bounds
DELETE FROM TutorialAppSchema.UserSalary WHERE UserId BETWEEN 250 AND 750

-- JOIN demo - each User has a single UserJobInfo entry
SELECT [Users].[UserId],
    -- Field/Value alias
    [Users].[FirstName] + ' ' + [Users].[LastName] AS FullName,
    [Users].[Email],
    [Users].[Gender],
    [Users].[Active],
    [UserSalary].[Salary],
    [UserJobInfo].[JobTitle],
    [UserJobInfo].[Department]
FROM TutorialAppSchema.Users AS Users -- Table alias
    -- INNER JOIN - Users without UserSalary entry will not be shown
    JOIN TutorialAppSchema.UserSalary AS UserSalary
    ON UserSalary.UserId = Users.UserId
    -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
    LEFT JOIN TutorialAppSchema.UserJobInfo
    ON Users.UserId = UserJobInfo.UserId
WHERE Users.Active = 1
ORDER BY Users.UserId DESC

SELECT [UserSalary].[UserId],
    [UserSalary].[Salary]
FROM TutorialAppSchema.UserSalary AS UserSalary
-- Only checks if matching record exists, doesn't pull data from
-- works similarly to JOIN but is faster due to not pulling data
WHERE EXISTS 
(
    SELECT *
    FROM TutorialAppSchema.UserJobInfo AS UserJobInfo
    WHERE UserId = UserSalary.UserId        
)
    -- <> is not equal
    AND UserId <> 7

-- use UNION to pick up DISTINCT rows between datasets
-- use UNION ALL to include non-distinct rows
    SELECT [UserId],
        [Salary]
    From TutorialAppSchema.UserSalary
UNION ALL
    SELECT [UserId],
        [Salary]
    From TutorialAppSchema.UserSalary


-- JOIN demo - each User has a single UserJobInfo entry
SELECT [Users].[UserId],
    -- Field/Value alias
    [Users].[FirstName] + ' ' + [Users].[LastName] AS FullName,
    [Users].[Email],
    [Users].[Gender],
    [Users].[Active],
    [UserSalary].[Salary],
    [UserJobInfo].[JobTitle],
    [UserJobInfo].[Department]
FROM TutorialAppSchema.Users AS Users -- Table alias
    -- Users without UserSalary entry will not be shown - INNER JOIN
    JOIN TutorialAppSchema.UserSalary AS UserSalary
    ON UserSalary.UserId = Users.UserId
    -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
    LEFT JOIN TutorialAppSchema.UserJobInfo
    ON Users.UserId = UserJobInfo.UserId
WHERE Users.Active = 1
ORDER BY Users.UserId DESC

-- create clustered index named cix_UserSalary_UserId 
-- clustered index optimizes ordering in physical storage of relevant data
-- clustered index is also included when using nonclustered index (searching using)
CREATE CLUSTERED INDEX cix_UserSalary_UserId ON TutorialAppSchema.UserSalary(UserId)

-- helps find JobTitle and Department
CREATE NONCLUSTERED INDEX ix_UserJobInfo_JobTitle ON TutorialAppSchema.UserJobInfo(JobTitle) INCLUDE (Department)

-- filtered index
CREATE NONCLUSTERED INDEX fix_Users_Active ON TutorialAppSchema.Users(Active) 
    INCLUDE ([Email], [FirstName], [LastName]) -- also includes UserId because it is our clustered index
        WHERE Active = 1



-- AGGREGATE FUNCTIONS
SELECT
    SUM([UserSalary].[Salary]) AS Salary,
    MIN([UserSalary].[Salary]) AS MinSalary,
    MAX([UserSalary].[Salary]) AS MaxSalary,
    AVG([UserSalary].[Salary]) AS AvgSalary,
    COUNT(*) AS PeopleInDepartment,
    -- gets UserIds associated with department and aggregates into string separated by provided delimiter
    STRING_AGG(Users.UserId, ', ') AS UserIds,
    ISNULL([UserJobInfo].[Department], 'No department listed') AS Department
FROM TutorialAppSchema.Users AS Users -- Table alias
    -- Users without UserSalary entry will not be shown - INNER JOIN
    JOIN TutorialAppSchema.UserSalary AS UserSalary
    ON UserSalary.UserId = Users.UserId
    -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
    LEFT JOIN TutorialAppSchema.UserJobInfo
    ON Users.UserId = UserJobInfo.UserId
WHERE Users.Active = 1
-- GROUP BY must be after WHERE and BEFORE ORDER BY
GROUP BY [UserJobInfo].[Department]
ORDER BY UserJobInfo.Department DESC


-- JOIN demo - each User has a single UserJobInfo entry
SELECT [Users].[UserId],
    -- Field/Value alias
    [Users].[FirstName] + ' ' + [Users].[LastName] AS FullName,
    [UserSalary].[Salary],
    [UserJobInfo].[JobTitle],
    [UserJobInfo].[Department],
    [DepartmentAverage].AvgSalary,
    [Users].[Email],
    [Users].[Gender],
    [Users].[Active]
FROM TutorialAppSchema.Users AS Users -- Table alias
    -- INNER JOIN - Users without UserSalary entry will not be shown
    JOIN TutorialAppSchema.UserSalary AS UserSalary
        ON UserSalary.UserId = Users.UserId
    -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
    LEFT JOIN TutorialAppSchema.UserJobInfo AS UserJobInfo
        ON UserJobInfo.UserId = Users.UserId
    OUTER APPLY (
        -- CAN ACCESS INFO FROM OUTSIDE IN THIS QUERY
        -- Aliases can become ambigious (hence some renamed with 2)
        SELECT ISNULL(UserJobInfo2.Department, 'No Department Listed') AS Department
                , AVG(UserSalary2.Salary) AS AvgSalary
            FROM TutorialAppSchema.UserSalary AS UserSalary2 -- Table alias
                -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
                LEFT JOIN TutorialAppSchema.UserJobInfo AS UserJobInfo2
                    ON UserJobInfo2.UserId = UserSalary2.UserId
                WHERE UserJobInfo2.Department = UserJobInfo.Department
                -- GROUP BY must be after WHERE and BEFORE ORDER BY
                GROUP BY UserJobInfo2.Department
    ) AS DepartmentAverage
WHERE Users.Active = 1
ORDER BY Users.UserId DESC;


-- get time SQL server is in
SELECT GETDATE()

--  DATEADD(TYPE_OF_TIME, NUMBER_OF_TIME, DATE_TO_ADD_TO)
SELECT DATEADD(MONTH, 2, GETDATE())

-- get number of days between current date and date 2 years from now
SELECT DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, 2, GETDATE()))  -- returns positive
SELECT DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, -2, GETDATE())) -- returns negative

-- add column to table
ALTER TABLE TutorialAppSchema.UserSalary ADD AvgSalary DECIMAL(18,4)

UPDATE UserSalary
    SET UserSalary.AvgSalary = DepartmentAverage.AvgSalary
FROM TutorialAppSchema.UserSalary AS UserSalary
    LEFT JOIN TutorialAppSchema.UserJobInfo AS UserJobInfo
        ON UserJobInfo.UserId = UserSalary.UserId
    CROSS APPLY (
        -- CAN ACCESS INFO FROM OUTSIDE IN THIS QUERY
        -- Aliases can become ambigious (hence some renamed with 2)
        SELECT ISNULL(UserJobInfo2.Department, 'No Department Listed') AS Department
                , AVG(UserSalary2.Salary) AS AvgSalary
            FROM TutorialAppSchema.UserSalary AS UserSalary2 -- Table alias
                -- LEFT JOIN - fills in NULL for values from "RIGHT" table in join where a match is not found
                LEFT JOIN TutorialAppSchema.UserJobInfo AS UserJobInfo2
                    ON UserJobInfo2.UserId = UserSalary2.UserId
                WHERE ISNULL(UserJobInfo2.Department, 'No Department Listed') = ISNULL(UserJobInfo.Department, 'No Department Listed')
                -- GROUP BY must be after WHERE and BEFORE ORDER BY
                GROUP BY UserJobInfo2.Department
    ) AS DepartmentAverage

SELECT * FROM TutorialAppSchema.UserSalary