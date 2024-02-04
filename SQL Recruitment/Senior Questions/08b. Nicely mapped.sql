--How might you fix this?
DROP TABLE IF EXISTS interview.User_User;
DROP TABLE IF EXISTS interview.User_Role
GO
CREATE TABLE interview.User_User
	(
	UserId INT CONSTRAINT PK_User_User PRIMARY KEY,
	FirstName VARCHAR(5),
	RoleId INT NOT NULL
	);

CREATE TABLE interview.User_Role
	(
	RoleId INT NOT NULL CONSTRAINT PK_User_Role PRIMARY KEY IDENTITY,
	RoleCode VARCHAR(20) CONSTRAINT UQ_User_Role_RoleCode UNIQUE NOT NULL
	);
INSERT interview.User_Role
	SELECT RoleCode = value
		FROM STRING_SPLIT('ANALYST,CLIENT,ADMINISTRATOR', ',', 1);

DECLARE @Test VARCHAR(MAX) = '
[
	{
		"UserId": 1,
		"FirstName": "Tom",
		"RoleCode": "ANALYST"
	},
	{
		"UserId": 2,
		"FirstName": "Dick",
		"RoleCode": "ANALYST"
	},
	{
		"UserId": 3,
		"FirstName": "Harry",
		"RoleCode": "CLIENT"
	},
	{
		"UserId": 4,
		"FirstName": "Admin",
		"RoleCode": "SYSADMIN"
	}
]';

DROP TABLE IF EXISTS #Mapping
CREATE TABLE #Mapping
	(
	From_RoleCode VARCHAR(20),
	To_RoleId INT
	);
INSERT #Mapping
	SELECT From_RoleCode = 'SYSADMIN',
		To_RoleCode = 3; --ADMINISTRATOR

INSERT interview.User_User
	SELECT j.UserId,
		j.FirstName,
		RoleId = ISNULL(r.RoleId, m.To_RoleId)
		FROM OPENJSON(@Test)
			WITH (
				UserId INT,
				FirstName VARCHAR(10),
				RoleCode VARCHAR(20)
				) AS j
			LEFT OUTER JOIN interview.User_Role AS r
				ON j.RoleCode = r.RoleCode
			LEFT OUTER JOIN #Mapping AS m
				ON j.RoleCode = m.From_RoleCode;