'Params:
'    Input: Optional String, Optional Integer, Optional Integer, Optional Integer
'    Output: Boolean
'
'This expects a string about what is being accessed i.e. trying to edit a ticket or display a menu item for a specific page
'This will then look at the users security items to see if they have that item for either that page or project.
'If they do then it will give True else it will give False
'
'This can also be used to see if the person has any access to a project by sending just the project ID
'
'If the User is of the lowest user group (Project Reporter (3)) then the OnSelf  field is checked. This means that they have the editticket sec item for a project but they are only
'a Project reporter. This combination then only allows them to edit their own things.

Function AllowAction(ByVal Action As String, Optional ByVal ProjectId As Integer = 0, Optional ByVal PageId As Integer = 0, Optional ByVal TicketAddedById As Integer = 0) As Boolean
    If ProjectId <> 0 Or PageId <> 0 Then
        Dim CheckActionConnection As sqlconnection
        Dim CheckActionCommand As sqlCommand
        Dim CheckActionReader As sqldataReader

        Dim AllowAccessToAction As Boolean = False
        Dim ProjectReporter As Integer = 3 'Project Reporter - Lowest Level as of 27/07/2012
        Dim GroupType As Integer = ProjectReporter

        Dim sql As String = ""
        Dim SecurityItemId As String = ""
        Dim Onself As Boolean = False
        Dim OnselfList As String
        Dim x As Integer

        CheckActionConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        CheckActionConnection.Open()

        If Action <> "" Then
            sql = "Select * from security_Items"
            sql = sql & " where sit_securityItem = '" & Action & "'"

            CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
            CheckActionReader = CheckActionCommand.ExecuteReader()

            While CheckActionReader.read()
                SecurityItemId = CheckActionReader("sit_id")
            End While

            CheckActionReader.close()
        End If

        If ProjectId <> 0 Then
            sql = "Select * from contact_securityGroup"
            sql = sql & " where cgsit_conId = '" & Session("UserID") & "'"
            sql = sql & " and cgsit_proId = '" & ProjectId & "'"

            CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
            CheckActionReader = CheckActionCommand.ExecuteReader()

            While CheckActionReader.read()
                GroupType = CheckActionReader("cgsit_gsitId")
            End While

            CheckActionReader.close()
        End If

        If TicketAddedById <> 0 Then
            sql = "Select * from security_Items"

            CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
            CheckActionReader = CheckActionCommand.ExecuteReader()

            While CheckActionReader.read()
                If Not (CheckActionReader("sit_onSelf") Is DBNull.value) Then
                    If CheckActionReader("sit_onSelf") = True Then
                        If OnselfList <> "" Then
                            OnselfList = OnselfList & ","
                        End If

                        OnselfList = OnselfList & CheckActionReader("sit_id")
                    End If
                End If
            End While

            CheckActionReader.close()
        End If

        sql = "Select * from Contact_securityItems "
        sql = sql & " where csit_conId = '" & Session("UserID") & "'"

        If Action <> "" Then
            sql = sql & " and csit_sitId = '" & SecurityItemId & "'"
        End If

        If ProjectId <> 0 Then
            sql = sql & " and csit_proId = '" & ProjectId & "'"
        ElseIf PageId <> 0 Then
            sql = sql & " and csit_pagId = '" & PageId & "'"
        Else
            Throw New ArgumentNullException("No Page ID/Project Id Given to AllowAction")
        End If

        CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
        CheckActionReader = CheckActionCommand.ExecuteReader()

        If CheckActionReader.hasrows() Then
            AllowAccessToAction = True
        Else
            AllowAccessToAction = False
        End If

        Dim OnSelfItems() As String = Split(OnSelfList, ",")

        For x = 0 To OnselfItems.length() - 1
            If SecurityItemId = OnselfItems(x) Then
                OnSelf = True
            End If
        Next

        If TicketAddedById <> Session("UserID") And TicketAddedById <> 0 And GroupType = ProjectReporter And Onself = True Then
            AllowAccessToAction = False
        End If

        CheckActionReader.close()
        CheckActionConnection.close()

        LogAction("AllowAction", ProjectId, request("ticket"), PageId, Action, AllowAccessToAction)

        Return AllowAccessToAction
    Else
        Throw New ArgumentNullException("No Action or Project/Page Id given to AllowAction")
    End If
End Function

'Params:
'    Input: Intger, Optional String
'    Output: Boolean
'
'The page id is sent to this function so it can check to see if you have access to the particular page. 
'This allows the menu to access it and not get sent to a different location by the use of the Location variable
'If you dont have access then you are sent to RenewSession and back to the dashboard once your session has been renewed
'If you do, then carry on 

Function ViewPage(ByVal PageId As Integer, Optional ByVal ProjectId As Integer = 0, Optional ByVal Location As String = "") As Boolean
    If PageId <> 0 Then
        Dim ViewPageConnection As sqlconnection
        Dim ViewPageCommand As sqlCommand
        Dim ViewPageReader As sqldataReader

        Dim ViewPageResult As Boolean

        Dim sql As String = ""

        ViewPageConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        ViewPageConnection.Open()

        sql = "Select * from Contact_securityItems inner join security_items on csit_sitid = sit_id"
        sql = sql & " where csit_conId = '" & Session("UserId") & "'"
        sql = sql & " and sit_pagId = '" & PageId & "'"

        If ProjectId <> 0 Then
            sql = sql & " and csit_proId = '" & projectId & "'"
        End If

        ViewPageCommand = New SqlCommand(sql, ViewPageConnection)
        ViewPageReader = ViewPageCommand.ExecuteReader()

        If ViewPageReader.hasrows() Then
            ViewPageResult = True
        Else
            ViewPageResult = False
        End If

        ViewPageReader.close()
        ViewPageConnection.close()

        If ViewPageResult = False And Location = "" Then
            LogAction("ViewPage", ProjectId, 0, PageId, "ViewPage", True)

            RenewSession(True)
        Else
            LogAction("ViewPage", ProjectId, 0, PageId, Location, ViewPageResult)

            RenewSession()

            Return ViewPageResult
        End If

    Else
        Throw New ArgumentNullException("No Page Id Sent to ViewPage")
    End If
End Function

'Params
'	Input: Optional Boolean
'	Output: 
'
'This renews the users session by destroying it and matching with their personal record.
'If there is no Session or record then it will send you to the login page
'If you dont have access to a page you will be sent here with a param of true, your session will be renewed and then to the dashboard

Function RenewSession(Optional ByVal SendToDashboard As Boolean = False) As Boolean
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
        End If

        AuthenticationCheckReader.Close()
        AuthenticationCheckConn.Close()

        If SendToDashboard = True Then
            Response.Redirect("Dashboard.aspx?Access=Denied")
        End If

        If Session("UserID") <> 0 Then
            Return True
        Else
            Response.Redirect("Login.aspx?LoggedIn=Unknown")
        End If
    Else
        Response.Redirect("Login.aspx?LoggedIn=Unknown")
    End If
End Function

'Params
'	Input: Integer
'	Output: String
'
'This takes the contact_securitygroupID Id and gives out the Security Group Name name 

Function GetSecurityGroupName(ByVal SecurityGroupID as integer) as string
    Dim SecurityGroupNameConnection As SqlConnection
    Dim SecurityGroupCommand As SqlCommand
    Dim SecurityGroupReader As SqlDataReader
    
    Dim sql as string
    Dim SecurityGroupName as string
   
    SecurityGroupNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    SecurityGroupNameConnection.Open()
    
    sql = "Select * from security_group "
    sql = sql & " Where gsit_id = '" & SecurityGroupID & "'"
   
    SecurityGroupCommand = New SqlCommand(sql, SecurityGroupNameConnection)
    SecurityGroupReader = SecurityGroupCommand.ExecuteReader()
    
    If SecurityGroupReader.Hasrows() then
    	While SecurityGroupReader.Read()
    		SecurityGroupName = SecurityGroupReader("gsit_description")
    	End While
    Else
    	SecurityGroupName = ""
    End if
            
    SecurityGroupReader.Close()
    SecurityGroupNameConnection.Close()
    
    Return SecurityGroupName
End Function

'Params
'	Input: String, Integer
'	OutPut: Boolean
'
'This function checks to see if the project has a feature and out puts a true/false

Function HasFeatures(ByVal Feature as string, ByVal ProjectId as Integer) as boolean 
	Dim HasFeatureConnection As SqlConnection
    Dim HasFeatureCommand As SqlCommand
    Dim HasFeatureReader As SqlDataReader
    
    Dim sql as string
    Dim HasFeatureBoolean as Boolean
    
    HasFeatureBoolean = False
   
    HasFeatureConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    HasFeatureConnection.Open()
    
    sql = "Select * from project_features "
    sql = sql & " Where prof_proID = '" & ProjectId & "'"
    sql = sql & " and prof_isActive = 'True'"
   
    HasFeatureCommand = New SqlCommand(sql, HasFeatureConnection)
    HasFeatureReader = HasFeatureCommand.ExecuteReader()
    
    If HasFeatureReader.Hasrows() then
    	HasFeatureBoolean = True
    Else
    	HasFeatureBoolean = False
    End if
            
    HasFeatureReader.Close()
    HasFeatureConnection.Close()
    
    LogAction("HasFeature", ProjectId, 0, 0, Feature, HasFeatureBoolean)    
    
    Return HasFeatureBoolean
End Function 