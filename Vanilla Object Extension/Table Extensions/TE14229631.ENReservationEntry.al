tableextension 14229631 "EN LT ReservationEntry EXT ELA" extends "Reservation Entry"
{
    fields
    {
        field(14229150; "Supplier Lot No. ELA"; Code[20])
        {
            Caption = 'Supplier Lot No.';
            DataClassification = ToBeClassified;

        }
        field(14229151; "Lot Creation Date ELA"; Date)
        {
            Caption = 'Lot Creation Date';
            DataClassification = ToBeClassified;
        }
        field(14229152; "Country/Regn of Orign Code ELA"; Code[20])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(14229153; "New Lot Status Code ELA"; Code[20])
        {
            Caption = 'New Lot Status Code';
            DataClassification = ToBeClassified;
        }
        field(14229154; "Phys. Inventory ELA"; Boolean)
        {
            Caption = 'Phys. Inventory';
            DataClassification = ToBeClassified;
        }
        field(14229155; "Quantity (Alt.) ELA"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                "Qty. to Handle (Alt.) ELA" := "Quantity (Alt.) ELA";
                "Qty. to Invoice (Alt.) ELA" := "Quantity (Alt.) ELA";
            end;
        }
        field(14229156; "Qty. to Handle (Alt.) ELA"; Decimal)
        {
            Caption = 'Qty. to Handle (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229158; "Qty. to Invoice (Alt.) ELA"; Decimal)
        {
            Caption = 'Qty. to Invoice (Alt.)';
            DataClassification = ToBeClassified;
        }
        field(14229160; "Qty. (Alt.) (Calculated) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Calculated)';
            DataClassification = ToBeClassified;
        }
        field(14229161; "Qty. (Alt.) (Phys. Inv) ELA"; Decimal)
        {
            Caption = 'Qty. (Alt.) (Phys. Inventory)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                "Qty. to Handle (Alt.) ELA" := "Qty. (Alt.) (Phys. Inv) ELA" - "Qty. (Alt.) (Calculated) ELA";
                "Quantity (Alt.) ELA" := "Qty. to Handle (Alt.) ELA";
                "Qty. to Invoice (Alt.) ELA" := "Qty. to Handle (Alt.) ELA";
            end;
        }
        field(14229162; "Qty. (Phys. Inventory) ELA"; Decimal)
        {
            Caption = 'Qty. (Phys. Inventory)';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Text14229150: TextConst ENU = 'Serialized items may only have counts of 0 or 1.';
                ItemJnlLine: Record "Item Journal Line";
            begin
                IF "Serial No." <> '' THEN
                    IF NOT ("Qty. (Phys. Inventory) ELA" IN [0, 1]) THEN
                        ERROR(Text14229150);

                VALIDATE("Quantity (Base)", "Qty. (Phys. Inventory) ELA" - "Qty. (Calculated) ELA");
                Positive := "Quantity (Base)" >= 0;

                IF Positive THEN
                    "Source Subtype" := ItemJnlLine."Entry Type"::"Positive Adjmt."
                ELSE
                    "Source Subtype" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
            end;
        }
        field(14229163; "Qty. (Calculated) ELA"; Decimal)
        {
            Caption = 'Qty. (Calculated)';
            DataClassification = ToBeClassified;
        }
    }

}

