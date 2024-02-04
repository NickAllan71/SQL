DROP TABLE IF EXISTS #Test;
--Define a table to store the dataset below...

--INSERT #Test
	SELECT NameEn = 'Tom',
		DateOfBirth = '1 JAN 1960',
		GenderId = 'M'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970', 'M'
	UNION ALL
	SELECT 'Harriet', '1 JAN 2000','F';