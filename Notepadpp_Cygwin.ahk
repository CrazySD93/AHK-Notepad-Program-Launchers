#SingleInstance force ; if already running, re-run
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;---------------------------------------------------------------------------------------
; ctrl + {space} = currently active window is now set to always on top
;^SPACE::  Winset, Alwaysontop, , A
;---------------------------------------------------------------------------------------

;=====================================Notepad++ Cygwin===================================

;----------------------------------------------------------------------------------------

#IfWinActive ahk_class Notepad++
{
	F9::
	{
		;cd current file path directory
		IfWinNotExist ahk_exe mintty.exe			;Checks to see if Cygwin Terminal exists
			run, C:\cygwin64\bin\mintty.exe			;It doesn't exist, so it is opened
			
		stringPath = 								;clear stringpath variable
		WinGetTitle, title, A						;Get title of Notepad++ Window
		
		;Checks and removes invalid characters		
		if InStr(title, "*")						;Searches string of title for asterisk character, returns position of first invalid found (0=none, 1=first element)
			title := SubStr(title, 2)				;if asterisk found, string is truncated of it.		
		
		;Send Drive Letter to cygwin		
		drive_loc := Substr(title,1,2)				;Extracts Drive Letter from file path
		
		;Send File Location to cygwin		
		pathArray := StrSplit(title, "\")			;Splits string into an array of words, delimiter is backslash
		
		sleep, 500									;Waits 500mS
		WinActivate, ahk_exe mintty.exe				;Set focus to mintty.exe
		Send {Raw}cd %drive_loc%					;Send Drive Location to cygwin
		Send {Blind}{Enter}							;Send Enter button
		
		Loop % (pathArray.MaxIndex() - 1)
		{
			ele_path := pathArray[A_Index]			;ele_path = next word array element
			stringPath = %stringPath%%ele_path%\	;stringpath += next element + backslash
			Send {Raw}cd %ele_path%					;Send File Path to cygwin
			Send {Blind}{Enter}						;Send Enter button
		}
		SetWorkingDir %stringPath%
		;MsgBox, Working Directory is %stringPath%
		WinActivate, ahk_class Notepad++			;Set focus back to Notepad++
		
		return
	}
	
	F10::
	{	
		stringPath = 								;clear stringpath variable
		WinGetTitle, title, A						;Get title of Notepad++ Window
		
		;Checks and removes invalid characters		
		if InStr(title, "*")						;Searches string of title for asterisk character, returns position of first invalid found (0=none, 1=first element)
			title := SubStr(title, 2)				;if asterisk found, string is truncated of it.		
		
		;Send File Location to cygwin		
		pathArray := StrSplit(title, "\")			;Splits string into an array of words, delimiter is backslash
		
		sleep, 500									;Waits 500mS
		
		Loop % (pathArray.MaxIndex() - 1)
		{
			ele_path := pathArray[A_Index]			;ele_path = next word array element
			stringPath = %stringPath%%ele_path%\	;stringpath += next element + backslash
		}
		SetWorkingDir %stringPath%					;Set Directory to save Makefile
	
		;Generate Standard 1 File Makefile
		
		Gui, Add, Text,, Sources:
		Gui, Add, Text,, Name.exe:
		Gui, Add, Edit, vsourceList ym W350 ; The ym option starts a new column of controls.
		Gui, Add, Edit, vnameEXE W350
		Gui, Add, Button, W150, CANCEL  ; The label ButtonCANCEL (if it exists) will close the GUI when the button is pressed.
		Gui, Add, Button, default x+50 W150, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
		Gui, Show,W450, Make the Makefile

		return  ; End of auto-execute section. The script is idle until the user does something.

		GuiClose:
		ButtonCANCEL:	;Button's associated command
		Gui, Destroy	;Destroy GUI
		return
		ButtonOK:		;Button's associated command
		Gui, Submit 	;Save the input from the user to each control's associated variable.
		
		;If sources and .exe fields are empty on submit, end command
		if(sourceList = "" || nameEXE = "")	
		{
			Gui, Destroy	;Destroy GUI
			return
		}
		
		;Makefile, with submitted sources and .exe names
		Makefiletxt := "CC=g++`nCFLAGS=-c -Wall -std=c++98`nLDFLAGS=`nSOURCES="
		Makefiletxt = %Makefiletxt%%sourceList%
		Makefiletxt2 := "`nOBJECTS=$(SOURCES:.cpp=.o)`nEXECUTABLE="
		Makefiletxt = %Makefiletxt%%Makefiletxt2%%nameEXE%
		Makefiletxt2 := "`n`nall: $(SOURCES) $(EXECUTABLE)`n`n$(EXECUTABLE): $(OBJECTS)`n	$(CC) $(LDFLAGS) $(OBJECTS) -o $@`n`n%.o : %.cpp`n	$(CC) $(CFLAGS) -c $<`n`nclean:`n	rm -rf *.o core"
		Makefiletxt = %Makefiletxt%%Makefiletxt2%
		
		;Rename current Makefile in folder to Makefile - old
		If FileExist("Makefile")
		{
			FileMove, Makefile, Makefile - Old
		}
		FileDelete, Makefile
		FileAppend, %Makefiletxt%, Makefile
		
		Gui, Destroy
		return
	}
	
	F11::
	{
		;compile make in current directory
		IfWinExist ahk_exe mintty.exe				;Checks to see if cygwin exists
		{
			WinActivate, ahk_exe mintty.exe			;Set focus to mintty.exe
			Send {Blind}{Text}clear					;clear screen
			Send {Blind}{Enter}						;Send Enter button
			Send {Blind}{Text}make clean			;Send command to clear previous make files
			Send {Blind}{Enter}						;Send Enter button
			Send {Blind}{Text}make					;Send command to compile all
			Send {Blind}{Enter}						;Send Enter button
			WinActivate, ahk_class Notepad++		;Set focus back to Notepad++
		}
		else
			MsgBox, Must press F9 to open cygwin, and set file location first.
		return
	}
	
	F12::
	{
		;Search Makefile in current directory for executable name, and run that
		IfWinExist ahk_exe mintty.exe
		{
			FileReadLine, exeName1, Makefile, 6
			;MsgBox, %exeName1%						;Displays "EXECUTABLE=%exeName1%"
			exeName2 := StrSplit(exeName1, "=")		;Splits string into an array of words, delimiter is backslash
			
			exeName3 := exeName2[2]					;Copy string of last element word
		
			;Msgbox, %exeName3%						;Displays "%exeName3%"
			
			WinActivate, ahk_exe mintty.exe			;Set focus to mintty.exe
			Send {Blind}{Text}./%exeName3%			;Send command with appname to cygwin
			Send {Blind}{Enter}						;Send Enter button
			;WinActivate, ahk_class Notepad++		;Set focus back to Notepad++
		}
		else
			MsgBox, Must press F9 to open cygwin, and set file location first.
		return
	}
}