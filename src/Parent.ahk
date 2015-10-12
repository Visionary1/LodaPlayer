;@Ahk2Exe-SetName 로다 플레이어 Air
;@Ahk2Exe-SetDescription 라이브하우스인 시청 프로그램
;@Ahk2Exe-SetCopyright Copyright (c) 2015`, 로다 &예지력
#NoEnv
#NoTrayIcon
#SingleInstance force
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
try
	Run, % A_ScriptDir . "\Loader.exe"
