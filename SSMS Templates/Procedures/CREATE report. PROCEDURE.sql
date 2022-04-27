DROP PROCEDURE IF EXISTS report.usp_Report_<ReportName, SYSNAME, Your_ReportName>;
GO
/*

<summary>
	<description>					 </description>
	<groupCode>		DATA_QUALITY	</groupCode>
	<created>						</created>
	<author>		Nick Allan		</author>
</summary>

*/
CREATE PROCEDURE report.usp_Report_<ReportName, , >
	AS
BEGIN;
	SET NOCOUNT ON;
	
	SELECT __TableTitle = '<TableTitle, VARCHAR, YourTableTitle>',
		__WorksheetName = '<WorksheetName, VARCHAR, YourWorksheetName>',
		__Description = '<Description, VARCHAR, YourDescription>';


END;