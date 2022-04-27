DROP VIEW IF EXISTS clean.vw_TaskList_<ProjectName, VARCHAR, ORG_YourProjectName>;
GO
/*

Description:	<Description, VARCHAR, Task List View to >
Created:		<CreatedDate, DATE, >
Author:			<Author, VARCHAR, Nick Allan>

--Example use:
SELECT TOP 100 * FROM clean.vw_TaskList_<ProjectName, , >
	ORDER BY CountryId,
		SortOrder;
*/
CREATE VIEW clean.vw_TaskList_<ProjectName, , >
	AS

SELECT org.RecordReference,
	org.CountryId,
	SortOrder = NULL
	FROM report.vw_OrganisationEssentials AS org
	WHERE <TaskCriteria, E.g., org.IsPublished = 0>;
GO
DECLARE @ProjectReference VARCHAR(20);
EXEC clean.usp_Project_Add @ProjectName = '<ProjectName, , >',
	@MaxTaskCountPerAnalyst = <MaxTaskCountPerAnalyst, INT, 10>,
	@Briefing = '<Briefing, NVARCHAR(1000), Your instructions>',
	@TaskListView = 'clean.vw_TaskList_<ProjectName, , >',
	@AutoSetTaskStatus = <AutoSetTaskStatus, BIT, 0>,
	@IsKeptActive = <IsKeptActive, BIT, 0>,
	@PageUrlShortKey = <PageUrlShortKey, VARCHAR(3), 'IR'>,
	@CreatedByUserId = 1,
	@EditIfExists = 1,
	@ProjectReference = @ProjectReference OUTPUT;

EXEC clean.usp_Project_AddManagersByName @ProjectReference = @ProjectReference, @ManagerNameList = '<ManagerName, VARCHAR(8000), Asma Ayyadi>';
--EXEC clean.usp_Project_AddAnalystsByName @ProjectReference = @ProjectReference, @AnalystNameList = '<AnalystNameList, VARCHAR(8000), >';
--EXEC clean.usp_Project_SetCountryOrder @ProjectReference = @ProjectReference, @CountryIdList = '<CountryIdList, VARCHAR(8000), >';
--EXEC clean.usp_Project_Benchmark_AddByProjectReference @ProjectReference = @ProjectReference;

SELECT * FROM clean.vw_DataQuality_Project WHERE ProjectReference = @ProjectReference;