Sub Test()
    If Request.Form("Test") = "Test" Then
        Dim CreateGroupItemsConnection As SqlConnection
        Dim CreateGroupItemsCommand As SqlCommand

        Dim Ra As Integer
        Dim i As Integer

        Dim sql As String

        CreateGroupItemsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        CreateGroupItemsConnection.Open()

        For i = 1 To 53


            sql = "Insert contact_securityItems ( csit_conId, csit_proId, csit_sitId, csit_addedDate, csit_addedBy)"
            sql = sql & " Values('1','3','" & i & "',getdate(), '1')"

            CreateGroupItemsCommand = New SqlCommand(sql, CreateGroupItemsConnection)
            Ra = CreateGroupItemsCommand.ExecuteNonQuery()

        Next
        CreateGroupItemsConnection.Close()

    End If
End Sub