--Run from diligencia-p
DECLARE @OrgsAdded INT;
EXEC import.usp_Vendor_AddOrganisations @RecordSourceName = '<RecordSourceName, VARCHAR(50), XXX>',
	@BatchSize = 1,
	@OrgsAdded = @OrgsAdded OUTPUT;
SELECT TOP (@OrgsAdded) * FROM import.vw_Map_VendorOrganisation ORDER BY 1 DESC;

--DECLARE @PeopleAdded INT;
--EXEC import.usp_Vendor_AddPeople @RecordSourceName = '<RecordSourceName, , >',
--	@BatchSize = 1,
--	@PeopleAdded = @PeopleAdded OUTPUT;
--SELECT TOP (@PeopleAdded) * FROM import.vw_Map_VendorPerson ORDER BY 1 DESC;

EXEC import.usp_Vendor_ViewProgress @RecordSourceName = '<RecordSourceName, , >',
	@ExpectedOrgCount = <ExpectedOrgCount, INT, NULL>,
	@ExpectedPersonCount = <ExpectedPersonCount, INT, NULL>;

/* To remove faulty profiles...
EXEC datafix.usp_HideRecords @RecordReferenceList = '?';
*/