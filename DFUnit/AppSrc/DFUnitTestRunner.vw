Use DFClient.pkg
Use cRichEdit.pkg
Use cProgressBar.pkg
Use DFUnit.pkg
Use cDFUnitResultList.pkg
Use cDFUnitResultXml.pkg

Function FilenameFromCommandLine Returns String
    Handle hCmdLine
    String sArgument
    Move (phoCommandLine(ghoApplication)) to hCmdLine
    Integer i iNumArgs
    Get CountOfArgs of hCmdLine to iNumArgs
    For i from 1 to iNumArgs
        Move (Argument(hCmdLine, i)) to sArgument
        If (Lowercase(Left(sArgument, 5)) = "/xml:") Begin
            Function_Return (Mid(sArgument, Length(sArgument) - 5, 6))
        End
    Loop
    Function_Return ""
End_Function

Object oResultXml is a cDFUnitResultXml
    Function XmlResultFileName Returns String
        String sFilename
        Get FilenameFromCommandLine to sFilename
        If (sFilename <> "") Function_Return sFilename
        Move (psHome(phoWorkspace(ghoApplication)) + "test_results.xml") to sFilename
        Function_Return sFilename
    End_Function
    Set psDocumentName to (XmlResultFileName(Self))
End_Object

Activate_View Activate_DFUnitTestRunner_vw for DFUnitTestRunner_vw
Object DFUnitTestRunner_vw is a View
    
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
    
    Object oOutputBox is a cDFUnitResultList
        Set Size to 110 400
        Set Location to 64 13
    End_Object

    Object oRunTestsButton is a Button
        Set Size to 30 200
        Set Location to 13 13
        Set Label to "Run tests!"
        Set Typeface to "verdana"
        Set FontSize to 20 10
    
        Procedure OnClick
            Send Execute to (Parent(Self))
        End_Procedure
    
    End_Object

End_Object

Object oTestFixtureCatalog is a cTestFixtureCatalog
    Set phTestFixtureNeighborhood to (Parent(Self))
    Send InitTestFixtureCatalog
End_Object

Object oTestFixtureRunner is a cTestFixtureRunner
    Procedure Execute Handle hOutput
        Send OnExecute to hOutput
        Indicate Err False
        Send RunTestFixtures
        If (pbFailOccured(Self)) Send OnFail to hOutput
        Else Send OnSuccess to hOutput
        Send OnExecuteFinished to hOutput
    End_Procedure
    
    Procedure OutputResults Handle hOutput
        Send OutputResults to hOutput oTestFixtureCatalog
    End_Procedure
    
    Set phTestFixtureCatalog to (oTestFixtureCatalog(Self))
End_Object

Procedure Execute
    Send Execute to oTestFixtureRunner (oOutputBox(DFUnitTestRunner_vw(Self)))
    Send OutputResults to oTestFixtureRunner (oOutputBox(DFUnitTestRunner_vw(Self)))
    Send OutputResults to oTestFixtureRunner oResultXml
    If (not(IsDebuggerPresent())) Abort
End_Procedure
