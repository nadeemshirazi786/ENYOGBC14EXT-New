//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Enum ENEnumErrorCode (ID 14229200).
/// </summary>
enum 14229200 "Error Code ELA"
{
    Extensible = true;
    value(0; Success)
    {
        Caption = 'Success';
    }

    value(1; InvalidPin)
    {
        Caption = 'Invalid Pin';
    }
    value(2; Blocked)
    {
    }
    value(3; NotEnabled)
    {
        Caption = 'Not Enabled';
    }

    value(4; Duplicate)
    {
    }

    value(100; Unknown)
    {
    }
}
