enum 14228831 "Delivery Type ELA"
{
    Extensible = true;
    
    value(0; "Standard")
    {
        Caption = 'Standard';
    }
    value(1; "Beginning")
    {
        Caption = 'Beginning';
    }
    value(2; "Ending")
    {
        Caption = 'Ending';
    }
}
enum 14228832 "Request Type"
{
    Extensible = true;
    
    value(0; Receive)
    {
        Caption = 'Receive';
    }
    value(1; Ship)
    {
        Caption = 'Ship';
    }
}