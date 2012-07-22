Function GetPageName() As String
    Dim PageURLArray() As String = Split(Request.Url.ToString(), "/")
    Dim PageURL As String = PageURLArray(PageURLArray.Length - 1)
    'Dim PageName As String = Left(PageURL, PageURL.Length - 5)

    Return PageURL
End Function

'Params
'   Input: Optional Integer, Optional String, Optional String
'   Output: String
'
'This Function takes the lookup id and returns the lup_child
'If there is no LookupId then it will use the lup_parent and lup_child to get and return the lup_id

Function GetLookupDetails(Optional ByVal LookupId As Integer = 0, Optional ByVal LookupParent As String = "", Optional ByVal LookupChild As String = "") As String
    Dim LookupConnection As SqlConnection
    Dim LookupCommand As SqlCommand
    Dim LookupReader As SqlDataReader

    Dim sql As String

    If LookupId <> 0 Then
        LookupConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        LookupConnection.Open()

        sql = "Select * from lookup"
        sql = sql & " Where lup_id = '" & LookupId & "'"

        LookupCommand = New SqlCommand(sql, LookupConnection)
        LookupReader = LookupCommand.ExecuteReader()

        While LookupReader.Read()
            LookupChild = LookupReader("lup_child")
        End While

        LookupReader.Close()
        LookupConnection.Close()

        Return LookupChild
    ElseIf LookupParent <> "" And LookupChild <> "" Then
        LookupConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        LookupConnection.Open()

        sql = "Select * from lookup"
        sql = sql & " Where lup_parent  = '" & LookupParent & "'"
        sql = sql & " and lup_child = '" & LookupChild & "'"

        LookupCommand = New SqlCommand(sql, LookupConnection)
        LookupReader = LookupCommand.ExecuteReader()

        While LookupReader.Read()
            LookupId = LookupReader("lup_id")
        End While

        LookupReader.Close()
        LookupConnection.Close()

        Return LookupId
    Else
        Throw New ArgumentNullException("Could Not get Required Params for Lookup Function")
    End If
End Function

Function SqlLookupBuilder(ByVal LookupParent As String, ByVal BuilderColumn As String, Optional ByVal Builder As String = "and", Optional ByVal LookupChild As String = "") As String
    If LookupParent <> "" Or BuilderColumn <> "" Then
        Dim SqlLookupBuilderConnection As SqlConnection
        Dim SqlLookupBuilderCommand As SqlCommand
        Dim SqlLookupBuilderReader As SqlDataReader

        Dim BuiltSqlString As String
        Dim sql As String

        Builder = " " & Builder & " "

        SqlLookupBuilderConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        SqlLookupBuilderConnection.Open()

        sql = " Select * from lookup"
        sql = sql & " where lup_parent = '" & LookupParent & "'"

        If LookupChild <> "" Then
            sql = sql & " and lup_child <> '" & LookupChild & "'"
        End If

        SqlLookupBuilderCommand = New SqlCommand(sql, SqlLookupBuilderConnection)
        SqlLookupBuilderReader = SqlLookupBuilderCommand.ExecuteReader()

        While SqlLookupBuilderReader.Read()
            If BuiltSqlString <> "" Then
                BuiltSqlString = BuiltSqlString & Builder
            End If

            BuiltSqlString = BuiltSqlString & " " & BuilderColumn & " = '" & SqlLookupBuilderReader("lup_id") & "' "
        End While

        SqlLookupBuilderConnection.Close()

        Return BuiltSqlString
    Else
        Throw New ArgumentNullException("No input for Lookup Parent or target column")
    End If
End Function