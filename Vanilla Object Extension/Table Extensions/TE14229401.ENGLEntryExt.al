tableextension 14229401 "GL Entry ELA" extends "G/L Entry"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Rebate Code ELA"; Code[20])
        {
            Caption = 'Rebate Code';

            DataClassification = ToBeClassified;
        }
        field(14228801; "Rebate Source Type ELA"; Option)
        {
            Caption = 'Rebate Source Type';

            DataClassification = ToBeClassified;
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(14228802; "Rebate Source No. ELA"; Code[20])
        {
            Caption = 'Rebate Source No.';

            DataClassification = ToBeClassified;
        }
        field(14228803; "Rebate Source Line No. ELA"; Integer)
        {



            DataClassification = ToBeClassified;
            Caption = 'Rebate Source Line No.';
        }
        field(14228804; "Rebate Document No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Document No.';
        }
        field(14228805; "Posted Rebate Entry No. ELA"; Integer)
        {


            DataClassification = ToBeClassified;
            Caption = 'Posted Rebate Entry No.';
        }
        field(14228806; "Rbt Accrual Customer No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Accrual Customer No.';
        }
        field(14228807; "Rebate Customer No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Customer No.';
        }
        field(14228808; "Rebate Item No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Item No.';
        }
        field(14228809; "Rebate Category Code ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Category Code';
        }
        field(14228810; "Customer Rebate Group ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Customer Rebate Group';
        }
        field(14228811; "Item Rebate Group ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Item Rebate Group';
        }
        field(14228812; "Rebate Accrual Vendor No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Accrual Vendor No.';
        }
        field(14228813; "Rebate Vendor No. ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Rebate Vendor No.';
        }
        field(14228814; "Vendor Rebate Group ELA"; Code[20])
        {


            DataClassification = ToBeClassified;
            Caption = 'Vendor Rebate Group';
        }

    }

    var
        myInt: Integer;
}