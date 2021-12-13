table 14229412 "Commodity Ledger ELA"
{
    // ENRE1.00 2021-09-08 AJ



    DrillDownPageID = "Commodity Ledger Entries ELA";
    LookupPageID = "Commodity Ledger Entries ELA";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; "Commodity No."; Code[20])
        {
            TableRelation = "Commodity ELA";
        }
        field(10; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(11; "Amount (LCY)"; Decimal)
        {
            DecimalPlaces = 2 : 5;
        }
        field(20; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(21; "Recipient Agency No."; Code[20])
        {
            TableRelation = "Recipient Agency ELA";
        }
        field(30; "Rebate Ledger Entry No."; Integer)
        {
            TableRelation = "Rebate Ledger Entry ELA"."Entry No.";
        }
        field(40; "Functional Area"; Option)
        {
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(50; "Source Type"; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(60; "Source No."; Code[20])
        {

            trigger OnValidate()
            var
                lrecSalesHeader: Record "Sales Header";
                lrecPurchHeader: Record "Purchase Header";
            begin
            end;
        }
        field(70; "Source Line No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
        key(Key2; "Recipient Agency No.", "Vendor No.", "Commodity No.", "Posting Date", "Functional Area", "Source Type", "Source No.", "Source Line No.")
        {
            SumIndexFields = Quantity, "Amount (LCY)";
        }
        key(Key3; "Source Type", "Source No.", "Source Line No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }
}

