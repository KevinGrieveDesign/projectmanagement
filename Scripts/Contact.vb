'Imports System.Data.SqlClient

'Public Class Contact
'Params
'   Input: String, String, Integer, String, String, Optional String
'        : Firstname, LastName, PrefixId, UserName, Password, Optional Phone
'        : ===From Form===
'   Output: -
'
'This Sub will take the contact Details (later will handle addresses, relationships and security) and will create a login for the user as well as the contact line
'

Sub AddContact()

End Sub

'Params
'   Input: Integer, Integer, Integer, Optional Boolean, Optional String, Optional String, Optional String
'        : ContactIDA, ContactIDB, TypeId, isActive, StartDate, EndDate, Description
'   Output: String
'   
'This is to add a relationship. It needs the ContactIdA, ContactIdB and the relationshipTypeId
'Start Date, EndDate and the desciption are all optional 
'
'If the relationship is added properly it will return a string of "True"
'If the relationhsip alread exsists it will not add it and will return "Duplication"
'If it trys to add it and it doesnt get added then it will return Fasle

Function AddRelationShip(ByVal ContactIdA As Integer, ByVal ContactIdB As Integer, ByVal RelationshipTypeId As Integer, Optional ByVal isActive As Boolean = True, Optional ByVal StartDate As String = "", Optional ByVal EndDate As String = "", Optional ByVal Decription As String = "")
    If ContactIdA = 0 Or ContactIdB = 0 Or RelationshipTypeId = 0 Then
        Throw New ArgumentNullException("Add relationship Function doesnt have necessary ID's")
    Else
        Dim AddRelationshipConnection As SqlConnection
        Dim AddRelationshipCommand As SqlCommand
        Dim AddRelationshipReader As SqlDataReader
        Dim AddRelationshipInt As Integer

        Dim sql As String
        Dim Result As String
        Result = "False"

        AddRelationshipConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        AddRelationshipConnection.Open()

        sql = "Select * from relationship"
        sql = sql & " Where rel_contactIdA = '" & ContactIdA & "'"
        sql = sql & " and rel_contactIdB = '" & ContactIdB & "'"
        sql = sql & " and rel_typeId = '" & RelationshipTypeId & "'"

        AddRelationshipCommand = New SqlCommand(sql, AddRelationshipConnection)
        AddRelationshipReader = AddRelationshipCommand.ExecuteReader()

        If AddRelationshipReader.HasRows() Then
            Result = "Duplicate"
        End If

        AddRelationshipReader.Close()

        If Result <> "Duplicate" Then
            'Add relationship here                 

        End If

        AddRelationshipReader.Close()
        AddRelationshipConnection.Close()

        Return Result
    End If
End Function

'Params
'   Input: Integer
'   Output: String
'
'This function takes the contact ID and give out the firstname & " " & lastname 
'If it is an organisation then it returns the organisation name

Function GetContactName(ByVal ContactId As String) As String
    Dim ContactName As String
    Dim ContactLink As String
    ContactName = ""

    If ContactId <> "" Then
        Dim GetContactNameConnection As sqlConnection
        Dim GetContactNameCommand As SqlCommand
        Dim GetContactNameReader As SqlDataReader

        Dim sql As String

        GetContactNameConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        GetContactNameConnection.Open()

        sql = "Select * from contact "
        sql = sql & " Where con_id = '" & ContactId & "'"

        GetContactNameCommand = New SqlCommand(sql, GetContactNameConnection)
        GetContactNameReader = GetContactNameCommand.ExecuteReader()

        While GetContactNameReader.Read()
            If Not (GetContactNameReader("con_firstname") Is DBNull.Value) Or Not (GetContactNameReader("con_lastname") Is DBNull.Value) Then
                ContactName = GetContactNameReader("con_firstName")

                If ContactName <> "" And GetContactNameReader("con_lastName") <> "" Then
                    ContactName = ContactName & " "
                End If

                ContactName = ContactName & GetContactNameReader("con_lastName")
            ElseIf GetContactNameReader("con_organisationName") <> "" Then
                ContactName = GetContactNameReader("con_organisationName")
            End If
        End While

        GetContactNameReader.Close()
        GetContactNameConnection.Close()
    End If

    If ContactName <> "" Then
        'ContactLink = "<a href = 'contact.aspx?contact=" & ContactId & "'>" & ContactName & "</a>"
        ContactLink = ContactName
    Else
        ContactLink = "N/A&nbsp;"
    End If

    Return ContactLink
End Function

'Params
'   Input: 
'   Output: String or Strng Array
'
'This will take the contacts id and spit out the primary address...maybe make it give all addresses but in an arry

Function GetAddress() As String

End Function

'Params
'   Input: Address info and contact ID
'   Output: String 
'
'This will take all the information about the address and try to add it.
'It will give feedback on if it completed.

Function AddAddress() As String

End Function

'Params
'	Input: Integer, Integer
'	Output: Boolean
'
'This takes the contact id that you want to check if the user has a relationship to and the relationship_type id 
'it will output a true/false result if the user has that relationship or not

Function CheckRelationship(ByVal ContactId As Integer, Optional ByVal RelationshipTypeId As Integer = 0) As Boolean
    Dim CheckRelationshipConnection As sqlConnection
    Dim CheckRelationshipCommand As SqlCommand
    Dim CheckRelationshipReader As SqlDataReader

    Dim sql As String
    Dim HasRelationship As Boolean
    Hasrelationship = False

    CheckRelationshipConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
    CheckRelationshipConnection.Open()

    sql = "Select * from relationship "
    sql = sql & " Where rel_contactIdA = '" & session("UserID") & "'"
    sql = sql & " and rel_contactIdB = '" & ContactId & "'"
    sql = sql & " and rel_typeId = '" & RelationshipTypeId & "'"

    CheckRelationshipCommand = New SqlCommand(sql, CheckRelationshipConnection)
    CheckRelationshipReader = CheckRelationshipCommand.ExecuteReader()

    If CheckRelationshipReader.hasrows() Then
        Hasrelationship = True
    End If

    CheckRelationshipReader.close()
    CheckRelationshipConnection.close()

    Return Hasrelationship
End Function