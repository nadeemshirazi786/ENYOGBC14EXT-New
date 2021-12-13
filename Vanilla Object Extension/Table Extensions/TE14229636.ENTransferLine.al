tableextension 14229636 "EN LT TransferLine EXT ELA" extends "Transfer Line"
{
    fields
    {
        field(14229150; "Lot No. ELA"; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin


                IF "Line No." <> 0 THEN BEGIN
                    MODIFY;
                    UpdateLotTracking(TRUE, 0);
                END;
            end;
        }
        modify("Item No.")
        {
            trigger ONAfterValidate()
            var
                lItem:Record Item;
            begin
                IF lItem.GET("Item No.") THEN begin
                    IF lItem."Reporting UOM ELA" <> '' THEN begin
                        VALIDATE("Unit of Measure Code",lItem."Reporting UOM ELA");
                    end else begin
                        VALIDATE("Unit of Measure Code",lItem."Base Unit of Measure");
                    end;
                end;
            end;
        }

    }
    procedure UpdateLotTracking(ForceUpdate: Boolean; Direction: Option)
    begin

    end;

    procedure GetLotNo()
    begin

    end;

    var
        EasyLotTracking: Codeunit "Sales-Post Prepayments";
        Qty: Decimal;
        QtyToHandle: Decimal;
        QtyToHandleAlt: Decimal;
        AltQtyTransNo: Integer;


}

