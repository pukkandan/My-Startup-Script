str_countLines(str){
	StrReplace(str, "`n",, ret)
	return ret+1
}

str_splitIntoLines(str, len){
	ret:="", i:=1
	loop % ceil(strLen(str)/len) {
		ret.="`n" subStr(str, i, len)
		i+=len
	}
	return subStr(ret, 2)
}

str_caseChange(text,type){ ; type: U=UPPER, L=Lower, T=Title, S=Sentence, I=Invert
    static X:= ["I","AHK","AutoHotkey","Dr","Mr","Ms","Mrs","AKJ"] ;list of words that should not be modified for S,T
    if (type="S") { ;Sentence case.
        text := RegExReplace(RegExReplace(text, "(.*)", "$L{1}"), "(?<=[^a-zA-Z0-9_-]\s|\n).|^.", "$U{0}")
    } else if (type="I") ;iNVERSE
        text:=RegExReplace(text, "([A-Z])|([a-z])", "$L1$U2")
    else text:=RegExReplace(text, "(.*)", "$" type "{1}")

    if (type="S" OR type="T")
        for _, word in X ;Parse the exceptions
            text:= RegExReplace(text,"i)\b" word "\b", word)
    return text
}

str_CommonPart(strArr){
	ret:=strArr[1]
	len:=strlen(ret)
	for _,str in strArr
	{
		loop % len
		{
			if (ret = substr(str, 1, len))
				break
			ret:=substr(ret,1,-1)
			len-=1
		}
	}
	return ret
}

str_Replace(str, replaceArr){ ; ReplaceArr = [[find, replace, regex?], ...]
	for _,re in replaceArr {
		fn:= re[3]? "RegExReplace" : "StrReplace"
		str:=Func(fn).call(str, re[1], re[2])
	}
	return str
}

str_fromArr(arr, delim:="`n", subKey:=""){
	ret:=""
	for _,v in arr {
		if IsObject(v)
			v:= (subKey==False) ? "<object>" : v[subKey]
		ret.=delim . v
	}
	return subStr(ret, 2)
}

str_fromMap(obj, delim1:=" = ", delim2:="`n", subKey:=False){
	ret:=""
	for k,v in obj {
		if IsObject(v)
			v:= (subKey==False) ? "<object>" : v[subKey]
		ret.=delim2 . k . delim1 . v
	}
	return subStr(ret, 2)
}
