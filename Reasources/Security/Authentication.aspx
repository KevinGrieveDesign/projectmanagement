<%@ Import Namespace="System.Data.SqlClient" %>

<%  Dim AuthenticationCheckConn As SqlConnection
    Dim AuthenticationCheckCommand As SqlCommand
    Dim AuthenticationCheckReader As SqlDataReader
        
    Dim SqlString As String
        
    If Session("UserID") <> 0 Then
        AuthenticationCheckConn = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        AuthenticationCheckConn.Open()
                                                  
        SqlString = " SELECT * "
        SqlString = SqlString & " FROM contact "
        SqlString = SqlString & " where con_id = '" & Session("UserID") & "'"
                                          
        AuthenticationCheckCommand = New SqlCommand(SqlString, AuthenticationCheckConn)
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
    Else
        Response.Redirect("Login.aspx?LoggedIn=Unknown")
    End If%>
