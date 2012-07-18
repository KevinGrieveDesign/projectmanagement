<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/Public.master" %>

 
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    Function IsEven(ByVal Number As Long) As Boolean
        IsEven = (Number Mod 2 = 0)
    End Function
    
    Sub Logout()
        Session.Remove("UserID")
        
        If Session("UserID") = 0 Then
            Response.Redirect("PE_AUTHLogin.aspx?page=" & Request("page") & "&LoggedOut=True")
        Else
            Response.Redirect("PE_AUTHLogin.aspx?page=" & Request("page") & "&LoggedOut=false")
        End If
    End Sub
    
    Sub LoginScript()
        If Request.Form("Login") = "Login" Then
            Dim UserAuthenticationConnection As SqlConnection
            Dim UserAuthenticationCommand As SqlCommand
            Dim UserAuthenticationReader As SqlDataReader
        
            Dim sql As String
            Dim IsAdmin As Boolean
        
            IsAdmin = False
        
            Session.Remove("UserID")
                  
            UserAuthenticationConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("PEConnectionString").ToString())
            UserAuthenticationConnection.Open()
                        
            sql = " Select * from pe_contact "
            sql = sql & " where con_UserId = '" & Request("UserName") & "' and con_password = '" & Request("Password") & "' "
                    
            UserAuthenticationCommand = New SqlCommand(sql, UserAuthenticationConnection)
            UserAuthenticationReader = UserAuthenticationCommand.ExecuteReader()
        
            If UserAuthenticationReader.HasRows Then
                While UserAuthenticationReader.Read()
                    Session("UserID") = UserAuthenticationReader("Con_id")
                
                    If UserAuthenticationReader("con_IsAdmin") = "True" Then
                        IsAdmin = True
                    End If
                End While
            Else
                UserAuthenticationReader.Close()
                UserAuthenticationConnection.Close()
            
                
                If Request("UnitPlan") = "" Then
                    Response.Redirect("PE_AUTHLogin.aspx?page=" & Request("page") & "&Credentials=Incorrect&RequestUsername=" & Request("Username"))
                Else
                    Dim RedirectString As String
                
                    RedirectString = "PE_AUTHLogin.aspx?page=" & Request("page")
                    RedirectString = RedirectString & "&Info=" & Request("Info")
                    RedirectString = RedirectString & "&Stage=4&UnitPlan=" & Request("UnitPlan")
                    RedirectString = RedirectString & "&Credentials=Incorrect&RequestUsername=" & Request("Username")
            
                    If Request("InitialYears") = "" Then
                        RedirectString = RedirectString & "&InitialYears=" & Request("InitialYears")
                    End If
                
                    If Session("UserID") = "1" Then
                        If Request("debug") <> "" Then
                            RedirectString = RedirectString & "&debug=" & Request("debug")
                        End If
                
                        If Request("Debug") <> "" Then
                            RedirectString = RedirectString & "&debug=" & Request("Debug")
                        End If
                    End If
                
                    If Request("StartingSemester") <> "" Then
                        RedirectString = RedirectString & "&StartingSemester=" & Request("StartingSemester")
                    End If
        
                    If Request("UnitLoad") <> "" Then
                        RedirectString = RedirectString & "&UnitLoad=" & Request("UnitLoad")
                    End If
            
                    If Request("CompletedUnits") <> "" Then
                        RedirectString = RedirectString & "&CompletedUnits=" & Request("CompletedUnits")
                    End If
        
                    Response.Redirect(RedirectString)
                End If
            End If
        
            UserAuthenticationReader.Close()
            UserAuthenticationConnection.Close()
        
            If Request("UnitPlan") = "" Then
                If IsAdmin = True Then
                    'Response.Redirect("PE_Dashboard.aspx?page=14")
                    Response.Redirect("PE_CoursePlanner1.aspx?page=16")
                Else
                    Response.Redirect("PE_CoursePlanner1.aspx?page=16")
                End If
            Else
                Dim RedirectString As String
                
                RedirectString = "PE_CoursePlanner4.aspx?page=16"
                RedirectString = RedirectString & "&Info=" & Request("Info")
                RedirectString = RedirectString & "&Stage=4&UnitPlan=" & Request("UnitPlan")
                RedirectString = RedirectString & "&Goto=SavePlan"
                
                If Request("InitialYears") = "" Then
                    RedirectString = RedirectString & "&InitialYears=" & Request("InitialYears")
                End If
                
                If Session("UserID") = "1" Then
                    If Request("debug") <> "" Then
                        RedirectString = RedirectString & "&debug=" & Request("debug")
                    End If
                
                    If Request("Debug") <> "" Then
                        RedirectString = RedirectString & "&debug=" & Request("Debug")
                    End If
                End If
                
                If Request("StartingSemester") <> "" Then
                    RedirectString = RedirectString & "&StartingSemester=" & Request("StartingSemester")
                End If
        
                If Request("UnitLoad") <> "" Then
                    RedirectString = RedirectString & "&UnitLoad=" & Request("UnitLoad")
                End If
            
                If Request("CompletedUnits") <> "" Then
                    RedirectString = RedirectString & "&CompletedUnits=" & Request("CompletedUnits")
                End If
        
                Response.Redirect(RedirectString)
            End If
        End If
    End Sub
</script> 

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server"> 
<%  If Request("Logout") = "True" Then
        Logout()
    End If %>

    <form id="Login" runat="server" >
        <table class = "LoginArea">        
            <tbody>
                <tr>
                    <td><h3>Username</h3></td>
                    <td><input Class = "TextBox" name="UserName" size = "25"  maxlength="100" <%if request("RequestUsername") <> "" then  %> Value="<%Response.write(Request("RequestUsername"))%>" <%end if%> /></td>
                </tr>
                <tr>
                    <td><h3>Password</h3></td>
                    <td><input Class = "TextBox" type = "password" name="Password" size = "25"  maxlength="100" /></td>
                </tr>

            <%  If Request("Credentials") = "Incorrect" Then%>
                    <tr>
                        <td>&nbsp;</td>
                        <td><span style = "color:Red;">User Name or Password is Incorrect</span></td>
                    </tr>
            <%  End If
                If Request("Credentials") = "UnitPlan" or Request("UnitPlan") <> ""  Then%>
                    <tr>
                        <td>&nbsp;</td>
                        <td><span style = "color:Red;">You Either Need to Log In or Create a Log In to Save Your Plan</span></td>
                    </tr>
            <%  end if %>
            
                <tr>
                    <td>&nbsp;</td>
                    <%  If Request("LoggedOut") = "True" Then%>
                            <td><span style = "color:Red;">Successfully Logged out</span></td>
                    <%  ElseIf Request("LoggedOut") = "False" Then%>
                            <td><span style = "color:Red;">Could not Successfully log you out</span></td>
                    <%  end if %>

                    <%  If Request("LoggedIn") = "Unknown" Then%>
                            <td><span style = "color:Red;">You must log in first to access that page.</span></td>
                    <%  end if %>
                </tr>

                <tr>
                    <td>&nbsp;</td>
                    <td>
                        <input class = "Button"  type = "submit" name = "Login" value = "Login" onclick = "<%LoginScript()%>" />
                        <%--<input class = "Button"  type = "submit" name = "SubmitStage3_5" value = "Submit Optional Units" onclick = "<%SubmitStage3_5()%>"/>--%>
                    </td>
                </tr>
            </tbody>    
        </table>
    </form>
</asp:Content>
