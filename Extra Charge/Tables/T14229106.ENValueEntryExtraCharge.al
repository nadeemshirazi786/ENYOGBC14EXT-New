table 14229106 "EN Value Entry Extra Charge"
{
    Caption = 'Value Entry Extra Charge';

    fields
    {
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
        }
        field(4; Charge; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge';
        }
        field(5; "Charge Posted to G/L"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge Posted to G/L';

        }
        field(6; "Charge (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Charge (ACY)';

        }
        field(7; "Charge Posted to G/L (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Charge Posted to G/L (ACY)';

        }
        field(8; "Expected Charge"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Expected Charge';
        }
        field(9; "Expected Charge Posted to G/L"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Expected Charge Posted to G/L';
        }
        field(10; "Expected Charge (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Expected Charge (ACY)';
        }
        field(11; "Exp. Chg. Posted to G/L (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Exp. Chg. Posted to G/L (ACY)';
        }
        field(12; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(13; "Expected Cost"; Boolean)
        {
            Caption = 'Expected Cost';
        }
        field(14;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Extra Charge Code")
        {
            Clustered = true;
            SumIndexFields = Charge, "Expected Charge", "Charge (ACY)";
        }
        key(Key2; "Item Ledger Entry No.", "Extra Charge Code", "Expected Cost")
        {
            SumIndexFields = "Expected Charge", "Expected Charge (ACY)";
        }
    }

    fieldgroups
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    procedure GetCurrencyCode(): Code[10]
    begin

        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
        exit(GLSetup."Additional Reporting Currency");
    end;
}

