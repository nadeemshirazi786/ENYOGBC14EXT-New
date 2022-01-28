//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Enum ENEnumErrorCode (ID 14229200).
/// </summary>
enum 14229220 "WMS Activity Type ELA"
{
    Extensible = true;
    // ,Put-away,Pick,Movement,Invt. Put-away,Invt. Pick
    value(0; "Blank")
    {
        Caption = '';
    }

    value(1; "Put-away")
    {
        Caption = 'Put-away';
    }
    value(2; Pick)
    {
        Caption = 'Pick';
    }
    value(3; Movement)
    {
        Caption = 'Movement';
    }

    value(4; "Invt. Put-away")
    {
        Caption = 'Invt. Put-away';
    }

    value(5; "Invt. Pick")
    {
        caption = 'Invt. Pick';
    }
}
