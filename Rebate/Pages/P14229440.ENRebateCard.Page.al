page 14229440 "Rebate Card ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - add Cancel Rebate function
    // 
    // ENRE1.00
    //    - add comment functionality
    // 
    // ENRE1.00
    //    - New Fields
    //    - Maximum Quantity (Base)
    //    - Maximum Amount
    //    - Modified Functions
    //    - SetEditableFields

    Caption = 'Rebate Card';
    PageType = Document;
    SourceTable = "Rebate Header ELA";

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

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Rebate Category Code"; "Rebate Category Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        RebateCategoryCodeOnAfterValid;
                    end;
                }
                field("Rebate Type"; "Rebate Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        RebateTypeOnAfterValidate;
                    end;
                }
                field("Calculation Basis"; "Calculation Basis")
                {
                    ApplicationArea = All;
                    Editable = "Calculation BasisEditable";

                    trigger OnValidate()
                    begin
                        CalculationBasisOnAfterValidat;
                    end;
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
                    Editable = MaximumQuantityBaseEditable;
                }
                field("Maximum Amount"; "Maximum Amount")
                {
                    ApplicationArea = All;
                    Editable = "Maximum AmountEditable";
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
            part(Subform; "Rebate SubForm ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Rebate Code" = FIELD(Code);
                SubPageView = SORTING("Rebate Code", "Line No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Post to Sub-Ledger"; "Post to Sub-Ledger")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CustomerSubLedgerUsageOnAfterV;
                    end;
                }
                field("Expense G/L Account No."; "Expense G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Offset G/L Account No."; "Offset G/L Account No.")
                {
                    ApplicationArea = All;
                    Editable = RebateAccrualGLAccountEditable;
                }
                field("Post to Cust. Buying Group"; "Post to Cust. Buying Group")
                {
                    ApplicationArea = All;
                }
                field("Apply-To Customer Type"; "Apply-To Customer Type")
                {
                    ApplicationArea = All;
                    Editable = true;

                    trigger OnValidate()
                    begin
                        ApplyToCustomerTypeOnAfterVali;
                    end;
                }
                field("Apply-To Customer No."; "Apply-To Customer No.")
                {
                    ApplicationArea = All;
                    Editable = "Apply-To Customer No.Editable";

                    trigger OnValidate()
                    begin
                        ApplyToCustomerNoOnAfterValida;
                    end;
                }
                field("Apply-To Customer Ship-To Code"; "Apply-To Customer Ship-To Code")
                {
                    ApplicationArea = All;
                    Editable = ApplyToCustomerShipToCodeEdita;
                }
                field("Apply-To Cust. Group Type"; "Apply-To Cust. Group Type")
                {
                    ApplicationArea = All;
                    Editable = ApplyToCustGroupTypeEditable;

                    trigger OnValidate()
                    begin
                        ApplyToCustGroupTypeOnAfterVal;
                    end;
                }
                field("Apply-To Cust. Group Code"; "Apply-To Cust. Group Code")
                {
                    ApplicationArea = All;
                    Editable = ApplyToCustGroupCodeEditable;

                    trigger OnValidate()
                    begin
                        ApplyToCustGroupCodeOnAfterVal;
                    end;
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
            systempart(Control23019028; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control23019026; Notes)
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
            group("<Action23019000>")
            {
                Caption = '&Rebate';
                action(Statistics)
                {
                    ApplicationArea = All;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        //<ENRE1.00>
                        ShowStatistics;
                        //</ENRE1.00>
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Rebate Comment Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action23019002)
                {
                }
                group(Entries)
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action(Open)
                    {
                        ApplicationArea = All;
                        Caption = 'Open';
                        RunObject = Page "Rebate Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code);
                    }
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019006>")
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
                    separator(Action23019008)
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
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Copy Rebate")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Rebate';
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        lrptCopyRebate: Report "Copy Rebate ELA";
                    begin
                        //<ENRE1.00>
                        TestField("Job No.", '');
                        //</ENRE1.00>

                        //<ENRE1.00>
                        Commit;
                        Clear(lrptCopyRebate);

                        lrptCopyRebate.SetCurrentRebate(Rec);
                        lrptCopyRebate.RunModal;
                        //</ENRE1.00>
                    end;
                }
                separator(Action23019012)
                {
                }
                action("Cancel Rebate")
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Rebate';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        //<ENRE1.00>
                        CancelRebate;
                        CurrPage.Update;
                        //</ENRE1.00>
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrRecord2;
    end;

    trigger OnInit()
    begin
        "Minimum AmountEditable" := true;
        "Calculation BasisEditable" := true;
        "Currency CodeEditable" := true;
        "Unit of Measure CodeEditable" := true;
        RebateAccrualGLAccountEditable := true;
        ApplyToCustGroupCodeEditable := true;
        ApplyToCustGroupTypeEditable := true;
        ApplyToCustomerShipToCodeEdita := true;
        "Apply-To Customer No.Editable" := true;
        "Apply-To Customer TypeEditable" := true;
        MinimumQuantityBaseEditable := true;
        "End DateVisible" := true;
        //<ENRE1.00>
        MaximumQuantityBaseEditable := true;
        "Maximum AmountEditable" := true;
        //</ENRE1.00>
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord2;
    end;

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
        MaximumQuantityBaseEditable: Boolean;
        [InDataSet]
        "Apply-To Customer TypeEditable": Boolean;
        [InDataSet]
        "Apply-To Customer No.Editable": Boolean;
        [InDataSet]
        ApplyToCustomerShipToCodeEdita: Boolean;
        [InDataSet]
        ApplyToCustGroupTypeEditable: Boolean;
        [InDataSet]
        ApplyToCustGroupCodeEditable: Boolean;
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
        [InDataSet]
        "Maximum AmountEditable": Boolean;


    procedure SetEditableFields()
    var
        lblnMinQtyEditable: Boolean;
        lblnCanUseFilters: Boolean;
        lblnAppCustNoEdit: Boolean;
        lblnCustAppShipToEdit: Boolean;
        lblnAppCustGrpEdit: Boolean;
        lblnIsLumpSum: Boolean;
        lblnIsPercent: Boolean;
    begin
        RebateAccrualGLAccountEditable := "Post to Sub-Ledger" = "Post to Sub-Ledger"::"Do Not Post";
        "Unit of Measure CodeEditable" := "Calculation Basis" = "Calculation Basis"::"($)/Unit";
        "Currency CodeEditable" := "Calculation Basis" <> "Calculation Basis"::"Pct. Sale($)";
        "Calculation BasisEditable" := "Rebate Type" <> "Rebate Type"::"Lump Sum";

        lblnMinQtyEditable := ("Rebate Type" <> "Rebate Type"::"Lump Sum") and
                              ("Calculation Basis" <> "Calculation Basis"::"Pct. Sale($)");
        MinimumQuantityBaseEditable := lblnMinQtyEditable;
        //<ENRE1.00>
        MaximumQuantityBaseEditable := ("Rebate Type" <> "Rebate Type"::"Lump Sum") and
          ("Calculation Basis" <> "Calculation Basis"::"Pct. Sale($)");
        //</ENRE1.00>
        "Minimum AmountEditable" := "Rebate Type" <> "Rebate Type"::"Lump Sum";

        "Maximum AmountEditable" := "Rebate Type" <> "Rebate Type"::"Lump Sum"; //<ENRE1.00/>

        lblnCanUseFilters := CanUseApplyToFilters;

        "Apply-To Customer TypeEditable" := lblnCanUseFilters;

        lblnAppCustNoEdit := lblnCanUseFilters and ("Apply-To Customer Type" = "Apply-To Customer Type"::Specific);
        "Apply-To Customer No.Editable" := lblnAppCustNoEdit;

        lblnCustAppShipToEdit := lblnAppCustNoEdit and ("Apply-To Customer No." <> '');
        ApplyToCustomerShipToCodeEdita := lblnCustAppShipToEdit;

        lblnAppCustGrpEdit := lblnCanUseFilters and ("Apply-To Customer Type" = "Apply-To Customer Type"::Group);
        ApplyToCustGroupTypeEditable := lblnAppCustGrpEdit;
        ApplyToCustGroupCodeEditable := lblnAppCustGrpEdit;

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

    local procedure CalculationBasisOnAfterValidat()
    begin
        SetEditableFields;
    end;

    local procedure RebateCategoryCodeOnAfterValid()
    begin
        SetEditableFields;
    end;

    local procedure RebateTypeOnAfterValidate()
    begin
        SetEditableFields;
    end;

    local procedure CustomerSubLedgerUsageOnAfterV()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToCustGroupCodeOnAfterVal()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToCustGroupTypeOnAfterVal()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToCustomerNoOnAfterValida()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToCustomerTypeOnAfterVali()
    begin
        SetEditableFields;
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        xRec := Rec;
        SetEditableFields;
    end;
}

