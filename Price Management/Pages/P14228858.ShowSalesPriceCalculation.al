page 14228858 "Show Sales Price Calculation"
{

    Caption = 'Item Sales Price Calculation';
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    UsageCategory = Tasks;
    SaveValues = true;
    SourceTable = "EN Sales Price";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Pricing Information")
            {
                Caption = 'Pricing Information';

                label(gtxtMessage)
                {


                    Style = Attention;
                    StyleExpr = TRUE;
                }
                label(gtxtMessage2)
                {


                }
                field("Last Price Paid"; grecSalesInvLine."Unit Price")
                {

                }
                field("Last Price Paid Date"; grecSalesInvLine."Posting Date")
                {

                }
                field("Quantity Purchased"; grecSalesInvLine.Quantity)
                {

                }
                field("Document No."; grecSalesInvLine."Document No.")
                {


                    trigger OnAssistEdit()
                    begin
                        IF grecSalesInvHeader.GET(grecSalesInvLine."Document No.") THEN
                            PAGE.RUN(PAGE::"Posted Sales Invoice", grecSalesInvHeader);
                    end;
                }


            }
            repeater(GeneralRepeater)
            {
                field("Price Calc. Ranking"; "Price Calc. Ranking")
                {
                }
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
                field(Code; Code)
                {
                }
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field("Ship-From Location"; "Ship-From Location")
                {
                    Visible = false;
                }
                field("Calculated Price"; "Calculated Price")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
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
                field(gdecAlternateCost; gdecAlternateCost)
                {
                    AutoFormatType = 2;
                    Caption = 'Alternate Sales Cost';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = false;


                }
                field("Calculation Base Price"; "Calculation Base Price")
                {
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                }
                field("Rounding Method"; "Rounding Method")
                {
                    Visible = false;
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    Visible = false;
                }
                field("Contract Price"; "Contract Price")
                {
                    Visible = false;
                }
                field("Contract Code"; "Contract Code")
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
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin


    end;

    trigger OnInit()
    begin
        "Sales CodeEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

    end;

    trigger OnOpenPage()
    begin
        grecSalesSetup.GET;
        IF "Price Rule" THEN BEGIN
            gtxtMessage := STRSUBSTNO(gtxc004, "Price Rule Code");
            gtxtMessage2 := '';
        END ELSE BEGIN
            gtxtMessage := STRSUBSTNO(gtxc001, FORMAT(grecSalesSetup."Sales Pricing Model ELA"));
            CASE grecSalesSetup."Sales Pricing Model ELA" OF
                grecSalesSetup."Sales Pricing Model ELA"::"Best Price":
                    gtxtMessage2 := gtxc003;
                grecSalesSetup."Sales Pricing Model ELA"::"Specific Price":
                    gtxtMessage2 := gtxc002;
            END;
        END;

        grecSalesInvLine.SETCURRENTKEY("Sell-to Customer No.", Type, "No.", "Shipment Date");
        grecSalesInvLine.SETRANGE("Sell-to Customer No.", grecSalesLine."Sell-to Customer No.");
        grecSalesInvLine.SETRANGE(Type, grecSalesLine.Type);
        grecSalesInvLine.SETRANGE("No.", grecSalesLine."No.");
        IF NOT grecSalesInvLine.FINDLAST THEN
            CLEAR(grecSalesInvLine);
    end;

    var
        Text000: Label 'All Customers';
        grecSalesSetup: Record "Sales & Receivables Setup";
        gtxtMessage: Text[1024];
        gtxtMessage2: Text[1024];
        gdecAlternateCost: Decimal;

        gtxc001: Label 'The Current Sales Pricing Model is set to %1.';
        gtxc002: Label 'The Hierarchy is established based on the values in the Price Hierarchy Ranking table.';
        gtxc003: Label 'The best price in all applicable pricing scenarios will be applied to the Customer''s order.';
        grecSalesLine: Record "Sales Line";
        grecSalesInvLine: Record "Sales Invoice Line";
        grecSalesInvHeader: Record "Sales Invoice Header";
        [InDataSet]
        "Sales CodeEditable": Boolean;
        gtxc004: Label 'Price Evaluation Rule being used for Price Rule Code %1.';





    procedure SetRecords(var precSalesPriceCalc: Record "EN Sales Price" temporary; precSalesLine: Record "Sales Line")
    begin
        IF precSalesPriceCalc.FINDSET THEN
            REPEAT
                Rec := precSalesPriceCalc;
                INSERT;
                IF (precSalesLine."Price Calc. GUID ELA" = precSalesPriceCalc.GUID) AND
                   (NOT ISNULLGUID(precSalesLine."Price Calc. GUID ELA"))
                THEN
                    MARK(TRUE);
            UNTIL precSalesPriceCalc.NEXT = 0;

        grecSalesLine := precSalesLine;

        SETCURRENTKEY("Price Calc. Ranking");
        ASCENDING(FALSE);
    end;

    //local procedure OnAfterGetCurrRecord()
    // begin
    //     xRec := Rec;
    //     "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";
    // end;
}

