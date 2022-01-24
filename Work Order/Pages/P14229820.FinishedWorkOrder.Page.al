page 14229820 "Finished Work Order"
{
    Editable = false;
    PageType = Document;
    SourceTable = "Finished WO Header ELA";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("PM Work Order No."; "PM Work Order No.")
                {
                }
                field(Description; Description)
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field(Type; Type)
                {

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate;
                    end;
                }
                field("No."; "No.")
                {
                    Editable = "No.Editable";
                }
                field(Name; Name)
                {
                }
                field("Serial No."; "Serial No.")
                {
                    Visible = false;
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Editable = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Editable = false;
                }
                field("Active Version";
                gcduPMVersionMgt.GetActiveVersion("PM Procedure Code"))
                {
                    Caption = 'Active Version';
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Work Order Date"; "Work Order Date")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
            }
            part("Fin. WO Subform"; "Fin. WO Subform")
            {
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No.");
            }
        }
        area(factboxes)
        {
            part("Fin. Work Ord Stat FactBox"; "Fin. Work Ord Stat FactBox")
            {
                ShowFilter = false;
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM Proc. Version No." = FIELD("PM Proc. Version No."), "PM Procedure Code" = FIELD("PM Procedure Code");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("PM Work Order")
            {
                Caption = 'PM Work Order';
                action("<Action1101769006>")
                {
                    Caption = 'Comments';
                    Image = ListPage;
                    RunObject = Page "Fin. WO Comments";
                    RunPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = CONST(0);
                }
                separator(Separator)
                {
                }
                action("Item Ledger Entries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Document No." = FIELD("PM Work Order No.");
                    RunPageView = SORTING("Document No.", "Posting Date");
                }
                action("Resource Ledger Entries")
                {
                    Caption = 'Resource Ledger Entries';
                    Image = ResourceLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page "Resource Ledger Entries";
                    RunPageLink = "Document No." = FIELD("PM Work Order No.");
                    RunPageView = SORTING("Document No.", "Posting Date");
                }
            }
        }
        area(processing)
        {
            group("&Print")
            {
                Caption = '&Print';
                action("<Action1102631005>")
                {
                    Caption = 'PM Work Order Worksheet';
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMWOHeader.SETRANGE("PM Work Order No.", "PM Work Order No.");
                        //REPORT.RUN(REPORT :: Report23019254, TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                // action("Report Selection(s)")
                // {
                //     Caption = 'Report Selection(s)';

                //     trigger OnAction()
                //     begin
                //         jfdoPrintReportSelections;
                //     end;
                // }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnInit()
    begin
        "No.Editable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin
        SETRANGE("PM Work Order No.");
    end;

    var
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        grecPMWOHeader: Record "Finished WO Header ELA";
        [InDataSet]
        "No.Editable": Boolean;

    [Scope('Internal')]
    procedure SetEditable()
    begin
        "No.Editable" := Type <> Type::" ";
    end;

    local procedure TypeOnAfterValidate()
    begin
        SetEditable;
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        SetEditable;
    end;
}

