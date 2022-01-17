table 14228845 "Finished WO Line"
{
    DrillDownPageID = 23019742;
    LookupPageID = 23019742;

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
        }
        field(14; "Date Value"; Date)
        {
        }
        field(15; "Boolean Value"; Boolean)
        {
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
            CalcFormula = Exist (Table23019272 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "PMWO Resources"; Boolean)
        {
            CalcFormula = Exist (Table23019273 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "PMWO Comments"; Boolean)
        {
            CalcFormula = Exist (Table23019274 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; Result; Option)
        {
            OptionCaption = '?,Pass,Fail';
            OptionMembers = "?",Pass,Fail;
        }
        field(101; "Test Complete"; Boolean)
        {
        }
        field(102; "PM Work Order Faults"; Boolean)
        {
            CalcFormula = Exist ("Fin. Work Order Fault" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                               "PM WO Line No." = FIELD ("Line No.")));
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
    end;

    var
        grecQM: Record Table23019255;
        gvarDesiredValue: Variant;

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecFinPMWOItemCons: Record Table23019272;
        lrecFinPMWOResource: Record Table23019273;
        lrecFinPMWOComments: Record Table23019274;
    begin
        //Delete Related Records

        lrecFinPMWOItemCons.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecFinPMWOItemCons.SETRANGE("PM WO Line No.", "Line No.");
        lrecFinPMWOItemCons.DELETEALL(true);

        lrecFinPMWOResource.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecFinPMWOResource.SETRANGE("PM WO Line No.", "Line No.");
        lrecFinPMWOResource.DELETEALL(true);

        lrecFinPMWOComments.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecFinPMWOComments.SETRANGE("PM WO Line No.", "Line No.");
        lrecFinPMWOComments.DELETEALL;
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
                    "Decimal Value" := lvarValue;
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
                    "Value Type"::Date:
                        pvarDesiredValue := Format(lrecPMProcLine."Time Value");
                end;
            end;
        end else
            pvarDesiredValue := '';
    end;
}

