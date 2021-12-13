tableextension 14229627 "EN Purchase  Line ELA" extends "Purchase Line"
{
    fields
    {
        modify(Quantity)
        {
            trigger ONAfterValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
                Item: Record Item;
            begin
                IF (xRec.Quantity <> Quantity) OR (xRec."Quantity (Base)" <> "Quantity (Base)") THEN
                    UpdateLotTracking(false);
                IF (Type = Type::Item) AND ("No." <> '') THEN BEGIN

                    IF (Item.Get("No.")) AND (ItemUOM.GET("No.", 'PALLET')) THEN
                        "Pallet Count ELA" := ("Quantity (Base)" / ItemUOM."Qty. per Unit of Measure")
                    ELSE
                        "Pallet Count ELA" := 0;
                END;
                "Qty. Secondary (Base UOM) ELA" := "Quantity (Base)";
            end;
        }
        modify("Qty. to Invoice")
        {
            trigger OnAfterValidate()
            begin
                UpdateLotTracking(false);
            end;
        }
        modify("Qty. to Receive")
        {
            trigger OnAfterValidate()
            begin
                GetLocation("Location Code");
                UpdateLotTracking(false);
            end;
        }
        modify("Return Qty. Shipped")
        {
            trigger OnAfterValidate()
            begin
                UpdateLotTracking(false);
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                IF xRec."Location Code" <> "Location Code" THEN BEGIN
                    IF "Prepmt. Amt. Inv." <> 0 THEN
                        IF NOT ConfirmManagement.ConfirmProcess(
                             STRSUBSTNO(
                               Text046, FIELDCAPTION("Direct Unit Cost"), FIELDCAPTION("Location Code"), PRODUCTNAME.FULL), TRUE)
                        THEN BEGIN
                            "Location Code" := xRec."Location Code";
                            EXIT;
                        END;
                    TESTFIELD("Qty. Rcd. Not Invoiced", 0);
                    TESTFIELD("Receipt No.", '');

                    TESTFIELD("Return Qty. Shipped Not Invd.", 0);
                    TESTFIELD("Return Shipment No.", '');
                    AutoLotNo(FALSE); // P8001234
                END;
                TestItemDocumentBlock;
            end;
        }
        modify("Bin Code")
        {
            trigger OnAfterValidate()
            begin
                GetLocation("Location Code");

            end;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            begin

                TestItemDocumentBlock;
            end;
        }
        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                TestItemDocumentBlock;
            end;
        }
        field(14228900; "Country/Reg of Origin Code ELA"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
        }
        field(14229100; "Extra Charge Code ELA"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = ToBeClassified;
        }
        field(14229101; "Purch. Ord for Ext Charge ELA"; Code[20])
        {
            caption = 'Purch. Order for Extra Charge';
            DataClassification = ToBeClassified;
        }
        field(14229102; "Extra Charge ELA"; Decimal)
        {
            Caption = 'Extra Charge';
            AutoFormatExpression = "Currency Code";
            FieldClass = FlowField;
            CalcFormula = Sum("EN Document Extra Charge".Charge WHERE("Table ID" = CONST(39), "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Line No." = FIELD("Line No.")));
        }
        field(14229103; "Pallet Count ELA"; Decimal)
        {
            Caption = 'Pallet Count';
            DataClassification = ToBeClassified;
        }

        field(14229150; "Lot No. ELA"; Code[20])

        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Text031: TextConst ENU = 'You cannot define item tracking on this line because it is linked to production order %1.';

            begin
                IF "Prod. Order No." <> '' THEN
                    ERROR(Text031, "Prod. Order No.");
                IF ("Lot No. ELA" = '') THEN BEGIN
                    "Supplier Lot No. ELA" := '';
                    "Creation Date ELA" := 0D;
                    "Purch Price Unit of Meas. ELA" := '';
                END;
                IF "Line No." <> 0 THEN BEGIN
                    MODIFY;
                    UpdateLotTracking(FALSE);
                END;

            end;
        }
        field(14229151; "Quantity (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229152; "Qty. to Invoice (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229153; "Alt. Qty. Transaction No. ELA"; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            DataClassification = ToBeClassified;
        }

        field(14229155; "Supplier Lot No. ELA"; Code[20])
        {
            Caption = 'Supplier Lot No.';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF ("Supplier Lot No. ELA" <> '') THEN
                    TESTFIELD("Lot No. ELA");
                IF "Line No." <> 0 THEN BEGIN
                    MODIFY;
                    UpdateLotTracking(false);
                end;
            end;
        }
        field(14229156; "Creation Date ELA"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF ("Creation Date ELA" <> 0D) THEN
                    TESTFIELD("Lot No. ELA");
                IF "Line No." <> 0 THEN BEGIN
                    MODIFY;
                    UpdateLotTracking(false);
                END;
            end;
        }
        field(14229158; "Lock Pricing ELA"; Boolean)
        {
            Caption = 'Lock Pricing';
        }

        field(14229157; "Purch Price Unit of Meas. ELA"; code[20])
        {
            Caption = 'Purchase Price Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            trigger OnValidate()
            var
                gjftext033: TextConst ENU = 'You changed the %1 when Lock Pricing is set. \Confirm pricing is correct';

            begin
                IF "Country/Reg of Origin Code ELA" <> '' THEN
                    TESTFIELD(Type, Type::Item);

                IF Type = Type::Item THEN
                    UpdateDirectUnitCost(FIELDNO("Country/Reg of Origin Code ELA"));
                IF (Type = Type::Item) AND ("Country/Reg of Origin Code ELA" <> xRec."Country/Reg of Origin Code ELA") AND ("Lock Pricing ELA") AND ("Direct Unit Cost" <> 0) THEN BEGIN
                    MESSAGE(gjftext033, FIELDNAME("Country/Reg of Origin Code ELA"))
                END;

            end;
        }
        field(14229159; "Qty. to Receive (Alt.) ELA"; Decimal)
        {
            Caption = 'Qty. to Receive (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229160; "Qty. Received (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229161; "Return Qty. Shipped (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229162; "Qty. Invoiced (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229163; "Return Qty. to Ship (Alt.) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14229164; "Qty. Secondary (Base UOM) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                lcduSecUOMMgt: Codeunit "EN UOM Management";

            begin

                IF Type = Type::Item THEN BEGIN
                    IF lcduSecUOMMgt.CheckAllowVariableUOM("No.", "Unit of Measure Code", TRUE) THEN BEGIN
                        IF Quantity <> 0 THEN BEGIN
                            "Qty. per Unit of Measure" := ROUND("Qty. Secondary (Base UOM) ELA" / Quantity, 0.00001);
                            lcduSecUOMMgt.CheckVariableUOMTolerance("No.", "Unit of Measure Code", "Qty. per Unit of Measure", TRUE);
                        END;
                    END;
                END;

                VALIDATE(Quantity);

                IF Type = Type::Item THEN
                    UpdateDirectUnitCost(FIELDNO("Qty. Secondary (Base UOM) ELA"));
            end;
        }
        field(51001; "List Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51008; "Bottle Deposit"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    procedure GetLocation("Location Code": Code[10])
    var
        Location: Record Location;
        LocationCode: Code[10];

    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;


    procedure WarehouseLineQuantityELA(QtyBase: Decimal; QtyAlt: Decimal; QtyToInvBase: Decimal)
    begin
        UseWhseLineQty := TRUE;
        WhseLineQtyBase := QtyBase;

        WhseLineQtyToInvBase := QtyToInvBase; // P80077569

    end;

    procedure TestItemDocumentBlock()

    begin
        IF Type = Type::Item then begin
            GetItem;
            IF GetSKU THEN BEGIN
                SKU.TESTFIELD("Block From Purch Doc ELA", FALSE);
            END ELSE BEGIN
                Item.TESTFIELD("Block From Purch Doc ELA", FALSE);
            END;
        end;
    end;

    procedure GetItem()
    begin

        TESTFIELD("No.");
        IF Item."No." <> "No." THEN
            Item.GET("No.");
    end;

    procedure GetSKU(): Boolean
    begin

        TESTFIELD("No.");
        IF (SKU."Location Code" = "Location Code") AND
           (SKU."Item No." = "No.") AND
           (SKU."Variant Code" = "Variant Code")
        THEN
            EXIT(TRUE);
        IF SKU.GET("Location Code", "No.", "Variant Code") THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;

    procedure GetExtraChargeAmountELA()
    var
        ChargeAmount: Decimal;
    begin
        //<<ENEC1.00
        IF (Quantity <> 0) OR ("Extra Charge Code ELA" = '') OR ("Purch. Ord for Ext Charge ELA" = '') THEN
            EXIT;
        IF NOT ExtraChargeSummary.GET("Purch. Ord for Ext Charge ELA", "Extra Charge Code ELA") THEN
            EXIT;
        ChargeAmount := 0;
        ChargeAmount := ExtraChargeSummary."Charge Amount" - ExtraChargeSummary."Posted Invoice Amount";
        IF ChargeAmount > 0 THEN BEGIN
            VALIDATE(Quantity, 1);
            VALIDATE("Direct Unit Cost", ChargeAmount);
            MODIFY;
        END;
        //>>ENEC1.00    
    end;


    procedure ValidateShortcutECChargeELA(FieldNumber: Integer; Charge: Decimal)
    begin
        //<<ENEC1.00
        TestStatusOpen;
        TESTFIELD(Type, Type::Item);
        ExtraChargeMgt.ValidateExtraCharge(FieldNumber, Charge);
        IF "Line No." <> 0 THEN BEGIN
            ExtraChargeMgt.SaveExtraCharge(DATABASE::"Purchase Line",
                "Document Type", "Document No.", "Line No.", FieldNumber, Charge);
            CALCFIELDS("Extra Charge ELA");
        END ELSE BEGIN
            ExtraChargeMgt.SaveTempExtraCharge(FieldNumber, Charge);
            "Extra Charge ELA" := ExtraChargeMgt.TotalTempExtraCharge;
        END;
        //>>ENEC1.00
    end;

    procedure ExtraChargeUnitCostELA(): Decimal
    begin
        //<<ENEC1.00
        CALCFIELDS("Extra Charge ELA");
        IF Quantity <> 0 THEN
            EXIT("Extra Charge ELA" / Quantity);
        //>>ENEC1.00
    end;

    procedure LineAmountWithExtraChargeELA(): Decimal
    begin
        //<<ENEC1.00
        CALCFIELDS("Extra Charge ELA");
        EXIT("Line Amount" + "Extra Charge ELA");
        //>>ENEC1.00
    end;

    procedure ShowExtraChargesELA()
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        Extracharges: Page "EN Document Hdr. Extra Charges";
    begin
        //<<ENEC1.00
        TESTFIELD("Document No.");
        TESTFIELD("Line No.");
        TESTFIELD(Type, Type::Item);
        DocExtraCharge.RESET;
        DocExtraCharge.SETRANGE("Table ID", DATABASE::"Purchase Line");
        DocExtraCharge.SETRANGE("Document Type", "Document Type");
        DocExtraCharge.SETRANGE("Document No.", "Document No.");
        DocExtraCharge.SETRANGE("Line No.", "Line No.");
        Extracharges.SETTABLEVIEW(DocExtraCharge);
        Extracharges.RUNMODAL;
        //>>ENEC1.00
    end;

    procedure ShowShortcutECChargeELA(VAR ShortcutECCharge: ARRAY[5] OF Decimal)
    begin
        //<<ENEC1.00
        IF "Line No." <> 0 THEN
            ExtraChargeMgt.ShowExtraCharge(DATABASE::"Purchase Line",
                "Document Type", "Document No.", "Line No.", ShortcutECCharge)
        ELSE
            ExtraChargeMgt.ShowTempExtraCharge(ShortcutECCharge);
        //>>ENEC1.00
    end;

    procedure GetLotNo()
    var
        EasyLotTracking: Codeunit "Easy Lot Tracking ELA";

    begin
        EasyLotTracking.SetPurchaseLine(Rec);
        "Lot No. ELA" := EasyLotTracking.GetLotNo;
        "Supplier Lot No. ELA" := EasyLotTracking.GetSupplierLotNo("Lot No. ELA");
        "Creation Date ELA" := EasyLotTracking.GetLotCreationDate("Lot No. ELA");
        "Purch Price Unit of Meas. ELA" := EasyLotTracking.GetCountryOfOrigin("Lot No. ELA");
    end;

    procedure UpdateLotTracking(ForceUpdate: Boolean)
    var
        P800Tracking: Codeunit "Process 800 Item Tracking ELA";
        EasyLotTracking: Codeunit "Easy Lot Tracking ELA";
        Handled: Boolean;
        UseWhseLineQty: Boolean;
        QtyBase: Decimal;
        WhseLineQtyBase: Decimal;
        QtyToHandle: Decimal;
        QtyToInvoice: Decimal;
        WhseLineQtyToInvBase: Decimal;
        QtyToHandleAlt: Decimal;
        Location: Record Location;
    begin
        IF Handled THEN
            EXIT;

        IF ((CurrFieldNo = 0) AND (NOT ForceUpdate)) OR (Type <> Type::Item) THEN
            EXIT;

        EasyLotTracking.TestPurchaseLine(Rec);
        IF "Line No." = 0 THEN
            EXIT;
        IF UseWhseLineQty THEN BEGIN
            QtyBase := WhseLineQtyBase;
            QtyToHandle := WhseLineQtyBase;
            QtyToInvoice := WhseLineQtyToInvBase;
        END ELSE BEGIN

            GetLocation("Location Code");
            CASE "Document Type" OF
                "Document Type"::Order, "Document Type"::Invoice:
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := "Qty. to Receive (Base)";
                        QtyToInvoice := "Qty. to Invoice (Base)";


                    END;
                "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := "Return Qty. to Ship (Base)";
                        QtyToInvoice := "Qty. to Invoice (Base)";

                    END ELSE BEGIN

                        QtyToHandle := "Return Qty. to Ship (Base)";
                        QtyToInvoice := "Qty. to Invoice (Base)";

                    END;
            END;

            QtyBase := "Quantity (Base)";
            EasyLotTracking.SetPurchaseLine(Rec);
            IF (xRec."Document Type" = 0) AND (xRec."Document No." = '') AND (xRec."Line No." = 0) THEN // P8000181A
                xRec."Lot No. ELA" := "Lot No. ELA";                                                              // P8000181A
            EasyLotTracking.SetSupplierLotNo(xRec."Supplier Lot No. ELA", "Supplier Lot No. ELA");
            EasyLotTracking.SetLotCreationDate(xRec."Creation Date ELA", "Creation Date ELA");                                 // P8008351
            EasyLotTracking.SetCountryOfOrigin(xRec."Purch Price Unit of Meas. ELA", "Purch Price Unit of Meas. ELA"); // P8008351
            EasyLotTracking.ReplaceTracking(xRec."Lot No. ELA", "Lot No. ELA", "Alt. Qty. Transaction No. ELA",
              QtyBase, QtyToHandle, QtyToHandleAlt, QtyToInvoice);
        end;

    end;

    procedure AutoLotNo(Posting: Boolean)
    var
        PurchLine: Record "Purchase Line";
        xPurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
        P800Tracking: Codeunit "Process 800 Item Tracking ELA";
    begin

        IF NOT ("Document Type" IN ["Document Type"::Order, "Document Type"::Invoice]) THEN
            EXIT;
        IF (Type <> Type::Item) OR ("No." = '') THEN
            EXIT;

        IF Posting AND ("Qty. to Receive" = 0) THEN
            EXIT;
        TESTFIELD("Document No.");
        IF ("Document Type" <> PurchHeader."Document Type") OR ("Document No." <> PurchHeader."No.") THEN BEGIN
            PurchHeader.GET("Document Type", "Document No.");
            IF PurchHeader."Currency Code" = '' THEN
                Currency.InitRoundingPrecision
            ELSE BEGIN
                PurchHeader.TESTFIELD("Currency Factor");
                Currency.GET(PurchHeader."Currency Code");
                Currency.TESTFIELD("Amount Rounding Precision");
            END;
        END;
        PurchLine := Rec;
        xPurchLine := xRec;
        IF Posting THEN BEGIN
            PurchLine."Expected Receipt Date" := PurchHeader."Posting Date";
            xPurchLine := PurchLine;
        END ELSE BEGIN
            PurchLine."Expected Receipt Date" := 0D;
            xPurchLine."Expected Receipt Date" := 0D;
        END;
        IF P800Tracking.AutoAssignLotNo(PurchLine, xPurchLine, "Lot No. ELA") THEN BEGIN

            UpdateLotTracking(true);
            IF Posting THEN
                MODIFY;
        END;
    end;

    procedure jfGetPurchPriceUOM(): Code[10]
    var
        lrecItemVendor: Record "Item Vendor";
        lrecVendor: Record Vendor;
        lrecItem: Record Item;
    begin
        IF Type <> Type::Item THEN
            EXIT('');

        lrecItemVendor.SETRANGE("Vendor No.", "Buy-from Vendor No.");
        lrecItemVendor.SETRANGE("Item No.", "No.");
        lrecItemVendor.SETRANGE("Variant Code", "Variant Code");
        lrecItemVendor.SETFILTER(Status, '%1|%2', lrecItemVendor.Status::" ", lrecItemVendor.Status::Approved);

        IF lrecItemVendor.FINDFIRST THEN
            IF lrecItemVendor."Purchase Price Unit of Measure" <> '' THEN
                EXIT(lrecItemVendor."Purchase Price Unit of Measure");

        lrecItem.GET("No.");

        IF lrecItem."Purchase Price Unit of Measure" <> '' THEN
            EXIT(lrecItem."Purchase Price Unit of Measure");

        lrecVendor.GET("Buy-from Vendor No.");

        IF lrecVendor."Purchase Price Unit of Measure" <> '' THEN
            EXIT(lrecVendor."Purchase Price Unit of Measure");
        EXIT('');
    end;

    procedure GetBottleAmount(recPurchLine: Record "Purchase Line") ptxtResult: Text[250]
    var
        recHeader: Record "Purchase Header";
        recState: Record "State ELA";
        ldecDecimalVariable: Decimal;
        UDCalc: Codeunit "UD Calculations ELA";
        recBottleSetup: Record "Bottle Deposit Setup";
    begin
        IF NOT recPurchLine."Bottle Deposit" then
            exit;
        IF (recPurchLine."No." = '') AND (recPurchLine.Type <> recPurchLine.Type::Item) then
            exit;
        IF recHeader.GET(recPurchLine."Document Type", recPurchLine."Document No.") then begin
            recBottleSetup.Reset();
            recBottleSetup.SetRange("Item No.", recPurchLine."No.");
            recBottleSetup.SetFilter("Bottle Deposit State", '<>%1', '');
            if recBottleSetup.FindFirst() then begin
                IF recBottleSetup.Get(recPurchLine."No.", recHeader."Buy-from County") then begin
                    ldecDecimalVariable := UDCalc.jfUOMConvert(
                                          recPurchLine."No.",
                                          recPurchLine."Unit of Measure Code",
                                          'EA',
                                          recBottleSetup."Bottle Deposit Amount");
                    ptxtResult := FORMAT(ROUND(ldecDecimalVariable, 0.01, '>'));
                end else
                    ptxtResult := Format(0);
            END ELSE begin
                IF recState.Get(recHeader."Buy-from County") then begin
                    ldecDecimalVariable := UDCalc.jfUOMConvert(
                                          recPurchLine."No.",
                                          recPurchLine."Unit of Measure Code",
                                          'EA',
                                          recState."Bottle Deposit ELA");
                    ptxtResult := FORMAT(ROUND(ldecDecimalVariable, 0.01, '>'));
                end else
                    ptxtResult := FORMAT(0);
            end;
        end;

    end;

    procedure CostInAlternateUnitsELA(): Boolean
    begin
        IF (Type <> Type::Item) OR ("No." = '') THEN
            EXIT(FALSE);
    end;

    procedure TestAltQtyEntryELA()
    begin
        IF ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN
            ;//AltQtyMgmt.TestWhseDataEntry("Location Code", Direction::Outbound)
             //AltQtyMgmt.TestWhseDataEntry("Location Code", Direction::Inbound);
    end;

    trigger OnInsert()
    begin
        UpdateLotTracking(true);
    end;

    trigger OnModify()
    begin
        IF ((Type = Type::Item) AND ("No." <> xRec."No.")) OR "Drop Shipment" THEN
            UpdateLotTracking("No." <> xRec."No.");
    end;

    var
        ExtraChargeSummary: record "EN Extra Charge Summary";
        ExtraChargeMgt: Codeunit "EN Extra Charge Management";
        ItemUOM: Record "Item Unit of Measure";
        myInt: Integer;
        Item: Record Item;
        QtyToHandle: Boolean;
        QtyToHandleAlt: Boolean;
        QtyToInvoice: Boolean;
        QtyBase: Boolean;
        Handled: Decimal;
        UseWhseLineQty: Boolean;
        WhseLineQtyBase: Decimal;
        WhseLineQtyToInvBase: Decimal;
        P800Globals: Codeunit "Process 800 System Globals ELA";
        ProcessFns: Codeunit "Process 800 Functions ELA";
        Text046: Textconst ENU = '%3 will not update %1 when changing %2 because a prepayment invoice has been posted. Do you want to continue?';
        SKU: Record "Stockkeeping Unit";
}