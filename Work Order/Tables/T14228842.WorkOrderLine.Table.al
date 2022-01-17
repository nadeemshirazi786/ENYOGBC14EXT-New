table 14228842 "Work Order Line"
{
    DrillDownPageID = 23019741;
    LookupPageID = 23019741;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = "Work Order Header"."PM Work Order No.";
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = Table23019250.Field2 WHERE (Field1 = FIELD ("PM Procedure Code"));
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; "PM Procedure Code"; Code[20])
        {
            TableRelation = Table23019250.Field1;
        }
        field(5; "PM Measure Code"; Code[20])
        {
            TableRelation = Table23019255.Field1;

            trigger OnValidate()
            begin
                //Need to get PM Measure and default the QM Value Type
                if grecQM.GET("PM Measure Code") then begin
                    Validate("Value Type", grecQM."Value Type");
                    Validate("PM Unit of Measure", grecQM."Default Unit of Measure Code");
                    Validate(Description, grecQM.Description);
                end;
            end;
        }
        field(6; "PM Unit of Measure"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(7; "Critical Control Point"; Boolean)
        {
        }
        field(8; Description; Text[80])
        {
        }
        field(9; "PM Step Code"; Code[10])
        {
            TableRelation = Table23019288;
        }
        field(10; "Value Type"; Option)
        {
            OptionCaption = 'Boolean,Code,Text,Decimal,Date,Time';
            OptionMembers = Boolean,"Code",Text,Decimal,Date,Time;

            trigger OnValidate()
            begin
                if "Value Type" <> xRec."Value Type" then begin
                    "Code Value" := '';
                    "Text Value" := '';
                    "Decimal Value" := 0;
                    "Date Value" := 0D;
                    "Boolean Value" := false;
                end;
            end;
        }
        field(11; "Code Value"; Code[30])
        {
        }
        field(12; "Text Value"; Text[50])
        {
        }
        field(13; "Decimal Value"; Decimal)
        {
            DecimalPlaces = 0 : 10;

            trigger OnValidate()
            begin
                "Decimal Value" := Round("Decimal Value", "Decimal Rounding Precision");

                if ("Decimal Min" <> 0) or ("Decimal Max" <> 0) then begin
                    if ("Decimal Value" >= "Decimal Min") and ("Decimal Value" <= "Decimal Max") then
                        Result := Result::Pass
                    else
                        Result := Result::Fail;
                    Validate(Result);
                end else begin

                end;
            end;
        }
        field(14; "Date Value"; Date)
        {
        }
        field(15; "Boolean Value"; Boolean)
        {

            trigger OnValidate()
            begin
                Clear(gvarDesiredValue);
                jfdoGetDesiredValue(gvarDesiredValue);

                if Format(gvarDesiredValue) <> '' then begin
                    if Format("Boolean Value") = Format(gvarDesiredValue) then
                        Result := Result::Pass
                    else
                        Result := Result::Fail;
                    Validate(Result);
                end;
            end;
        }
        field(16; "Time Value"; Time)
        {
        }
        field(20; "Decimal Min"; Decimal)
        {
            DecimalPlaces = 0 : 10;
        }
        field(21; "Decimal Max"; Decimal)
        {
            DecimalPlaces = 0 : 10;
        }
        field(22; "Decimal Rounding Precision"; Decimal)
        {
            DecimalPlaces = 0 : 10;
            InitValue = 0.00001;
            MinValue = 0.0000000001;
        }
        field(25; "No. Results"; Integer)
        {
            InitValue = 1;
        }
        field(26; "Result Calc. Type"; Option)
        {
            OptionCaption = 'Mean,Median,Mode';
            OptionMembers = Mean,Median,Mode;

            trigger OnValidate()
            begin
                if ("Value Type" = "Value Type"::Decimal) and ("No. Results" > 1) then begin
                    Validate("Decimal Value", grecPMWOResultLine.jfdoPMWOResultsLookup(Rec, false));
                end;
            end;
        }
        field(30; "Qualification Code"; Code[10])
        {
            Description = 'Related to Qualifications in HR';
            TableRelation = Qualification;
        }
        field(32; "Employee No."; Code[20])
        {
            Description = 'Specific Employee';
            TableRelation = Employee;
        }
        field(33; "PM Measure Cost"; Decimal)
        {
            DecimalPlaces = 2 : 5;
        }
        field(50; "PMWO Item Consumption"; Boolean)
        {
            CalcFormula = Exist (Table23019262 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "PMWO Resources"; Boolean)
        {
            CalcFormula = Exist (Table23019263 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "PMWO Comments"; Boolean)
        {
            CalcFormula = Exist (Table23019264 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "PM Fault Possibilities"; Boolean)
        {
            CalcFormula = Exist (Table23019259 WHERE (Field1 = FIELD ("PM Procedure Code"),
                                                     Field2 = FIELD ("PM Proc. Version No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; Result; Option)
        {
            OptionCaption = '?,Pass,Fail';
            OptionMembers = "?",Pass,Fail;

            trigger OnValidate()
            begin
                TestField("Test Complete", false);
                if Result = Result::Pass then
                    Validate("Test Complete", true);
            end;
        }
        field(101; "Test Complete"; Boolean)
        {

            trigger OnValidate()
            begin
                if "Test Complete" then
                    if Result = Result::"?" then
                        FieldError(Result);
            end;
        }
        field(102; "PM Work Order Faults"; Boolean)
        {
            CalcFormula = Exist (Table23019265 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "PM Measure Cost";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteRelations;

        if HasLinks then
            DeleteLinks;
    end;

    var
        grecQM: Record Table23019255;
        grecPMWOResultLine: Record Table23019266;
        gvarDesiredValue: Variant;

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecPMWOItemCons: Record Table23019262;
        lrecPMWOResource: Record Table23019263;
        lrecPMWOComments: Record Table23019264;
        lrecPMWOFault: Record Table23019265;
        lrecPMWOLineResults: Record Table23019266;
    begin
        //Delete Related Records

        lrecPMWOItemCons.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOItemCons.SETRANGE("PM WO Line No.", "Line No.");
        lrecPMWOItemCons.DELETEALL(true);

        lrecPMWOResource.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOResource.SETRANGE("PM WO Line No.", "Line No.");
        lrecPMWOResource.DELETEALL(true);

        lrecPMWOComments.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOComments.SETRANGE("PM WO Line No.", "Line No.");
        lrecPMWOComments.DELETEALL;

        lrecPMWOFault.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOFault.SETRANGE("PM WO Line No.", "Line No.");
        lrecPMWOFault.DELETEALL;

        lrecPMWOLineResults.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOLineResults.SETRANGE("PM WO Line No.", "Line No.");
        lrecPMWOLineResults.DELETEALL;
    end;

    [Scope('Internal')]
    procedure jmdoValidateValue(var lvarValue: Variant)
    var
        ltxtValue: Text[250];
        lrecPMMeasure: Record Table23019255;
        lcduApplMgt: Codeunit Codeunit1;
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
            "Value Type"::Decimal:
                begin
                    lrecPMMeasure.GET("PM Measure Code");
                    if lrecPMMeasure."Decimal Rounding Precision" = 0 then
                        lrecPMMeasure."Decimal Rounding Precision" := 0.00001;
                    //<JF8692SHR>
                    /*
                    "Decimal Value" := lvarValue;
                    */
                    ltxtValue := Format(lvarValue);
                    Evaluate("Decimal Value", ltxtValue);
                    //</JF8692SHR>

                    Validate("Decimal Value", Round("Decimal Value", lrecPMMeasure."Decimal Rounding Precision"));
                end;
            "Value Type"::Date:
                begin
                    ltxtValue := Format(lvarValue);
                    lcduApplMgt.MakeDateText(ltxtValue);
                    Evaluate("Date Value", ltxtValue);
                    Validate("Date Value");
                end;
            "Value Type"::Time:
                begin
                    ltxtValue := Format(lvarValue);
                    lcduApplMgt.MakeTimeText(ltxtValue);
                    Evaluate("Time Value", ltxtValue);
                    Validate("Time Value");
                end;
        end;

    end;

    [Scope('Internal')]
    procedure jfdoGetDesiredValue(var pvarDesiredValue: Variant)
    var
        lrecPMProcLine: Record Table23019251;
    begin
        if lrecPMProcLine.GET("PM Procedure Code", "PM Proc. Version No.", "Line No.") then begin
            if lrecPMProcLine."PM Measure Code" = "PM Measure Code" then begin
                case "Value Type" of
                    "Value Type"::Boolean:
                        begin
                            pvarDesiredValue := Format(lrecPMProcLine."Boolean Value");
                        end;
                    "Value Type"::Code:
                        pvarDesiredValue := lrecPMProcLine."Code Value";
                    "Value Type"::Text:
                        pvarDesiredValue := lrecPMProcLine."Text Value";
                    "Value Type"::Decimal:
                        pvarDesiredValue := lrecPMProcLine."Decimal Value";
                    "Value Type"::Date:
                        pvarDesiredValue := Format(lrecPMProcLine."Date Value");
                    "Value Type"::Time:
                        pvarDesiredValue := Format(lrecPMProcLine."Time Value");
                end;
            end;
        end else
            pvarDesiredValue := '';
    end;
}

