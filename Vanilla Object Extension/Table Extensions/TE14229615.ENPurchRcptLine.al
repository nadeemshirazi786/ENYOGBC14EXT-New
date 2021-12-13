tableextension 14229615 "EN Purch. Rcpt. Line ELA" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(14229400; "Line Net Weight ELA"; Decimal)
        {
            Caption = 'Line Net Weight';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14229100; "Extra Charge Code ELA"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = ToBeClassified;
        }
        field(14229103; "Pallet Count ELA"; Decimal)
        {
            Caption = 'Pallet Count';
            DataClassification = ToBeClassified;
        }

    }

    procedure ShowExtraChargesELA()
    var
        PostedExtraCharge: Record "EN Posted Doc. Extra Charges";
        PostedExtraCharges: Page "EN Pstd.Doc Hdr. Extra Charges";
    begin
        //<<ENEC1.00
        TESTFIELD("No.");
        TESTFIELD("Line No.");
        TESTFIELD(Type, Type::Item);
        PostedExtraCharge.SETRANGE("Table ID", DATABASE::"Purch. Rcpt. Line");
        PostedExtraCharge.SETRANGE("Document No.", "Document No.");
        PostedExtraCharge.SETRANGE("Line No.", "Line No.");
        PostedExtraCharges.SETTABLEVIEW(PostedExtraCharge);
        PostedExtraCharges.RUNMODAL;
        //>>ENEC1.00
    end;
}