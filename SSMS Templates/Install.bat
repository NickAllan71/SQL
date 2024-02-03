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
Echo Installing templates to:
Echo %TemplatePath%
Echo.

If Exist "%TemplatePath%" (
    Del "%TemplatePath%" /Q
)

Set ExistingFiles=%TemplatePath%\*.sql
If Exist "%ExistingFiles%" Del "%ExistingFiles%" /s
XCopy "%ThisPath%*.sql" "%TemplatePath%" /S /i /Y /Q
pause
Set TemplateAuthor=%USERNAME%
Set /P TemplateAuthor=Choose default template author (%TemplateAuthor%): 
Powershell.exe -ExecutionPolicy Bypass -File SearchAndReplace.ps1 -RootFolder "%TemplatePath%" -FileSpec "*.sql" -SearchTarget "Nick Allan" -ReplacementText "%TemplateAuthor%"

Echo.
Echo 1. Close and re-open Sql Server Management Studio
Echo 2. View ^> Template Explorer
Echo 3. Expand (%TemplateFolder%^)
Echo 4. The above templates should now be visible.
Pause