table 14229107 "EN Extra Charge Vendor Buffer"
{

    Caption = 'Extra Charge Vendor Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(4; Charge; Decimal)
        {
            Caption = 'Charge';
            DataClassification = SystemMetadata;
        }
        field(5; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Currency Code", "Extra Charge Code", "Account No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

