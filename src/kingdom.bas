' Transpiled on 06-07-2021 18:48:33

' Input file for 'sptrans' to convert/format BBC Basic.

' PROCESSED: !indent 2
' PROCESSED: !spacing generous
' PROCESSED: !empty-lines 1
' PROCESSED: !replace { DEF PROC%% } { Sub proc%1 }
' PROCESSED: !replace { DEF FN%% } { Function fn%1 }
' PROCESSED: !replace { PROC%% } { proc%1 }
' PROCESSED: !replace { : ENDPROC } { : Exit Sub }
' PROCESSED: !replace { THEN ENDPROC } { Then Exit Sub }
' PROCESSED: !replace ENDPROC { End Sub }
' PROCESSED: !replace GOTO%d { Goto %1 }
' PROCESSED: !replace { THEN %d } { Then Goto %1 }
' PROCESSED: !replace { ELSE %d } { Else Goto %1 }
' PROCESSED: !replace { PRINT '%% } { ? : ? %1 }
' PROCESSED: !replace '%% { : ? %1 }
' PROCESSED: !replace REM%% {' %1 }
' PROCESSED: !replace { Spc ( } { Space$ ( }
' PROCESSED: !replace &%d &h%1
' BEGIN:     #Include "kingdom.bas" --------------------------------------------
    10 ' KINGDOM/Yellow River Kingdom
    12 ' Program by Tom Hartley and Jerry Temple-Fry (NETHERHALL SCHOOL) and Richard G Warner
    13 ' Version 5 - October 1981
    14 ' For BBC Model A Microcomputer 16K Minimum
    40 On Error Goto 50
    50 Mode 7
    60 Cls : On Error Goto 800
   100 procVARIABLE : procTITLEPAGE
   110 procINSTRUCTIONS
   200 F = 5000 + Rnd(2000)
   210 P = 300 + Rnd(100)
   220 J = 0 : S = 0
   300 S = S + 1 : If S = 4 Then S = 1
   310 J = J + 1 : Y = (J - 1) DIV 3 + 1
   320 procNEWSEASON
   330 For V = 1 To 3 : FL(V) = 0 : Next
   340 TD = 0 : TF = 0 : FD = 0 : FF = 0 : VF = 0
   350 procMAP : procDBL(S$(S) + " Season             Year " + Str$(Y), 1, 1)
   360 If Rnd(2) = 1 Then Goto 380
   370 procFLOOD : procATTACK : Goto 400
   380 procATTACK : procFLOOD
   400 procCALCULATE
   410 procENDSEASON
   440 If P = 0 Or F = 0 Then Goto 500
   450 If J Mod 12 = 0 Then procRITUAL : If Y% = 0 Then Goto 500
   460 If P < 200 And Rnd(3) = 1 Then procADDTHIEVES
   470 P = Int(P * 1.045) : Goto 300
   500 VDU 26 : Cls : Print Tab(0, 9)
   510 Print "Press the RETURN key to start again." : ?
   520 Print "Press the ESCAPE key to leave the" : ? "program."
   530 REPEAT Until GET$ = Chr$(13) : Goto 200
   800 If ERR <> 17 Then REPORT : Print " in line "; ERL : End
   900 VDU 26 : Cls
   910 End
  1000 Sub procMAP
  1010   VDU 26 : Cls : ? : ? : ?
  1020   For I = 3 To 23
  1030     Print Y$; W$; Chr$(&h96); "55"; Y$; Tab(27); R$
  1040   Next
  1050   For I = 3 To 21 Step 2
  1060     Print Tab(27, I); R$; " x "; Tab(27, I + 1); R$; "x"; Chr$(255); "~x  x"
  1070     Print Tab(32, I + 2); R$; "x"; Chr$(255); "~x";
  1080   Next
  1100   For I = 13 To 15 : Print Tab(30, I); "  "
  1110   Next
  1120   Print Tab(30, 14); "THIEVES"; Tab(31, 13); "TT"; Tab(31, 15); "T"; Tab(32, 16); "T"; Tab(32, 17); "T"
  1200   Print Tab(0, 23); "   DYKE        VILLAGES      MOUNTAINS";
  1210   For V = 1 To 3 : procVDRAW(V) : Next
  1299 End Sub

  1500 Sub procVDRAW(V)
  1510   Print Tab(VX(V) - 2, VY(V)); V$; "^&"; Y$ Tab(VX(V) - 2, VY(V) + 1); V$; "&^"; Y$
  1599 End Sub

  2000 Sub procINSTRUCTIONS
  2010   procYELLOW : ? : ? : ? : ?
  2020   Print "The kingdom is three villages. It" : ? "is between the Yellow River and" : ? "the mountains."
  2030   ? : ? "You have been chosen to take" : ? "all the important decisions. Your " : ? "poor predecessor was executed by" : ? "thieves who live in the nearby" : ? "mountains."
  2040   ? : ? "These thieves live off the " : ? "villagers and often attack. The" : ? "rice stored in the villages must" : ? "be protected at all times."
  2090   procSPACE
  2100   Cls : ? : ? : ?
  2110   Print "The year consists of three long " : ? "seasons, Winter, Growing and" : ? "Harvest. Rice is planted every" : ? "Growing Season. You must decide" : ? "how much is planted."
  2120   ? : ? "The river is likely to flood the" : ? "fields and the villages. The high" : ? "dyke between the river and the" : ? "fields must be kept up to prevent" : ? "a serious flood."
  2130   ? : ? "The people live off the rice that" : ? "they have grown. It is a very poor" : ? "living. You must decide what the" : ? "people will work at each season" : ? "so that they prosper under your" : ? "leadership."
  2190   procSPACE
  2199 End Sub

  3000 Sub procNEWSEASON
  3010   procYELLOW : Print Tab(8, 1); "Census Results" : ? : If J = 1 Then 3050
  3020   Print "At the start of the "; S$(S); " Season"
  3030   Print "of year "; Y; " of your reign this is"
  3040   Print "the situation." : Goto 3100
  3050   Print "You have inherited this situation"
  3060   Print "from your unlucky predecessor. It"
  3070   Print "is the start of the Winter Season."
  3100   ? : ? "Allowing for births and deaths,"
  3110   Print "the population is "; P; ". " : ?
  3120   Print "There are "; F; " baskets of rice"
  3130   Print "in the village stores."
  3140   ? : ? "How many people should:"
  3150   Print " A) Defend the dyke......"
  3160   Print " B) Work in the fields..."
  3170   Print " C) Protect the villages."
  3200   QU = 14 : A = 0
  3210   Print Tab(26, QU); : NI = FNNUMINP
  3220   If A + NI > P Then procIMPOS : Goto 3210
  3230   QU = QU + 1 : If QU = 16 Then B = NI : Goto 3260
  3240   A = NI : If A < P Then Goto 3210
  3250   B = 0 : Print Tab(26, QU); B : QU = 16
  3260   C = P - (A + B) : Print Tab(26, QU); C
  3300   If S <> 2 Then Goto 3390
  3310   ? : ? "How many baskets of rice will be"
  3320   Print "planted in the fields....."
  3330   Print Tab(26, 19); : G = FNNUMINP
  3340   If G > F Then procIMPOS : Goto 3330
  3350   F = F - G
  3390   procSPACE
  3399 End Sub

  3500 Sub procENDSEASON
  3510   procWAIT(1)
  3520   If F > 0 Then Goto 3600
  3530   Cls : Print Tab(3, 7); "There was no food left.All of the"
  3540   Print "   people have run off and joined up"
  3550   Print "   with the thieves after "; J; " seasons"
  3560   Print "   of your misrule" : procSPACE : Exit Sub
  3600   If P > 0 Then Goto 3700
  3610   Cls : Print Tab(2, 8); "There is no-one left! They have all"
  3620   Print "  been killed off by your decisions "
  3630   Print "  after only "; Y; " year"; : If Y <> 1 Then Print "s";
  3640   Print "." : procSPACE : Exit Sub
  3700   F1 = P / (FD + TD + ST + 1) : F2 = F / (TF + FF + 1) : If F2 < F1 Then F1 = F2
  3720   If F2 < 2 Then T$ = "Disastrous Losses!" : Goto 3800
  3730   If F1 < 4 Then T$ = "Worrying losses!" : Goto 3800
  3740   If F1 < 8 Then T$ = "You got off lightly!" : Goto 3800
  3750   If F / P < 4 Then T$ = "Food supply is low." : Goto 3800
  3760   If F / P < 2 Then T$ = "Starvation Imminent!" : Goto 3800
  3770   If ZA + ZF + ST > 0 Then T$ = "Nothing to worry about." : Goto 3800
  3780   procDBL("             A quiet season           ", 1, 11)
  3790   procWAIT(2) : Exit Sub
  3800   procYELLOW : Print Tab(3, 2); "Village Leader's Report"
  3810   ? : ? Tab(15 - Len(T$) / 2); Chr$(&h88); T$
  3820   ? : ? "In the "; S$(S); " Season of year "; Y
  3830   Print "of your reign, the kingdom has"
  3840   Print "suffered these losses:" : ?
  3900   Print "Deaths from floods.........."; FD
  3910   Print "Deaths from the attacks....."; TD
  3920   Print "Deaths from starvation......"; ST
  3930   Print "Baskets of rice" : ? "lost during the floods......"; FF
  3940   Print "Baskets of rice" : ? "lost during the attacks....."; TF
  3950   ? : ? "The village census follows."
  3990   procSPACE
  3999 End Sub

  4000 Sub procADDTHIEVES
  4010   procYELLOW : Print Tab(0, 8)
  4020   Print "Thieves have come out of the"
  4030   Print "mountain to join you. They"
  4040   Print "have decided that it will be"
  4050   Print "easier to grow the rice than"
  4060   Print "to steal it!" : procSPACE
  4070   P = P + 50 + Rnd(100)
  4099 End Sub

  4500 Sub procRITUAL
  4510   procYELLOW : ? : ? : ?
  4520   Print "We have survived for "; Y; " years"
  4530   Print "under your glorious control."
  4540   Print "By an ancient custom we must"
  4550   Print "offer you the chance to lay"
  4560   Print "down this terrible burden and"
  4570   Print "resume a normal life."
  4600   ? : ? "In the time honoured fashion"
  4610   Print "I will now ask the ritual"
  4620   Print "question:" : ? : PROCWAIT(5)
  4630   Print "Are you prepared to accept"
  4640   Print "the burden of decision again?" : ?
  4650   Print "You need only answer Yes or No"
  4660   Print "for the people will understand" : ? "your reasons."
  4670   Print Tab(0, 21); : procYESORNO : If Y% < 0 Then Goto 4670
  4699 End Sub

  5000 Sub procATTACK
  5010   Local X, Y, I
  5020   ZA = 0 : R = Rnd(1) : On S Goto 5030, 5040, 5050
  5030   If R < .5 Then Exit Sub Else Goto 5060
  5040   If R < .2 Then Exit Sub Else Goto 5060
  5050   If R < .6 Then Exit Sub Else Goto 5060
  5060   ZA = 1
  5070   If VF = 3 Then Exit Sub
  5100   V = Rnd(3) : If FL(V) = 1 Then Goto 5100
  5110   X = 32 : WX = VX(V) : WY = VY(V) - 1
  5120   If WY < 17 Then Y = 13 : D = -1 Else Y = 17 : D = 1
  5130   SY = Y
  5140   Print Tab(X, Y); " " : If Y = WY Then Goto 5160
  5150   Y = Y + D : Print Tab(X, Y); "T" : procWAIT(.05) : Goto 5140
  5160   X = X - 1 : Print Tab(X - 1, Y); R$; "T" : procWAIT(1 - (X - WX) / 5)
  5170   Print Tab(X, Y); : If X = 29 Then Print "x" Else Print " "
  5180   If X > WX Then Goto 5160
  5200   For I = 1 To 99
  5210     Print Tab(X, Y + 1); Chr$(Rnd(94) + 32) : Next
  5220   procVDRAW(V)
  5300   X = X + 1 : If X < 27 Then Print Tab(X - 2, Y); " "
  5310   If X = 31 Then Print Tab(29, Y); "x"
  5320   Print Tab(X - 1, Y); R$; "T" : procWAIT(.04)
  5330   If X < 32 Then Goto 5300
  5340   If Y = SY Then Goto 5400
  5350   Print Tab(X, Y); " " : Y = Y - D : Print Tab(X, Y); "T" : procWAIT(.05) : Goto 5340
  5400   On S Goto 5410, 5420, 5430
  5410   I = 200 + Rnd(70) - C : Goto 5440
  5420   I = 30 + Rnd(200) - C : Goto 5440
  5430   I = Rnd(400) - C
  5440   I = Int(I) : If I < 0 Then I = 0
  5450   TD = Int(C * I / 400) : C = C - TD
  5460   TF = Int(I * F / 729 + Rnd(2000 - C) / 10) : If TF < 0 Then TF = 0
  5470   If TF > 2000 Then TF = 1900 + Rnd(200)
  5480   F = F - TF
  5499 End Sub

  5500 Sub procFLOOD
  5510   Local X, Y
  5520   ZF = 0 : On S Goto 5530, 5540, 5550
  5530   FS = Rnd(330) / (A + 1) : Goto 5560
  5540   FS = (Rnd(100) + 60) / (A + 1) : Goto 5560
  5550 End Sub

  5560 If FS < 1 Then Exit Sub
  5570 X = 6 : ZF = 1 : Y = Rnd(8) + 10 : If FS < 2 Then FS = Rnd(2) Else FS = Rnd(4)
  5600 Print Tab(1, Y); W$; W$; W$; W$; W$; W$
  5610 For K = 1 To FS * 100
  5620   On Rnd(4) Goto 5630, 5640, 5650, 5660
  5630   If X = 25 Then Goto 5620 Else X = X + 1 : Goto 5700
  5640   If X = 6 Then Goto 5620 Else X = X - 1 : Goto 5700
  5650   If Y = 22 Then Goto 5620 Else Y = Y + 1 : Goto 5700
  5660   If Y = 3 Then Goto 5620 Else Y = Y - 1 : Goto 5700
  5700   V = 1
  5720   W1 = VX(V) - X : W2 = Y - VY(V)
  5730   If W2 <> 1 And W2 <> 0 Then Goto 5760
  5740   If W1 = 0 Or W1 = 1 Then FL(V) = 1
  5750   If W1 = -1 Then Goto 5780
  5760   V = V + 1 : If V < 4 Then Goto 5720
  5770   Print Tab(X, Y); W$
  5780 Next K
  5790 VF = FL(1) + FL(2) + FL(3)
  5800 OP = A + B + C
  5810 A = Int((A / 10) * (10 - FS))
  5820 B = Int((B / 10) * (10 - FS))
  5830 C = Int((C / 6) * (6 - VF))
  5840 FF = Int(F * VF / 6) : F = F - FF
  5850 FD = OP - A - B - C
  5860 If S = 2 Then G = G * (20 - FS) / 20
  5870 If S = 3 Then G = G * (10 - FS) / 10
  5899 End Sub

  6000 Sub procCALCULATE
  6010   If B = 0 Then G = 0 : Goto 6100
  6020   On S Goto 6100, 6030, 6050
  6030   If G > 1000 Then G = 1000
  6040   G = G * (B - 10) / B : Goto 6100
  6050   If G < 0 Then Goto 6100
  6060   G = 18 * (11 + Rnd(3)) * (0.05 - 1 / B) * G
  6070   If G < 0 Then Goto 6100
  6080   F = F + Int(G)
  6100   ST = 0 : P = A + B + C : If P = 0 Then Goto 6299
  6110   T = F / P : If T > 5 Then T = 4 : Goto 6200
  6120   If T < 2 Then P = 0 : Goto 6299
  6130   If T > 4 Then T = 3.5 : Goto 6200
  6140   ST = Int(P * (7 - T) / 7) : T = 3
  6200   P = P - ST : F = Int(F - P * T - ST * T / 2)
  6210   If F < 0 Then F = 0
  6299 End Sub

  7000 Sub procVARIABLE
  7010   Dim S$(3), VX(3), VY(3), FL(3)
  7020   S$(1) = "Winter" : S$(2) = "Growing" : S$(3) = "Harvest"
  7040   W$ = Chr$(255) : Y$ = Chr$(&h93) : R$ = Chr$(&h91) : V$ = Chr$(&h92)
  7050   VX(1) = 13 : VY(1) = 8
  7060   VX(2) = 21 : VY(2) = 12
  7070   VX(3) = 22 : VY(3) = 18
  7099 End Sub

  7100 Sub procIMPOS
  7110   Print Tab(4, 20); Chr$(&h88); Chr$(&h82); "I M P O S S I B L E"
  7120   procWAIT(2)
  7130   procSPACE
  7140   Print Tab(5, 20); Space$(20); Tab(0, 22); Space$(40)
  7199 End Sub

  7200 Sub procYELLOW
  7210   Local I
  7220   Cls : For I = 0 To 24
  7230     Print Tab(0, I); Chr$(&h83); : Next
  7240   Print Tab(0, 0);
  7250   VDU 28, 3, 24, 39, 0
  7299 End Sub

  8000 Sub procDBL(X$, X, Y)
  8010   Print Tab(X - 1, Y); Chr$(141); X$
  8020   Print Tab(X - 1, Y + 1); Chr$(141); X$
  8099 End Sub

  8100 Sub procWAIT(X)
  8110   Local Z
  8120   Z = TIME
  8130   REPEAT Until TIME - Z > X * 100
  8199 End Sub

  8200 Sub procSPACE
  8220   Print Tab(0, 22); "Press the SPACE BAR to continue"; : procKCL
  8240   REPEAT Until GET$ = " "
  8299 End Sub

  8300 Sub procTITLEPAGE
  8310   procMAP : procOFF : procWAIT(2) : Print Tab(0, 11); Space$(200)
  8315   procDBL(Y$ + "YELLOW RIVER", 11, 11) : procDBL(Y$ + "KINGDOM", 13, 14)
  8320   I% = INKEY(500)
  8399 End Sub

  8800 Sub procKCL
  8810   If Inkey$(0) > "" Then Goto 8810
  8899 End Sub

  8900 Sub procOFF
  8910   VDU 23; 8202; 0; 0; 0;
  8915 End Sub

  8950 Sub procON
  8960   VDU 23; 29194; 0; 0; 0;
  8965 End Sub

  9000 Sub procGPI(F2, ML) : ' General Purpose Input Routine
  9010   Local B, B$
  9020   A$ = ""
  9030   Print String$(ML, " "); String$(ML + 1, Chr$(8)); Chr$(&h83); : procON : procKCL
  9040   B$ = GET$ : B = Asc(B$) : If B = 13 Then Goto 9190
  9050   If (B = 127 Or B = 8) And A$ = "" Then Goto 9040
  9060   If (B = 127 Or B = 8) Then A$ = Left$(A$, Len(A$) - 1) : Print B$; " "; B$; : Goto 9040
  9070   If Len(A$) = ML Or B < 32 Or B > 126 Then Goto 9170
  9080   If F2 = 0 Or B = 32 Or (B >= 48 And B <= 57) Then Goto 9180
  9170   VDU 7 : Goto 9040
  9180   Print B$; : A$ = A$ + B$ : Goto 9040
  9190   procOFF
  9199 End Sub

  9200 Sub procYESORNO
  9210   Local B$
  9220   procGPI(0, 3)
  9230   B$ = Left$(A$, 1)
  9240   Y% = -1
  9250   If B$ = "Y" Or B$ = "y" Then Y% = 1
  9260   If B$ = "N" Or B$ = "n" Then Y% = 0
  9299 End Sub

  9300 Function fnNUMINP
  9310   procGPI(1, 6)
  9320   = Val(A$)
' END:       #Include "kingdom.bas" --------------------------------------------
