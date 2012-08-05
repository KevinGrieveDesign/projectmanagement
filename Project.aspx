<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/ListPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    Sub Menu1_MenuItemClick(ByVal sender As Object, ByVal e As MenuEventArgs)
        LogAction("ChangeProjectTab", Request("project"), 0, 0, "StartTab=" & MultiView1.ActiveViewIndex, "EndTab=" & Int32.Parse(e.Item.Value))
        Dim index As Integer = Int32.Parse(e.Item.Value)
        MultiView1.ActiveViewIndex = index
    End Sub
</script>

<script language="VB" runat ="server" src = "Scripts/Contact.vb"/>
<script language="VB" runat ="server" src = "Scripts/Security.vb"/>
<script language="VB" runat ="server" src = "Scripts/General.vb"/>
<script language="VB" runat ="server" src = "Scripts/Project.vb"/>
<script language="VB" runat ="server" src = "Scripts/Ticket.vb"/>

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server">     
<% If Request("project") = "" Then
        LogAction("ViewProjectDashboard", Request("project"))%>
	
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
	                            <td><%  Response.Write(ProjectLastEditedBy(ProjectsReader("pro_id")))%></td>
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
        If AllowAction("", Request("project")) Then%>

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
 <%--                    <asp:MenuItem Text="Pages"  Value="2"  />
                    <asp:MenuItem Text="Repository" Value="3" />  
                    <asp:MenuItem Text="Features" Value="4" />
                    <asp:MenuItem Text="Roles" Value-"5" --%>
                </Items>  
            </asp:Menu>
   
            <div class="tabContents">
                <asp:MultiView id="MultiView1" ActiveViewIndex="0" Runat="server">
                           
               
<%-- -------------------------------------------------------------------------------------------------------------------
--------------------------------------------View 1 - Activities-----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------- --%>
                    <asp:View ID="View1" runat="server">
                    <%  Dim ViewProjectTicket As String
                        ViewProjectTicket = AllowAction("viewProjectTicket", Request("project"))

                        If ViewProjectTicket = "True" And Request("ticket")  = "" Then%>
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
	                                            <td><%  Response.Write(ProjectLastEditedDate(ProjectsReader("pro_id"), True))%>&nbsp;</td>                        
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
	       	                            <th colspan = "2">Added</th>
	       	                            <th colspan = "2">Last Edited</th>
	                                </tr>
	            
	                                <tr>
	                                    <th>#</th>
	                                    <th>Name</th>
	                                    <th>Status</th>
	                                    <th>Priority</th>
                                        <th>Type</th>
	                                    <th>Assigned</th>
                                        <th>User</th>
	                                    <th>Date</th>
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
	                
	                                OpenTicketTypes = SqlLookupBuilder("ticket_status", "tic_status", "or", GetLookupDetails(0, "ticket_status", "Closed") & "," & GetLookupDetails(0, "ticket_status", "Rejected"))
	                
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
		                    
	                                        <td><%  Response.Write(GetTicketName(TicketsReader("tic_id")))%></td>
	                                        <td><%  If Not (TicketsReader("tic_status") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_status"))) Else Response.Write("N/A")%> </td>
	                                        <td><%  If Not (TicketsReader("tic_priority") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_priority"))) Else Response.Write("N/A")%> </td>
	                                        <td><%  If Not (TicketsReader("tic_typeID") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_typeID"))) Else Response.Write("N/A")%> </td>
	                                        <td><%  If Not (TicketsReader("tic_assignedTo") Is DBNull.Value) Then Response.Write(GetContactName(TicketsReader("tic_assignedTo"))) Else Response.Write("N/A")%> </td>
	                                        <td><%  If Not (TicketsReader("tic_addedby") Is DBNull.Value) Then Response.Write(GetContactName(TicketsReader("tic_addedby"))) Else Response.Write("N/A")%> </td>
	                                        <td><%  If Not (TicketsReader("tic_addedDate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate"))) Else Response.Write("N/A")%>&nbsp;</td>
	                                        <td><%  If not(TicketsReader("tic_editedby") is dbnull.value) then Response.Write(GetContactName(TicketsReader("tic_editedby")))  Else Response.Write("N/A")%></td>
                                            <td><%  If not(TicketsReader("tic_editedDate") is dbnull.value) then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate"))) Else Response.Write("N/A")%> </td>
	                                    </tr>
	                            <%  End While
	        
	                                TicketsReader.Close()
	                                TicketsConnection.Close()
	                        
	                                If y = 1 Then%>
	                                    <tr>
	                                        <td colspan = "10">There are no Open Tickets for <%  response.write(GetProjectName(Request("Project"))) %></td>
	                                    </tr>
	                            <%  end if %>
	                            </tbody>        
	                        </table>

                        <%  if AllowAction("addProjectTicket", request("project")) then
                                if request("AddNew") = "Ticket" then
                                    dim RequestTicketPriority as string
                                
                                    if request("RequestTicketPriority") <> "" then 
                                        RequestTicketPriority = request("RequestTicketPriority")
                                    else
                                        RequestTicketPriority = GetLookupDetails(0, "ticket_priority", "Normal")
                                    end if
                            %>
                                    <br /><br /><hr /><br />                                 
                                
                                    <table border = "1" width = "100%">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
	                                            <th>Priority</th>
                                                <th>Type</th>
	                                            <th>Assigned</th>
                                            </tr>                                    
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td><input Class = "TextBox" name="TicketName"   maxlength="100"  size = "85" <% If Request("RequestTicketName") <> "" Then%> Value="<%Response.write(Request("RequestTicketName"))%>" <%end if%>/></td>                                            
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_priority", "PriorityDropDown", RequestTicketPriority))%> &nbsp;</td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_type", "TypeDropDown", request("RequestTicketType")))%> &nbsp;</td>     
	                                            <td><%  Response.Write(BuildDynamicDropDown("Assigned", "AssignedToDropDown", request("RequestTicketAssignedTo")))%> &nbsp;</td>                                                 
                                            </tr>
                                        </tbody>

                                        <tfoot>
                                            <tr>
                                                <td colspan = "4"><textarea class = "TextBox" name="Description"  cols="151" rows="12"><%Response.Write(request("requestdescription"))%></textarea></td>
                                            </tr>
                                        </tfoot>
                                    </table>
                            <%  end if  %>

                                <br /><br /><hr /><br />                                 

                            <%  if request("AddNew") = "Ticket" then %>
                                    <input class = "Button"  type = "submit" name = "SaveTicket" value = "Save Ticket" onclick = "<%AddNewTicket()%>" />                                                    
                                    <input class = "Button"  type = "submit" name = "CancelAction" value = "Cancel" onclick = "<%CancelAction()%>" />  
                            <%  else %>
                                    <input class = "Button"  type = "submit" name = "AddTicket" value = "Add New Ticket" onclick = "<%AddNewTicket()%>" />                                                                                         
                            <%  end if   
                            end if                            
                        ElseIf ViewProjectTicket <> "" Then
                            LogAction("ViewProjectTicket", Request("project"), Request("ticket"))%>                          
                                                           
                            <div align = left style = "float:left;">                        
                                <input class = "Button"  type = "submit" name = "ViewAllTickets" value = "View All Tickets" onclick = "<%ViewAllTickets()%>" />
                            </div>   
                                                  
                            <div align = right style = "float:right;"> 
                            <%  if IsWatcher(request("ticket")) then %>
                                    <input class = "Button"  type = "submit" name = "StopWatching" value = "Stop Watching Ticket" onclick = "<%WatchTicket()%>" />                                                    
                            <%  else %>
                                    <input class = "Button"  type = "submit" name = "StartWatching" value = "Watch Ticket" onclick = "<%WatchTicket()%>" />
                            <%  end if %>
                            </div>                         

                            <br /><br /><br />   

                            <h2><%  Response.write(GetTicketName(request("ticket"))) %></h2>

                        <%  Dim TicketsConnection As SqlConnection
	                        Dim TicketsCommand As SqlCommand
	                        Dim TicketsReader As SqlDataReader
	           	                    
                            Dim Description as string = "N/A"
                            Dim sql as string

                            Dim RequestTicketStatus as string
                            Dim RequestTicketType as string
                            Dim RequestTicketAssignedTo as string
                            Dim RequestTicketPriority as string

                            Dim AddedById as integer = 0 
                                    
	                        TicketsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
	                        TicketsConnection.Open()
                                                        	               
	                        sql = "Select * from ticket "
	                        sql = sql & " where tic_id = '" & request("ticket") & "'"
	                
	                        TicketsCommand = New SqlCommand(sql, TicketsConnection)
	                        TicketsReader = TicketsCommand.ExecuteReader() 

                            while TicketsReader.read()
                                AddedById = TicketsReader("tic_addedBy")
                            end while

                            TicketsReader.Close()
                              
                            Dim DeleteProjectTicket As Boolean = AllowAction("deleteProjectTicket", Request("project"))
                            Dim EditProjectTicket As Boolean = AllowAction("editProjectTicket", Request("project"), 0, AddedById)%>

                            <table border = "1" width = "100%" >
                                <thead>
                                    <tr>
                                        <th colspan = "2">Added</th>
                                        <th colspan = "2">Last Edited</th>
                                    </tr>
                                    <tr>
                                        <th>User</th>
                                        <th>Date</th>
                                        <th>User</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Priority</th>
                                        <th>Assigned To</th>
                                        <th>Ticket Type</th>

                                    <%  If DeleteProjectTicket Or EditProjectTicket Then%>
                                            <th>Action</th>
                                   <%   end if%>

                                    </tr>
                                </thead>
                                <tbody>
                                
                                <%  sql = "Select * from ticket "
	                                sql = sql & " where tic_id = '" & request("ticket") & "'"
	                
	                                TicketsCommand = New SqlCommand(sql, TicketsConnection)
	                                TicketsReader = TicketsCommand.ExecuteReader() 
                                
                                    while TicketsReader.read()
                                        if not(TicketsReader("tic_description") is dbnull.value) then
                                            Description = TicketsReader("tic_description")
                                        end if 
                                        
                                        if request("RequestAssignedToDropDown") <> "" then 
                                            RequestTicketAssignedTo = request("RequestAssignedToDropDown")
                                        else
                                            if not(TicketsReader("tic_assignedTo") is dbnull.value) then 
                                                RequestTicketAssignedTo = TicketsReader("tic_assignedTo")
                                            End if
                                        end if 

                                        if request("RequestPriorityDropDown") <> "" then 
                                            RequestTicketPriority = request("RequestPriorityDropDown")
                                        else
                                            if not(TicketsReader("tic_priority") is dbnull.value) then 
                                                RequestTicketPriority = TicketsReader("tic_priority")
                                            end if
                                        end if 

                                        if request("RequestStatusDropDown") <> "" then 
                                            RequestTicketStatus = request("RequestStatusDropDown")
                                        else
                                            if not(TicketsReader("tic_status") is dbnull.value) then 
                                                RequestTicketStatus = TicketsReader("tic_status")
                                            end if
                                        end if 

                                        if request("RequestTypeDropDown") <> "" then 
                                            RequestTicketType = request("RequestTypeDropDown")
                                        else
                                            if not(TicketsReader("tic_typeId") is dbnull.value) then 
                                                RequestTicketType = TicketsReader("tic_typeId")
                                            end if
                                        end if %>
                                        
                                        <tr>
                                            <td><%  if not(TicketsReader("tic_addedby") is dbnull.value) then Response.Write(GetContactName(TicketsReader("tic_addedby"))) else Response.write("N/A")%> </td>
	                                        <td><%  if not(TicketsReader("tic_addedDate") is dbnull.value) then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate"))) else Response.write("N/A")%>&nbsp;</td>
                                            <td><%  if not(TicketsReader("tic_editedby") is dbnull.value) then Response.Write(GetContactName(TicketsReader("tic_editedby"))) else Response.write("N/A")%></td>
	                                        <td><%  if not(TicketsReader("tic_editedDate") is dbnull.value) then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate"))) else Response.write("N/A")%>&nbsp;</td> 
                                            
                                        <%  if request("Edit") <> "Ticket" then %>                                           
	                                            <td><%  if not(TicketsReader("tic_status") is dbnull.value) then Response.Write(GetLookupDetails(TicketsReader("tic_status"))) else Response.write("N/A")%> &nbsp;</td>
	                                            <td><%  if not(TicketsReader("tic_priority") is dbnull.value) then Response.Write(GetLookupDetails(TicketsReader("tic_priority"))) else Response.write("N/A")%> &nbsp;</td>
	                                            <td><%  if not(TicketsReader("tic_assignedTo") is dbnull.value) then Response.Write(GetContactName(TicketsReader("tic_assignedTo"))) else Response.write("N/A")%> &nbsp;</td>
	                                            <td><%  if not(TicketsReader("tic_typeId") is dbnull.value) then Response.Write(GetLookupDetails(TicketsReader("tic_typeId"))) else Response.write("N/A")%> &nbsp;</td>
                                        <%  else%>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_status", "StatusDropDown", RequestTicketStatus, "", False, True))%>&nbsp; </td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_priority", "PriorityDropDown", RequestTicketPriority))%> &nbsp;</td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("Assigned", "AssignedToDropDown", RequestTicketAssignedTo, "", False, True))%> &nbsp;</td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_type", "TypeDropDown", RequestTicketType, "", False, True))%> &nbsp;</td>                                     
                                        <%  end if %>

                                        <%  If DeleteProjectTicket Or EditProjectTicket Then%>
                                                <td>
                                                <%  if request("Delete") <> "Ticket" and request("Edit") <> "Ticket" then %>
                                                    <%  if EditProjectTicket then %>
                                                            <input class = "Button"  type = "submit" name = "EditTicket" value = "Edit Ticket" onclick = "<%EditTicket()%>" />
                                                    <%  end if %>
                                        
                                                    <%  If DeleteProjectTicket Then%>
                                                            <%--<input class = "Button"  type = "submit" name = "DeleteTicket" value = "Delete Ticket" onclick = "<%DeleteTicket()%>" />  --%>
                                                    <%  end if %>    
                                                <%  else %>
                                                    <%  if Request("Delete") = "Ticket"
                                                            if DeleteProjectTicket then  %>                                
                                                            <input class = "Button"  type = "submit" name = "DeleteConfirmed" value = "Confirm Delete" onclick = "<%DeleteTicket()%>" />  
                                                        <%  end if
                                                        else if Request("Edit") = "Ticket"%>                                        
                                                            <input class = "Button"  type = "submit" name = "SaveTicket" value = "Save" onclick = "<%SaveTicket()%>" />  
                                                    <%  end if %>

                                                        <input class = "Button"  type = "submit" name = "CancelAction" value = "Cancel" onclick = "<%CancelAction()%>" />  
                                                <%  end if %>
                                                </td>
                                        <%   end if%>
                                        </tr>                                                                   
                                <%  end while
                            
                                    TicketsReader.close()
                                    TicketsConnection.close() 
                                    
                                    if Request("RequestDescription") <> "" then 
                                        Description = Request("RequestDescription")
                                    end if%>
                                </tbody>    
                            </table>

                            <br /><br />

                            <table border = "1" width = "100%">
                                <thead>
                                    <tr>
                                        <th>Description</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                    <%  If request("Edit") <> "Ticket" then %>
                                            <td height = "200px" style = "vertical-align:top;"><br />
                                    <%  else %>
                                            <td style = "vertical-align:top;">
                                    <%  end if  
                                                                               
                                        If request("Edit") <> "Ticket" then 
                                            Response.write(Description) 
                                        else %>
                                            <textarea class = "TextBox" name="Description"  cols="151" rows="12"><%Response.Write(description)%></textarea>
                                    <%  end if %>
                                        </td>
                                    </tr>                                
                                </tbody>
                            </table>

                            <h2>Notes</h2>

                        <%  Dim TicketNotesReaderConnection As SqlConnection
	                        Dim TicketNotesReaderCommand As SqlCommand
	                        Dim TicketNotesReader As SqlDataReader	
                            
                            Dim x as integer
                            x = 1           	               
                               
                            TicketNotesReaderConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
	                        TicketNotesReaderConnection.Open()
	                
	                        sql = "Select * from ticket_note "
	                        sql = sql & " where note_ticId = '" & request("ticket") & "'"
                            sql = sql & " order by note_addedDate"
	                
	                        TicketNotesReaderCommand = New SqlCommand(sql, TicketNotesReaderConnection)
	                        TicketNotesReader = TicketNotesReaderCommand.ExecuteReader() 
                                
                            if TicketNotesReader.hasrows() then
                                while TicketNotesReader.read() 
                                    if request("Edit") = "Note" and request("NoteId") = TicketNotesReader("note_id") then %>
                                        <textarea class = "TextBox" name="Note"  cols="154" rows="12"><%  response.write(TicketNotesReader("note_text"))%></textarea>   
                                <%  else
                                        response.write(TicketNotesReader("note_text"))                                         
                                    end if %>

                                    <br /><br />

                                    Added By: <%Response.write(GetContactName(TicketNotesReader("note_addedBy"))) %><br />
                                    Added Date: <%  Response.Write(String.Format("{0:dd MMM yyy &nb\sp;&nb\sp;&nb\sp; Ti\me: h:mm tt}", TicketNotesReader("note_addedDate")))%>

                                <% if not (TicketNotesReader("note_editedBy") is dbnull.value) or not(TicketNotesReader("note_editedDate") is dbnull.value) then %>
                                        <br /><br />

                                        Edited By: <%Response.write(GetContactName(TicketNotesReader("note_editedBy"))) %><br />
                                        Edited Date: <%  Response.Write(String.Format("{0:dd MMM yyy &nb\sp;&nb\sp;&nb\sp; Ti\me: h:mm tt}", TicketNotesReader("note_editedDate")))%>
                                <%  end if 
                                
                                    if AllowAction("editTicketNote", request("project"), 0, TicketNotesReader("note_addedBy")) then %>
                                        <div align = "right">
                                        <%  if request("Edit") <> "Note" or Request("NoteID") <> TicketNotesReader("note_id") then%>
                                                <input class = "Button"  type = "button" name = "EditNote" value = "Edit Note" onclick = "location.href='Project.aspx?project=<%response.write(request("project"))%>&ticket=<%response.write(request("ticket"))%>&Edit=Note&NoteId=<%response.write(TicketNotesReader("note_id"))%>'" /> 
                                        <%  else if Request("NoteID") = TicketNotesReader("note_id")%>
                                                <input class = "Button"  type = "submit" name = "UpdateNote" value = "Save Note" onclick = "<%SaveNote(TicketNotesReader("note_id"))%>" />  
                                                <input class = "Button"  type = "submit" name = "CancelAction" value = "Cancel" onclick = "<%CancelAction()%>" />
                                        <%  end if%> 
                                        </div>
                                <%  else %>
                                        <br /><br />
                                <%  end if%>

                                    <hr /><br />
                        <%      end while

                                if request("AddNew") = "Note" then %>
                                    <textarea class = "TextBox" name="Note"  cols="154" rows="12"><%Response.Write(request("RequestNote"))%></textarea>   
                                    
                                    <br /><br /><hr /><br />                                 
                            <%  end if 
                            Else
                                If request("AddNew") <> "Note" %>
                                    No notes Availiable for <%  response.write(GetTicketName(Request("ticket")))     
                                else if request("AddNew") = "Note" then %>
                                    <textarea class = "TextBox" name="Note"  cols="154" rows="12"></textarea>                                                                   
                            <%  end if %>

                                <br /><br /><hr /><br />
                        <%  end if

                            TicketNotesReader.close()
                            TicketNotesReaderConnection.close() 

                            If request("AddNew") <> "Note" %>
                                <input class = "Button"  type = "submit" name = "AddNote" value = "Add New Note" onclick = "<%AddNewNote()%>" />  
                        <%  else %>
                                <input class = "Button"  type = "submit" name = "SaveNote" value = "Save Note" onclick = "<%SaveNote()%>" />  
                                <input class = "Button"  type = "submit" name = "CancelAction" value = "Cancel" onclick = "<%CancelAction()%>" />                          
                        <%  end if %>

                    <%  else %>
                            You do not have access to view the tickets for ths project
                    <%  end if %>

                        <br /><br />
                    </asp:View>
                    
                    <asp:View ID="View2" runat="server">
                    Content
                    </asp:View>
                    <asp:View ID="View3" runat="server">
                    Pages
                    </asp:View>
                    <asp:View ID="View4" runat="server">
                    Repo
                    </asp:View>
                    <asp:View ID="View5" runat="server">
                    Features
                    </asp:View>
                    <asp:View ID="View6" runat="server">
                    <%  if AllowAction("viewProjectRelationships", request("project")) then %>
                    		<table width = "100%" border = "1">
                    			<thead>
                    				<tr>
                    					<th colspan = "3" class = "InvisibleRow">&nbsp;</th>
                    					<th>Added</th>
                    				</tr>
                    				
                    				<tr>
                    					<th>#</th>
                    					<th>Name</th>
                    					<th>Role</th>
                    					<th>User</th>
                    					<th>Date</th>
                					</tr>                					
                    			</thead>
                    			<tbody>
                    				<tr>
                    				
                    				</tr>
                    			</tbody>
                    		<table>
                    <%  end if %>
                    </asp:View>
                </asp:MultiView>
            </div>
    <%  else %>
            not allowed
	<% 	end if
	end if%>
</asp:Content>

