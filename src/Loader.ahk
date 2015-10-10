; FileEncoding, UTF-8
;@Ahk2Exe-SetName 로다 플레이어 Air
;@Ahk2Exe-SetDescription 라이브하우스인 시청 프로그램
;@Ahk2Exe-SetVersion 0.0.0.1-Air
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
;@Ahk2Exe-SetOrigFilename 로다 플레이어 Net
#NoEnv
#NoTrayIcon
#SingleInstance Off
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
Menu, Tray, NoStandard
ExecScript(getCode("https://raw.githubusercontent.com/Visionary1/DaumPot/master/src.ahk"), "", A_Temp . "\LodaPlayer.exe")
ExitApp

/*
AhkThread := AhkDllThread(A_ScriptDir . "\AutoHotkey.dll") ; Creates an additional AutoHotkey thread using AutoHotkey.dll.
AhkThread.ahktextdll() ; Will automatically add *#Persistent`n#NoTrayIcon* and run "empty" script.
AhkThread.ahkExec(src) ; Execute some code.
While, !AhkThread.ahkReady() ; Wait for the script to be ready.
  Sleep, 10
While, AhkThread.ahkReady() ; Wait for the dll to finish running its script.
  Sleep, 100
  */

getCode(Url)
{
	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("GET", Url, true), http.Send(), http.WaitForResponse()
	DllCall("Winhttp.dll\WinHttpCloseHandle", "Str", http)
	return http.ResponseText
}

ExecScript(Script, Params="", Path="")
{
	Name := "LodaPlayer.exe"
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
	Exec := Shell.Exec(Call " " Params)
	DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
	DllCall("CloseHandle", "UPtr", Pipe[1])
	DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
	FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
	DllCall("CloseHandle", "UPtr", Pipe[2])
	return Exec
}