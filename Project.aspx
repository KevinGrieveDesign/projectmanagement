<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/ListPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    Sub Menu1_MenuItemClick(ByVal sender As Object, ByVal e As MenuEventArgs)
        Dim index As Integer = Int32.Parse(e.Item.Value)
        MultiView1.ActiveViewIndex = index
    End Sub
    
    Function CharInsertion(ByVal StringToConvert As String) As String
        CharInsertion = Replace(StringToConvert, "'", "''")
    End Function
  
    Sub ViewAllTickets()
        If Request.Form("ViewAllTickets") = "View All Tickets" Then
            response.redirect("Project.aspx?project=" & request("project"))
        end if
    End Sub

 </script>  

<script language="VB" runat ="server" src = "Scripts/Contact.vb"/>
<script language="VB" runat ="server" src = "Scripts/Security.vb"/>
<script language="VB" runat ="server" src = "Scripts/General.vb"/>
<script language="VB" runat ="server" src = "Scripts/Project.vb"/>
<script language="VB" runat ="server" src = "Scripts/Ticket.vb"/>

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server">     
<% ' RenewSession()
    
    If Request("project") = "" Then%>
	
	    <h1>Projects</h1>

	    <table border = "1" width = "100%" >
		    <thead>
			    <tr>
       	            <th colspan = "2" class = "InvsibleRow">&nbsp;</th>
       	            <th colspan = "2">Last Edited</th>       	    
       	            <th colspan = "2">Open Tickets</th>
       	        </tr>
       	        
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th>User</th>
                    <th>Date</th>
                    <th>Bugs</th>
                    <th>Features</th>               
                </tr>
		    </thead>
		
		    <tbody>
		    <%  Dim ProjectsConnection As SqlConnection
                Dim ProjectsCommand As SqlCommand
                Dim ProjectsReader As SqlDataReader
           
                Dim sql As String
            
                Dim x As Integer
                x = 1
   
                ProjectsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                ProjectsConnection.Open()
           
                sql = "Select * from project"
                     
                ProjectsCommand = New SqlCommand(sql, ProjectsConnection)
                ProjectsReader = ProjectsCommand.ExecuteReader()
                   
                If ProjectsReader.HasRows Then
                    While ProjectsReader.Read()
                        If AllowAction("", ProjectsReader("pro_id")) Then
                            If (x Mod 2 = 0) = False Then%>
		                        <tr>
	                    <%  Else%>
		                        <tr class = "AlternateRow">
	                    <%  end if %>
	                
		                        <td>
		                        <%  Response.Write(x)
		                            x = x + 1%>	               
		                        </td>

                                <td><%  Response.write(GetProjectName(ProjectsReader("pro_id"))) %>&nbsp;</td>	                    
	                            <td><%  Response.Write(ProjectLastEditedBy(ProjectsReader("pro_id")))%> </td>
	                            <td><%  Response.Write(ProjectLastEditedDate(ProjectsReader("pro_id")))%>&nbsp;</td>                        
	                            <td><%  Response.Write(GetTicketCount(ProjectsReader("pro_id"), GetLookupDetails(0, "ticket_type", "Bug"))) %>&nbsp;</td>
	                            <td><%  Response.Write(GetTicketCount(ProjectsReader("pro_id"), GetLookupDetails(0, "ticket_type", "Feature"))) %>&nbsp;</td>
		                    </tr>
                    <%  End If
                    End While
                End If
            
                If x = 1 then%>
                    <tr>
                        <td colspan = "6">You do not have access to any Projects. Click <a href = "Dashboard.aspx">Here</a> to return to the dashboard</td>
                    </tr>    
            <%  End If
            
                ProjectsReader.Close()
                ProjectsConnection.Close()%> 	
		    </tbody>
	    </table>
<%  else
		if AllowAction("",request("project")) then%>
			<h1><%  Response.write(GetProjectName(request("project"))) %></h1><br />
			
		<%  Dim GetProjectOwnerConnection as sqlConnection
			Dim GetProjectOwnerCommand as sqlcommand
			Dim GetProjectOwnerReader as sqldataReader
			
			Dim sql as string %>

            <asp:Menu id="Menu1" Orientation="Horizontal" 
                      StaticSelectedStyle-CssClass="selectedTab" Runat="server"
                      CssClass="tabs" OnMenuItemClick="Menu1_MenuItemClick"   StaticMenuItemStyle-CssClass="tab"  RenderingMode = "Table" >

                <Items>
                    <asp:MenuItem Text="Tickets"  Value="0"  />
                    <asp:MenuItem Text="Content" Value="1" />    
                    <asp:MenuItem Text="Pages"  Value="2"  />
                    <asp:MenuItem Text="Repository" Value="3" />  
                    <asp:MenuItem Text="Features" Value="4" /> 
                    <asp:MenuItem Text="Contact Us" Value="5" /> 
                </Items>  
            </asp:Menu>
   
            <div class="tabContents">
                <asp:MultiView id="MultiView1" ActiveViewIndex="0" Runat="server">
                           
               
<%-- -------------------------------------------------------------------------------------------------------------------
--------------------------------------------View 1 - Activities-----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------- --%>
                    <asp:View ID="View1" runat="server">
                    <%  if AllowAction("viewProjectTicket", request("project")) and request("ticket") = "" then %>
                            <h1>Summary</h1>
                                <table width = "100%" border = "1">
                                    <thead>
       	                                <tr>
       	                                    <th colspan = "2">Last Edited</th>       	     
       	                                    <th colspan = "2">Open Tickets</th>
       	                                </tr>
       	        
                                        <tr>
                                            <th>User</th>
                                            <th>Date</th>
                                            <th>Bugs</th>
                                            <th>Features</th>               
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <%  Dim ProjectsConnection As SqlConnection
                                        Dim ProjectsCommand As SqlCommand
                                        Dim ProjectsReader As SqlDataReader
           
                                        Dim sql As String
            
                                        Dim x As Integer
                                        x = 1
   
                                        ProjectsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                                        ProjectsConnection.Open()
           
                                        sql = "Select * from project"
                                        sql = sql & " where pro_id = '" & request("project") & "'"
                     
                                        ProjectsCommand = New SqlCommand(sql, ProjectsConnection)
                                        ProjectsReader = ProjectsCommand.ExecuteReader()
                   
                                        If ProjectsReader.HasRows Then
                                            While ProjectsReader.Read()
                                                If (x Mod 2 = 0) = False Then%>
		                                            <tr>
	                                        <%  Else%>
		                                            <tr class = "AlternateRow">
	                                        <%  end if %>
	                                                <td><%  Response.Write(ProjectLastEditedBy(ProjectsReader("pro_id")))%> </td>
	                                                <td><%  Response.Write(ProjectLastEditedDate(ProjectsReader("pro_id")))%>&nbsp;</td>                        
	                                                <td><%  Response.Write(GetTicketCount(ProjectsReader("pro_id"), GetLookupDetails(0, "ticket_type", "Bug"))) %>&nbsp;</td>
	                                                <td><%  Response.Write(GetTicketCount(ProjectsReader("pro_id"), GetLookupDetails(0, "ticket_type", "Feature"))) %>&nbsp;</td>
		                                        </tr>
                                        <%  End While
                                        End If
                                                    
                                        ProjectsReader.Close()
                                        ProjectsConnection.Close()%>
                                    </tbody>
                                </table>
                            <h1>Open Tickets</h1>

                            <table border = "1" width = "100%">
	                            <thead>
	                                <tr>
	                                    <th colspan = "6" class = "InvsibleRow">&nbsp;</th>
	       	                            <th colspan = "2">Last Edited</th>
	                                </tr>
	            
	                                <tr>
	                                    <th>#</th>
	                                    <th>Name</th>
	                                    <th>Status</th>
	                                    <th>Priority</th>
	                                    <th>Assigned</th>
	                                    <th>Created Date</th>
	                                    <th>User</th>
	                                    <th>Date</th>
	                                </tr>        
	                            </thead>
	                            <tbody>
	                            <%  Dim TicketsConnection As SqlConnection
	                                Dim TicketsCommand As SqlCommand
	                                Dim TicketsReader As SqlDataReader
	           
	                                Dim OpenTicketTypes As String
	                                OpenTicketTypes = ""
	            
	                                Dim y As Integer
	                                y = 1
	
	                                TicketsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
	                                TicketsConnection.Open()
	                
	                                OpenTicketTypes = SqlLookupBuilder("ticket_status", "tic_status", "or", GetLookupDetails(0, "ticket_status", "Closed"))
	                
	                                sql = "Select * from ticket "
	                                sql = sql & " where (" & OpenTicketTypes & ")" 
                                    sql = sql & " and tic_proId = '" & request("project") & "'"     
	                                sql = sql & " order by tic_addedDate "                   
	                
	                                TicketsCommand = New SqlCommand(sql, TicketsConnection)
	                                TicketsReader = TicketsCommand.ExecuteReader()
	                
	                                While TicketsReader.Read()
	                                     If (y Mod 2 = 0) = False Then%>
		                                    <tr>
	                                <%  Else%>
		                                    <tr class = "AlternateRow">
	                                <%  end if %>
	
	                                        <td>
		                                    <%  Response.Write(y)
		                                        y = y + 1%>	               
		                                    </td>
		                    
	                                        <td><% Response.Write(GetTicketName(TicketsReader("tic_id")))%></td>
	                                        <td><% Response.Write(GetLookupDetails(TicketsReader("tic_status")))%> </td>
	                                        <td><% Response.Write(GetLookupDetails(TicketsReader("tic_priority")))%> </td>
	                                        <td><% Response.Write(GetContactName(TicketsReader("tic_assignedTo")))%> </td>
	                                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate")))%>&nbsp;</td>
	                                        <td><% Response.Write(GetContactName(TicketsReader("tic_editedby")))%> </td>
	                                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate")))%>&nbsp;</td>
	                                    </tr>
	                            <%  End While
	        
	                                TicketsReader.Close()
	                                TicketsConnection.Close()
	                        
	                                If y = 1 Then%>
	                                    <tr>
	                                        <td colspan = "8">There are no Open Tickets for <%  response.write(GetProjectName(Request("Project"))) %></td>
	                                    </tr>
	                            <%  end if %>
	                            </tbody>        
	                        </table>
                    <%  else if AllowAction("viewProjectTicket", request("project")) and request("ticket") <> "" then %>                            
                            <input class = "Button"  type = "submit" name = "ViewAllTickets" value = "View All Tickets" onclick = "<%ViewAllTickets()%>" />

                            <h2><%  response.write(GetTicketName(request("ticket"))) %></h2>

                            <table border = "1" width = "100%" >
                                <thead>
                                    <tr>
                                        <th>Description</th>
                                    </tr>
                                </thead>
                          
                            <%  Dim TicketsConnection As SqlConnection
	                            Dim TicketsCommand As SqlCommand
	                            Dim TicketsReader As SqlDataReader
	           	
                                Dim sql as string

	                            TicketsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
	                            TicketsConnection.Open()
	                
	                            sql = "Select * from ticket "
	                            sql = sql & " where tic_id = '" & request("ticket") & "'"
	                
	                            TicketsCommand = New SqlCommand(sql, TicketsConnection)
	                            TicketsReader = TicketsCommand.ExecuteReader() 
                                
                                while TicketsReader.read()%>
                                    <tbody>
                                        <tr>
                                            <td><%  response.write(TicketsReader("tic_description")) %></td>
                                        </tr>
                                    </tbody>
                                    <tfoot style = "text-align:left;" >
                                        <tr>
                                            <td>Added By: <%  response.write(GetContactName(TicketsReader("tic_addedBy"))) %>
                                            <br />
                                            Date Added: <% Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate")))%></td>
                                        </tr>
                                    </tfoot>
                            <%  end while
                            
                                TicketsReader.close()
                                TicketsConnection.close() %>
                            </table>




                    <%  else %>
                            You do not have access to view the tickets for ths project
                    <%  end if %>
                    </asp:View>



                    <asp:View ID="View2" runat="server">
                    D
                    </asp:View>
                    <asp:View ID="View3" runat="server">
                    D
                    </asp:View>
                    <asp:View ID="View4" runat="server">
                    D
                    </asp:View>
                    <asp:View ID="View5" runat="server">
                    D
                    </asp:View>
                </asp:MultiView>
            </div>
    <%  else %>
            not allowed
	<% 	end if
	end if%>
</asp:Content>

