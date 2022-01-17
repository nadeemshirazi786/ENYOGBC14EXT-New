table 14228848 "PM Work Order Matrix"
{
    fields
    {
        field(10; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";
        }
        field(20; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
        }
        // field(30; "PM Procedure"; Code[20])
        // {
        //     TableRelation = Table23019250.Field1 WHERE(Field20 = FIELD(Type));

        //     trigger OnValidate()
        //     var
        //         lrecQualityProcedureSetup: Record Table23019250;
        //         lcduQualityManagement: Codeunit Codeunit23019250;
        //         lcodVersion: Code[10];
        //     begin
        //         TestField("PM Procedure");
        //         Clear(lcodVersion);
        //         lcodVersion := lcduQualityManagement.GetActiveVersion("PM Procedure");
        //         lrecQualityProcedureSetup.RESET;
        //         lrecQualityProcedureSetup.GET("PM Procedure", lcodVersion);
        //         "Work Order Freq." := lrecQualityProcedureSetup."Work Order Freq.";
        //     end;
        // }
        field(40; "Last Work Order Date"; Date)
        {
        }
        field(50; "Work Order Freq."; DateFormula)
        {
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

