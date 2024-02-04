DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	GenderId CHAR(1)
	);

INSERT #Test
	(
	NameEn,
	DateOfBirth,
	GenderId
	)
	SELECT NameEn = 'Tom',
		DateOfBirth = '1 JAN 1960',
		GenderId = 'M'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970', 'M'
	UNION ALL
	SELECT 'Harriet', '1 JAN 2000','F';

--How might you obtain the oldest person?
SELECT *
	FROM #Test;