--How might you fix this?
DROP TABLE IF EXISTS ##User;
GO
DECLARE @Test VARCHAR(MAX) = 'Tom,Dick,Harry,';

CREATE TABLE ##User
	(
	NameId INT IDENTITY PRIMARY KEY,
	FirstName VARCHAR(5) CONSTRAINT CK_MinNameLength CHECK (LEN(FirstName) > 0)
	);

WITH cteUsers
	AS
	(
	SELECT NameId = ordinal,
		FirstName = NULLIF(value, '')
		FROM STRING_SPLIT(@Test, ',', 1)
	)
	INSERT ##User
		SELECT *
			FROM cteUsers;