tableextension 14229651 "Purchase Price ELA" extends "Purchase Price"
{
    fields
    {
        field(14229600; "Purchase Type ELA"; Option)
        {
            Caption = 'Purchase Type';
            OptionMembers = "Vendor","Vendor Price Group","All Vendors";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF "Purchase Type ELA" <> xRec."Purchase Type ELA" THEN BEGIN
                    VALIDATE("Vendor No.", '');
                    VALIDATE("Order Address Code ELA", '');
                END;
            end;
        }
        field(14229601; "Location Code ELA"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }
        field(14229652; "Order Address Code ELA"; Code[10])
        {
            Caption = 'Order Address Code';
            TableRelation = IF ("Purchase Type ELA" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("Vendor No."));
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF "Order Address Code ELA" <> '' THEN BEGIN
                    TESTFIELD("Purchase Type ELA", "Purchase Type ELA"::Vendor);
                END;
            end;
        }
    }
    keys
    {
        key(Key1; "Purchase Type ELA", "Location Code ELA")
        {
        }
    }
    var
        myInt: Integer;
}