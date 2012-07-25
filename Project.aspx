<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/ListPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script language="VB" runat ="server" src = "Scripts/Contact.vb"/>
<script language="VB" runat ="server" src = "Scripts/Security.vb"/>
<script language="VB" runat ="server" src = "Scripts/General.vb"/>
<script language="VB" runat ="server" src = "Scripts/Project.vb"/>
<script language="VB" runat ="server" src = "Scripts/Ticket.vb"/>

<asp:Content ID="Box1" ContentPlaceHolderID="Box1" Runat="Server">     
<%  if request("project") = "" then %>
	
	<h1>Projects</h1>

	<table = border = "1" width = "100%" >
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
<%  else
		if AllowAction("",request("project")) then%>
			<h1><%  Response.write(GetProjectName(request("project"))) %></h1>
			
		<%  Dim GetProjectOwnerConnection as sqlConnection
			Dim GetProjectOwnerCommand as sqlcommand
			Dim GetProjectOwnerReader as sqldataReader
			
			Dim sql as string %>
			<h2><%  'Response.write(%></h2>




	<% 	end if
	end if%>
</asp:Content>

