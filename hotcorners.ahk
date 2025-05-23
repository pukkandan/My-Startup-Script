hotcorners(){
	CoordMode, Mouse, Screen
	static counter:=0, trigger:=False, smallDelay:=2, delay:=10
	counterTemp:=0
	MouseGetPos, xpos, ypos
	buttonsPressed:= GetKeyState("LButton") OR GetKeyState("RButton")
	;tooltip, % "X:" xpos "+" A_ScreenWidth-xpos "=" A_ScreenWidth "`nY:"  ypos "+" A_ScreenHeight-ypos "=" A_ScreenHeight "`nTrigger=" trigger "`nCounter=" counter

	; Edges not containing trigger:=True will fire contineously. Counter can be used to controll the frequency of firing.
	; Corners must always contain trigger:=True. Otherwise, edge to corner transitions will fire the corresponding edge.

	/* How to use counter:
	; Repeat
		counterTemp:=counter+1
		if (counterTemp>delay){
			DO THIS
			counterTemp:=0
		}
	; No repeat
		counterTemp:=counter+1
		if (counterTemp==delay){ ; After delay, but dont repeat
			DO THIS
			trigger:=True
		}
	; NB: Make sure to disable "trigger:=True" at the top
	*/

	if (xpos<2) {
		if (ypos<2){
			if (!trigger){
				trigger:=True
				if(!buttonsPressed){
					; 										Top Left
					send, #{tab}
					;---------------------------------------------------------
				}
			}
		}
		else if (ypos+2>=A_ScreenHeight){
			if (!trigger){
				trigger:=True
				if(!buttonsPressed){
					; 										Bottom Left
					Send, #n
					;---------------------------------------------------------
				}
			}
		}
		else {
			if (!trigger){
				; trigger:=True
				if(!buttonsPressed){
					; 										Left
					; counterTemp:=counter+1
					; if (counterTemp>=delay){
					; 	Send, #^{Left}
					; 	counterTemp:=0
					; }
					;---------------------------------------------------------
				}
			}
		}
	}
	else if (xpos+2>=A_ScreenWidth) {
		if (ypos<2) {
			if (!trigger){
				trigger:=True
				if(!buttonsPressed){
					; 										Top Right

					;---------------------------------------------------------
				}
			}
			lastYedge:="Top"
		}
		else if (ypos+2>=A_ScreenHeight){
			if (!trigger){
				;trigger:=True
				if(!buttonsPressed){
					; 										Bottom Right
					; counterTemp:=counter+1
					; if (counterTemp==delay){ ; After delay, but dont repeat
					; 	Send, #a
					; 	trigger:=True
					; }
					;---------------------------------------------------------
				}
			}
		}
		else {
			lastcorner:="None"
			if (!trigger){
				; trigger:=True
				if(!buttonsPressed){
					; 										Right
					; counterTemp:=counter+1
					; if (counterTemp>delay){
					; 	Send, #^{Right}
					; 	counterTemp:=0
					; }
					;---------------------------------------------------------
				}
			}
		}
		lastXedge:="Right"
	}
	else if (ypos<2){
		if (!trigger){
			trigger:=True
			if(!buttonsPressed){
				; 											Top

				;-------------------------------------------------------------
			}
		}
	}
	else if (ypos+2>=A_ScreenHeight){
		if (!trigger){
			; trigger:=True
			if(!buttonsPressed){
				; 											Bottom
				; counterTemp:=counter+1
				; 	if (counterTemp>delay){
				; 		send, #{Tab}
				; 		trigger:=True
				; 		counterTemp:=0
				; 	}
				;-------------------------------------------------------------
			}
		}
	}
	else trigger:=False
	counter:=counterTemp
	;ToolTip, %LastCorner%%LastXEdge%%LastYEdge%
}
