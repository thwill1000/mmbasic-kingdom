' Yellow River Kingdom (aka Hamurabi).
' BBC Micro - Version 5 - October 1981.
' By Tom Hartley, Jerry Temple-Fry (NETHERHALL SCHOOL) and Richard G Warner.
' MMBasic 5.07 port by Thomas Hugo Williams, 2021-2023.

Option Base 0
Option Default None
Option Explicit

Const VERSION = 10100 ' 1.1.0

#Include "splib/system.inc"

'!if defined PICOMITEVGA
  '!replace { Page Copy 1 To 0 , B } { FrameBuffer Copy F , N , B }
  '!replace { Page Write 1 } { FrameBuffer Write F }
  '!replace { Page Write 0 } { FrameBuffer Write N }
  '!replace { Mode 7 } { Mode 2 : FrameBuffer Create }
'!elif defined PICOMITE
  '!replace { Page Copy 1 To 0 , B } { FrameBuffer Copy F , N }
  '!replace { Page Write 1 } { FrameBuffer Write F }
  '!replace { Page Write 0 } { FrameBuffer Write N }
  '!replace { Mode 7 } { FrameBuffer Create }
'!endif

#Include "splib/string.inc"
#Include "splib/txtwm.inc"
#Include "splib/ctrl.inc"
#Include "splib/sound.inc"
'!if defined(PGLCD) || defined(PGLCD2)
#Include "splib/gamemite.inc"
'!endif

sys.override_break("on_break")

If sys.is_device%("mmb4l") Then
  Option CodePage CMM2
  Const CTRL$ = "keys_cursor_ext"
  Const THIEF$ = "T"
  Randomize Timer
ElseIf sys.is_device%("gamemite") Then
  Const CTRL$ = "ctrl.gamemite"
  Const THIEF$ = Chr$(&h98)
  Randomize Timer
ElseIf sys.is_device%("cmm2*", "mmb4w") Then
  Option Console Serial
  Const CTRL$ = "keys_cursor_ext"
  Const THIEF$ = Chr$(&h98)
  Mode 2
  Font 4
Else
  Error "Unsupported device: " + Mm.Device$
EndIf

If CTRL$ = "keys_cursor_ext" Then
  Const START_MSG$ = "Press the SPACE BAR to play"
  Const CONTINUE_MSG$ = "Press the SPACE BAR to continue"
Else
  Const START_MSG$ = "Press START to play"
  Const CONTINUE_MSG$ = "Press A to continue"
EndIf

ctrl.init_keys()
Call CTRL$, ctrl.OPEN

Cls

twm.init(3, 4328)

If sys.is_device%("gamemite", "mmb4l") Then
  Const HEIGHT = 20
  Const WIDTH = 40
  Const win1% = twm.new_win%(0, 0, WIDTH, HEIGHT)
  Const win2% = twm.new_win%(3, 0, WIDTH - 4, HEIGHT)
  Const win_menu% = twm.new_win%(7, 4, 26, 11)
Else
  Const HEIGHT = 25
  Const WIDTH = 40
  Const win1% = twm.new_win%(11, 0, WIDTH, HEIGHT)
  Const win2% = twm.new_win%(14, 0, WIDTH - 4, HEIGHT - 1)
  Const win_menu% = twm.new_win%(17, 8, 26, 11)
EndIf

Dim season_name$(3) = ("", "Winter", "Growing", "Harvest")
Dim vx%(3) = (0, 13, 21, 22) ' Village x-coordinates
If HEIGHT = 20 Then
  Dim vy%(3) = (0, HEIGHT - 16, HEIGHT - 12, HEIGHT - 6) ' Village y-coordinates
Else
  Dim vy%(3) = (0, HEIGHT - 17, HEIGHT - 13, HEIGHT - 7) ' Village y-coordinates
EndIf
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
Dim use_keyboard% = (CTRL$ = "keys_cursor_ext") ' Use keyboard for number entry.

Dim FX_ATTACK%(sound.data_size%("attack_fx_data"))
Dim FX_FLOOD%(sound.data_size%("flood_fx_data"))
Dim MUSIC_AUTUMN_FESTIVAL%(sound.data_size%("autumn_festival_music_data"))
Dim MUSIC_MO_LI_HUA%(sound.data_size%("mo_li_hua_music_data"))
Dim music_track%

sound.load_data("attack_fx_data", FX_ATTACK%())
sound.load_data("flood_fx_data", FX_FLOOD%())
sound.load_data("autumn_festival_music_data", MUSIC_AUTUMN_FESTIVAL%())
sound.load_data("mo_li_hua_music_data", MUSIC_MO_LI_HUA%())
sound.music_tick% = 150
sound.init()
music_track% = 0 : on_music_done()

procTITLEPAGE()
procINSTRUCTIONS()

Do
  procREINIT()
  procGAMELOOP()
  procMENU(1)
Loop

procEND()

Sub procTITLEPAGE()
  procMAP()
  Pause 1000

  Const y% = Choice(HEIGHT = 20, 7, 11)
  twm.foreground(twm.YELLOW%)
  twm.bold(1)
  twm.print_at(0, y%, Space$(twm.w%))
  twm.print_at(0, y% + 1, str.centre$("YELLOW RIVER", twm.w%))
  twm.print_at(0, y% + 2, str.centre$(" KINGDOM", twm.w%))
  twm.bold(0)
  twm.print_at(0, y% + 3, str.centre$(sys.format_version$(VERSION), twm.w%))
  twm.print_at(0, y% + 4, Space$(twm.w%))
  If HEIGHT <> 20 Then twm.print_at(0, twm.h% - 2, Space$(twm.w%))
  twm.print_at(0, twm.h% - 1, str.centre$(START_MSG$, twm.w%))

  procKCL()
  Local key%
  Do
    Call CTRL$, key%
    Select Case key%
      Case 0 ' Do nothing
      Case ctrl.A, ctrl.START, ctrl.SELECT
        ' For testing purposes even when using the keyboard pressing 'E' or 'S' will
        ' cause the game to use the gamepad number entry mechanism.
        If (key% = ctrl.START) Or (key% = ctrl.SELECT) Then use_keyboard% = 0
        procOK()
        Exit Do
      Case Else
        procINVALID()
    End Select
  Loop

  twm.print_at(0, twm.h% - 1, Space$(twm.w%))

  procMENU(1)
End Sub

Sub procMENU(new_game%)
  Const old_win% = twm.id%
  twm.switch(win_menu%)
  twm.cls()
  twm.foreground(twm.YELLOW%)
  twm.box(0, 0, twm.w%, twm.h%)
  twm.bold(1)
  twm.print_at(1, 2, str.centre$("YELLOW RIVER KINGDOM", twm.w% - 2))
  twm.bold(0)

  Const x% = 5
  Local key%, sel% = 0, update% = 1

  Do
    If update% Then
      twm.inverse(sel% = 0)
      twm.print_at(x% + 3, 4, Choice(new_game%, " New Game ", " Continue "))
      twm.inverse(sel% = 1)
      twm.print_at(x% + 3, 5, "   Quit   ")
      twm.inverse(0) : twm.print_at(x%, 7, str.decode$("Music    \x95 "))
      twm.inverse(sel% = 2)
      twm.print(Choice(sound.enabled% And sound.MUSIC_FLAG%, "ON ", "OFF"))
      twm.inverse(0)
      twm.print(str.decode$(" \x94")))
      twm.inverse(0)
      twm.print_at(x%, 8, str.decode$("Sound FX \x95 "))
      twm.inverse(sel% = 3)
      twm.print(Choice(sound.enabled% And sound.FX_FLAG%, "ON ", "OFF"))
      twm.inverse(0)
      twm.print(str.decode$(" \x94")))
      update% = 0
    EndIf

    Call CTRL$, key%
    Select Case key%
      Case ctrl.A, ctrl.START
        Select Case sel%
          Case 0 : procOK() : Exit Do
          Case 1 : procOK() : procEND()
        End Select
      Case ctrl.UP
        Inc sel%, -1
        If sel% = -1 Then sel% = 0 Else update% = 1
      Case ctrl.DOWN
        Inc sel%, 1
        If sel% = 4 Then sel% = 3 Else update% = 1
      Case ctrl.LEFT, ctrl.RIGHT
        Select Case sel%
          Case 2
            If sound.enabled% And sound.MUSIC_FLAG% Then
              sound.enable(sound.enabled% Xor sound.MUSIC_FLAG%)
            Else
              sound.enable(sound.enabled% Or sound.MUSIC_FLAG%)
              on_music_done() ' Start next music track.
            EndIf
            update% = 1
          Case 3
            If sound.enabled% And sound.FX_FLAG% Then
              sound.enable(sound.enabled% Xor sound.FX_FLAG%)
            Else
              sound.enable(sound.enabled% Or sound.FX_FLAG%)
            EndIf
            update% = 1
        End Select
    End Select

    If update% Then procOK() Else If key% Then procINVALID()
  Loop

  procKCL()
  If Not new_game% Then
    twm.switch(old_win%)
    twm.redraw()
  EndIf
End Sub

Sub procMAP()
  Local y%
  twm.switch(win1%)
  twm.cls()

  ' Print river.
  twm.foreground(twm.YELLOW%)
  For y% = Choice(HEIGHT = 20, 1, 3) To HEIGHT - 2
    twm.print_at(1, y%, Chr$(219))
  Next

  ' Print dam.
  twm.foreground(twm.CYAN%)
  For y% = Choice(HEIGHT = 20, 1, 3) To HEIGHT - 2
    twm.print_at(3, y%, Chr$(221) + Chr$(221))
  Next

  ' Print mountains.
  twm.foreground(twm.RED%)
  For y% = Choice(HEIGHT = 20, 1, 3) To HEIGHT - 4 Step 2
    twm.print_at(29, y%, Chr$(222))
    twm.print_at(28, y% + 1, Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220) + "  " + Chr$(222))
    twm.print_at(33, y% + 2, Chr$(220) + Chr$(219) + Chr$(219) + Chr$(220))
  Next

  ' Print thieves.
  Local y_top% = Choice(HEIGHT = 20, HEIGHT - 12, HEIGHT - 13)
  For y% = y_top% + 1 To y_top% + 3 : twm.print_at(30, y%, "  ") : Next
  twm.print_at(32, y_top%, THIEF$)
  twm.print_at(31, y_top% + 1, THIEF$ + THIEF$)
  twm.print_at(30, y_top% + 2, "THIEVES")
  twm.print_at(31, y_top% + 3, THIEF$)
  twm.print_at(32, y_top% + 4, THIEF$)
  twm.print_at(32, y_top% + 5, THIEF$)

  ' Print villages.
  For y% = 1 To 3 : procVDRAW(y%) : Next

  twm.foreground(twm.white%)
  y% = Choice(HEIGHT = 20, 19, HEIGHT - 2)
  twm.print_at(0, y%, "   DYKE        VILLAGES      MOUNTAINS")
End Sub

Sub procVDRAW(i%)
  twm.foreground(twm.GREEN%)
  twm.print_at(vx%(i%) - 1, vy%(i%), Chr$(138) + Chr$(165))
  twm.print_at(vx%(i%) - 1, vy%(i%) + 1, Chr$(165) + Chr$(138))
End Sub

Sub procINSTRUCTIONS()
  procYELLOW()

  Const y% = Choice(HEIGHT = 20, 1, 4)
  twm.print_at(0, y%, "The kingdom is three villages. It")
  twm.print_at(0, y% + 1, "is between the Yellow River and")
  twm.print_at(0, y% + 2, "the mountains.")

  twm.print_at(0, y% + 4, "You have been chosen to take")
  twm.print_at(0, y% + 5, "all the important decisions. Your")
  twm.print_at(0, y% + 6, "poor predecessor was executed by")
  twm.print_at(0, y% + 7, "thieves who live in the nearby")
  twm.print_at(0, y% + 8, "mountains.")

  twm.print_at(0, y% + 10, "These thieves live off the ")
  twm.print_at(0, y% + 11, "villagers and often attack. The")
  twm.print_at(0, y% + 12, "rice stored in the villages must")
  twm.print_at(0, y% + 13, "be protected at all times.")

  procSPACE()

  twm.cls()

  twm.print_at(0, y% - 1, "The year consists of three long ")
  twm.print_at(0, y%,     "seasons, Winter, Growing and")
  twm.print_at(0, y% + 1, "Harvest. Rice is planted every")
  twm.print_at(0, y% + 2, "Growing Season. You must decide")
  twm.print_at(0, y% + 3, "how much is planted.")

  twm.print_at(0, y% + 5, "The river is likely to flood the")
  twm.print_at(0, y% + 6, "fields and the villages. The high")
  twm.print_at(0, y% + 7, "dyke between the river and the")
  twm.print_at(0, y% + 8, "fields must be kept up to prevent")
  twm.print_at(0, y% + 9, "a serious flood.")

  twm.print_at(0, y% + 11, "The people live off the rice that")
  twm.print_at(0, y% + 12, "they have grown. It is a very poor")
  twm.print_at(0, y% + 13, "living. You must decide what the")
  twm.print_at(0, y% + 14, "people will work at each season")
  twm.print_at(0, y% + 15, "so that they prosper under your")
  twm.print_at(0, y% + 16, "leadership.")

  procSPACE()
End Sub

Sub procSPACE()
  Const y% = Choice(HEIGHT = 20, 19, 22)
  twm.print_at(0, y%, str.centre$(CONTINUE_MSG$, twm.w% - 2))
  procKCL()
  Local key%
  Do
    Call CTRL$, key%
    Select Case key%
      Case 0 ' Do nothing
      Case ctrl.START, ctrl.A
        procOK()
        Exit Do
      Case ctrl.SELECT
        procOK()
        procMENU()
      Case Else
        procINVALID()
    End Select
  Loop
  procKCL()
  twm.print_at(0, y%, Space$(twm.w% - 2))
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

  If use_keyboard% Then
    ' Prompt for number of people to defend the dyke.
    Do
      workers% = fnNUMKEYS%(26, 14, 6)
      If workers% > people% Then procIMPOS() Else Exit Do
    Loop

    ' Prompt for number of people to work in the fields.
    If workers% = people% Then
      farmers% = 0
      twm.print_at(26, 15, "0")
    Else
      Do
        farmers% = fnNUMKEYS%(26, 15, 6)
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
        planted! = fnNUMKEYS%(26, 19, 6)
        If planted! > food% Then procIMPOS()
      Loop Until planted! <= food%
      Inc food%, -planted!
    EndIf

    procSPACE()
  Else
    Local i%, key%, cb$ = "people_change_cb"
    workers% = (people% \ 20) * 5
    farmers% = (people% \ 20) * 5
    soldiers% = (people% \ 20) * 5
    twm.print_at(28, 14, Format$(workers%, "%4g"))
    twm.print_at(28, 15, Format$(farmers%, "%4g"))
    twm.print_at(28, 16, Format$(soldiers%, "%4g"))
    Do
      Select Case i%
        Case 0 ' Workers
          workers% = fnNUMGAMEPAD%(26, 14, workers%, people% - farmers% - soldiers%, key%, cb$)
        Case 1 ' Farmers
          farmers% = fnNUMGAMEPAD%(26, 15, farmers%, people% - workers% - soldiers%, key%, cb$)
        Case 2 ' Soldiers
          soldiers% = fnNUMGAMEPAD%(26, 16, soldiers%, people% - workers% - farmers%, key%, cb$)
      End Select

      Select Case key%
        Case ctrl.A
          If workers% + farmers% + soldiers% = people% Then
            procOK()
            Exit Do
          Else
            procINVALID()
          EndIf
        Case ctrl.UP
          If i% = 0 Then procINVALID() Else Inc i%, -1
        Case ctrl.DOWN
          If i% = 2 Then procINVALID() Else Inc i%
        Case ctrl.SELECT
          procOK()
          procMENU()
        Case Else
          procINVALID()
      End Select
    Loop

    procKCL()

    If season% = 2 Then
      twm.print_at(0, 13, "How many baskets of rice will be  ")
      twm.print_at(0, 14, "planted in the fields....         ")
      twm.print_at(0, 15, "                                  ")
      twm.print_at(0, 16, "                                  ")
      planted! = Min(food% \ 3, 500)
      Do
        planted! = fnNUMGAMEPAD%(26, 14, planted!, food%, key%)
        If key% = ctrl.A And planted! > 0 Then
          procOK()
          Exit Do
        Else
          procINVALID()
        EndIf
      Loop
      Inc food%, -planted!
    EndIf

  EndIf

End Sub

Sub people_change_cb(y%, value%)
  Local remaining%
  Select Case y%
    Case 14 ' Workers
      remaining% = people% - farmers% - soldiers% - value%
    Case 15 ' Farmers
      remaining% = people% - workers% - soldiers% - value%
    Case 16 ' Soldiers
      remaining% = people% - farmers% - workers% - value%
    Case Else
      Error "Invalid state"
  End Select
  Local msg$
  Select Case remaining%
    Case 0 : msg$ = CONTINUE_MSG$
    Case 1 : msg$ = "1 unallocated villager"
    Case Else : msg$ = Str$(remaining%) + " unallocated villagers"
  End Select

  twm.print_at(0, Choice(HEIGHT = 20, 18, 21), str.centre$(msg$, twm.w% - 2))
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
  Const y% = Choice(HEIGHT = 20, 0, 1)
  twm.print_at(1,  y%, season_name$(season%) + " Season")
  twm.print_at(28, y%, "Year " + Str$(year%))
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
  If wy% < HEIGHT - 8 Then
    y% = HEIGHT - 12 : d% = -1
  Else
    y% = HEIGHT - 8 : d% = 1
  EndIf
  Local sy% = y%

  twm.foreground(twm.RED%)

  ' Move the thief vertically towards village.
  Do
    If Not sound.is_playing%(sound.FX_FLAG%) Then sound.play_fx(FX_ATTACK%())
    twm.print_at(x%, y%, " ")
    If y% = wy% Then Exit Do
    Inc y%, d%
    twm.print_at(x%, y%, THIEF$)
    Pause 50
  Loop

  ' Move the thief horizontally toward village.
  Do While x% > wx%
    If Not sound.is_playing%(sound.FX_FLAG%) Then sound.play_fx(FX_ATTACK%())
    Inc x%, -1
    twm.print_at(x%, y%, THIEF$)
    Pause 1000 * (1 - Min(0.9, (x% - wx%) / 5))
    twm.print_at(x%, y%, Choice(x% = 29, Chr$(222), " "))
  Loop

  ' Attack the village.
  twm.foreground(twm.GREEN%)
  Local i%
  For i% = 1 To 40
    If Not sound.is_playing%(sound.FX_FLAG%) Then sound.play_fx(FX_ATTACK%())
    twm.print_at(x%, y% + 1, Mid$("\|/-", 1 + i% Mod 4, 1))
    Pause 40
  Next

  procVDRAW(village%)

  twm.foreground(twm.RED%)

  ' Move the thief horizontally back to the mountains.
  Do While x% < 32
    If Not sound.is_playing%(sound.FX_FLAG%) Then sound.play_fx(FX_ATTACK%())
    twm.print_at(x%, y%, Choice(x% = 29, Chr$(222), " "))
    Inc x%
    twm.print_at(x%, y%, THIEF$)
    Pause 40
  Loop

  ' Move the thief vertically back to the mountains.
  Do While y% <> sy%
    If Not sound.is_playing%(sound.FX_FLAG%) Then sound.play_fx(FX_ATTACK%())
    twm.print_at(x%, y%, " ")
    Inc y%, -d%
    twm.print_at(x%, y%, THIEF$)
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
  sound.play_fx(FX_FLOOD%())

  Local x% = 6
  Local y% = fnRND%(8) + 10
  twm.foreground(twm.YELLOW%)
  twm.print_at(1, y%, Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219) + Chr$(219))

  Local k%, key%, v%, w1%, w2%
  fs! = fnRND%(Choice(fs! < 2.0, 2.0, 4.0))
  procKCL()
  For k% = 1 To fs! * 100
    Do
      Select Case fnRND%(4)
        Case 1 : If x% < 25 Then Inc x%     : Exit Do
        Case 2 : If x% > 6  Then Inc x%, -1 : Exit Do
        Case 3 : If y% < HEIGHT - 3 Then Inc y% : Exit Do
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

    If Not key% Then key% = fnWAITFORKEY%(100)
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
    Local y% = Choice(HEIGHT = 20, 8, 11)
    twm.bold(1)
    twm.print_at(1, y%,     "                                      ")
    twm.print_at(1, y% + 1, "             A quiet season           ")
    twm.print_at(1, y% + 2, "                                      ")
    twm.bold(0)
    Pause 2000
    Exit Sub
  EndIf

  procYELLOW()
  Const y% = Choice(HEIGHT = 20, 1, 2)
  twm.print_at(3, y%, "Village Leader's Report")

  twm.inverse(1)
  twm.print_at(13 - Len(msg$) / 2, y% + 2, " " + msg$ + " ")
  twm.inverse(0)

  twm.print_at(0, y% + 4, "In the " + season_name$(season%) + " Season of year " + Str$(year%))
  twm.print_at(0, y% + 5, "of your reign, the kingdom has")
  twm.print_at(0, y% + 6, "suffered these losses:")

  twm.print_at(0, y% + 8,  "Deaths from floods......... " + Format$(flood_deaths%, "%4g"))
  twm.print_at(0, y% + 9,  "Deaths from the attacks.... " + Format$(thief_deaths%, "%4g"))
  twm.print_at(0, y% + 10, "Deaths from starvation..... " + Format$(starvation_deaths%, "%4g"))
  twm.print_at(0, y% + 11, "Baskets of rice")
  twm.print_at(0, y% + 12, "  lost during the floods... " + Format$(flood_losses%, "%4g"))
  twm.print_at(0, y% + 13, "Baskets of rice")
  twm.print_at(0, y% + 14, "  lost during the attacks.. " + Format$(thief_losses%, "%4g"))

  twm.print_at(0, y% + 16, "The village census follows.")
  procSPACE()
End Sub

Function fnRITUAL%()
  Const y% = Choice(HEIGHT = 20, 1, 3)
  procYELLOW()

  twm.print_at(2, y%,     "We have survived for " + Str$(year%) + " years")
  twm.print_at(2, y% + 1, "under your glorious control.")
  twm.print_at(2, y% + 2, "By an ancient custom we must")
  twm.print_at(2, y% + 3, "offer you the chance to lay")
  twm.print_at(2, y% + 4, "down this terrible burden and")
  twm.print_at(2, y% + 5, "resume a normal life.")

  twm.print_at(2, y% + 7, "In the time honoured fashion")
  twm.print_at(2, y% + 8, "I will now ask the ritual")
  twm.print_at(2, y% + 9, "question:")

  Pause 2000

  twm.print_at(2, y% + 11, "Are you prepared to accept")
  twm.print_at(2, y% + 12, "the burden of decision again?")

  twm.print_at(2, y% + 14, "You need only answer Yes or No")
  twm.print_at(2, y% + 15, "for the people will understand")
  twm.print_at(2, y% + 16, "your reasons.")

  fnRITUAL% = fnYESORNO%(y% + 18)
End Function

Sub procADDTHIEVES()
  Const y% = Choice(HEIGHT = 20, 7, 8)
  procYELLOW()
  twm.print_at(0, y%,     "Thieves have come out of the")
  twm.print_at(0, y% + 1, "mountain to join you. They")
  twm.print_at(0, y% + 2, "have decided that it will be")
  twm.print_at(0, y% + 3, "easier to grow the rice than")
  twm.print_at(0, y% + 4, "to steal it!")
  procSPACE()
  people% = people% + 50 + fnRND%(100)
End Sub

Sub procYELLOW()
  twm.switch(win1%)
  twm.cls()
  twm.switch(win2%)
  twm.cls()
  twm.foreground(twm.YELLOW%)
End Sub

' Waits approximately 'duration%' milliseconds for START/SPACE/A
'
' @param  duration%   milliseconds to wait.
' @return             ctrl code of key pressed, or 0 if none was pressed.
Function fnWAITFORKEY%(duration%)
  Local expires% = Timer + duration%
  Do While Timer < expires%
    Call CTRL$, fnWAITFORKEY%
    If fnWAITFORKEY% = ctrl.A Or fnWAITFORKEY% = ctrl.START Then Exit Do
  Loop
End Function

' Clears the input buffer.
Sub procKCL()
  Pause 100 ' Make sure we deal with any delayed LF following a CR.
  ctrl.term_keys()
  Local key%
  Do : Call ctrl$, key% : Loop Until Not key%
  ctrl.init_keys()
End Sub

' General purpose keyboard input routine.
Function fnGPI$(expect_num%, max_length%)
  Local k$, kcode%, x% = twm.x%, y% = twm.y%

  twm.print_at(x%, y%, String$(max_length%, " "))
  twm.print_at(x% - 1, y%, " ")

  ctrl.term_keys() ' So we can use INKEY$
  twm.enable_cursor(1)

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
        procINVALID()

      Case Else
        If expect_num% And (kcode% < 48 Or kcode% > 57) Then
          procINVALID()
        ElseIf Len(fnGPI$) = max_length% Then
          procINVALID()
        Else
          twm.print(k$)
          Cat fnGPI$, k$
        EndIf

    End Select

  Loop

  ctrl.init_keys()
  twm.enable_cursor(0)
End Function

' Gets 'Yes' / 'No' input from user.
'
' @return  1 if 'Yes', 0 if 'No'.
Function fnYESORNO%(y%)
  procKCL()

  Local key%, update% = 1
  Do
    If update% Then
      If fnYESORNO% < 0 Then procINVALID() : fnYESORNO% = 0
      If fnYESORNO% > 1 Then procINVALID() : fnYESORNO% = 1
      If fnYESORNO% Then twm.inverse(1)
      twm.print_at(11, y%, " Yes ")
      twm.inverse(0)
      If Not fnYESORNO% Then twm.inverse(1)
      twm.print_at(18, y%, " No ")
      twm.inverse(0)
      update% = 0
    EndIf

    Call CTRL$, key%
    If key% Then
      Select Case key%
        Case 0 ' Do nothing
        Case ctrl.A, ctrl.START : Exit Function
        Case ctrl.LEFT : Inc fnYESORNO% : update% = 1
        Case ctrl.RIGHT : Inc fnYESORNO%, -1 : update% = 1
        Case ctrl.SELECT
          procOK()
          procMENU()
          key% = 0
      End Select
    Else
      If ctrl.keydown%(121) Then ' Y
        fnYESORNO% = 1
        update% = 1
      ElseIf ctrl.keydown%(110) Then ' N
        fnYESORNO% = 0
        update% = 1
      EndIf
    EndIf

    If update% Then procOK() Else If key% Then procINVALID()
  Loop

  ctrl.init_keys()
End Function

' Gets positive integer input via gamepad.
'
' @param  x%          x-coordinate to start number entry at.
' @param  y%          y-coordinate to start number entry at.
' @param  initial%    initial value.
' @param  max_value%  maximum value.
' @param  callback$   callback when value is changed.
Function fnNUMGAMEPAD%(x%, y%, initial%, max_value%, key%, callback$)
  twm.print_at(x%, y%, Chr$(&h95) + "      " + Chr$(&h94))
  Local buzz%, delta% = Choice(max_value% < 1000, 5, 25)
  Local update% = 1, value% = initial%
  key% = 0

  Do
    If update% Then
      Select Case value%
        Case < 0 : Inc buzz% : value% = 0
        Case > max_value%
          If value% - max_value% >= delta% Then Inc buzz%
          value% = max_value%
        Case Else
          If value% Mod delta% Then value% = (value% \ delta%) * delta% + delta%
          buzz% = 0
      End Select
      twm.inverse(1)
      twm.print_at(x% + 2, y%, Format$(value%, "%4g"))
      twm.inverse(0)
      If Len(callback$) Then Call callback$, y%, value%
      If buzz% >= 10 Then procINVALID() ' Don't buzz immediately the limits are hit.
      Pause 100
    EndIf

    Call CTRL$, key%
    Select Case key%
      Case 0          : update% = 0
      Case ctrl.LEFT  : Inc value%, -delta% : update% = 1
      Case ctrl.RIGHT : Inc value%, delta% : update% = 1
      Case Else       : Exit Do
    End Select
  Loop
  twm.print_at(x%, y%, "  " + Format$(value%, "%4g") + "  ")

  fnNUMGAMEPAD% = value%
End Function

' Gets positive integer input via keyboard.
'
' @param  x%          x-coordinate to start number entry at.
' @param  y%          y-coordinate to start number entry at.
' @param  max_len%    maximum number of digits.
Function fnNUMKEYS%(x%, y%, max_len%)
  twm.print_at(x%, y%)
  fnNUMKEYS% = Val(fnGPI$(1, max_len%))
  If fnNUMKEYS% = 0 Then twm.print_at(x%, y%, "0")
End Function

' Generates a random integer between 1 and x%.
Function fnRND%(x%)
  fnRND% = Int(Rnd() * x%) + 1
End Function

Sub procINVALID()
  If sys.is_device%("mmb4l") Then
    twm.bell()
  Else
    sound.play_fx(sound.FX_BLART%())
  EndIf
  Pause ctrl.UI_DELAY
End Sub

Sub procOK()
  sound.play_fx(sound.FX_SELECT%())
  Pause ctrl.UI_DELAY
End Sub

Sub on_break()
  procEND(1)
End Sub

Sub procEND(break%)
  If sys.is_device%("gamemite") Then
    gamemite.end(break%)
  Else
    ' Hide cursor, clear console, return cursor to home.
    ' Print Chr$(27) "[?25l" Chr$(27) "[2J" Chr$(27) "[H"
    End
  EndIf
End Sub

Sub on_music_done()
  If music_track% = 1 Then
    sound.music_volume% = Choice(sys.is_device%("gamemite"), 5, 10)
    sound.play_music(MUSIC_AUTUMN_FESTIVAL%(), "on_music_done")
    music_track% = 2
  Else
    sound.music_volume% = Choice(sys.is_device%("gamemite"), 10, 15)
    sound.play_music(MUSIC_MO_LI_HUA%(), "on_music_done")
    music_track% = 1
  EndIf
End Sub

attack_fx_data:
Data 48    ' Number of bytes of music data.
Data 3     ' Number of channels.
Data &h0033000000000034, &h0000003200000000, &h0000310000310000, &hFFFF000000000000
Data &hFFFFFFFFFFFFFFFF, &hFFFFFFFFFFFFFFFF

flood_fx_data:
Data 192   ' Number of bytes of music data.
Data 3     ' Number of channels.
Data &h0031000031000031, &h3200003200003100, &h0000320000320000, &h0033000033000033
Data &h3400003400003300, &h0000340000340000, &h0035000035000035, &h3600003600003500
Data &h0000360000360000, &h0037000037000037, &h3800003800003700, &h0000380000380000
Data &h0039000039000039, &h3A00003A00003900, &h00003A00003A0000, &h003B00003B00003B
Data &h3C00003C00003B00, &h00003C00003C0000, &h003D00003D00003D, &h3D00003D00003D00
Data &h00003D00003D0000, &hFFFFFFFFFF000000, &hFFFFFFFFFFFFFFFF, &hFFFFFFFFFFFFFFFF

autumn_festival_music_data:
Data 1320  ' Number of bytes of music data.
Data 3     ' Number of channels.
Data &h003C2B003E2B003E, &h3A2B373A2B003C2B, &h2B373A2B373A2B37, &h00412B00002B0000
Data &h3F2C003F2B00412B, &h2C003E2C003E2C00, &h383C2C383C2C383C, &h002C00002C383C2C
Data &h2C00002C00002C00, &h00382E003A2E003A, &h372E00372E00382E, &h2E00372E00372E00
Data &h00352E00002E0000, &h373000372E00352E, &h3000383000383000, &h0037300037300037
Data &h3A30003A30003730, &h30003A30003A3000, &h003C2B003E2B003E, &h3A2B373A2B003C2B
Data &h2B373A2B373A2B37, &h00412B00002B0000, &h3F2C003F2B00412B, &h2C003E2C003E2C00
Data &h383C2C383C2C383C, &h002C00002C383C2C, &h2C00002C00002C00, &h003F2E003E2E003E
Data &h412E3A412E003F2E, &h2E3A412E3A412E3A, &h00432E00432E0043, &h3F30003F2E00432E
Data &h30003E30003E3000, &h003C30003C30003C, &h0030000030003C30, &h3000003000003000
Data &h003C2B003E2B003E, &h3A2B373A2B003C2B, &h2B373A2B373A2B37, &h00412B00002B0000
Data &h3F2C003F2B00412B, &h2C003E2C003E2C00, &h383C2C383C2C383C, &h002C00002C383C2C
Data &h2C00002C00002C00, &h00382E003A2E003A, &h372E00372E00382E, &h2E00372E00372E00
Data &h00352E00002E0000, &h373000372E00352E, &h3000383000383000, &h0037300037300037
Data &h3A30003A30003730, &h30003A30003A3000, &h003C2B003E2B003E, &h3A2B373A2B003C2B
Data &h2B373A2B373A2B37, &h00412B00002B0000, &h3F2C003F2B00412B, &h2C003E2C003E2C00
Data &h383C2C383C2C383C, &h002C00002C383C2C, &h2C00002C00002C00, &h003F2E003E2E003E
Data &h412E3A412E003F2E, &h2E3A412E3A412E3A, &h00432E00432E0043, &h3F30003F2E00432E
Data &h30003E30003E3000, &h003C30003C30003C, &h0030000030003C30, &h3000003000003000
Data &h003C2B003E2B003E, &h3A37003A2B003C2B, &h00003C37003C3700, &h003A37003E37003E
Data &h412C004137003A37, &h2C003F2C003F2C00, &h003F38003E38003E, &h4138004100003F38
Data &h3800413800413800, &h00412E00432E0043, &h3F3A003F2E00412E, &h0000433A00433A00
Data &h00443A00463A0046, &h433000433A00443A, &h3000413000413000, &h00413C003F3C003F
Data &h3E3C003E3C00413C, &h3C00003C003E3C00, &h003C2B003E2B003E, &h3A37003A2B003C2B
Data &h00003C37003C3700, &h003A37003E37003E, &h412C004137003A37, &h2C003F2C003F2C00
Data &h003F38003E38003E, &h4138004100003F38, &h3800413800413800, &h00412E00432E0043
Data &h3F3A003F2E00412E, &h0000433A00433A00, &h00443A00463A0046, &h433000433A00443A
Data &h3000413000413000, &h00413C003F3C003F, &h3E3C003E3C00413C, &h3C003F3C003F3C00
Data &h3D00310041313D41, &h00384100313D0031, &h3844003844003841, &h44003D48003D4800
Data &h41313D413D44003D, &h313D00313D003100, &h4400384100384100, &h003D480038440038
Data &h3D44003D44003D48, &h3D002E41002E4100, &h003541002E3D002E, &h3544003544003541
Data &h44003A48003A4800, &h002E41003A44003A, &h2E3D002E3D002E41, &h4400354100354100
Data &h003A480035440035, &h3A44003A44003A48, &h3D002F3F002F3F00, &h003B3F002F3D002F
Data &h0044003B44003B3F, &h3D003B3F003B3F00, &h002F3F003B3D003B, &h2F3D002F3D002F3F
Data &h44003B3F003B3F00, &h003B3F000044003B, &h3B3D003B3D003B3F, &h3D00213F00213F00
Data &h2D283F2D213D0021, &h00440028442D283F, &h3D2D283F2D283F2D, &h00213F00283D2D28
Data &h213D00213D00213F, &h442D283F2D283F2D, &h2D283F2D00440028, &h283D2D283D2D283F
Data &h3D27203F27203F27, &h27203F27203D2720, &h204427204427203F, &h3D27203F27203F27
Data &h27203F27203D2720, &h203D27203D27203F, &h4427203F27203F27, &h27203F2720442720
Data &h203D27203D27203F, &h2400200000200000, &h0020270020240020, &h202C00202C002027
Data &h3300203000203000, &h0020380020330020, &h203A00203A002038, &h3F00203C00203C00
Data &h00204400203F0020, &h2046002046002044, &h4800204800204800, &h0020000020480020
Data &hFFFFFF0000002000

mo_li_hua_music_data:
Data 696   ' Number of bytes of music data.
Data 3     ' Number of channels.
Data &h2C35002535002535, &h35003135002C0000, &h002C38002C380031, &h313D002A3A002A3A
Data &h0000363D00310000, &h00313A00313A0036, &h2C38002538002538, &h38003138002C0000
Data &h00353A00353A0031, &h3138002C38002C38, &h3800353800313800, &h0031380031380035
Data &h2C35002535002535, &h35003135002C0000, &h002C38002C380031, &h313D002A3A002A3A
Data &h0000363D00310000, &h00313A00313A0036, &h2C38002538002538, &h38003138002C0000
Data &h00353A00353A0031, &h3138002C38002C38, &h3800353800313800, &h0031000031380035
Data &h2C38002538002538, &h38003138002C0000, &h002C00002C380031, &h2C38002938002938
Data &h35003135002C0000, &h002C38002C380031, &h313A002A3A002A3A, &h3A00363A00310000
Data &h00310000313A0036, &h3138002938002938, &h3800353800313800, &h0031380031380035
Data &h2C35002535002535, &h33002933002C3500, &h002C35002C350029, &h2A38002738002738
Data &h35002E35002A3800, &h002A33002A33002E, &h2C31002531002531, &h31002931002C0000
Data &h002C33002C330029, &h2C31002531002531, &h31002931002C3100, &h002C31002C310029
Data &h2C33002535002535, &h31003131002C3300, &h002C35002C350031, &h2C33003033003033
Data &h33003033002C3300, &h0033350033350030, &h2A38002238002238, &h3A00273A002A3800
Data &h00303D00303D0027, &h2C38002538002538, &h38003138002C3800, &h002C38002C380031
Data &h2C33002733002733, &h35003035002C3300, &h0033380033380030, &h2A35003033003033
Data &h31002E31002A3500, &h002A2E002A2E002E, &h302C002C2C002C2C, &h2C002A2C00302C00
Data &h00272C00272C002A, &h2C00002900002900, &h00003100002C0000, &h002C00002C000031
Data &h2A2E00222E00222E, &h31002E31002A2E00, &h002A31002A31002E, &h3033002733002733
Data &h3300333300303300, &h0030350030350033, &h2E33003131003131, &h31002E31002E3300
Data &h002A2E002A2E002E, &h252C00252C00252C, &h2C00252C00252C00, &h00252C00252C0025
Data &hFFFFFFFFFF000000, &hFFFFFFFFFFFFFFFF, &hFFFFFFFFFFFFFFFF
