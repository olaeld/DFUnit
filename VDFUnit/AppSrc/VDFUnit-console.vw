Use DFClient.pkg
Use cRichEdit.pkg
Use cProgressBar.pkg
Use VDFUnit.pkg

Activate_View Activate_VDFUnitConsole_vw for VDFUnitConsole_vw
Object VDFUnitConsole_vw is a View

    Set Border_Style to Border_None
    Set Size to 246 427
    Set Location to 0 0
    Set Label to "VDFUnit-console"
    Set Maximize_Icon to False
    Set Minimize_Icon to False
    Set pbSizeToClientArea to False
    Set Sysmenu_Icon to False
    Set Caption_Bar to False
    Set View_Mode to Viewmode_Zoom

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

Use Flexml.pkg

Object oResultXml is a cXMLDOMDocument
    Property Handle phRoot
    
    Procedure InsertXmlDeclaration Handle hoRoot
        //Add <?xml version="1.0" encoding="ISO-8859-1"?>
        Handle hoNodeToInsert hoInsertedNode
        Get CreateChildProcessingInstruction of hoRoot "xml" 'version="1.0" encoding="ISO-8859-1"' to hoNodeToInsert
        If (hoNodeToInsert > 0) Begin
            Get InsertBeforeNode of hoNodeToInsert hoRoot to hoInsertedNode
            If ((hoInsertedNode <> hoNodeToInsert) and (hoInsertedNode > 0)) Begin
                Send Destroy of hoInsertedNode
            End
            Send Destroy of hoNodeToInsert
        End
    End_Procedure
    

    Procedure StartTestResults
        Handle hRoot
        Get CreateDocumentElement "testsuites" to hRoot
        Send InsertXmlDeclaration hRoot
        Set phRoot to hRoot
    End_Procedure
    
    Procedure EndTestResults
        String sXml
        Get psXML to sXml
        Set psDocumentName to "C:\Jenkins\jobs\Unit test results\workspace\Test.xml"
        Integer iResult
        Get SaveXMLDocument to iResult
        Send Destroy of (phRoot(Self))
    End_Procedure
    
    Procedure AddErrorNode Handle hNode String sErrorMessage
        Handle hNewNode
        Get AddElement of hNode "failure" sErrorMessage to hNewNode
        Send AddAttribute to hNewNode "type" "error-type"
        Send Destroy of hNewNode
    End_Procedure
    
    Function OutputTestResult Handle hNode String sTagName Handle hResult Returns Handle
        String sName
        Get psName of hResult to sName
        Handle hNewNode
        Get AddElement of hNode sTagName "" to hNewNode
        Send AddAttribute to hNewNode "name" sName
        Number nTime
        Move (SpanTotalMilliSeconds(pTime(hResult))/1000) to nTime
        Send AddAttribute to hNewNode "time" (Replaces(",", nTime, "."))
        If (psErrorMessage(hResult) <> "") Send AddErrorNode hNewNode (psErrorMessage(hResult))
        Function_Return hNewNode
    End_Function
    
    Procedure OutputTestResults Handle hNode Handle hTestFixture
        Handle hTestCatalog hTest hResult hNewNode
        Get phTestCatalog of hTestFixture to hTestCatalog
        Send IteratorReset to hTestCatalog
        String sClassName
        Move (oTestFixtureResult(hTestFixture)) to hResult
        Get psName of hResult to sClassName
        While (IteratorMoveNext(hTestCatalog))
            Get CurrentTest of hTestCatalog to hTest
            Move (oTestResult(hTest)) to hResult
            Get OutputTestResult hNode "testcase" hResult to hNewNode
            Send AddAttribute to hNewNode "classname" sClassName
            Send Destroy of hNewNode
        Loop
    End_Procedure
    
    Function OutputTestFixtureResult Handle hNode Handle hTestFixture Returns Handle
        Handle hNewNode hResult
        Move (oTestFixtureResult(hTestFixture)) to hResult
        Get OutputTestResult hNode "testsuite" hResult to hNewNode
        Send AddAttribute to hNewNode "tests" (TotalNumberOfTests(hTestFixture))
        Send OutputTestResults hNewNode hTestFixture
        Function_Return hNewNode
    End_Function
    
    Procedure OutputTestFixture Handle hTestFixture Handle hNode
        Handle hNewNode
        Get OutputTestFixtureResult hNode hTestFixture to hNewNode
        Send OutputTestFixtureCatalog (oTestFixtureCatalog(hTestFixture)) hNewNode
        Send Destroy of hNewNode
    End_Procedure
    
    Procedure OutputTestFixtureCatalog Handle hCatalog Handle hNode
        Send IteratorReset to hCatalog
        While (IteratorMoveNext(hCatalog))
            Send OutputTestFixture (CurrentTestFixture(hCatalog)) hNode
        Loop
    End_Procedure
    
    Procedure OutputResults Handle hTestFixtureCatalog
        Send StartTestResults
        Handle hNode
        Get phRoot to hNode
        Send OutputTestFixtureCatalog hTestFixtureCatalog hNode
        Send EndTestResults
    End_Procedure
End_Object

Object oTestFixtureRunner is a cTestFixtureRunner
    Procedure Execute
        Indicate Err False
        Send RunTestFixtures
        Send OutputResults to oResultXml oTestFixtureCatalog
        Abort
    End_Procedure
    
    Set phTestFixtureCatalog to (oTestFixtureCatalog(Self))
    
End_Object

Procedure Execute
    Send Execute to oTestFixtureRunner
End_Procedure
