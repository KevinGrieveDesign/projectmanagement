<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/EditPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script language="VB" runat ="server" src = "Scripts/Contact.vb"/>
<script language="VB" runat ="server" src = "Scripts/Security.vb"/>
<script language="VB" runat ="server" src = "Scripts/General.vb"/>
<script language="VB" runat ="server" src = "Scripts/Project.vb"/>
<script language="VB" runat ="server" src = "Scripts/Ticket.vb"/>

<asp:Content ID="Box1" ContentPlaceHolderID="Box1" Runat="Server">     	     
    <br /><h1>Projects</h1>

    <table width = "100%" border = "1">
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
                    <td colspan = "6">You do not have access to any Projects</td>
                </tr>    
        <%  End If
            
            ProjectsReader.Close()
            ProjectsConnection.Close()%>
        </tbody>
    </table>
</asp:Content>

<asp:Content ID="Box2" ContentPlaceHolderID="Box2" Runat="Server">     
    <br /><h1>Relationships</h1>     
 
    <table border = "1" width = "100%">
        <thead>
            <tr>
                <th>#</th>
                <th>Type</th>
                <th>To</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Description</th>
            </tr>
        </thead>
        
        <tbody>
        <%  Dim RelationshipsConnection As SqlConnection
            Dim RelationshipsCommand As SqlCommand
            Dim RelationshipsReader As SqlDataReader
           
            Dim sql As String
            
            Dim x As Integer
            x = 1
   
            RelationshipsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
            RelationshipsConnection.Open()
                        
            sql = "Select * from relationship Where (" & SqlLookupBuilder("relationship_type", "rel_typeId", "or") & ")"
            sql = sql & " and rel_contactIdA = '" & Session("UserID") & "'"
            sql = sql & " and rel_isActive = 'True'"
            
            RelationshipsCommand = New SqlCommand(sql, RelationshipsConnection)
            RelationshipsReader = RelationshipsCommand.ExecuteReader()
            
            If RelationshipsReader.HasRows Then
                While RelationshipsReader.Read()
                     If (x Mod 2 = 0) = False Then%>
	                    <tr>
                <%  Else%>
	                    <tr class = "AlternateRow">
                <%  end if %>

                        <td>
	                    <%  Response.Write(x)
	                        x = x + 1%>	  
	                    </td>

                        <td><% If Not (RelationshipsReader("rel_typeId") Is DBNull.Value) Then Response.Write(GetLookupDetails(RelationshipsReader("rel_typeId"))) else Response.Write("N/A")%> </td>
                        <td><% If Not (RelationshipsReader("rel_contactIdB") Is DBNull.Value) Then Response.Write(GetContactName(RelationshipsReader("rel_contactIdB"))) Else Response.Write("N/A")%> </td>
                        <td><% If Not (RelationshipsReader("rel_startdate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy}", RelationshipsReader("rel_startdate"))) Else Response.Write("N/A")%>&nbsp;</td>
                        <td><% If Not (RelationshipsReader("rel_enddate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy}", RelationshipsReader("rel_enddate"))) Else Response.Write("N/A")%>&nbsp;</td>
                        <td><% If Not (RelationshipsReader("rel_description") Is DBNull.Value) Then Response.Write(RelationshipsReader("rel_description")) else Response.Write("N/A")%>&nbsp;</td>
                    </tr>
            <%  End While
            Else%>
                <tr>
                    <td colspan = "6">You do not have any Relationships</td>
                </tr>
        <%  End If
            
            RelationshipsReader.Close()
            RelationshipsConnection.Close()%>
        </tbody>
    </table>
</asp:Content>

<asp:Content ID="Box3" ContentPlaceHolderID="Box3" Runat="Server">     
    <h1>Open Tickets</h1>

<%  Dim x as integer

	For x = 0 To 2
		Dim Employee as boolean
		
		Employee = CheckRelationship(5, GetLookupDetails(0, "relationship_type", "Employee of"))
		
		If (x = 0 and Employee = True) or x > 0 then
	        if x = 0 then%>
	            <h2>Assigned</h2>
	    <%  ElseIf x = 1 Then%>
	            <h2>Watched</h2>            
	    <%  else %>
	            <h2>Added</h2>            
	    <%  End If%>
	
	        <table border = "1" width = "100%">
	            <thead>
	                <tr>
	                    <th colspan = "7" class = "InvsibleRow">&nbsp;</th>
	       	            <th colspan = "2">Added</th>
	       	            <th colspan = "2">Last Edited</th>
	                </tr>
	            
	                <tr>
	                    <th>#</th>
	                    <th>Project</th>
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
	           
	                Dim sql As String
	                Dim OpenTicketTypes As String
	                OpenTicketTypes = ""
	            
	                Dim y As Integer
	                y = 1
	
	                TicketsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
	                TicketsConnection.Open()
	                
	                OpenTicketTypes = SqlLookupBuilder("ticket_status", "tic_status", "or", GetLookupDetails(0, "ticket_status", "Closed"))
	                
	                If x = 0 Then
	                    sql = "Select * from ticket "
	                    sql = sql & " Where tic_assignedTo = '" & Session("UserID") & "' "
	                ElseIf x = 1 Then	                    
	                    sql = " Select * from ticket inner join ticket_watched "
	                    sql = sql & " on tic_id = twat_ticId "
	                    sql = sql & " Where twat_conId = '" & Session("UserID") & "'"
	                Else                   
	                    sql = "Select * from ticket "
	                    sql = sql & " Where tic_addedBy = '" & Session("UserID") & "'"
	                End If
	                
	                sql = sql & "and (" & OpenTicketTypes & ")"      
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
		                    
	                    	<td><%  If Not (TicketsReader("tic_proId") Is DBNull.Value) Then Response.Write(GetProjectName(TicketsReader("tic_proId"))) Else Response.Write("N/A")%> </td>                        
	                        <td><%  If Not (TicketsReader("tic_id") Is DBNull.Value) Then Response.Write(GetTicketName(TicketsReader("tic_id"))) Else Response.Write("N/A")%></td>
	                        <td><%  If Not (TicketsReader("tic_status") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_status"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_priority") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_priority"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_typeID") Is DBNull.Value) Then Response.Write(GetLookupDetails(TicketsReader("tic_typeID"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_assignedTo") Is DBNull.Value) Then Response.Write(GetContactName(TicketsReader("tic_assignedTo"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_addedby") Is DBNull.Value) Then Response.Write(GetContactName(TicketsReader("tic_addedby"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_addedDate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_addedDate"))) Else Response.Write("N/A")%>&nbsp;</td>
	                        <td><%  If Not (TicketsReader("tic_editedby") Is DBNull.Value) Then Response.Write(GetContactName(TicketsReader("tic_editedby"))) Else Response.Write("N/A")%> </td>
	                        <td><%  If Not (TicketsReader("tic_editedDate") Is DBNull.Value) Then Response.Write(String.Format("{0:dd MMM yyy}", TicketsReader("tic_editedDate"))) Else Response.Write("N/A")%>&nbsp;</td>
	                    </tr>
	            <%  End While
	        
	                TicketsReader.Close()
	                TicketsConnection.Close()
	                        
	                If y = 1 Then%>
	                    <tr>
	                    <%  If x = 0 Then%>
	                            <td colspan = "11">There are no Tickets Assigned to you</td>
	                    <% else if x = 1 %>
	                            <td colspan = "11">There are no Tickets Watched by you</td>
	                    <%  Else%>
	                            <td colspan = "11">There are no Tickets Added by you</td>
	                    <% end if %>
	                    </tr>
	            <%  end if %>
	            </tbody>        
	        </table>
	<%  End if
    Next%>           
</asp:Content>

<asp:Content ID="Box4" ContentPlaceHolderID="Box4" Runat="Server">    
<%  if AllowAction("viewLogs",1) then %>

    <h1>Recent Activity</h1>    
    
<%  end if %>
</asp:Content>

