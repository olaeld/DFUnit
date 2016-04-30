Use DFClient.pkg
Use cRichEdit.pkg
Use cProgressBar.pkg
Use VDFUnit.pkg

Activate_View Activate_VDFUnitTestRunner_vw for VDFUnitTestRunner_vw
Object VDFUnitTestRunner_vw is a View

    Procedure ShowText String sText
        Send AppendTextLn to oOutputBox (Replaces("_", sText, " "))
    End_Procedure
    
    Set Border_Style to Border_None
    Set Size to 246 427
    Set Location to 0 0
    Set Label to "VDFUnit TestRunner"
    Set Maximize_Icon to False
    Set Minimize_Icon to False
    Set pbSizeToClientArea to False
    Set Sysmenu_Icon to False
    Set Caption_Bar to False
    Set View_Mode to Viewmode_Zoom
    
    Object oOutputBox is a cRichEdit
        Set Size to 110 400
        Set Location to 64 13
        Set Focus_Mode to NonFocusable
        
        Procedure SetRunningColor
            Set Color to clGray
        End_Procedure
        
        Procedure SetSuccessColor
            Set Color to clLime
        End_Procedure
        
        Procedure SetWarningColor
            Set Color to clYellow
        End_Procedure
        
        Procedure SetFailedColor
            Set Color to clRed
        End_Procedure
        
        Function TestResultOutputString Handle hResult Returns String
            String sResult sSuccess
            If (psSuccess(hResult) = "True") Move "" to sSuccess
            Else Move "*** FAILED ***" to sSuccess
            Move ("[" + FormatNumber(Number(SpanTotalMilliSeconds(pTime(hResult)))/1000, 3) + "]" * sSuccess * psName(hResult)) to sResult
            Function_Return sResult
        End_Function
        
        Procedure StartTestResults
        End_Procedure
        Procedure EndTestResults
        End_Procedure
        Procedure ListTestResult Handle hResult Integer iIndentation
            String sResult
            Get TestResultOutputString hResult iIndentation to sResult
            Move (Pad("", iIndentation * 4) + sResult) to sResult
            Integer iStart iEnd
            String sValue
            Send Select_All
            Get SelText to sValue
            Move (Length(sValue)) to iStart
            Send AppendTextLn (Replaces("_", sResult, " "))
            Boolean bFailed
            Move (Pos("*** FAILED ***", sResult) > 0) to bFailed
            If (not(bFailed)) Procedure_Return
            Send Select_All
            Get SelText to sValue
            Move (Length(sValue)) to iEnd
            Send SetSel iStart iEnd
            Set pbBold to bFailed
            Send SetSel 0 0
        End_Procedure
        
        Procedure ListTestFixtureResult Handle hTestFixture Integer iIndentation
            Send ListTestResult (oTestFixtureResult(hTestFixture)) iIndentation
        End_Procedure
        
    End_Object

    Object oRunTestsButton is a Button
        Set Size to 30 200
        Set Location to 13 13
        Set Label to "Run tests!"
        Set Typeface to "verdana"
        Set FontSize to 20 10
    
        Procedure OnClick
            Send Execute to oTestFixtureRunner
        End_Procedure
    
    End_Object

End_Object

Object oTestFixtureCatalog is a cTestFixtureCatalog
    Set phTestFixtureNeighborhood to (Parent(Self))
    Send InitTestFixtureCatalog
End_Object

Object oTestFixtureRunner is a cTestFixtureRunner
    Procedure ListTestResults Handle hTestFixture Handle hLister Integer iIndentation
        Handle hTestCatalog hTest
        Get phTestCatalog of hTestFixture to hTestCatalog
        Send IteratorReset to hTestCatalog
        While (IteratorMoveNext(hTestCatalog))
            Get CurrentTest of hTestCatalog to hTest
            Send ListTestResult to hLister (oTestResult(hTest)) iIndentation
        Loop
    End_Procedure
    
    Procedure ListTestFixtureResult Handle hTestFixture Handle hLister Integer iIndentation
        Send ListTestFixtureResult to hLister hTestFixture iIndentation
        Send ListTestResults hTestFixture hLister (iIndentation + 1)
        Send ListTestFixtureResults (oTestFixtureCatalog(hTestFixture)) hLister (iIndentation + 1)
    End_Procedure
    
    Procedure ListTestFixtureResults Handle hTestFixtureCatalog Handle hLister Integer iIndentation
        Send StartTestResults to hLister
        If (not(hLister)) Function_Return
        Integer iIndentation_
        If (num_arguments >= 3) Move iIndentation to iIndentation_
        Send IteratorReset to hTestFixtureCatalog
        While (IteratorMoveNext(hTestFixtureCatalog))
            Send ListTestFixtureResult (CurrentTestFixture(hTestFixtureCatalog)) hLister iIndentation_
        Loop
        Send EndTestResults to hLister
    End_Procedure
    
    Procedure Execute
        Indicate Err False
        Handle hOutputBox
        Move (oOutputBox(VDFUnitTestRunner_vw(Self))) to hOutputBox
        Send SetRunningColor to hOutputBox
        Send RunTestFixtures
        If (pbFailOccured(Self)) Begin
            Send SetFailedColor to hOutputBox
        End
        Else Begin
            Send SetSuccessColor to hOutputBox
        End
        Send Delete_Data to (oOutputBox(VDFUnitTestRunner_vw(Self)))
        Send ListTestFixtureResults oTestFixtureCatalog (oOutputBox(VDFUnitTestRunner_vw(Self)))
    End_Procedure
    
    Set phTestFixtureCatalog to (oTestFixtureCatalog(Self))
    
End_Object

Procedure Execute
    Send Execute to oTestFixtureRunner
End_Procedure
