table 14229817 "PM Worksheet Batch ELA"
{
    Caption = 'PM Worksheet Batch';
    DrillDownPageID = "PM Worksheet Batch";
    LookupPageID = "PM Worksheet Batch";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(5; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        grecPMPlanWksht.SetRange("Worksheet Batch Name", Name);
        grecPMPlanWksht.DeleteAll(true);
    end;

    var
        Text000: Label 'Only the %1 field can be filled in on recurring journals.';
        Text001: Label 'must not be %1';
        grecPMPlanWksht: Record "PM Planning Worksheet ELA";
}

