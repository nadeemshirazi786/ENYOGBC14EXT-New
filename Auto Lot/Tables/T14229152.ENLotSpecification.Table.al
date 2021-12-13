table 14229152 "EN Lot Specification ELA"
{
    Caption = 'Lot Specification';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(4; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';


            trigger OnValidate()
            var
                DataElement: Record "EN Data Collct. Data Elmnt ELA";
            begin

                TestField("Quality Control Result", false);
                TestField(Value, '');

                LotSpecCategory.Get("Data Element Code");
                Description := LotSpecCategory.Description;
                Type := LotSpecCategory.Type;
                "Certificate of Analysis" := false;
                // P80037645
                if "Data Element Code" <> '' then begin
                    DataElement.Get("Data Element Code");
                    "Unit of Measure Code" := DataElement."Unit of Measure Code";
                    "Measuring Method" := DataElement."Measuring Method";
                end;
                // P80037645
            end;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = "Boolean","Date","Lookup",Numeric,"Text";
        }
        field(6; "Lookup Value"; Code[10])
        {
            Caption = 'Lookup Value';
            Editable = false;
            //TableRelation = IF (Type = CONST ('Lookup')) Table37002021.Field2 WHERE (Field1=FIELD("Data Element Code"));

            trigger OnValidate()
            begin
                // P8000152A
                if "Lookup Value" <> '' then
                    LotSpecLookup.Get("Data Element Code", "Lookup Value");
            end;
        }
        field(8; "Numeric Value"; Decimal)
        {
            Caption = 'Numeric Value';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(9; "Date Value"; Date)
        {
            Caption = 'Date Value';
            Editable = false;
        }
        field(10; Comment; Text[80])
        {
            Caption = 'Comment';
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'PR2.00';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; "Text Value"; Code[50])
        {
            Caption = 'Text Value';
            Editable = false;
        }
        field(13; "Quality Control Result"; Boolean)
        {
            Caption = 'Quality Control Result';
            Editable = false;
        }
        field(14; "Certificate of Analysis"; Boolean)
        {
            Caption = 'Certificate of Analysis';
        }
        field(15; Value; Code[50])
        {
            Caption = 'Value';

            trigger OnValidate()
            var
                DateText: Text[50];
            begin

                TestField("Quality Control Result", false);

                if Value = '' then begin
                    Clear("Boolean Value");
                    Clear("Date Value");
                    Clear("Lookup Value");
                    Clear("Numeric Value");
                    Clear("Text Value");
                end else begin
                    case Type of
                        Type::Boolean:
                            begin
                                if Value = CopyStr(Text000, 1, StrLen(Value)) then begin
                                    Value := Text000;
                                    Validate("Boolean Value", true);
                                end else
                                    if Value = CopyStr(Text003, 1, StrLen(Value)) then begin
                                        Value := Text003;
                                        Validate("Boolean Value", false);
                                    end else
                                        if Value = CopyStr(Text001, 1, StrLen(Value)) then begin
                                            Value := Text000;
                                            Validate("Boolean Value", true);
                                        end else
                                            if Value = CopyStr(Text004, 1, StrLen(Value)) then begin
                                                Value := Text003;
                                                Validate("Boolean Value", false);
                                            end else
                                                Error(Text005);
                            end;

                        Type::Date:
                            if Evaluate("Date Value", Value) then begin
                                Validate("Date Value");
                                Value := Format("Date Value")
                            end else
                                Error(Text007);



                        Type::Text:
                            Validate("Text Value", Value);

                        Type::Numeric:
                            if Evaluate("Numeric Value", Value) then
                                Validate("Numeric Value")
                            else
                                Error(Text006);
                    end;
                end;
            end;
        }
        field(16; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                TestField("Quality Control Result", false);
            end;
        }
        field(17; "Quality Control Test No."; Integer)
        {
            Caption = 'Quality Control Test No.';
            Editable = false;
        }
        field(18; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            Editable = false;
        }
        field(119; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(122; "Measuring Method"; Text[50])
        {
            Caption = 'Measuring Method';
            Editable = false;
        }
        field(123; "Threshold on COA"; Boolean)
        {
            Caption = 'Threshold on COA';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Data Element Code")
        {
            Clustered = true;
        }
        key(Key2; "Data Element Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField("Quality Control Result", false);
    end;

    var
        Text000: Label 'YES';
        Text001: Label 'TRUE';
        Text003: Label 'NO';
        Text004: Label 'FALSE';
        Text005: Label 'Result must be YES or NO.';
        Text006: Label 'Result must be numeric.';
        Text007: Label 'Result must be a date.';
        LotSpecCategory: Record "EN Data Collct. Data Elmnt ELA";
        LotSpecLookup: Record "EN Data Collection Lookup ELA";
}

