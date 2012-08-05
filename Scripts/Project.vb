'Params
'	Input: Integer
'	Output: String
'
'This takes the project Id and gives out the project name in a hyperlink 

Function GetProjectName(ByVal ProjectId as string) as string
    Dim ProjectNameConnection As SqlConnection
    Dim ProjectNameCommand As SqlCommand
    Dim ProjectNameReader As SqlDataReader
    
    Dim sql as string
    Dim ProjectName as string
   
    ProjectNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    ProjectNameConnection.Open()
    
    sql = "Select * from project "
    sql = sql & " Where pro_id = '" & ProjectId & "'"
   
    ProjectNameCommand = New SqlCommand(sql, ProjectNameConnection)
    ProjectNameReader = ProjectNameCommand.ExecuteReader()
    
    If ProjectNameReader.Hasrows() then
    	While ProjectNameReader.Read()
    		ProjectName = "<a href = 'project.aspx?project=" & ProjectNameReader("pro_id") & "'>" & ProjectNameReader("pro_name") & "<a/>"
    	End While
    Else
    	ProjectName = ""
    End if
            
    ProjectNameReader.Close()
    ProjectNameConnection.Close()
    
    Return ProjectName
End Function

'Params
'	Input: Integer
'	Output: String
'
'This takes the Project Id, then links to GetAllProjectTables Function to build the sql statement
'Once it is searching on all the SQL tables then it will get the last edited by integer that matches with the latest date
'This will then get the contact name from GetContactName and return it

Function ProjectLastEditedBy(ByVal ProjectId as integer) as String
	Dim LastEditedByConnection As SqlConnection
    Dim LastEditedByCommand As SqlCommand
	Dim LastEditedByReader As SqlDataReader
            
    Dim LastEditedBy As String
    Dim sql As String

    LastEditedBy = "N/A"

    LastEditedByConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    LastEditedByConnection.Open()
   
    sql = GetAllProjectTables(ProjectId)
	                           
	LastEditedByCommand = New SqlCommand(sql, LastEditedByConnection)
	LastEditedByReader = LastEditedByCommand.ExecuteReader()
                        
    While LastEditedByReader.Read()
        If Not (LastEditedByReader("tic_editedBy") Is DBNull.Value) Then
            LastEditedBy = LastEditedByReader("tic_editedBy")
        End If
    End While

    LastEditedByReader.Close()
    LastEditedByConnection.Close()
        
    LastEditedBy = GetContactName(LastEditedBy)
    
    Return LastEditedBy
End Function

'Params
'	Input: Integer, Optional Boolean
'	Output: String
'
'This takes the Project Id, then links to GetAllProjectTables Function to build the sql statement
'Once it is searching on all the SQL tables then it will get the last editedDate and return it

Function ProjectLastEditedDate(ByVal ProjectId As Integer, Optional ByVal Time As Boolean = False) As String
    Dim LastEditedConnection As SqlConnection
    Dim LastEditedCommand As SqlCommand
    Dim LastEditedReader As SqlDataReader

    Dim LastEditedDate As String
    Dim sql As String
    LastEditedDate = "N/A"

    LastEditedConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    LastEditedConnection.Open()

    sql = GetAllProjectTables(ProjectId)

    LastEditedCommand = New SqlCommand(sql, LastEditedConnection)
    LastEditedReader = LastEditedCommand.ExecuteReader()

    While LastEditedReader.Read()
        If Not (LastEditedReader("tic_editedDate") Is DBNull.Value) Then
            If Time = True And (String.Format("{0:Ti\me: H:mm:ss}", LastEditedReader("tic_editedDate")) <> "0:00:00" Or String.Format("{0:Ti\me: H:mm:ss}", LastEditedReader("tic_editedDate")) <> "12:00:00") Then
                LastEditedDate = String.Format("{0:\Da\te: dd MMM yyy}", LastEditedReader("tic_editedDate")) & "<br/>" & String.Format("{0:Ti\me: h:mm:ss tt}", LastEditedReader("tic_editedDate"))
            Else
                LastEditedDate = String.Format("{0:dd MMM yyy}", LastEditedReader("tic_editedDate"))
            End If
            'do a date diff here and get the latest one 
        End If
    End While

    LastEditedReader.Close()
    LastEditedConnection.Close()

    Return LastEditedDate
End Function

'Params
'	Input: Integer
'	Output: String
'
'This is used to send out an sql to access all the project tables. Keeps it in one location in order to edit it

Function GetAllProjectTables(ByVal ProjectId as integer) as String
	Dim sql as String
	
	sql = "Select * from project "
    sql = sql & " Left Join ticket on tic_proId = pro_id "
    sql = sql & " Left Join ticket_note on tic_id = note_ticId "
	'add more tables in here to search through when the system has been built for the other tables
	sql = sql & " Where pro_id = '" & ProjectId & "'"
		
	return sql
End Function

'Params
'	Input: Integer, Optional Integer
'	Output: Integer
'
'This takes the ticketTypeID and the ProjectId. It will get a count of how many tickets of that type are for that project
'If there is no ticketTypeId sent to it then it will get the amount of tickets for ALL types

Function GetTicketCount(ByVal ProjectId as integer, Optional ByVal TicketTypeId as integer = 0 ) as integer
	Dim TicketCountConnection As SqlConnection
    Dim TicketCountCommand As SqlCommand
	Dim TicketCountReader As SqlDataReader
	
	Dim TicketCount as integer
	Dim sql as String
	TicketCount = 0 

	TicketCountConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    TicketCountConnection.Open()
    
    sql = "Select * from ticket "
    sql = sql & " Where tic_proId = '" & ProjectId & "'"
    
    If TicketTypeId <> 0 then 
    	sql = sql & " and tic_typeId = '" & TicketTypeId & "'"
    End If

    sql = sql & " and ( " & SqlLookupBuilder("ticket_status", "tic_status", "or", GetLookupDetails(0, "ticket_status", "Closed")) & ")"

    TicketCountCommand = New SqlCommand(sql, TicketCountConnection)
    TicketCountReader = TicketCountCommand.ExecuteReader()
            
    While TicketCountReader.Read()
    	TicketCount = TicketCount + 1
    End While

    TicketCountReader.Close()
    TicketCountConnection.Close()
	                        
	Return TicketCount
End Function

Function CharInsertion(ByVal StringToConvert As String) As String
    CharInsertion = Replace(StringToConvert, "'", "''")
End Function

Sub ViewAllTickets()
    If Request.Form("ViewAllTickets") = "View All Tickets" Then
        response.redirect("Project.aspx?project=" & request("project"))
    End If
End Sub

Sub EditTicket()
    If Request.Form("EditTicket") = "Edit Ticket" Then
        response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Ticket")
    End If
End Sub

Sub DeleteTicket()
    If Request.Form("DeleteTicket") = "Delete Ticket" Then
        response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Delete=Ticket")
    End If
End Sub

Sub CancelAction()
    If Request.Form("CancelAction") = "Cancel" Then
        response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket"))
    End If
End Sub

Sub SaveTicket()
    If Request.Form("SaveTicket") = "Save" Then
        If request("Description") <> "" Then
            Dim SaveTicketConnection As SqlConnection
            Dim SaveTicketCommand As SqlCommand
            Dim SaveTicketReader As SqlDataReader
            Dim SaveTicket As Integer

            Dim StatusChange As String = ""
            Dim PriorityChange As String = ""
            Dim AssigneeChange As String = ""
            Dim TypeChange As String = ""

            Dim sql As String

            SaveTicketConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
            SaveTicketConnection.Open()

            sql = "Select * from ticket"
            sql = sql & " where tic_id = '" & request("ticket") & "'"

            SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
            SaveTicketReader = SaveTicketCommand.ExecuteReader()

            While SaveTicketReader.read()
                If Request("StatusDropDown") <> SaveTicketReader("tic_status") Then
                    StatusChange = SaveTicketReader("tic_status")
                End If

                If Request("PriorityDropDown") <> SaveTicketReader("tic_priority") Then
                    PriorityChange = SaveTicketReader("tic_priority")
                End If

                If Request("AssignedToDropDown") <> SaveTicketReader("tic_assignedTo") Then
                    AssigneeChange = SaveTicketReader("tic_assignedTo")
                End If

                If Request("TypeDropDown") <> SaveTicketReader("tic_typeId") Then
                    TypeChange = SaveTicketReader("tic_typeId")
                End If
            End While

            SaveTicketReader.close()

            Dim TicketDetails As String
            TicketDetails = "StatusChange=" & StatusChange & "," & "PriorityChange=" & PriorityChange & "," & "AssigneeChange=" & AssigneeChange & "," & "TypeChange=" & TypeChange

            LogAction("EditTicket", request("project"), request("ticket"), 0, request("Description"), TicketDetails)

            If StatusChange <> "" Then
                sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Status Changed from " & GetLookupDetails(StatusChange) & " to " & GetLookupDetails(Request("StatusDropDown")) & "')"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicket = SaveTicketCommand.ExecuteNonQuery()
            End If

            If PriorityChange <> "" Then
                sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Priority Changed from " & GetLookupDetails(PriorityChange) & " to " & GetLookupDetails(Request("PriorityDropDown")) & "')"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicket = SaveTicketCommand.ExecuteNonQuery()
            End If

            If AssigneeChange <> "" Then
                sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Assignee Changed from " & GetLookupDetails(AssigneeChange) & " to " & GetLookupDetails(Request("AssignedToDropDown")) & "')"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicket = SaveTicketCommand.ExecuteNonQuery()
            End If

            If TypeChange <> "" Then
                sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Type Changed from " & GetLookupDetails(TypeChange) & " to " & GetLookupDetails(Request("TypeDropDown")) & "')"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicket = SaveTicketCommand.ExecuteNonQuery()
            End If

            sql = "Update ticket"
            sql = sql & " Set tic_status = '" & Request("StatusDropDown") & "'"
            sql = sql & ", tic_priority = '" & request("PriorityDropDown") & "'"
            sql = sql & ", tic_assignedTo = '" & request("AssignedToDropDown") & "'"
            sql = sql & ", tic_typeId = '" & request("TypeDropDown") & "'"
            sql = sql & ", tic_editedBy = '" & session("UserId") & "'"
            sql = sql & ", tic_editedDate = getdate()"
            sql = sql & ", tic_description = '" & request("Description") & "'"
            sql = sql & " where tic_id = '" & request("ticket") & "'"

            SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
            SaveTicket = SaveTicketCommand.ExecuteNonQuery()

            SaveTicketConnection.close()

            response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Ticket")
        Else
            Dim RedirectString As String

            RedirectString = "Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Ticket"

            If Request("StatusDropDown") <> "" Then RedirectString = RedirectString & "&RequestStatusDropDown=" & Request("StatusDropDown")
            If Request("PriorityDropDown") <> "" Then RedirectString = RedirectString & "&RequestPriorityDropDown=" & Request("PriorityDropDown")
            If Request("AssignedToDropDown") <> "" Then RedirectString = RedirectString & "&RequestAssignedToDropDown=" & Request("AssignedToDropDown")
            If Request("TypeDropDown") <> "" Then RedirectString = RedirectString & "&RequestTypeDropDown=" & Request("TypeDropDown")
            If Request("Description") <> "" Then RedirectString = RedirectString & "&RequestDescription=" & Request("Description")

            RedirectString = RedirectString & "&FieldBlank=True"

            response.redirect(RedirectString)
        End If
    End If
End Sub

Sub AddNewNote()
    If Request.Form("AddNote") = "Add New Note" Then
        response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&AddNew=Note")
    End If
End Sub

Sub SaveNote(Optional ByVal TicketID As String = "")
    If Request.Form("SaveNote") = "Save Note" Then
        If Request("Note") <> "" Then
            Dim SaveNoteConnection As SqlConnection
            Dim SaveNoteCommand As SqlCommand
            Dim SaveNote As Integer

            Dim sql As String

            SaveNoteConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
            SaveNoteConnection.Open()

            sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
            sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , '" & Request("Note") & "')"

            SaveNoteCommand = New SqlCommand(sql, SaveNoteConnection)
            SaveNote = SaveNoteCommand.ExecuteNonQuery()

            SaveNoteConnection.close()

            response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Note")
        Else
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&AddNew=Note&FieldBlank=True")
        End If
    End If

    If Request.Form("UpdateNote") = "Save Note" Then
        Dim SaveNoteConnection As SqlConnection
        Dim SaveNoteCommand As SqlCommand
        Dim SaveNote As Integer

        Dim sql As String

        SaveNoteConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        SaveNoteConnection.Open()

        sql = "Update ticket_note"
        sql = sql & " Set note_text = '" & Request("Note") & "'"
        sql = sql & ", note_editedby = '" & Session("UserId") & "'"
        sql = sql & ", note_editedDate = getdate()"
        sql = sql & " where note_id = '" & TicketID & "'"

        SaveNoteCommand = New SqlCommand(sql, SaveNoteConnection)
        SaveNote = SaveNoteCommand.ExecuteNonQuery()

        SaveNoteConnection.close()

        response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Note")
    End If
End Sub

Sub EditNote(ByVal testing As Integer)
    If Request.Form("EditNote") = "Edit Note" Then
        response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Note" & "&NoteId=" & request("NoteId"))
    End If
End Sub

Sub AddNewTicket()
    If Request.Form("AddTicket") = "Add New Ticket" Then
        response.redirect("Project.aspx?project=" & request("project") & "&AddNew=Ticket")
    End If

    If Request.Form("SaveTicket") = "Save Ticket" Then
        If Request("Description") <> "" Or request("TicketName") <> "" Then
            Dim SaveNoteConnection As SqlConnection
            Dim SaveNoteCommand As SqlCommand
            Dim SaveNote As Integer

            Dim sql As String

            SaveNoteConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
            SaveNoteConnection.Open()

            sql = "Insert ticket (tic_proId, tic_name, tic_assignedTo, tic_addedBy, tic_addedDate, tic_typeID, tic_status, tic_priority, tic_description)"
            sql = sql & " Values( '" & Request("project") & "' , '" & request("TicketName") & "', '" & request("AssignedToDropDown") & "' , '" & session("UserID") & "', getdate(), "
            sql = sql & " '" & request("TypeDropDown") & "', '" & GetLookupDetails(0, "ticket_status", "New") & "' , '" & Request("PriorityDropDown") & "', '" & request("description") & "')"

            SaveNoteCommand = New SqlCommand(sql, SaveNoteConnection)
            SaveNote = SaveNoteCommand.ExecuteNonQuery()

            SaveNoteConnection.close()

            response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Ticket")
        Else
            Dim RedirectString As String

            RedirectString = "Project.aspx?project=" & request("project") & "&AddNew=Ticket"

            If Request("TicketName") <> "" Then RedirectString = RedirectString & "&RequestTicketName=" & Request("TicketName")
            If Request("AssignedToDropDown") <> "" Then RedirectString = RedirectString & "&RequestAssignedToDropDown=" & Request("AssignedToDropDown")
            If Request("TypeDropDown") <> "" Then RedirectString = RedirectString & "&RequestTypeDropDown=" & Request("TypeDropDown")
            If Request("PriorityDropDown") <> "" Then RedirectString = RedirectString & "&RequestPriorityDropDown=" & Request("PriorityDropDown")
            If Request("Description") <> "" Then RedirectString = RedirectString & "&RequestDescription=" & Request("Description")
            RedirectString = RedirectString & "&FieldBlank=True"

            response.redirect(RedirectString)
        End If
    End If
End Sub

Sub WatchTicket()
    If Request.Form("StartWatching") = "Watch Ticket" Then
        Dim StartWatchingConnection As SqlConnection
        Dim StartWatchingCommand As SqlCommand
        Dim StartWatching As Integer

        Dim sql As String

        LogAction("StartWatchingTicket", request("project"), request("ticket"))

        StartWatchingConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        StartWatchingConnection.Open()

        sql = "Insert ticket_watched (twat_ticid, twat_conId, twat_addedDate, twat_addedBy)"
        sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate(), '" & session("UserID") & "')"

        StartWatchingCommand = New SqlCommand(sql, StartWatchingConnection)
        StartWatching = StartWatchingCommand.ExecuteNonQuery()

        StartWatchingConnection.close()

        response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket"))
    ElseIf Request.Form("StopWatching") = "Stop Watching Ticket" Then
        Dim StopWatchingConnection As SqlConnection
        Dim StopWatchingCommand As SqlCommand
        Dim StopWatching As Integer

        Dim sql As String

        LogAction("StopWatchingTicket", request("project"), request("ticket"))

        StopWatchingConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        StopWatchingConnection.Open()

        sql = "Delete from ticket_watched where twat_ticId = '" & request("ticket") & "' and twat_conId = '" & Session("UserID") & "'"

        StopWatchingCommand = New SqlCommand(sql, StopWatchingConnection)
        StopWatching = StopWatchingCommand.ExecuteNonQuery()

        StopWatchingConnection.close()

        response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket"))
    End If
End Sub