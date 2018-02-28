; Modified by GeekDude from http://goo.gl/0a0iJq
URI_Encode(URI, RE="[0-9A-Za-z]") {
    VarSetCapacity(Var, StrPut(URI, "UTF-8"), 0), StrPut(URI, &Var, "UTF-8")
    While Code := NumGet(Var, A_Index - 1, "UChar")
        Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
    Return, Res
}

URI_Decode(URI) {
    Pos := 1
    While Pos := RegExMatch(URI, "i)(%[\da-f]{2})+", Code, Pos)
    {
        VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
        Loop, Parse, Code, `%
            NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
        Decoded := StrGet(&Var, "UTF-8")
        URI := SubStr(URI, 1, Pos-1) . Decoded . SubStr(URI, Pos+StrLen(Code)+1)
        Pos += StrLen(Decoded)+1
    }
    Return, URI
}

;----------------------------------

URI_URLEncode(URL) { ; keep ":/;?@,&=+$#."
    return URI_Encode(URL, "[0-9a-zA-Z:/;?@,&=+$#.]")
}

URI_URLDecode(URL) {
    return URI_Decode(URL)
}