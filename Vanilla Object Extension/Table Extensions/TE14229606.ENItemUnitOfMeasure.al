
tableextension 14229606 "EN Item Unit Of Measure ELA" extends "Item Unit of Measure"
{
    fields
    {
        field(14228850; "Qty. per Base UOM ELA"; Decimal)
        {
            Caption = 'Qty. per Base UOM';
            InitValue = 1;
            DecimalPlaces = 0 : 15;

            trigger OnValidate()
            begin


                IF CurrFieldNo = FIELDNO("Qty. per Base UOM ELA") THEN BEGIN
                    CheckUOM_ELA;
                END;

                gcduUOMMgmt.TestItemUOMPrecision("Qty. per Base UOM ELA");

                IF "Qty. per Base UOM ELA" <= 0 THEN
                    FIELDERROR("Qty. per Base UOM ELA", Text000_ELA);

                gblnFromQtyPerBaseUOM := TRUE;

                VALIDATE("Qty. per Unit of Measure", ROUND(1 / "Qty. per Base UOM ELA", gcduUOMMgmt.GetItemUOMPrecision));

                gblnFromQtyPerBaseUOM := FALSE;

            end;


        }
        field(14228851; "Item UOM Size Code ELA"; Code[10])
        {
            Caption = 'Item UOM Size Code';
            TableRelation = "EN Unit of Measure Size";
        }
        field(14228852; "No. of Servings ELA"; Integer)
        {
            Caption = 'No. of Servings';
            DataClassification = ToBeClassified;
            MinValue = 0;
        }
        field(14228853; "UOM Group ELA"; Code[10])
        {
            Caption = 'UOM Group';
            DataClassification = ToBeClassified;

        }


        field(14228882; "Allow Variable Qty. Per ELA"; Boolean)
        {
            Caption = 'Allow Variable Qty. Per';
            DataClassification = ToBeClassified;
        }
        field(14229100; "Type ELA"; Enum "EN Dimension Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(51001; "Std. Pack UPC/EAN Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        modify("Qty. per Unit of Measure")
        {

            trigger OnAfterValidate()
            begin

                IF CurrFieldNo = FIELDNO("Qty. per Unit of Measure") THEN BEGIN
                    CheckUOM_ELA;
                END;
                gcduUOMMgmt.TestItemUOMPrecision("Qty. per Unit of Measure");

                IF NOT gblnFromQtyPerBaseUOM THEN BEGIN
                    "Qty. per Base UOM ELA" := ROUND(1 / "Qty. per Unit of Measure", gcduUOMMgmt.GetItemUOMPrecision);
                END;
                gblnFromQtyPerBaseUOM := FALSE;
            end;

        }
		field(14229220; "Case Barcode ELA"; Code[20])
        {
            Caption = 'Case Barcode';
            DataClassification = ToBeClassified;
        }

        field(14229221; "Is Bulk ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Bulk';

            trigger OnValidate()
            var
                ItemUnitOfMeasure: record "Item Unit of Measure";
                TEXT14229220: Label 'Unable to mark %1 as bulk unit for Item No. %2';
            begin
                if "Is Bulk ELA" then begin
                    ItemUnitOfMeasure.SetRange("Item No.", "Item No.");
                    ItemUnitOfMeasure.SetRange("Is Bulk ELA", true);
                    ItemUnitOfMeasure.SetFilter(Code, '<>%1', Rec.Code);
                    if ItemUnitOfMeasure.FindFirst() then
                        Error(
                            StrSubstNo(TEXT14229220, Code, "Item No."));
                end;
            end;
        }
        field(14229222; "Item Description ELA"; Text[30])
        {
            Caption = 'Item Description';
            DataClassification = ToBeClassified;
        }

        field(14229223; "Std. Pack UPC/EAN Number ELA"; Code[20])
        {
            Caption = 'Std. Pack UPC/EAN Number';
            DataClassification = ToBeClassified;
            /* trigger OnValidate()
             var
                 Item: Record Item;
             begin

                 IF NOT ISSERVICETIER THEN BEGIN //EN1.03
                     IF NOT (STRLEN("Std. Pack UPC/EAN Number ELA") IN [0, 14]) THEN
                         IF NOT CONFIRM(
                                  Text14000701, FALSE,
                                  FIELDNAME("Std. Pack UPC/EAN Number ELA"))
                         THEN
                             ERROR(Text14000702);

                     IF "Std. Pack UPC/EAN Number ELA" <> '' THEN BEGIN
                         Item.GET("Item No.");
                         IF Item."Item UPC ELA" <> '' THEN
                             IF (STRPOS("Std. Pack UPC/EAN Number ELA", Item."Item UPC ELA") = 0) AND
                                (STRPOS(
                                   "Std. Pack UPC/EAN Number ELA",
                                   COPYSTR(Item."Item UPC ELA", 1, STRLEN(Item."Item UPC ELA") - 1)) = 0)
                             THEN
                                 IF NOT CONFIRM(
                                          Text14000703, FALSE,
                                          Item.FIELDNAME("Item UPC ELA"), Item."Item UPC ELA",
                                          FIELDNAME("Std. Pack UPC/EAN Number ELA"))
                                 THEN
                                     ERROR(Text14000702);
                     END;
                 END; // EN1.03

                 //<<EN1.03
                 NewBarcode := "Std. Pack UPC/EAN Number ELA";
                 NewBarcode := DELCHR(NewBarcode, '=', '(');
                 NewBarcode := DELCHR(NewBarcode, '=', ')');
                 Barcode := NewBarcode;
             end;*/
        }
        field(14229224; "Label Description ELA"; Text[80])
        {
            Caption = 'Label Description';
            DataClassification = ToBeClassified;
        }
        field(14229225; "Lable Size ELA"; Text[20])
        {
            Caption = 'Lable Size';
            DataClassification = ToBeClassified;
        }
        field(14229226; "Base Quantity ELA"; Decimal)
        {
            Caption = 'Base Quantity';
            DataClassification = ToBeClassified;
        }
        field(14229227; "Putaway Unit of Measure ELA"; Code[10])
        {
            Caption = 'Putaway Unit of Measure';
            DataClassification = ToBeClassified;
        }
        field(14229228; "Base Unit of Measure ELA"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = ToBeClassified;
        }
    }
    procedure CheckUOM_ELA()
    var
        lrecItem: Record Item;
        lrecProdBOMLine: Record "Production BOM Line";
        lrecProdOrderLine: Record "Prod. Order Line";
        lrecProdOrderComponent: Record "Prod. Order Component";
        lrecReqLine: Record "Requisition Line";
        lrecItemJournalLine: Record "Item Journal Line";
    begin

        lrecItem.GET("Item No.");

        IF lrecItem."Sales Unit of Measure" = Code THEN BEGIN
            IF NOT CONFIRM(Text002_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;
        IF lrecItem."Purch. Unit of Measure" = Code THEN BEGIN
            IF NOT CONFIRM(Text003_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;

        lrecProdBOMLine.SETCURRENTKEY(Type, "No.");
        lrecProdBOMLine.SETRANGE(Type, lrecProdBOMLine.Type::Item);
        lrecProdBOMLine.SETRANGE("No.", lrecItem."No.");
        IF lrecProdBOMLine.FINDSET THEN BEGIN
            IF NOT CONFIRM(Text005_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;


        lrecProdOrderLine.SETCURRENTKEY("Item No.", "Variant Code", "Location Code", Status, "Ending Date");
        lrecProdOrderLine.SETRANGE("Item No.", lrecItem."No.");
        lrecProdOrderLine.SETRANGE("Variant Code");
        lrecProdOrderLine.SETRANGE("Location Code");
        lrecProdOrderLine.SETRANGE(Status);
        lrecProdOrderLine.SETRANGE("Ending Date");
        IF lrecProdOrderLine.FINDSET THEN BEGIN
            IF NOT CONFIRM(Text006_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;

        lrecProdOrderComponent.SETCURRENTKEY("Item No.", "Due Date");
        lrecProdOrderComponent.SETRANGE("Item No.", lrecItem."No.");
        lrecProdOrderComponent.SETRANGE("Due Date");
        IF lrecProdOrderComponent.FINDSET THEN BEGIN
            IF NOT CONFIRM(Text007_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;


        lrecReqLine.SETCURRENTKEY(Type, "No.", "Variant Code", "Location Code", "Sales Order No.", "Order Date");
        lrecReqLine.SETRANGE(Type, lrecReqLine.Type::Item);
        lrecReqLine.SETRANGE("No.", lrecItem."No.");
        lrecReqLine.SETRANGE("Location Code");
        lrecReqLine.SETRANGE("Sales Order No.");
        lrecReqLine.SETRANGE("Order Date");
        IF lrecReqLine.FINDSET THEN BEGIN
            IF NOT CONFIRM(Text008_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;

        lrecItemJournalLine.SETCURRENTKEY("Item No.", "Posting Date");
        lrecItemJournalLine.SETRANGE("Item No.", lrecItem."No.");
        lrecItemJournalLine.SETRANGE("Posting Date");
        IF lrecItemJournalLine.FINDSET THEN BEGIN
            IF NOT CONFIRM(Text009_ELA, FALSE) THEN BEGIN
                ERROR('');
            END ELSE BEGIN
                EXIT;
            END;
        END;
    end;

    var
        gcduUOMMgmt: Codeunit "EN UOM Management";
        gblnFromQtyPerBaseUOM: Boolean;
        Text000_ELA: Label 'must be greater than 0';
        Text001_ELA: Label 'Only one %1 can be setup as a %2 %3.';
        Text002_ELA: Label 'This is the Sales Unit of Measure. Do you still wish to update?';
        Text003_ELA: Label 'This is the Purch. Unit of Measure. Do you still wish to update?';
        Text004_ELA: Label 'This is the Prod. BOM Unit of Measure. Do you still wish to update?';
        Text005_ELA: Label 'This Item is used in a Production BOM. Do you still wish to update?';
        Text006_ELA: Label 'This Item is used on a Production Order. Do you still wish to update?';
        Text007_ELA: Label 'This Item is used as a Production BOM Component. Do you still wish to update?';
        Text008_ELA: Label 'This Item is used on a Requisition Line. Do you still wish to update?';
        Text009_ELA: Label 'This Item is used on an Item Journal Line. Do you still wish to update?';


}
