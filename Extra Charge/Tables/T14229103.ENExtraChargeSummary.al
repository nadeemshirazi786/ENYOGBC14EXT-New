table 14229103 "EN Extra Charge Summary"
{


    fields
    {
        field(1; "Purchase Order No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Extra Charge Code"; Code[10])
        {
            Editable = false;
            TableRelation = "EN Extra Charge";
        }
        field(3; "Charge Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            Editable = false;
        }
        field(4; "Charge Amount (Actual)"; Decimal)
        {
            AutoFormatType = 1;
            Editable = false;
        }
        field(5; "Charge Amount"; Decimal)
        {
            AutoFormatType = 1;
            Editable = false;
        }
        field(6; "Unposted Invoice Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Purchase Line"."Line Amount" WHERE("Purch. Ord for Ext Charge ELA" = FIELD("Purchase Order No."),
                                                                   "Extra Charge Code ELA" = FIELD("Extra Charge Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Posted Invoice Amount"; Decimal)
        {
            AutoFormatType = 1;
            Editable = false;
        }
        field(8; Open; Boolean)
        {
            Editable = false;
        }
        field(9; "Vendor No."; Code[20])
        {

        }
        field(10; "Vendor Shipment No."; Text[30])
        {

        }
        field(20; "Invoice Date"; Date)
        {

        }
        field(30; "Invoice No."; Code[20])
        {

        }
        field(40; "Posting Date"; Date)
        {

        }
    }

    keys
    {
        key(Key1; "Purchase Order No.", "Extra Charge Code")
        {
            Clustered = true;
        }
        key(Key2; Open, "Extra Charge Code")
        {
        }
        key(Key3; "Purchase Order No.", "Invoice Date")
        {
            SumIndexFields = "Charge Amount (Expected)", "Charge Amount (Actual)";
        }
    }

    fieldgroups
    {
    }
}

