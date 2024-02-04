DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	GenderId CHAR(1)
	);

--How might you fix this issue?
INSERT #Test
	(
	NameEn,
	DOB,
	GenderId
	)
	SELECT NameEn = 'Tom',
		DOB = '1 JAN 1960',
		GenderId = 'Male'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970', 'Male'
	UNION ALL
	SELECT 'Harriet', '1 JAN 2000','Female';