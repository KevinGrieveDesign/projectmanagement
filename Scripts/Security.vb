'Params:
'    Input:String
'    Output:Boolean
'
'This expects a string about what is being accessed i.e. trying to edit a ticket
'This will then look at the users security items and match them with the ticket and the relationships to see if they have the right to do that action

Function AllowAction(ByVal Action As String) As Boolean
    If Action <> "" Then

    Else
        Throw New ArgumentNullException("No action give to Security Model")
    End If
End Function

Sub RenewSession()
    Dim AuthenticationCheckConn As SqlConnection
    Dim AuthenticationCheckCommand As SqlCommand
    Dim AuthenticationCheckReader As SqlDataReader

    Dim sql As String

    If Session("UserID") <> 0 Then
        AuthenticationCheckConn = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        AuthenticationCheckConn.Open()

        sql = " SELECT * "
        sql = sql & " FROM contact "
        sql = sql & " where con_id = '" & Session("UserID") & "'"

        AuthenticationCheckCommand = New SqlCommand(sql, AuthenticationCheckConn)
        AuthenticationCheckReader = AuthenticationCheckCommand.ExecuteReader()

        While AuthenticationCheckReader.Read()
            Session.Remove("UserID")
            Session("UserID") = AuthenticationCheckReader("Con_id")
        End While

        If Not AuthenticationCheckReader.HasRows Then
            Session.Remove("UserID")

            Response.Redirect("Login.aspx?LoggedIn=Unknown")
        End If

        AuthenticationCheckReader.Close()
        AuthenticationCheckConn.Close()

        Return
    Else
        Response.Redirect("Login.aspx?LoggedIn=Unknown")
    End If
End Sub