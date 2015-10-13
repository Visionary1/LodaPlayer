pooq_Get(_What)
{
	Static Size = 427, Name = "pooq.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_pooq(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAkFBMVEVMaXEzmcwxm80ymcwymcwym80ymMwzl8syl8wxms0zmMsymMsymMszmMsxl8sxl8symswtf9Uyl8wxl8oymMsymcwxl8wxmMsymMsymcw0mMozmcs1ockzmMsymswymMwxmMsxm80xl80zmswymcwymMsvoM8zl8symMwxmcw0lsoxl8w2msgymcwzmcszmMpmzXnHAAAAMHRSTlMAZwyAQTM0QMAjWJyU88mDXQPV9W+s4+3OsDCoBndQxIgUIXqmRhs7jucn6ByNsuA6M5+2AAAAmklEQVQYGe3ANQKDMAAF0I80lCS4u9X1/rerLIHAws7DZh1i/BHTPKpn0ywNginL3v9kuq6dFF2n1wxTKYHAb5cKkoMLoUZjQKI5EJzSUiGhBUZyHzKSYkRhkKmBB4EpmLk/IPg5ZvYRL3jbOtqTD5XlYYYocZwMYciCxNZcLNj5iFyAhV2ARer7lfQAjZsIyzra44vUJTbrfQASuQhtoYUu6AAAAABJRU5ErkJggg=="
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 585 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 427, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 427, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 427, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
