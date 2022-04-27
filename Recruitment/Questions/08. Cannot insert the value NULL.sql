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

INSERT interview.User_User
	SELECT j.UserId,
		j.FirstName,
		r.RoleId
		FROM OPENJSON(@Test)
			WITH (
				UserId INT,
				FirstName VARCHAR(10),
				RoleCode VARCHAR(20)
				) AS j
			LEFT OUTER JOIN interview.User_Role AS r
				ON j.RoleCode = r.RoleCode;