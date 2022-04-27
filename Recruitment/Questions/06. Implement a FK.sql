--Implement a foreign key between these two tables...
DROP TABLE IF EXISTS interview.User_User;
DROP TABLE IF EXISTS interview.User_Role;
GO
CREATE TABLE interview.User_Role
	(
	RoleId INT NOT NULL CONSTRAINT PK_User_Role PRIMARY KEY IDENTITY,
	RoleCode VARCHAR(20) CONSTRAINT UQ_User_Role_RoleCode UNIQUE NOT NULL,
	RoleDescription VARCHAR(1000),
	CreatedDateTime DATETIME NOT NULL
		CONSTRAINT DF_User_Role_CreatedDateTime DEFAULT GETDATE()
	);

INSERT interview.User_Role
	(
	RoleCode
	)
	SELECT RoleCode = value
		FROM STRING_SPLIT('ANALYST,CLIENT,ADMINISTRATOR', ',', 0);

CREATE TABLE interview.User_User
	(
	UserId INT CONSTRAINT PK_User_User PRIMARY KEY,
	FirstName VARCHAR(5)
	);

SELECT * FROM interview.User_Role;
SELECT * FROM interview.User_User;
