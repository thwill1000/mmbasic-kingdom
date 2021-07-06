' Yellow River Kingdom (aka Hamurabi).
' BBC Micro - Version 5 - October 1981.
' By Tom Hartley and Jerry Temple-Fry (NETHERHALL SCHOOL) and Richard G Warner.
' Colour Maximite 2 port by Thomas Hugo Williams, 2021.

On Error Goto 50
50:
Mode 7
Cls
On Error Goto 800
procVARIABLE()
procTITLEPAGE()
procINSTRUCTIONS()
200:
F = 5000 + Rnd(2000)
P = 300 + Rnd(100)
J = 0 : S = 0
300:
S = S + 1
If S = 4 Then S = 1
J = J + 1
Y = (J - 1) DIV 3 + 1
procNEWSEASON()
For V = 1 To 3 : FL(V) = 0 : Next
TD = 0 : TF = 0 : FD = 0 : FF = 0 : VF = 0
procMAP()
procDBL(S$(S) + " Season             Year " + Str$(Y), 1, 1)
If Rnd(2) = 1 Then Goto 380
procFLOOD()
procATTACK()
Goto 400
380:
procATTACK()
procFLOOD()
400:
procCALCULATE()
procENDSEASON()
If P = 0 Or F = 0 Then Goto 500
If J Mod 12 = 0 Then procRITUAL() : If Y% = 0 Then Goto 500
If P < 200 And Rnd(3) = 1 Then procADDTHIEVES()
P = Int(P * 1.045)
Goto 300
500:
VDU 26
Cls
Print Tab(0, 9)
Print "Press the RETURN key to start again."
Print
Print "Press the ESCAPE key to leave the"
Print "program."
REPEAT Until GET$ = Chr$(13) : Goto 200
800:
If ERR <> 17 Then REPORT : Print " in line "; ERL : End
VDU 26
Cls
End

Sub procMAP()
  VDU 26
  Cls
  Print
  Print
  Print
  For I = 3 To 23
    Print Y$; W$; Chr$(&h96); "55"; Y$; Tab(27); R$
  Next
  For I = 3 To 21 Step 2
    Print Tab(27, I); R$; " x "; Tab(27, I + 1); R$; "x"; Chr$(255); "~x  x"
    Print Tab(32, I + 2); R$; "x"; Chr$(255); "~x";
  Next
  For I = 13 To 15
    Print Tab(30, I); "  "
  Next
  Print Tab(30, 14); "THIEVES"; Tab(31, 13); "TT"; Tab(31, 15); "T"; Tab(32, 16); "T"; Tab(32, 17); "T"
  Print Tab(0, 23); "   DYKE        VILLAGES      MOUNTAINS";
  For V = 1 To 3
    procVDRAW(V)
  Next
End Sub

Sub procVDRAW(V)
  Print Tab(VX(V) - 2, VY(V)); V$; "^&"; Y$ Tab(VX(V) - 2, VY(V) + 1); V$; "&^"; Y$
End Sub

Sub procINSTRUCTIONS()
  procYELLOW()
  Print
  Print
  Print
  Print
  Print "The kingdom is three villages. It"
  Print "is between the Yellow River and"
  Print "the mountains."
  Print
  Print "You have been chosen to take"
  Print "all the important decisions. Your "
  Print "poor predecessor was executed by"
  Print "thieves who live in the nearby"
  Print "mountains."
  Print
  Print "These thieves live off the "
  Print "villagers and often attack. The"
  Print "rice stored in the villages must"
  Print "be protected at all times."
  procSPACE()
  Cls
  Print
  Print
  Print
  Print "The year consists of three long "
  Print "seasons, Winter, Growing and"
  Print "Harvest. Rice is planted every"
  Print "Growing Season. You must decide"
  Print "how much is planted."
  Print
  Print "The river is likely to flood the"
  Print "fields and the villages. The high"
  Print "dyke between the river and the"
  Print "fields must be kept up to prevent"
  Print "a serious flood."
  Print
  Print "The people live off the rice that"
  Print "they have grown. It is a very poor"
  Print "living. You must decide what the"
  Print "people will work at each season"
  Print "so that they prosper under your"
  Print "leadership."
  procSPACE()
End Sub

Sub procNEWSEASON()
  procYELLOW()
  Print Tab(8, 1); "Census Results"
  Print
  If J = 1 Then Goto 3050
  Print "At the start of the "; S$(S); " Season"
  Print "of year "; Y; " of your reign this is"
  Print "the situation."
  Goto 3100
3050:
  Print "You have inherited this situation"
  Print "from your unlucky predecessor. It"
  Print "is the start of the Winter Season."
3100:
  Print
  Print "Allowing for births and deaths,"
  Print "the population is "; P; ". "
  Print
  Print "There are "; F; " baskets of rice"
  Print "in the village stores."
  Print
  Print "How many people should:"
  Print " A) Defend the dyke......"
  Print " B) Work in the fields..."
  Print " C) Protect the villages."
  QU = 14
  A = 0
3210:
  Print Tab(26, QU);
  NI = FNNUMINP
  If A + NI > P Then procIMPOS() : Goto 3210
  QU = QU + 1
  If QU = 16 Then B = NI : Goto 3260
  A = NI
  If A < P Then Goto 3210
  B = 0
  Print Tab(26, QU); B
  QU = 16
3260:
  C = P - (A + B)
  Print Tab(26, QU); C
  If S <> 2 Then Goto 3390
  Print
  Print "How many baskets of rice will be"
  Print "planted in the fields....."
3330:
  Print Tab(26, 19);
  G = fnNUMINP()
  If G > F Then procIMPOS() : Goto 3330
  F = F - G
3390:
  procSPACE()
End Sub

Sub procENDSEASON()
  procWAIT(1)
  If F > 0 Then Goto 3600
  Cls
  Print Tab(3, 7); "There was no food left.All of the"
  Print "   people have run off and joined up"
  Print "   with the thieves after "; J; " seasons"
  Print "   of your misrule"
  procSPACE()
  Exit Sub
3600:
  If P > 0 Then Goto 3700
  Cls
  Print Tab(2, 8); "There is no-one left! They have all"
  Print "  been killed off by your decisions "
  Print "  after only "; Y; " year";
  If Y <> 1 Then Print "s";
  Print "."
  procSPACE()
  Exit Sub
3700:
  F1 = P / (FD + TD + ST + 1)
  F2 = F / (TF + FF + 1)
  If F2 < F1 Then F1 = F2
  If F2 < 2 Then T$ = "Disastrous Losses!" : Goto 3800
  If F1 < 4 Then T$ = "Worrying losses!" : Goto 3800
  If F1 < 8 Then T$ = "You got off lightly!" : Goto 3800
  If F / P < 4 Then T$ = "Food supply is low." : Goto 3800
  If F / P < 2 Then T$ = "Starvation Imminent!" : Goto 3800
  If ZA + ZF + ST > 0 Then T$ = "Nothing to worry about." : Goto 3800
  procDBL("             A quiet season           ", 1, 11)
  procWAIT(2)
  Exit Sub
3800:
  procYELLOW()
  Print Tab(3, 2); "Village Leader's Report"
  Print
  Print Tab(15 - Len(T$) / 2); Chr$(&h88); T$
  Print
  Print "In the "; S$(S); " Season of year "; Y
  Print "of your reign, the kingdom has"
  Print "suffered these losses:"
  Print
  Print "Deaths from floods.........."; FD
  Print "Deaths from the attacks....."; TD
  Print "Deaths from starvation......"; ST
  Print "Baskets of rice"
  Print "lost during the floods......"; FF
  Print "Baskets of rice"
  Print "lost during the attacks....."; TF
  Print
  Print "The village census follows."
  procSPACE()
End Sub

Sub procADDTHIEVES()
  procYELLOW()
  Print Tab(0, 8)
  Print "Thieves have come out of the"
  Print "mountain to join you. They"
  Print "have decided that it will be"
  Print "easier to grow the rice than"
  Print "to steal it!"
  procSPACE()
  P = P + 50 + Rnd(100)
End Sub

Sub procRITUAL()
  procYELLOW()
  Print
  Print
  Print
  Print "We have survived for "; Y; " years"
  Print "under your glorious control."
  Print "By an ancient custom we must"
  Print "offer you the chance to lay"
  Print "down this terrible burden and"
  Print "resume a normal life."
  Print
  Print "In the time honoured fashion"
  Print "I will now ask the ritual"
  Print "question:"
  Print
  procWAIT(5)
  Print "Are you prepared to accept"
  Print "the burden of decision againPrint"
  Print
  Print "You need only answer Yes or No"
  Print "for the people will understand"
  Print "your reasons."
4670:
  Print Tab(0, 21);
  procYESORNO()
  If Y% < 0 Then Goto 4670
End Sub

Sub procATTACK()
  Local X, Y, I
  ZA = 0 : R = Rnd(1) : On S Goto 5030, 5040, 5050
5030:
  If R < .5 Then Exit Sub Else Goto 5060
5040:
  If R < .2 Then Exit Sub Else Goto 5060
5050:
  If R < .6 Then Exit Sub Else Goto 5060
5060:
  ZA = 1
  If VF = 3 Then Exit Sub
5100:
  V = Rnd(3)
  If FL(V) = 1 Then Goto 5100
  X = 32
  WX = VX(V)
  WY = VY(V) - 1
  If WY < 17 Then Y = 13 : D = -1 Else Y = 17 : D = 1
  SY = Y
5140:
  Print Tab(X, Y); " "
  If Y = WY Then Goto 5160
  Y = Y + D
  Print Tab(X, Y); "T"
  procWAIT(.05)
  Goto 5140
5160:
  X = X - 1
  Print Tab(X - 1, Y); R$; "T"
  procWAIT(1 - (X - WX) / 5)
  Print Tab(X, Y);
  If X = 29 Then Print "x" Else Print " "
  If X > WX Then Goto 5160
  For I = 1 To 99
    Print Tab(X, Y + 1); Chr$(Rnd(94) + 32)
  Next
  procVDRAW(V)
5300:
  X = X + 1
  If X < 27 Then Print Tab(X - 2, Y); " "
  If X = 31 Then Print Tab(29, Y); "x"
  Print Tab(X - 1, Y); R$; "T"
  procWAIT(.04)
  If X < 32 Then Goto 5300
5340:
  If Y = SY Then Goto 5400
  Print Tab(X, Y); " "
  Y = Y - D
  Print Tab(X, Y); "T"
  procWAIT(.05)
  Goto 5340
5400:
  On S Goto 5410, 5420, 5430
5410:
  I = 200 + Rnd(70) - C
  Goto 5440
5420:
  I = 30 + Rnd(200) - C
  Goto 5440
5430:
  I = Rnd(400) - C
5440:
  I = Int(I)
  If I < 0 Then I = 0
  TD = Int(C * I / 400)
  C = C - TD
  TF = Int(I * F / 729 + Rnd(2000 - C) / 10)
  If TF < 0 Then TF = 0
  If TF > 2000 Then TF = 1900 + Rnd(200)
  F = F - TF
End Sub

Sub procFLOOD()
  Local X, Y
  ZF = 0
  On S Goto 5530, 5540, 5550
5530:
  FS = Rnd(330) / (A + 1)
  Goto 5560
5540:
  FS = (Rnd(100) + 60) / (A + 1)
  Goto 5560
5550:
  Exit Sub
5560:
  If FS < 1 Then Exit Sub
  X = 6
  ZF = 1
  Y = Rnd(8) + 10
  If FS < 2 Then FS = Rnd(2) Else FS = Rnd(4)
  Print Tab(1, Y); W$; W$; W$; W$; W$; W$
  For K = 1 To FS * 100
    On Rnd(4) Goto 5630, 5640, 5650, 5660
5630:
    If X = 25 Then Goto 5620 Else X = X + 1 : Goto 5700
5640:
    If X = 6 Then Goto 5620 Else X = X - 1 : Goto 5700
5650:
    If Y = 22 Then Goto 5620 Else Y = Y + 1 : Goto 5700
5660:
    If Y = 3 Then Goto 5620 Else Y = Y - 1 : Goto 5700
5700:
    V = 1
5720:
    W1 = VX(V) - X
    W2 = Y - VY(V)
    If W2 <> 1 And W2 <> 0 Then Goto 5760
    If W1 = 0 Or W1 = 1 Then FL(V) = 1
    If W1 = -1 Then Goto 5780
5760:
    V = V + 1
    If V < 4 Then Goto 5720
    Print Tab(X, Y); W$
  Next K
  VF = FL(1) + FL(2) + FL(3)
  OP = A + B + C
  A = Int((A / 10) * (10 - FS))
  B = Int((B / 10) * (10 - FS))
  C = Int((C / 6) * (6 - VF))
  FF = Int(F * VF / 6)
  F = F - FF
  FD = OP - A - B - C
  If S = 2 Then G = G * (20 - FS) / 20
  If S = 3 Then G = G * (10 - FS) / 10
End Sub

Sub procCALCULATE()
  If B = 0 Then G = 0 : Goto 6100
  On S Goto 6100, 6030, 6050
6030:
  If G > 1000 Then G = 1000
  G = G * (B - 10) / B
  Goto 6100
6050:
  If G < 0 Then Goto 6100
  G = 18 * (11 + Rnd(3)) * (0.05 - 1 / B) * G
  If G < 0 Then Goto 6100
  F = F + Int(G)
6100:
  ST = 0
  P = A + B + C
  If P = 0 Then Goto 6299
  T = F / P
  If T > 5 Then T = 4 : Goto 6200
  If T < 2 Then P = 0 : Goto 6299
  If T > 4 Then T = 3.5 : Goto 6200
  ST = Int(P * (7 - T) / 7)
  T = 3
6200:
  P = P - ST
  F = Int(F - P * T - ST * T / 2)
  If F < 0 Then F = 0
6299:
End Sub

Sub procVARIABLE()
  Dim S$(3), VX(3), VY(3), FL(3)
  S$(1) = "Winter"
  S$(2) = "Growing"
  S$(3) = "Harvest"
  W$ = Chr$(255)
  Y$ = Chr$(&h93)
  R$ = Chr$(&h91)
  V$ = Chr$(&h92)
  VX(1) = 13
  VY(1) = 8
  VX(2) = 21
  VY(2) = 12
  VX(3) = 22
  VY(3) = 18
End Sub

Sub procIMPOS()
  Print Tab(4, 20); Chr$(&h88); Chr$(&h82); "I M P O S S I B L E"
  procWAIT(2)
  procSPACE()
  Print Tab(5, 20); Space$(20); Tab(0, 22); Space$(40)
End Sub

Sub procYELLOW()
  Local I
  Cls
  For I = 0 To 24
    Print Tab(0, I); Chr$(&h83);
  Next
  Print Tab(0, 0);
  VDU 28, 3, 24, 39, 0
End Sub

Sub procDBL(X$, X, Y)
  Print Tab(X - 1, Y); Chr$(141); X$
  Print Tab(X - 1, Y + 1); Chr$(141); X$
End Sub

Sub procWAIT(X)
  Local Z
  Z = TIME
  REPEAT Until TIME - Z > X * 100
End Sub

Sub procSPACE()
  Print Tab(0, 22); "Press the SPACE BAR to continue";
  procKCL()
  REPEAT Until GET$ = " "
End Sub

Sub procTITLEPAGE()
  procMAP()
  procOFF()
  procWAIT(2)
  Print Tab(0, 11); Space$(200)
  procDBL(Y$ + "YELLOW RIVER", 11, 11)
  procDBL(Y$ + "KINGDOM", 13, 14)
  I% = INKEY(500)
End Sub

Sub procKCL()
8810:
  If Inkey$(0) > "" Then Goto 8810
End Sub

Sub procOFF()
  VDU 23; 8202; 0; 0; 0;
End Sub

Sub procON()
  VDU 23; 29194; 0; 0; 0;
End Sub

' General purpose input routine.
Sub procGPI(F2, ML)
  Local B, B$
  A$ = ""
  Print String$(ML, " "); String$(ML + 1, Chr$(8)); Chr$(&h83);
  procON()
  procKCL()
9040:
  B$ = GET$
  B = Asc(B$)
  If B = 13 Then Goto 9190
  If (B = 127 Or B = 8) And A$ = "" Then Goto 9040
  If (B = 127 Or B = 8) Then A$ = Left$(A$, Len(A$) - 1) : Print B$; " "; B$; : Goto 9040
  If Len(A$) = ML Or B < 32 Or B > 126 Then Goto 9170
  If F2 = 0 Or B = 32 Or (B >= 48 And B <= 57) Then Goto 9180
9170:
  VDU 7
  Goto 9040
9180:
  Print B$;
  A$ = A$ + B$
  Goto 9040
9190:
  procOFF()
End Sub

Sub procYESORNO()
  Local B$
  procGPI(0, 3)
  B$ = Left$(A$, 1)
  Y% = -1
  If B$ = "Y" Or B$ = "y" Then Y% = 1
  If B$ = "N" Or B$ = "n" Then Y% = 0
End Sub

Function fnNUMINP()
  procGPI(1, 6)
  fnNUMINP = Val(A$)
End Function
