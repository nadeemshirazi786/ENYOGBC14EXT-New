page 23019289 "Fin. Work Order List"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    CardPageID = "Finished Work Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Table23019270;

    layout
    {
        area(content)
        {
            repeater()
            {
                Editable = false;
                field("PM Work Order No."; "PM Work Order No.")
                {
                }
                field("Work Order Date"; "Work Order Date")
                {
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field(gcduPMVersionMgt.GetActiveVersion("PM Procedure Code");
                    gcduPMVersionMgt.GetActiveVersion("PM Procedure Code"))
                {
                    Caption = 'Active Version';
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field("Evaluated At Qty."; "Evaluated At Qty.")
                {
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field("Location Code"; xRec."Location Code")
                {
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
            }
        }
        area(factboxes)
        {
            part(; 23019296)
            {
                ShowFilter = false;
                SubPageLink = Field1 = FIELD (Field1),
                              Field2 = FIELD (Field2),
                              Field3 = FIELD (Field3);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action1000000020>")
            {
                Caption = 'PM Work Order';
                action("<Action1101769006>")
                {
                    Caption = 'Comments';
                    Image = ListPage;
                    RunObject = Page 23019274;
                    RunPageLink = PM Work Order No.=FIELD(Field1),
                                  PM WO Line No.=CONST(0);
                }
                separator()
                {
                }
                action("<Action1101769001>")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page 38;
                                    RunPageLink = Document No.=FIELD(Field1);
                    RunPageView = SORTING(Document No.,Posting Date);
                }
                action("<Action1101769056>")
                {
                    Caption = 'Resource Ledger Entries';
                    Image = ResourceLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page 202;
                                    RunPageLink = Document No.=FIELD(Field1);
                    RunPageView = SORTING(Document No.,Posting Date);
                }
            }
        }
        area(processing)
        {
            group("<Action1102631004>")
            {
                Caption = '&Print';
                action("<Action1102631005>")
                {
                    Caption = 'PM Work Order Worksheet';
                    Image = SuggestGrid;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMWOHeader.SETRANGE("PM Work Order No.", "PM Work Order No.");
                        REPORT.RUN(REPORT :: Report23019254, TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                action("<Action1102631006>")
                {
                    Caption = 'Report Selection(s)';
                    Image = SelectReport;

                    trigger OnAction()
                    begin
                        jfdoPrintReportSelections;
                    end;
                }
            }
        }
    }

    var
        gcduPMVersionMgt: Codeunit "23019250";
        grecPMWOHeader: Record "23019270";
}

