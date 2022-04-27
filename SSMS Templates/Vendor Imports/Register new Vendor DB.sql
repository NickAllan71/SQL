--Run on diligencia DBs (-d -s -p):
EXEC import.usp_Map_VendorRecordSource_Add @RecordSourceName = '<RecordSourceName, VARCHAR(50), XXX>',
	@CountryId = '<CountryId, NCHAR(2), XX>',
	@VendorDatabaseName = '<VendorDatabaseName, SYSNAME, VendorXXX>',
	@VendorDescription = '<VendorDescription, VARCHAR(1000), Webscraped from http:\\etc>';

EXEC import.usp_CreateExternalDataSources;