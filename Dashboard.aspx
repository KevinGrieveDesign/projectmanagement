<@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/EditPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script language="VB" runat ="server" src = "Reasources/Security/SecurityModel.aspx.vb"/>
<%--<script language="VB" runat ="server" src = "Reasources/Security/Authentication.aspx.vb"/>--%>

<asp:Content ID="Box1" ContentPlaceHolderID="Box1" Runat="Server">     	     
    <!--#include file="Reasources/Security/Authentication.aspx"-->       
    <h1>Projects</h1>
   
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
           
            sql = "Select * from relationship "
            sql = sql & " Left Join project on pro_id = rel_contactIdB "
            sql = sql & " Where rel_typeId = '11' and rel_contactIdA = '" & Session("UserID") & "'"
           
            ProjectsCommand = New SqlCommand(sql, ProjectsConnection)
            ProjectsReader = ProjectsCommand.ExecuteReader()
                   
            If ProjectsReader.HasRows Then
                While ProjectsReader.Read()
                    If (x Mod 2 = 0) = False Then%>
	                    <tr>
                <%  Else%>
	                    <tr class = "AlternateRow">
                <%  end if %>
	                    <td>
	                    <%  Response.Write(x)
	                        x = x + 1%>	               
	                    </td>

	                    <td><a href = "projects.aspx?project=<%  Response.Write(ProjectsReader("pro_id")) %>"><%  Response.Write(ProjectsReader("pro_name")) %></a></td>
                    
                    <%  Dim LastEditedConnection As SqlConnection
                        Dim LastEditedCommand As SqlCommand
                        Dim LastEditedReader As SqlDataReader
                    
                        Dim LastEditedBy As String
                        Dim LastEditedDate As String
                    
                        LastEditedBy = "N/A"
                        LastEditedDate = "N/A"
                    
                        LastEditedConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                        LastEditedConnection.Open()
           
                        sql = "Select * from project "
                        sql = sql & " Left Join ticket on tic_proid = pro_id "
                        'add more tables in here to search through when the system has been built for the other tabels
                        sql = sql & " Where pro_id = '" & ProjectsReader("pro_id") & "'"
                                                   
                        LastEditedCommand = New SqlCommand(sql, LastEditedConnection)
                        LastEditedReader = LastEditedCommand.ExecuteReader()
                                
                        While LastEditedReader.Read()
                            If Not (LastEditedReader("tic_editedDate") Is DBNull.Value) Then
                                LastEditedDate = LastEditedReader("tic_editedDate")
                            End If
                        
                            If Not (LastEditedReader("tic_editedBy") Is DBNull.Value) Then
                                LastEditedBy = LastEditedReader("tic_editedBy")
                            End If
                        End While

                        LastEditedReader.Close()
                    
                        If LastEditedBy <> "N/A" Then
                            sql = "Select * from contact "
                            sql = sql & " Where con_id = '" & LastEditedBy & "'"
                                                   
                            LastEditedCommand = New SqlCommand(sql, LastEditedConnection)
                            LastEditedReader = LastEditedCommand.ExecuteReader()
                                
                            While LastEditedReader.Read()
                                LastEditedBy = "<a href = 'contact.aspx?contact=" & LastEditedReader("con_id") & "'>"
                                LastEditedBy = LastEditedBy & LastEditedReader("con_firstName") & " " & LastEditedReader("con_lastName") & "</a>"
                            End While
                    
                            LastEditedReader.Close()
                        End If
                    
                        LastEditedConnection.Close()%>
                                       
                        <td>
                        <%  Response.write(GetContactName(LastEditedBy))%>
                            <br/>
                        <%  response.write(LastEditedBy)%>&nbsp;
                        </td>
                        <td><%  Response.Write(LastEditedDate)%>&nbsp;</td>

                    <%  Dim TicketCountConnection As SqlConnection
                        Dim TicketCountCommand As SqlCommand
                        Dim TicketCountReader As SqlDataReader
                    
                        Dim BugCount As Integer
                        Dim FeatureCount As Integer
                    
                        Dim BugID As Integer
                        Dim FeatureID As Integer
                    
                        BugCount = 0
                        FeatureCount = 0
                    
                        TicketCountConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                        TicketCountConnection.Open()
           
                        sql = "Select * from lookup "
                        sql = sql & " Where lup_parent = 'ticket_type'"
                                                   
                        TicketCountCommand = New SqlCommand(sql, TicketCountConnection)
                        TicketCountReader = TicketCountCommand.ExecuteReader()
                    
                        While TicketCountReader.Read()
                            If TicketCountReader("lup_child") = "Bug" Then
                                BugID = TicketCountReader("lup_id")
                            End If
                        
                            If TicketCountReader("lup_child") = "Feature" Then
                                FeatureID = TicketCountReader("lup_id")
                            End If
                        End While
                                        
                        TicketCountReader.Close()
                    
                        sql = "Select * from ticket "
                        sql = sql & " Where tic_proid = '" & ProjectsReader("pro_id") & "'"
                                                   
                        TicketCountCommand = New SqlCommand(sql, TicketCountConnection)
                        TicketCountReader = TicketCountCommand.ExecuteReader()
                                
                        While TicketCountReader.Read()
                            If Not (TicketCountReader("tic_typeID") Is DBNull.Value) Then
                            
                                If TicketCountReader("tic_typeID") = BugID Then
                                    BugCount = BugCount + 1
                                End If
                            
                                If TicketCountReader("tic_typeID") = FeatureID Then
                                    FeatureCount = FeatureCount + 1
                                End If
                            End If
                        End While

                        TicketCountReader.Close()
                        TicketCountConnection.Close()%>
                    
                        <td><% Response.Write(BugCount) %>&nbsp;</td>
                        <td><% Response.Write(FeatureCount)%>&nbsp;</td>
	                </tr>
            <%  End While
            Else%>
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
    <h1>Relationships</h1>     
 
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
            
            sql = "Select * from lookup "
            sql = sql & " Where lup_parent = 'relationship_type'"
           
            RelationshipsCommand = New SqlCommand(sql, RelationshipsConnection)
            RelationshipsReader = RelationshipsCommand.ExecuteReader()
            
            sql = ""
            
            While RelationshipsReader.Read()
                If sql <> "" Then
                    sql = sql & " or "
                End If
                    
                sql = sql & " rel_typeId = '" & RelationshipsReader("lup_id") & "'"
            End While
                           
            RelationshipsReader.Close()
                                  
            sql = "Select * from relationship Where (" & sql & ")"
            sql = sql & " and rel_contactIdA = '" & Session("UserID") & "'"
            sql = sql & " and rel_isActive = 'True'"
            
            RelationshipsCommand = New SqlCommand(sql, RelationshipsConnection)
            RelationshipsReader = RelationshipsCommand.ExecuteReader()
            
            If RelationshipsReader.HasRows Then
                While RelationshipsReader.Read()%>
                    <tr>
                        <td>
	                    <%  Response.Write(x)
	                        x = x + 1%>	               
	                    </td>

                        <td>
                        <%  Dim RelationshipNameConnection As SqlConnection
                            Dim RelationshipNameCommand As SqlCommand
                            Dim RelationshipNameReader As SqlDataReader
           
                            RelationshipNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            RelationshipNameConnection.Open()
            
                            sql = "Select * from lookup "
                            sql = sql & " Where lup_id = '" & RelationshipsReader("rel_typeId") & "'"
           
                            RelationshipNameCommand = New SqlCommand(sql, RelationshipNameConnection)
                            RelationshipNameReader = RelationshipNameCommand.ExecuteReader()
                        
                            While RelationshipNameReader.Read()
                                Response.Write(RelationshipNameReader("lup_child"))
                            End While
                        
                            RelationshipNameReader.Close()
                            RelationshipNameConnection.Close()%>&nbsp;
                        </td>

                        <td>
                        <%  Dim ContactConnection As SqlConnection
                            Dim ContactCommand As SqlCommand
                            Dim ContactReader As SqlDataReader
           
                            ContactConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            ContactConnection.Open()
            
                            sql = "Select * from contact "
                            sql = sql & " Where con_id = '" & RelationshipsReader("rel_contactIdB") & "'"
           
                            ContactCommand = New SqlCommand(sql, ContactConnection)
                            ContactReader = ContactCommand.ExecuteReader()
                        
                            While ContactReader.Read()
                                If Not (ContactReader("con_organisationName") Is DBNull.Value) Then
                                    Response.Write("<a href = 'contact.aspx?contact=" & ContactReader("con_id") & "'>" & ContactReader("con_organisationName") & "</a>")
                                Else
                                    Response.Write("<a href = 'contact.aspx?contact=" & ContactReader("con_id") & "'>" & ContactReader("con_firstname") & " " & ContactReader("con_lastname") & "</a>")
                                End If
                            End While
                        
                            ContactReader.Close()
                            ContactConnection.Close()%>&nbsp;
                        </td>

                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", RelationshipsReader("rel_startdate")))%>&nbsp;</td>
                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", RelationshipsReader("rel_enddate")))%>&nbsp;</td>

                        <td><% Response.Write(RelationshipsReader("rel_description"))%>&nbsp;</td>
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

<%  For x = 0 To 2
        if x = 0 then%>
            <h2>Assigned</h2>
    <%  ElseIf x = 1 Then%>
            <h2>Added</h2>            
    <%  else %>
            <h2>Watched</h2>            
    <%  End If%>

        <table border = "1" width = "100%">
            <thead>
                <tr>
                    <th colspan = "7" class = "InvsibleRow">&nbsp;</th>
       	            <th colspan = "2">Last Edited</th>
                </tr>
            
                <tr>
                    <th>#</th>
                    <th>Project</th>
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
            <%  Dim AssignedTicketsConnection As SqlConnection
                Dim AssignedTicketsCommand As SqlCommand
                Dim AssignedTicketsReader As SqlDataReader
           
                Dim sql As String
                Dim OpenTicketTypes As String
                OpenTicketTypes = ""
            
                Dim y As Integer
                y = 1
   
                AssignedTicketsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                AssignedTicketsConnection.Open()
                            
                sql = " Select * from lookup"
                sql = sql & " where lup_parent = 'ticket_status' and lup_child <> 'Closed'"
                
                AssignedTicketsCommand = New SqlCommand(sql, AssignedTicketsConnection)
                AssignedTicketsReader = AssignedTicketsCommand.ExecuteReader()
            
                While AssignedTicketsReader.Read()
                    If OpenTicketTypes <> "" Then
                        OpenTicketTypes = OpenTicketTypes & " or "
                    End If
                    
                    OpenTicketTypes = OpenTicketTypes & " tic_status = '" & AssignedTicketsReader("lup_id") & "' "
                End While
                
                AssignedTicketsReader.Close()
                
                If x = 0 Then
                    sql = "Select * from ticket "
                    sql = sql & " Where tic_assignedTo = '" & Session("UserID") & "' "
                ElseIf x = 1 Then
                    sql = "Select * from ticket "
                    sql = sql & " Where tic_creator = '" & Session("UserID") & "'"
                Else
                    sql = "Select * from lookup "
                    sql = sql & " Where lup_parent = 'project_relationship_type'"
                    sql = sql & " and lup_child = 'Watcher of' "
                    
                    AssignedTicketsCommand = New SqlCommand(sql, AssignedTicketsConnection)
                    AssignedTicketsReader = AssignedTicketsCommand.ExecuteReader()
            
                    While AssignedTicketsReader.Read()
                        sql = " Select * from relationship inner join ticket on tic_id = rel_contactIdB "
                        sql = sql & " Where rel_contactIdA = '" & Session("UserID") & "'"
                        sql = sql & " and rel_typeID = '" & AssignedTicketsReader("lup_id") & "' "
                    End While
                    
                    AssignedTicketsReader.Close()
                End If
                
                sql = sql & "and (" & OpenTicketTypes & ")"          
                
                AssignedTicketsCommand = New SqlCommand(sql, AssignedTicketsConnection)
                AssignedTicketsReader = AssignedTicketsCommand.ExecuteReader()
                
                While AssignedTicketsReader.Read()%>
                    <tr>
                        <td>
	                    <%  Response.Write(y)
	                        y = y + 1%>	               
	                    </td>
                    
                        <td>
                        <%  Dim ProjectNameConnection As SqlConnection
                            Dim ProjectNameCommand As SqlCommand
                            Dim ProjectNameReader As SqlDataReader
           
                            ProjectNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            ProjectNameConnection.Open()
            
                            sql = "Select * from project "
                            sql = sql & " Where pro_id = '" & AssignedTicketsReader("tic_proId") & "'"
           
                            ProjectNameCommand = New SqlCommand(sql, ProjectNameConnection)
                            ProjectNameReader = ProjectNameCommand.ExecuteReader()
            
                            While ProjectNameReader.Read()
                                Response.Write("<a href = 'project.aspx?project=" & ProjectNameReader("pro_id") & "'>" & ProjectNameReader("pro_name") & "<a/>")
                            End While
                    
                            ProjectNameReader.Close()
                            ProjectNameConnection.Close()%>&nbsp;
                        </td>

                        <td><% Response.Write("<a href = 'ticket.aspx?ticket=" & AssignedTicketsReader("tic_id") & "'>" & AssignedTicketsReader("tic_name") & "<a/>")%></td>

                        <td>
                        <%  Dim TicketStatusConnection As SqlConnection
                            Dim TicketStatusCommand As SqlCommand
                            Dim TicketStatusReader As SqlDataReader
           
                            TicketStatusConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            TicketStatusConnection.Open()
            
                            sql = "Select * from lookup "
                            sql = sql & " Where lup_id = '" & AssignedTicketsReader("tic_status") & "'"
           
                            TicketStatusCommand = New SqlCommand(sql, TicketStatusConnection)
                            TicketStatusReader = TicketStatusCommand.ExecuteReader()
                        
                            While TicketStatusReader.Read()
                                Response.Write(TicketStatusReader("lup_child"))
                            End While
                        
                            TicketStatusReader.Close()
                            TicketStatusConnection.Close()%>&nbsp;
                        </td>

                        <td>
                        <%  Dim TicketPriorityConnection As SqlConnection
                            Dim TicketPriorityCommand As SqlCommand
                            Dim TicketPriorityReader As SqlDataReader
           
                            TicketPriorityConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            TicketPriorityConnection.Open()
            
                            sql = "Select * from lookup "
                            sql = sql & " Where lup_id = '" & AssignedTicketsReader("tic_priority") & "'"
           
                            TicketPriorityCommand = New SqlCommand(sql, TicketPriorityConnection)
                            TicketPriorityReader = TicketPriorityCommand.ExecuteReader()
                        
                            While TicketPriorityReader.Read()
                                Response.Write(TicketPriorityReader("lup_child"))
                            End While
                        
                            TicketPriorityReader.Close()
                            TicketPriorityConnection.Close()%>&nbsp;
                        </td>

                        <td>
                        <%  Dim TicketAssignedToConnection As SqlConnection
                            Dim TicketAssignedToCommand As SqlCommand
                            Dim TicketAssignedToReader As SqlDataReader
           
                            TicketAssignedToConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            TicketAssignedToConnection.Open()
            
                            sql = "Select * from contact "
                            sql = sql & " Where con_id = '" & AssignedTicketsReader("tic_assignedTo") & "'"
           
                            TicketAssignedToCommand = New SqlCommand(sql, TicketAssignedToConnection)
                            TicketAssignedToReader = TicketAssignedToCommand.ExecuteReader()
                        
                            While TicketAssignedToReader.Read()
                                Response.Write("<a href = 'contact.aspx?contact=" & TicketAssignedToReader("con_id") & "'>" & TicketAssignedToReader("con_firstname") & " " & TicketAssignedToReader("con_lastname") & "<a/>")
                            End While
                        
                            TicketAssignedToReader.Close()
                            TicketAssignedToConnection.Close()%>&nbsp;
                        </td>

                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", AssignedTicketsReader("tic_creationDate")))%>&nbsp;</td>
                    
                        <td>
                        <%  Dim EditByConnection As SqlConnection
                            Dim EditByCommand As SqlCommand
                            Dim EditByReader As SqlDataReader
           
                            EditByConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
                            EditByConnection.Open()
            
                            sql = "Select * from contact "
                            sql = sql & " Where con_id = '" & AssignedTicketsReader("tic_editedby") & "'"
           
                            EditByCommand = New SqlCommand(sql, EditByConnection)
                            EditByReader = EditByCommand.ExecuteReader()
                        
                            While EditByReader.Read()
                                Response.Write("<a href = 'contact.aspx?contact=" & EditByReader("con_id") & "'>" & EditByReader("con_firstname") & " " & EditByReader("con_lastname") & "<a/>")
                            End While
                        
                            EditByReader.Close()
                            EditByConnection.Close()%>&nbsp;
                        </td>

                        <td><% Response.Write(String.Format("{0:dd MMM yyy}", AssignedTicketsReader("tic_editedDate")))%>&nbsp;</td>
                    </tr>
            <%  End While
        
                AssignedTicketsReader.Close()
                AssignedTicketsConnection.Close()
                        
                If y = 1 Then%>
                    <tr>
                    <%  If x = 0 Then%>
                            <td colspan = "9">There are no Tickets Assigned to you</td>
                    <% else if x = 1 %>
                            <td colspan = "9">There are no Tickets Added by you</td>
                    <%  Else%>
                            <td colspan = "9">There are no Tickets Watched by you</td>
                    <% end if %>
                    </tr>
            <%  end if %>
            </tbody>        
        </table>
<%  Next%>           
</asp:Content>

<asp:Content ID="Box4" ContentPlaceHolderID="Box4" Runat="Server">    
 
<%--got to the security model here and work out what permissions they have... i should create a seperate file in the security folder to handle this

what it should do is accept a param of secuirty ie where are we say are we allowed to edit a ticket then we will send editTicket
it will reply with a tru or false if that is allowed--%>

    <h1>Recent Activity</h1>    
    
       
</asp:Content>

