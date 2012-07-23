'Params:
'    Input: Optional String, Optionsl Integer, Optional Integer
'    Output: Boolean
'
'This expects a string about what is being accessed i.e. trying to edit a ticket or display a menu item for a specific page
'This will then look at the users security items to see if they have that item for either that page or project.
'If they do then it will give True else it will give False
'
'This can also be used to see if the person has any access to a project by sending just the project ID

Function AllowAction(ByVal Action As String, Optional ByVal ProjectId as integer = 0, Optional ByVal PageId as integer = 0) As Boolean
    If ProjectId <> 0 or PageId <> 0 Then
        Dim CheckActionConnection As sqlconnection
        Dim CheckActionCommand as sqlCommand
        Dim CheckActionReader as sqldataReader
        
        Dim AllowAccessToAction as boolean = false

        Dim sql as string = "" 
        Dim SecurityItemId as string = ""
        
        CheckActionConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        CheckActionConnection.Open()

		If Action <> "" then 
	        sql = "Select * from security_Items"
	        sql = sql & " where sit_securityItem = '" & Action & "'" 
	
            CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
	        CheckActionReader = CheckActionCommand.ExecuteReader()
	
	        while CheckActionReader.read()
	            SecurityItemId = CheckActionReader("sit_id")
	        End While
	
	        CheckActionReader.close()
		End If
		
        sql = "Select * from Contact_securityItems "
        sql = sql & " where csit_conId = '" & Session("UserID") & "'"
        
        if Action <> "" then 
        	sql = sql & " and csit_id = '" & SecurityItemId & "'"
        end if
        
        if ProjectId <> 0 then
            sql = sql & " and csit_proId = '" & ProjectId & "'"
        else if PageId <> 0
            sql = sql & " and csit_pagId = '" & PageId & "'" 
        else
        	Throw New ArgumentNullException("No Page ID/Project Id Given to AllowAction")
        end if 

        CheckActionCommand = New SqlCommand(sql, CheckActionConnection)
        CheckActionReader = CheckActionCommand.ExecuteReader()

        If CheckActionReader.hasrows() then 
            AllowAccessToAction = True
        else
			AllowAccessToAction = False
        End if  
        
        CheckActionReader.close()
        CheckActionConnection.close()
        
        return AllowAccessToAction
    Else
        Throw New ArgumentNullException("No Action or Project/Page Id given to AllowAction")
    End If
End Function

'Params:
'    Input: Intger
'    Output: Boolean
'
'The page id is sent to this function so it can check to see if you have access to the particular page. 
'If you dont have access then you are sent to RenewSession and back to the dashboard once your session has been renewed
'If you do, then carry on 

Sub ViewPage(ByVal PageId as integer) 
	If PageId <> 0 then
        Dim ViewPageConnection As sqlconnection
        Dim ViewPageCommand as sqlCommand
        Dim ViewPageReader as sqldataReader
        
        Dim ViewPage as boolean
      
        Dim sql as string = "" 
        
		ViewPageConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        ViewPageConnection.Open()
	
		sql = "Select * from Contact_securityItems "
        sql = sql & " where csit_pagId = '" & PageId & "'"         

        ViewPageCommand = New SqlCommand(sql,ViewPageConnection)
        ViewPageReader = ViewPageCommand.ExecuteReader()

        If ViewPageReader.hasrows() then 
            ViewPage = True
        else
			ViewPage = False
        End if  
        
        ViewPageReader.close()
        ViewPageConnection.close()
        
        If ViewPage = True then
        	Return
        else
        	RenewSession(True)
        End If
	else
		Throw New ArgumentNullException("No Page Id Sent to ViewPage")
	end if
End Sub

'Params
'	Input: Optional Boolean
'	Output: 
'
'This renews the users session by destroying it and matching with their personal record.
'If there is no Session or record then it will seend you to the login page
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
