table 14229407 "Category Default Property ELA"
{

    // ENRE1.00
    //    - modified function jmdoValidateValue, decimal values would not convert
    // 
    // ENRE1.00
    //   
    //     rem (deprecated) ILE property fields

    LookupPageID = "Category Def. Properties ELA"; //Category Default Properties

    fields
    {
        field(1; "Category Code"; Code[20])
        {
            TableRelation = "Item Category";
        }
        field(2; "Line No."; Integer)
        {
        }
        field(8; "Property Group Code"; Code[10])
        {
            TableRelation = "Property Group ELA";
        }
        field(9; "Property Code"; Code[20])
        {
            TableRelation = "Property ELA";

            trigger OnValidate()
            begin
                if grecProperties.Get("Property Code") then begin
                    Validate("Property Group Code", grecProperties."Property Group Code");
                    Validate("Value Type", grecProperties."Value Type");
                    //<ENRE1.00> - deleted code
                    Validate("Default Property Value", grecProperties."Default Property Value");
                    //<ENRE1.00> - deleted code
                    "Unit of Measure Code" := grecProperties."Unit of Measure Code";
                end;
            end;
        }
        field(10; "Value Type"; Option)
        {
            OptionCaption = 'Boolean,Code,Text,Decimal,Time,Date,Percent';
            OptionMembers = Boolean,"Code",Text,Decimal,Time,Date,Percent;

            trigger OnValidate()
            begin
                if "Value Type" <> xRec."Value Type" then begin
                    "Code Value" := '';
                    "Text Value" := '';
                    "Decimal Value" := 0;
                    "Time Value" := 0T;
                    "Date Value" := 0D;
                    "Boolean Value" := false;
                end;
            end;
        }
        field(11; "Code Value"; Code[30])
        {
            TableRelation = "Code Property Value ELA"."Code" WHERE("Property Code" = FIELD("Property Code"));
        }
        field(12; "Text Value"; Text[50])
        {
        }
        field(13; "Decimal Value"; Decimal)
        {
        }
        field(14; "Time Value"; Time)
        {
        }
        field(15; "Date Value"; Date)
        {
        }
        field(16; "Boolean Value"; Boolean)
        {
        }
        field(20; "Decimal Min"; Decimal)
        {
        }
        field(21; "Decimal Max"; Decimal)
        {
        }
        field(30; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(41; "Default Property Value"; Boolean)
        {
        }
        field(43; "Required Nutirient Information"; Boolean)
        {
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
        key(Key1; "Category Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        jmdoCheckDuplicateProperty;
    end;

    var
        JMText001: Label 'Item Category Property %1 already exists for Category %2.';
        grecProperties: Record "Property ELA";
        JMText002: Label 'Turning on Item Ledger Property Tracking will cause the system to always track this property to the item ledger regardless of conformance.';
        JMText003: Label 'Turning off Item Ledger Property Tracking will only affect the property if it is within the Customer / Item specification.  All non-conformances of this property will still be tracked.';


    procedure jmdoCheckDuplicateProperty()
    var
        lrecCategoryProp: Record "Category Default Property ELA";
    begin
        lrecCategoryProp.SetRange("Category Code", "Category Code");
        lrecCategoryProp.SetRange("Property Code", "Property Code");
        if lrecCategoryProp.Find('-') then
            Error(JMText001, "Property Code", "Category Code");
    end;


    procedure jmdoValidateValue(var lvarValue: Variant)
    var
        ltxtValue: Text[250];
        lrecProperty: Record "Property ELA";
        TextManagement: Codeunit TextManagement;
    begin

        case "Value Type" of
            "Value Type"::Boolean:
                begin
                    ltxtValue := lvarValue;
                    if ltxtValue = '' then
                        ltxtValue := 'No';
                    Evaluate("Boolean Value", ltxtValue);
                    Validate("Boolean Value");
                end;
            "Value Type"::Code:
                begin
                    "Code Value" := lvarValue;
                    Validate("Code Value");
                end;
            "Value Type"::Text:
                begin
                    "Text Value" := lvarValue;
                    Validate("Text Value");
                end;
            "Value Type"::Decimal,
            "Value Type"::Percent:
                begin
                    lrecProperty.Get("Property Code");
                    if lrecProperty."Decimal Rounding Precision" = 0 then
                        lrecProperty."Decimal Rounding Precision" := 0.00001;
                    //<ENRE1.00>
                    ltxtValue := lvarValue;
                    Evaluate("Decimal Value", ltxtValue);
                    //</ENRE1.00>
                    Validate("Decimal Value", Round("Decimal Value", lrecProperty."Decimal Rounding Precision"));
                end;
            "Value Type"::Time:
                begin
                    ltxtValue := Format(lvarValue);
                    TextManagement.MakeTimeText(ltxtValue);
                    "Time Value" := lvarValue;
                    Validate("Time Value");
                end;
            "Value Type"::Date:
                begin
                    ltxtValue := Format(lvarValue);
                    TextManagement.MakeDateText(ltxtValue);
                    Evaluate("Date Value", ltxtValue);
                    Validate("Date Value");
                end;
        end;
    end;
}

