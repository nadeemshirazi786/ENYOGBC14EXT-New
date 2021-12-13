table 14229423 "Property ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00 - Label Item Property
    //           - Added fields:
    //              * 70            "Display In Lot Tracking"                Boolean
    //            - Added code on validate that if Checked On (TRUE) that it checks to make sure it is
    //              not set on any other Property  (only 1 property is allowed tyo be set)
    // 
    // ENRE1.00
    //   
    //     rem (deprecated) ILE property fields

    LookupPageID = "Properties ELA"; //Properties

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Value Type"; Option)
        {
            OptionCaption = 'Boolean,Code,Text,Decimal,Time,Date,Percent';
            OptionMembers = Boolean,"Code",Text,Decimal,Time,Date,Percent;

            trigger OnValidate()
            begin
                if ("Value Type" = "Value Type"::Decimal) or
                   ("Value Type" = "Value Type"::Percent) then
                    "Decimal Rounding Precision" := 0.00001
                else
                    "Decimal Rounding Precision" := 0;
            end;
        }
        field(8; "Property Group Code"; Code[10])
        {
            TableRelation = "Property Group ELA";
        }
        field(30; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(41; "Default Property Value"; Boolean)
        {
        }
        field(50; "Decimal Rounding Precision"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            InitValue = 0.00001;
            MinValue = 0;
        }
        field(55; "Rounding Method Code"; Code[10])
        {
            TableRelation = "Rounding Method".Code;
        }
        field(70; "Display In Lot Tracking"; Boolean)
        {
            Caption = 'Display In Lot Tracking';
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                lrecProperty: Record "Property ELA";
                lconText001: Label 'Display In Lot Tracking can only exist on one Property.';
            begin
                //<ENRE1.00>
                if xRec."Display In Lot Tracking" <> Rec."Display In Lot Tracking" then begin
                    if "Display In Lot Tracking" = true then begin
                        lrecProperty.Reset;
                        lrecProperty.SetFilter(Code, '<>%1', Code);
                        lrecProperty.SetRange("Display In Lot Tracking", true);
                        if lrecProperty.FindFirst then begin
                            Error(lconText001);
                        end;
                    end;
                end;
                //</ENRE1.00>
            end;
        }
        field(23019000; "Value Posting"; Option)
        {
            Caption = 'Value Posting';
            Description = 'ENRE1.00';
            OptionCaption = ' ,Code Mandatory,Same Code,No Code';
            OptionMembers = " ","Code Mandatory","Same Code","No Code";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

