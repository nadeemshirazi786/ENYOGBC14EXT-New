//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information
/// <summary>
/// Enum EN WMS Ship Acion (ID 14229223).
/// </summary>
enum 14229223 "WMS Ship Acion ELA"
{
    Extensible = true;
    //  ' ,Fullfill,Cut,Over Ship,Back Order';
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Fullfill)
    {
        Caption = 'Fullfill';
    }
    value(2; Cut)
    {
        Caption = 'Cut';
    }
    value(3; "Over Ship")
    {
        Caption = 'Over Ship';
    }

    value(4; "Back Order")
    {
        Caption = 'Back Order';
    }
}
