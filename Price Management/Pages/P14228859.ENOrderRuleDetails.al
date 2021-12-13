/// <summary>
/// Page EN Order Rule Details (ID 14228859).
/// </summary>
page 14228859 "EN Order Rule Details"
{
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "EN Order Rule Detail";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(SalesTypeFilter; SalesTypeFilter)
                {
                    Caption = 'Sales Type Filter';

                    trigger OnValidate()
                    begin
                        SalesTypeFilterOnAfterValidate;
                    end;
                }
                field(SalesCodeFilterCtrl; SalesCodeFilter)
                {
                    Caption = 'Sales Code Filter';
                    Enabled = SalesCodeFilterCtrlEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        OrderRuleGrList: Page "EN Order Rule Groups";
                    begin
                        IF SalesTypeFilter = SalesTypeFilter::"All Customers" THEN EXIT;

                        CASE SalesTypeFilter OF
                            SalesTypeFilter::Customer:
                                BEGIN
                                    CustList.LOOKUPMODE := TRUE;
                                    IF CustList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := CustList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            SalesTypeFilter::"Order Rule Group":
                                BEGIN
                                    OrderRuleGrList.LOOKUPMODE := TRUE;
                                    IF OrderRuleGrList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := OrderRuleGrList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        SalesCodeFilterOnAfterValidate;
                    end;
                }
                field(gtxtShipToCodeFilter; gtxtShipToCodeFilter)
                {
                    Caption = 'Ship-To Code Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        lrecShipTo: Record "Ship-to Address";
                        lfrmShipToList: Page "Ship-to Address List";
                    begin

                        IF SalesTypeFilter <> SalesTypeFilter::Customer THEN BEGIN
                            EXIT(FALSE);
                        END ELSE BEGIN
                            IF SalesCodeFilter = '' THEN BEGIN
                                EXIT(FALSE);
                            END;
                            lrecShipTo.SETFILTER("Customer No.", '%1', SalesCodeFilter);
                            lfrmShipToList.LOOKUPMODE := TRUE;
                            lfrmShipToList.SETTABLEVIEW(lrecShipTo);
                            IF lfrmShipToList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                                ///Text := lfrmShipToList.GetSelectionFilter;
                            END ELSE BEGIN
                                EXIT(FALSE);
                            END;
                        END;
                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        gtxtShipToCodeFilterOnAfterVal;
                    end;
                }
                field(ItemTypeFilter; ItemTypeFilter)
                {
                    Caption = 'Item Type Filter';

                    trigger OnValidate()
                    begin
                        ItemTypeFilterOnAfterValidate;
                    end;
                }
                field(ItemRefNoFilterCtrl; ItemRefNoFilter)
                {
                    Caption = 'Item Ref. Filter';
                    Enabled = ItemRefNoFilterCtrlEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        ItemCategories: Page "Item Categories";
                    begin

                        CASE ItemTypeFilter OF
                            ItemTypeFilter::"Item No.":
                                BEGIN
                                    ItemList.LOOKUPMODE := TRUE;
                                    IF ItemList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            ItemTypeFilter::"Item Category":
                                BEGIN
                                    ItemCategories.LOOKUPMODE := TRUE;
                                    IF ItemCategories.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemCategories.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;
                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        ItemRefNoFilterOnAfterValidate;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    Caption = 'Starting Date Filter';

                    trigger OnValidate()
                    begin
                        StartingDateFilterOnAfterValid;
                    end;
                }
            }
            repeater(GeneralRepeater)
            {
                field("Sales Type"; "Sales Type")
                {
                }
                field("Sales Code"; "Sales Code")
                {
                    Editable = "Sales CodeEditable";
                }
                field("Ship-To Address Code"; "Ship-To Address Code")
                {
                    Editable = "Ship-To Address CodeEditable";
                }
                field("Item Type"; "Item Type")
                {
                }
                field("Item Ref. No."; "Item Ref. No.")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Start Date"; "Start Date")
                {
                }
                field("End Date"; "End Date")
                {
                }
                field("Min. Order Qty."; "Min. Order Qty.")
                {
                }
                field("Order Multiple"; "Order Multiple")
                {
                    Editable = "Order MultipleEditable";
                }
                field(Status; Status)
                {
                }
                field("Reason Code"; "Reason Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Rule)
            {
                Caption = 'Rule';
                action("Combination Lines")
                {
                    Caption = 'Combination Lines';

                    trigger OnAction()
                    var
                        lcon001: Label '';
                        lrecOrderRuleDetLine: Record "EN Order Rule Detail Line";
                        lfrmOrderRuleDetLine: Page "EN Order Rule Detail Line";
                    begin
                        TESTFIELD("Item Type", "Item Type"::Combination);
                        lrecOrderRuleDetLine.SETRANGE("Sales Type", "Sales Type");
                        lrecOrderRuleDetLine.SETRANGE("Sales Code", "Sales Code");
                        lrecOrderRuleDetLine.SETRANGE("Ship-To Address Code", "Ship-To Address Code");
                        lrecOrderRuleDetLine.SETRANGE("Item Type", "Item Type");
                        lrecOrderRuleDetLine.SETRANGE("Item Ref. No.", "Item Ref. No.");
                        lrecOrderRuleDetLine.SETRANGE("Start Date", "Start Date");
                        lrecOrderRuleDetLine.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
                        lfrmOrderRuleDetLine.SETTABLEVIEW(lrecOrderRuleDetLine);
                        lfrmOrderRuleDetLine.RUNMODAL;
                    end;
                }
                separator(GeneralSeparator)
                {
                }
                action("Pricing by Customer/Item")
                {
                    Caption = 'Pricing by Customer/Item';
                    RunObject = Page 7002;
                    RunPageLink = "Sales Type" = CONST(Customer),
                                  "Sales Code" = FIELD("Sales Code"),
                                  "Ship-To Code ELA" = FIELD("Ship-To Address Code"),
                                  "Item No." = FIELD("Item Ref. No."),
                                  "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                  "Starting Date" = FIELD("Start Date");
                    RunPageView = SORTING("Sales Type", "Sales Code", "Item No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                }
                action("Pricing by Customer")
                {
                    Caption = 'Pricing by Customer';
                    RunObject = Page 7002;
                    RunPageLink = "Sales Type" = CONST(Customer),
                                  "Sales Code" = FIELD("Sales Code");
                    RunPageView = SORTING("Sales Type", "Sales Code", "Item No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                }
                action("Pricing by Item")
                {
                    Caption = 'Pricing by Item';
                    RunObject = Page 7002;
                    RunPageLink = "Sales Type" = CONST("All Customers"),
                                  "Item No." = FIELD("Item Ref. No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IF "End Date" <> 0D THEN
            SETRANGE("Date Filter", "Start Date", "End Date")
        ELSE
            IF "Start Date" <> 0D THEN
                SETFILTER("Date Filter", '>=%1', "Start Date");

        IF "Min. Order Qty." <> 0 THEN
            SETFILTER("Min. Qty. Filter", '<=%1', "Min. Order Qty.")
        ELSE
            SETRANGE("Min. Qty. Filter", 0);

        IF "Sales Type" = "Sales Type"::Customer THEN BEGIN
            SETFILTER("Sales Type Filter", '%1', "Sales Type");
            SETFILTER("Sales Code Filter", '%1', "Sales Code");
        END;
        OnAfterGetCurrRecordValidate;
    end;

    trigger OnInit()
    begin
        ItemRefNoFilterCtrlEnable := TRUE;
        SalesCodeFilterCtrlEnable := TRUE;
        "Order MultipleEditable" := TRUE;
        "Sales CodeEditable" := TRUE;
        "Ship-To Address CodeEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecordValidate;
    end;

    trigger OnOpenPage()
    begin
        GetRecFilters;
        SetRecFilters;
    end;

    var
        SalesTypeFilter: Enum "EN Sales Type Order Rule For Filters";
        SalesCodeFilter: Text[250];
        ItemTypeFilter: Enum "EN Item Type Order Rule For Filter";
        ItemRefNoFilter: Text[250];
        StartingDateFilter: Text[30];
        Cust: Record "Customer";
        OrderRuleGroup: Record "EN Order Rule Group";
        Text000: Label '';
        OrderRuleGrList: Integer;
        gtxtShipToCodeFilter: Text[250];

        [InDataSet]
        "Ship-To Address CodeEditable": Boolean;
        [InDataSet]
        "Sales CodeEditable": Boolean;
        [InDataSet]
        "Order MultipleEditable": Boolean;
        [InDataSet]
        SalesCodeFilterCtrlEnable: Boolean;
        [InDataSet]
        ItemRefNoFilterCtrlEnable: Boolean;

    
    procedure GetRecFilters()
    begin
        IF GETFILTERS <> '' THEN BEGIN
            IF GETFILTER("Sales Type") <> '' THEN
                SalesTypeFilter := TransSalesTypeFieldToVar
            ELSE
                SalesTypeFilter := SalesTypeFilter::None;

            SalesCodeFilter := GETFILTER("Sales Code");

            IF GETFILTER("Item Type") <> '' THEN
                ItemTypeFilter := TransItemTypeFieldToVar
            ELSE
                ItemTypeFilter := ItemTypeFilter::None;

            ItemRefNoFilter := GETFILTER("Item Ref. No.");

            //CurrencyCodeFilter := GETFILTER("Currency Code");
            gtxtShipToCodeFilter := GETFILTER("Ship-To Address Code");
        END;

        EVALUATE(StartingDateFilter, GETFILTER("Start Date"));
    end;

    
    procedure SetRecFilters()
    begin
        SalesCodeFilterCtrlEnable := TRUE;
        ItemRefNoFilterCtrlEnable := TRUE;

        IF SalesTypeFilter <> SalesTypeFilter::None THEN
            SETRANGE("Sales Type", TransSalesTypeVarToField)
        ELSE
            SETRANGE("Sales Type");

        IF SalesTypeFilter IN [SalesTypeFilter::"All Customers", SalesTypeFilter::None] THEN BEGIN
            SalesCodeFilterCtrlEnable := FALSE;
            SalesCodeFilter := '';
        END;

        IF SalesCodeFilter <> '' THEN
            SETFILTER("Sales Code", SalesCodeFilter)
        ELSE
            SETRANGE("Sales Code");


        IF gtxtShipToCodeFilter <> '' THEN
            SETFILTER("Ship-To Address Code", gtxtShipToCodeFilter)
        ELSE
            SETRANGE("Ship-To Address Code");

        IF StartingDateFilter <> '' THEN
            SETFILTER("Start Date", StartingDateFilter)
        ELSE
            SETRANGE("Start Date");

        IF ItemTypeFilter <> ItemTypeFilter::None THEN
            SETRANGE("Item Type", TransItemTypeVarToField)
        ELSE
            SETRANGE("Item Type");

        IF ItemTypeFilter IN [ItemTypeFilter::None] THEN BEGIN
            ItemRefNoFilterCtrlEnable := FALSE;
            ItemRefNoFilter := '';
        END;

        IF ItemRefNoFilter <> '' THEN BEGIN
            SETFILTER("Item Ref. No.", ItemRefNoFilter);
        END ELSE
            SETRANGE("Item Ref. No.");

        CurrPage.UPDATE(FALSE);

    end;

    
    /// <summary>
    /// GetCaption.
    /// </summary>
    /// <returns>Return value of type Text[250].</returns>
    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[100];
        SalesSrcTableName: Text[100];
        Description: Text[250];
    begin
        GetRecFilters;
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";



        SourceTableName := '';
        IF ItemRefNoFilter <> '' THEN
            SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);

        SalesSrcTableName := '';
        CASE SalesTypeFilter OF
            SalesTypeFilter::Customer:
                BEGIN
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 18);
                    Cust."No." := SalesCodeFilter;
                    IF Cust.FIND THEN
                        Description := Cust.Name;
                END;
            SalesTypeFilter::"Order Rule Group":
                BEGIN
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 23019663);
                    OrderRuleGroup.Code := SalesCodeFilter;
                    IF OrderRuleGroup.FIND THEN
                        Description := OrderRuleGroup.Description;
                END;
            SalesTypeFilter::"All Customers":
                BEGIN
                    SalesSrcTableName := Text000;
                    Description := '';
                END;
        END;

        IF SalesSrcTableName = Text000 THEN
            EXIT(STRSUBSTNO('%1 %2 %3', SalesSrcTableName, SourceTableName, ItemRefNoFilter));
        EXIT(STRSUBSTNO('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, ItemRefNoFilter));
    end;

    local procedure TransSalesTypeFieldToVar() pint: Enum "EN Sales Type Order Rule For Filters"
    var
        lText030: Label 'No %1 conversion for %2 %3.';
    begin

        CASE "Sales Type" OF
            "Sales Type"::Customer:
                EXIT(pint::Customer);
            "Sales Type"::"Order Rule Group":
                EXIT(pint::"Order Rule Group");
            "Sales Type"::"All Customers":
                EXIT(pint::"All Customers");
            ELSE
                ERROR(lText030, FIELDNAME("Sales Type Filter"), FIELDNAME("Sales Type"), FORMAT("Sales Type"));
        END;
    end;

    local procedure TransSalesTypeVarToField() pint: Integer
    var
        lText030: Label 'No %1 conversion for %2 %3.';
    begin

        CASE SalesTypeFilter OF
            SalesTypeFilter::Customer:
                EXIT(0);
            SalesTypeFilter::"Order Rule Group":
                EXIT(1);
            SalesTypeFilter::"All Customers":
                EXIT(2);
            ELSE
                ERROR(lText030, FIELDNAME("Sales Type"), FIELDNAME("Sales Type Filter"), FORMAT(SalesTypeFilter));
        END;
    end;

    local procedure TransItemTypeFieldToVar() pint: Enum "EN Item Type Order Rule For Filter"
    var
        lText030: Label 'No %1 conversion for %2 %3.';
    begin

        CASE "Item Type" OF
            "Item Type"::"Item No.":
                EXIT(pint::"Item No.");
            "Item Type"::"Item Category":
                EXIT(pint::"Item Category");
            "Item Type"::Combination:
                EXIT(pint::Combination);
            ELSE
                ERROR(lText030, FIELDNAME("Item Type Filter"), FIELDNAME("Item Type"), FORMAT("Item Type"));
        END;
    end;

    local procedure TransItemTypeVarToField() pint: Integer
    var
        lText030: Label 'No %1 conversion for %2 %3.';
    begin

        CASE ItemTypeFilter OF
            ItemTypeFilter::"Item No.":
                EXIT(0);
            ItemTypeFilter::"Item Category":
                EXIT(1);
            ItemTypeFilter::Combination:
                EXIT(2);
            ELSE
                ERROR(lText030, FIELDNAME("Item Type"), FIELDNAME("Item Type Filter"), FORMAT(ItemTypeFilter));
        END;
    end;

    local procedure SalesTypeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SalesCodeFilter := '';
        SetRecFilters;
    end;

    local procedure SalesCodeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure gtxtShipToCodeFilterOnAfterVal()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ItemRefNoFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ItemTypeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        ItemRefNoFilter := '';
        SetRecFilters;
    end;

    local procedure OnAfterGetCurrRecordValidate()
    begin
        xRec := Rec;
        IF "Item Type" = "Item Type"::Combination THEN BEGIN
            "Order MultipleEditable" := FALSE;
        END ELSE BEGIN
            "Order MultipleEditable" := TRUE;
        END;
        "Ship-To Address CodeEditable" := "Sales Type" <> "Sales Type"::"Order Rule Group";
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";
        SETRANGE("Date Filter");
        IF "End Date" <> 0D THEN
            SETRANGE("Date Filter", "Start Date", "End Date")
        ELSE
            IF "Start Date" <> 0D THEN
                SETFILTER("Date Filter", '>=%1', "Start Date");

        IF "Min. Order Qty." <> 0 THEN
            SETFILTER("Min. Qty. Filter", '<=%1', "Min. Order Qty.")
        ELSE
            SETRANGE("Min. Qty. Filter", 0);

        IF "Sales Type" = "Sales Type"::Customer THEN BEGIN
            SETFILTER("Sales Type Filter", '%1', "Sales Type");
            SETFILTER("Sales Code Filter", '%1', "Sales Code");
        END ELSE BEGIN
            SETRANGE("Sales Code Filter");
        END;
    end;
}

