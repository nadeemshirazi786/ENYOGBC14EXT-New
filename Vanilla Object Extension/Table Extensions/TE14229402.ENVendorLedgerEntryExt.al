tableextension 14229402 "Vendor Ledger Entry ELA" extends "Vendor Ledger Entry"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Rebate Code ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Caption = 'Rebate Code';
        }
        field(14228801; "Rebate Source Type ELA"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
            Caption = 'Rebate Source Type';
        }
        field(14228802; "Rebate Source No. ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Caption = 'Rebate Source No.';
        }
        field(14228803; "Rebate Source Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Caption = 'Rebate Source Line No.';
        }
        field(14228804; "Rebate Document No. ELA"; Code[20])
        {
            Caption = 'Rebate Document No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228805; "Posted Rebate Entry No. ELA"; Integer)
        {
            Caption = 'Posted Rebate Entry No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228806; "Rebate Accrual Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Vendor No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Vendor;
        }
        field(14228807; "Rebate Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Vendor;
        }
        field(14228808; "Rebate Item No. ELA"; Code[20])
        {
            Caption = 'Rebate Item No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228809; "Rebate Category Code ELA"; Code[20])
        {
            Caption = 'Rebate Category Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228810; "Vendor Rebate Group ELA"; Code[20])
        {
            Caption = 'Vendor Rebate Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228811; "Item Rebate Group ELA"; Code[20])
        {
            Caption = 'Item Rebate Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228812; "Comment ELA"; Text[80])
        {
            Caption = 'Comment';
            DataClassification = ToBeClassified;
            Description = 'EBRE1.00';
        }
    }


}