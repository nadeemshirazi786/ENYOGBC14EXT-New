tableextension 14229407 "Detailed CV Led Entry Buf ELA" extends "Detailed CV Ledg. Entry Buffer"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Rebate Code ELA"; Code[20])
        {
            Caption = 'Rebate Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228801; "Rebate Source Type ELA"; Option)
        {
            Caption = 'Rebate Source Type';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(14228802; "Rebate Source No. ELA"; Code[20])
        {
            Caption = 'Rebate Source No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228803; "Rebate Source Line No. ELA"; Integer)
        {
            Caption = 'Rebate Source Line No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
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
        field(14228806; "Rbt Accrual Customer No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Customer No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228807; "Rebate Customer No. ELA"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
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
        field(14228810; "Customer Rebate Group ELA"; Code[20])
        {
            Caption = 'Customer Rebate Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228811; "Item Rebate Group ELA"; Code[20])
        {
            Caption = 'Item Rebate Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228812; "Rebate Accrual Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Vendor No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228813; "Rebate Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                lrecVend: Record Vendor;
            begin
            end;
        }
        field(14228814; "Vendor Rebate Group ELA"; Code[20])
        {
            Caption = 'Vendor Rebate Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }

    }

    var
        myInt: Integer;
}