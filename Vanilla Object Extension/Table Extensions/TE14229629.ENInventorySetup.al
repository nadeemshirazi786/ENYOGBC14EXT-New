tableextension 14229629 "EN Inventory Setup ELA" extends "Inventory Setup"
{
    fields
    {
        field(14229400; "Standard Weight UOM ELA"; Code[10])
        {
            caption = 'Standard Weight UOM';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Unit of Measure" WHERE("UOM Group Code ELA" = FIELD("Weight UOM Group ELA"));
        }
        field(14229401; "Weight UOM Group ELA"; Code[10])
        {
            Caption = 'Weight UOM Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Unit of Measure Group ELA";
        }
        field(14228850; "Item UOM Round Precision ELA"; Decimal)
        {
            Caption = 'Item UOM Rounding Precision';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 15;
        }
        field(14229120; "Repack Order Nos. ELA"; Code[20])
        {
            Caption = 'Repack Order Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14229121; "Default Repack Location ELA"; Code[10])
        {
            Caption = 'Default Repack Location';
            DataClassification = ToBeClassified;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
            trigger OnValidate()
            var
                Location: Record Location;
            begin
                IF "Default Repack Location ELA" <> '' THEN BEGIN
                    Location.GET("Default Repack Location ELA");
                    Location.TESTFIELD("Bin Mandatory", FALSE);
                END;
            end;
        }
        field(14229150; "Lot Pref. Enforcmnt Level ELA"; Option)
        {
            Caption = 'Lot Pref. Enforcement Level';
            DataClassification = ToBeClassified;
            OptionMembers = Warning,Error;

        }
        field(142291551; "Chg. Lot Status Doc Nos. ELA"; Code[20])
        {
            Caption = 'Chg. Lot Status Document Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14229152; "Quarantine Lot Status ELA"; Code[20])
        {
            Caption = 'Quarantine Lot Status';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                VALIDATE("Quality Control Lot Status ELA");
                VALIDATE("Sales Lot Status ELA");
                VALIDATE("Purchase Lot Status ELA");
                VALIDATE("Output Lot Status ELA");
                VALIDATE("Qlt. Ctrl. Fail Lot Status ELA");
            end;

        }
        field(14229153; "Quality Control Lot Status ELA"; code[20])
        {
            Caption = 'Quality Control Lot Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF ("Quarantine Lot Status ELA" <> '') AND ("Quality Control Lot Status ELA" = "Quarantine Lot Status ELA") THEN
                    FIELDERROR("Quality Control Lot Status ELA", STRSUBSTNO(Text37002001, "Quarantine Lot Status ELA"));
            end;
        }
        field(14229154; "Sales Lot Status ELA"; Code[20])
        {
            Caption = 'Sales Lot Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF ("Quarantine Lot Status ELA" <> '') AND ("Sales Lot Status ELA" = "Quarantine Lot Status ELA") THEN
                    FIELDERROR("Sales Lot Status ELA", STRSUBSTNO(Text37002001, "Quarantine Lot Status ELA"));
            end;
        }
        field(14229155; "Purchase Lot Status ELA"; Code[20])
        {
            Caption = 'Purchase Lot Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF ("Quarantine Lot Status ELA" <> '') AND ("Purchase Lot Status ELA" = "Quarantine Lot Status ELA") THEN
                    FIELDERROR("Purchase Lot Status ELA", STRSUBSTNO(Text37002001, "Quarantine Lot Status ELA"));
            end;
        }
        field(14229156; "Output Lot Status ELA"; Code[20])
        {
            Caption = 'Output Lot Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF ("Quarantine Lot Status ELA" <> '') AND ("Output Lot Status ELA" = "Quarantine Lot Status ELA") THEN
                    FIELDERROR("Output Lot Status ELA", STRSUBSTNO(Text37002001, "Quarantine Lot Status ELA"));
            end;
        }
        field(14229157; "Qlt. Ctrl. Fail Lot Status ELA"; Code[20])
        {
            Caption = 'Quality Ctrl. Fail Lot Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                IF ("Quarantine Lot Status ELA" <> '') AND ("Qlt. Ctrl. Fail Lot Status ELA" = "Quarantine Lot Status ELA") THEN
                    FIELDERROR("Qlt. Ctrl. Fail Lot Status ELA", STRSUBSTNO(Text37002001, "Quarantine Lot Status ELA"));
            end;
        }
        field(14229158; "Def. Price Rounding Method ELA"; code[20])
        {
            Caption = 'Def. Price Rounding Method';
            DataClassification = ToBeClassified;
            TableRelation = "Rounding Method";
        }
        field(14229159; "Price Selection Priority ELA"; Option)
        {
            Caption = 'Price Selection Priority';
            DataClassification = ToBeClassified;
            OptionMembers = None,"Currency Only","UOM Only","Currency/UOM","UOM/Currency/Variant","Variant/UOM/Currency";
        }
        field(51000; "Copy to Sales Documents"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Copy to Purchase Documents"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51002; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51003; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51004; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51005; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51006; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(14229160; "Hide Items on Lookup ELA"; Option)
        {
            Caption = 'Hide Items on Lookup';
            OptionMembers = "None","Blocked and Closed","Blocked Only","Closed Only";
        }
    }



    var
        myInt: Integer;
        Text37002001: TextConst ENU = 'cannot be %1';

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