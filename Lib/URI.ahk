; Modified by GeekDude from http://goo.gl/0a0iJq
URI_Encode(URI, nochange="[0-9A-Za-z]") {
    VarSetCapacity(Var, StrPut(URI, "UTF-8"), 0), StrPut(URI, &Var, "UTF-8")
    while code := NumGet(Var, A_Index - 1, "UChar")
        result .= (Chr:=Chr(code)) ~= nochange ? Chr : Format("%{:02X}", code)
    return result
}

URI_Decode(URI) {
    position := 1
    while position := RegExMatch(URI, "i)(%[\da-f]{2})+", code, position)
    {
        VarSetCapacity(Var, StrLen(code) // 3, 0), code := SubStr(code,2)
        Loop, Parse, code, `%
            NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
        Decoded := StrGet(&Var, "UTF-8")
        URI := SubStr(URI, 1, position-1) . Decoded . SubStr(URI, position+StrLen(code)+1)
        position += StrLen(Decoded)+1
    }
    return URI
}

;----------------------------------

URI_URLEncode(URL) { ; keep ":/;?@,&=+$#."
    return URI_Encode(URL, "[0-9a-zA-Z:/;?@,&=+$#.]")
}

URI_URLDecode(URL) {
    return URI_Decode(URL)
}

URI_QueryEncode(URL) { ; keep ",&=+#."
    return URI_Encode(URL, "[0-9a-zA-Z,&=+#.]")
}

URI_QueryDecode(URL) {
    return URI_Decode(URL)
}

;Msgbox % URI_Encode("hi hello")
;Msgbox % URI_Decode("hi%20hello")
