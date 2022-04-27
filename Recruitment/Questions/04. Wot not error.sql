--How might you fix this?
DROP TABLE IF EXISTS ##User;
GO
DECLARE @Test VARCHAR(MAX) = 'Tom,Dick,Harry,';

CREATE TABLE ##User
	(
	NameId INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(5) CONSTRAINT CK_MinNameLength CHECK (LEN(FirstName) > 0)
	);

SET IDENTITY_INSERT ##User ON;
WITH cteUsers
	AS
	(
	SELECT NameId = ordinal,
		FirstName = NULLIF(value, '')
		FROM STRING_SPLIT(@Test, ',', 1)
	)
	INSERT ##User
		(
		NameId,
		FirstName
		)
		SELECT *
			FROM cteUsers;
SET IDENTITY_INSERT ##User OFF;

SELECT NameId,
	FirstName = ISNULL(FirstName, '(no name)')
	FROM ##User;