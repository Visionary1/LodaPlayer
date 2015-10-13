setting_Get(_What)
{
	Static Size = 244, Name = "setting.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_setting(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAQlBMVEVMaXExms0ymcwymMwvms8zmcwymcwzmcsyl8wzl8symcwqlNUzm8symMw0lsszmcszmMszmMsxmM0ymcwxl8ozmczDKXxhAAAAFXRSTlMAImFnFVJzgMBATQYqfxOefIE0sMg0EwJgAAAATElEQVR4Xu3KORKAIBQE0fkbKiDu97+qWkpCTFkGvKiDRmVNPF7MwjLFHT+kY3cxU4G7y6GQnsEr5+F7gZJS0CFbUaDF20zWZxsqa076jwLtVcqKjQAAAABJRU5ErkJggg=="
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 335 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 244, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 244, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 244, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
