page 14229429 "Purchase Rebate Card ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Page
    // 
    // ENRE1.00
    //    - Modified Function
    //              - SetEditableFields
    // 
    // ENRE1.00
    //    - New Fields
    //              - Maximum Quantity (Base)
    //              - Maximum Amount 
    //            - Modified Functions
    //              - SetEditableFields
    // 
    // ENRE1.00
    //   
    //     - change ::"Guaranteed Cost Deal" from a "Rebate Type" to a "Calculation Basis"
    //     - add Customers to the Rebate actions group
    // 
    // ENRE1.00
    //    - add field:
    //      "Sales Profit Modifier"
    // ENRE1.00  disallow users from opening Purchase Rebate Customers from non-Sales-Based rebates

    Caption = 'Purchase Rebate Card';
    PageType = Document;
    SourceTable = "Purchase Rebate Header ELA";

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
                }
                field("Maximum Amount"; "Maximum Amount")
                {
                    ApplicationArea = All;
                }
                field("Rebate Value"; "Rebate Value")
                {
                    ApplicationArea = All;
                    CaptionClass = Format(gtxtRebValueLabel);
                    Editable = RebateValueEditable;
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
                field("Sales Profit Modifier"; "Sales Profit Modifier")
                {
                    ApplicationArea = All;
                    Editable = SalesProfitModEditable;
                }
            }
            part(Subform; "Purchase Rebate SubForm ELA")
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

                    trigger OnValidate()
                    begin
                        ApplyToVendorNoOnAfterValida;
                    end;
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

                    trigger OnValidate()
                    begin
                        ApplyToVendGroupCodeOnAfterVal;
                    end;
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
                        ShowStatistics;
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
                separator(Action23019019)
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

                    trigger OnAction()
                    var
                        lrecPurchaseRebateCustomer: Record "Purchase Rebate Customer ELA";
                        lpagPurchaseRebateCustomers: Page "Purchase Rebate Customers ELA";
                        lctxtPurchaseRebateCustomers: Label '%1 can only apply to a %2 %3; the Page cannot open.';
                    begin
                        //<ENRE1.00>
                        if (
                          ("Rebate Type" <> "Rebate Type"::"Sales-Based")
                        ) then begin
                            // %1 can only apply to a %2 %3; the Page cannot open.
                            Message(StrSubstNo(lctxtPurchaseRebateCustomers, lpagPurchaseRebateCustomers.Caption,
                                                                             Format("Rebate Type"::"Sales-Based"),
                                                                             TableCaption));
                            exit;
                        end;
                        lrecPurchaseRebateCustomer.SetRange("Purchase Rebate Code", Code);
                        lpagPurchaseRebateCustomers.SetTableView(lrecPurchaseRebateCustomer);
                        lpagPurchaseRebateCustomers.Run;
                        //</ENRE1.00>
                    end;
                }
                separator(Action23019018)
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
                        Image = Open;
                        RunObject = Page "Rebate Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        Image = Registered;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid-by Vendor" = CONST(false),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action("<Action23019006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        Image = Post;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid-by Vendor" = CONST(false),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action(Closed)
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        Image = Close;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid-by Vendor" = CONST(true),
                                      "Functional Area" = CONST(Purchase);
                    }
                    separator(Action23019008)
                    {
                    }
                    action("Vendor Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Ledger Entries';
                        Image = VendorLedger;
                        RunObject = Page "Vendor Ledger Entries";
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
                        lrptCopyPurchRebate: Report "Copy Purchase Rebate ELA";
                    begin
                        Commit;
                        Clear(lrptCopyPurchRebate);
                        lrptCopyPurchRebate.SetCurrentRebate(Rec);
                        lrptCopyPurchRebate.RunModal;
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
                        CancelRebate;
                        CurrPage.Update;
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
        ApplyToVendGroupCodeEditable := true;
        ApplyToVendShipToCodeEdita := true;
        "Apply-To Vendor No.Editable" := true;
        MinimumQuantityBaseEditable := true;
        "End DateVisible" := true;

        RebateValueEditable := true; //<ENRE1.00/>

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
        [InDataSet]
        RebateValueEditable: Boolean;
        [InDataSet]
        "Maximum AmountEditable": Boolean;
        [InDataSet]
        SalesProfitModEditable: Boolean;


    procedure SetEditableFields()
    var
        lblnMinQtyEditable: Boolean;
        lblnCanUseFilters: Boolean;
        lblnAppVendNoEdit: Boolean;
        lblnVendAppShipToEdit: Boolean;
        lblnAppVendGrpEdit: Boolean;
        lblnIsLumpSum: Boolean;
        lblnIsPercent: Boolean;
    begin
        RebateAccrualGLAccountEditable := "Post to Sub-Ledger" = "Post to Sub-Ledger"::"Do Not Post";

        //<ENRE1.00>
        "Unit of Measure CodeEditable" := ("Calculation Basis" = "Calculation Basis"::"($)/Unit");
        "Currency CodeEditable" := (not ("Calculation Basis" in ["Calculation Basis"::"Pct. Purch.($)",
                                                                        "Calculation Basis"::"Guaranteed Cost Deal"]));
        "Calculation BasisEditable" := ("Rebate Type" <> "Rebate Type"::"Lump Sum");
        RebateValueEditable := ("Calculation Basis" <> "Calculation Basis"::"Guaranteed Cost Deal");
        //</ENRE1.00>

        lblnMinQtyEditable := ("Rebate Type" <> "Rebate Type"::"Lump Sum") and
                              ("Calculation Basis" <> "Calculation Basis"::"Pct. Purch.($)");
        MinimumQuantityBaseEditable := lblnMinQtyEditable;

        "Minimum AmountEditable" := "Rebate Type" <> "Rebate Type"::"Lump Sum";

        //<ENRE1.00>
        MaximumQuantityBaseEditable := ("Rebate Type" <> "Rebate Type"::"Lump Sum") and
          ("Calculation Basis" <> "Calculation Basis"::"Pct. Purch.($)");
        //</ENRE1.00>

        lblnCanUseFilters := CanUseApplyToFilters;

        lblnAppVendNoEdit := lblnCanUseFilters;
        "Apply-To Vendor No.Editable" := (lblnAppVendNoEdit) and ("Apply-To Vendor Group Code" = '');
        lblnVendAppShipToEdit := lblnAppVendNoEdit and ("Apply-To Vendor No." <> '');
        ApplyToVendShipToCodeEdita := lblnVendAppShipToEdit;
        lblnAppVendGrpEdit := lblnCanUseFilters;
        //<ENRE1.00>
        ApplyToVendGroupCodeEditable := lblnAppVendGrpEdit and ("Apply-To Vendor No." = '')
                                        and ("Rebate Type" <> "Rebate Type"::"Sales-Based");
        //</ENRE1.00>
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

        //<ENRE1.00>
        SalesProfitModEditable := ("Rebate Type" <> "Rebate Type"::"Sales-Based") and ("Rebate Type" <> "Rebate Type"::"Lump Sum");
        //</ENRE1.00>
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

    local procedure ApplyToVendGroupCodeOnAfterVal()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToVendGroupTypeOnAfterVal()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToVendorNoOnAfterValida()
    begin
        SetEditableFields;
    end;

    local procedure ApplyToVendorTypeOnAfterVali()
    begin
        SetEditableFields;
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        xRec := Rec;
        SetEditableFields;
    end;
}

