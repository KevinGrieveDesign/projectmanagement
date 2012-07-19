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
        ContactLink = "<a href = 'contact.aspx?contact=" & ContactId & "'>" & ContactName & "</a>"
    Else
        ContactLink = "&nbsp;"
    End If

    Return ContactLink
End Function

    'Params
    '   Input: Optional Integer, Optional String, Optional String
    '   Output: String
    '
    'This Function takes the lookup id and returns the lup_child
    'If there is no LookupId then it will use the lup_parent and lup_child to get and return the lup_id

Function GetLookupDetails(Optional ByVal LookupId As Integer = 0, Optional ByVal LookupParent As String = "", Optional ByVal LookupChild As String = "") As String
    Dim LookupConnection As SqlConnection
    Dim LookupCommand As SqlCommand
    Dim LookupReader As SqlDataReader

    Dim sql As String

    If LookupId <> 0 Then
        LookupConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        LookupConnection.Open()

        sql = "Select * from lookup"
        sql = sql & " Where lup_id = '" & LookupId & "'"

        LookupCommand = New SqlCommand(sql, LookupConnection)
        LookupReader = LookupCommand.ExecuteReader()

        While LookupReader.Read()
            LookupChild = LookupReader("lup_child")
        End While

        LookupReader.Close()
        LookupConnection.Close()

        Return LookupChild
    ElseIf LookupParent <> "" And LookupChild <> "" Then
        LookupConnection = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("ProjectsConnection").ToString())
        LookupConnection.Open()

        sql = "Select * from lookup"
        sql = sql & " Where lup_parent  = '" & LookupParent & "'"
        sql = sql & " and lup_child = '" & LookupChild & "'"

        LookupCommand = New SqlCommand(sql, LookupConnection)
        LookupReader = LookupCommand.ExecuteReader()

        While LookupReader.Read()
            LookupId = LookupReader("lup_id")
        End While

        LookupReader.Close()
        LookupConnection.Close()

        Return LookupId
    Else
        Throw New ArgumentNullException("Could Not get Required Params for Lookup Function")
    End If
End Function

