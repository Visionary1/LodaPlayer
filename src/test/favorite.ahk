favorite_Get(_What)
{
	Static Size = 444, Name = "favorite.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_favorite(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAllBMVEVMaXEzl8symMwxmMwymcwymMwyl8siyOQxmc0ymcsyncwymMwymMwypswxmMsxmMwymcwzmMsxnM4ymMwxmMwxmc0ymMwymcwzmcsymcwymcwymMs6nMQxmc0zmcwxmMsxmcwymcwymcwymcszmcozmMszmMoyl8wymsw1mskymMwzl8sxl8oxmM0wl84zmcs0mcozmctTxNMEAAAAMnRSTlMAHFLONFXZAUdNEHySBpbtr4YK3+MunWaNoyrRDVsUt+cgasHpd8fFPSZ1O+thJXZdgL2NUb8AAACjSURBVBgZ5cCFEYMwAEDRjya4191d9l+ux1UvBRbg0TrmwbNSoLjerYA/opP1kmluinAWJkvDRdXdpICe+0sXRD9BtZWU4mgCcDRQzTRKN4/SPEdlD/gxsFH1u/zQp6ikIfgK16jE0OHDjTT+SDvgzQ+pEHu8mKsJFbRTwVPPotJ5GFAa61QTsQ+wc0bUcDML5s6eWmZUpFLSYJw5CxotLrTSA9D0CETDPEdWAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 609 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 444, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 444, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 444, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
