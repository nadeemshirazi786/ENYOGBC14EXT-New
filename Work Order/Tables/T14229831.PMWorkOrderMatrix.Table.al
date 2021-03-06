table 14229831 "PM Work Order Matrix ELA"
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
            TableRelation = IF (Type = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST ("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset";
        }
        field(30; "PM Procedure"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code WHERE (Type = FIELD (Type));

            trigger OnValidate()
            var
                lrecQualityProcedureSetup: Record "PM Procedure Header ELA";
                lcduQualityManagement: Codeunit "PM Management ELA";
                lcodVersion: Code[10];
            begin
                TestField("PM Procedure");
                Clear(lcodVersion);
                lcodVersion := lcduQualityManagement.GetActiveVersion("PM Procedure");
                lrecQualityProcedureSetup.Reset;
                lrecQualityProcedureSetup.Get("PM Procedure", lcodVersion);
                "Work Order Freq." := lrecQualityProcedureSetup."Work Order Freq.";
            end;
        }
        field(40; "Last Work Order Date"; Date)
        {
        }
        field(50; "Work Order Freq."; DateFormula)
        {
        }
    }

    keys
    {
        key(Key1; Type, "No.", "PM Procedure")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

