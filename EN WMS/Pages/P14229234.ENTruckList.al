//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Truck List (ID 14229234).
/// </summary>
page 14229234 "Truck List ELA"
{

    ApplicationArea = All;
    Caption = 'Truck List';
    PageType = List;
    SourceTable = "Truck ELA";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("VIN No."; Rec."VIN No.")
                {
                    ApplicationArea = All;
                }
                field("No. Of Axles"; Rec."No. Of Axles")
                {
                    ApplicationArea = All;
                }
                field("License Type"; Rec."License Type")
                {
                    ApplicationArea = All;
                }
                field("License/Plate No."; Rec."License/Plate No.")
                {
                    ApplicationArea = All;
                }
                field("License Exp. Date"; Rec."License Exp. Date")
                {
                    ApplicationArea = All;
                }
                field("Engine Type"; Rec."Engine Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
