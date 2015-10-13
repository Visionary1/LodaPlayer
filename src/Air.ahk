#NoEnv
#NoTrayIcon
#SingleInstance Off
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , H
SetBatchLines, -1
SetKeyDelay, 10, 10
SetMouseDelay, 0
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0
Menu, Tray, NoStandard
ComObjError(False)
From := "https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/PD/"
/*
Film := ServerInfo.getList("FilmList.txt"), FilmCount := NumGet(&Film, 4*A_PtrSize)
Ani := ServerInfo.getList("AniList.txt"), AniCount := NumGet(&Ani, 4*A_PtrSize)
Show := ServerInfo.getList("ShowList.txt"), ShowCount := NumGet(&Show, 4*A_PtrSize)
Etc := ServerInfo.getList("EtcList.txt"), EtcCount := NumGet(&Etc, 4*A_PtrSize)
*/
BrowserEmulation(1)
ServerInfo.getFilmList("FilmList.txt"), ServerInfo.getAniList("AniList.txt"), ServerInfo.getShowList("ShowList.txt"), ServerInfo.getEtcList("EtcList.txt")
FullEx := ObjBindMethod(ViewControl, "ToggleAll"), LessEx := ObjBindMethod(ViewControl, "ToggleOnlyMenu"), CheckPoo := ObjBindMethod(ServerInfo, "OnAirCheck")
Init := new LodaPlayer()
Init.RegisterCloseCallback(Func("PlayerClose"))
SetTimer, %CheckPoo%, 900000  ;900000
Hotkey, IfWinActive, % "ahk_id " hMainWindow
Hotkey, Ctrl & Enter, %LessEx%
Hotkey, Alt & Enter, %FullEx%
return

PlayerClose(Init)
{
	BrowserEmulation(0), DaumPotSet(0)
	ExitApp
}

class LodaPlayer {

	static W := A_ScreenWidth * 0.7, H := A_ScreenHeight * 0.7, BaseAddr := "https://livehouse.in/en/channel/", ExternalCount := 0, InternalCount := 1, CustomCount := 0, PluginCount := 0, Title := "로다 플레이어 Air 1.2.6", PotChatBAN := 0, TopToggleCk := 0
	
	__New()
	{
		global
		vIni := class_EasyIni("LodaPlayer.ini"), PotIni := vIni.Player.PotLocation, chatBAN := vIni.GaGaLive.ChatPreSet, DisplayW := vIni.Player.Width, DisplayH := vIni.Player.Height
		SWP_NACT := 0x10, SWP_NSC := 0x400, SWP_NOZO := 0x0200
		
		Gui, New, +Resize -DPIScale +hWndhMainWindow +LastFound +0x2000000 ;WS_CLIPCHILDREN := 0x2000000
		this.hMainWindow := hMainWindow
		
		Gui, Add, ActiveX, % " x" 0 " y" 0 " w" this.W*0.25 " h" this.H-10 " hwndhGaGa vChat", Shell.Explorer
		Chat.Navigate("http://www.gagalive.kr/livechat1.swf?chatroom=~~~new_ForPotsu&fontlarge=true")
		this.hGaGa := hGaGa, Chat.Silent := true
		
		Gui, Add, ActiveX, % " x" this.W *0.25 " y" 0 " w" this.W*0.75 " h" this.H-10 " hwndhStream vStream", Shell.Explorer
		Stream.Navigate("http://poooo.ml/")
		this.hStream := hStream, Stream.Silent := true
		
		this.Bound := []
		this.Bound.OnMessage := this.OnMessage.Bind(this)
		
		Menu, GaGaMenu, Add, 채팅하기, LodaPlayer.GaGaMenu
		if (vIni.GaGaLive.ChatPreSet = 0)
			Menu, GaGaMenu, Icon, 채팅하기, %A_Temp%\on.png,,0
		if (vIni.GaGaLive.ChatPreSet = 1) {
			GuiControl, Disable, chat
			GuiControl, Hide, chat
			Menu, GaGaMenu, Icon, 채팅하기, %A_Temp%\off.png,,0
		}
		Menu, GaGaMenu, Add, 새로고침, LodaPlayer.GaGaMenu
		Menu, MyMenuBar, Add, 가가라이브:설정, :GaGaMenu
		
		Menu, SetMenu, Add, UI 인터페이스 : 태그 형식으로 전환, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add, 익스플로러 전용 : 팝업으로 보기, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add,
		Menu, SetMenu, Add, 로다 플레이어를 항상위로, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add,
		Menu, SetMenu, Add, 내장브라우저 : 크롬을 사용, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add, 내장플레이어 : 다음팟플레이어를 사용, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add, 다음팟플레이어전용 : 채팅창숨기기, LodaPlayer.PlayerMenu
		Menu, SetMenu, Disable, 다음팟플레이어전용 : 채팅창숨기기
		Menu, SetMenu, Add,
		Menu, SetMenu, Add, 문의 ＆ 피드백, LodaPlayer.PlayerMenu
		
		Menu, ErrorFixMenu, Add, 렉＆끊김현상시 : 방송 새로고침, LodaPlayer.PlayerMenu
		Menu, ErrorFixMenu, Add, 설정리셋 : 초기화후 재시작, LodaPlayer.PlayerMenu
		Menu, ErrorFixMenu, Add, 즐겨찾기 목록수정 : 설정파일 열기, LodaPlayer.PlayerMenu
		Menu, ErrorFixMenu, Add, 방송＆채팅방이 안나오면 : IE11 설치, LodaPlayer.PlayerMenu
		Menu, SetMenu, Add, 에러수정＆기타설정, :ErrorFixMenu
		Menu, MyMenuBar, Add, 플레이어:설정, :SetMenu
		
		while !(IsObject(Film) && IsObject(Ani) && IsObject(Show) && IsObject(Etc))
			continue
		while !(Stream.readyState=4 || Stream.document.readyState="complete" || !Stream.busy) 
			continue
		newcon := Stream.document.getElementByID("main-content").InnerText, ServerInfo.ParsePD()
		
		try {
			this.UpdateMenu("Film"), this.UpdateMenu("Ani"), this.UpdateMenu("Show"), this.UpdateMenu("Etc")
			Menu, MyMenuBar, Add, 영화:방송, :FilmMenu
			Menu, MyMenuBar, Add, 애니:방송, :AniMenu
			Menu, MyMenuBar, Add, 예능:방송, :ShowMenu
			Menu, MyMenuBar, Add, 기타:방송, :EtcMenu
			
			for SectionName, a in vIni
				for KeyName, Value in a
					if SectionName = Favorite
						Menu, FavoriteMenu, Add, %KeyName%, LodaPlayer.PDMenu
			Menu, MyMenuBar, Add, 즐겨찾기:목록, :FavoriteMenu
		}
		Menu, MyMenuBar, Add, 주소로 이동 ,LodaPlayer.PlayerMenu
		Menu, MyMenuBar, Add, POOOO ,LodaPlayer.PlayerMenu
		Menu, MyMenuBar, Add, 즐겨찾기, LodaPlayer.PlayerMenu
		Menu, MyMenuBar, Add, 방송추가 ,LodaPlayer.PlayerMenu
		Menu, MyMenuBar, Add, 도움말 ,LodaPlayer.PlayerMenu
		
		Menu, MyMenuBar, Icon, POOOO, %A_Temp%\pooq.png,, 0
		Menu, MyMenuBar, Icon, 플레이어:설정, %A_Temp%\setting.png,, 0
		Menu, MyMenuBar, Icon, 가가라이브:설정, %A_Temp%\chat.png,, 0
		Menu, MyMenuBar, Icon, 주소로 이동, %A_Temp%\byaddr.png,, 0
		Menu, MyMenuBar, Icon, 즐겨찾기, %A_Temp%\favorite.png,, 0
		Menu, MyMenuBar, Icon, 방송추가, %A_Temp%\addpd.png,, 0
		Menu, MyMenuBar, Icon, 도움말, %A_Temp%\help.png,, 0
		Menu, MyMenuBar, Icon, 영화:방송, %A_Temp%\PD.png,, 0
		Menu, MyMenuBar, Icon, 애니:방송, %A_Temp%\PD.png,, 0
		Menu, MyMenuBar, Icon, 예능:방송, %A_Temp%\PD.png,, 0
		Menu, MyMenuBar, Icon, 기타:방송, %A_Temp%\PD.png,, 0
		Menu, GaGaMenu, Icon, 새로고침, %A_Temp%\refresh.png,, 0
		Menu, SetMenu, Icon, UI 인터페이스 : 태그 형식으로 전환, %A_Temp%\off.png,,0
		Menu, SetMenu, Icon, 익스플로러 전용 : 팝업으로 보기, %A_Temp%\off.png,,0
		Menu, SetMenu, Icon, 로다 플레이어를 항상위로, %A_Temp%\off.png,,0
		Menu, SetMenu, Icon, 내장브라우저 : 크롬을 사용, %A_Temp%\off.png,,0
		Menu, SetMenu, Icon, 내장플레이어 : 다음팟플레이어를 사용, %A_Temp%\off.png,,0
		Menu, SetMenu, Icon, 다음팟플레이어전용 : 채팅창숨기기, %A_Temp%\off.png,,0
		try
			Menu, MyMenuBar, Icon, 즐겨찾기:목록, %A_Temp%\PD.png,, 0
		Gui, Menu, MyMenuBar
		
		WinEvents.Register(this.hMainWindow, this)
		for each, Msg in [0x100]
			OnMessage(Msg, this.Bound.OnMessage)
		
		if DisplayW
			Gui, Show, % "w" DisplayW " h" DisplayH, % this.Title
		else if !DisplayW
			Gui, Show, % "w" this.W " h" this.H, % this.Title
		VarSetCapacity(OnlineFilm1, 0), VarSetCapacity(OnlineAni1, 0), VarSetCapacity(OnlineShow1, 0), VarSetCapacity(OnlineEtc1, 0)
	}

	GuiSize()
	{
		global
		IMAX := A_GuiWidth - ( this.W*0.25 )

		if (chatBAN = 0 && this.PluginCount = 0 && this.PotChatBAN = 0) {
			GuiControl, Move, % this.hGaGa, % " x" 0 " y" 0 " w" this.W*0.25 " h" A_GuiHeight+5
			if (this.CustomCount = 0)
				GuiControl, Move, % this.hStream, % " x" this.W*0.25 " y" 0 " w" IMAX " h" A_GuiHeight+5
			else if (this.CustomCount = 1)
				DllCall("SetWindowPos", "ptr", LodaChromeChild, "uint", 0, "int", this.W*0.25, "int", 0, "int", IMAX, "int", A_GuiHeight + 5, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
		
		if (chatBAN = 1 && this.PluginCount = 0 && this.PotChatBAN = 0) {
			if (this.CustomCount = 0)
				GuiControl, Move, % this.hStream, % " x" 0 " y" 0 " w" A_GuiWidth " h" A_GuiHeight+5
			else if (this.CustomCount = 1)
				DllCall("SetWindowPos", "ptr", LodaChromeChild, "uint", 0, "int", 0, "int", 0, "int", A_GuiWidth, "int", A_GuiHeight + 5, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
		
		if (chatBAN = 0 && this.PluginCount = 1 && this.PotChatBAN = 0) {
			GuiControl, Move, % this.hGaGa, % " x" 0 " y" 0 " w" this.W*0.25 " h" A_GuiHeight+5
			DllCall("SetWindowPos", "ptr", LodaPotChild, "uint", 0, "int", (this.W*0.25) - 2, "int", -2, "int", IMAX - 398, "int", A_GuiHeight+7, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
			if (this.CustomCount = 0)
				GuiControl, Move, % this.hStream, % " x"  A_GuiWidth - 400 " y" 0 " w" 400 " h" A_GuiHeight
			else if (this.CustomCount = 1)
				DllCall("SetWindowPos", "ptr", LodaChromeChild, "uint", 0, "int", A_GuiWidth - 400, "int", 0, "int", 400, "int", A_GuiHeight, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
		
		if (chatBAN =1 && this.PluginCount = 1 && this.PotChatBAN = 0) {
			DllCall("SetWindowPos", "ptr", LodaPotChild, "uint", 0, "int", -2, "int", -2, "int", A_GuiWidth - 398, "int", A_GuiHeight+7, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
			if (this.CustomCount = 0)
				GuiControl, Move, % this.hStream, % " x"  A_GuiWidth - 400 " y" 0 " w" 400 " h" A_GuiHeight
			else if (this.CustomCount = 1)
				DllCall("SetWindowPos", "ptr", LodaChromeChild, "uint", 0, "int", A_GuiWidth - 400, "int", 0, "int", 400, "int", A_GuiHeight, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
		
		if (chatBAN = 0 && this.PluginCount = 1 && this.PotChatBAN = 1) {
			GuiControl, Move, % this.hGaGa, % " x" 0 " y" 0 " w" this.W*0.25 " h" A_GuiHeight+5
			DllCall("SetWindowPos", "ptr", LodaPotChild, "uint", 0, "int", (this.W*0.25) - 2, "int", -2, "int", IMAX+7, "int", A_GuiHeight+7, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
		
		if (chatBAN = 1 && this.PluginCount = 1 && this.PotChatBAN = 1) {
			DllCall("SetWindowPos", "ptr", LodaPotChild, "uint", 0, "int", -2, "int", -2, "int", A_GuiWidth+7, "int", A_GuiHeight+7, "uint", SWP_NACT|SWP_NSC|SWP_NOZO)
		}
	}
	
	GuiClose()
	{
		global
		
		SetTimer, %CheckPoo%, Off
		VarSetCapacity( rect, 16, 0 ), DllCall("GetClientRect", uint, hMainWindow, uint, &rect ), ClientW := NumGet( rect, 8, "int" ), ClientH := NumGet( rect, 12, "int" )
		vIni.GaGaLive.ChatPreSet := chatBAN, vIni.Player["Width"] := ClientW, vIni.Player["Height"] := ClientH, vIni.Save()
		FileSetAttrib, +H, LodaPlayer.ini
		
		if (LodaPlayer.CustomCount = 1) {
			ControlFocus,, ahk_id %LodaChromeChild%
			ControlSend,, {Ctrl Down}w{Ctrl Up}, ahk_id %LodaChromeChild%
		}
		
		try {
			WinKill, ahk_id %LodaChromeChild%
			WinKill, ahk_id %LodaPotChild%
		}
		
		for each, Msg in [0x100]
			OnMessage(Msg, this.Bound.OnMessage, 0)
		this.Delete("Bound")
		WinEvents.Unregister(this.hMainWindow)
		Gui, Destroy
		this.CloseCallback()
	}
	
	RegisterCloseCallback(CloseCallback)
	{
		this.CloseCallback := CloseCallback
	}
	
	OnMessage(wParam, lParam, Msg, hWnd)
	{
		global Stream
		static fields := "hWnd,Msg,wParam,lParam,A_EventInfo,A_GuiX,A_GuiY"
		
		if (Msg == 0x100)
		{
			WinGetClass, ClassName, ahk_id %hWnd%
			
			if (ClassName = "MacromediaFlashPlayerActiveX" && wParam == GetKeyVK("Enter"))
				SendInput, {tab 4}{space}+{tab 4}
			
			if (ClassName = "Internet Explorer_Server")
			{
				pipa := ComObjQuery(Stream.document, "{00000117-0000-0000-C000-000000000046}")
				VarSetCapacity(Msgs, 48)
				Loop Parse, fields, `,             ;`
					NumPut(%A_LoopField%, Msgs, (A_Index-1)*A_PtrSize)
				TranslateAccelerator := NumGet(NumGet(1*pipa)+5*A_PtrSize)
				Loop 2
					r := DllCall(TranslateAccelerator, "Ptr",pipa, "Ptr",&Msgs)
				until wParam != 9 || Stream.document.activeElement != ""
				ObjRelease(pipa)
				if r = 0
					return 0
			}
		}
	}
	
	GaGaMenu()
	{
		global
		CheckSum := Stream.LocationURL()
		
		if (A_ThisMenuItem = "채팅하기" && ChatBAN = 0) {
			ChatBAN := 1
			GuiControl, Disable, chat
			GuiControl, Hide, chat
			Menu, GaGaMenu, NoIcon, 채팅하기
			Menu, GaGaMenu, Icon, 채팅하기, %A_Temp%\off.png,,0
			RedrawWindow()
			
			if (LodaPlayer.CustomCount = 0 || LodaPlayer.PluginCount = 0)
			{
				if InStr(CheckSum, "https://livehouse.in/en/channel/")
				{
					VarSetCapacity( rect, 16, 0 )
					DllCall("GetClientRect", uint, hMainWindow, uint, &rect )
					ClientW := NumGet( rect, 8, "int" )
					if (ClientW > 1279)
						Stream.document.getElementsByTagName("DIV")[66].Click() ; 왼쪽 프로필창 자동제거
				}
			}
			return
		}
		
		if (A_ThisMenuItem = "채팅하기" && ChatBAN = 1) {
			ChatBAN := 0
			GuiControl, Enable, chat
			GuiControl, Show, chat
			Menu, GaGaMenu, NoIcon, 채팅하기
			Menu, GaGaMenu, Icon, 채팅하기, %A_Temp%\on.png,,0
			RedrawWindow()
			
			if (LodaPlayer.CustomCount = 0 || LodaPlayer.PluginCount = 0)
			{
				if InStr(CheckSum, "https://livehouse.in/en/channel/")
				{
					VarSetCapacity( rect, 16, 0 )
					DllCall("GetClientRect", uint, hStream, uint, &rect )
					ClientW := NumGet( rect, 8, "int" )
					if (ClientW > 1279)
						Stream.document.getElementsByTagName("DIV")[66].Click() ; 왼쪽 프로필창 자동제거
				}
			}
			return
		}
		
		if (A_ThisMenuItem = "새로고침")
			Chat.Refresh()
	}
	
	PlayerMenu()
	{
		global
		
		if (A_ThisMenuItem = "다음팟플레이어전용 : 채팅창숨기기" && LodaPlayer.PotChatBAN = 0 && LodaPlayer.PluginCount = 1) {
			if LodaPlayer.CustomCount = 0
			{
				GuiControl, Disable, Stream
				WinHide, ahk_id %hStream%
			}
			else if LodaPlayer.CustomCount = 1
				WinHide, ahk_id %LodaChromeChild%
			
			Menu, SetMenu, NoIcon, 다음팟플레이어전용 : 채팅창숨기기
			Menu, SetMenu, Icon, 다음팟플레이어전용 : 채팅창숨기기, %A_Temp%\on.png,,0
			LodaPlayer.PotChatBAN := 1, RedrawWindow()
			return
		}
		
		if (A_ThisMenuItem = "다음팟플레이어전용 : 채팅창숨기기" && LodaPlayer.PotChatBAN = 1 && LodaPlayer.PluginCount = 1) {
			if LodaPlayer.CustomCount = 0
			{
				GuiControl, Enable, Stream
				WinShow, ahk_id %hStream%
			}
			else if LodaPlayer.CustomCount = 1
				WinShow, ahk_id %LodaChromeChild%
			
			Menu, SetMenu, NoIcon, 다음팟플레이어전용 : 채팅창숨기기
			Menu, SetMenu, Icon, 다음팟플레이어전용 : 채팅창숨기기, %A_Temp%\off.png,,0
			LodaPlayer.PotChatBAN := 0, RedrawWindow()
			return
		}
		
		if (A_ThisMenuItem = "POOOO") {
			if LodaPlayer.CustomCount = 0
			{
				if ( Stream.LocationURL() = "http://poooo.ml/" )
					return
				Stream.Navigate("http://poooo.ml/")
			}
			
			else if LodaPlayer.CustomCount = 1
			{
				ClipHistory := Clipboard
				Clipboard := "http://poooo.ml/"
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlFocus,, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F6}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Ctrl Down}{v}{Ctrl Up}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Enter}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Sleep, 30
				Clipboard := ClipHistory, RedrawWindow()
			}
			return
		}
		
		if  (A_ThisMenuItem = "UI 인터페이스 : 태그 형식으로 전환" && LodaPlayer.PluginCount = 0) {
			if (LodaPlayer.BaseAddr = "https://livehouse.in/en/channel/")
			{
				MsgBox, 262180, 보기, 방송UI를 태그 형식으로 전환할까요?
				IfMsgBox, Yes
				{
					Menu, SetMenu, NoIcon, UI 인터페이스 : 태그 형식으로 전환
					Menu, SetMenu, Icon, UI 인터페이스 : 태그 형식으로 전환, %A_Temp%\on.png,,0
					LodaPlayer.BaseAddr := "https://livehouse.in/en/embed/channel/", LoNumber := ReservedAddr
					return LodaPlayer.StartTrans(LoNumber)
				}
			}
			
			if (LodaPlayer.BaseAddr = "https://livehouse.in/en/embed/channel/")
			{
				MsgBox, 262180, 보기, 방송UI를 기본 형식으로 전환할까요?
				IfMsgBox, Yes
				{
					Menu, SetMenu, NoIcon, UI 인터페이스 : 태그 형식으로 전환
					Menu, SetMenu, Icon, UI 인터페이스 : 태그 형식으로 전환, %A_Temp%\off.png,,0
					LodaPlayer.BaseAddr := "https://livehouse.in/en/channel/", LoNumber := ReservedAddr
					return LodaPlayer.StartTrans(LoNumber)
				}
			}
		}
		
		if (A_ThisMenuItem = "익스플로러 전용 : 팝업으로 보기") {
			if (LodaPlayer.CustomCount = 1 || LodaPlayer.PluginCount = 1)
			{
				MsgBox, 262192, 안내, 기본 플레이어모드로 전환하세요`n`n*다음팟모드`,크롬해제
				return
			}
			
			if (LodaPlayer.InternalCount = 1 && LodaPlayer.ExternalCount = 0)
			{
				MsgBox, 262180, 팝업모드, 동시에 여러 방송 시청이 가능해집니다! `n`팝업형으로 전환할까요?
				IfMsgBox, Yes
				{
					LodaPlayer.InternalCount := 0, LodaPlayer.ExternalCount := 1
					Menu, SetMenu, NoIcon, 익스플로러 전용 : 팝업으로 보기
					Menu, SetMenu, Icon, 익스플로러 전용 : 팝업으로 보기, %A_Temp%\on.png,,0
				}
				return
			}
			
			if (LodaPlayer.InternalCount = 0 && LodaPlayer.ExternalCount = 1)
			{
				MsgBox, 262180, 내장모드, 방송화면이 플레이어안으로 들어옵니다! `n`n내장모드로 전환할까요?
				IfMsgBox, Yes
				{
					LodaPlayer.InternalCount := 1, LodaPlayer.ExternalCount := 0
					Menu, SetMenu, NoIcon, 익스플로러 전용 : 팝업으로 보기
					Menu, SetMenu, Icon, 익스플로러 전용 : 팝업으로 보기, %A_Temp%\off.png,,0
				}
				return
			}
		}
		
		if (A_ThisMenuItem = "로다 플레이어를 항상위로") {
			WinSet, AlwaysOnTop, Toggle
			if LodaPlayer.TopToggleCk = 0
			{
				Menu, SetMenu, NoIcon, 로다 플레이어를 항상위로
				Menu, SetMenu, Icon, 로다 플레이어를 항상위로, %A_Temp%\on.png,,0
				return LodaPlayer.TopToggleCk := 1
			}
			if LodaPlayer.TopToggleCk = 1
			{
				Menu, SetMenu, NoIcon, 로다 플레이어를 항상위로
				Menu, SetMenu, Icon, 로다 플레이어를 항상위로, %A_Temp%\off.png,,0
				return LodaPlayer.TopToggleCk := 0
			}
		}
		
		if (A_ThisMenuItem = "내장브라우저 : 크롬을 사용") {
			if (LodaPlayer.CustomCount = 0)
			{
				MsgBox, 262180, 사용자 브라우저, 로다 플레이어는 익스플로러를 기본으로 사용합니다`n`n크롬 브라우저로 변경하시겠어요?
				IfMsgBox, Yes
				{
					MsgBox, 262208, 크롬으로 전환, 내장브라우저를 IE에서 크롬으로 전환합니다`n`n전체화면(F11) 메시지는 건드리지 말고`,`n전체화면을 풀지도 마세요`, 작동중에 에러가 발생할 수 있습니다
					LodaPlayer.CustomCount := 1
					Stream.Navigate("about:blank")
					GuiControl, Disable, Stream
					GuiControl, Hide, Stream
					Menu, SetMenu, NoIcon, 내장브라우저 : 크롬을 사용
					Menu, SetMenu, Icon, 내장브라우저 : 크롬을 사용, %A_Temp%\on.png,,0
					
					Process, Exist, chrome.exe
					if ErrorLevel != 0
						ChildPID := ErrorLevel
					else
					{
						try
							Run, chrome.exe,,, ChildPID
						catch e
						{
							RegRead, ChromeLocation, HKCU, SOFTWARE\Google\Update, path
							if ErrorLevel = 0
							{
								try
									Run, % SubStr(ChromeLocation, 1, -23) . "Chrome\Application\chrome.exe",,, ChildPID
							}
							else
							{
								MsgBox, 262160, 오류, 크롬이 설치되어있지 않은것 같습니다
								return
							}
						}
					}
					
					WinWait ahk_pid %ChildPID%
					LodaChromeChild := WinExist("ahk_pid " ChildPID), VarSetCapacity(ChildPID, 0), LodaPlayer.SetChildWindow(LodaChromeChild, hMainWindow)
					ControlFocus,, ahk_id %LodaChromeChild%
					ControlSend,, {F11}, ahk_id %LodaChromeChild%
					Sleep, 500
					RedrawWindow()
					return
				}
			}
		
			if (LodaPlayer.CustomCount = 1)
			{
				MsgBox, 262180, 사용자 브라우저, 기본 IE브라우저로 전환하시겠어요?
				IfMsgBox, Yes
				{
					LodaPlayer.CustomCount := 0
					GuiControl, Enable, Stream
					GuiControl, Show, Stream
					
					ControlFocus,, ahk_id %LodaChromeChild%
					ControlSend,, {Ctrl Down}w{Ctrl Up}, ahk_id %LodaChromeChild%
					WinKill, ahk_id %LodaChromeChild%
					WinWaitClose, ahk_id %LodaChromeChild%
					
					Menu, SetMenu, NoIcon, 내장브라우저 : 크롬을 사용
					Menu, SetMenu, Icon, 내장브라우저 : 크롬을 사용, %A_Temp%\off.png,,0
					RedrawWindow()
					return
				}
			}
		}

		if (A_ThisMenuItem = "내장플레이어 : 다음팟플레이어를 사용") {
			if LodaPlayer.PluginCount = 0
			{
				MsgBox, 262180, 다음팟모드, 다음팟플레이어로 방송을 시청하시겠어요?`n`n'예'를 누르시면`, 다음팟모드로 전환합니다!
				IfMsgBox, Yes
				{
					pressed := CMsgbox( "스트리밍 서버 선택", "스트리밍 서버를 선택하세요", "&기본|*대만서버2|&일본서버|&홍콩서버", "Q", 0)
					if (pressed = "기본")
						DefaultServer := "hi.cdn.livehouse.in"
					else if (pressed = "대만서버2")
						DefaultServer := "220.130.187.73"
					else if (pressed = "일본서버")
						DefaultServer := "106.187.40.237"
					else if (pressed = "홍콩서버")
						DefaultServer := "119.81.135.21"
					
					if (LodaPlayer.InternalCount = 0 && LodaPlayer.ExternalCount = 1)
					{
						Menu, SetMenu, NoIcon, 익스플로러 전용 : 팝업으로 보기
						Menu, SetMenu, Icon, 익스플로러 전용 : 팝업으로 보기, %A_Temp%\off.png,,0
						Menu, SetMenu, Disable, 익스플로러 전용 : 팝업으로 보기
					}
					else
						Menu, SetMenu, Disable, 익스플로러 전용 : 팝업으로 보기
					
					if (LodaPlayer.BaseAddr = "https://livehouse.in/en/embed/channel/")
					{
						Menu, SetMenu, NoIcon, UI 인터페이스 : 태그 형식으로 전환
						Menu, SetMenu, Icon, UI 인터페이스 : 태그 형식으로 전환, %A_Temp%\off.png,,0
						Menu, SetMenu, Disable, UI 인터페이스 : 태그 형식으로 전환
					}
					else
						Menu, SetMenu, Disable, UI 인터페이스 : 태그 형식으로 전환
					
					Menu, SetMenu, Enable, 다음팟플레이어전용 : 채팅창숨기기
					LodaPlayer.PluginCount := 1, LodaPlayer.InternalCount := 1, LodaPlayer.ExternalCount := 0, LodaPlayer.BaseAddr := "https://livehouse.in/en/channel/"
					Menu, SetMenu, NoIcon, 내장플레이어 : 다음팟플레이어를 사용
					Menu, SetMenu, Icon, 내장플레이어 : 다음팟플레이어를 사용, %A_Temp%\on.png,,0
					
					if LodaPlayer.CustomCount = 0
					{
						if (Stream.LocationURL() != "about:blank")
							Stream.Navigate("about:blank")
					}
					
					DaumPotSet(1)
					RegRead, PotLocation, HKCU, SOFTWARE\DAUM\PotPlayer, ProgramFolder
					if ErrorLevel = 0
					{
						try
							Run, % PotLocation . "\PotPlayerMini.exe",,, ChildPID
					}
					else if ErrorLevel = 1
					{
						if PotIni
						{
							try
								Run, % PotIni,,, ChildPID
						}
						if !PotIni
						{
							FileSelectFolder, PotLocation, *C:\, 0, 다음팟플레이어 경로를 설정해주세요`n\DAUM\PotPlayer 까지만 설정하면 됩니다!
							if PotLocation =
								return
							else
							{
								MsgBox, 262180, 팟플레이어, 다음팟플레이어 64비트용을 사용하고 계세요?`n`n*컴퓨터의 사양을 묻는게 아닙니다
								IfMsgBox, No
								{
									try
										Run, % PotLocation . "\PotPlayerMini.exe",,, ChildPID
									vIni.Player["PotLocation"] := PotLocation . "\PotPlayerMini.exe"
								}
								IfMsgBox, Yes
								{
									try
										Run, % PotLocation . "\PotPlayerMini64.exe",,, ChildPID
									vIni.Player["PotLocation"] := PotLocation . "\PotPlayerMini64.exe"
								}
							}
						}
					}
					WinWait ahk_pid %ChildPID%
					LodaPotChild := WinExist("ahk_pid " ChildPID), VarSetCapacity(ChildPID, 0), DaumPotSet("Fix"), LodaPlayer.SetChildWindow(LodaPotChild, hMainWindow), RedrawWindow()
				}
				return
			}
		
			if LodaPlayer.PluginCount = 1
			{
				MsgBox, 262180, 모드 해제, 다음팟플레이어로 시청을 중단하시겠어요?`n`n'예'를 누르면 다음팟 모드를 해제합니다
				IfMsgBox, Yes
				{
					LodaPlayer.PluginCount := 0
					
					if (LodaPlayer.CustomCount = 0)
					{
						if (LodaPlayer.PotChatBAN = 1)
						{ 
							Menu, SetMenu, Disable, 다음팟플레이어전용 : 채팅창숨기기
							LodaPlayer.PotChatBAN := 0
							GuiControl, Enable, Stream
							GuiControl, Show, Stream
						}
						else if (LodaPlayer.PotChatBAN = 0)
							Menu, SetMenu, Disable, 다음팟플레이어전용 : 채팅창숨기기
						
					if ( Stream.LocationURL() != "http://poooo.ml/" )
						Stream.Navigate("http://poooo.ml/")
					}
					
					Menu, SetMenu, Enable, UI 인터페이스 : 태그 형식으로 전환
					Menu, SetMenu, Enable, 익스플로러 전용 : 팝업으로 보기
					Menu, SetMenu, NoIcon, 내장플레이어 : 다음팟플레이어를 사용
					Menu, SetMenu, Icon, 내장플레이어 : 다음팟플레이어를 사용, %A_Temp%\off.png,,0
					Menu, SetMenu, NoIcon, 다음팟플레이어전용 : 채팅창숨기기
					Menu, SetMenu, Icon, 다음팟플레이어전용 : 채팅창숨기기, %A_Temp%\off.png,,0
					WinKill, ahk_id %LodaPotChild%
					WinWaitClose, ahk_id %LodaPotChild%
					RedrawWindow(), FreeMemory()
				}
				return
			}
		}
		
		if (A_ThisMenuItem = "문의 ＆ 피드백") {
			if LodaPlayer.CustomCount = 0
				Stream.Navigate("http://knowledgeisfree.tistory.com/guestbook")
			else if LodaPlayer.CustomCount = 1
				Run, http://knowledgeisfree.tistory.com/guestbook
			return
		}
		
		if (A_ThisMenuItem = "렉＆끊김현상시 : 방송 새로고침") {
			if LodaPlayer.CustomCount = 0
				Stream.Refresh()
			else if LodaPlayer.CustomCount = 1
			{
				ControlFocus,, ahk_id %LodaChromeChild%
				ControlSend,, {F5}, ahk_id %LodaChromeChild%
			}
			return
		}
		
		if (A_ThisMenuItem = "설정리셋 : 초기화후 재시작") {
			try
			{
			MsgBox, 262193, 초기화, 대부분의 오류는 '방송 새로고침' 으로 해결이 됩니다`n`n그럼에도 오류가있다면 '확인' 버튼을 누르세요!`n`n프로그램을 초기화하고 재시작됩니다
			IfMsgBox, Ok
				{
					ClearCookies()
					FileDelete, LodaPlayer.ini
					Reload
				}
			}
			return
		}
		
		if (A_ThisMenuItem = "즐겨찾기 목록수정 : 설정파일 열기") {
			try
				Run, LodaPlayer.ini
			if LodaPlayer.PluginCount = 0
				Stream.Navigate("http://knowledgeisfree.tistory.com/89")
			return
		}

		if (A_ThisMenuItem = "방송＆채팅방이 안나오면 : IE11 설치") {
			if LodaPlayer.CustomCount = 0
				Stream.Navigate("http://windows.microsoft.com/ko-kr/internet-explorer/download-ie")
			else if LodaPlayer.CustomCount = 1
				Run,  http://windows.microsoft.com/ko-kr/internet-explorer/download-ie
			return
		}
		
		if (A_ThisMenuItem = "주소로 이동") {
			Gui, +OwnDialogs
			InputBox, Address, 찾아가기, 채널번호를 입력해 방송으로 이동합니다`n`n채널번호를 입력하세요!`n`n채널번호 : 방송주소 끝의 6자리 숫자
			if !ErrorLevel
				return LodaPlayer.StartTrans(Address)
		}
		
		if (A_ThisMenuItem = "즐겨찾기") {
			Gui, +OwnDialogs
			if LodaPlayer.CustomCount = 0
			{
				CheckSum := Stream.LocationURL()
				if !(InStr(CheckSum, "livehouse"))
				{
					MsgBox, 262192, 즐겨찾기, 방송을 입장한 이후에 클릭해주세요
					return
				}
			}
			else if LodaPlayer.CustomCount = 1
				CheckSum := ReservedAddr
			
			MsgBox, 262180, 즐겨찾기 추가, % ReservedBanner "`n`n방송을 자주 시청하시나봐요!`n`n이 방송을 즐겨찾는 방송으로 설정할까요?"
			IfMsgBox, Yes
			{
				vIni.Favorite[ReservedBanner] := ReservedAddr, vIni.Save()
				FileSetAttrib, +H, LodaPlayer.ini
				MsgBox, 262208, 완료, 즐겨찾기에 추가하였습니다`n`n다음 실행부터 메뉴의 '즐겨찾기:목록' 에서 볼 수 있어요!
				return
			}
		}
		
		if (A_ThisMenuItem = "방송추가") {
			if LodaPlayer.CustomCount = 0
				Stream.Navigate("http://knowledgeisfree.tistory.com/84")
			else if LodaPlayer.CustomCount = 1
				Run, http://knowledgeisfree.tistory.com/84
			return
		}
		
		if (A_ThisMenuItem = "도움말") {
			if LodaPlayer.CustomCount = 0
				Stream.Navigate("http://knowledgeisfree.tistory.com/category/로다%20플레이어/메뉴얼")
			else if LodaPlayer.CustomCount = 1
				Run, % "http://knowledgeisfree.tistory.com/category/로다%20플레이어/메뉴얼"
			return
		}
	}

	PDMenu()
	{
		global
		ReservedBanner := A_ThisMenuItem, Part := SubStr(A_ThisMenu, 1, -4)
		
		if Part = Favorite
		{
			NewKey := A_ThisMenuItem
			return LodaPlayer.StartTrans(vIni.Favorite[NewKey])
		}
		else
			return LodaPlayer.StartTrans(%Part%[A_ThisMenuItemPos]["Addr"])
	}
	
	StartTrans(Go) 
	{
		global
		ReservedAddr := Go
	
		if (LodaPlayer.InternalCount = 1 && LodaPlayer.PluginCount = 0 && LodaPlayer.ExternalCount = 0) {
			if (LodaPlayer.CustomCount = 0)
			{
				Stream.Navigate(LodaPlayer.BaseAddr . Go, 0x0400)  ;navTrustedForActiveX = 0x0400,
			
				while !(Stream.readyState=4 || Stream.document.readyState="complete" || !Stream.busy) 
					continue
				
				if (LodaPlayer.BaseAddr = "https://livehouse.in/en/channel/")
				{
					VarSetCapacity( rect, 16, 0 )
					DllCall("GetClientRect", uint, hStream, uint, &rect )
					if (NumGet( rect, 8, "int" ) >= 1279)
						Stream.document.getElementsByTagName("DIV")[66].Click() ; 왼쪽 프로필창 자동제거
				}
			}
			
			if (LodaPlayer.CustomCount = 1)
			{
				Critical
				ClipHistory := Clipboard
				Clipboard := LodaPlayer.BaseAddr . Go
				ControlFocus,, ahk_id %LodaChromeChild%
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F6}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Ctrl Down}v{Ctrl Up}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Enter}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Critical, Off
				Sleep, 30
				Clipboard := ClipHistory
				RedrawWindow()
			}
		}
		
		if (LodaPlayer.ExternalCount = 1 && LodaPlayer.CustomCount = 0 && LodaPlayer.PluginCount = 0) {
			iePopUp := ComObjCreate("InternetExplorer.Application")
			iePopUp.Visible := true, iePopUp.MenuBar := false, iePopUp.StatusBar := false, iePopUp.ToolBar := false
			iePopUp.Width := A_ScreenWidth * 0.7, iePopUp.Height := A_ScreenHeight * 0.7
			iePopUp.Navigate(LodaPlayer.BaseAddr . Go, 0x20)  ; navBrowserBar = 0x20,
			ObjRelease(iePopUp), VarSetCapacity(iePopUp, 0)
			FreeMemory()
			return
		}
		
		if (LodaPlayer.PluginCount = 1 && LodaPlayer.ExternalCount = 0 && LodaPlayer.InternalCount = 1) {
			Critical
			InputURL := "http://" . DefaultServer "/" . Go . "/video/playlist.m3u8"
			ControlFocus,, ahk_id %LodaPotChild%
			ControlSend,, {Ctrl Down}u{Ctrl Up}, ahk_id %LodaPotChild%
			WinWait, ahk_class #32770, 주소 열기
			Teleport := WinExist("ahk_class #32770", "주소 열기")
			WinSet, Transparent, 0, % "ahk_id " Teleport 
			Loop
			{
				ControlClick, Button2, ahk_id %Teleport%,,,, NA ; 목록 삭제
				Sleep,30
				ControlSetText, Edit1, %InputURL%, ahk_id %Teleport% ; 주소 열기
				Sleep, 30
				ControlGetText, forVerify, Edit1, ahk_id %Teleport%  ;주소 열기
				Sleep, 30
			} until forVerify = InputURL
			
			Sleep, 0
			ControlClick, Button7, ahk_id %Teleport%,,,, NA   ; 확인(&O)
			Critical, Off
			
			if LodaPlayer.CustomCount = 0
				Stream.Navigate("https://livehouse.in/en/channel/" . Go . "/chatroom")
			if LodaPlayer.CustomCount = 1
			{
				Critical
				ClipHistory := Clipboard
				Clipboard := "https://livehouse.in/en/channel/" . Go . "/chatroom"
				ControlFocus,, ahk_id %LodaChromeChild%
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F6}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Ctrl Down}v{Ctrl Up} , ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {Enter}, ahk_id %LodaChromeChild%
				Sleep, 30
				ControlSend,, {F11}, ahk_id %LodaChromeChild%
				Sleep, 30
				Critical, Off
				Clipboard := ClipHistory
				RedrawWindow()
			}
			
			Loop
				WinGetTitle, LatterT, ahk_id %LodaPotChild%
			until LatterT = "다음 팟플레이어" ; playlist.m3u8 - 다음 팟플레이어
			Sleep, 100
			Loop
				WinGetTitle, LatterT, ahk_id %LodaPotChild%
			until LatterT = "playlist.m3u8 - 다음 팟플레이어" ; playlist.m3u8 - 다음 팟플레이어
			Sleep, 100
			
			VarSetCapacity(LatterT, 0), VarSetCapacity(forVerify, 0), VarSetCapacity(Teleport, 0), VarSetCapacity(InputURL, 0)
			RedrawWindow(), FreeMemory()
		}
		return
	}
	
	DeleteMenu(Desire)
	{
		global
		Loop, % %Desire%Count
			Menu, % Desire . "Menu", Delete, % %Desire%[A_Index]["PD"] "`t" %Desire%[A_Index]["Channel"]
	}
	
	UpdateMenu(Category)
	{
		global
		Loop, % %Category%Count {
			Menu, % Category . "Menu", Add, % %Category%[A_Index]["PD"] "`t" %Category%[A_Index]["Channel"], LodaPlayer.PDMenu
			if InStr(Online%Category%1, %Category%[A_Index]["PD"])
				Menu, % Category . "Menu", Icon, % %Category%[A_Index]["PD"] "`t" %Category%[A_Index]["Channel"], %A_Temp%\on.png,,0
			else
				Menu, % Category . "Menu", Icon, % %Category%[A_Index]["PD"] "`t" %Category%[A_Index]["Channel"], %A_Temp%\off.png,,0
			Sleep, 0
		}
	}
	
	SetChildWindow(Win, Des)
	{
		WinSet, Style, -0x80000000, % "ahk_id " Win ;remove popup
		WinSet, Style, +0x40000000, % "ahk_id " Win ;add child
		WinSet, Redraw,, % "ahk_id " Win
		DllCall( "SetParent", "Ptr", Win, "Ptr", Des)
	}
}

class ServerInfo extends LodaPlayer {

	OnAirCheck()
	{
		global
		poo := ComObjCreate("InternetExplorer.Application")
		poo.Visible := true, poo.Navigate("http://poooo.ml/")
		
		Gui, Menu
		this.DeleteMenu("Film"), Film:= "", FilmCount := ""
		this.DeleteMenu("Ani"), Ani := "", AniCount := ""
		this.DeleteMenu("Show"), Show := "", ShowCount := ""
		this.DeleteMenu("Etc"), Etc := "", EtcCount := ""
		/*
		Film := this.getList("FilmList.txt"), FilmCount := NumGet(&Film, 4*A_PtrSize)
		Ani := this.getList("AniList.txt"), AniCount := NumGet(&Ani, 4*A_PtrSize)
		Show := this.getList("ShowList.txt"), ShowCount := NumGet(&Show, 4*A_PtrSize)
		Etc := this.getList("EtcList.txt"), EtcCount := NumGet(&Etc, 4*A_PtrSize)
		*/
		this.getFilmList("FilmList.txt"), this.getAniList("AniList.txt"), this.getShowList("ShowList.txt"), this.getEtcList("EtcList.txt")
		while !(IsObject(Film) && IsObject(Ani) && IsObject(Show) && IsObject(Etc))
			continue
		while !(poo.readyState=4 || poo.document.readyState="complete" || !poo.busy) 
			continue
		newcon := poo.document.getElementByID("main-content").InnerText, this.ParsePD()
		
		try {
			this.UpdateMenu("Film"), this.UpdateMenu("Ani"), this.UpdateMenu("Show"), this.UpdateMenu("Etc")
		}
		Gui, Menu, MyMenuBar
		WinSet, Redraw,, ahk_id %hMainWindow%
		poo.Quit(), VarSetCapacity(poo, 0), VarSetCapacity(OnlineFilm1, 0), VarSetCapacity(OnlineAni1, 0), VarSetCapacity(OnlineShow1, 0), VarSetCapacity(OnlineEtc1, 0), FreeMemory()
	}
	
	/* until 1.2.3,  async false
	getList(Which)
	{
		;global
		From := "https://raw.githubusercontent.com/Visionary1/LodaPlayer/master/PD/"
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", From . Which, True), whr.Send(), whr.WaitForResponse()
		;json := "[" RegExReplace(whr.ResponseText, "\R+", ",") "]"
		return JSON_ToObj(whr.ResponseText)
	}
	*/ 
	
	getFilmList(Which) {
		global
		reqFilm := ComObjCreate("Msxml2.XMLHTTP"), reqFilm.Open("GET", From . Which, true)
		reqFilm.onreadystatechange := ObjBindMethod(ServerInfo, "FilmReady"), reqFilm.Send()
	}

	getAniList(Which) {
		global
		reqAni := ComObjCreate("Msxml2.XMLHTTP"), reqAni.Open("GET", From . Which, true)
		reqAni.onreadystatechange := ObjBindMethod(ServerInfo, "AniReady"), reqAni.Send()
	}

	getShowList(Which) {
		global
		reqShow := ComObjCreate("Msxml2.XMLHTTP"), reqShow.Open("GET", From . Which, true)
		reqShow.onreadystatechange := ObjBindMethod(ServerInfo, "ShowReady"), reqShow.Send()
	}

	getEtcList(Which) {
		global
		reqEtc := ComObjCreate("Msxml2.XMLHTTP"), reqEtc.Open("GET", From . Which, true)
		reqEtc.onreadystatechange := ObjBindMethod(ServerInfo, "EtcReady"), reqEtc.Send()
	}

	FilmReady() {
		global
		if (reqFilm.readyState != 4)  ; Not done yet.
			return
		if (reqFilm.status == 200 || reqFilm.status == 304) ; OK.
		{
			Film := JSON_ToObj(reqFilm.ResponseText), VarSetCapacity(reqFilm, 0), FilmCount := NumGet(&Film, 4*A_PtrSize)
		}
	}

	AniReady() {
		global
		if (reqAni.readyState != 4)  ; Not done yet.
			return
		if (reqAni.status == 200 || reqAni.status == 304) ; OK.
		{
			Ani := JSON_ToObj(reqAni.ResponseText), VarSetCapacity(reqAni, 0), AniCount := NumGet(&Ani, 4*A_PtrSize)
		}
	}

	ShowReady() {
		global
		if (reqShow.readyState != 4)  ; Not done yet.
			return
		if (reqShow.status == 200 || reqShow.status == 304) ; OK.
		{
			Show := JSON_ToObj(reqShow.ResponseText), VarSetCapacity(reqShow, 0), ShowCount := NumGet(&Show, 4*A_PtrSize)
		}
	}

	EtcReady() {
		global
		if (reqEtc.readyState != 4)  ; Not done yet.
			return
		if (reqEtc.status == 200 || reqEtc.status == 304) ; OK.
		{
			Etc := JSON_ToObj(reqEtc.ResponseText), VarSetCapacity(reqEtc, 0), EtcCount := NumGet(&Etc, 4*A_PtrSize)
		}
	}
	
	ParsePD()
	{
		global
		newcon := RegExReplace(newcon, "\R+\R", "`r`n"), newcon := RegExReplace(newcon, "\s+", " ")
		RegExMatch(newcon,"영화(.*?)오프라인",OnlineFilm), RegExMatch(newcon,"애니(.*?)오프라인",OnlineAni)
		RegExMatch(newcon,"예능(.*?)오프라인",OnlineShow), RegExMatch(newcon,"기타(.*?)오프라인",OnlineEtc)
		VarSetCapacity(newcon, 0), VarSetCapacity(OnlineFilm, 0), VarSetCapacity(OnlineAni, 0), VarSetCapacity(OnlineShow, 0), VarSetCapacity(OnlineEtc, 0)
	}
}

class ViewControl extends LodaPlayer {

	static hVisible := 1, MenuNotify := 1
	
	ToggleOnlyMenu()
	{
		global hMainWindow
		static aMenu := ""
		
		WinGet, ckin, Transparent, ahk_class Shell_TrayWnd
		if ckin < 120
			return
		
		KeyWait Ctrl
		KeyWait Enter
		
		if aMenu =
			aMenu := DllCall("GetMenu", "uint", hMainWindow)
		
		if this.MenuNotify = 0
		{
			DllCall("SetMenu", "uint", hMainWindow, "uint", aMenu) ;Menu Show
			return this.MenuNotify := 1
		}
		if this.MenuNotify = 1 ;처음
		{
			DllCall("SetMenu", "uint", hMainWindow, "uint", 0) ;Menu Hide
			return this.MenuNotify := 0
		}
	}
	
	ToggleAll()
	{
		static hMenu := ""
		global
		
		if this.PluginCount = 0
			return
		
		KeyWait Alt
		KeyWait Enter
		
		if hMenu =
			hMenu := DllCall("GetMenu", "uint", hMainWindow)
		
		if (this.hVisible = 0)
		{
			DllCall("SetMenu", "uint", hMainWindow, "uint", hMenu)
			this.MenuNotify := 1
			if (this.PluginCount = 1)
			{
				LodaPlayer.PotChatBAN := 0
				if this.CustomCount = 0
					WinShow, ahk_id %hStream%
				if this.CustomCount = 1
					WinShow, ahk_id %LodaChromeChild%
			}
			WinSet, Transparent, 255, ahk_class Shell_TrayWnd
			WinSet, Style, +0xC00000, ahk_id %hMainWindow%
			WinSet, Redraw,, ahk_id %hMainWindow%
			WinRestore, ahk_id %hMainWindow%
			BlockInput(1)
			ControlFocus,, ahk_id %LodaPotChild%
			SendInput, {Enter}
			BlockInput(0), RedrawWindow(), DaumPotSet("Fix"), this.hVisible := 1
			return
		}
		
		if (this.hVisible = 1)
		{
			DllCall("SetMenu", "uint", hMainWindow, "uint", 0)
			this.MenuNotify := 0
			if chatBAN = 0
			{
				ChatBAN := 1
				WinHide, ahk_id %hGaGa%
				Menu, GaGaMenu, NoIcon, 채팅하기
				Menu, GaGaMenu, Icon, 채팅하기, %A_Temp%\off.png,,0
			}
			if (this.PluginCount = 1)
			{
				LodaPlayer.PotChatBAN := 1
				if this.CustomCount = 0 
					WinHide, ahk_id %hStream%
				if this.CustomCount = 1
					WinHide, ahk_id %LodaChromeChild%
			}
			WinSet, Transparent, 70, ahk_class Shell_TrayWnd
			WinMaximize, ahk_id %hMainWindow%
			WinSet, Style, -0xC00000, ahk_id %hMainWindow%
			WinSet, Redraw,, ahk_id %hMainWindow%
			BlockInput(1)
			ControlFocus,, ahk_id %LodaPotChild%
			SendInput, {Enter}
			BlockInput(0), this.hVisible := 0
			return
		}
	}
}

BrowserEmulation(Level) {
	static key := "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", ieversion := ""
	
	if ieversion = 
	{
		try {
			RegRead ver, HKLM, SOFTWARE\Microsoft\Internet Explorer, svcVersion
			ieversion :=  SubStr(ver, 1, InStr(ver, ".")-1)
		}
		catch e {
			MsgBox, 262160, Exception, 익스플로러 11을 설치하세요
			ExitApp
		}
	}
	if Level = 1
		RegWrite, REG_DWORD, HKCU, %key%, LodaPlayer.exe, % ieversion * 1000
	else if Level = 0
		RegDelete HKCU, %key%, LodaPlayer.exe
}

ClearMemory() {
    for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
    {
        hProcess := DllCall("kernel32.dll\OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "UInt", objItem.ProcessID)
        , DllCall("kernel32.dll\SetProcessWorkingSetSize", "Ptr", hProcess, "UPtr", -1, "UPtr", -1)
        , DllCall("psapi.dll\EmptyWorkingSet", "Ptr", hProcess)
        , DllCall("kernel32.dll\CloseHandle", "Ptr", hProcess)
    }
    return
}

FreeMemory() {
    return DllCall("psapi.dll\EmptyWorkingSet", "Ptr", -1)
}

DaumPotSet(Set) {
	global LodaPotChild
	
	if Set = 1
	{
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, UseStreamTimeShift, 1
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, StreamTimeShiftTime, 5
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, UseStreamTimeShift, 1
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, StreamTimeShiftTime, 5
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, PlaylistAttachToMain2, 0
		RegWrite, REG_DWORD, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, PlaylistAttachToMain2, 0
		RegWrite, REG_SZ, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, LastSkinName, WindowFrame.dsf
		RegWrite, REG_SZ, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, LastSkinName, WindowFrame.dsf
	}
	if Set = 0
	{
		RegDelete, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, PlaylistAttachToMain2
		RegDelete, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, PlaylistAttachToMain2
		RegDelete, HKCU, SOFTWARE\DAUM\PotPlayerMini\Settings, LastSkinName
		RegDelete, HKCU, SOFTWARE\DAUM\PotPlayerMini64\Settings, LastSkinName
	}
	if Set = Fix
	{
		WinSet, Style, -0xC00000, % "ahk_id " LodaPotChild ;-Border
		WinSet, Style, -0x40000, % "ahk_id " LodaPotChild ;-Caption
		WinSet, Style, -0x800000, % "ahk_id " LodaPotChild ;-Sizebox
		WinSet, Redraw,, % "ahk_id " LodaPotChild
	}
}

RedrawWindow() {
	global hMainWindow
	
	WinGetPos, MoveX, MoveY, MoveW, MoveH, ahk_id %hMainWindow%
	if (MoveW > A_ScreenWidth - 15)
	{
		WinRestore, ahk_id %hMainWindow%
		Sleep, 50
		WinMaximize, ahk_id %hMainWindow%
	}
	else
	{
		WinMove, ahk_id %hMainWindow%,, % MoveX, % MoveY, % MoveW - 1, % MoveH - 1
		Sleep, 50
		WinMove, ahk_id %hMainWindow%,, % MoveX, % MoveY, % MoveW, % MoveH
	}
}

BlockInput(BlockIt := 0) {
    if !(DllCall("user32.dll\BlockInput", "UInt", BlockIt))
        return DllCall("kernel32.dll\GetLastError")
    return 1
}

ClearCookies() {
	static CmdLine := 0x0002 | 0x0100 ; CLEAR_COOKIES | CLEAR_SHOW_NO_GUI
	static INTERNET_OPTION_END_BROWSER_SESSION := 42
	DllCall("inetcpl.cpl\ClearMyTracksByProcessW", "UInt", 0, "UInt", 0, "Str", CmdLine, "Int", 0)
	DllCall("wininet\InternetSetOption", "Int", 0, "Int", INTERNET_OPTION_END_BROWSER_SESSION, "Int", 0, "Int", 0)
}

CMsgBox( title, text, buttons, icon="", owner=0 ) {
  Global _CMsg_Result
  
  GuiID := 9      ; If you change, also change the subroutines below
  
  StringSplit Button, buttons, |
  
  If( owner <> 0 ) {
    Gui %owner%:+Disabled
    Gui %GuiID%:+Owner%owner%
  }

  Gui %GuiID%: new, -SysMenu +AlwaysOnTop
  
  MyIcon := ( icon = "I" ) or ( icon = "" ) ? 222 : icon = "Q" ? 24 : icon = "E" ? 110 : icon
  
  Gui %GuiID%:Add, Picture, Icon%MyIcon% , Shell32.dll
  Gui %GuiID%:Add, Text, x+12 yp w180 r8 section , %text%
  
  Loop %Button0% 
    Gui %GuiID%:Add, Button, % ( A_Index=1 ? "x+12 ys " : "xp y+3 " ) . ( InStr( Button%A_Index%, "*" ) ? "Default " : " " ) . "w100 gCMsgButton", % RegExReplace( Button%A_Index%, "\*" )

  Gui %GuiID%:Show,,%title%
  
  Loop 
    If( _CMsg_Result )
      Break

  If( owner <> 0 )
    Gui %owner%:-Disabled
    
  Gui %GuiID%:Destroy
  Result := _CMsg_Result
  _CMsg_Result := ""
  Return Result
}

;9GuiEscape:
9GuiClose:
  _CMsg_Result := "Close"
Return

CMsgButton:
  StringReplace _CMsg_Result, A_GuiControl, &,, All
Return

class_EasyIni(sFile="", sLoadFromStr="")
{
	return new EasyIni(sFile, sLoadFromStr)
}

class EasyIni
{
	__New(sFile="", sLoadFromStr="")
	{
		this := this.CreateIniObj("EasyIni_ReservedFor_m_sFile", sFile
			, "EasyIni_ReservedFor_TopComments", Object())

		if (sFile == A_Blank && sLoadFromStr == A_Blank)
			return this
		
		if (SubStr(sFile, StrLen(sFile)-3, 4) != ".ini")
			this.EasyIni_ReservedFor_m_sFile := sFile := (sFile . ".ini")

		sIni := sLoadFromStr
		if (sIni == A_Blank)
			FileRead, sIni, %sFile%

		Loop, Parse, sIni, `n, `r
		{
			sTrimmedLine := Trim(A_LoopField)
			if (SubStr(sTrimmedLine, 1, 1) == ";" || sTrimmedLine == A_Blank)
			{
				LoopField := A_LoopField == A_Blank ? Chr(14) : A_LoopField

				if (sCurSec == A_Blank)
					this.EasyIni_ReservedFor_TopComments.Insert(A_Index, LoopField)
				else
				{
					if (sPrevKeyForThisSec == A_Blank)
						sPrevKeyForThisSec := "SectionComment"

					if (IsObject(this[sCurSec].EasyIni_ReservedFor_Comments))
					{
						if (this[sCurSec].EasyIni_ReservedFor_Comments.HasKey(sPrevKeyForThisSec))
							this[sCurSec].EasyIni_ReservedFor_Comments[sPrevKeyForThisSec] .= "`n" LoopField
						else this[sCurSec].EasyIni_ReservedFor_Comments.Insert(sPrevKeyForThisSec, LoopField)
					}
					else
					{
						if (IsObject(this[sCurSec]))
							this[sCurSec].EasyIni_ReservedFor_Comments := {(sPrevKeyForThisSec):LoopField}
						else this[sCurSec, "EasyIni_ReservedFor_Comments"] := {(sPrevKeyForThisSec):LoopField}
					}
				}
				continue
			}
			
			if (SubStr(sTrimmedLine, 1, 1) = "[" && InStr(sTrimmedLine, "]"))
			{
				if (sCurSec != A_Blank && !this.HasKey(sCurSec))
					this[sCurSec] := EasyIni_CreateBaseObj()
				sCurSec := SubStr(sTrimmedLine, 2, InStr(sTrimmedLine, "]", false, 0) - 2)
				sPrevKeyForThisSec := ""
				continue
			}
			
			iPosOfEquals := InStr(sTrimmedLine, "=")
			if (iPosOfEquals)
			{
				sPrevKeyForThisSec := SubStr(sTrimmedLine, 1, iPosOfEquals - 1)
				val := SubStr(sTrimmedLine, iPosOfEquals + 1)
				StringReplace, val, val , `%A_ScriptDir`%, %A_ScriptDir%, All
				StringReplace, val, val , `%A_WorkingDir`%, %A_ScriptDir%, All
				this[sCurSec, sPrevKeyForThisSec] := val
			}
			else
			{
				sPrevKeyForThisSec := sTrimmedLine
				this[sCurSec, sPrevKeyForThisSec] := ""
			}
		}
		if (sCurSec != A_Blank && !this.HasKey(sCurSec))
			this[sCurSec] := EasyIni_CreateBaseObj()

		return this
	}

	CreateIniObj(parms*)
	{
		static base := {__Set: "EasyIni_Set", _NewEnum: "EasyIni_NewEnum", Remove: "EasyIni_Remove", Insert: "EasyIni_Insert", InsertBefore: "EasyIni_InsertBefore", AddSection: "EasyIni.AddSection", RenameSection: "EasyIni.RenameSection", DeleteSection: "EasyIni.DeleteSection", GetSections: "EasyIni.GetSections", FindSecs: "EasyIni.FindSecs", AddKey: "EasyIni.AddKey", RenameKey: "EasyIni.RenameKey", DeleteKey: "EasyIni.DeleteKey", GetKeys: "EasyIni.GetKeys", FindKeys: "EasyIni.FindKeys", GetVals: "EasyIni.GetVals", FindVals: "EasyIni.FindVals", HasVal: "EasyIni.HasVal", Copy: "EasyIni.Copy", Merge: "EasyIni.Merge", GetFileName: "EasyIni.GetFileName", GetOnlyIniFileName:"EasyIni.GetOnlyIniFileName", IsEmpty:"EasyIni.IsEmpty", Reload: "EasyIni.Reload", GetIsSaved: "EasyIni.GetIsSaved", Save: "EasyIni.Save", ToVar: "EasyIni.ToVar"}
		return Object("_keys", Object(), "base", base, parms*)
	}

	AddSection(sec, key="", val="", ByRef rsError="")
	{
		if (this.HasKey(sec))
		{
			rsError := "Error! Cannot add new section [" sec "], because it already exists."
			return false
		}

		if (key == A_Blank)
			this[sec] := EasyIni_CreateBaseObj()
		else this[sec, key] := val

		return true
	}

	RenameSection(sOldSec, sNewSec, ByRef rsError="")
	{
		if (!this.HasKey(sOldSec))
		{
			rsError := "Error! Could not rename section [" sOldSec "], because it does not exist."
			return false
		}

		aKeyValsCopy := this[sOldSec]
		this.DeleteSection(sOldSec)
		this[sNewSec] := aKeyValsCopy
		return true
	}

	DeleteSection(sec)
	{
		this.Remove(sec)
		return
	}

	GetSections(sDelim="`n", sSort="")
	{
		for sec in this
			secs .= (A_Index == 1 ? sec : sDelim sec)

		if (sSort)
			Sort, secs, D%sDelim% %sSort%

		return secs
	}

	FindSecs(sExp, iMaxSecs="")
	{
		aSecs := []
		for sec in this
		{
			if (RegExMatch(sec, sExp))
			{
				aSecs.Insert(sec)
				if (iMaxSecs&& aSecs.MaxIndex() == iMaxSecs)
					return aSecs
			}
		}
		return aSecs
	}

	AddKey(sec, key, val="", ByRef rsError="")
	{
		if (this.HasKey(sec))
		{
			if (this[sec].HasKey(key))
			{
				rsError := "Error! Could not add key, " key " because there is a key in the same section:`nSection: " sec "`nKey: " key
				return false
			}
		}
		else
		{
			rsError := "Error! Could not add key, " key " because Section, " sec " does not exist."
			return false
		}
		this[sec, key] := val
		return true
	}

	RenameKey(sec, OldKey, NewKey, ByRef rsError="")
	{
		if (!this[sec].HasKey(OldKey))
		{
			rsError := "Error! The specified key " OldKey " could not be modified because it does not exist."
			return false
		}

		ValCopy := this[sec][OldKey]
		this.DeleteKey(sec, OldKey)
		this.AddKey(sec, NewKey)
		this[sec][NewKey] := ValCopy
		return true
	}

	DeleteKey(sec, key)
	{
		this[sec].Remove(key)
		return
	}

	GetKeys(sec, sDelim="`n", sSort="")
	{
		for key in this[sec]
			keys .= A_Index == 1 ? key : sDelim key

		if (sSort)
			Sort, keys, D%sDelim% %sSort%

		return keys
	}

	FindKeys(sec, sExp, iMaxKeys="")
	{
		aKeys := []
		for key in this[sec]
		{
			if (RegExMatch(key, sExp))
			{
				aKeys.Insert(key)
				if (iMaxKeys && aKeys.MaxIndex() == iMaxKeys)
					return aKeys
			}
		}
		return aKeys
	}
	
	FindExactKeys(key, iMaxKeys="")
	{
		aKeys := {}
		for sec, aData in this
		{
			if (aData.HasKey(key))
			{
				aKeys.Insert(sec, key)
				if (iMaxKeys && aKeys.MaxIndex() == iMaxKeys)
					return aKeys
			}
		}
		return aKeys
	}

	GetVals(sec, sDelim="`n", sSort="")
	{
		for key, val in this[sec]
			vals .= A_Index == 1 ? val : sDelim val

		if (sSort)
			Sort, vals, D%sDelim% %sSort%

		return vals
	}

	FindVals(sec, sExp, iMaxVals="")
	{
		aVals := []
		for key, val in this[sec]
		{
			if (RegExMatch(val, sExp))
			{
				aVals.Insert(val)
				if (iMaxVals && aVals.MaxIndex() == iMaxVals)
					break
			}
		}
		return aVals
	}

	HasVal(sec, FindVal)
	{
		for k, val in this[sec]
			if (FindVal = val)
				return true
		return false
	}
	
	Copy(SourceIni, bCopyFileName = true)
	{
		; Get ini as string.
		if (IsObject(SourceIni))
			sIniString := SourceIni.ToVar()
		else FileRead, sIniString, %SourceIni%

		if (IsObject(this))
		{
			if (bCopyFileName)
				sOldFileName := this.GetFileName()
			this := A_Blank

			this := class_EasyIni(SourceIni.GetFileName(), sIniString)

			this.EasyIni_ReservedFor_m_sFile := sOldFileName
		}
		else
			return class_EasyIni(bCopyFileName ? SourceIni.GetFileName() : "", sIniString)

		return this
	}
	
	Merge(vOtherIni, bRemoveNonMatching = false, bOverwriteMatching = false, vExceptionsIni = "")
	{
		for sec, aKeysAndVals in vOtherIni
		{
			if (!this.HasKey(sec))
				if (bRemoveNonMatching)
					this.DeleteSection(sec)
				else this.AddSection(sec)
					
			for key, val in aKeysAndVals
			{
				bMakeException := vExceptionsIni[sec].HasKey(key)

				if (this[sec].HasKey(key))
				{
					if (bOverwriteMatching && !bMakeException)
						this[sec, key] := val
				}
				else
				{
					if (bRemoveNonMatching && !bMakeException)
						this.DeleteKey(sec, key)
					else if (!bRemoveNonMatching)
						this.AddKey(sec, key, val)
				}
			}
		}
		return
	}
	
	GetFileName()
	{
		return this.EasyIni_ReservedFor_m_sFile
	}
	
	GetOnlyIniFileName()
	{
		return SubStr(this.EasyIni_ReservedFor_m_sFile, InStr(this.EasyIni_ReservedFor_m_sFile,"\", false, -1)+1)
	}
	
	IsEmpty()
	{
		return (this.GetSections() == A_Blank
			&& !this.EasyIni_ReservedFor_TopComments.HasKey(1))
	}
	
	Reload()
	{
		if (FileExist(this.GetFileName()))
			this := class_EasyIni(this.GetFileName())
		return this
	}
	
	Save(sSaveAs="", bWarnIfExist=false)
	{
		if (sSaveAs == A_Blank)
			sFile := this.GetFileName()
		else
		{
			sFile := sSaveAs
			if (SubStr(sFile, StrLen(sFile)-3, 4) != ".ini")
				sFile .= ".ini"

			if (bWarnIfExist && FileExist(sFile))
			{
				MsgBox, 4,, The file "%sFile%" already exists.`n`nAre you sure that you want to overwrite it?
				IfMsgBox, No
					return false
			}
		}
		FileDelete, %sFile%

		bIsFirstLine := true
		for k, v in this.EasyIni_ReservedFor_TopComments
		{
			FileAppend, % (A_Index == 1 ? "" : "`n") (v == Chr(14) ? "" : v), %sFile%
			bIsFirstLine := false
		}

		for section, aKeysAndVals in this
		{
			FileAppend, % (bIsFirstLine ? "[" : "`n[") section "]", %sFile%
			bIsFirstLine := false

			bEmptySection := true
			for key, val in aKeysAndVals
			{
				bEmptySection := false
				FileAppend, `n%key%=%val%, %sFile%
				sComments := this[section].EasyIni_ReservedFor_Comments[key]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), %sFile%
			}
			if (bEmptySection)
			{
				sComments := this[section].EasyIni_ReservedFor_Comments["SectionComment"]
				Loop, Parse, sComments, `n
					FileAppend, % "`n" (A_LoopField == Chr(14) ? "" : A_LoopField), %sFile%
			}
		}
		return true
	}

	ToVar()
	{
		sTmpFile := "$$$EasyIni_Temp.ini"
		this.Save(sTmpFile, !A_IsCompiled)
		FileRead, sIniAsVar, %sTmpFile%
		FileDelete, %sTmpFile%
		return sIniAsVar
	}
}

EasyIni_CreateBaseObj(parms*)
{
	static base := {__Set: "EasyIni_Set", _NewEnum: "EasyIni_NewEnum", Remove: "EasyIni_Remove", Insert: "EasyIni_Insert", InsertBefore: "EasyIni_InsertBefore"}
	return Object("_keys", Object(), "base", base, parms*)
}

EasyIni_Set(obj, parms*)
{
	if parms.maxindex() > 2
		ObjInsert(obj, parms[1], EasyIni_CreateBaseObj())
	if (SubStr(parms[1], 1, 20) <> "EasyIni_ReservedFor_")
		ObjInsert(obj._keys, parms[1])
}

EasyIni_NewEnum(obj)
{
	static base := Object("Next", "EasyIni_EnumNext")
	return Object("obj", obj, "enum", obj._keys._NewEnum(), "base", base)
}

EasyIni_EnumNext(e, ByRef k, ByRef v="")
{
	if r := e.enum.Next(i,k)
		v := e.obj[k]
	return r
}

EasyIni_Remove(obj, parms*)
{
	r := ObjRemove(obj, parms*)
	Removed := []
	for k, v in obj._keys
		if not ObjHasKey(obj, v)
			Removed.Insert(k)
	for k, v in Removed
		ObjRemove(obj._keys, v, "")
	return r
}

EasyIni_Insert(obj, parms*)
{
	r := ObjInsert(obj, parms*)
	enum := ObjNewEnum(obj)
	while enum[k] {
		for i, kv in obj._keys
			if (k = "_keys" || k = kv || SubStr(k, 1, 20) = "EasyIni_ReservedFor_" || SubStr(kv, 1, 20) = "EasyIni_ReservedFor_")   ; If found...
				continue 2
		ObjInsert(obj._keys, k)
	}
	return r
}

EasyIni_InsertBefore(obj, key, parms*)
{
	OldKeys := obj._keys
	obj._keys := []
	for idx, k in OldKeys {
		if (k = key)
			break
		obj._keys.Insert(k)
	}

	r := ObjInsert(obj, parms*)
	enum := ObjNewEnum(obj)
	while enum[k] {
		for i, kv in OldKeys
			if (k = "_keys" || k = kv)
				continue 2
		ObjInsert(obj._keys, k)
	}

	for i, k in OldKeys {
		if (i < idx)
			continue
		obj._keys.Insert(k)
	}

	return r
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