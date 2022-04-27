--How might you fix this?
DROP TABLE IF EXISTS ##User;
GO
DECLARE @Test VARCHAR(MAX) = 'Tom,Dick,Harry,';

CREATE TABLE ##User
	(
	FirstName VARCHAR(4) CONSTRAINT CK_MinNameLength CHECK (LEN(FirstName) > 0)
	);

WITH cteUsers
	AS
	(
	SELECT FirstName = value
		FROM STRING_SPLIT(@Test, ',', 0)
	)
	INSERT ##User
		SELECT *
			FROM cteUsers;