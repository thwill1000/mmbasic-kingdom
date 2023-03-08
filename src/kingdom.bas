' Yellow River Kingdom (aka Hamurabi).
' BBC Micro - Version 5 - October 1981.
' By Tom Hartley, Jerry Temple-Fry (NETHERHALL SCHOOL) and Richard G Warner.
' MMBasic 5.07 port by Thomas Hugo Williams, 2021-2023.

Option Base 0
Option Default None
Option Explicit
'!ifndef CONSOLE_ONLY
Option Console Serial
'!endif

#Include "splib/system.inc"
#Include "splib/txtwm.inc"

'!ifndef CONSOLE_ONLY
Mode 2
Font 4
Cls
'!endif

'!uncomment_if CONSOLE_ONLY

'' Restore cursor and default attributes on exit.
'Option Break 4
'On Key 3, my_exit()
'Sub my_exit()
'  Print Chr$(27) "[?25h" Chr$(27) "[0m"
'  Option Break 3
'  End
'End Sub

'' Hide cursor, clear console, return cursor to home.
'Print Chr$(27) "[?25l" Chr$(27) "[2J" Chr$(27) "[H"

'!endif

Const VERSION$ = "Version 1.0.4"

twm.init(2, 3742)
'!ifndef CONSOLE_ONLY
Dim win1% = twm.new_win%(11, 0, 40, 25)
Dim win2% = twm.new_win%(14, 0, 36, 24)
'!endif
'!uncomment_if CONSOLE_ONLY
'Dim win1% = twm.new_win%(3, 0, 40, 25)
'Dim win2% = twm.new_win%(6, 0, 36, 24)
'!endif

Dim season_name$(3) = ("", "Winter", "Growing", "Harvest")
Dim vx%(3) = (0, 13, 21, 22) ' Village x-coordinates
Dim vy%(3) = (0,  8, 12, 18) ' Village y-coordinates
Dim food%                    ' Food.
Dim people%                  ' Population.
Dim turn%                    ' Turn.
Dim season%                  ' Season.
Dim year%                    ' Year.
Dim workers%                 ' People defending the dyke.
Dim farmers%                 ' People working in the fields.
Dim soldiers%                ' People defending the villages.
Dim planted!                 ' Baskets of rice planted in the fields.
Dim flooded%(3)              ' Is a village flooded ? (boolean)
Dim flood_deaths%            ' Number of deaths caused by flooding.
Dim flood_losses%            ' Food lost to flooding.
Dim thief_deaths%            ' Number of deaths caused by thieves.
Dim thief_losses%            ' Food lost to thieves.
Dim starvation_deaths%       ' Number of deaths caused by starvation.
Dim num_flooded%             ' Number of flooded villages.
Dim was_attacked%            ' Was there an attack ? (boolean)
Dim was_flooded%             ' Was there a flood ? (boolean)

procTITLEPAGE()
procINSTRUCTIONS()

Do
  procREINIT()
  procGAMELOOP()
Loop Until Not fnPLAYAGAIN%()

End

Sub procTITLEPAGE()
  procMAP()
  Pause 2000
  twm.print_at(0, 11, Space$(200))
  twm.foreground(twm.YELLOW%)
  twm.bold(1)
  twm.print_at(12, 12, "YELLOW RIVER")
  twm.print_at(12, 13, "   KINGDOM    ")
  twm.bold(0)
  twm.print_at(18 - Len(VERSION$) \ 2, 14, VERSION$)
  Local i% = fnINKEY%(10000, 1) ' 10 seconds
End Sub

Sub procMAP()
  Local i%
  twm.switch(win1%)
  twm.cls()

  ' Print river.
  twm.foreground(twm.YELLOW%)
  For i% = 3 To 23
    twm.print_at(1, i%, Chr$(219))
  Next

  ' Print dam.
  twm.foreground(twm.CYAN%)
  For i% = 3 To 23
    twm.print_at(3, i%, Chr$(221) + Chr$(221))
  Next

  ' Print mountains.
  twm.foreground(twm.RED%)
  For i% = 3 To 21 Step 2
    twm.print_at(29, i%, Chr$(222))
    twm.print_at(28, i% + 1, Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220) + "  " + Chr$(222))
    twm.print_at(33, i% + 2, Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220))
  Next

  ' Print thieves.
  For i% = 13 To 15 : twm.print_at(30, i%, "  ") : Next
  twm.print_at(30, 14, "THIEVES")
  twm.print_at(31, 13, "TT")
  twm.print_at(31, 15, "T")
  twm.print_at(32, 16, "T")
  twm.print_at(32, 17, "T")

  ' Print villages.
  For i% = 1 To 3 : procVDRAW(i%) : Next

  twm.foreground(twm.white%)
  twm.print_at(0, 23, "   DYKE        VILLAGES      MOUNTAINS")
End Sub

Sub procVDRAW(i%)
  twm.foreground(twm.GREEN%)
  twm.print_at(vx%(i%) - 1, vy%(i%), Chr$(138) + Chr$(165))
  twm.print_at(vx%(i%) - 1, vy%(i%) + 1, Chr$(165) + Chr$(138))
End Sub

Sub procINSTRUCTIONS()
  procYELLOW()

  twm.print_at(0,  4, "The kingdom is three villages. It")
  twm.print_at(0,  5, "is between the Yellow River and")
  twm.print_at(0,  6, "the mountains.")

  twm.print_at(0,  8, "You have been chosen to take")
  twm.print_at(0,  9, "all the important decisions. Your")
  twm.print_at(0, 10, "poor predecessor was executed by")
  twm.print_at(0, 11, "thieves who live in the nearby")
  twm.print_at(0, 12, "mountains.")

  twm.print_at(0, 14, "These thieves live off the ")
  twm.print_at(0, 15, "villagers and often attack. The")
  twm.print_at(0, 16, "rice stored in the villages must")
  twm.print_at(0, 17, "be protected at all times.")

  procSPACE()

  twm.cls()

  twm.print_at(0,  3, "The year consists of three long ")
  twm.print_at(0,  4, "seasons, Winter, Growing and")
  twm.print_at(0,  5, "Harvest. Rice is planted every")
  twm.print_at(0,  6, "Growing Season. You must decide")
  twm.print_at(0,  7, "how much is planted.")

  twm.print_at(0,  9, "The river is likely to flood the")
  twm.print_at(0, 10, "fields and the villages. The high")
  twm.print_at(0, 11, "dyke between the river and the")
  twm.print_at(0, 12, "fields must be kept up to prevent")
  twm.print_at(0, 13, "a serious flood.")

  twm.print_at(0, 15, "The people live off the rice that")
  twm.print_at(0, 16, "they have grown. It is a very poor")
  twm.print_at(0, 17, "living. You must decide what the")
  twm.print_at(0, 18, "people will work at each season")
  twm.print_at(0, 19, "so that they prosper under your")
  twm.print_at(0, 20, "leadership.")

  procSPACE()
End Sub

Sub procSPACE()
  twm.print_at(0, 22, "Press the SPACE BAR to continue")
  procKCL()
  Do While Inkey$ <> " " : Loop
  twm.print_at(0, 22, "                               ")
End Sub

Sub procREINIT()
  food% = 5000 + fnRND%(2000)
  people% = 300 + fnRND%(100)
  turn% = 0
End Sub

Sub procGAMELOOP()
  Do

    procNEWTURN()
    procBEGINSEASON()
    procMAP()
    procHEADER()

    If fnRND%(2) = 1 Then
      procATTACK()
      procFLOOD()
    Else
      procFLOOD()
      procATTACK()
    EndIf

    procCALCULATE()
    procENDSEASON()

    If people% <= 0 Or food% <= 0 Then Exit Do

    If turn% Mod 12 = 0 Then
      If Not fnRITUAL%() Then Exit Do
    EndIf

    If people% < 200 And fnRND%(3) = 1 Then procADDTHIEVES()

    ' Make babies.
    people% = Int(people% * 1.045)

  Loop
End Sub

Sub procNEWTURN()
  Inc turn%
  season% = (turn% - 1) Mod 3 + 1
  year% = (turn% - 1) \ 3 + 1

  Local i%
  For i% = 1 To 3 : flooded%(i%) = 0 : Next

  flood_deaths% = 0
  flood_losses% = 0
  thief_deaths% = 0
  thief_losses% = 0
  num_flooded% = 0
  was_flooded% = 0
  was_attacked% = 0
End Sub

Sub procBEGINSEASON()
  procYELLOW()

  twm.print_at(8, 1, "Census Results")

  If turn% = 1 Then
    twm.print_at(0,  3, "You have inherited this situation")
    twm.print_at(0,  4, "from your unlucky predecessor. It")
    twm.print_at(0,  5, "is the start of the Winter Season.")
  Else
    twm.print_at(0, 3, "At the start of the " + season_name$(season%) + " Season")
    twm.print_at(0, 4, "of year "+ Str$(year%) + " of your reign this is")
    twm.print_at(0, 5, "the situation.")
  EndIf

  twm.print_at(0,  7, "Allowing for births and deaths,")
  twm.print_at(0,  8, "the population is " + Str$(people%) + ".")

  twm.print_at(0, 10, "There are " + Str$(food%) + " baskets of rice")
  twm.print_at(0, 11, "in the village stores.")

  twm.print_at(0, 13, "How many people should:")
  twm.print_at(0, 14, " A) Defend the dyke......")
  twm.print_at(0, 15, " B) Work in the fields...")
  twm.print_at(0, 16, " C) Protect the villages.")

  ' Prompt for number of people to defend the dyke.
  Do
    twm.print_at(26, 14)
    workers% = fnNUMINP%()
    If workers% > people% Then procIMPOS() Else Exit Do
  Loop

  ' Prompt for number of people to work in the fields.
  If workers% = people% Then
    farmers% = 0
    twm.print_at(26, 15, "0")
  Else
    Do
      twm.print_at(26, 15)
      farmers% = fnNUMINP%()
      If workers% + farmers% > people% Then procIMPOS() Else Exit Do
    Loop
  EndIf

  ' Calculate the number of people to protect the villages.
  soldiers% = people% - workers% - farmers%
  twm.print_at(26, 16, Str$(soldiers%))

  If season% = 2 Then
    twm.print_at(0, 18, "How many baskets of rice will be")
    twm.print_at(0, 19, "planted in the fields.....")
    Do
      twm.print_at(26, 19)
      planted! = fnNUMINP%()
      If planted! > food% Then procIMPOS()
    Loop Until planted! <= food%
    Inc food%, -planted!
  EndIf

  procSPACE()
End Sub

Sub procIMPOS()
  twm.inverse(1)
  twm.bold(1)
  twm.print_at(5, 20, " I M P O S S I B L E ")
  twm.inverse(0)
  twm.bold(0)
  Pause 2000
  procSPACE()
  twm.print_at(5, 20, "                     ")
End Sub

Sub procHEADER()
  twm.foreground(twm.WHITE%)
  twm.bold(1)
  twm.print_at(1,  1, season_name$(season%) + " Season")
  twm.print_at(28, 1, "Year " + Str$(year%))
  twm.bold(0)
End Sub

Sub procATTACK()
  ' There can be no attack if all the villages have been flooded.
  If num_flooded% = 3 Then Exit Sub

  Select Case season%
    Case 1    : If Rnd() < 0.5 Then Exit Sub ' 50% likely to attack in winter
    Case 2    : If Rnd() < 0.2 Then Exit Sub ' 80% likely to attack in growing season
    Case 3    : If Rnd() < 0.6 Then Exit Sub ' 40% likely to attack in harvest season
    Case Else : Error "Unknown season " + Str$(season%)
  End Select

  ' There has been an attack.
  was_attacked% = 1

  ' Select an unflooded village to attack.
  Local village%
  Do
    village% = fnRND%(3)
  Loop Until Not flooded%(village%)

  Local x% = 32, y%
  Local wx% = vx%(village%)
  Local wy% = vy%(village%) - 1
  Local d% ' direction
  If wy% < 17 Then
    y% = 13 : d% = -1
  Else
    y% = 17 : d% = 1
  EndIf
  Local sy% = y%

  twm.foreground(twm.RED%)

  ' Move the thief vertically towards village.
  Do
    twm.print_at(x%, y%, " ")
    If y% = wy% Then Exit Do
    Inc y%, d%
    twm.print_at(x%, y%, "T")
    Pause 50
  Loop

  ' Move the thief horizontally toward village.
  Do While x% > wx%
    Inc x%, -1
    twm.print_at(x%, y%, "T")
    Pause 1000 * (1 - Min(0.9, (x% - wx%) / 5))
    twm.print_at(x%, y%, Choice(x% = 29, Chr$(222), " "))
  Loop

  ' Attack the village.
  twm.foreground(twm.GREEN%)
  Local i%
  For i% = 1 To 40
    twm.print_at(x%, y% + 1, Mid$("\|/-", 1 + i% Mod 4, 1))
    Pause 40
  Next

  procVDRAW(village%)

  twm.foreground(twm.RED%)

  ' Move the thief horizontally back to the mountains.
  Do While x% < 32
    twm.print_at(x%, y%, Choice(x% = 29, Chr$(222), " "))
    Inc x%
    twm.print_at(x%, y%, "T")
    Pause 40
  Loop

  ' Move the thief vertically back to the mountains.
  Do While y% <> sy%
    twm.print_at(x%, y%, " ")
    Inc y%, -d%
    twm.print_at(x%, y%, "T")
    Pause 50
  Loop

  ' How effective were the thieves ?
  Select Case season%
    Case 1 : i% = 200 + fnRND%(70) - soldiers%
    Case 2 : i% = 30 + fnRND%(200) - soldiers%
    Case 3 : i% = fnRND%(400) - soldiers%
    Case Else
      Error "Unknown season: " + Str$(season%)
  End Select
  If i% < 0 Then i% = 0

  ' Thieves kill people.
  thief_deaths% = Int(soldiers% * i% / 400)
  soldiers% = soldiers% - thief_deaths%

  ' Thieves steal food.
  thief_losses% = Int(i% * food% / 729 + fnRND%(2000 - soldiers%) / 10)
  If thief_losses% < 0 Then
    thief_losses% = 0
  ElseIf thief_losses% > 2000 Then
    thief_losses% = 1900 + fnRND%(200)
  EndIf
  Inc food%, -thief_losses%
End Sub

Sub procFLOOD()
  Local fs! ' Flood severity.
  Select Case season%
    Case 1    : fs! = fnRND%(330) / (workers% + 1)
    Case 2    : fs! = (fnRND%(100) + 60) / (workers% + 1)
    Case 3    : Exit Sub
    Case Else : Error "Unknown season " + Str$(season%)
  End Select

  If fs! < 1.0 Then Exit Sub

  was_flooded% = 1

  Local x% = 6
  Local y% = fnRND%(8) + 10
  twm.foreground(twm.YELLOW%)
  twm.print_at(1, y%, Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219))

  Local k%, key% = -1, v%, w1%, w2%
  fs! = fnRND%(Choice(fs! < 2.0, 2.0, 4.0))
  For k% = 1 To fs! * 100
    Do
      Select Case fnRND%(4)
        Case 1 : If x% < 25 Then Inc x%     : Exit Do
        Case 2 : If x% > 6  Then Inc x%, -1 : Exit Do
        Case 3 : If y% < 22 Then Inc y%     : Exit Do
        Case 4 : If y% > 3  Then Inc y%, -1 : Exit Do
      End Select
    Loop

    ' Have any of the villages flooded ?
    For v% = 1 To 3
      w1% = vx%(v%) - x%
      w2% = y% - vy%(v%)
      If w2% = 0 Or w2% = 1 Then
        If w1% = 0 Or w1% = 1 Then flooded%(v%) = 1 : Inc num_flooded%
        If w1% = -1 Then Exit For
      EndIf
    Next

    twm.print_at(x%, y%, Chr$(219))

    If key% = -1 Then key% = fnINKEY%(100, k% = 1)
  Next

  ' Deaths.
  Local orig_pop%  = workers% + farmers% + soldiers%
  workers% = Int((workers% / 10) * (10 - fs!))
  farmers% = Int((farmers% / 10) * (10 - fs!))
  soldiers% = Int((soldiers% / 6) * (6 - num_flooded%))
  flood_deaths% = orig_pop% - workers% - farmers% - soldiers%

  ' Loss of food from the villages.
  flood_losses% = Int(food% * num_flooded% / 6)
  Inc food%, -flood_losses%

  ' Loss of rice in the fields.
  Select Case season%
    Case 1    : ' Nothing
    Case 2    : planted! = planted! * (20 - fs!) / 20
    Case 3    : planted! = planted! * (10 - fs!) / 10
    Case Else : Error "Unknown season " + Str$(season%)
  End Select
End Sub

Sub procCALCULATE()

  ' How much grain have we grown ?
  If farmers% = 0 Then
    planted! = 0
  Else
    Select Case season%
      Case 1 : ' No grain grown during the winter.
      Case 2
        If planted! > 1000 Then planted! = 1000
        planted! = planted! * (farmers% - 10) / farmers%
      Case 3
        If planted! > 0 Then planted! = 18 * (11 + fnRND%(3)) * (0.05 - 1 / farmers%) * planted!
        If planted! > 0 Then food% = food% + Int(planted!)
      Case Else
        Error "Unknown season " + Str$(season%)
    End Select
  EndIf

  ' How many people have starved ?
  starvation_deaths% = 0
  people% = workers% + farmers% + soldiers%
  If people% <= 0 Then Exit Sub ' Everyone is dead!

  Local t! = food% / people%
  If t! > 5 Then
    t! = 4
  ElseIf t! < 2 Then
    people% = 0
  ElseIf t! > 4 Then
    t! = 3.5
  Else
    starvation_deaths% = Int(people% * (7 - t!) / 7)
    t! = 3
  EndIf

  If people% > 0 Then
    Inc people%, -starvation_deaths%
    food% = Int(food% - people% * t! - starvation_deaths% * t! / 2)
    If food% < 0 Then food% = 0
  EndIf
End Sub

Sub procENDSEASON()
  Pause 2000
  If food% <= 0 Then
    procYELLOW()
    twm.print_at(0,  7, "There was no food left. All of the")
    twm.print_at(0,  8, "people have run off and joined up")
    twm.print_at(0,  9, "with the thieves after " + Str$(turn%) + " seasons")
    twm.print_at(0, 10, "of your misrule")
    procSPACE()
    Exit Sub
  EndIf

  If people% <= 0 Then
    procYELLOW()
    twm.print_at(0,  8, "There is no-one left! They have all")
    twm.print_at(0,  9, "been killed off by your decisions ")
    twm.print_at(0, 10, "after only " + Str$(year%) + Choice(year% = 1, " year.", " years."))
    procSPACE()
    Exit Sub
  EndIf

  Local f1! = people% / (flood_deaths% + thief_deaths% + starvation_deaths% + 1)
  Local f2! = food% / (flood_losses% + thief_losses% + 1)
  Local msg$
  If f2! < f1! Then f1! = f2!
  If f2! < 2 Then
    msg$ = "Disastrous Losses!"
  ElseIf f1! < 4 Then
    msg$ = "Worrying losses!"
  ElseIf f1! < 8 Then
    msg$ = "You got off lightly!"
  ElseIf food% / people% < 4 Then
    msg$ = "Food supply is low."
  ElseIf food% / people% < 2 Then
    msg$ = "Starvation Imminent!"
  ElseIf was_attacked% + was_flooded% + starvation_deaths% > 0 Then
    msg$ = "Nothing to worry about."
  Else
    twm.bold(1)
    twm.print_at(1, 11, "                                      ")
    twm.print_at(1, 12, "             A quiet season           ")
    twm.print_at(1, 13, "                                      ")
    twm.bold(0)
    Pause 2000
    Exit Sub
  EndIf

  procYELLOW()
  twm.print_at(3, 2, "Village Leader's Report")

  twm.inverse(1)
  twm.print_at(13 - Len(msg$) / 2, 4, " " + msg$ + " ")
  twm.inverse(0)

  twm.print_at(0,  6, "In the " + season_name$(season%) + " Season of year " + Str$(year%))
  twm.print_at(0,  7, "of your reign, the kingdom has")
  twm.print_at(0,  8, "suffered these losses:")

  twm.print_at(0, 10, "Deaths from floods......... " + Str$(flood_deaths%))
  twm.print_at(0, 11, "Deaths from the attacks.... " + Str$(thief_deaths%))
  twm.print_at(0, 12, "Deaths from starvation..... " + Str$(starvation_deaths%))
  twm.print_at(0, 13, "Baskets of rice")
  twm.print_at(0, 14, "  lost during the floods... " + Str$(flood_losses%))
  twm.print_at(0, 15, "Baskets of rice")
  twm.print_at(0, 16, "  lost during the attacks.. " + Str$(thief_losses%))

  twm.print_at(0, 18, "The village census follows.")
  procSPACE()
End Sub

Function fnRITUAL%()
  procYELLOW()

  twm.print_at(0,  3, "We have survived for " + Str$(year%) + " years")
  twm.print_at(0,  4, "under your glorious control.")
  twm.print_at(0,  5, "By an ancient custom we must")
  twm.print_at(0,  6, "offer you the chance to lay")
  twm.print_at(0,  7, "down this terrible burden and")
  twm.print_at(0,  8, "resume a normal life.")

  twm.print_at(0, 10, "In the time honoured fashion")
  twm.print_at(0, 11, "I will now ask the ritual")
  twm.print_at(0, 12, "question:")

  Pause 2000

  twm.print_at(0, 14, "Are you prepared to accept")
  twm.print_at(0, 15, "the burden of decision again?")

  twm.print_at(0, 17, "You need only answer Yes or No")
  twm.print_at(0, 18, "for the people will understand")
  twm.print_at(0, 19, "your reasons.")

  twm.print_at(0, 21)
  fnRITUAL% = fnYESORNO%()
End Function

Sub procADDTHIEVES()
  procYELLOW()
  twm.print_at(0,  8, "Thieves have come out of the")
  twm.print_at(0,  9, "mountain to join you. They")
  twm.print_at(0, 10, "have decided that it will be")
  twm.print_at(0, 11, "easier to grow the rice than")
  twm.print_at(0, 12, "to steal it!")
  procSPACE()
  people% = people% + 50 + fnRND%(100)
End Sub

' Prompts the user to play again.
'
' @return  1 if the user wants to play again, otherwise 0.
Function fnPLAYAGAIN%()
  procYELLOW()
  twm.print_at(0,  9, "Press the ENTER key to start again.")
  twm.print_at(0, 11, "Press the ESCAPE key to leave the")
  twm.print_at(0, 12, "program.")

  procKCL()
  Do
    Select Case Inkey$
      Case Chr$(10), Chr$(13) : fnPLAYAGAIN% = 1 : Exit Function
      Case Chr$(27)           : fnPLAYAGAIN% = 0 : Exit Function
    End Select
  Loop
End Function

Sub procYELLOW()
  twm.switch(win1%)
  twm.cls()
  twm.switch(win2%)
  twm.cls()
  twm.foreground(twm.YELLOW%)
End Sub

' Waits approximately 'duration%' milliseconds for a key press.
'
' @param  duration%   milliseconds to wait.
' @param  clear_buf%  if 1 then clear the keyboard buffer first.
' @return             ASCII code of the key pressed, or -1 if none was pressed.
Function fnINKEY%(duration%, clear_buf%)
  If clear_buf% Then procKCL()

  Local i%, k$
  Do
    k$ = Inkey$
    If k$ <> "" Then Exit Do
    Pause 10
    Inc i%, 10
  Loop Until i% >= duration%
  fnINKEY% = Choice(k$ = "", -1, Asc(k$))
End Function

' Clears the keyboard buffer.
Sub procKCL()
  Do While Inkey$ <> "" : Loop
  Pause 100 ' Make sure we deal with any delayed LF following a CR.
  Do While Inkey$ <> "" : Loop
End Sub

' General purpose input routine.
Function fnGPI$(expect_num%, max_length%)
  Local x% = twm.x%, y% = twm.y%
  twm.print_at(x%, y%, String$(max_length%, " "))
  twm.print_at(x% - 1, y%, " ")
  twm.enable_cursor(1)

  procKCL()
  Local k$, kcode%

  Do
    Do : k$ = Inkey$ : Loop Until k$ <> ""
    kcode% = Asc(k$)

    Select Case kcode%
      Case 10, 13 ' Enter
        Exit Do

      Case 8, 127 ' Delete and backspace
        If fnGPI$ <> "" Then
          fnGPI$ = Left$(fnGPI$, Len(fNGPI$) - 1)
          twm.print_at(x%, y%, String$(max_length%, " "))
          twm.print_at(x% - 1, y%, " " + fnGPI$)
        EndIf

      Case < 32, > 126
        twm.bell()

      Case Else
        If expect_num% And (kcode% < 48 Or kcode% > 57) Then
          twm.bell()
        ElseIf Len(fnGPI$) = max_length% Then
          twm.bell()
        Else
          twm.print(k$)
          Cat fnGPI$, k$
        EndIf

    End Select

  Loop

  twm.enable_cursor(0)
End Function

' Gets 'Yes' / 'No' input from user.
'
' @return  1 if 'Yes', 0 if 'No'.
Function fnYESORNO%()
  Local x% = twm.x%
  Do
    twm.x% = x%
    Select Case Left$(fnGPI$(0, 3), 1)
      Case "y", "Y" : fnYESORNO% = 1 : Exit Do
      Case "n", "N" : fnYESORNO% = 0 : Exit Do
    End Select
  Loop
End Function

' Gets number input from user.
Function fnNUMINP%()
  Local x% = twm.x%, y% = twm.y%
  fnNUMINP% = Val(fnGPI$(1, 6))
  If fnNUMINP% = 0 Then twm.print_at(x%, y%, "0")
End Function

' Generates a random integer between 1 and x%.
Function fnRND%(x%)
  fnRND% = Int(Rnd() * x%) + 1
End Function
