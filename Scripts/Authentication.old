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


<%-- 'Params:
'    Input:Session Variable UserID
'    Output:
'
'This is for restricted Pages
'This Expects to have a user session id. If it doesnt then it redirects them to the login page
'if it finds the variable and it matches to their contact id in the contact tabel then the seesion if refeshed and they continue
--%>