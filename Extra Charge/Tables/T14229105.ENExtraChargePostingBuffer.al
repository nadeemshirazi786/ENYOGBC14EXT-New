table 14229105 "EN Extra Charge Posting Buffer"
{


    Caption = 'Extra Charge Posting Buffer';

    fields
    {
        field(1; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
        }
        field(2; Charge; Decimal)
        {
            Caption = 'Charge';
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(4; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
        }
        field(5; "Recv/Ship Charge"; Decimal)
        {
            Caption = 'Recv/Ship Charge';
        }
        field(6; "Invoicing Charge"; Decimal)
        {
            Caption = 'Invoicing Charge';
        }
        field(7; "Recv/Ship Charge (LCY)"; Decimal)
        {
            Caption = 'Recv/Ship Charge ($)';
        }
        field(8; "Invoicing Charge (LCY)"; Decimal)
        {
            Caption = 'Invoicing Charge ($)';
        }
        field(9; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
        }
        field(10; "Cost To Post"; Decimal)
        {
            Caption = 'Cost To Post';
        }
        field(11; "Cost To Post (ACY)"; Decimal)
        {
            Caption = 'Cost To Post (ACY)';
        }
        field(12; "Cost To Post (Expected)"; Decimal)
        {
            Caption = 'Cost To Post (Expected)';
        }
        field(13; "Cost To Post (Expected) (ACY)"; Decimal)
        {
            Caption = 'Cost To Post (Expected) (ACY)';

        }
        field(14; "Sales Line No."; Decimal)
        {
            Caption = 'Sales Line No.';
        }
        field(15; "Vendor No."; Code[20])
        {
            Caption = 'Vendor';
        }
    }

    keys
    {
        
        key(Key1; "Extra Charge Code", "Sales Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

