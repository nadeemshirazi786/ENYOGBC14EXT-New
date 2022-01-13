tableextension 14229610 "EN Purchase Header ELA" extends "Purchase Header"
{
    fields
    {
        field(14229400; "Bypass Rebate Calculation ELA"; Boolean)
        {
            Caption = 'Bypass Rebate Calculation';
            Description = 'ENRE1.00';
        }
        field(14229401; "Rebate Amount (LCY) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (LCY)';
            CalcFormula = Sum("Rebate Entry ELA"."Amount (LCY)" WHERE("Functional Area" = CONST(Purchase),
                                                                   "Source Type" = FIELD("Document Type"),
                                                                   "Source No." = FIELD("No."),
                                                                   "Rebate Type" = FIELD("Rebate Type Filter ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229403; "Rebate Amount (RBT) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (RBT)';
            CalcFormula = Sum("Rebate Entry ELA"."Amount (RBT)" WHERE("Functional Area" = CONST(Purchase),
                                                                   "Source Type" = FIELD("Document Type"),
                                                                   "Source No." = FIELD("No."),
                                                                   "Rebate Type" = FIELD("Rebate Type Filter ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229404; "Rebate Amount (DOC) ELA"; Decimal)
        {
            Caption = 'Rebate Amount (DOC)';
            CalcFormula = Sum("Rebate Entry ELA"."Amount (DOC)" WHERE("Functional Area" = CONST(Purchase),
                                                                   "Source Type" = FIELD("Document Type"),
                                                                   "Source No." = FIELD("No."),
                                                                   "Rebate Type" = FIELD("Rebate Type Filter ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14229405; "Rebate Type Filter ELA"; Option)
        {
            Caption = 'Rebate Type Filter';
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum";
        }
        field(14228900; "Supply Chain Group Code ELA"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            DataClassification = ToBeClassified;
        }
        field(14229100; "ExtrChrg crtd for Ord. No. ELA"; Code[20])
        {
            Caption = 'Extr chrg created for Ord. No.';
            DataClassification = ToBeClassified;
        }
        field(51000; "No. Pallets"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
            DataClassification = ToBeClassified;
        }
        field(51002; "Lock Pricing"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51003; "Exp. Delivery Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51004; "Exp. Delivery Appointment Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(14229101; "PO for Extra Charge ELA"; Code[20])
        {
            Caption = 'PO For Extra Charge';
            TableRelation = "Purchase Header"."No.";
        }
        field(14229102; "Communication Group Code ELA"; Code[20])
        {
            Caption = 'Communication Group Code';
            DataClassification = ToBeClassified;
            TableRelation = "Communication Group ELA".Code;
        }
        field(14229103; "Shipping Instructions ELA"; Text[50])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                "Communication Group Code ELA" := Vend."Communication Group Code ELA";
                "Shipping Instructions ELA" := Vend."Shipping Instructions ELA";
            end;
        }
    }
    Keys
    {
        key(Key1; "Exp. Delivery Appointment Date", "Exp. Delivery Appointment Time")
        {

        }
    }
    procedure ShowExtraChargesELA()
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        Extracharges: Page "EN Document Hdr. Extra Charges";
    begin
        //<<ENEC1.00
        TESTFIELD("No.");
        DocExtraCharge.RESET;
        DocExtraCharge.SETRANGE("Table ID", DATABASE::"Purchase Header");
        DocExtraCharge.SETRANGE("Document Type", "Document Type");
        DocExtraCharge.SETRANGE("Document No.", "No.");
        Extracharges.SETTABLEVIEW(DocExtraCharge);
        Extracharges.RUNMODAL;
        //>>ENEC1.00   
    end;

    var
        Vend: Record Vendor;
}