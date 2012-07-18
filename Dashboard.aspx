<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/EditPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
    
</script>  

<asp:Content ID="Box1" ContentPlaceHolderID="Box1" Runat="Server">     
	<!--#include file="Reasources/Security/Authentication.aspx"--> 
	     
   <h1>Projects</h1>
   
   <table>
       <thead>+
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
           
           Dim sql as string
           
           Dim x as integer
           x = 1
   
           ProjectsConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
           ProjectsConnection.Open()
           
           'sql = "Select * from relationships "
           'sql = sql & " Left Join projects pro_id 
           
           ProjectsCommand = New SqlCommand(sql, ProjectsConnection)
           ProjectsReader = ProjectsCommand.ExecuteReader()
                                
           While ProjectsReader.Read()%>
	           <tr>
	               <td>
	               <%  Response.Write(x)
	                   x = x + 1  %>	               
	               </td>
	               <td></td>
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

