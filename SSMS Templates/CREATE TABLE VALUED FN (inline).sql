DROP FUNCTION IF EXISTS <SchemaFunctionName, SYSNAME, dbo.fn_Your_FunctionName>;
GO
/*

Description:	<Description, SYSNAME, Table-valued function to >
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT * FROM <SchemaFunctionName, , >();

*/
CREATE FUNCTION <SchemaFunctionName, , >
	(
	<FirstParameterName, SYSNAME, @FirstParameterName> <FirstParameterType, SYSNAME, INT>
	)
	RETURNS TABLE
	AS RETURN (
	SELECT ErrorMessage = 'Not implemented'
	);
GO