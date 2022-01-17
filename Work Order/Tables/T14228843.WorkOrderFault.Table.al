table 14228843 "Work Order Fault"
{

    DrillDownPageID = 23019265;
    LookupPageID = 23019265;

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
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = Table23019250.Field1;
        }
        field(10; "PM Fault Area"; Code[10])
        {
            TableRelation = Table23019280;
        }
        field(11; "PM Fault Code"; Code[10])
        {
            TableRelation = Table23019281.Field2 WHERE (Field1 = FIELD ("PM Fault Area"));
        }
        field(12; Description; Text[50])
        {
        }
        field(15; "PM Fault Effect"; Code[10])
        {
            TableRelation = Table23019284;
        }
        field(16; "PM Fault Reason"; Code[10])
        {
            TableRelation = Table23019282;
        }
        field(17; "PM Fault Resolution"; Code[10])
        {
            TableRelation = Table23019283;
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if HasLinks then
            DeleteLinks;
    end;

    trigger OnInsert()
    begin
        if grecPMWOHeader.Get("PM Work Order No.") then begin
            "PM Proc. Version No." := grecPMWOHeader."PM Proc. Version No.";
            "PM Procedure Code" := grecPMWOHeader."PM Procedure Code";
        end;
    end;

    var
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;
        grecPMWOHeader: Record "Work Order Header";
}

