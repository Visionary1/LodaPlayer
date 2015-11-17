on_Get(_What)
{
	Static Size = 537, Name = "on.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_on(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAAzFBMVEUAAABEREBEREBEREBEREBEREBEREBEREBEREAppt4oq+Epq+IpqeEoquEiqt0/UU0pquAnqOEwjLi58/677v687f666vuu2eis1uRoyOwupNdDX2u98P697P1It+S77v1YwOu97v1Zwuu/7/+97f1JuOmu4e6t1uWr1eOt2Oe66vu87f5ryO8prOEAqv8rodInq+AmqeAvlMEpqd8oq+InquEpqeEuoue97v8pquEqptopq+K87f635fW25PRFuOcrpdi67P4qq+JIuehHbhlGAAAAOHRSTlMAAQQFCQoCDQ9ApMy/eQ8Oh+AxFl9oaXBxndgRI+xki8SJwiDpXhRjbWxlZJbRA4TbIUCbw7VvC3VLU2gAAADESURBVHheldKHDoMgEAZgwYHd09q9997F1fn+71RBrKYYm15icvkuAn9A+FEAihAEXeCSLIFwx0pBKlKCLtYB+aIcklV5VyRREKAc8kQylc5kFSS7f4jSx3N5i1ShqJKTQVAqa5pW0at6jbph1ht072YLY2w7V8e+eX4323SNju+PJ3OjSwc95pgMqFt9OhgMPcf4xdwaecnHk+lsvnBryXy1/k6+ob7d8cn3h+PpfOGTs85PzjtLzjsiBv67q+g7j30jb3wyIBxHh7MdAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 736 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 537, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 537, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 537, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
