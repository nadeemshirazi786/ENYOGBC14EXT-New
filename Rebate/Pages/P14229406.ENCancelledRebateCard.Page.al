page 14229406 "Cancelled Rebate Card ELA"
{
    // ENRE1.00
    //      - add comment functionality
    //      - New Fields
    //            - Maximum Quantity (Base)
    //            - Maximum Amount

    //ApplicationArea = All;
    Caption = 'Cancelled Rebate Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    SourceTable = "Cancelled Rebate Header ELA";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Rebate Category Code"; "Rebate Category Code")
                {
                    ApplicationArea = All;
                }
                field("Rebate Type"; "Rebate Type")
                {
                    ApplicationArea = All;
                }
                field("Calculation Basis"; "Calculation Basis")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity (Base)"; "Minimum Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Minimum Amount"; "Minimum Amount")
                {
                    ApplicationArea = All;
                }
                field("Maximum Quantity (Base)"; "Maximum Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Maximum Amount"; "Maximum Amount")
                {
                    ApplicationArea = All;
                }
                field("Rebate Value"; "Rebate Value")
                {
                    ApplicationArea = All;
                    CaptionClass = Format(gtxtRebValueLabel);
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    CaptionClass = Format(gtxtStartDateLabel);
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    Visible = "End DateVisible";
                }
                field("External Reference No."; "External Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Cancelled Date"; "Cancelled Date")
                {
                    ApplicationArea = All;
                }
                field("Cancelled By User ID"; "Cancelled By User ID")
                {
                    ApplicationArea = All;
                }
            }
            part(Subform; "Cancelled Rebate SubForm ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Rebate Code" = FIELD(Code);
            }
            group(Posting)
            {
                Caption = 'Posting';
                Editable = false;
                field("Post to Sub-Ledger"; "Post to Sub-Ledger")
                {
                    ApplicationArea = All;
                }
                field("Expense G/L Account No."; "Expense G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Offset G/L Account No."; "Offset G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Post to Cust. Buying Group"; "Post to Cust. Buying Group")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Customer Type"; "Apply-To Customer Type")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Customer No."; "Apply-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Customer Ship-To Code"; "Apply-To Customer Ship-To Code")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Cust. Group Type"; "Apply-To Cust. Group Type")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Cust. Group Code"; "Apply-To Cust. Group Code")
                {
                    ApplicationArea = All;
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Custom Values")
            {
                Caption = 'Custom Values';
                Editable = false;
                Visible = false;
                field("Custom Value 1"; "Custom Value 1")
                {
                    ApplicationArea = All;
                }
                field("Custom Value 2"; "Custom Value 2")
                {
                    ApplicationArea = All;
                }
                field("Custom Value 3"; "Custom Value 3")
                {
                    ApplicationArea = All;
                }
                field("Custom Value 4"; "Custom Value 4")
                {
                    ApplicationArea = All;
                }
                field("Custom Value 5"; "Custom Value 5")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control23019017; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control23019016; Notes)
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Rebate")
            {
                Caption = '&Rebate';
                action("Co&mments")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Cancel. Rbt Comment Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action1102631004)
                {
                }
                group(Entries)
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action("<Action1102631005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action1102631002>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(false);
                    }
                    action(Closed)
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(true);
                    }
                    separator(Action1102631003)
                    {
                    }
                    action("Customer Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Ledger Entries';
                        RunObject = Page "Customer Ledger Entries";
                        RunPageLink = "Rebate Code ELA" = FIELD(Code);
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord() //"Rebate Code ELA"
    begin

        SetFields;
    end;

    trigger OnInit()
    begin
        "End DateVisible" := true;
    end;

    trigger OnOpenPage()
    begin
        SetFields;
    end;

    var
        gtxtRebValueLabel: Text[30];
        gText000: Label 'Rebate Value ($)';
        gText001: Label 'Rebate Value (%)';
        gText002: Label 'Start Date';
        gText003: Label 'Payment Date';
        gtxtStartDateLabel: Text[30];
        [InDataSet]
        "End DateVisible": Boolean;
        Text19043309: Label 'Use these filters to enhance the performance of the rebate calculation routine. You must still add the appropriate rebate detail criteria for the rebate to calculate correctly.';


    procedure SetFields()
    var
        lblnIsLumpSum: Boolean;
        lblnIsPercent: Boolean;
    begin
        lblnIsLumpSum := "Rebate Type" = "Rebate Type"::"Lump Sum";

        if lblnIsLumpSum then begin
            gtxtStartDateLabel := gText003;
        end else begin
            gtxtStartDateLabel := gText002;
        end;

        "End DateVisible" := not lblnIsLumpSum;

        lblnIsPercent := "Calculation Basis" = "Calculation Basis"::"Pct. Sale($)";

        if lblnIsPercent then begin
            gtxtRebValueLabel := gText001;
        end else begin
            gtxtRebValueLabel := gText000;
        end;
    end;
}

