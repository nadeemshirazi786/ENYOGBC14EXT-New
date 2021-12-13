page 14229455 "Reg Cust GL Rbt Ldg Sform ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   ENRE1.00
    //     new field: "Schedule For Processing"
    //     - "marks" the record for the scheduled batch posting report 23019640 "Post Scheduled Rebate Entries"
    // 
    //     added new function ScheduleAll
    //     - allows the parent form to mark/unmark the "Schedule For Processing" field
    // 
    // ENRE1.00
    //   ENRE1.00 - new function RebateAdjustment


    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = "Rebate Ledger Entry ELA";
    SourceTableView = SORTING("Functional Area", "Post-to Customer No.", "Rebate Code", "Posting Date", "Posted To G/L", "G/L Posting Only", "Posted To Customer")
                      WHERE("Functional Area" = CONST(Sales),
                            "Posted To G/L" = CONST(true),
                            "Posted To Customer" = CONST(false),
                            "G/L Posting Only" = CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field(gblnIsMarked; gblnIsMarked)
                {
                    ApplicationArea = All;
                    Caption = 'Process';

                    trigger OnValidate()
                    begin
                        Mark(gblnIsMarked);
                    end;
                }
                field("Schedule For Processing"; "Schedule For Processing")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Code"; "Rebate Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rebate Description"; "Rebate Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rebate Unit Rate (LCY)"; "Rebate Unit Rate (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rebate Unit Rate (RBT)"; "Rebate Unit Rate (RBT)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Amount (RBT)"; "Amount (RBT)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Rebate Unit Rate (DOC)"; "Rebate Unit Rate (DOC)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Amount (DOC)"; "Amount (DOC)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Adjustment; Adjustment)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rebate Document No."; "Rebate Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill-to Customer Name"; "Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Post-to Customer No."; "Post-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Post-to Customer Name"; "Post-to Customer Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Type"; "Rebate Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Item Rebate Group Code"; "Item Rebate Group Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        gblnIsMarked := Mark;
    end;

    var
        Navigate: Page Navigate;
        gblnIsMarked: Boolean;
        gcduRebateMgt: Codeunit "Rebate Management ELA";




    procedure Navigatefunc()
    begin
        if not ("Source Type" in ["Source Type"::Customer, "Source Type"::Vendor]) then begin
            Navigate.SetDoc("Posting Date", "Source No.");
            Navigate.Run;
        end;
    end;


    // procedure ShowRebateCard()
    // var
    //     lrecRebate: Record "Rebate Header";
    // begin
    //     if "Rebate Code" <> '' then begin
    //         lrecRebate.SetRange(Code, "Rebate Code");

    //         PAGE.Run(PAGE::"Rebate Card", lrecRebate);
    //     end;
    // end;


    procedure AccrueRebates()
    var
        lcduRebateMgmt: Codeunit "Rebate Management ELA";
        lText000: Label 'You have not selected any entries.';
        lrecRebateLedgEntry: Record "Rebate Ledger Entry ELA";
    begin
        lrecRebateLedgEntry.ClearMarks;
        lrecRebateLedgEntry.MarkedOnly(false);

        MarkedOnly(true);

        if FindSet then begin
            repeat
                if lrecRebateLedgEntry.Get("Entry No.") then
                    lrecRebateLedgEntry.Mark(true);
            until Next = 0;

            FindSet;
        end;

        MarkedOnly(false);

        lrecRebateLedgEntry.MarkedOnly(true);

        if lrecRebateLedgEntry.IsEmpty then
            Error(lText000);

        lcduRebateMgmt.AccrueRebateToCustomer(lrecRebateLedgEntry, "Post-to Customer No.");

        CurrPage.Update(false);
    end;


    procedure MarkAll(pblnMark: Boolean)
    begin
        if FindSet then begin
            repeat
                Mark(pblnMark);
            until Next = 0;

            FindSet;
        end;

        CurrPage.Update(false);
    end;


    procedure ScheduleAll(pbln: Boolean)
    begin

        ModifyAll("Schedule For Processing", pbln);
    end;


    procedure RebateAdjustment()
    begin
        //<ENRE1.00>
        gcduRebateMgt.CreateRebateAdjustment(Rec);
        //</ENRE1.00>
    end;
}

