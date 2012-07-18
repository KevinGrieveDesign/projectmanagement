<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/Public.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    Sub Logout()
        Session.Remove("UserID")
        
        If Session("UserID") = 0 Then
            Response.Redirect("Login.aspx?LoggedOut=True")
        Else
            Response.Redirect("Login.aspx?LoggedOut=false")
        End If
    End Sub
    
    Sub LogUserIn()
        If Request.Form("Login") = "Login" Then
            If Request("UserName") <> "" And Request("Password") <> "" Then
                Dim UserAuthenticationConnection As SqlConnection
                Dim UserAuthenticationCommand As SqlCommand
                Dim UserAuthenticationReader As SqlDataReader
                Dim ra As Integer
                
                Dim sql As String
        
                Session.Remove("UserID")
                  
                UserAuthenticationConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                UserAuthenticationConnection.Open()
                        
                sql = " Select * from login inner join contact on contact.con_id = login.log_conId"
                sql = sql & " where log_userName = '" & Request("UserName") & "' and log_password = '" & Request("Password") & "'"
                    
                UserAuthenticationCommand = New SqlCommand(sql, UserAuthenticationConnection)
                UserAuthenticationReader = UserAuthenticationCommand.ExecuteReader()
                
                If UserAuthenticationReader.HasRows Then
                    While UserAuthenticationReader.Read()
                        Session("UserID") = UserAuthenticationReader("log_conId")
                    End While
                Else
                    UserAuthenticationReader.Close()
                    UserAuthenticationConnection.Close()
        
                    Response.Redirect("Login.aspx?page=1&Credentials=Incorrect&RequestUsername=" & Request("Username"))
                End If
           
                UserAuthenticationReader.Close()
                
                sql = "Update login set log_lastLogIn = getdate() where log_conId = '" & Session("UserID") & "'"
                                
                UserAuthenticationCommand = New SqlCommand(sql, UserAuthenticationConnection)
                ra = UserAuthenticationCommand.ExecuteNonQuery()
                
                UserAuthenticationConnection.Close()
        
                Response.Redirect("Dashboard.aspx")
            Else
                Response.Redirect("Login.aspx?Credentials=Incorrect")
            End If
        End If
    End Sub
</script>  

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server"> 
<%  If Request("Logout") = "True" Then
        Logout()
    End If%>
    
    <form id="Login" runat="server" >
        <div class = "LoginArea">
            <table>        
                <tbody align = "left">
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            <h1>Project Management Login</h1>
                        </td>
                    </tr>

                    <tr>
                        <td width = "70"><h3>Username</h3></td>
                        <td><input class = "TextBox" name="UserName" size = "40"  maxlength="100" <%if request("RequestUsername") <> "" then  %> Value="<%Response.write(Request("RequestUsername"))%>" <%end if%> /></td>
                    </tr>
                    <tr>
                        <td><h3>Password</h3></td>
                        <td><input class = "TextBox" type = "password" name="Password" size = "40"  maxlength="100" /></td>
                    </tr>

                <%  Dim MessageDisplayed As Boolean
    
                    MessageDisplayed = False
            
                    If Request("Credentials") = "Incorrect" Then
                        MessageDisplayed = true%>
                        <tr>
                            <td>&nbsp;</td>
                            <td class = "Message">User Name or Password is Incorrect</td>
                        </tr>
                <%  End If %>

                <%  If Request("LoggedOut") <> "" Or Request("LoggedOut") <> "" Or Request("LoggedIn") <> "" Then
                        MessageDisplayed = True%>
                        <tr>
                            <td>&nbsp;</td>

                        <%  If Request("LoggedOut") = "True" Then%>
                                <td class = "Message">Successfully Logged out</td>
                        <%  ElseIf Request("LoggedOut") = "False" Then%>
                                <td class = "Message">Could not Successfully log you out</td>
                        <%  elseIf Request("LoggedIn") = "Unknown" Then%>
                                <td class = "Message">You must log in first to access that page</td>
                        <%  end if %>
                        </tr> 
                <%  End If %> 
                        
                <%  If MessageDisplayed = False Then%>
                        <tr>
                            <td colspan = "2">&nbsp;</td>
                        </tr>
                <%  end if %>
                    <tr>
                        <td>&nbsp;</td>

                        <td align = "left">
                            <input class = "Button"  type = "submit" name = "Login" value = "Login" onclick = "<%LogUserIn()%>" />
                        </td>
                    </tr>
                </tbody>    
            </table>
        </div>
    </form>
</asp:Content>