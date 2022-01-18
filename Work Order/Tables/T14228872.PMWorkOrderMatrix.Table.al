table 23019286 "PM Work Order Matrix"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF.00007 - PM Work Order Generation
    //   20050302 - Created Table


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
            TableRelation = "PM Procedure Header".Code WHERE (Type = FIELD (Type));

            trigger OnValidate()
            var
                lrecQualityProcedureSetup: Record "PM Procedure Header";
                lcduQualityManagement: Codeunit Codeunit23019250;
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

