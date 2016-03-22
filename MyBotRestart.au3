#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <Date.au3>
#include <Timers.au3>

$hMainGUI               = GUICreate("My Bot Restart", 350, 200)
;~ row1
						  GUICtrlCreateLabel("Bot File Path"  , 10 , 12, 120    )
$txtBotFilePath         = GUICtrlCreateInput(""               , 110, 10, 180, 20)
$btnBotFilaDialog       = GUICtrlCreateButton("Browse"        , 290, 10,  50, 20)
;~ row2
						  GUICtrlCreateLabel("Atack File Path", 10 , 32, 120    )
$txtAtackFilePath    	= GUICtrlCreateInput(""               , 110, 30, 180, 20)
$btnAtackFilaDialog  	= GUICtrlCreateButton("Browse"        , 290, 30,  50, 20)
;~ row3
						  GUICtrlCreateLabel("Last Atack Checked",  10, 55, 120    )
$txtmaxControlSeconds   = GUICtrlCreateInput("120"               , 110, 52,  50, 20)
						  GUICtrlCreateLabel("seconds"           , 162, 55,  80    )
;~ row4
						  GUICtrlCreateLabel("Last Atack Passing",  10, 78, 120    )
$txtMaxMinute           = GUICtrlCreateInput("120"               , 110, 75, 50 , 20)
						  GUICtrlCreateLabel("minute"            , 162, 78, 80     )

$btnRun                 = GUICtrlCreateButton("Run", 210, 52, 130,44)

GUIStartGroup()
						  GUICtrlCreateLabel("What will I do?",    10, 100, 120    )
$radioBotBS			    = GUICtrlCreateRadio("Restart Bot and BS", 10, 115, 400, 20)
$radioComputer			= GUICtrlCreateRadio("Restart Computer  ", 10, 135, 400, 20)

$statLog                = _GUICtrlStatusBar_Create($hMainGUI)

GUICtrlSetState($txtAtackFilePath, $GUI_DISABLE)
GUICtrlSetState(  $txtBotFilePath, $GUI_DISABLE)
GUICtrlSetState(      $radioBotBS, $GUI_CHECKED)
_GUICtrlStatusBar_SetSimple($statLog)

_GUICtrlStatusBar_SetText($statLog, "Status : Idle")
Local $hTimer = 0
Local $maxControlSeconds
Local $maxControlAfterRestartSeconds = 30*60
Local $restartBot = False
Local $stateProgram= False
Local $dateLastAtack
Local $dateFutureControl
GUISetState(@SW_SHOW, $hMainGUI)

setWrite("RestartBotBSCount",0)
GUICtrlSetData($txtBotFilePath       ,setRead("BotFilePath"))
GUICtrlSetData($txtAtackFilePath     ,setRead("AtackFilePath"))
GUICtrlSetData($txtMaxControlSeconds ,setRead("ControlFrequencySeconds"))
GUICtrlSetData($txtMaxMinute         ,setRead("AtackControlFrequencyMinute"))

While 1
     Switch GUIGetMsg()
             Case $GUI_EVENT_CLOSE
                 ExitLoop
             Case $btnBotFilaDialog
			     $path = btnOpenFilaDialog()
				 setWrite("BotFilePath",$path )
				 GUICtrlSetData($txtBotFilePath ,$path)
			 Case $btnAtackFilaDialog
				 $path = btnOpenFilaDialog()
				 setWrite("AtackFilePath",$path )
			     GUICtrlSetData($txtAtackFilePath ,$path)
			 Case $btnRun
                btnRun()
             Case Else
                Control()
      EndSwitch
Wend

Func Control()
   if $stateProgram  then
	  if $restartBot Then
		 if Round(TimerDiff($hTimer)/1000,2) > $maxControlAfterRestartSeconds Then
			controlIdleTime()
		 EndIf
	  Else
		 if Round(TimerDiff($hTimer)/1000,2) > $maxControlSeconds Then
			controlIdleTime()
		 EndIf
	  EndIf
   EndIf
EndFunc

Func controlIdleTime()
   $dateLastAtack = StringReplace( ZamanHesapla(GUICtrlRead($txtAtackFilePath)), "-", ".")
   $dateNow       = StringReplace( Time(), "-", ".")
   $idleTime= _DateDiff('n',$dateLastAtack , $dateNow)
   $maxIdleTime = GUICtrlRead($txtMaxMinute)
   If $idleTime > $maxIdleTime Then
	  closeBotBS();
	  $restartBot = True
	  Sleep(10000)
   EndIf
   $hTimer            = TimerInit()
   $dateNow           = StringReplace( Time(), "-", ".")
   $dateFutureControl = _DateAdd("s", $maxControlSeconds ,$dateNow)
   SetStatus("")

EndFunc

Func btnRun()
   if NOT $stateProgram Then
	  $path = GUICtrlRead($txtAtackFilePath)
	  $controlseconds = GUICtrlRead($txtMaxControlSeconds)
	  $maxminute = GUICtrlRead($txtMaxMinute)
	  if  StringLen($path) < 1 Then
		 Msg("Lütfen dosya seçiniz.")
		 Return
	  ElseIf  StringLen($controlseconds) < 1 Then
		 Msg("Lütfen kaç dk bir kontrol edileceðini giriniz.")
		 Return
	  ElseIf  StringLen($maxminute ) < 1 Then
		 Msg("Lütfen max saldýrý olmadan geçecek süreyi giriniz.")
		 Return
	  EndIf
	  setWrite("ControlFrequencySeconds",$controlseconds )
	  setWrite("AtackControlFrequencyMinute",$maxminute)
   EndIf

   if $stateProgram Then
	  stateProgram(False)
   else
	  stateProgram(True)
	  $maxControlSeconds  = GUICtrlRead($txtMaxControlSeconds)
	  controlIdleTime()
	  $hTimer = TimerInit()
   EndIf
EndFunc

Func stateProgram($state)
   If $state Then
   ;~ çalýþýyor ise ekranlarý kapat
	  GUICtrlSetState($txtMaxMinute         , $GUI_DISABLE )
	  GUICtrlSetState($txtmaxControlSeconds , $GUI_DISABLE )
	  GUICtrlSetState($btnAtackFilaDialog   , $GUI_DISABLE )
	  GUICtrlSetState($btnBotFilaDialog     , $GUI_DISABLE )
	  GUICtrlSetState($radioComputer        , $GUI_DISABLE )
	  GUICtrlSetState($radioBotBS           , $GUI_DISABLE )
	  GUICtrlSetData($btnRun, "Stop")
	  $stateProgram = True
   Else
	  GUICtrlSetState($txtMaxMinute         , $GUI_ENABLE )
	  GUICtrlSetState($txtmaxControlSeconds , $GUI_ENABLE )
	  GUICtrlSetState($btnAtackFilaDialog   , $GUI_ENABLE )
	  GUICtrlSetState($btnBotFilaDialog     , $GUI_ENABLE )
	  GUICtrlSetState($radioComputer        , $GUI_ENABLE )
	  GUICtrlSetState($radioBotBS           , $GUI_ENABLE )

	  GUICtrlSetData($btnRun, "Run")
	  $stateProgram = False
   EndIf
EndFunc

Func Msg($msg)
   MsgBox($MB_SYSTEMMODAL, "", $msg)
EndFunc

Func Logs($msg)
   ConsoleWrite($msg & @CRLF)
EndFunc

Func Time()
  Return @YEAR & "-" & @MON & "-" & @MDAY & " " & _NowTime(5)
EndFunc

Func SetStatus($msg)
;_GUICtrlStatusBar_SetText($statLog, "Status :  [Last Atack: " &$dateLastAtack &"] [Control Time: " & $dateFutureControl &"]  Message: "& $msg)
 _GUICtrlStatusBar_SetText($statLog, "[ Control Time:  " &  _DateTimeFormat($dateFutureControl,5) &" ]   [ Last Atack: " & _DateTimeFormat($dateLastAtack,5) &" ] ")
EndFunc

Func ZamanHesapla($DosyaYolu)
 Local CONST $FO_BINARY = 16
 Local $i = FileOpen($DosyaYolu,$FO_BINARY)
 if $i = -1 then
	 MsgBox(16,"Hata","Dosya okuma iþlemi yapýlamýyor.")
	 return "DOSYA OKUNAMADI"
 Else
	  $last_line = FileReadLine ($i, -1)
	  FileClose($i)
	  $iPosition = StringInStr($last_line, "|")
	  $sString = StringMid($last_line, 1, $iPosition-9)
   EndIf
   Return $sString
EndFunc

Func btnOpenFilaDialog()
    Local Const $sMessage = "Select a single file of any type."
    Local $sFileOpenDialog = FileOpenDialog($sMessage, @WindowsDir & "\", "All (*.*)", $FD_FILEMUSTEXIST)
    If @error Then
        MsgBox($MB_SYSTEMMODAL, "", "No file was selected.")
        FileChangeDir(@ScriptDir)
    Else
		FileChangeDir(@ScriptDir)
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)
		Return $sFileOpenDialog
    EndIf
EndFunc

Func closeBotBS()
    $count = setRead("RestartBotBSCount")
    if $count  > 5 Then
	  Shutdown(1)
    Else
	   setWrite("RestartBotBSCount",$count+1)
    EndIf

    ProcessClose("notepad++.exe")
    ProcessClose("MyBot.run.exe")
    ProcessClose("BlueStacks.exe")
    ProcessClose("HD-Agent.exe")
    ProcessClose("HD-Adb.exe")
    ProcessClose("HD-BlockDevice.exe")
    ProcessClose("HD-FrontEnd.exe")
    ProcessClose("HD-Network.exe")
    ProcessClose("HD-Service.exe")
    ProcessClose("HD-SharedFolder.exe")
    ProcessClose("HD-UpdaterService.exe")
    ProcessClose("HD-LogRotatorService.exe")
    ProcessClose("HD-RunApp.exe")
	Sleep(1000)
    Run(@ProgramFilesDir & "\BlueStacks\HD-StartLauncher.exe", "", @SW_SHOWMAXIMIZED)
    Sleep(1000)
	Run(GUICtrlRead($txtBotFilePath), "", @SW_SHOWMAXIMIZED)
    Sleep(1000)
EndFunc

Func setWrite($key ,$value)
   RegWrite("HKEY_CURRENT_USER\Software\MyBotRunRestart", $key, "REG_SZ", $value)
EndFunc

Func setRead($key)
  $value = RegRead("HKEY_CURRENT_USER\Software\MyBotRunRestart", $key)
  Return $value
EndFunc