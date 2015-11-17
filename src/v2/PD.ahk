PD_Get(_What)
{
	Static Size = 294, Name = "PD.png", Extension = "png", Directory = "C:\Users\cs\Documents\GitHub\LodaPlayer\src"
	, Options = "Size,Name,Extension,Directory"
	;This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.
	If (InStr("," Options ",", "," _What ","))
		Return %_What%
}

Extract_PD(_Filename, _DumpData = 0)
{
	;This function "extracts" the file to the location+name you pass to it.
	Static HasData = 1, Out_Data, Ptr, ExtractedData
	Static 1 = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAAMhJREFUWIXt0rtqAkEUh/Hv082NPEUKiwQSCIFACIQQSJWXSqEICgoKIoK+pp1rs9sI3mZXbc6vm8uZ/8xwIIQQwm7ZJc/J1DnwUDG8pU6ARkrxvboAWonhT+oUuE2sB+Cu+InHI+teipdfVwkv3agz4PnA/W/qiPp6CICr4kWve/Z9qAOgWWd4KVPHwPuW9S+1R2LDHaqpDoHPjflftQN4yvBSQ+0D38X4T/1PCa9yW9U2sMrzfAl0gbzCeWmXAH7OHRpCCKFWa3i2FCIw9xypAAAAAElFTkSuQmCC"
	
	If (!HasData)
		Return -1
	
	If (!ExtractedData){
		ExtractedData := True
		, Ptr := A_IsUnicode ? "Ptr" : "UInt"
		, VarSetCapacity(TD, 403 * (A_IsUnicode ? 2 : 1))
		
		Loop, 1
			TD .= %A_Index%, %A_Index% := ""
		
		VarSetCapacity(Out_Data, Bytes := 294, 0)
		, DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &TD, "UInt", 0, "UInt", 1, Ptr, &Out_Data, A_IsUnicode ? "UIntP" : "UInt*", Bytes, "Int", 0, "Int", 0, "CDECL Int")
		, TD := ""
	}
	
	IfExist, %_Filename%
		FileDelete, %_Filename%
	
	h := DllCall("CreateFile", Ptr, &_Filename, "Uint", 0x40000000, "Uint", 0, "UInt", 0, "UInt", 4, "Uint", 0, "UInt", 0)
	, DllCall("WriteFile", Ptr, h, Ptr, &Out_Data, "UInt", 294, "UInt", 0, "UInt", 0)
	, DllCall("CloseHandle", Ptr, h)
	
	If (_DumpData)
		VarSetCapacity(Out_Data, 294, 0)
		, VarSetCapacity(Out_Data, 0)
		, HasData := 0
}
