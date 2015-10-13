help_Get(_What)
{
	Static Size = 405, Name = "help.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_help(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAh1BMVEVMaXEymMwvm880lcoymMszmMsymswxmc48icU0ncsymMwymcszmcs2mskxmcwyl8wymsw0mcoxmMwzmMszmcsvl88xl8symcwzmcsymcsymc0xmMs2mskxmMszmcszmcsymsw0mcoyl8wzmcswmMsymMwymM00lsoymswxl8oxmcwymMszmctMRzCJAAAALHRSTlMAVhUJ7l4pEQMGibK9Hei7TElHi/IgtZercoWjDpx2bFs63tB9f2YxxeH2aaH5xoEAAACRSURBVBgZ7cCFDYNAAAXQD6docZe6sv98JaRpkLsNeNipmFEkoEdyenCT2IKOUzSAmdXQCC4SI3I+Qa3tMbnZUCsMTO4t1OwKk7yDGvc9jDj1oNG/jEYwn0FDfJ7vYUhcRqAiO1obXAjOMt/AluW4KX4eZYmN2JH4I9cQK4KamPEqrIQHzEmbYCkNsHC0sJv7AqFlBpfbhaoZAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 555 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 405, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 405, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 405, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
