refresh_Get(_What)
{
	Static Size = 479, Name = "refresh.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_refresh(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAAyVBMVEUAAAAA//8Af/9VqqoqqtQ/n78zmcwuotAqlNQzmcw4m8YzmcwxnM02msgxnM0ymMs0lsozmcw3lcc1mskwl841msk0lso0mcoymMsymsw0mcozl8symMsxmM00mcozl8sxmM0xmM00mcozl8szmcw2mckym840mMoymMs0l8oxl8szmcwzmc0wlssxl8ozmMsxl8ozmMs0l8ozmMsymcwymMwzmMoxl8ozmcsxl8oyl8wxl8ozmMozmM0xl8oxmcwymMsxmcszl8oXdDWsAAAAQ3RSTlMAAQIDBggKCwwPEhQaHB8jJygpKy8wMTU3ODpAQUNERUhNTk9QVV9mbnR2eHt9h4uMlZapsLGztLe5wMPHx8jJ1tjvYa6ENgAAAIJJREFUGBnNwAUSgkAAQNG/Nlhgd3e3qIhx/0PpCKM74AF4+IRSLKl4ZXen1dI45nHpnHWAtJFB1phdotimGpL2Y1vBFh8iqd6bAsc4yH+64Ef0+IoEkUxwhEbPOpK+hq28ubaQxOZhPpK3QQFZyqwJCHStHC6JtbU/mAsVL6Eq+MQLWoEJm/ifZUcAAAAASUVORK5CYII="
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 657 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 479, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 479, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 479, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
