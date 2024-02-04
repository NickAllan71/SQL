DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	Age INT NOT NULL
	);
--How would you fix this issue?
INSERT #Test
	SELECT 'Tom', NULL;