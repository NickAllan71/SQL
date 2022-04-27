DROP VIEW IF EXISTS import.vw_Interchange_Person_<RecordSourceName, VARCHAR(50), XXX>;
GO
/*

Description:	View to return Json Interchange format for importing <RecordSourceName, , > Persons into Diligencia
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

--Example use:
SELECT TOP 100 * FROM import.vw_Interchange_Person_<RecordSourceName, , >;

*/
CREATE VIEW import.vw_Interchange_Person_<RecordSourceName, , >
	AS

SELECT SourceId = p.<SourceIdColumn, SYSNAME, RowId>,
	SourceJson = (
	SELECT NameEn = NULL, --PER_NameEn
		NameAr = NULL, --PER_NameAr
		CountryId = '<CountryId, NCHAR(2), XX>', --PER_Country
		GenderId = NULL,
		DateOfBirth = NULL,
		PlaceOfBirthCityId = NULL, --NB: 'N/A' Cities are unsupported
		TitleId = NULL,
		DataSetReceivedDate = CONVERT(DATE, '<DataSetReceivedDate, DATE, >'), --PER_LastReviewDate
		Management = (
			SELECT ManagedOrg_SourceId = CONVERT(VARCHAR(20), p.<Org_SourceIdColumn, SYSNAME, Org_RowId>),
				PositionNameEn = NULL,
				RelationshipTypeCode = NULL,
				IsFormer = NULL,
				StartDate = NULL,
				EndDate = NULL
				FOR JSON PATH
			),
		[Ownership] = (
			SELECT OwnedOrg_SourceId = CONVERT(VARCHAR(20), p.<Org_SourceIdColumn, SYSNAME, Org_RowId>),
				NoOfShares = NULL, --NB: Org's SharesIssued must be provided!
				OwnedPercentage = NULL,
				IsFormer = NULL,
				StartDate = NULL,
				EndDate = NULL
				FOR JSON PATH
			),
		Nationalities = (
			SELECT Id = NULL
				FOR JSON PATH
			),
		Identification = (
			SELECT IdentificationTypeCode = NULL,
				IdentificationNo = NULL,
				IssuedByCountryId = '<CountryId, , >',
				IssuedInTownId = NULL
				FOR JSON PATH
			)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)
	FROM <PersonSourceTable, SYSNAME, > AS p;
GO