page 14229836 "Fin. Work Order List"
{
    CardPageID = "Finished Work Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = "Finished WO Header ELA";

    layout
    {
        area(content)
        {
            repeater(General)
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
                field("Active Version";
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
            part("Fin. Work Ord Stat FactBox"; "Fin. Work Ord Stat FactBox")
            {
                ShowFilter = false;
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No."),
                              "PM Proc. Version No." = FIELD("PM Proc. Version No."),
                              "PM Procedure Code" = FIELD("PM Procedure Code");
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
                    RunObject = Page "Fin. WO Comments";
                    RunPageLink = "PM Work Order No."=FIELD("PM Work Order No."),
                                  "PM WO Line No."=CONST(0);
                }
                
                action("<Action1101769001>")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page "Item Ledger Entries";
                                    RunPageLink = "Document No."=FIELD("PM Work Order No.");
                    RunPageView = SORTING("Document No.","Posting Date");
                }
                action("<Action1101769056>")
                {
                    Caption = 'Resource Ledger Entries';
                    Image = ResourceLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page "Resource Ledger Entries";
                                    RunPageLink = "Document No."=FIELD("PM Work Order No.");
                    RunPageView = SORTING("Document No.","Posting Date");
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
                        REPORT.RUN(REPORT :: "Suggest PM Work Orders ELA", TRUE, FALSE, grecPMWOHeader);
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
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        grecPMWOHeader: Record "Finished WO Header ELA";
}

