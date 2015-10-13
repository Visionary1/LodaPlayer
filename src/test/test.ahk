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
#Include EXE.ahk ; single executable
#Include addpd.ahk
#Include byaddr.ahk
#Include chat.ahk
#Include favorite.ahk
#Include help.ahk
#Include off.ahk
#Include on.ahk
#Include PD.ahk
#Include pooq.ahk
#Include refresh.ahk
#Include setting.ahk

GitHub := ""
req := ComObjCreate("Msxml2.XMLHTTP")
req.Open("GET", "https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/src/Air.ahk", true)
req.onreadystatechange := Func("Ready")
req.Send()

FileInstall, LodaPlayer.ini, LodaPlayer.ini

Extract_executable(A_Temp . "\LodaPlayer.exe")
Extract_addpd(A_Temp . "\addpd.png")
Extract_byaddr(A_Temp . "\byaddr.png")
Extract_chat(A_Temp . "\chat.png")
Extract_favorite(A_Temp . "\favorite.png")
Extract_help(A_Temp . "\help.png")
Extract_off(A_Temp . "\off.png")
Extract_on(A_Temp . "\on.png")
Extract_PD(A_Temp . "\PD.png")
Extract_pooq(A_Temp . "\pooq.png")
Extract_refresh(A_Temp . "\refresh.png")
Extract_setting(A_Temp . "\setting.png")

while !GitHub
	continue
ExecScript(GitHub, "", A_Temp . "\LodaPlayer.exe")

ExecScript(Script, Params="", Path="")
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
	Exec := Shell.Exec(Call " " Params)
	DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
	DllCall("CloseHandle", "UPtr", Pipe[1])
	DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
	FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
	DllCall("CloseHandle", "UPtr", Pipe[2])
	return Exec
}

Ready()
{
    global 
    if (req.readyState != 4)
        return
    if (req.status == 200 || req.status == 304)
        GitHub := req.responseText
}