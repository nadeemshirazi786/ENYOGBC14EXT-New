table 14229150 "EN Data Collct. Data Elmnt ELA"
{
    Caption = 'Data Collection Data Element';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Type"; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Boolean,Date,Lookup,Numeric,Text';
            OptionMembers = "Boolean","Date","Lookup","Numeric","Text";

            trigger OnValidate()
            begin

                if Type <> xRec.Type then
                    "Averaging Method" := "Averaging Method"::" ";

            end;
        }
        field(4; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(5; "Create Separate Lines"; Boolean)
        {
            Caption = 'Create Separate Lines';
        }
        field(119; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(122; "Measuring Method"; Text[50])
        {
            Caption = 'Measuring Method';
        }
        field(123; "Averaging Method"; Option)
        {
            Caption = 'Averaging Method';
            OptionCaption = ' ,First,Last,,,,,,Arithmetic,Geometric,Harmonic';
            OptionMembers = " ",First,Last,,,,,,Arithmetic,Geometric,Harmonic;

            trigger OnValidate()
            begin

                if "Averaging Method" in ["Averaging Method"::Arithmetic, "Averaging Method"::Geometric, "Averaging Method"::Harmonic] then
                    TestField(Type, Type::Numeric);

            end;
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

    trigger OnDelete()
    begin

        DataCollectionLine.SetCurrentKey("Data Element Code");
        DataCollectionLine.SetRange("Data Element Code", Code);
        if not DataCollectionLine.IsEmpty then
            Error(Text000, TableCaption, Code, DataCollectionLine.TableCaption);

        LotSpec.SetCurrentKey("Data Element Code");
        LotSpec.SetRange("Data Element Code", Code);
        if LotSpec.Find('-') then
            Error(Text000, TableCaption, Code, LotSpec.TableCaption);

        LotSpecLookup.SetRange("Data Element Code", Code);
        LotSpecLookup.DeleteAll;
        LotSpecFilter.SetCurrentKey("Data Element Code");
        LotSpecFilter.SetRange("Data Element Code", Code);
        LotSpecFilter.DeleteAll;

        InvSetup.Get;

    end;

    var
        LotSpec: Record "EN Lot Specification ELA";
        DataCollectionLine: Record "EN Data Collection Line ELA";
        LotSpecLookup: Record "EN Data Collection Lookup ELA";
        Text000: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this code.';
        LotSpecFilter: Record "EN Lot Specf. Filter ELA";
        InvSetup: Record "Inventory Setup";
}

