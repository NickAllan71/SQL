DROP VIEW IF EXISTS import.vw_Org_Identifier;
GO
/*

Description:	View to transform Org_Identifiers
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT TOP 100 * FROM import.vw_Org_Identifier;

*/
CREATE VIEW import.vw_Org_Identifier
	AS

WITH cteOrgIds
	AS
	(
	SELECT RowId,
		CRN = CONVERT(NVARCHAR(30), <CrnColumn, SYSNAME, Crn>),
		COMPANY_NO = CONVERT(NVARCHAR(30),<CompanyNoColumn, SYSNAME, CompanyNo>),
		TRADE_LICENCE = CONVERT(NVARCHAR(30), <TradeLicenceColumn, SYSNAME, TradeLicence>)
		FROM <OrganisationSourceTable, SYSNAME, >
	)
	SELECT u.*
		FROM cteOrgIds AS ids
			UNPIVOT (
				Identifier FOR IdentifierTypeCode IN (CRN, COMPANY_NO, TRADE_LICENCE) --Ref: diligencia-p.dbo.Org_IdentifierType
				) AS u
		WHERE u.Identifier IS NOT NULL;
GO