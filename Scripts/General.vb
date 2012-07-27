'Params
'   Input: None
'   Output: Integer
'
'This gets the URL and matches it into the page table and sends back the Page ID

Function GetPageID(Optional ByVal PageNameToUse As String = "") As Integer
    Dim PageURLArray() As String = Split(Request.Url.ToString(), "/")
    Dim PageURLParams() As String = Split(PageURLArray(PageURLArray.Length - 1), "?")
    Dim PageName As String = PageURLParams(0)
    Dim PageID As Integer

    Dim GetPageHeaderConnection As sqlconnection
    Dim GetPageHeaderCommand As sqlcommand
    Dim GetPageHeaderReader As sqldatareader

    Dim sql As String

    GetPageHeaderConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    GetPageHeaderConnection.Open()

    If PageNameToUse <> "" Then
        PageName = PageNameToUse
    End If

    sql = "Select * from pages "
    sql = sql & " where pag_name = '" & PageName & "'"

    GetPageHeaderCommand = New SqlCommand(sql, GetPageHeaderConnection)
    GetPageHeaderReader = GetPageHeaderCommand.ExecuteReader()

    While GetPageHeaderReader.Read()
        PageID = GetPageHeaderReader("pag_id")
    End While

    GetPageHeaderReader.Close()
    GetPageHeaderConnection.Close()

    Return PageID
End Function

'Params
'   Input: Optional Integer, Optional String
'   Output: String
'
'This will get the page link in a nice hyperlink for menus

Function GetPageName(Optional ByVal PageId As Integer = 0, Optional ByVal Alternate As Boolean = False) As String
    If PageId <> 0 Then
        Dim GetPageNameConnection As SqlConnection
        Dim GetPageNameCommand As SqlCommand
        Dim GetPageNameReader As SqlDataReader

        Dim sql As String
        Dim PageName As String

        GetPageNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        GetPageNameConnection.Open()

        sql = "Select * from pages"
        sql = sql & " Where pag_id = '" & PageId & "'"

        GetPageNameCommand = New SqlCommand(sql, GetPageNameConnection)
        GetPageNameReader = GetPageNameCommand.ExecuteReader()

        While GetPageNameReader.Read()
            PageName = "<a href = '"

            If GetPageNameReader("pag_name") Is DBNull.Value Then
                PageName = PageName & "index.aspx"
            Else
                PageName = PageName & GetPageNameReader("pag_name")
            End If

            If GetPageNameReader("pag_name") = "Login.aspx" Then
                Pagename = Pagename & "?Logout=True"

                If Session("UserId") <> 0 Then
                    Alternate = True
                End If
            End If

            If Not (GetPageNameReader("pag_target") Is dbnull.value) Then
                Pagename = Pagename & "target = '" & GetPageNameReader("pag_target") & "'"
            End If

            PageName = PageName & "'>"

            If Alternate = True Then
                Pagename = Pagename & GetPageNameReader("pag_AltMenuItem")
            Else
                Pagename = Pagename & GetPageNameReader("pag_MenuItem")
            End If

            PageName = PageName & "</a>"
        End While

        GetPageNameReader.Close()
        GetPageNameConnection.Close()

        Return PageName
    Else
        Throw New ArgumentNullException("No Page Id given to GetPageName")
    End If
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
            sql = sql & " and lup_id <> '" & LookupChild & "'"
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

'Params
'   Input: None
'   OutPut: None
'
'WHen this sub is called it will build the menu, taking into account each persons security items and the groupings for the menu

Sub BuildMenu()
    Dim BuildMenuConneciton As SqlConnection
    Dim BuildMenuCommand As SqlCommand
    Dim BuildMenuReader As SqlDataReader

    BuildMenuConneciton = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    BuildMenuConneciton.Open()

    Dim Grouping As String
    Dim sql As String
    Dim Counter As Integer

    Grouping = ""
    Counter = 0

    sql = " select * from pages "
    sql = sql & " where pag_inMenu = 'true'"
    sql = sql & " order by pag_sequence"

    BuildMenuCommand = New SqlCommand(sql, BuildMenuConneciton)
    BuildMenuReader = BuildMenuCommand.ExecuteReader()

    While BuildMenuReader.Read()
        If ViewPage(BuildMenuReader("pag_id"), 0, "Menu") Or BuildMenuReader("pag_public") = True Then
            Counter = Counter + 1
            If Not (BuildMenuReader("pag_grouping") Is DBNull.Value) Then
                If Grouping = "" Or Grouping <> BuildMenuReader("pag_grouping") Then
                    If Counter <> 1 Then
                        Response.write("<br />")
                    End If

                    Response.write("<h3>" & BuildMenuReader("pag_grouping") & "</h3>")
                End If
                Grouping = BuildMenuReader("pag_grouping")
            End If

            Response.Write(GetPageName(BuildMenuReader("pag_id")) & "<br/>")
        End If
    End While

    BuildMenuReader.Close()
    BuildMenuConneciton.Close()
End Sub

'Params
'   Input: String, String, Optional String, Optional String
'   Output: Nothing
'
'This takes the parent to get a lookup list, or a employee of Kevin Grieve Design (5)
'This will output the results to the screen

Function BuildDynamicDropDown(ByVal Parent As String, ByVal DropDownName As String, ByVal Selected As String, Optional ByVal Exclude As String = "", Optional ByVal PleaseSelect As Boolean = False, Optional ByVal EmployeeOnly As Boolean = False) As String
    Dim BuildDropDownConneciton As SqlConnection
    Dim BuildDropDownCommand As SqlCommand
    Dim BuildDropDownReader As SqlDataReader

    BuildDropDownConneciton = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    BuildDropDownConneciton.Open()

    Dim DropDown As String
    Dim SelectedValue As String
    Dim sql As String
    Dim IsEmployee As Boolean = False

    If EmployeeOnly = True Then
        Dim GetContactConneciton As SqlConnection
        Dim GetContactCommand As SqlCommand
        Dim GetContactReader As SqlDataReader

        GetContactConneciton = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        GetContactConneciton.Open()

        sql = " select * from contact"
        sql = sql & " inner join relationship on con_id = rel_contactIdA"
        sql = sql & " where rel_contactIDA = '" & Session("UserId") & "'"
        sql = sql & " and rel_contactIdB = '5'"
        sql = sql & " and rel_typeId = '" & GetLookUpDetails(0, "relationship_type", "Employee of") & "'"

        GetContactCommand = New SqlCommand(sql, GetContactConneciton)
        GetContactReader = GetContactCommand.ExecuteReader()

        If GetContactReader.hasrows() Then
            IsEmployee = True
        End If

        GetContactReader.close()
        GetContactConneciton.close()
    End If

    If Parent = "Assigned" Then
        Dim GetContactConneciton As SqlConnection
        Dim GetContactCommand As SqlCommand
        Dim GetContactReader As SqlDataReader

        GetContactConneciton = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        GetContactConneciton.Open()

        sql = " select * from contact"
        sql = sql & " inner join relationship on con_id = rel_contactIdA"
        sql = sql & " where rel_typeId = '" & GetLookUpDetails(0, "relationship_type", "Employee of") & "'"
        sql = sql & " and rel_contactIdB = '5'"

        If Exclude <> "" Then
            sql = sql & " and not(con_id in '" & Exclude & "')"
        End If

        sql = sql & " order by con_firstname"

        BuildDropDownCommand = New SqlCommand(sql, BuildDropDownConneciton)
        BuildDropDownReader = BuildDropDownCommand.ExecuteReader()

        While BuildDropDownReader.Read()
            If IsEmployee = True Or Selected = BuildDropDownReader("con_id") Or EmployeeOnly = False Then
                DropDown = DropDown & "<option value = '" & BuildDropDownReader("con_id") & "'"

                If Selected = BuildDropDownReader("con_id") Then
                    DropDown = DropDown & "selected='selected'"
                End If

                sql = "Select * from Contact"
                sql = sql & " where con_id = '" & BuildDropDownReader("con_id") & "'"

                GetContactCommand = New SqlCommand(sql, GetContactConneciton)
                GetContactReader = GetContactCommand.ExecuteReader()

                While GetContactReader.Read()
                    DropDown = DropDown & ">" & GetContactReader("con_firstName") & " " & GetContactReader("con_lastName") & "</option>"
                End While

                GetContactReader.close()
            End If
        End While

        GetContactConneciton.close()
    Else
        sql = " select * from lookup "
        sql = sql & " where lup_parent = '" & Parent & "'"

        If Exclude <> "" Then
            sql = sql & " and not(lup_id in '" & Exclude & "')"
        End If

        sql = sql & " order by lup_sequence, lup_child"

        BuildDropDownCommand = New SqlCommand(sql, BuildDropDownConneciton)
        BuildDropDownReader = BuildDropDownCommand.ExecuteReader()

        While BuildDropDownReader.Read()
            If IsEmployee = True Or Selected = BuildDropDownReader("lup_id") Or EmployeeOnly = False Then
                DropDown = DropDown & "<option value = '" & BuildDropDownReader("lup_id") & "'"

                If Selected = BuildDropDownReader("lup_id") Then
                    DropDown = DropDown & "selected='selected'"
                End If

                DropDown = DropDown & ">" & BuildDropDownReader("lup_child") & "</option>"
            End If
        End While
    End If

    If PleaseSelect = True Then
        DropDown = "<select name='" & DropDownName & "' class = 'TextBox'><option value ='' >--Please Choose--</option>" & DropDown & "</select>"
    Else
        DropDown = "<select name='" & DropDownName & "' class = 'TextBox'>" & DropDown & "</select>"
    End If

    BuildDropDownReader.close()

    Response.write(DropDown)

    BuildDropDownConneciton.close()
End Function

