table 23019258 "PM Proc. Comment"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = 23019258;
    LookupPageID = 23019258;

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
        lrecPMProc: Record "PM Procedure Header";
    begin
        lrecPMProc.Get("PM Procedure Code", "Version No.");
        lrecPMProc.CheckStatus;
    end;
}

