page 14229001 "EN Purchase Prices"
{

    Caption = 'Purchase Prices';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Purchase Price";
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(goptPurchaseTypeFilter; goptPurchaseTypeFilter)
                {
                    Caption = 'Purchase Type Filter';

                    trigger OnValidate()
                    begin
                        PurchTypeFilterOnAfterValid;
                    end;
                }
                field(VendNoFilterCtrl; VendNoFilter)
                {
                    Caption = 'Puchase Code Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        VendList: Page "Vendor List";
                        lfrmVendPriceGrList: Page " EN Vendor Price Groups";
                    begin
                        //<JF8569SHR>

                        IF goptPurchaseTypeFilter = goptPurchaseTypeFilter::"All Vendors" THEN EXIT;

                        CASE goptPurchaseTypeFilter OF
                            goptPurchaseTypeFilter::Vendor:
                                BEGIN
                                    VendList.LOOKUPMODE := TRUE;
                                    IF VendList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := VendList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                            goptPurchaseTypeFilter::"Vendor Price Group":
                                BEGIN
                                    lfrmVendPriceGrList.LOOKUPMODE := TRUE;
                                    IF lfrmVendPriceGrList.RUNMODAL = ACTION::LookupOK THEN
                                        Text := lfrmVendPriceGrList.GetSelectionFilter
                                    ELSE
                                        EXIT(FALSE);
                                END;
                        END;

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        VendNoFilterOnAfterValidate;
                    end;
                }
                field(ItemNoFIlterCtrl; ItemNoFilter)
                {
                    Caption = 'Item No. Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin
                        ItemList.LOOKUPMODE := TRUE;
                        IF ItemList.RUNMODAL = ACTION::LookupOK THEN
                            Text := ItemList.GetSelectionFilter
                        ELSE
                            EXIT(FALSE);

                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoFilterOnAfterValidate;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    Caption = 'Starting Date Filter';

                    trigger OnValidate()
                    var
                        TextManagement: Codeunit "TextManagement";
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
                        TextManagement: Codeunit "TextManagement";
                    begin

                        IF TextManagement.MakeDateFilter(gtxtEndingDateFilter) = 0 THEN;
                        ibEndingDateFilterOnAfterValid;

                    end;
                }
            }
            repeater(Repeater1)
            {
                field("Purchase Type"; "Purchase Type ELA")
                {
                }
                field("Vendor No."; "Vendor No.")
                {
                    Editable = gblnVendNoEditable;
                }

                field("Item No."; "Item No.")
                {
                }
                field("Location Code"; "Location Code ELA")
                {
                }
                field("Item Description"; "Item Description ELA")
                {
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Ending Date"; "Ending Date")
                {
                }
                field("Reason Code"; "Reason Code ELA")
                {
                    Visible = false;
                }
                field("Upcharge Type"; "Upcharge Type ELA")
                {
                }
                field("Upcharge Value"; "Upcharge Value ELA")
                {
                }
                field("Upcharge Amount"; "Upcharge Amount ELA")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Billback Type"; "Billback Type ELA")
                {
                }
                field("Billback Value"; "Billback Value ELA")
                {
                }
                field("Billback Amount"; "Billback Amount ELA")
                {
                    Editable = false;
                    Visible = false;
                }

                field("Discount 1 Type"; "Discount 1 Type ELA")
                {
                }
                field("Discount 1 Value"; "Discount 1 Value ELA")
                {
                }
                field("Discount 1 Amount"; "Discount 1 Amount ELA")
                {
                    Editable = false;
                    Visible = false;
                }

                field("Freight Type"; "Freight Type ELA")
                {
                }
                field("Freight Value"; "Freight Value ELA")
                {
                }
                field("Freight Amount"; "Freight Amount ELA")
                {
                    Editable = false;
                }
                field("List Cost ELA"; "List Cost ELA")
                {
                    Caption = 'List Cost';
                    Editable = false;
                    Visible = false;
                }
                field("Cost After Discounts"; "List Cost ELA" - "Discount 1 Amount ELA")
                {
                    Caption = 'Cost After Discounts';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("P.O. Cost"; "List Cost ELA" - "Discount 1 Amount ELA" + "Upcharge Amount ELA")
                {
                    Caption = 'P.O. Cost';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Cost After Billback"; "List Cost ELA" - "Discount 1 Amount ELA" + "Upcharge Amount ELA" - "Billback Amount ELA")
                {
                    Caption = 'Cost After Billback';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Landed Cost"; "List Cost ELA" - "Discount 1 Amount ELA" + "Upcharge Amount ELA" - "Billback Amount ELA" + "Freight Amount ELA")
                {
                    Caption = 'Landed Cost';
                    Editable = false;
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                }
            }
        }

    }

    actions
    {
    }

    trigger OnInit()
    begin
        gblnVendNoFilterCtrlEnable := TRUE;
        gblnVendNoEditable := TRUE;
    end;

    trigger OnOpenPage()
    begin
        SETFILTER("Starting Date", '%1..%2', 0D, WORKDATE);
        SETFILTER("Ending Date", '%1|>=%2', 0D, WORKDATE);
        GetRecFilters;
        SetRecFilters;
    end;

    var
        VendNoFilter: Code[30];
        ItemNoFilter: Code[30];
        StartingDateFilter: Text[30];
        Vend: Record Vendor;
        goptPurchaseTypeFilter: Option Vendor,"Vendor Price Group","All Vendors","None";
        gtxtOrderAddressCodeFilter: Text[250];
        grecVendPriceGr: Record "EN Vendor Price Group";
        gjfText000: Label 'All Vendors';
        [InDataSet]
        gblnVendNoEditable: Boolean;
        [InDataSet]
        gblnVendNoFilterCtrlEnable: Boolean;
        gtxtEndingDateFilter: Text[30];
        gtxtStartingDateFilter: Text[30];

    [Scope('Internal')]
    procedure GetRecFilters()
    begin
        IF GETFILTERS <> '' THEN BEGIN
            IF GETFILTER("Purchase Type ELA") <> '' THEN
                goptPurchaseTypeFilter := TransPurchaseTypeFilterToVar
            ELSE
                goptPurchaseTypeFilter := goptPurchaseTypeFilter::None;

            gtxtOrderAddressCodeFilter := GETFILTER("Order Address Code ELA");

            VendNoFilter := GETFILTER("Vendor No.");
            ItemNoFilter := GETFILTER("Item No.");
            StartingDateFilter := GETFILTER("Starting Date");
            gtxtEndingDateFilter := GETFILTER("Ending Date");
        END;
    end;

    [Scope('Internal')]
    procedure SetRecFilters()
    begin
        gblnVendNoFilterCtrlEnable := TRUE;

        IF goptPurchaseTypeFilter <> goptPurchaseTypeFilter::None THEN
            SETRANGE("Purchase Type ELA", TransPurchaseTypeVarToField)
        ELSE
            SETRANGE("Purchase Type ELA");

        IF goptPurchaseTypeFilter IN [goptPurchaseTypeFilter::"All Vendors", goptPurchaseTypeFilter::None] THEN BEGIN
            gblnVendNoFilterCtrlEnable := FALSE;
            VendNoFilter := '';
        END;

        IF gtxtOrderAddressCodeFilter <> '' THEN
            SETFILTER("Order Address Code ELA", gtxtOrderAddressCodeFilter)
        ELSE
            SETRANGE("Order Address Code ELA");

        IF VendNoFilter <> '' THEN
            SETFILTER("Vendor No.", VendNoFilter)
        ELSE
            SETRANGE("Vendor No.");

        IF StartingDateFilter <> '' THEN
            SETFILTER("Starting Date", StartingDateFilter)
        ELSE
            SETRANGE("Starting Date");

        IF gtxtEndingDateFilter <> '' THEN BEGIN
            SETFILTER("Ending Date", gtxtEndingDateFilter)
        END ELSE BEGIN
            SETRANGE("Ending Date");
        END;

        IF ItemNoFilter <> '' THEN BEGIN
            SETFILTER("Item No.", ItemNoFilter);
        END ELSE
            SETRANGE("Item No.");

        CurrPage.UPDATE(FALSE);
    end;

    [Scope('Internal')]
    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[100];
        Description: Text[250];
        ltxtPurchaseSrcTableName: Text[100];
    begin
        GetRecFilters;

        gblnVendNoEditable := "Purchase Type ELA" <> "Purchase Type ELA"::"All Vendors";
        SourceTableName := '';

        IF ItemNoFilter <> '' THEN
            SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27)
        ELSE
            SourceTableName := '';

        //<JF8569SHR>
        ltxtPurchaseSrcTableName := '';
        CASE goptPurchaseTypeFilter OF
            goptPurchaseTypeFilter::Vendor:
                BEGIN
                    ltxtPurchaseSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 23);
                    Vend."No." := VendNoFilter;
                    IF Vend.FIND THEN
                        Description := Vend.Name;
                END;
            goptPurchaseTypeFilter::"Vendor Price Group":
                BEGIN
                    ltxtPurchaseSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 23019005);
                    grecVendPriceGr.Code := VendNoFilter;
                    IF grecVendPriceGr.FIND THEN
                        Description := grecVendPriceGr.Description;
                END;
            goptPurchaseTypeFilter::"All Vendors":
                BEGIN
                    ltxtPurchaseSrcTableName := gjfText000;
                    Description := '';
                END;
        END;

        IF ltxtPurchaseSrcTableName = gjfText000 THEN
            EXIT(STRSUBSTNO('%1 %2 %3', ltxtPurchaseSrcTableName, SourceTableName, ItemNoFilter));
        EXIT(STRSUBSTNO('%1 %2 %3 %4 %5', ltxtPurchaseSrcTableName, VendNoFilter, Description, SourceTableName, ItemNoFilter));
    end;

    local procedure VendNoFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure TransPurchaseTypeFilterToVar() pint: Integer
    var
        lText030: Label 'No %1 conversion for %2 %3.';
    begin

        CASE GETFILTER("Purchase Type ELA") OF
            FORMAT("Purchase Type ELA"::Vendor):
                EXIT(0);
            FORMAT("Purchase Type ELA"::"Vendor Price Group"):
                EXIT(1);
            FORMAT("Purchase Type ELA"::"All Vendors"):
                EXIT(2);
        END;

    end;

    local procedure TransPurchaseTypeVarToField() pint: Integer
    var
        ljfText030: Label 'No %1 conversion for %2 %3.';
        lctxt000: Label 'Purchase Type Filter';
    begin

        CASE goptPurchaseTypeFilter OF
            goptPurchaseTypeFilter::Vendor:
                EXIT(0);
            goptPurchaseTypeFilter::"Vendor Price Group":
                EXIT(1);
            goptPurchaseTypeFilter::"All Vendors":
                EXIT(2);
            ELSE
                ERROR(ljfText030, FIELDNAME("Purchase Type ELA"), lctxt000, FORMAT(goptPurchaseTypeFilter));
        END;

    end;

    local procedure PurchTypeFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        VendNoFilter := '';
        SetRecFilters;
    end;

    local procedure OrdAddFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;

    local procedure ibEndingDateFilterOnAfterValid()
    begin
        CurrPage.SAVERECORD;
        SetRecFilters;
    end;
}

