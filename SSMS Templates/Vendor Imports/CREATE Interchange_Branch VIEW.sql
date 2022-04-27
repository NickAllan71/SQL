DROP VIEW IF EXISTS import.vw_Interchange_Branch_<RecordSourceName, VARCHAR(50), XXX>;
GO
/*

Description:	View to return Json Interchange format for importing <RecordSourceName, , > Branches into Diligencia
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT TOP 100 * FROM import.vw_Interchange_Branch_<RecordSourceName, , >;

*/
CREATE VIEW import.vw_Interchange_Branch_<RecordSourceName, , >
	AS

SELECT SourceId = CONVERT(VARCHAR(20), b.<SourceIdColumn, SYSNAME, RowId>),
	SourceJson = (
	SELECT ParentOrg_SourceId = CONVERT(VARCHAR(20), b.<Org_SourceIdColumn, SYSNAME, Org_RowId>),
		NameEn = NULL,
		NameAr = NULL,
		CountryId = '<CountryId, NCHAR(2), XX>',
		PlaceOfRegistration_ZoneId = NULL,
		Identifiers = (
			SELECT IdentifierTypeCode = 'BRANCH_REGISTRATION', --Currently the only type supported by Asterisk
				Identifier = NULL,
				DateIssued = NULL,
				DateExpired = NULL
--				FROM import.vw_Org_Identifier AS id
--				WHERE b.<SourceIdColumn, , > = id.<SourceIdColumn, , >
				FOR JSON PATH
			),
		EstablishedDate = NULL,
		EndDate = NULL,
		IsFormer = NULL,
		--ORG_ADDR = (
		--	SELECT LandMarkEn = NULL,
		--		LandMarkAr = NULL,
		--		PostCode = NULL,
		--		ZoneId = NULL
		--		FOR JSON PATH
		--	),
		--ORG_MAIL_ADDR = (
		--	SELECT org.POBox,
		--		ZoneId
		--		WHERE org.POBox IS NOT NULL
		--		FOR JSON PATH
		--	),
		PhoneNo1 = NULL,
		PhoneNo2 = NULL,
		MobileNo = NULL,
		FaxNo = NULL,
		EmailAddress = NULL,
		WebUrl = NULL
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
	FROM <BranchSourceTable, SYSNAME, > AS b;
GO