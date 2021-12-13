tableextension 14229616 "EN Purch. Inv. Header ELA" extends "Purch. Inv. Header"
{
    fields
    {
        field(14229400; "Bypass Rebate Calculation"; Boolean)
        {
            Caption = 'Bypass Rebate Calculation';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229401; "Rebate Amount (LCY) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (LCY)';
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Functional Area" = CONST(Purchase),
                                                                          "Source Type" = CONST("Posted Invoice"),
                                                                          "Source No." = FIELD("No."),
                                                                          "Rebate Type" = FIELD("Rebate Type Filter ELA"),
                                                                          "Posted To G/L" = FIELD("Rbt Posted To G/L Filter ELA"),
                                                                          "Paid-by Vendor" = FIELD("Rebate Posted To Vend. LE ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229402; "Rebate Amount (RBT) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (RBT)';
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (RBT)" WHERE("Functional Area" = CONST(Purchase),
                                                                          "Source Type" = CONST("Posted Invoice"),
                                                                          "Source No." = FIELD("No."),
                                                                          "Rebate Type" = FIELD("Rebate Type Filter ELA"),
                                                                          "Posted To G/L" = FIELD("Rbt Posted To G/L Filter ELA"),
                                                                          "Paid-by Vendor" = FIELD("Rebate Posted To Vend. LE ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229403; "Rebate Amount (DOC) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (DOC)';
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (DOC)" WHERE("Functional Area" = CONST(Purchase),
                                                                          "Source Type" = CONST("Posted Invoice"),
                                                                          "Source No." = FIELD("No."),
                                                                          "Rebate Type" = FIELD("Rebate Type Filter ELA"),
                                                                          "Posted To G/L" = FIELD("Rbt Posted To G/L Filter ELA"),
                                                                          "Paid-by Vendor" = FIELD("Rebate Posted To Vend. LE ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229404; "Rebate Type Filter ELA"; Option)
        {
            Caption = 'Rebate Type Filter';
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum";
        }
        field(14229405; "Rbt Posted To G/L Filter ELA"; Boolean)
        {

            Caption = 'Rebate Posted To G/L Filter';
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
        }
        field(14229406; "Rebate Posted To Vend. LE ELA"; Boolean)
        {
            Caption = 'Rebate Posted To Vend. LE';

            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
        }
        field(14229100; "ExtrChrg crtd for Rcpt No. ELA"; Code[20])
        {
            Caption = 'Extr chrg created for Rcpt No.';
            DataClassification = ToBeClassified;
        }
    }


}