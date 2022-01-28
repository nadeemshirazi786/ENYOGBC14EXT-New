//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// PageExtension EN WMS Units of Measure (ID 14229232) extends Record Units of Measure.
/// </summary>
pageextension 14229232 "WMS Units of Measure ELA" extends "Units of Measure"
{
    layout
    {
        addafter(Description)
        {
            field("Use for WMS App."; Rec."Use for WMS App. ELA")
            {
                ApplicationArea = All;
            }

            field("Is Bulk"; Rec."Is Bulk ELA")
            {
                ApplicationArea = All;
            }
        }
    }
}
