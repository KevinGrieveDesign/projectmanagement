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

    sub EditTicket()
        If Request.Form("EditTicket") = "Edit Ticket" Then
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Ticket")
        end if
    End Sub

    sub DeleteTicket()
        If Request.Form("DeleteTicket") = "Delete Ticket" Then
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Delete=Ticket")
        end if
    End Sub

    sub CancelAction()
        If Request.Form("CancelAction") = "Cancel" Then
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket"))
        end if
    End Sub

    sub SaveTicket()
        If Request.Form("SaveTicket") = "Save" Then
            If request("Description") <> "" then
                Dim SaveTicketConnection As SqlConnection
                Dim SaveTicketCommand As SqlCommand
                Dim SaveTicketReader As SqlDataReader
                Dim SaveTicket as integer
           
                Dim StatusChange as string = ""
                Dim PriorityChange as string = ""
                Dim AssigneeChange as string = ""
                Dim TypeChange as string = ""   

                Dim sql As String
            
                SaveTicketConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                SaveTicketConnection.Open()

                sql = "Select * from ticket"
                sql = sql & " where tic_id = '" & request("ticket") & "'"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicketReader = SaveTicketCommand.ExecuteReader()
                
                while SaveTicketReader.read()
                    if Request("StatusDropDown") <> SaveTicketReader("tic_status") then
                        StatusChange = SaveTicketReader("tic_status")
                    End if

                    if Request("PriorityDropDown") <> SaveTicketReader("tic_priority") then
                        PriorityChange = SaveTicketReader("tic_priority")
                    End if

                    if Request("AssignedToDropDown") <> SaveTicketReader("tic_assignedTo") then
                        AssigneeChange = SaveTicketReader("tic_assignedTo")
                    End if

                    if Request("TypeDropDown") <> SaveTicketReader("tic_typeId") then
                        TypeChange = SaveTicketReader("tic_typeId")
                    End if
                end while

                SaveTicketReader.close()

                if StatusChange <> "" then
                    sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                    sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Status Changed from " & GetLookupDetails(StatusChange) & " to " & GetLookupDetails(Request("StatusDropDown")) & "')"
           
                    SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                    SaveTicket = SaveTicketCommand.ExecuteNonQuery()
                end if

                if PriorityChange <> "" then
                    sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                    sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Priority Changed from " & GetLookupDetails(PriorityChange) & " to " & GetLookupDetails(Request("PriorityDropDown")) & "')"
           
                    SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                    SaveTicket = SaveTicketCommand.ExecuteNonQuery()
                end if

                if AssigneeChange <> "" then
                    sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                    sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Assignee Changed from " & GetLookupDetails(AssigneeChange) & " to " & GetLookupDetails(Request("AssignedToDropDown")) & "')"
                               
                    SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                    SaveTicket = SaveTicketCommand.ExecuteNonQuery()
                end if

                if TypeChange <> "" then
                    sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                    sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , 'Type Changed from " & GetLookupDetails(TypeChange) & " to " & GetLookupDetails(Request("TypeDropDown")) & "')"
           
                    SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                    SaveTicket = SaveTicketCommand.ExecuteNonQuery()
                end if                              
                   
                sql = "Update ticket"
                sql = sql & " Set tic_status = '" & Request("StatusDropDown") & "'"
                sql = sql & ", tic_priority = '" & request("PriorityDropDown") & "'" 
                sql = sql & ", tic_assignedTo = '" & request("AssignedToDropDown") & "'" 
                sql = sql & ", tic_typeId = '" & request("TypeDropDown") & "'" 
                sql = sql & ", tic_editedBy = '" & session("UserId") & "'" 
                sql = sql & ", tic_editedDate = getdate()" 
                sql = sql & ", tic_description = '" & request("Description") & "'" 
                sql = sql & " where tic_id = '" & request("ticket") & "'"

                SaveTicketCommand = New SqlCommand(sql, SaveTicketConnection)
                SaveTicket = SaveTicketCommand.ExecuteNonQuery()
            
                SaveTicketConnection.close()

                response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Ticket")
            else
                Dim RedirectString as string

                RedirectString =  "Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Ticket"
                
                if Request("StatusDropDown") <> "" then RedirectString = RedirectString & "&RequestStatusDropDown=" & Request("StatusDropDown")
                if Request("PriorityDropDown") <> "" then RedirectString = RedirectString & "&RequestPriorityDropDown=" & Request("PriorityDropDown")
                if Request("AssignedToDropDown") <> "" then RedirectString = RedirectString & "&RequestAssignedToDropDown=" & Request("AssignedToDropDown")
                if Request("TypeDropDown") <> "" then RedirectString = RedirectString & "&RequestTypeDropDown=" & Request("TypeDropDown")
                if Request("Description") <> "" then RedirectString = RedirectString & "&RequestDescription=" & Request("Description")

                RedirectString = RedirectString & "&FieldBlank=True" 

                response.redirect(RedirectString)
            end if
        end if
    End Sub

    sub AddNewNote()
        If Request.Form("AddNote") = "Add New Note" Then
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&AddNew=Note")
        end if
    End Sub

    sub SaveNote(optional ByVal TicketID as string = "")
        If Request.Form("SaveNote") = "Save Note" Then
            If Request("Note") <> "" then
                Dim SaveNoteConnection As SqlConnection
                Dim SaveNoteCommand As SqlCommand
                Dim SaveNote as integer
           
                Dim sql As String
            
                SaveNoteConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                SaveNoteConnection.Open()
                   
                sql = "Insert ticket_note (note_ticId, note_addedBy, note_addedDate, note_text)"
                sql = sql & " Values( '" & Request("ticket") & "' , '" & session("UserID") & "', getdate() , '" & Request("Note") & "')"
           
                SaveNoteCommand = New SqlCommand(sql, SaveNoteConnection)
                SaveNote = SaveNoteCommand.ExecuteNonQuery()
            
                SaveNoteConnection.close()

                response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Note")
            else
                response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&AddNew=Note&FieldBlank=True")            
            end if
        end if

        if Request.Form("UpdateNote") = "Save Note" Then
            Dim SaveNoteConnection As SqlConnection
            Dim SaveNoteCommand As SqlCommand
            Dim SaveNote as integer
           
            Dim sql As String
            
            SaveNoteConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
            SaveNoteConnection.Open()
                   
            sql = "Update ticket_note"
            sql = sql & " Set note_text = '" & Request("Note") & "'"
            sql = sql & ", note_editedby = '" & Session("UserId") & "'" 
            sql = sql & ", note_editedDate = getdate()" 
            sql = sql & " where note_id = '" & TicketID & "'"

            SaveNoteCommand = New SqlCommand(sql, SaveNoteConnection)
            SaveNote = SaveNoteCommand.ExecuteNonQuery()
            
            SaveNoteConnection.close()

            response.redirect("project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Saved=Note")
        end if
    End Sub

    Sub EditNote(BYval testing as integer)
        If Request.Form("EditNote") = "Edit Note" Then
            response.redirect("Project.aspx?project=" & request("project") & "&ticket=" & request("ticket") & "&Edit=Note" & "&NoteId=" & request("NoteId"))        
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
	                                        <td><% Response.Write(GetLookupDetails(TicketsReader("tic_typeID")))%> </td>
	                                        <td><% Response.Write(GetContactName(TicketsReader("tic_assignedTo")))%> </td>
	                                        <td><% Response.Write(GetContactName(TicketsReader("tic_addedby")))%> </td>
	                                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate")))%>&nbsp;</td>
	                                        <td><% Response.Write(GetContactName(TicketsReader("tic_editedby")))%> </td>
	                                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate")))%>&nbsp;</td>
	                                    </tr>
	                            <%  End While
	        
	                                TicketsReader.Close()
	                                TicketsConnection.Close()
	                        
	                                If y = 1 Then%>
	                                    <tr>
	                                        <td colspan = "9">There are no Open Tickets for <%  response.write(GetProjectName(Request("Project"))) %></td>
	                                    </tr>
	                            <%  end if %>
	                            </tbody>        
	                        </table>
                    <%  else if AllowAction("viewProjectTicket", request("project")) and request("ticket") <> "" then %>                            
                            <input class = "Button"  type = "submit" name = "ViewAllTickets" value = "View All Tickets" onclick = "<%ViewAllTickets()%>" />

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

                            TicketsReader.close()%>

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

                                    <%  if AllowAction("deleteProjectTicket", request("project")) or AllowAction("editProjectTicket", request("project"), 0, AddedById)  %>
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
                                            RequestTicketAssignedTo = TicketsReader("tic_assignedTo")
                                        end if 

                                        if request("RequestPriorityDropDown") <> "" then 
                                            RequestTicketPriority = request("RequestPriorityDropDown")
                                        else
                                            RequestTicketPriority = TicketsReader("tic_priority")
                                        end if 

                                        if request("RequestStatusDropDown") <> "" then 
                                            RequestTicketStatus = request("RequestStatusDropDown")
                                        else
                                            RequestTicketStatus = TicketsReader("tic_status")
                                        end if 

                                        if request("RequestTypeDropDown") <> "" then 
                                            RequestTicketType = request("RequestTypeDropDown")
                                        else
                                            RequestTicketType = TicketsReader("tic_typeId")
                                        end if %>
                                        
                                        <tr>
                                            <td><%  Response.Write(GetContactName(TicketsReader("tic_addedby")))%> </td>
	                                        <td><%  Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate")))%>&nbsp;</td>
                                            <td><%  Response.Write(GetContactName(TicketsReader("tic_editedby")))%> </td>
	                                        <td><%  Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate")))%>&nbsp;</td> 
                                            
                                        <%  if request("Edit") <> "Ticket" then %>                                           
	                                            <td><%  Response.Write(GetLookupDetails(TicketsReader("tic_status")))%> &nbsp;</td>
	                                            <td><%  Response.Write(GetLookupDetails(TicketsReader("tic_priority")))%> &nbsp;</td>
	                                            <td><%  Response.Write(GetContactName(TicketsReader("tic_assignedTo")))%> &nbsp;</td>
	                                            <td><%  Response.Write(GetLookupDetails(TicketsReader("tic_typeId")))%> &nbsp;</td>
                                        <%  else%>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_status", "StatusDropDown", RequestTicketStatus, "", False, True))%>&nbsp; </td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_priority", "PriorityDropDown", RequestTicketPriority))%> &nbsp;</td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("Assigned", "AssignedToDropDown", RequestTicketAssignedTo, "", False, True))%> &nbsp;</td>
	                                            <td><%  Response.Write(BuildDynamicDropDown("ticket_type", "TypeDropDown", RequestTicketType, "", False, True))%> &nbsp;</td>                                     
                                        <%  end if %>

                                        <%  if AllowAction("deleteProjectTicket", request("project")) or AllowAction("editProjectTicket", request("project"), 0, AddedByID)  %>
                                                <td>
                                                <%  if request("Delete") <> "Ticket" and request("Edit") <> "Ticket" then %>
                                                    <%  if AllowAction("editProjectTicket", request("project"), 0, AddedByID) then %>
                                                            <input class = "Button"  type = "submit" name = "EditTicket" value = "Edit Ticket" onclick = "<%EditTicket()%>" />
                                                    <%  end if %>
                                        
                                                    <%  if AllowAction("deleteProjectTicket", request("project")) then %>
                                                            <input class = "Button"  type = "submit" name = "DeleteTicket" value = "Delete Ticket" onclick = "<%DeleteTicket()%>" />  
                                                    <%  end if %>    
                                                <%  else %>
                                                    <%  if Request("Delete") = "Ticket"
                                                            if AllowAction("deleteProjectTicket", request("project"))   %>                                
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
                                    Added Date: <%  Response.Write(String.Format("{0:dd MMM yyy &nb\sp;&nb\sp;&nb\sp; Ti\me: H:mm:ss}", TicketNotesReader("note_addedDate")))%>

                                <% if not (TicketNotesReader("note_editedBy") is dbnull.value) or not(TicketNotesReader("note_editedDate") is dbnull.value) then %>
                                        <br /><br />

                                        Edited By: <%Response.write(GetContactName(TicketNotesReader("note_editedBy"))) %><br />
                                        Edited Date: <%  Response.Write(String.Format("{0:dd MMM yyy &nb\sp;&nb\sp;&nb\sp; Ti\me: H:mm:ss}", TicketNotesReader("note_editedDate")))%>
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
                    Contact Us
                    </asp:View>
                </asp:MultiView>
            </div>
    <%  else %>
            not allowed
	<% 	end if
	end if%>
</asp:Content>

