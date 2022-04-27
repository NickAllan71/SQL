/*
Improve on the design of this table.  Requirements are:
	- Must reside in schema [interview]
	- RoleId must auto-increment and will be referenced via foriegn key
	- RoleCode is mandatory and cannot be duplicated
	- Additional column needed to describe each role
	- Record date/time that row was inserted
*/
DROP TABLE IF EXISTS #Role
SELECT RoleId = ordinal,
	RoleCode = value
	INTO #Role
	FROM STRING_SPLIT('ANALYST,CLIENT,ADMINISTRATOR', ',', 1);

SELECT * FROM #Role;