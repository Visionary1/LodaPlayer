FileEncoding, UTF-8
;@Ahk2Exe-SetName 로다 플레이어 Air
;@Ahk2Exe-SetDescription 라이브하우스인 시청 프로그램
;@Ahk2Exe-SetVersion 0.0.0.0
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
FileInstall, addpd.png, %A_Temp%\addpd.png
FileInstall, byaddr.png, %A_Temp%\byaddr.png
FileInstall, chat.png, %A_Temp%\chat.png
FileInstall, favorite.png, %A_Temp%\favorite.png
FileInstall, help.png, %A_Temp%\help.png
FileInstall, off.png, %A_Temp%\off.png
FileInstall, on.png, %A_Temp%\on.png
FileInstall, PD.png, %A_Temp%\PD.png
FileInstall, pooq.png, %A_Temp%\pooq.png
FileInstall, refresh.png, %A_Temp%\refresh.png
FileInstall, setting.png, %A_Temp%\setting.png
FileInstall, LodaPlayer.ini, LodaPlayer.ini
FileInstall, LodaPlayer.exe, %A_Temp%\LodaPlayer.exe, 1
#NoEnv
#NoTrayIcon
#SingleInstance Off
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
Menu, Tray, NoStandard
ExecScript(GitHub("https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/src/Air.ahk"), "", A_Temp . "\LodaPlayer.exe")

/*
AhkThread := AhkDllThread(A_ScriptDir . "\AutoHotkey.dll") ; Creates an additional AutoHotkey thread using AutoHotkey.dll.
AhkThread.ahktextdll() ; Will automatically add *#Persistent`n#NoTrayIcon* and run "empty" script.
AhkThread.ahkExec(src) ; Execute some code.
While, !AhkThread.ahkReady() ; Wait for the script to be ready.
  Sleep, 10
While, AhkThread.ahkReady() ; Wait for the dll to finish running its script.
  Sleep, 100
  */

GitHub(Url)
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