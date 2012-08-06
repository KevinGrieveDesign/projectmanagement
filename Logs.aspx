<%@ Page Language="VB" AutoEventWireup="false" MasterPageFile ="MasterPages/ListPage.master" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<script runat ="server">
   
</script>  

<asp:Content ID="Content" ContentPlaceHolderID="Content" Runat="Server"> 
	<h1>Logs</h1>
	
<%  Dim LogConnection as sqlconnection
	Dim LogsCommand as sqlcommand 
	Dim LogsReader as sqldatareader
	
	
	%>
	
	<table border = "1" width = "100%>
		<thead>
		
		</thead>
	<%  while LogsReader.read()%>
</asp:Content>