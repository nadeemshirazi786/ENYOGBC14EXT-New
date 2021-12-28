tableextension 14229605 "EN Ship-to Address ELa" extends "Ship-to Address"
{
    fields
    {
        field(14228880; "Use Backorder Tolerance ELA"; Boolean)
        {
            Caption = 'Use Backorder Tolerance';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Backorder Tolerance % ELA"; Decimal)
        {
            Caption = 'Backorder Tolerance %';
            DecimalPlaces = 0:5;
            BlankZero = true;
            DataClassification = ToBeClassified;
        }
        field(14228810; "Shipping Instructions ELA"; Text[80])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
        field(14228831; "Delivery Zone Code ELA"; Code[20])
        {
            TableRelation = "Delivery Zone ELA".Code;
            Caption = 'Delivery Zone Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                lrecDeliveryZone: Record "Delivery Zone ELA";
            begin
                IF "Delivery Zone Code ELA" <> '' THEN BEGIN
                    lrecDeliveryZone.GET("Delivery Zone Code ELA");
                    lrecDeliveryZone.TESTFIELD(Type, lrecDeliveryZone.Type::Standard);
                END;
            end;
        }

        field(14228882; "Cash and Carry Location ELA"; Code[10])
        {
            Caption = 'Cash and Carry Location';
            DataClassification = ToBeClassified;
        }

        field(14228850; "Ship-To Price Group"; Code[10])
        {
            Caption = 'Ship-To Price Group';
            DataClassification = ToBeClassified;
            TableRelation = "Customer Price Group";
        }
        field(14228851; "Invoice Disc. Code"; Code[20])
        {
            Caption = 'Invoice Disc. Code';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            ValidateTableRelation = false;

        }
        field(14228852; "Order Rule Group"; Code[20])
        {
            Caption = 'Order Rule Group';
            DataClassification = ToBeClassified;
            TableRelation = "EN Order Rule Group";

        }
    }

}