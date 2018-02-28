urlDownload_toFile(url,file:="urlDownload_toFile.tmp"){ ;Cannot be interupted
    UrlDownloadToFile, % url, % file
    return file
}

urlDownload(url,byref onDownloadvar:=False,interuptable:=True){
    ; onDownloadVar=False causes it to wait till download finishes and returns the text
    ; IMPORTANT: If it waits, it sends text, but if not, it sends the req object
    if onDownloadVar
         req := ComObjCreate("Msxml2.XMLHTTP") ; Open a request with async enabled.
    else req := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    req.open("GET", url, interuptable)
    if isByRef(onDownloadVar)    ;if onDownloadvar is not byRef, req is returned, but urlDownload_setVar is not called
        req.onreadystatechange := Func("_urlDownload_setVar").bind(onDownloadvar,req) ;urlDownload_setVar() will be called when download is complete.
    req.send()  ;send request

    if onDownloadVar
        return req ;Return object if not waiting for reply

    ; Using interruptable=true and the call below allows the script to remain responsive while waiting for download.
    try
        req.WaitForResponse()
    catch
        return False ;Unable to download
    return req.ResponseText
}

_urlDownload_setVar(byRef var, req) {
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200) ; OK.
        var:=req.responseText
    else var:=False
    return
}