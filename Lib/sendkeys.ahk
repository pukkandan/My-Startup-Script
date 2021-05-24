sendKeys(text, level:=1, mode:="event"){
	SendLevel % level
	if (mode="event")
		sendevent % text
	else if (mode="input")
		sendinput % text
	else if (mode="play")
		sendplay % text
	else
		send % text
}
