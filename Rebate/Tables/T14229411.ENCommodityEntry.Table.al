table 14229411 "Commodity Entry ELA"
{
    // ENRE1.00 2021-09-08 AJ


    DrillDownPageID = "Commodity Entries ELA";
    LookupPageID = "Commodity Entries ELA";

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
        field(15; "Quantity Posted"; Decimal)
        {
            CalcFormula = Sum("Commodity Ledger ELA".Quantity WHERE("Source Type" = FIELD("Source Type"),
                                                                 "Source No." = FIELD("Source No."),
                                                                 "Source Line No." = FIELD("Source Line No."),
                                                                 "Commodity No." = FIELD("Commodity No.")));
            Caption = 'Quantity Posted';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(21; "Recipient Agency No."; Code[20])
        {
            TableRelation = "Recipient Agency ELA";
        }
        field(30; "Rebate Entry No."; Integer)
        {
            TableRelation = "Rebate Entry ELA"."Entry No.";
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
    }

    fieldgroups
    {
    }
}

