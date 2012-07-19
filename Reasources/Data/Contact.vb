Public Class Contact
    
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

    Sub AddRelationShip(ByVal ContactIdA as intger, ByVal ContactIdB as integer, ByVal RelationshipTypeId as intger, Optional ByVal isActive as boolean = True, Optional ByVal StartDate as string = "", Optional ByVal EndDate as string, Optional ByVal Decription as string = "" )
        If ContactIdA = 0 or ContactIdB = 0 or RelationshipTypeId = 0 then 
            Throw New ArgumentNullException("Add relationship Function doesnt have necessary ID's")
        Else
            Dim AddRelationshipConnection as sqlconnection
            Dim AddRelationshipCommand as sqlcommand
            Dim AddRelationshipReader as sqlDataReader
            Dim AddRelationship as Integer

            Dim sql as string
            Dim Result as string
            Result = "False"

            AddRelationshipConnection = New SqlConnection(System.Configuration.ConfiguationManager.ConnectionStrings("ProjectsConnection").ToString())
            AddRelationshipConnection.Open()

            sql = "Select * from relationship"
            sql = sql & " Where rel_contactIdA = '" & ContactIdAD & "'"
            sql = sql & " and rel_contactIdB = '" & ContactIdB & "'"
            sql = sql & " and rel_typeId = '" & RelationshipTypeId & "'"            

            AddRelationshipCommand = New SqlCommand(sql, AddRelationshipConnection)
            AddRelationshipReader = AddRelationshipCommand.ExecuteReader()

            If AddRelationshipReader.HasRows() then 
                Result = "Duplicate"
            End If
            
            AddRelationshipReader.Close()
    
            If Result <> "Duplicate" then 
                'Add relationship here                 
                
            End If

            AddRelationshipReader.Close()
            AddRelationshipConnection.Close()            

            Return Result  
        End If
    End Sub

    'Params
    '   Input: Integer
    '   Output: String
    '
    'This function takes the contact ID and give out the firstname & " " & lastname 
    'If it is an organisation then it returns the organisation name

    Function GetContactName(ByVal ContactId as integer) as string
        Dim ContactName as string
        ContactName = ""

        If ContactId <> "" then
            Dim GetContactNameConnection as sqlConenction
            Dim GetContactNameCommand as sqlcommand
            Dim GetContactNameReader as sqlDataReader

            Dim sql as string

            GetContactNameConnection = New SqlConnection(System.Configuration.ConfiguationManager.ConnectionStrings("ProjectsConnection").ToString())
            GetContactNameConnection.Open()

            sql = "Select * from contact"
            sql = sql & " Where con_id = '" & ContactID & "'"
            
            GetContactNameCommand = New SqlCommand(sql, GetContactNameConnection)
            GetContactNameReader = GetContactNameCommand.ExecuteReader()
            
            While GetContactNameReader.read()
                If GetContactNameReader("con_firstname") <> "" or GetContactNameReader("con_lastname") <> "" then
                    ContactName = GetContactNameReader("con_firstName")

                    If ContactName <> "" and GetContactNameReader("con_lastName") <> "" then 
                        ContactName = ContactName & " "
                    End if

                    ContatcName = ContactName & GetContactNameReader("con_lastName")
                Else if GetContactNameReader("con_organisationName") <> "" then
                    ContactName = GetContactNameReader("con_organisationName")
                End If
            End While
        
            GetContactNameReader.Close()
            GetContactNameConnection.Close()
        Else
            Throw New ArgumentNullException("No ContactID given to GetContactName")
        End if
        
        if ContactName <> "" then 
            ContactLink = "<a href = 'contact.aspx?contact=" & ContactID & "'>" & ContactName & "</a>"
        Else
            Throw New ArgumentNullException("Could Not Get Contact Name")
        End if
        
        Return ContactLink
    End Function

    'Params
    '   Input: Optional Integer, Optional String, Optional String
    '   Output: String
    '
    'This Function takes the lookup id and returns the lup_child
    'If there is no LookupId then it will use the lup_parent and lup_child to get and return the lup_id

    Function GetLookupDetails(Optional ByVal LookupId as integer = 0, Optional ByVal LookupParent as string = "", Optional ByVal LookupChild as string = "") as String
        Dim LookupConnection as sqlConnection
        Dim LookupCommand as sqlCommand
        Dim LookupReader as sqldatareader

        Dim sql as string

        If LookupId <> 0 then 
            LookupConnection = New SqlConnection(System.Configuration.ConfiguationManager.ConnectionStrings("ProjectsConnection").ToString())
            LookupConnection.Open()

            sql = "Select * from lookup""
            sql = sql & " Where lup_id = '" & LookupId & "'"

            LookipCommand = New SqlCommand(sql, LookupConnection)
            LookupReader = LookupCommand.ExecuteReader()

            While LookupReader.Read()            
                LookupChild = LookupReader("lup_child")
            End While

            LookupReader.Close()
            LookupConnection.Close()

            Return LookupChild
        Else if LookupParent <> "" and LookupChild <> "" then 
            LookupConnection = New SqlConnection(System.Configuration.ConfiguationManager.ConnectionStrings("ProjectsConnection").ToString())
            LookupConnection.Open()

            sql = "Select * from lookup"
            sql = sql & " Where lup_parent  = '" & LookupParent & "'"
            sql = sql & " and lup_child = '" & LookupChild & "'"

            LookipCommand = New SqlCommand(sql, LookupConnection)
            LookupReader = LookupCommand.ExecuteReader()

            While LookupReader.Read()        
                LookupId = LookupReader("lup_id")
            End While

            LookupReader.Close()
            LookupConnection.Close()

            Return LookupId
        Else
            Throw New ArgumentNullException("Could Not get Required Params for Lookup Function")
        End if
    End Function
End Class
