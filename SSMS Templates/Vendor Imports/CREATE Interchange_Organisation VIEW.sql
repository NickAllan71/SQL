DROP VIEW IF EXISTS import.vw_Interchange_Organisation_<RecordSourceName, VARCHAR(50), XXX>;
GO
/*

Description:	View to return Json Interchange format for importing <RecordSourceName, , > Organisations into Diligencia
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT TOP 100 * FROM import.vw_Interchange_Organisation_<RecordSourceName, , >;

*/
CREATE VIEW import.vw_Interchange_Organisation_<RecordSourceName, , >
	AS

SELECT SourceId = org.<SourceIdColumn, SYSNAME, RowId>,
	SourceJson = (
	SELECT NameEn = NULL, --ORG_NameEn
		NameAr = NULL, --ORG_NameAr
		TradingNameEn = NULL,
		CountryId = '<CountryId, NCHAR(2), XX>', --ORG_CountryIsCovered
		PlaceOfRegistration_ZoneId = NULL, --ORG_PlaceOfReg
		Identifiers = ( --ORG_RegNos
			SELECT IdentifierTypeCode = NULL,
				Identifier = NULL,
				DateIssued = NULL,
				DateExpired = NULL
--				FROM import.vw_Org_Identifier AS id
--				WHERE org.<SourceIdColumn, , > = id.<SourceIdColumn, , >
				FOR JSON PATH
			),
		DataSetReceivedDate = CONVERT(DATE, '<DataSetReceivedDate, DATE, >'), --ORG_LastReviewDate
		StatusCode = NULL, --ORG_Status
		EstablishedDate = NULL,
		DateDissolved = NULL,
		LegalFormId = NULL, --ORG_LegalForm
		Regulator_OrgId = NULL, --ORG_RegulatorMissing
--ORG_Addresses
		--ORG_ADDR = (
		--	SELECT LandMarkEn = NULL,
		--		LandMarkAr = NULL,
		--		PostCode = NULL,
		--		ZoneId = NULL
		--		FOR JSON PATH
		--	),
		--ORG_REG_ADDR = (
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
		--ORG_REG_MAIL_ADDR = (
		--	SELECT org.POBox,
		--		ZoneId
		--		WHERE org.POBox IS NOT NULL
		--		FOR JSON PATH
		--	),
		PhoneNo1 = NULL,
		PhoneNo2 = NULL,
		PhoneNo3 = NULL,
		MobileNo = NULL,
		FaxNo = NULL,
		EmailAddress = NULL,
		WebUrl = NULL,
		CurrencyCode = NULL, --Defaults to local currency
		PaidCapital = NULL, --ORG_IssuedCapital
		AuthorisedCapital = NULL, --Typically same as PaidCapital
		SharesIssued = NULL,
		ParValue = NULL,
		--Sectors = (
		--	SELECT Id = s.To_SectorId
		--		FROM import.Map_Sector AS s
		--		WHERE org.Sector = s.From_Sector
		--		FOR JSON PATH
		--),
		--Activities = (
		--	SELECT ActivityCode = NULL,
		--		ActivityNameEn = NULL,
		--		ActivityNameAr = NULL
		--		FROM import.vw_Activities AS act
		--		WHERE org.<SourceIdColumn, , > = act.<SourceIdColumn, , >
		--		FOR JSON PATH
		--),
		BusinessOperationsEn = NULL,
		BusinessOperationsAr = NULL,
		--[Ownership] = (
		--	SELECT OwnedOrg_SourceId = CONVERT(VARCHAR(20), org.<OwnedOrg_SourceIdColumn, SYSNAME, OwnedOrg_RowId>),
		--		NoOfShares = NULL, --NB: Org's SharesIssued must be provided!
		--		OwnedPercentage = NULL,
		--		IsFormer = NULL,
		--		StartDate = NULL,
		--		EndDate = NULL
		--		FOR JSON PATH
		--	)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
	FROM <OrganisationSourceTable, SYSNAME, > AS org;
GO