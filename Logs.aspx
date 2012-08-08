<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/ListPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script language="VB" runat ="server" src = "Scripts/Contact.vb"/>
<script language="VB" runat ="server" src = "Scripts/General.vb"/>
<script language="VB" runat ="server" src = "Scripts/Project.vb"/>
<script language="VB" runat ="server" src = "Scripts/Security.vb"/>

<script runat ="server">
   
</script>  

<asp:Content ID="ToolBox" ContentPlaceHolderID="Toolbox" Runat="Server"> 
    <h1>Filter Logs</h1>

    <br />

<%  dim GetFilterDetailsConnection as sqlconnection
    dim GetFilterDetailsCommand as sqlcommand
    dim GetFilterDetailsReader as sqldatareader 
    
    dim sql as string
    
    GetFilterDetailsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    GetFilterDetailsConnection.Open()%>

    <table>
        <tbody>
            <tr>
                <th width = "70">Limit</th>
                <td>&nbsp;</td>
                <td><input class = "TextBox" name="Limit" size = "5"  maxlength="100" <%if request("Limit") <> "" then  %> value="<%Response.write(Request("Limit"))%>" <%else %>  Value="50" <%end if%> /></td>
            </tr>

            <tr>
                <th>User</th>
                <td>&nbsp;</td>                
                <td>
                    <select name='" & DropDownName & "' class = 'TextBox'>
                        <option value ='' >--Please Choose--</option>
                    <%  sql = " Select * from contact "
                        sql = sql & " where con_typeID = '" & GetlookupDetails(0, "contact_type", "Individual")  & "'"
                        sql = sql & " order by con_lastName, con_firstname"
                    
                        GetFilterDetailsCommand = New SqlCommand(sql, GetFilterDetailsConnection)
                        GetFilterDetailsReader = GetFilterDetailsCommand.ExecuteReader()
                                                
                        while GetFilterDetailsReader.read()%>
                            <option value = "<%  response.write(GetFilterDetailsReader("con_id")) %>"><%  response.write(GetContactName(GetFilterDetailsReader("con_id"))) %></option>
                    <%  End while

                        GetFilterDetailsReader.close() %>
                    </select>
                </td>
            </tr>

            <tr>
                <th>Project</th>
                <td>&nbsp;</td>
                <td>
                    <select name='" & DropDownName & "' class = 'TextBox'>
                        <option value ='' >--Please Choose--</option>
                    <%  sql = " Select * from project "
                        sql = sql & " order by pro_Name"
                    
                        GetFilterDetailsCommand = New SqlCommand(sql, GetFilterDetailsConnection)
                        GetFilterDetailsReader = GetFilterDetailsCommand.ExecuteReader()
                                                
                        while GetFilterDetailsReader.read()%>
                            <option value = "<%  response.write(GetFilterDetailsReader("pro_id")) %>"><%  response.write(GetProjectName(GetFilterDetailsReader("pro_id"))) %></option>
                    <%  End while

                        GetFilterDetailsReader.close() %>
                    </select>
                </td>
            </tr>

            <tr>
                <th>Action</th>
                <td>&nbsp;</td>
                <td>
                    <select name='" & DropDownName & "' class = 'TextBox'>
                        <option value ='' >--Please Choose--</option>
                    <%  sql = " Select * from security_Items "
                        sql = sql & " order by sit_pagID"
                    
                        GetFilterDetailsCommand = New SqlCommand(sql, GetFilterDetailsConnection)
                        GetFilterDetailsReader = GetFilterDetailsCommand.ExecuteReader()
                                                
                        while GetFilterDetailsReader.read()%>
                            <option value = "<%  response.write(GetFilterDetailsReader("sit_id")) %>"><%  response.write(GetFilterDetailsReader("sit_description")) %></option>
                    <%  End while

                        GetFilterDetailsReader.close() %>
                    </select>
                </td>
            </tr>
                
            <tr>
                <td colspan = "3">&nbsp;</td>
            </tr>

            <tr>
                <td colspan = "3">
                    <input class = "Button"  type = "submit" name = "FilterLogs" value = "Filter" />
                </td>
            </tr>    
        </tbody>
    </table>
    
<%  GetFilterDetailsConnection.Close() %>
</asp:Content>

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server"> 
    <h1>Logs</h1>

    <br />

<%  Dim LogsConnection As SqlConnection
	Dim LogsCommand as sqlcommand 
	Dim LogsReader as sqldatareader
	
    Dim x As Integer
    Dim sql As String
    
    x = 1
    
    LogsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    LogsConnection.Open()

    If Request("Limit") = "" Then
        sql = "Select Top (50) * from Log"
    ElseIf Request("Limit") = "0" Then
        sql = "Select * from Log"
    Else
        sql = "Select Top (" & Request("Limit") & ") * from Log"
    End If
        
    sql = sql & " where log_conId <> '" & Session("UserID") & "' and log_conId <> ''"
    sql = sql & " order by log_addedDate desc"
                    
    LogsCommand = New SqlCommand(sql, LogsConnection)
    LogsReader = LogsCommand.ExecuteReader()%>
	
	<table border = "1" width = "100%">
		<thead>
		    <tr>
                <th>#</th>
                <th><a href = "Logs.aspx?Sort=User<%if request("Sort") = "User"%>1<%end if %>" >User</a></th> 
                <th><a href = "Logs.aspx?Sort=Project<%if request("Sort") = "User"%>1<%end if %>" >Project</a></th> 
                <th><a href = "Logs.aspx?Sort=Page<%if request("Sort") = "User"%>1<%end if %>" >Page</a></th> 
                <th><a href = "Logs.aspx?Sort=Action<%if request("Sort") = "User"%>1<%end if %>" >Action</a></th> 
                <th><a href = "Logs.aspx?Sort=Text1<%if request("Sort") = "Text1"%>1<%end if %>" >Text 1</a></th> 
                <th><a href = "Logs.aspx?Sort=Text2<%if request("Sort") = "Text2"%>1<%end if %>" >Text 2</a></th> 
                <th><a href = "Logs.aspx?Sort=AddedDate<%if request("Sort") = "AddedDate"%>1<%end if %>" >Added Date</a></th> 
            </tr>
		</thead>
        <tbody>
	    <% 	If LogsReader.HasRows() Then
	            While LogsReader.Read()
                   If (x Mod 2 = 0) = False Then%>
		                <tr>
	            <%  Else%>
		                <tr class = "AlternateRow">
	            <%  end if %>	

	                    <td>
		                <%  Response.Write(x)
		                    x = x + 1%>	               
		                </td>

                        <td><%  If Not (LogsReader("log_conId") Is DBNull.Value) Then response.write(GetContactName(LogsReader("log_conId"))) Else Response.Write("N/A") %></td>
                        <td><%  If Not (LogsReader("log_proId") Is DBNull.Value) Then response.write(GetProjectName(LogsReader("log_proId"))) Else Response.Write("N/A") %></td>
                        <td><%  If Not (LogsReader("log_pagId") Is DBNull.Value) Then response.write(GetPageName(LogsReader("log_pagId"))) Else Response.Write("N/A") %></td>
                        <td><%  If Not (LogsReader("log_Action") Is DBNull.Value) Then response.write(LogsReader("log_Action")) Else Response.Write("N/A") %></td>
                        <td><%  If Not (LogsReader("log_text1") Is DBNull.Value) Then response.write(LogsReader("log_text1")) Else Response.Write("N/A") %></td>

                    <%  If Not (LogsReader("log_text2") Is DBNull.Value) Then
                            If LogsReader("log_text2") = "True" Then%>
                                <td class = "Yes">
                		<%  Else if ViewContactUsReader("us_replied") = "False" then %>
		                        <td class = "No">
		                <%  else%>
		                		<td>
		                <%  End If
	                    Else%>
	                        <td>	                        
	                <%  End If%>
	                    
	                    <%  If Not (LogsReader("log_text2") Is DBNull.Value) Then
	                    		Response.Write(LogsReader("log_text2"))
	                        Else
	                    		Response.Write("N/A")
	                        End If%>
                        </td>
                        <td><%  If Not (LogsReader("log_addedDate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy - h:mm tt}", LogsReader("log_addedDate"))) Else Response.Write("N/A")%></td>
                    </tr>
            <%  End While
            Else%>
                <tr>
                    <td colspan = ""></td>
                </tr>
        <%  End If%>
        </tbody>
    </table>

<%  LogsReader.Close()
    LogsConnection.Close()%>
</asp:Content>