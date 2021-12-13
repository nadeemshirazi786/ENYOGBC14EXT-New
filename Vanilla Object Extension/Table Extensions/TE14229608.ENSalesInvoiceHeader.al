tableextension 14229608 "Sales Invoice Header Ext ELA" extends "Sales Invoice Header"
{
    fields
    {
        field(14229420; "Bypass Rebate Calculation ELA"; Boolean)
        {
            Caption = 'Bypass Rebate Calculation';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228850; "Price List Group Code ELA"; Code[20])
        {
            Caption = 'Price List Group Code';
            TableRelation = "EN Price List Group";
            DataClassification = ToBeClassified;

        }
        field(14228851; "Pallet Code ELA"; Code[10])
        {
            //TableRelation = "EN Container Type";
            Caption = 'Pallet Code';
        }
        field(14228852; "Bypass Surcharge Calc ELA"; Boolean)
        {
            Caption = 'Bypass Surcharge Calculation';

        }
        field(14228853; "Lock Pricing ELA"; Boolean)
        {
            Caption = 'Lock Pricing';
        }
        field(14228854; "Order Rule Group ELA"; Code[20])
        {
            TableRelation = "EN Order Rule Group";
            Caption = 'Order Rule Group';
        }
        field(14228855; "Bypass Order Rules ELA"; Boolean)
        {
            Caption = 'Bypass Order Rules';

        }
        field(14228880; "Source Type ELA"; Integer)
        {
            Caption = 'Source Type';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(14228881; "Source Subtype ELA"; Enum "EN Source Subtype")
        {
            Caption = 'Source Subtype';

        }
        field(14228882; "Source ID ELA"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(14228883; "Authorized Amount ELA"; Decimal)
        {
            Caption = 'Authorized Amount';

        }
        field(14228884; "Authorized User ELA"; Code[20])
        {
            Caption = 'Authorized User';
        }

        field(14228885; "Cash vs Amount Incld Tax ELA"; Decimal)
        {
            Caption = 'Cash vs Amount Including Tax';
        }
        field(14228886; "Created By ELA"; Code[50])
        {
            Caption = 'Created By';
        }
        field(14228887; "Cash Applied (Other) ELA"; Decimal)
        {
            Caption = 'Cash Applied (Other)';
        }
        field(14228888; "Cash Applied (Current) ELA"; Decimal)
        {
            Caption = 'Cash Applied (Current)';
        }
        field(14228889; "Cash Tendered ELA"; Decimal)
        {
            Caption = 'Cash Tendered';
        }
        field(14228890; "Entered Amount to Apply ELA"; Decimal)
        {
            Caption = 'Entered Amount to Apply';
            Editable = true;
        }
        field(14228891; "Change Due ELA"; Decimal)
        {
            Caption = 'Change Due';
        }
        field(14228892; "Stop Arrival Time ELA"; Time)
        {
            Caption = 'Stop Arrival Time';

        }
        field(14228893; "Non-Commissionable ELA"; Boolean)
        {
            Caption = 'Non-Commissionable';

        }
        field(14228894; "Approved By ELA"; Code[50])
        {
            Caption = 'Approved By';
            Editable = false;
        }
        field(14228895; "Approval Status ELA"; Enum "EN Approved Status")
        {
            Caption = 'Approval Status';
            Editable = false;

        }
        field(14228896; "Cash & Carry ELA"; Boolean)
        {
            Caption = 'Cash & Carry';
            DataClassification = ToBeClassified;
        }
        field(14228897; "Order Template Location ELA"; Code[10])
        {
            Caption = 'Order Template Location';
            DataClassification = ToBeClassified;
        }
    }

}