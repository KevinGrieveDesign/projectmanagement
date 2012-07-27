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
    
    If ProjectNameReader.hasrows() then
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

    LastEditedBy = ""

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
            If Time = True Then
                LastEditedDate = String.Format("{0:dd MMM yyy &nb\sp;&nb\sp;&nb\sp; Ti\me: H:mm:ss}", LastEditedReader("tic_editedDate"))
            Else
                LastEditedDate = String.Format("{0:dd MMM yyy}", LastEditedReader("tic_editedDate"))
            End If
            ' do a date diff here and get the latest one 
        End If
    End While

    LastEditedReader.Close()
    LastEditedConnection.Close()

    Return LastEditedDate
End Function

'Params
'	Input: Integer
'	Ouput: String
'
'This is used to send out an sql to access all the project tables. Keeps it in one location in order to edit it

Function GetAllProjectTables(ByVal ProjectId as integer) as String
	Dim sql as String
	
	sql = "Select * from project "
    sql = sql & " Left Join ticket on tic_proid = pro_id "
    sql = sql & " Left Join ticket_note on tic_id = note_ticId "
	'add more tables in here to search through when the system has been built for the other tabels
	sql = sql & " Where pro_id = '" & ProjectId & "'"
		
	return sql
End Function

'Params
'	Input: Integer, Optional Integer
'	Ouput: Integer
'
'This takes the ticketTypeID and the ProjectId. It will get a count of how many tickets of that type are for that project
'If there is no ticketTypeId sent to it then it will get the amount of tickets for ALL types

Function GetTicketCount(ByVal ProjectId as integer, Optional ByVal TicketTypeId as integer = 0 ) as integer
	Dim TicketCountConnection As SqlConnection
    Dim TicketCountCommand As SqlCommand
	Dim TicketCountReader As SqlDataReader
	
	DIm TicketCount as integer
	Dim sql as String
	TicketCount = 0 

	TicketCountConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    TicketCountConnection.Open()
    
    sql = "Select * from ticket "
    sql = sql & " Where tic_proid = '" & ProjectId & "'"
    
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