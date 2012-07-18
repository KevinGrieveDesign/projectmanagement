'Params:
'    Input:String
'    Output:Boolean
'
'This expects a string about what is being accessed i.e. trying to edit a ticket
'This will then look at the users security items and match them with the ticket and the relationships to see if they have the right to do that action

Function AllowAction(ByVal Action As String) As Boolean
    If Action <> "" Then

    Else
        Throw New ArgumentNullException("No action give to Security Model")
    End If
End Function