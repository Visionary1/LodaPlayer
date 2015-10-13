PD_Get(_What)
{
	Static Size = 338, Name = "PD.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_PD(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAbFBMVEVMaXEymMwzmMtDiLs0msoAzv85mcUymswxl8ozmcszmMwymssxl8symcwymMwvn88ymMszl8sxmMs0mcoxl8oymMsymcwymMoymcwxmMs1mskzl8szmcwymcw0lcozmcwymcwymMsxmcwzmcx2RwmDAAAAI3RSTlMANuUDFwENTLRInyvqB3AQXjuNWKXRa77uwSZZHnYdPIiaziuIdWgAAABySURBVHhe7Y9HDoAwEAMdEgKh9975/x9RxA2BX8AcfNmRtcaDHy3A8c5KcaHfukQywUfY1isV4JZOoJgA6CJqJBOAsD8EFeBm0Z4yAXrv3jqUsUkeNbNNOzXHKzKmI+4G727/ajAmy/GNGJcJDDWQ488FVwYEhGDuf2UAAAAASUVORK5CYII="
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 464 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 338, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 338, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 338, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
