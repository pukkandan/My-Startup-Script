class ini{
	__new(file:="Settings.ini"){
		this.file:=file
	}
	get(sect:="",key:="",def:=0){
		if (sect="")
			iniRead, val, % this.file
		else if (key="")
			iniRead, val, % this.file, % sect
		else
			iniRead, val, % this.file, % sect, % key, % def
		return val
	}
	set(sect,key:="",val:=""){
		if (key="")
			iniWrite, % val, % this.file, % sect
		else
			iniWrite, % val, % this.file, % sect, % key
		return
	}
	delete(sect:="",key:=""){
		if (sect="")
			FileDelete, % this.file
		else if (key="")
			iniDelete, % this.file, % sect
		else
			iniDelete, % this.file, % sect, % key
		return
	}
}
