#NoEnv
#SingleInstance Off
#KeyHistory 0
#ErrorStdOut
ListLines Off
SetBatchLines, -1
SetKeyDelay, 10, 10
SetMouseDelay, 0
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0
Menu, Tray, NoStandard
Menu, Tray, Add, 가가라이브 채팅, ShowGa
Menu, Tray, Add,
Menu, Tray, Add, 종료하기, Terminate
ComObjError(false)
BrowserEmulation(1)

Noti := new CleanNotify("로다 플레이어 [임시]", "12월 12일까지 바빠 오류를 수정할 시간이 없어서`n플러그인으로 대체합니다(__) 쒸,,,뿔 라이브하우스" , (A_ScreenWidth / 2.7), (A_ScreenHeight / 6), "vc hc", "P")

/*
IfNotExist, %A_Temp%\LodaPlugin.exe
	Extract_LodaPlayer(A_Temp . "\LodaPlugin.exe")

Extract_PD(A_Temp . "\PD.png")
Extract_on(A_Temp . "\on.png")
*/


Init := new LodaPlugin()
Noti.Destroy(), Noti := ""
GaGa := new Browser()
Init.RegisterCloseCallback(Func("PlayerClose"))
return

ShowGa:
WinShow, % "ahk_id " GaGa.hMain
return

Terminate:
BrowserEmulation(0)
try {
	WinKill, % "ahk_id " Init.hPotPlayer
	Init.ie.Quit(), Init.ie := ""
	DllCall("GlobalFree", "Ptr", Init.hookProcAdr, "Ptr")
}
ExitApp
return

BrowserEmulation(Level) {
	static key := "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", ieversion := ""
	
	if ieversion = 
	{
		try {
			RegRead ver, HKLM, SOFTWARE\Microsoft\Internet Explorer, svcVersion
			ieversion :=  SubStr(ver, 1, InStr(ver, ".")-1)
		}
		catch {
			MsgBox, 262160, Exception, 익스플로러 11가 설치되지 않았어요`n설치를 권장합니다
		}
	}
	if Level = 1
		RegWrite, REG_DWORD, HKCU, %key%, LodaPlayer.exe, % ieversion * 1000
	else if Level = 0
		RegDelete HKCU, %key%, LodaPlayer.exe
}

class Browser
{
	static URL := "http://www.gagalive.kr/livechat1.swf?chatroom=~~~new_ForPotsu&fontlarge=true"
	
	__New() 
	{
		global
		Gui, New, +Resize +hwndhMain
		this.hMain := hMain
		
		Gui, Add, ActiveX, x0 y0 w500 h500 hwndhEmbed vWB, Shell.Explorer
		this.hEmbed := hEmbed
		WB.silent := true, WB.Navigate(this.URL)
		
		this.Bound := []
		this.Bound.OnMessage := this.OnMessage.Bind(this)
		
		WinEvents.Register(this.hMain, this)
		OnMessage(0x100, this.Bound.OnMessage)
		
		Gui,Show, % " hide w" A_ScreenWidth*0.3 " h" A_ScreenHeight*0.6 , 가가라이브
	}

	GuiSize()
	{
		DllCall("MoveWindow", "Ptr", this.hEmbed, "Int", 0, "Int", 0, "Int", A_GuiWidth, "Int", A_GuiHeight, "Int", 1)
	}
 
	GuiClose()
	{
		Gui, Hide
	}
	
	OnMessage(wParam, lParam, Msg, hWnd)
	{
		global WB
		static fields := "hWnd,Msg,wParam,lParam,A_EventInfo,A_GuiX,A_GuiY"
		
		if (Msg == 0x100) {
			WinGetClass, ClassName, ahk_id %hWnd%
			
			if (ClassName = "MacromediaFlashPlayerActiveX" && wParam == GetKeyVK("Enter"))
				SendInput, {tab 4}{space}+{tab 4}
			
			if (ClassName = "Internet Explorer_Server") {
				pipa := ComObjQuery(WB.document, "{00000117-0000-0000-C000-000000000046}")
				VarSetCapacity(Msgs, 48)
				Loop Parse, fields, `,             ;`
					NumPut(%A_LoopField%, Msgs, (A_Index-1)*A_PtrSize)
				TranslateAccelerator := NumGet(NumGet(1*pipa)+5*A_PtrSize)
				Loop 2
					r := DllCall(TranslateAccelerator, "Ptr",pipa, "Ptr",&Msgs)
				until wParam != 9 || WB.document.activeElement != ""
				ObjRelease(pipa)
				if r = 0
					return 0
			}
		}
	}
}

class CleanNotify {
 
	__New(Title, Msg, pnW := "700", pnH := "300", Pos := "b r", Time := "10")
	{
		LastFound := WinExist()
		Gui, new, +hwndhNotify -DPIScale
		this.hNotify := hNotify
		Gui, % this.hNotify ": Default"
		Gui, % this.hNotify ": +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound +E0x20"
		WinSet, Transparent, 0
		Gui, % this.hNotify ": Color", 0xF2F2F0
		Gui, % this.hNotify ": Font", c0x07D82F s18 wBold, Segoe UI
		Gui, % this.hNotify ": Add", Text, % " x" 20 " y" 12 " w" pnW-20 " hwndhTitle", % Title
		this.hTitle := hTitle
		
		Gui, % this.hNotify ": Font", cBlack s15 wRegular
		Gui, % this.hNotify ": Add", Text, % " x" 20 " y" 55 " w" pnW-20 " h" pnH-55 " hwndhMsg", % Msg
		this.hMsg := hMsg
		Gui, % this.hNotify ": Show", % "W " pnW + 50 " H" pnH " NoActivate"
		
		this.WinMove(this.hNotify, Pos)
		WinSet, Region, % " 0-0 w" pnW " h" pnH " R40-40", % "ahk_id " this.hNotify
		this.winfade("ahk_id " this.hNotify, 210, 5)
		if (WinExist(LastFound))
			Gui, % LastFound ": Default"
	}
	
	Mod(Title, Msg := "")
	{
		if !(Title == "")
			GuiControl, % this.hNotify ": Text", % this.hTitle, % Title
		if !(Msg == "")
			GuiControl, % this.hNotify ": Text", % this.hMsg, % Msg
	}
	
	Destroy()
	{
		try this.winfade("ahk_id " this.hNotify, 0, 5)
		try Gui, % this.hNotify ": Destroy"
	}
	
	WinMove(hwnd,position)
	{
	   SysGet, Mon, MonitorWorkArea
	   WinGetPos,ix,iy,w,h, ahk_id %hwnd%
	   x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
	   y := InStr(position,"t") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"b") ? MonBottom - h : iy
	   WinMove, ahk_id %hwnd%,, x, y
	}
	
	winfade(w:="",t:=128,i:=1,d:=10) ; Thanks, Joedf
	{
		Critical
		w:=(w="") ? ("ahk_id " this.hNotify) : w
		t:=(t>255)?255:(t<0)?0:t
		WinGet,s,Transparent,%w%
		s:=(s="")?255:s ;prevent trans unset bug
		WinSet,Transparent,%s%,%w%
		i:=(s<t)?abs(i):-1*abs(i)
		while(k:=(i<0)?(s>t):(s<t)&&WinExist(w)) {
			WinGet,s,Transparent,%w%
			s+=i
			WinSet,Transparent,%s%,%w%
			sleep %d%
		}
		Critical, Off
	}
}

class LodaPlugin
{
	static Title := "로다 플러그인 [임시]"
	, DB := {"THOMTV": "318288", "FOX&Tails TV": "318870", "WARP": "318512", "마스터": "328250", "사공TV": "338631", "반지하팟수": "338369"
	, "민지": "318023", "푸른용": "318532", "고퀄리티": "323005", "족발": "325458", "장국영": "322516", "mirnoff": "349503"
	, "Danna": "357882", "일주일에영화세편": "354799", "엘": "343740", "미르": "318493", "레아TV": "328321", "암내공격둘리": "322231"
	, "플로우": "321812", "레베": "346894", "브레인워시": "321989", "힐링": "323745", "떠돌이맥스": "317950", "조PD": "331325"
	, "망둥어": "324699", "아라라기상": "319279", "yeori": "318073", "PD 어둠의볶음밥": "323431", "알타비스타": "320834"
	, "현돌이": "354181", "SuDaL NIM": "318840", "하루": "341613", "바삭바삭": "341808", "해냐차": "345197"
	, "James Corbett": "318061", "팟수24시": "323587", "애니메이션": "319157", "레로": "318612"
	, "맹약": "347423", "불꽃방망이": "342962", "팟수여죽창을들라": "320851", "흑설": "346699"
	, "홍삼원": "337072", "Navy": "322254", "해보라기": "361341", "이리저리": "318182", "풍파고등학교": "324901", "땔감": "353473"
	, "PD Bara": "321080", "나이스~": "323530", "파트라슈": "317955", "팟하": "321058", "실제상황기막힌이야기": "324391"
	, "팟수 Lee(potsu lee)": "318254", "팟수 Lee 2관": "318396", "호,뭐?!심슨!!": "319046", "키메": "318215", "정은지": "336352"
	, "친절한상근씨": "334645", "[전대미문의 팟수] 방송중": "329611", "마리테넷": "317975", "E.A.OP TV": "342792", "우리집개": "317849"
	, "pengs": "316825", "RONGSPORTS": "329050", "이리도": "365821", "더으락": "325628", "ikoma": "317679"
	, "로솔": "329829", "갓쥬멍뭉": "317753", "happysky": "317987", "PD 별루군": "325098", "Yunaito": "315846"
	, "라이거": "358420", "팟]엘퀴네스": "317910", "erido": "322063"}
	
	__New()
	{
		global
		LPP := ObjBindMethod(this, "PDMenu"), MakeVisible := ObjBindMethod(this, "isPluginTop"), isOnAir := ObjBindMethod(this, "Refresh")
		
		Gui, new, -DPIScale +hwndhPlugin -Resize +ToolWindow -SysMenu ;-MaximizeBox -MinimizeBox
		this.hPlugin := hPlugin
		;DisableCloseButton(this.hPlugin)
		
		this.ParsePOOO(), this.UpdateMenu("Film", "영화"), this.UpdateMenu("Ani", "애니"), this.UpdateMenu("Show", "예능"), this.UpdateMenu("Etc", "기타"), this.FreeObjects()
		/*
		Menu, MenuBar, Add, 영화:방송, :FilmMenu
		Menu, MenuBar, Add, 애니:방송, :AniMenu
		Menu, MenuBar, Add, 예능:방송, :ShowMenu
		Menu, MenuBar, Add, 기타:방송, :EtcMenu
		try Menu, MenuBar, Icon, 영화:방송, %A_Temp%\PD.png,, 0
		try Menu, MenuBar, Icon, 애니:방송, %A_Temp%\PD.png,, 0
		try Menu, MenuBar, Icon, 예능:방송, %A_Temp%\PD.png,, 0
		try Menu, MenuBar, Icon, 기타:방송, %A_Temp%\PD.png,, 0
		*/
		Gui, Menu, MyMenuBar
		
		RegRead, location32, HKCU, SOFTWARE\DAUM\PotPlayer, ProgramFolder
		if ErrorLevel = 0
			try Run, % location32 . "\PotPlayerMini.exe",,, TargetPID
		else if ErrorLevel = 1
		{
			RegRead, location64, HKCU, SOFTWARE\DAUM\PotPlayer64, ProgramFolder
			if ErrorLevel = 0
				try Run, % location64 . "\PotPlayerMini.exe",,, TargetPID
			else if ErrorLevel = 1
			{
				MsgBox, 262192, 이런!, 팟플레이어가 설치되지 않은 것 같아요`n설치후에 다시 실행해주세요!, 5
				this.CloseCallback()
			}
		}
		
		WinWait, % "ahk_pid " TargetPID
		this.hPotPlayer := WinExist("ahk_pid " TargetPID)
		
		this.ie := ComObjCreate("InternetExplorer.Application"), this.ie.Visible := true, this.ie.MenuBar := false, this.ie.StatusBar := false, this.ie.ToolBar := false, this.ie.Navigate("about:blank", "65536")
		WS_CAPTION := "0xC00000", WS_SIZEBOX := "0x40000", WS_SYSMENU := "0x80000"
		WinWait, % "ahk_id " this.ie.hwnd
		WinSet, Style, % "-" WS_CAPTION, % "ahk_id " this.ie.hwnd
		WinSet, Style, % "-" WS_SIZEBOX, % "ahk_id " this.ie.hwnd
		WinSet, Style, % "-" WS_SYSMENU, % "ahk_id " this.ie.hwnd
		WinSet, Redraw,, % "ahk_id " this.ie.hwnd
		DetectHiddenWindows, On
		WinHide, % "ahk_id " this.ie.hwnd
		WinSet, ExStyle, +0x80, % "ahk_id " this.ie.hwnd ; 0x80 is WS_EX_TOOLWINDOW
		WinShow, % "ahk_id " this.ie.hwnd
		DetectHiddenWindows, Off
		
		;Gui, % "+Owner" this.hPotPlayer
		
		this.hookProcAdr := RegisterCallback("HookProc", "Fast")
		hHook := SetWinEventHook(0x800B,0x800B,0,this.hookProcAdr,0,0,0)	; EVENT_OBJECT_LOCATIONCHANGE 
		WinEvents.Register(this.hPlugin, this)
		
		WinGetPos, pX, pY, pW, pH, % "ahk_id " this.hPotPlayer
		Gui, Show, % "x" pX " y" pY - 71 " w" 430 "h " 15, % this.Title
		
		DllCall("MoveWindow", "Ptr", this.hPotPlayer, "Int", pX + 1, "Int", pY + 1, "Int", pW + 1, "Int", pH + 1, "Int", true)
		Sleep, 50
		DllCall("MoveWindow", "Ptr", this.hPotPlayer, "Int", pX - 1, "Int", pY - 1, "Int", pW - 1, "Int", pH - 1, "Int", true)
		
		;this.WinMove(this.hPotPlayer, "vc hc")
		SetTimer, % isOnAir, 600000
		SetTimer, % MakeVisible, 500
		
		;DllCall("psapi.dll\EmptyWorkingSet", "Ptr", -1)
	}
	
	GuiClose()
	{
		WinEvents.Unregister(this.hPlugin)
		BrowserEmulation(0)
		Gui, Destroy
		try WinKill, % "ahk_id " this.hPotPlayer
		this.ie.Quit(), this.ie := ""
		DllCall("GlobalFree", "Ptr", this.hookProcAdr, "Ptr")
		this.CloseCallback()
	}
	
	RegisterCloseCallback(CloseCallback)
	{
		this.CloseCallback := CloseCallback
	}
	
	Refresh()
	{
		global
		Gui, Menu
		try Menu, FilmMenu, Delete,
		try Menu, AniMenu, Delete,
		try Menu, ShowMenu, Delete,
		try Menu, EtcMenu, Delete,
		;MsgBox, 삭제
		this.ParsePOOO(), this.UpdateMenu("Film", "영화"), this.UpdateMenu("Ani", "애니"), this.UpdateMenu("Show", "예능"), this.UpdateMenu("Etc", "기타"), this.FreeObjects()
		Gui, Menu, MyMenuBar
		;WinSet, Redraw,, % "ahk_id " this.hPlugin
		;MsgBox, 완료
	}
	
	isPluginTop()
	{
		global
		
		If (WinExist("ahk_id " this.hPotPlayer) && WinExist("ahk_id " this.hPlugin)) {
			
			if (WinActive("ahk_id " this.hPotPlayer)) {
				If !(WinActive("ahk_id " this.hPlugin) || WinActive("ahk_id " this.ie.hwnd)) {
					WinSet, AlwaysOnTop, On, % "ahk_id " this.hPlugin
					WinSet, AlwaysOnTop, Off, % "ahk_id " this.hPlugin
					WinSet, AlwaysOnTop, On, % "ahk_id " this.ie.hwnd
					WinSet, AlwaysOnTop, Off, % "ahk_id " this.ie.hwnd
				}
			} else if !(WinActive("ahk_id " this.hPotPlayer)) {
				If (WinActive("ahk_id " this.hPlugin) || WinActive("ahk_id " this.ie.hwnd)) {
					WinSet, AlwaysOnTop, On, % "ahk_id " this.hPotPlayer 
					WinSet, AlwaysOnTop, Off, % "ahk_id " this.hPotPlayer 
				}
			}
		}
		
		else if !(WinExist("ahk_id " this.hPotPlayer)) {
			this.GuiClose()
		}
	}
	
	PDMenu(ItemName, ItemPos, MenuName)
	{
		PDName := SubStr(SubStr(ItemName, 1, InStr(ItemName, "`t")), 1, -1) ;Part := SubStr(MenuName, 1, -4)
		DefaultServer := "hi.cdn.livehouse.in", forVerify := "", InputURL := "", LatterT := ""
		InputURL := "http://" . DefaultServer "/" . this.DB[PDName] . "/video/playlist.m3u8"
		
		WinGetPos, pX, pY, pW, pH, % "ahk_id " this.hPotPlayer
		
		ControlFocus,, % "ahk_id " this.hPotPlayer
		ControlSend,, {Ctrl Down}u{Ctrl Up}, % "ahk_id " this.hPotPlayer
		WinWait, ahk_class #32770, 주소 열기
		Teleport := WinExist("ahk_class #32770", "주소 열기")
		
		while forVerify != InputURL {
			ControlClick, Button2, ahk_id %Teleport%,,,, NA ; 목록 삭제
			Sleep,30
			ControlSetText, Edit1, %InputURL%, ahk_id %Teleport% ; 주소
			Sleep, 30
			ControlGetText, forVerify, Edit1, ahk_id %Teleport%  ;check
			Sleep, 30
		}
		ControlClick, Button7, ahk_id %Teleport%,,,, NA   ; 확인(&O)
		
		;try Run, % "iexplore.exe https://livehouse.in/en/channel/" . this.DB[PDName] . "/chatroom"
		this.ie.Navigate("https://livehouse.in/en/channel/" . this.DB[PDName] . "/chatroom")
		
		while LatterT != "다음 팟플레이어"
			WinGetTitle, LatterT, % "ahk_id " this.hPotPlayer
		Sleep, 200
		
		while LatterT != "playlist.m3u8 - 다음 팟플레이어"
			WinGetTitle, LatterT, % "ahk_id " this.hPotPlayer
		Sleep, 200
		
		DllCall("MoveWindow", "Ptr", this.hPotPlayer, "Int", pX, "Int", pY, "Int", pW, "Int", pH, "Int", true)
		
		/*
		try Run, % "https://livehouse.in/en/channel/" . DB[PDName] . "/chatroom",,, ChatPID
		WinWait, % "ahk_pid " ChatPID
		Room := WinExist("ahk_pid " ChatPID)
		*/
	
	}
	
	FreeObjects()
	{
		global
		FilmHTML := "", AniHTML := "", ShowHTML := "", EtcHTML := ""
		Small := "", Smaller := "", poo := "", html := "", LiveFilm := "" , LiveAni := "", LiveShow := "", LiveEtc := ""
	}
	
	ParsePOOO()
	{
		global
		
		poo := ComObjCreate("WinHttp.WinHttpRequest.5.1"), poo.Open("GET", "http://poooo.ml/", true), poo.Send(), poo.WaitForResponse()
		Small := SubStr(poo.ResponseText, 1, InStr(poo.ResponseText, "Music Top 50")), Smaller := SubStr(Small, 1, InStr(Small, "트위치_KR"))
		html := ComObjCreate("HTMLFile"), html.Write(Smaller), html.Close()
		
		while html.getElementsByClassName("livelist")[A_Index-1].innerText
			OnlineList .= html.getElementsByClassName("livelist")[A_Index-1].innerText
		
		LiveFilm := html.getElementsByClassName("livelist")[0].OuterHTML, FilmHTML := ComObjCreate("HTMLFile"), FilmHTML.Write(LiveFilm), FilmHTML.Close()
		LiveAni := html.getElementsByClassName("livelist")[1].OuterHTML, AniHTML := ComObjCreate("HTMLFile"), AniHTML.Write(LiveAni), AniHTML.Close()
		LiveShow := html.getElementsByClassName("livelist")[2].OuterHTML, ShowHTML := ComObjCreate("HTMLFile"), ShowHTML.Write(LiveShow), ShowHTML.Close()
		LiveEtc := html.getElementsByClassName("livelist")[3].OuterHTML, EtcHTML := ComObjCreate("HTMLFile"), EtcHTML.Write(LiveEtc), EtcHTML.Close()
	}
	
	UpdateMenu(Category, Kor := "")
	{
		global
		/*
		Loop, % NumGet(&%Category%, 4*A_PtrSize) {
			if !InStr(OnlineList, %Category%[A_Index]["PD"])
				continue	;	%Category%[A_Index].Delete("PD")
			try Menu, % Category . "Menu", Add, % %Category%[A_Index]["PD"] "`t" %Category%[A_Index]["Channel"], % LPP
			try Menu, % Category . "Menu", Icon, % %Category%[A_Index]["PD"] "`t" %Category%[A_Index]["Channel"], % A_Temp . "\on.png",, 0
		}
		*/
		while %Category%HTML.getElementsByClassName("deepblue")[A_Index-1].innerText
		{
			try Menu, % Category . "Menu", Add
			, % %Category%HTML.getElementsByClassName("deepblue")[A_Index-1].innerText "`t" %Category%HTML.getElementsByClassName("ellipsis")[A_Index-1].innerText, % LPP
			try Menu, % Category . "Menu", Icon
			, % %Category%HTML.getElementsByClassName("deepblue")[A_Index-1].innerText "`t" %Category%HTML.getElementsByClassName("ellipsis")[A_Index-1].innerText
			, % A_Temp . "\on.png",, 0
		}
		
		try Menu, MyMenuBar, Add, % Kor . ":방송", % ":" . Category . "Menu"
		try Menu, MyMenuBar, Icon, % Kor . ":방송", %A_Temp%\PD.png,, 0
	}
}

PlayerClose(Init)
{
	ExitApp
}

HookProc(hWinEventHook, event, hwnd) 
{
	global Init
	if (hwnd == Init.hPotPlayer)
	{
		WinGetPos hX, hY, hW, hH, % "ahk_id " Init.hPotPlayer
		WinGetPos cX, cY, cW, cH, % "ahk_id " Init.hPlugin
		DllCall("MoveWindow", "Ptr", Init.hPlugin, "Int", hX, "Int", hY - 66, "Int", hW, "Int", cH, "Int", true)
		DllCall("MoveWindow", "Ptr", Init.ie.hwnd, "Int", hX + hW, "Int", hY - 66, "Int", 400, "Int", hH + 66, "Int", true)
		
		/*
		WinSet, AlwaysOnTop, On, % "ahk_id " hPlugin
		WinSet, AlwaysOnTop, Off, % "ahk_id " hPlugin
		WinSet, AlwaysOnTop, On, % "ahk_id " ieFrame
		WinSet, AlwaysOnTop, Off, % "ahk_id " ieFrame
		*/
	}
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) { 
   DllCall("CoInitialize", "uint", 0) 
   return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "uint", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags) 
}

class WinEvents ; static class
{
	static Table := {}
	
	Register(hWnd, Class, Prefix="Gui")
	{
		Gui, +LabelWinEvents.
		this.Table[hWnd] := {Class: Class, Prefix: Prefix}
	}
	
	Unregister(hWnd)
	{
		this.Table.Delete(hWnd)
	}
	
	Dispatch(hWnd, Type)
	{
		Info := this.Table[hWnd]
		
		return Info.Class[Info.Prefix . Type].Call(Info.Class)
	}
	
	Close()
	{
		return WinEvents.Dispatch(this, "Close")
	}
	
	Size()
	{
		return WinEvents.Dispatch(this, "Size")
	}
}

json_toobj( str ) {

	quot := """" ; firmcoded specifically for readability. Hardcode for (minor) performance gain
	ws := "`t`n`r " Chr(160) ; whitespace plus NBSP. This gets trimmed from the markup
	obj := {} ; dummy object
	objs := [] ; stack
	keys := [] ; stack
	isarrays := [] ; stack
	literals := [] ; queue
	y := nest := 0

	StringGetPos, z, str, %quot% ; initial seek
	while !ErrorLevel
	{
		StringGetPos, x, str, %quot%,, % z + 1
		while !ErrorLevel
		{
			StringMid, key, str, z + 2, x - z - 1
			StringReplace, key, key, \\, \u005C, A
			If SubStr( key, 0 ) != "\"
				Break
			StringGetPos, x, str, %quot%,, % x + 1
		}
		str := ( z ? SubStr( str, 1, z ) : "" ) quot SubStr( str, x + 2 ) ; this won't
		StringReplace, key, key, \%quot%, %quot%, A
		StringReplace, key, key, \b, % Chr(08), A
		StringReplace, key, key, \t, % A_Tab, A
		StringReplace, key, key, \n, `n, A
		StringReplace, key, key, \f, % Chr(12), A
		StringReplace, key, key, \r, `r, A
		StringReplace, key, key, \/, /, A
		while y := InStr( key, "\u", 0, y + 1 )
			if ( A_IsUnicode || Abs( "0x" SubStr( key, y + 2, 4 ) ) < 0x100 )
				key := ( y = 1 ? "" : SubStr( key, 1, y - 1 ) ) Chr( "0x" SubStr( key, y + 2, 4 ) ) SubStr( key, y + 6 )

		literals.insert(key)

		StringGetPos, z, str, %quot%,, % z + 1 ; seek
	}

	key := isarray := 1

	Loop Parse, str, % "]}"
	{
		StringReplace, str, A_LoopField, [, [], A
		Loop Parse, str, % "[{"
		{
			if ( A_Index != 1 )
			{
				objs.insert( obj )
				isarrays.insert( isarray )
				keys.insert( key )
				obj := {}
				isarray := key := Asc( A_LoopField ) = 93
			}

			if ( isarray )
			{
				Loop Parse, A_LoopField, `,, % ws "]"
					if ( A_LoopField != "" )
						obj[key++] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			else
			{
				Loop Parse, A_LoopField, `,
					Loop Parse, A_LoopField, :, % ws
						if ( A_Index = 1 )
							key := A_LoopField = quot ? literals.remove(1) : A_LoopField
						else if ( A_Index = 2 && A_LoopField != "" )
							obj[key] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			nest += A_Index > 1
		}

		If !--nest
			Break
		
		pbj := obj
		obj := objs.remove()
		obj[key := keys.remove()] := pbj
		If ( isarray := isarrays.remove() )
			key++

	}
	Return obj
}