tableextension 14229617 "EN Purch. Inv. Line ELA" extends "Purch. Inv. Line"
{
    fields
    {
        field(14229400; "Line Net Weight ELA"; Decimal)
        {
            Caption = 'Line Net Weight';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
        }
        field(14229100; "Extra Charge Code ELA"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = ToBeClassified;
        }
        field(14229101; "Purch. Ord for Extra Chrg ELA"; Code[20])
        {
            Caption = 'Purch. Order for Extra Charge';
            DataClassification = ToBeClassified;
        }
        field(14229001; "List Cost ELA"; Decimal)
        {
            Caption = 'List Cost';
        }
        field(14229002; "Upcharge Amount ELA"; Decimal)
        {
            Caption = 'Upcharge Amount';
        }
        field(14229003; "Billback Amount ELA"; Decimal)
        {
            Caption = 'Billback Amount';
        }
        field(14229004; "Discount 1 Amount ELA"; Decimal)
        {

        }
        field(14229005; "Freight Amount ELA"; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = ToBeClassified;

        }

    }

    procedure ShowExtraChargesELA()
    var
        PostedExtraCharge: Record "EN Posted Doc. Extra Charges";
        PostedExtraCharges: Page "EN Pstd.Doc Hdr. Extra Charges";
    begin
        //ENEC1.00
        TESTFIELD("No.");
        TESTFIELD("Line No.");
        TESTFIELD(Type, Type::Item);
        PostedExtraCharge.SETRANGE("Table ID", DATABASE::"Purch. Inv. Line");
        PostedExtraCharge.SETRANGE("Document No.", "Document No.");
        PostedExtraCharge.SETRANGE("Line No.", "Line No.");
        PostedExtraCharges.SETTABLEVIEW(PostedExtraCharge);
        PostedExtraCharges.RUNMODAL;
        //ENEC1.00
    end;
}