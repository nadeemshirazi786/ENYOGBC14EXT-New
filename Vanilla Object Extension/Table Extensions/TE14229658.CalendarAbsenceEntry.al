tableextension 14229658 "Calendar Absence Entry ELA" extends "Calendar Absence Entry"
{
    fields
    {
        field(14229800; "PM Work Order No. ELA"; Code[20])
        {
            Editable = false;
            TableRelation = "Work Order Header ELA"."PM Work Order No.";
            Caption = 'PM Work Order No.';
            DataClassification = ToBeClassified;
        }
    }

    procedure UpdateDatetime()
    begin
        "Starting Date-Time" := CREATEDATETIME(Date, "Starting Time");
        "Ending Date-Time" := CREATEDATETIME(Date, "Ending Time");
    end;

    var
        myInt: Integer;
}