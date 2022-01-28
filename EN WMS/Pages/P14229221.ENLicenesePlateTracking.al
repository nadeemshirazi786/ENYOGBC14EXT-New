//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN License Plate History (ID 14229224).
/// </summary>
page 14229221 "License Plate Tracking ELA"
{

    ApplicationArea = All;
    Caption = 'License Plate Tracking';
    PageType = List;
    SourceTable = "License Plate Tracking ELA";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                // field("Lot No."; Rec."Lot No.")
                // {
                //     ApplicationArea = All;
                // }
                // field("Expiration Date"; Rec."Expiration Date")
                // {
                //     ApplicationArea = All;
                // }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }

                field("Action"; "Action")
                {
                    ApplicationArea = all;
                }

                // field("Merged To"; "Merged To")
                // {
                //     ApplicationArea = All;
                // }
                // field("Merged From"; "Merged From")
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

}
