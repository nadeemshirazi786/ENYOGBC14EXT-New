page 14229820 "Finished Work Order"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF00081MG
    //   20071030 - hide JF attachment functionality
    // 
    // JF3883MG
    //   20090702 - remove all JF attachment functionality (replaced by Links in v5.0)
    // 
    // JF11393SHR
    //   20110117 - Add Posting Date

    Editable = false;
    PageType = Document;
    SourceTable = Table23019270;

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
                field(gcduPMVersionMgt.GetActiveVersion("PM Procedure Code");
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
            part(; 23019271)
            {
                SubPageLink = Field1 = FIELD (Field1);
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
            group("PM Work Order")
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
                action("Item Ledger Entries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Page 38;
                                    RunPageLink = Document No.=FIELD(Field1);
                    RunPageView = SORTING(Document No.,Posting Date);
                }
                action("Resource Ledger Entries")
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
                        REPORT.RUN(REPORT :: Report23019254, TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                action("Report Selection(s)")
                {
                    Caption = 'Report Selection(s)';

                    trigger OnAction()
                    begin
                        jfdoPrintReportSelections;
                    end;
                }
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
        gcduPMVersionMgt: Codeunit "23019250";
        grecPMWOHeader: Record "23019270";
        [InDataSet]
        "No.Editable": Boolean;

    [Scope('Internal')]
    procedure SetEditable()
    begin
        "No.Editable" := Type <> Type::"0";
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

