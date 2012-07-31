'Params
'	Input: Integer
'	Output: String
'
'This takes the Ticket Id and gives out the project name in a hyperlink 

Function GetTicketName(ByVal TicketId as string) as string
	Dim TicketNameConnection As SqlConnection
    Dim TicketNameCommand As SqlCommand
    Dim TicketNameReader As SqlDataReader
    
    Dim sql as string
    Dim TicketName as string
   
    TicketNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    TicketNameConnection.Open()
    
    sql = "Select * from ticket "
    sql = sql & " Where tic_id = '" & TicketId & "'"
   
    TicketNameCommand = New SqlCommand(sql, TicketNameConnection)
    TicketNameReader = TicketNameCommand.ExecuteReader()
    
    If TicketNameReader.hasrows() then
    	While TicketNameReader.Read()
            TicketName = "<a href = 'project.aspx?project=" & TicketNameReader("tic_proId") & "&Ticket=" & TicketNameReader("tic_id") & "'>" & TicketNameReader("tic_name") & "</a>"
    	End While
    Else
    	TicketName = ""
    End if
            
    TicketNameReader.Close()
    TicketNameConnection.Close()
    
    Return TicketName
End Function

Function IsWatcher(ByVal TicketId As String) As Boolean
    Dim IsWatcherConnection As SqlConnection
    Dim IsWatcherCommand As SqlCommand
    Dim IsWatcherReader As SqlDataReader

    Dim sql As String
    Dim IsWatcherBool As Boolean = False

    IsWatcherConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    IsWatcherConnection.Open()

    sql = "Select * from ticket_watched "
    sql = sql & " Where twat_ticID = '" & TicketId & "' and twat_conID = '" & Session("UserID") & "'"

    IsWatcherCommand = New SqlCommand(sql, IsWatcherConnection)
    IsWatcherReader = IsWatcherCommand.ExecuteReader()

    If IsWatcherReader.hasrows() Then
        IsWatcherBool = True
    Else
        IsWatcherBool = False
    End If

    IsWatcherReader.Close()
    IsWatcherConnection.Close()

    Return IsWatcherBool
End Function
