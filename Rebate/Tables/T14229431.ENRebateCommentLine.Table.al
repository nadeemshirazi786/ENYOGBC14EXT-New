table 14229431 "Rebate Comment Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //            - add field
    //              * 35 Code
    //            - add SetupNewLine function (replace old one that was invalid)
    //            - make Date field editable


    fields
    {
        field(10; "Rebate Code"; Code[20])
        {
            TableRelation = "Rebate Header ELA".Code;
        }
        field(20; "Line No."; Integer)
        {
            TableRelation = "Rebate Line ELA"."Line No." WHERE("Rebate Code" = FIELD("Rebate Code"));
        }
        field(30; Date; Date)
        {
        }
        field(35; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(40; Comment; Text[80])
        {
        }
        field(50; "Created By User ID"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
    }

    keys
    {
        key(Key1; "Rebate Code", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField(Comment);
    end;

    trigger OnModify()
    begin
        TestField(Comment);
    end;


    procedure SetUpNewLine()
    var
        RebateCommentLine: Record "Rebate Comment Line ELA";
    begin
        //<ENRE1.00>
        RebateCommentLine.SetRange("Rebate Code", "Rebate Code");
        RebateCommentLine.SetRange(Date, WorkDate);

        if not RebateCommentLine.Find('-') then begin
            Date := WorkDate;
        end;

        "Created By User ID" := UpperCase(UserId);
        //</ENRE1.00>
    end;
}

