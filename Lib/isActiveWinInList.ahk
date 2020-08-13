isActiveWinInList(arr){
	if !arr
		return false
	for _,win in arr
        if winActive(win)
        	return True
    return False
}