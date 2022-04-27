@Echo Off
Set WinMergeEXE=C:\Program Files (x86)\WinMerge\WinMergeU.exe
Set ThisPath=%~dp0
Set SqlVersion=18.0
Set CompareWithPath=%APPDATA%\Microsoft\SQL Server Management Studio\%SqlVersion%\Templates\Sql\(Diligencia)

"%WinMergeEXE%" "%CompareWithPath%" "%ThisPath%"
If ErrorLevel 1 Pause