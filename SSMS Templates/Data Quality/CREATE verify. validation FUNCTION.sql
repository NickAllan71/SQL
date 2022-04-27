DROP FUNCTION IF EXISTS verify.fn_Validate_<ValidationCode, VARCHAR(20), ORG_YourCode>;
GO
/*

<summary>
	<assert></assert>
	<costfactor></costfactor>
	<dirtfactor></dirtfactor>
	<ismaskable>true</ismaskable>
	<ispublishallowed>true</ispublishallowed>
	<pageurlshortkey></pageurlshortkey>
</summary>

--Example use:
SELECT org.RecordReference,
	vfn.*
	FROM dbo.Org_Organisations AS org
		CROSS APPLY verify.fn_Validate_<ValidationCode, , >(org.OrgId) AS vfn;

SELECT * FROM verify.fn_Validate_<ValidationCode, , >(13);
*/
CREATE FUNCTION verify.fn_Validate_<ValidationCode, , >
	(
	@OrgId INT
	)
	RETURNS TABLE
	AS RETURN (
		SELECT FailureReason = '<FailureReason, VARCHAR, YourFailureReason>'
			FROM dbo.Org_Organisations AS org
			WHERE --Your validation rule
				AND org.OrgId = @OrgId
	);
GO
EXEC verify.usp_Validate_RegisterFunctions;