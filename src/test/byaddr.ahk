byaddr_Get(_What)
{
	Static Size = 420, Name = "byaddr.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_byaddr(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAh1BMVEVMaXEzmMszmcwxmMsxl8oymMwymc4A//80jM4nk9cxl8symcsymMwxmM02mskymcsxmcwxmMwxmMwymcwzmMsymMsxm80ymMwxmM0ymcwymM0ymMwymMwymcwzmMowmM0xl8oymswymcwwl84tm9ExmMsymcwymMsxmM0ymMsymcwzl8symcu38YrpAAAALXRSTlMAY6G761QxAQMH4t2OPxRCw0m2soEtKXE+d2bVz6fvGuY8gyUOiqxpXDeST/YgUdhMAAAAn0lEQVQYGeXAxxGDMBBA0Q9IYkV2zjHg2H99nmHgttAAj9GRfDMPTvR67/bZ/HDMPLq1sTFQzKaCxicTGhKt0AQzWouzoAgDOukSxXRCp7qgCLe04uSG4hXRskdB4VNLw+/TUFA48xTAVYd7VHsUyyoJP9EvKfD1A028CFbfe7Y7Ie5Br3iT3pD8Sr/t2SH5lX7WrC+2YEBpTMkgVzIyf1R5B9/PftinAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 576 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 420, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 420, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 420, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
