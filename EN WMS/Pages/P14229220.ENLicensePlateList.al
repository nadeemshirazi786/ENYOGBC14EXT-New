//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN License Plate List (ID 14229221).
/// </summary>
page 14229220 "License Plate List ELA"
{
    ApplicationArea = Basic, Suite, Warehouse;
    Caption = 'License Plate List';
    PageType = List;
    // CardPageId = "EN License PlateX";
    Editable = false;
    RefreshOnActivate = true;
    SourceTable = "License Plate ELA";
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
                // field(Status; Rec.Status)
                // {
                //     ApplicationArea = All;
                // }

                field("Type"; Type)
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
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

    actions
    {
        area(Processing)
        {
            group(Process)
            {
                Action("Show Contents")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Show Plate Contents';
                    image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F6';
                    ToolTip = 'List contents assigned to license plate';
                    trigger OnAction()
                    var
                        LicensePlateMgmt: codeunit "License Plate Mgmt. ELA";
                    begin

                    end;

                }
            }
        }
    }
}
