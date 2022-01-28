//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Container Subform (ID 14229224).
/// </summary>
page 14229224 "Container Subform ELA"
{

    Caption = 'Container Subform';
    PageType = ListPart;
    SourceTable = "Container Content ELA";
    AutoSplitKey = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Container No."; Rec."Container No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
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
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Location; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("License Plate No."; Rec."License Plate No.")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                // field("Pallet No."; Rec."Pallet No.")
                // {
                //     ApplicationArea = All;
                // }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                }

                field("Activty Type"; "Activity Type")
                {
                    ApplicationArea = All;
                }

                field("Activity No."; "Activity No.")
                {
                    ApplicationArea = All;
                }

                field("Activity Line No."; "Activity Line No.")
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

                action("Assign Content")
                {
                    ApplicationArea = Suite;
                    Caption = 'Assign &Content';
                    Image = ResourceGroup;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedIsBig = true;
                    ShortCutKey = 'F6';
                    ToolTip = 'Add Items';
                    trigger OnAction()
                    var
                        // ContMgmt: Codeunit "EN Container Mgmt.";
                        // WhseDocType: enum "EN Whse. Doc. Type";
                        AssignContents: page "Assign Container Contents ELA";
                        // SourceDocTypeFilter: Enum "EN WMS Source Doc Type";
                        Container: record "Container ELA";
                    // PurchaseLine: record "Purchase Line";
                    // PurchaseLineTemp: Record "Purchase Line";
                    begin
                        Container.Get("Container No.");
                        /* AssignContents.SetDocumentFilters(
                                 Container."Source Document Type", Container."Document Type", Container."Document No.", 0,
                                        Container."Whse. Document Type", Container."Whse. Document No.", Container."Activity Type",
                                        Container."Activity No.", "Activity Line No.", "Container No.", true); // use manual here.
                         AssignContents.RunModal();*/
                        CurrPage.Update();

                        // ContMgmt.ShowContaier('', "Location Code", 0, '', WhseDocType::Receipt, "No.");
                    end;
                }
            }
        }
    }
}