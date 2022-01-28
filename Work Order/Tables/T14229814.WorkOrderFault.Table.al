table 14229814 "Work Order Fault ELA"
{
    DrillDownPageID = "Work Order Faults ELA";
    LookupPageID = "Work Order Faults ELA";

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = "Work Order Header ELA"."PM Work Order No.";
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header ELA"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
        }
        field(10; "PM Fault Area"; Code[10])
        {
            TableRelation = "PM Fault Area ELA";
        }
        field(11; "PM Fault Code"; Code[10])
        {
            TableRelation = "PM Fault Code ELA".Code WHERE ("PM Fault Area" = FIELD ("PM Fault Area"));
        }
        field(12; Description; Text[50])
        {
        }
        field(15; "PM Fault Effect"; Code[10])
        {
            TableRelation = "PM Fault Effect ELA";
        }
        field(16; "PM Fault Reason"; Code[10])
        {
            TableRelation = "PM Fault Reason ELA";
        }
        field(17; "PM Fault Resolution"; Code[10])
        {
            TableRelation = "PM Fault Resolution ELA";
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
        grecPMWOHeader: Record "Work Order Header ELA";
}

