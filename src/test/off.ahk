off_Get(_What)
{
	Static Size = 798, Name = "off.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_off(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAABaFBMVEUAAABEREBEREBEREBEREBEREBEREBEREBEREDNzczi4uLr6+vw8O/u7u3v7+/g4N/i4uLx8fH+/v7S0tHe3t7Ly8vX19br6+v29vbj4+LPz87b29rv7+/r6+vQ0M/Q0M/e3t3////j4+Ph4eHW1tX29vbQ0M7MzMz29vbv7+/i4uHq6uro6Ojr6+jr6+vv7+/19fXQ0NDPz8/09PT////p6eno6OhmZmP19fXV1dXb29rb29vi4uLV1dXf397b29rz8/Lt7ezZ2dja2trr6+vNzcz+/v719fXx8fHv7+/i4uLg4ODx8fHy8vLz8/PBwcD///+7u7nAwL/j4+P+/v7R0dG6urj5+fn19fX9/f3ExMP39/fe3t7CwsHT09O/v77Jycfd3dzV1dT09PTy8vHGxsXU1NTk5OPa2tn4+PjIyMfZ2dju7u3h4eHKysnX19b6+vrHx8fY2Nfp6ejFxcTz8/PQ0M/JyciierGPAAAAT3RSTlMAAQQFCQoCDQ86iqCgoaWmpIUuR8jy78M7cunmalDr6VADz88DWfv6Vqalt7a2taNR+fdOAsvJBUHn5URm5OFmL7zp57o2HWqTmZ2emGodmxbwnwAAARZJREFUeF6F0tVuwzAYBeDfTgqjtmNmZmbmtstmB8owZubXn604cW+iHcnS0WfJN8fwTxBWMJJNuupTkduk+wPBgF+2Ei8rr6jkqRoJR6pruCF+auvqE683D4QYelI3vhoamwBh5s0tFynK8vTCnbC0tqkKQHuHaVEe6/vMdmJ0dmHo7jkXnr68urZdT/b2Qf9AxvG0dStcHxyC4Tvp9F64QUIwakqnNCucjMG4KZ1dCCcTEHos8ZzjZBKmpjOu02fHZ2Zhbj7veupUOFlYBFhazgt/e3d8ZVUBwGvrHznG1icRXtjY9GEARd3a3kkUf7L2+4Xf3b39IN+E73VwGI3Fj+IxTdOixydsE2aAvLbycK/Nvf/IH7UPZUvJTKpnAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 1094 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 798, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 798, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 798, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
