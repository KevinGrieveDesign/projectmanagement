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
    
    While ProjectNameReader.Read()
    	ProjectName = "<a href = 'project.aspx?project=" & ProjectNameReader("pro_id") & "'>" & ProjectNameReader("pro_name") & "<a/>"
    End While
            
    ProjectNameReader.Close()
    ProjectNameConnection.Close()
    
    Reutrn ProjectName
End Function﻿

'Params
'	Input:
'	Output: 
'
'