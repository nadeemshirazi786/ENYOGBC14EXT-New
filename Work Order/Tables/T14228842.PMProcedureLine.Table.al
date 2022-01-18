table 23019251 "PM Procedure Line"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF8692SHR
    //   20100624 - modified function jmdoValidateValue, decimal values would not convert
    // 
    // JF11335SHR
    //   20110113 - modified function jmdoValidateValue
    // 
    // JF14148AC
    //   20110822
    //     remove "Employee Position Code" (legacy Serenic field/table)
    // 
    // JF23246AC 20130415 - reverse out fix that isn't required now that we're on Pages, to provide better data entry feedback


    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(2; "Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "Line No."; Integer)
        {
        }
        field(5; "PM Measure Code"; Code[20])
        {
            Description = 'DO NOT USE Field No. 4';
            TableRelation = "PM Measure".Code;

            trigger OnValidate()
            begin
                //Need to get PM Measure and default the QM Value Type
                if grecQM.Get("PM Measure Code") then begin
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
            TableRelation = "PM Step";
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
            end;
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
        field(50; "PM Item Consumption"; Boolean)
        {
            CalcFormula = Exist ("PM Item Consumption" WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code"),
                                                             "Version No." = FIELD ("Version No."),
                                                             "PM Procedure Line No." = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; "PM Resources"; Boolean)
        {
            CalcFormula = Exist ("PM Resource" WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code"),
                                                     "Version No." = FIELD ("Version No."),
                                                     "PM Procedure Line No." = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(52; "PM Comments"; Boolean)
        {
            CalcFormula = Exist ("PM Proc. Comment" WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code"),
                                                          "Version No." = FIELD ("Version No."),
                                                          "PM Procedure Line No." = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "PM Fault Possibilities"; Boolean)
        {
            CalcFormula = Exist ("PM Fault Possibilities" WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code"),
                                                                "Version No." = FIELD ("Version No."),
                                                                "PM Procedure Line No." = FIELD ("Line No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "PM Procedure Code", "Version No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckPMProcedureStatus;
        DeleteRelations;

        if HasLinks then
            DeleteLinks;
    end;

    trigger OnInsert()
    begin
        CheckPMProcedureStatus;
    end;

    trigger OnModify()
    begin
        CheckPMProcedureStatus;
    end;

    trigger OnRename()
    begin
        CheckPMProcedureStatus;
    end;

    var
        grecQM: Record "PM Measure";

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecPMPItemCons: Record "PM Item Consumption";
        lrecPMPResment: Record "PM Resource";
        lrecPMProcComments: Record "PM Proc. Comment";
    begin
        //Delete Related Records

        lrecPMPItemCons.SetRange("PM Procedure Code", "PM Procedure Code");
        lrecPMPItemCons.SetRange("Version No.", "Version No.");
        lrecPMPItemCons.SetRange("PM Procedure Line No.", "Line No.");
        lrecPMPItemCons.DeleteAll(true);

        lrecPMPResment.SetRange("PM Procedure Code", "PM Procedure Code");
        lrecPMPResment.SetRange("Version No.", "Version No.");
        lrecPMPResment.SetRange("PM Procedure Line No.", "Line No.");
        lrecPMPResment.DeleteAll(true);

        lrecPMProcComments.SetRange("PM Procedure Code", "PM Procedure Code");
        lrecPMProcComments.SetRange("Version No.", "Version No.");
        lrecPMProcComments.SetRange("PM Procedure Line No.", "Line No.");
        lrecPMProcComments.DeleteAll(true);
    end;

    [Scope('Internal')]
    procedure jmdoValidateValue(var lvarValue: Variant)
    var
        ltxtValue: Text[250];
        lrecPMMeasure: Record "PM Measure";
        lcduApplMgt: Codeunit Codeunit1;
    begin
        case "Value Type" of
            "Value Type"::Boolean:
                begin
                    ltxtValue := lvarValue;
                    if ltxtValue = '' then
                        ltxtValue := 'No';
                    //<JF11335SHR>
                    //<JF23246AC>
                    Evaluate("Boolean Value", ltxtValue);
                    Validate("Boolean Value");
                    /*
                    IF EVALUATE("Boolean Value",ltxtValue) THEN BEGIN
                      VALIDATE("Boolean Value");
                    END;
                    */
                    //</JF23246AC>
                    //</JF11335SHR>
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
                    lrecPMMeasure.Get("PM Measure Code");
                    if lrecPMMeasure."Decimal Rounding Precision" = 0 then
                        lrecPMMeasure."Decimal Rounding Precision" := 0.00001;
                    //<JF8692SHR>
                    /*
                    "Decimal Value" := lvarValue;
                    */
                    ltxtValue := Format(lvarValue);
                    //<JF11335SHR>
                    //<JF23246AC>
                    Evaluate("Decimal Value", ltxtValue);
                    //</JF8692SHR>
                    Validate("Decimal Value", Round("Decimal Value", lrecPMMeasure."Decimal Rounding Precision"));
                    /*
                    IF EVALUATE("Decimal Value",ltxtValue) THEN BEGIN
                      VALIDATE("Decimal Value", ROUND("Decimal Value",lrecPMMeasure."Decimal Rounding Precision"));
                    END;
                    */
                    //</JF23246AC>
                    //</JF11335SHR>
                end;
            "Value Type"::Date:
                begin
                    ltxtValue := Format(lvarValue);
                    lcduApplMgt.MakeDateText(ltxtValue);
                    //<JF11335SHR>
                    //<JF23246AC>
                    Evaluate("Date Value", ltxtValue);
                    Validate("Date Value");
                    /*
                    IF EVALUATE("Date Value",ltxtValue) THEN BEGIN
                      VALIDATE("Date Value");
                    END;
                    */
                    //</JF23246AC>
                    //</JF11335SHR>
                end;
            "Value Type"::Time:
                begin
                    ltxtValue := Format(lvarValue);
                    lcduApplMgt.MakeTimeText(ltxtValue);
                    //<JF11335SHR>
                    //<JF23246AC>
                    Evaluate("Time Value", ltxtValue);
                    Validate("Time Value");
                    /*
                    IF EVALUATE("Time Value",ltxtValue) THEN BEGIN
                      VALIDATE("Time Value");
                    END;
                    */
                    //</JF23246AC>
                    //</JF11335SHR>
                end;
        end;

    end;

    [Scope('Internal')]
    procedure CheckPMProcedureStatus()
    var
        lrecPMProcedure: Record "PM Procedure Header";
    begin
        lrecPMProcedure.Get("PM Procedure Code", "Version No.");
        lrecPMProcedure.CheckStatus;
    end;
}

