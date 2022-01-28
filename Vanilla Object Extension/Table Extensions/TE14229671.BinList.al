tableextension 14229249 "WMS Bin List ELA" extends "Bin"
{
    fields
    {

        field(14229220; "Blocked ELA"; Option)
        {
            OptionMembers = Open,Blocked,QC;
            DataClassification = ToBeClassified;
            Caption = 'Blocked';
        }
        field(14229221; "Blocked Reason ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Blocked Reason';
        }

    }
}