//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN License Plate Subform (ID 14229223).
/// </summary>
page 14229273 "License Plate SubformX ELA"
{

    Caption = 'License Plate Subform';
    PageType = ListPart;
    SourceTable = "License Plate LineX ELA";
    AutoSplitKey = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
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
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Qty. Per Unit of Measure"; Rec."Qty. Per Unit of Measure")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
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

                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Warranty Date"; Rec."Warranty Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Created On"; "Created On")
                {
                    ApplicationArea = All;
                }

                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Last Updated By"; Rec."Last Updated By")
                {
                    ApplicationArea = All;
                }
                field("Last Updated On"; Rec."Last Updated On")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
