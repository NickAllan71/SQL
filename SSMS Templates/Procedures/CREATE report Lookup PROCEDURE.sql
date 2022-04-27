DROP PROCEDURE IF EXISTS report.usp_Lookup_<ItemKeyColumnName, SYSNAME, YourColumnId>;
GO
/*

Description:	Report Generator Lookup Procedure to return <ItemKeyColumnName, , >
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
EXEC report.usp_Lookup_<ItemKeyColumnName, , >;

*/
CREATE PROCEDURE report.usp_Lookup_<ItemKeyColumnName, , >
	AS
BEGIN;
	SET NOCOUNT ON;
	
	SELECT ItemKey = <ItemKeyColumnName, , >,
		ItemValue = <ItemValueColumnName, , >
		FROM <LookupTableName, SYSNAME, YourLookupTableName>
		<LookupTableFilter, , WHERE IsHidden = 0>
		ORDER BY ItemValue;
END;