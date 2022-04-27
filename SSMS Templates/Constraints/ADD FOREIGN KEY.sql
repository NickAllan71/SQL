ALTER TABLE <SchemaName, SYSNAME, dbo>.[<TableName, SYSNAME, YourTable>]
	DROP CONSTRAINT IF EXISTS [FK_<TableName, , >_<ReferencedTableName, SYSNAME, ReferencedTable>]
GO
ALTER TABLE <SchemaName, , dbo>.[<TableName, , >]
	WITH <CHECK or NOCHECK, , CHECK>
	ADD CONSTRAINT [FK_<TableName, , >_<ReferencedTableName, , >] FOREIGN KEY ([<TableColumn, SYSNAME, YourColumn>])
		REFERENCES <SchemaName, , >.[<ReferencedTableName, , >]([<ReferencedColumn, SYSNAME, ReferencedColumn>]) <CascadeDelete, behaviour, ON DELETE CASCADE>;
GO
ALTER TABLE <SchemaName, , dbo>.[<TableName, , >]
	<CHECK or NOCHECK, , CHECK> CONSTRAINT [FK_<TableName, , >_<ReferencedTableName, , >];
