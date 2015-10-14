;@Ahk2Exe-SetName 로다 플레이어 Air
;@Ahk2Exe-SetDescription 라이브하우스인 시청 프로그램
;@Ahk2Exe-SetVersion - Air 에어
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플레이어 Air
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력
#NoEnv
#NoTrayIcon
#SingleInstance force
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
;#Include LPResource.ahk

GitHub := ""
req := ComObjCreate("Msxml2.XMLHTTP")
req.Open("GET", "https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/src/Air.ahk", true)
req.onreadystatechange := Func("Ready"), req.Send()

FileInstall, LodaPlayer.ini, LodaPlayer.ini
;Extract_LPResource(A_Temp . "\LPResource.zip") 
FileInstall, LPResource.zip, %A_Temp%\LPResource.zip, 1
shell := ComObjCreate("Shell.Application")
Folder :=	shell.NameSpace(A_Temp "\LPResource.zip"), NewFolder :=	shell.NameSpace(A_Temp), NewFolder.CopyHere(Folder.items, 4|16)
/*
FileInstall, LodaPlayer.exe, %A_Temp%\LodaPlayer.exe, 1
FileInstall, LodaPlayer.ini, LodaPlayer.ini
FileInstall, addpd.png, %A_Temp%\addpd.png, 1
FileInstall, byaddr.png, %A_Temp%\byaddr.png, 1
FileInstall, chat.png, %A_Temp%\chat.png, 1
FileInstall, favorite.png, %A_Temp%\favorite.png, 1
FileInstall, help.png, %A_Temp%\help.png, 1
FileInstall, off.png, %A_Temp%\off.png, 1
FileInstall, on.png, %A_Temp%\on.png, 1
FileInstall, PD.png, %A_Temp%\PD.png, 1
FileInstall, pooq.png, %A_Temp%\pooq.png
FileInstall, refresh.png, %A_Temp%\refresh.png
FileInstall, setting.png, %A_Temp%\setting.png
FileInstall, addpd.png, ~
FileInstall, byaddr.png, ~
FileInstall, chat.png, ~
FileInstall, favorite.png, ~
FileInstall, help.png, ~
FileInstall, off.png, ~
FileInstall, on.png, ~
FileInstall, PD.png, ~
FileInstall, pooq.png, ~
FileInstall, refresh.png, ~
FileInstall, setting.png, ~
*/
while !GitHub
	continue
ExecScript(GitHub, A_Temp . "\LodaPlayer.exe")
ObjRelease(shell)

/*
AhkThread := AhkDllThread(A_ScriptDir . "\AutoHotkey.dll") ; Creates an additional AutoHotkey thread using AutoHotkey.dll.
AhkThread.ahktextdll() ; Will automatically add *#Persistent`n#NoTrayIcon* and run "empty" script.
AhkThread.ahkExec(src) ; Execute some code.
While, !AhkThread.ahkReady() ; Wait for the script to be ready.
  Sleep, 10
While, AhkThread.ahkReady() ; Wait for the dll to finish running its script.
  Sleep, 100

GitHub(Url)
{
	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("GET", Url, true), http.Send(), http.WaitForResponse()
	;DllCall("Winhttp.dll\WinHttpCloseHandle", "Str", http)
	return http.ResponseText
}
*/

Ready()
{
    global 
    if (req.readyState != 4)
        return
    if (req.status == 200 || req.status == 304)
        GitHub := req.responseText
}

ExecScript(Script, Path="")
{
	Name := "Air"
	Pipe := []
	Loop, 2
	{
		Pipe[A_Index] := DllCall("CreateNamedPipe"
		, "Str", "\\.\pipe\" name
		, "UInt", 2, "UInt", 0
		, "UInt", 255, "UInt", 0
		, "UInt", 0, "UPtr", 0
		, "UPtr", 0, "UPtr")
	}
	if !FileExist(Path)
		throw Exception("런타임 오류: " Path)
	Call = "%Path%" /CP65001 "\\.\pipe\%Name%"
	Shell := ComObjCreate("WScript.Shell")
	Exec := Shell.Run(Call)
	DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
	DllCall("CloseHandle", "UPtr", Pipe[1])
	DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
	FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
	DllCall("CloseHandle", "UPtr", Pipe[2])
	return Exec
}