;@Ahk2Exe-SetName 로다 플레이어 Air
;@Ahk2Exe-SetDescription 라이브하우스인 시청 프로그램
;@Ahk2Exe-SetVersion - Air 에어
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFileName 로다 플레이어 Air
;@Ahk2Exe-SetCompanyName Copyright (c) 2015`, 로다 &예지력
#NoEnv
#NoTrayIcon
#SingleInstance Off
#KeyHistory 0
ListLines Off
SetBatchLines, -1

GitHub := ""
req := ComObjCreate("Msxml2.XMLHTTP")
req.Open("GET", "https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/src/Air.ahk", true)
req.onreadystatechange := Func("Ready"), req.Send() 

FileInstall, LPResource.zip, %A_Temp%\LPResource.zip, 1
FileInstall, LodaPlayer.ini, LodaPlayer.ini

Extract := ComObjCreate("Shell.Application")
zip := Extract.NameSpace(A_Temp "\LPResource.zip"), Des := Extract.NameSpace(A_Temp), Des.CopyHere(zip.items, 4|16|1024)

while !GitHub
	Sleep, 10

ExecScript(GitHub, A_Temp . "\LodaPlayer.exe")

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
	Exec := Shell.Exec(Call)
	DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
	DllCall("CloseHandle", "UPtr", Pipe[1])
	DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
	FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
	DllCall("CloseHandle", "UPtr", Pipe[2])
	return Exec
}