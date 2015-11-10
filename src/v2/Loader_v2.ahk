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

IfExist, % A_Temp "\LPResource.zip"
	Unz(A_Temp "\LPResource.zip", A_Temp)

while !GitHub
	Sleep, 10

ExecScript(GitHub,, A_Is64bitOS ? (A_Temp . "\LodaPlayer64.exe") : (A_Temp . "\LodaPlayer32.exe"))

Unz(sZip, sUnz)
{
    fso := ComObjCreate("Scripting.FileSystemObject")
    If Not fso.FolderExists(sUnz)
       fso.CreateFolder(sUnz)
    psh  := ComObjCreate("Shell.Application")
    zippedItems := psh.Namespace( sZip ).items().count
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
    Loop {
        Sleep, 50
        unzippedItems := psh.Namespace( sUnz ).items().count
        ToolTip 리소스 파일 설정 중..
        If (unzippedItems >= zippedItems)
            break
    }
    ToolTip
}

Ready()
{
    global 
    if (req.readyState != 4)
        return
    if (req.status == 200 || req.status == 304)
        GitHub := req.responseText
}

ExecScript(Script, Params="", Path="")
{
	Name := "로다 플레이어 Air"
	Pipe := []
	Loop, 2
	{
		Pipe[A_Index] := DllCall("CreateNamedPipe"
		, "Str", "\\.\pipe\" Name
		, "UInt", 2, "UInt", 0
		, "UInt", 255, "UInt", 0
		, "UInt", 0, "UPtr", 0
		, "UPtr", 0, "UPtr")
	}
	if !FileExist(Path)
		throw Exception("해당 리소스 파일이 설치되지 않았습니다: " Path)
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