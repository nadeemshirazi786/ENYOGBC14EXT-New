//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information
/// <summary>
/// Enum EN WMS Document Status (ID 14229227).
/// </summary>
enum 14229227 "WMS Document Status ELA"
{
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
