<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/EditPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    
</script>  

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
                        If Not (LastEditedReader("tic_editDate") Is DBNull.Value) Then
                            LastEditedDate = LastEditedReader("tic_editDate")
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
                                       
                    <td><%  response.write(LastEditedBy)%>&nbsp;</td>
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
       	   
            ProjectsReader.Close()
            ProjectsConnection.Close()%>
        </tbody>
    </table>
</asp:Content>

<asp:Content ID="Box2" ContentPlaceHolderID="Box2" Runat="Server">     
    <h1>Relationships</h1>       
</asp:Content>

<asp:Content ID="Box3" ContentPlaceHolderID="Box3" Runat="Server">     
    <h1>Tickets</h1>
   
    <h2>Assigned</h2>
   
   
    <h2>Added</h2>
   
   
    <h2>Watched</h2>
   
          
</asp:Content>

<asp:Content ID="Box4" ContentPlaceHolderID="Box4" Runat="Server">     
    <h1>Recent Activity</h1>       
</asp:Content>

