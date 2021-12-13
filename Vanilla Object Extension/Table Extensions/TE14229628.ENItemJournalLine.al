tableextension 14229628 "EN Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        field(14229400; "Quality Measure Code ELA"; Code[20])
        {
            Caption = 'Quality Measure Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                CASE "Entry Type" OF
                    "Entry Type"::Output:
                        begin
                            IF (Item."Reporting UOM ELA" <> '') AND
                               ("Value Entry Type" <> "Value Entry Type"::Revaluation)
                            THEN BEGIN
                                VALIDATE("Unit of Measure Code", Item."Reporting UOM ELA");
                            END;
                        end;
                end;
            end;
        }
        field(14229120; "Order Type Ext ELA"; Enum "EN Order type")
        {
            Caption = 'Order Type Ext';
            DataClassification = ToBeClassified;

        }
        field(14228901; "Trans. No. ELA"; Code[20])
        {
            Caption = 'Trans. No.';
            DataClassification = ToBeClassified;


        }
        field(14228902; "Delivery Route No. ELA"; Code[20])
        {
            Caption = 'Delivery Route No.';
            DataClassification = ToBeClassified;
        }

        field(14229903; "Purchase Order No. ELA"; Code[20])
        {
            Caption = 'Purchase Order No.';

        }
        field(14229150; "New Lot Status Code ELA"; Code[20])
        {
            Caption = 'New Lot Status Code';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                CheckMoveContainerELA(FIELDCAPTION("New Lot Status Code ELA"));

                P800ItemTracking.ItemJnlValidateNewLotStatus(xRec, Rec);
            end;
        }
        field(14229151; "Country/Regn of Orign Code ELA"; Code[20])
        {
            Caption = 'ELA Country/Region of Origin Code';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(14229154; "Quantity (Alt.) ELA"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229155; "Invoiced Qty. (Alt.) ELA"; Decimal)
        {
            Caption = 'Invoiced Qty. (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229156; "Qty. (Alt.) (Calculated) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Calculated)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                VALIDATE("Qty. (Alt.) (Phys. Inv) ELA");
            end;
        }
        field(14229157; "Qty. (Alt.) (Phys. Inv) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Phys. Inventory)';
            DataClassification = ToBeClassified;
        }
    }
    procedure UpdateLotTracking(ForceUpdate: Boolean)
    var
        EasyLotTracking: Codeunit "Easy Lot Tracking ELA";
        QtyToHandle: Decimal;
        QtyToHandleAlt: Decimal;
    begin

        EasyLT := FALSE;
        IF ("Lot No." = P800Globals.MultipleLotCode) OR (NOT ProcessFns.TrackingInstalled) OR
          (("Lot No." = '') AND (("Line No." <> xRec."Line No.") OR (xRec."Lot No." = '')))
        THEN
            EXIT;

        EasyLotTracking.TestItemJnlLine(Rec);
        IF "Line No." = 0 THEN
            EXIT;

        CLEAR(ReserveItemJnlLine);

        ReserveItemJnlLine.DeleteLine(Rec);

        QtyToHandle := "Quantity (Base)";

        EasyLotTracking.SetItemJnlLine(Rec, 0);
        EasyLotTracking.SetNewLotNo(xRec."New Lot No.", "New Lot No.");
        EasyLotTracking.SetNewLotStatus(xRec."New Lot Status Code ELA", "New Lot Status Code ELA");
        EasyLotTracking.ReplaceTracking(xRec."Lot No.", "Lot No.", 0,
          "Quantity (Base)", QtyToHandle, QtyToHandleAlt, "Quantity (Base)");

    end;

    procedure CheckMoveContainerELA(FldCaption: text[50])
    begin
        // P8001323
        //IF (CurrFieldNo <> 0) AND ("Container Master Line No." <> 0) THEN
        //  ERROR(Text37002001,FldCaption);
        //ENX
    end;


    procedure GetCostingQtyELA(FldNo: Integer): Decimal
    begin
        //>>ENEC1.00
        CASE FldNo OF
            FIELDNO(Quantity):
                EXIT(Quantity);
            FIELDNO("Quantity (Base)"):
                EXIT("Quantity (Base)");
            FIELDNO("Invoiced Quantity"):
                EXIT("Invoiced Quantity");
            FIELDNO("Invoiced Qty. (Base)"):
                EXIT("Invoiced Qty. (Base)");
            FIELDNO("Scrap Quantity"):
                EXIT("Scrap Quantity");
            FIELDNO("Scrap Quantity (Base)"):
                EXIT("Scrap Quantity (Base)");
        END;
        //>>ENEC1.00
    end;

    var

        P800ItemTracking: Codeunit "Process 800 Item Tracking ELA";
        ReserveItemJnlLine: Codeunit "Item Jnl. Line-Reserve";
        P800Globals: Codeunit "Process 800 System Globals ELA";
        ItemTrackingCode: Record "Item Tracking Code";
        EasyLT: Boolean;
        ProcessFns: Codeunit "Process 800 Functions ELA";
        Item: Record Item;

}
