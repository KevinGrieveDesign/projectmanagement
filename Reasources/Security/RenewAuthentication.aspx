<%@ Import Namespace="System.Data.SqlClient" %>

<%  Dim AuthenticationCheckConn As SqlConnection
    Dim AuthenticationCheckCommand As SqlCommand
    Dim AuthenticationCheckReader As SqlDataReader
        
    Dim SqlString As String
        
    If Session("UserID") <> 0 Then
        AuthenticationCheckConn = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("PEConnectionString").ToString())
        AuthenticationCheckConn.Open()
                                                  
        SqlString = " SELECT * "
        SqlString = SqlString & " FROM  pe_contact "
        SqlString = SqlString & " where con_id = '" & Session("UserID") & "'"
                                          
        AuthenticationCheckCommand = New SqlCommand(SqlString, AuthenticationCheckConn)
        AuthenticationCheckReader = AuthenticationCheckCommand.ExecuteReader()
                    
        While AuthenticationCheckReader.Read()
            Session.Remove("UserID")
            Session("UserID") = AuthenticationCheckReader("Con_id")
        End While
                     
        If Not AuthenticationCheckReader.HasRows Then
            Session.Remove("UserID")
                
            Response.Redirect("PE_AUTHLogin.aspx?page=2&LoggedIn=Unknown&RenAuth=1")
        End If
                                          
        AuthenticationCheckReader.Close()
        AuthenticationCheckConn.Close()
    End If%>