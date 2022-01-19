table 14229807 "PM Proc. Comment ELA"
{
    DrillDownPageID = 23019258;
    LookupPageID = 23019258;

    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
        }
        field(2; "Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header ELA"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM Procedure Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
            Description = 'DO NOT USE Field No. 5';
        }
        field(10; Comments; Text[125])
        {
        }
        field(50; Spaces; Integer)
        {
        }
        field(51; NewLine; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnInsert()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnModify()
    begin
        CheckPMHeaderStatus;
    end;

    trigger OnRename()
    begin
        CheckPMHeaderStatus;
    end;

    var
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;

    [Scope('Internal')]
    procedure CheckPMHeaderStatus()
    var
        lrecPMProc: Record "PM Procedure Header ELA";
    begin
        lrecPMProc.Get("PM Procedure Code", "Version No.");
        lrecPMProc.CheckStatus;
    end;
}

