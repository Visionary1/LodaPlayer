on_Get(_What)
{
	Static Size = 841, Name = "on.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_on(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAABm1BMVEUAAABEREBEREBEREBEREBEREBEREBEREBEREBEREDNzcjW4sne7s7f8NDd7s7T4sTR4MPT4sbj8dj+/vnL0sDK3rmkzX6q14XZ68Xt9uXW48uu0Iyz25Lj79be69Sq0oat0IjV3sv////P5LrN4bnW1tXt+eWYzGei0XLt9uTe78ze78/S6r3T6L7T677T68He787v9eWcz2yi0HPt9OP////V6cHV6cJmZmPq9d6x1pC125XY28zX4sy11pi+35zR28Xt8+ja7ce02pG32pHa68jNzcP+/vbp9d/j8dfi79TX4snV4Mfk8dbz8/OIxk6Aw0KAwkJ9vEKLw1ijznqr14Oi03SUyGTX5sf19fX+/v7////z+ey03JChzXjx8/DQ6Lp+v0KNxFvv8u201pWAwkLI37L09PTw8uyAw0J+vEXw8u2q14B8u0KKw1a+4J+OyVe94J2Aw0OBxET4+/So1n7N57T3+/KOyle13JGg0nPx8u7K5rCBwkONxFvP4739/v3s9uKs2ISRy1uCxEWJx0+f0nGl1Hmh03O+RTXqAAAAT3RSTlMAAQQFAQkKAg0POoqgoKGlpqSFLkfI8u/DO3Lp5mpQ6+lQA8/PA1n7+lampbe2trWjUfn3TgLLyQVB5+VEZuThZi+86ee6Nh1qk5mdnpgdCyO1KAAAAQ5JREFUKFOF0j1LQ0EQheHzzp1cC1G0EAwRwRQWYhdBgqIigv9Z1EQEbewsxcIiRFBQIgiRa8Zib76I4jZ7eBZ2Z5iV/liUG0TEZEoHDhHFVEKS5iCiP51c0hwG5OkeoC8JJF+CJhr5FXR9gKiyW76bAwhaPA/QOo3SF/gCSaq0eaLOwXvyZT6TR8y3ccfL+v1j6Is45scvyVcrI+/1Tsysm7zmbyOHzMxK79iEy8y+68kjq45djuXt5PFoY1+7dHNfodaJkKw6dJk7atLopA63eE2+0eIW2R6H96mCbXiQNrngpkCZ7cMRd1DrxA5wDtdFgcwKnQIQkUlF5GdEUSBC+mVW5cxn/J+ZM/NHpB+xFoMVxid4lgAAAABJRU5ErkJggg=="
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 1153 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 841, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 841, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 841, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
