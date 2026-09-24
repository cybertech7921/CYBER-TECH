Option Explicit
Dim sh,fso,dir,ps
Set sh=CreateObject("WScript.Shell")
Set fso=CreateObject("Scripting.FileSystemObject")
dir=fso.GetParentFolderName(WScript.ScriptFullName)
ps=dir & "\Update.ps1"
If Not fso.FileExists(ps) Then MsgBox "Update.ps1 was not found.",16,"CYBER TECH Updater" : WScript.Quit
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & ps & """",1,True
