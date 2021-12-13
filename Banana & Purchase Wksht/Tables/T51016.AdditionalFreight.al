table 51016 "Additional Freight"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Order No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Shipping Agent Code"; Code[20])
        {
            TableRelation = "Shipping Agent";
            DataClassification = ToBeClassified;
        }
        field(4; "Freight Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Shipping Agent Code", "Order Date", "Order No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}