//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information
/// <summary>
/// Enum WMS Sales Document Type (ID 14229221).
/// </summary>
enum 14229221 "WMS Sales Document Type ELA"
{
    Extensible = true;

    value(0; Quote)
    {
        Caption = 'Quote';
    }
    value(1; Order)
    {
        Caption = 'Order';
    }
    value(2; Invoice)
    {
        Caption = 'Invoice';
    }
    value(3; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(4; "Blanket Order")
    {
        Caption = 'Blanket Order';
    }
    value(5; "Return Order")
    {
        Caption = 'Return Order';
    }

}
