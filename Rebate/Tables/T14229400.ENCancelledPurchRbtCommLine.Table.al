table 14229400 "Cancel Purch Rbt Comm Line ELA"
{

    //ENRE1.00 2021-09-08 AJ 
    // ENRE1.00
    //    - New Table

    LookupPageID = "Purch. Rbt Comment Sheet ELA";

    fields
    {
        field(10; "Purchase Rebate Code"; Code[20])
        {
            TableRelation = "Purchase Rebate Header ELA";
        }
        field(20; "Line No."; Integer)
        {
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
        key(Key1; "Purchase Rebate Code", "Line No.")
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
        CancelledRebateCommentLine: Record "Cancel Purch Rbt Comm Line ELA";
    begin
        CancelledRebateCommentLine.SetRange("Purchase Rebate Code", "Purchase Rebate Code");
        CancelledRebateCommentLine.SetRange(Date, WorkDate);
        if not CancelledRebateCommentLine.Find('-') then begin
            Date := WorkDate;
        end;
        "Created By User ID" := UpperCase(UserId);
    end;
}

