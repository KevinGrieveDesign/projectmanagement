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
    		TicketName = "<a href = 'project.aspx?project=" & TicketNameReader("tic_proId") & "&Ticket=" & TicketNameReader("tic_id") & "'>" & TicketNameReader("tic_name") & "<a/>"
    	End While
    Else
    	TicketName = ""
    End if
            
    TicketNameReader.Close()
    TicketNameConnection.Close()
    
    Return TicketName
End Function
