DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	Age INT
	);

INSERT #Test
	(
	NameEn,
	DateOfBirth
	)
	SELECT 'Tom', '1 JAN 1960'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970'
	UNION ALL
	SELECT 'Harry', '1 JAN 2000';

--UPDATE #Test SET Age = ? --How might you populate column "Age" with the correct value

SELECT * FROM #Test;