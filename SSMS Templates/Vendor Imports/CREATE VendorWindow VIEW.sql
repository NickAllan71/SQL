DROP VIEW IF EXISTS import.vw_VendorWindow_<VendorEntityTypeName, Person or, Organisation>_<RecordSourceName, VARCHAR(50), XXX>;
GO
/*

Description:	View to return the <VendorEntityTypeName, , > Vendor Window for <RecordSourceName, , >
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT TOP 100 * FROM import.vw_VendorWindow_<VendorEntityTypeName, , >_<RecordSourceName, , >;

*/
CREATE VIEW import.vw_VendorWindow_<VendorEntityTypeName, , >_<RecordSourceName, , >
	AS

SELECT SourceId = <TableAlias, SYSNAME, org>.<SourceIdColumnName, SYSNAME, RowId>,
	SourceJson = (
		SELECT <TableAlias, , >.*
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
	FROM <SchemaTableName, SYSNAME, dbo.CompanyDetails> AS <TableAlias, , >;
GO