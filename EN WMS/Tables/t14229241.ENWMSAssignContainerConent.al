table 14229241 "WMS Asgn Container Content ELA"
{
    Caption = 'WMS Assign Container Conent';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "WMS Sales Document Type ELA")
        {
            DataClassification = ToBeClassified;
        }


        field(2; "Document No."; Code[20])
        {
        }

        field(3; "Line No."; Integer)
        {
        }

        field(14; "Location Code"; code[20])
        {
            TableRelation = Location;
        }

        field(4; "Item No."; code[20])
        {
            TableRelation = Item;
        }

        field(5; Description; text[50])
        {
        }

        field(6; "Document Qty."; Decimal)
        {
            Caption = 'Document Qty.';
        }

        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }

        field(8; "Qty. Outstanding"; Decimal)
        {
            Caption = 'Qty. Outstanding';
        }

        field(10; "Qty. To Handle"; Decimal)
        {
            Caption = 'Qty. To Handle';
        }

        field(11; "Qty. Per Container"; Decimal)
        {
            Caption = 'Qty. Per Container';
        }
        field(12; "Total Containers"; Decimal)
        {
            Caption = 'Total Containers';
        }

        field(13; "Qty. Remaining"; Decimal)
        {
        }

        field(20; "Vendor Lot No."; code[20])
        {

        }
        field(21; "Vendor Item No."; code[20])
        {
        }


        field(31; "Activity No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(32; "Activity Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

}
