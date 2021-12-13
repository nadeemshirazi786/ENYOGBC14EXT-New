/// <summary>
/// Page EN Price List Line (ID 14228855).
/// </summary>
page 14228855 "EN Price List Line"
{
    Caption = 'Price List Line';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "EN Sales Price";
    ApplicationArea = Basic, Suite;
    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    UsageCategory = Lists;
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
                    //OptionCaption = 'Customer,Customer Buying Group,Customer Price Group,Price List Group,All Customers,Campaign,None';

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
                        lrecCustPriceGrList: Page "Customer Price Groups";
                        CampaignList: Page "Campaign List";
                        ItemList: Page "Item List";
                        CustomerBuyingGrp: Page "EN Customer Buying Group";
                        PriceListGrp: Page "EN Price List Group";
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
                            SalesTypeFilter::"Customer Price Group":
                                BEGIN
                                    lrecCustPriceGrList.LOOKUPMODE := TRUE;
                                    IF lrecCustPriceGrList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := lrecCustPriceGrList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            SalesTypeFilter::Campaign:
                                BEGIN
                                    CampaignList.LOOKUPMODE := TRUE;
                                    IF CampaignList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := CampaignList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        // SalesTypeFilter::"Customer Buying Group":
                        //     BEGIN
                        //         CustomerBuyingGrp.LOOKUPMODE := TRUE;
                        //         IF CustomerBuyingGrp.RUNMODAL = ACTION::LookupOK THEN
                        //            Text := '' 
                        //         ELSE
                        //             EXIT(FALSE);
                        //     END;
                        // SalesTypeFilter::"Price List Group":
                        //     BEGIN
                        //         PriceListGrp.LOOKUPMODE := TRUE;
                        //         IF PriceListGrp.RUNMODAL = ACTION::LookupOK THEN
                        //             Text := ''
                        //         ELSE
                        //             EXIT(FALSE);
                        //     END;
                        END;

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        SalesCodeFilterOnAfterValidate;
                    end;
                }
                field(ItemTypeFilter; ItemTypeFilter)
                {
                    Caption = 'Type Filter';

                    trigger OnValidate()
                    begin
                        ItemTypeFilterOnAfterValidate;
                    end;
                }
                field(CodeFilterCtrl; CodeFilter)
                {
                    Caption = 'Code Filter';
                    Enabled = CodeFilterCtrlEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        ItemDiscGrList: Page "EN Item Sales Price Group";
                    begin
                        CASE Type OF
                            Type::Item:
                                BEGIN
                                    ItemList.LOOKUPMODE := TRUE;
                                    IF ItemList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            Type::"Item Price Group":
                                BEGIN
                                    ItemDiscGrList.LOOKUPMODE := TRUE;
                                    IF ItemDiscGrList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := ItemDiscGrList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        CodeFilterOnAfterValidate;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    Caption = 'Starting Date Filter';

                    trigger OnValidate()
                    var
                        TextManagement: Codeunit TextManagement;
                    begin
                        IF TextManagement.MakeDateFilter(StartingDateFilter) = 0 THEN;
                        StartingDateFilterOnAfterValid;
                    end;
                }
                field(gtxtEndingDateFilter; gtxtEndingDateFilter)
                {
                    Caption = 'Ending Date Filter';

                    trigger OnValidate()
                    var
                        TextManagement: Codeunit TextManagement;
                    begin

                        IF TextManagement.MakeDateFilter(gtxtEndingDateFilter) = 0 THEN;
                        ibEndingDateFilterOnAfterValid;

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
                field(Type; Type)
                {
                }
                field("Price Rule"; "Price Rule")
                {
                }
                field("Price Rule Code"; "Price Rule Code")
                {
                }
                field(Code; Code)
                {
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Contract Code"; "Contract Code")
                {
                }
                field("Contract Price"; "Contract Price")
                {
                }
                field("Ship-From Location"; "Ship-From Location")
                {
                    Visible = false;
                }
                field("Calculation Cost Base"; "Calculation Cost Base")
                {
                }
                field("Calculation Type"; "Calculation Type")
                {
                }
                field("Price Calc. Treatment"; "Price Calc. Treatment")
                {
                }
                field(Value; Value)
                {
                }
                field(Billback; Billback)
                {
                }

                field("Calc. Item Price"; esCalcCurrPrice)
                {
                    Caption = 'Calc. Item Price';
                    DecimalPlaces = 2 : 5;
                    Style = Strong;
                    StyleExpr = TRUE;
                }

                field("Del. Unit Cost Calc. Type"; "Del. Unit Cost Calc. Type")
                {
                }
                field("Del. Unit Cost Value"; "Del. Unit Cost Value")
                {
                }
                field(isCalcDelUnitCost; isCalcDelUnitCost)
                {
                    Caption = 'Del. Calc Item Price';
                }
                field(gdecAlternateCost; gdecAlternateCost)
                {
                    Editable = false;
                    Visible = false;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                }
                field("Unit Price Protection Level"; "Unit Price Protection Level")
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Ending Date"; "Ending Date")
                {
                }
                field("Starting Order Date"; "Starting Order Date")
                {
                    Visible = false;
                }
                field("Ending Order Date"; "Ending Order Date")
                {
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    Visible = false;
                }
                field("Rounding Method"; "Rounding Method")
                {
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ENOnAfterGetCurrRecord;
    end;

    trigger OnInit()
    begin
        CodeFilterCtrlEnable := TRUE;
        SalesCodeFilterCtrlEnable := TRUE;
        "Sales CodeEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ENOnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin

        SETFILTER("Starting Date", '%1..%2', 0D, WORKDATE);
        SETFILTER("Ending Date", '%1|>=%2', 0D, WORKDATE);

        GetRecFilters;
        SetRecFilters;
    end;

    var
        Cust: Record "Customer";
        lrecCustPriceGrp: Record "Customer Price Group";
        Campaign: Record "Campaign";
        Item: Record "Item";
        lrecItemSalesPriceGrpLine: Record "EN Price List Group";
        SalesCodeFilter: Text[250];
        ItemTypeFilter: Enum "EN Price Type For Filters";
        CodeFilter: Text[250];
        StartingDateFilter: Text[30];
        Text000: Label 'All Customers';
        CurrencyCodeFilter: Text[250];
        SalesTypeFilter: Enum "EN Sales Type for Filter";
        [InDataSet]
        "Sales CodeEditable": Boolean;
        [InDataSet]
        SalesCodeFilterCtrlEnable: Boolean;
        [InDataSet]
        CodeFilterCtrlEnable: Boolean;
        gdecAlternateCost: Decimal;

        gtxtEndingDateFilter: Text[30];
        gtxtStartingDateFilter: Text[30];


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
        CASE ItemTypeFilter OF
            ItemTypeFilter::Item:
                BEGIN
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);
                    Item."No." := CodeFilter;
                END;
            ItemTypeFilter::"Item Price Group":
                BEGIN
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 14228854);
                    lrecItemSalesPriceGrpLine.Code := CodeFilter;
                END;
        END;

        SalesSrcTableName := '';
        CASE SalesTypeFilter OF
            SalesTypeFilter::Customer:
                BEGIN
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 18);
                    Cust."No." := SalesCodeFilter;
                    IF Cust.FIND THEN
                        Description := Cust.Name;
                END;
            SalesTypeFilter::"Customer Price Group":
                BEGIN
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 340);
                    lrecCustPriceGrp.Code := SalesCodeFilter;
                    IF lrecCustPriceGrp.FIND THEN
                        Description := lrecCustPriceGrp.Description;
                END;
            SalesTypeFilter::Campaign:
                BEGIN
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 5071);
                    Campaign."No." := SalesCodeFilter;
                    IF Campaign.FIND THEN
                        Description := Campaign.Description;
                END;

            SalesTypeFilter::"All Customers":
                BEGIN
                    SalesSrcTableName := Text000;
                    Description := '';
                END;
        END;

        IF SalesSrcTableName = Text000 THEN
            EXIT(STRSUBSTNO('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, CodeFilter));
        EXIT(STRSUBSTNO('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, CodeFilter));
    end;

    /// <summary>
    /// GetRecFilters.
    /// </summary>
    //[Scope('Internal')]
    procedure GetRecFilters()
    begin
        IF GETFILTERS <> '' THEN BEGIN

            IF GETFILTER("Sales Type") <> '' THEN
                SalesTypeFilter := TransSalesTypeFieldToVar
            ELSE
                SalesTypeFilter := SalesTypeFilter::"None";
            IF GETFILTER(Type) <> '' THEN
                ItemTypeFilter := TransItemTypeFieldToVar
            ELSE
                ItemTypeFilter := ItemTypeFilter::None;

            SalesCodeFilter := GETFILTER("Sales Code");
            CodeFilter := GETFILTER(Code);

            StartingDateFilter := GETFILTER("Starting Date");
            gtxtEndingDateFilter := GETFILTER("Ending Date");


        END;

    end;


    /// <summary>
    /// TransSalesTypeFieldToVar.
    /// </summary>
    /// <returns>Return variable pint of type Integer.</returns>
    procedure TransSalesTypeFieldToVar() pint: Enum "EN Sales Type for Filter"
    var
        lText030: Label 'No %1 conversion for %2 %3.';
        lText031: Label 'Sales Type Filter';
    begin

        CASE "Sales Type" OF
            "Sales Type"::Customer:
                EXIT(pint::Customer);
            "Sales Type"::"Customer Price Group":
                EXIT(pint::"Customer Price Group");
            "Sales Type"::"All Customers":
                EXIT(pint::"All Customers");
            "Sales Type"::Campaign:
                EXIT(pint::Campaign);
            "Sales Type"::"Customer Buying Group":
                EXIT(pint::"Customer Buying Group");
            "Sales Type"::"Price List Group":
                EXIT(pint::"Price List Group");
            ELSE
                ERROR(lText030, lText031, FIELDNAME("Sales Type"), FORMAT("Sales Type"));
        END;
    end;
    /// <summary>
    /// TransItemTypeFieldToVar.
    /// </summary>
    /// <returns>Return variable pint of type Enum "EN Price Type for Filter".</returns>
    procedure TransItemTypeFieldToVar() pint: Enum "EN Price Type For Filters"
    var
        lText030: Label 'No %1 conversion for %2 %3.';
        lText031: Label 'Type Filter';
    begin

        CASE "Type" OF
            "Type"::Item:
                EXIT(pint::Item);
            "Type"::"Item Price Group":
                EXIT(pint::"Item Price Group");
            ELSE
                ERROR(lText030, lText031, FIELDNAME("Type"), FORMAT("Type"));
        END;
    end;

    /// <summary>
    /// SetRecFilters.
    /// </summary>
    //[Scope('Internal')]
    procedure SetRecFilters()
    begin
        SalesCodeFilterCtrlEnable := TRUE;
        CodeFilterCtrlEnable := TRUE;

        IF SalesTypeFilter <> SalesTypeFilter::"None" THEN
            SETRANGE("Sales Type", TransSalesTypeVarToField)
        ELSE
            SETRANGE("Sales Type");


        IF SalesTypeFilter IN [SalesTypeFilter::"All Customers", SalesTypeFilter::"Customer Price Group"] THEN BEGIN
            SalesCodeFilterCtrlEnable := FALSE;
            SalesCodeFilter := '';
        END;

        IF SalesCodeFilter <> '' THEN
            SETFILTER("Sales Code", SalesCodeFilter)
        ELSE
            SETRANGE("Sales Code");

        IF ItemTypeFilter <> ItemTypeFilter::None THEN
            SETRANGE(Type, TransItemTypeVarToField)
        ELSE
            SETRANGE(Type);

        IF ItemTypeFilter = ItemTypeFilter::None THEN BEGIN
            CodeFilterCtrlEnable := FALSE;
            CodeFilter := '';
        END;

        IF CodeFilter <> '' THEN BEGIN
            SETFILTER(Code, CodeFilter);
        END ELSE
            SETRANGE(Code);

        IF StartingDateFilter <> '' THEN
            SETFILTER("Starting Date", StartingDateFilter)
        ELSE
            SETRANGE("Starting Date");

        IF gtxtEndingDateFilter <> '' THEN BEGIN
            SETFILTER("Ending Date", gtxtEndingDateFilter)
        END ELSE BEGIN
            SETRANGE("Ending Date");
        END;


        CurrPage.UPDATE(FALSE);

    end;

    local procedure CodeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ENOnAfterGetCurrRecord()
    begin
        xRec := Rec;
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";

    end;

    local procedure ibEndingDateFilterOnAfterValid()
    begin

        CurrPage.SAVERECORD;
        SetRecFilters;

    end;

    local procedure ItemTypeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        CodeFilter := '';
        SetRecFilters;
    end;

    local procedure TransSalesTypeVarToField() pint: Integer
    var
        lText030: Label 'No %1 conversion for %2 %3.';
        lText031: Label 'Sales Type Filter';
    begin

        CASE SalesTypeFilter OF
            SalesTypeFilter::Customer:
                EXIT(0);
            SalesTypeFilter::"Customer Buying Group":
                EXIT(4);
            SalesTypeFilter::"Customer Price Group":
                EXIT(1);
            SalesTypeFilter::"All Customers":
                EXIT(2);
            SalesTypeFilter::Campaign:
                EXIT(3);
            SalesTypeFilter::"Price List Group":
                EXIT(5);
            ELSE
                ERROR(lText030, FIELDNAME("Sales Type"), lText031, FORMAT(SalesTypeFilter));
        END;
    end;

    local procedure TransItemTypeVarToField() pint: Integer
    var
        lText030: Label 'No %1 conversion for %2 %3.';
        lText031: Label 'Type Filter';
    begin

        CASE ItemTypeFilter OF
            ItemTypeFilter::Item:
                EXIT(0);
            ItemTypeFilter::"Item Price Group":
                EXIT(1);
            ELSE
                ERROR(lText030, FIELDNAME("Type"), lText031, FORMAT(ItemTypeFilter));
        END;

    end;


    /// <summary>
    /// esCalcCurrPrice.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    ////

    procedure esCalcCurrPrice(): Decimal
    var
        lcduSalesPriceCalcMgt: Codeunit "EN Sales Price Calc. Mgt.";
        lrecItem: Record Item;
    begin
        IF (Type = Type::Item) AND (lrecItem.GET(Code)) THEN
            EXIT(lcduSalesPriceCalcMgt.ExecutePriceCalcCalcultion(Rec, lrecItem));
    end;

    local procedure SalesCodeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure SalesTypeFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SalesCodeFilter := '';
        SetRecFilters;
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;
}

