; https://github.com/shajul/Autohotkey/blob/master/COM/Zip Unzip Natively.ahk

unzip(zipFullPath, folderFullPath) {
	folderFullPath:=RegExReplace(folderFullPath, "\\$")
	try FileCreateDir, % folderFullPath

	SA:=ComObjCreate("Shell.Application")
	pzip:=SA.Namespace(zipFullPath)
	pfol:=SA.Namespace(folderFullPath)
	zippedItems:=pzip.items().count
	pfol.CopyHere(pzip.items(), 4|16 )

	while (pfol.items().count<zippedItems) { ; Wait for completion
		tooltip, "Zipped " pfol.items().count "/" zippedItems
		sleep 100
	}
	tooltip
	return zippedItems
}


zip(filesToZip, zipFullPath, append:=False) {
	if !append or !fileExist(zipFullPath) {
		try FileDelete % zipFullPath
		_zip_create(zipFullPath)
	}
	SA:=ComObjCreate("Shell.Application")
	pzip:=SA.Namespace(zipFullPath)
	start:=pzip.items().count

	if !isObject(filesToZip)
		filesToZip:=[filesToZip]
	for i,file in filesToZip {
		if !FileExist(file)
			continue
		pzip.CopyHere(file, 4|16)
		while (pzip.items().count < i+start) { ; Wait for completion
			tooltip % "Unzipping " file
			sleep 100
		}
		tooltip
	}
	return pzip.items().count
}


_zip_create(zipFullPath){
	file := fileOpen(zipFullPath, "w")
	file.write("PK" Chr(5) Chr(6))
	VarSetCapacity(h, 18, 0)
	file.RawWrite(h, 18)
	file.close()
}


zip_unzip(args*){
	return unzip(args*)
}
zip_zip(args*){
	return zip(args*)
}
