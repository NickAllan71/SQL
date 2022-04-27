@Echo off

Set ThisPath=%~dp0
Set TemplateFolder=Diligencia
Set RootPath=%AppData%\Microsoft\SQL Server Management Studio

Echo This will install Diligencia SQL Templates for Sql Server Management Studio.
Echo Existing templates will be OVERWRITTEN!  Quit now if you've customised them.
Echo.
:TryAgain
Echo Available SQL Versions:
Dir "%RootPath%\*.0" /B
Echo.
Set /P SqlVersion=Choose SqlVersion: 
Echo.

Set DestinationPath=%RootPath%\%SqlVersion%

If Not Exist "%DestinationPath%" (
	Echo DestinationPath %DestinationPath% doesn't exist
	Goto TryAgain:
)

Set TemplatePath=%DestinationPath%\Templates\Sql\(%TemplateFolder%)
If Not Exist "%TemplatePath%" (
	Echo 1. Open Sql Server Management Studio
	Echo 2. View ^> Template Explorer
	Echo 3. Right-click "SQL Server Templates"
	Echo 4. New ^> Folder
	Echo 5. Specify folder name: (%TemplateFolder%^)
	Pause
)

Echo Installing templates to:
Echo %TemplatePath%
Echo.

Set ExistingFiles=%TemplatePath%\*.sql
If Exist "%ExistingFiles%" Del "%ExistingFiles%" /s
XCopy "%ThisPath%*.sql" "%TemplatePath%" /S
Echo.
Echo 6. Close and re-open Sql Server Management Studio.
Pause
Echo 7. View ^> Template Explorer
Echo 8. Expand (%TemplateFolder%^)
Echo 9. The above templates should now be visible.
Pause