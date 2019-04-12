#SingleInstance force ; if already running, re-run
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;---------------------------------------------------------------------------------------
; ctrl + {space} = currently active window is now set to always on top
;^SPACE::  Winset, Alwaysontop, , A
;---------------------------------------------------------------------------------------

#IfWinActive ahk_class Notepad++
{
	F9::
	{
		;cd current file path directory
		IfWinNotExist ahk_exe cmd.exe				;Checks to see if cmd exists
			run, C:\windows\system32\cmd.exe		;It doesn't exist, so it is opened
			
		stringPath = 								;clear stringpath variable
		WinGetTitle, title, A						;Get title of Notepad++ Window
		
		;Checks and removes invalid characters		
		if InStr(title, "*")						;Searches string of title for asterisk character, returns position of first invalid found (0=none, 1=first element)
			title := SubStr(title, 2)				;if asterisk found, string is truncated of it.		
		
		;Send Drive Letter to CMD		
		drive_loc := Substr(title,1,2)				;Extracts Drive Letter from file path
		
		;Send File Location to CMD		
		pathArray := StrSplit(title, "\")			;Splits string into an array of words, delimiter is backslash
		
		Loop % (pathArray.MaxIndex() - 1) 			;loops until 2nd last element in array is reached
		{
			ele_path := pathArray[A_Index]			;ele_path = next word array element
			stringPath = %stringPath%%ele_path%\	;stringpath += next element + backslash
		}
		sleep, 500									;Waits 500mS
		WinActivate, ahk_exe cmd.exe				;Set focus to cmd.exe
		Send {Raw}%drive_loc%						;Send Drive Location to CMD
		Send {Blind}{Enter}							;Send Enter button
		Send {Raw}cd %stringPath%					;Send File Path to CMD
		Send {Blind}{Enter}							;Send Enter button
		WinActivate, ahk_class Notepad++			;Set focus back to Notepad++
		
		return
	}
	
	F10::
	{
		;compile all in current directory
		IfWinExist ahk_exe cmd.exe					;Checks to see if cmd exists
		{
			WinActivate, ahk_exe cmd.exe			;Set focus to cmd.exe
			Send {Blind}{Text}cls					;clear screen
			Send {Blind}{Enter}						;Send Enter button
			Send {Blind}{Text}javac *.java			;Send command to compile all
			Send {Blind}{Enter}						;Send Enter button
			WinActivate, ahk_class Notepad++		;Set focus back to Notepad++
		}
		else
			MsgBox, Must press F9 to open CMD, and set file location first.
		return
	}
	
	F11::
	{
		;compile current file
		IfWinExist ahk_exe cmd.exe					;Checks to see if cmd exists
		{
			stringPath = 							;clear stringpath variable
			WinGetTitle, title, A					;Get title of Notepad++ Window
			pathArray := StrSplit(title, "\")		;Splits string into an array of words, delimiter is backslash
			
			NameEnum := patharray.MaxIndex()		;Store number of elements in array
			appName := pathArray[NameEnum]			;Copy string of last element word
			
			appArray := StrSplit(appName, ".java")	;Creates word array from the applican path-name's last element, delimiter = .java
			appEnum := appArray.MinIndex()			;Variable = string of word array's first element
			appName2 := appArray[appEnum]			;Gets Raw file name of .java document (without file extension attached)
			
			WinActivate, ahk_exe cmd.exe			;Set focus to cmd.exe
			Send {Blind}{Text}cls					;clear screen
			Send {Blind}{Enter}						;Send Enter button
			Send {Blind}{Text}javac %appName2%.java	;Send command with appname.java to cmd
			Send {Blind}{Enter}						;Send Enter button
			WinActivate, ahk_class Notepad++		;Set focus back to Notepad++	
		}
		else
			MsgBox, Must press F9 to open CMD, and set file location first.
		return
	}
	
	F12::
	{
		;run current compiled file
		IfWinExist ahk_exe cmd.exe
		{
			stringPath = 							;clear stringpath variable
			WinGetTitle, title, A					;Get title of Notepad++ Window
			pathArray := StrSplit(title, "\")		;Splits string into an array of words, delimiter is backslash
			
			NameEnum := patharray.MaxIndex()		;Store index number of last element in array
			appName := pathArray[NameEnum]			;Copy string of last element word
			
			appArray := StrSplit(appName, ".java")	;Creates word array from the applican path-name's last element, delimiter = .java
			appEnum := appArray.MinIndex()			;Variable = string of word array's first element
			appName2 := appArray[appEnum]			;Gets Raw file name of .java document (without file extension attached)
			
			WinActivate, ahk_exe cmd.exe			;Set focus to cmd.exe
			Send {Blind}{Text}java %appName2%		;Send command with appname to cmd
			Send {Blind}{Enter}						;Send Enter button
			;WinActivate, ahk_class Notepad++		;Set focus back to Notepad++
		}
		else
			MsgBox, Must press F9 to open CMD, and set file location first.
		return
	}
}