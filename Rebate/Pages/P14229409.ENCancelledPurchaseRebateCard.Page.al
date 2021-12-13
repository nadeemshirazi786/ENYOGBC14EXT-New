page 14229409 "Cancelled Purch Rbt Card ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Page
    // 
    // ENRE1.00
    //    - New Fields
    //    - Maximum Quantity (Base)
    //    - Maximum Amount
    // 
    // ENRE1.00
    //   
    //     - add Customers to the Rebate actions group

    Caption = 'Cancelled Purchase Rebate Card';
    Editable = false;
    PageType = Document;
    SourceTable = "Cancel Purch. Rbt Header ELA";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                    Editable = "Calculation BasisEditable";
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = "Unit of Measure CodeEditable";
                }
                field("Minimum Quantity (Base)"; "Minimum Quantity (Base)")
                {
                    ApplicationArea = All;
                    Editable = MinimumQuantityBaseEditable;
                }
                field("Minimum Amount"; "Minimum Amount")
                {
                    ApplicationArea = All;
                    Editable = "Minimum AmountEditable";
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
                    Editable = "Currency CodeEditable";
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
            }
            part(Subform; "Cancelled Purch Rbt SFrm ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Purchase Rebate Code" = FIELD(Code);
                SubPageView = SORTING("Purchase Rebate Code", "Line No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Post to Sub-Ledger"; "Post to Sub-Ledger")
                {
                    ApplicationArea = All;
                }
                field("Credit G/L Account No."; "Credit G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Offset G/L Account No."; "Offset G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Post to Vendor Buying Group"; "Post to Vendor Buying Group")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Vendor No."; "Apply-To Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = "Apply-To Vendor No.Editable";
                }
                field("Apply-To Order Address Code"; "Apply-To Order Address Code")
                {
                    ApplicationArea = All;
                    Editable = ApplyToVendShipToCodeEdita;
                }
                field("Apply-To Vendor Group Code"; "Apply-To Vendor Group Code")
                {
                    ApplicationArea = All;
                    Editable = ApplyToVendGroupCodeEditable;
                }
            }
            group("Custom Values")
            {
                Caption = 'Custom Values';
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
                    RunObject = Page "Can. Purch Rbt Comm. Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action23019002)
                {
                }
                action(Customers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    Image = TeamSales;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Cancelled Purch Rbt Cust ELA";
                    RunPageLink = "Cancelled Purch. Rebate Code" = FIELD(Code);
                    RunPageView = SORTING("Cancelled Purch. Rebate Code", "Customer No.");
                }
                separator(Action23019014)
                {
                }
                group(Entries)
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        Image = Registered;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        Image = Post;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(false);
                    }
                    action(Closed)
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        Image = Close;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(true);
                    }
                    separator(Action23019008)
                    {
                    }
                    action("<Action23019009>")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Ledger Entries';
                        RunObject = Page "Vendor Ledger Entries";
                        RunPageLink = "Rebate Code ELA" = FIELD(Code);
                    }
                }
            }
        }
    }

    var
        gText000: Label 'Rebate Value ($)';
        gText001: Label 'Rebate Value (%)';
        gText002: Label 'Start Date';
        gText003: Label 'Payment Date';
        gtxtRebValueLabel: Text[30];
        gtxtStartDateLabel: Text[30];
        [InDataSet]
        "End DateVisible": Boolean;
        [InDataSet]
        MinimumQuantityBaseEditable: Boolean;
        [InDataSet]
        "Apply-To Vendor No.Editable": Boolean;
        [InDataSet]
        ApplyToVendShipToCodeEdita: Boolean;
        [InDataSet]
        ApplyToVendGroupCodeEditable: Boolean;
        [InDataSet]
        RebateAccrualGLAccountEditable: Boolean;
        [InDataSet]
        "Unit of Measure CodeEditable": Boolean;
        [InDataSet]
        "Currency CodeEditable": Boolean;
        [InDataSet]
        "Calculation BasisEditable": Boolean;
        [InDataSet]
        "Minimum AmountEditable": Boolean;
        Text19043309: Label 'Use these filters to enhance the performance of the rebate calculation routine. You must still add the appropriate rebate detail criteria for the rebate to calculate correctly.';

    [Scope('Internal')]
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
        lblnIsPercent := "Calculation Basis" = "Calculation Basis"::"Pct. Purch.($)";
        if lblnIsPercent then begin
            gtxtRebValueLabel := gText001;
        end else begin
            gtxtRebValueLabel := gText000;
        end;
    end;
}

