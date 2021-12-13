table 14229413 "Cost Categories ELA"
{
    // ENRE1.00 2021-09-08 AJ


    Caption = 'Cost Categories';
    DrillDownPageID = "Cost Categories ELA"; //Cost Categories
    LookupPageID = "Cost Categories ELA";

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(10; "Reporting Sequence"; Integer)
        {
        }
        field(20; "Cost Type"; Option)
        {
            OptionCaption = 'Material,Capacity,MFG Overhead,Capacity Overhead,Item Charge';
            OptionMembers = Material,Capacity,"MFG Overhead","Capacity Overhead","Item Charge";
        }
        field(21; Usage; Option)
        {
            OptionCaption = 'All,Actuals Only,BOM Only,WIP Pass Through';
            OptionMembers = All,"Actuals Only","BOM Only","WIP Pass Through";
        }
        field(25; "Item Charge Filter"; Text[250])
        {
        }
        field(26; "IC Inclusion"; Option)
        {
            OptionCaption = 'All Transactions,Pre-Production,Post-Production';
            OptionMembers = "All Transactions","Pre-Production","Post-Production";
        }
        field(100; Amount; Decimal)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Reporting Sequence")
        {
        }
    }

    fieldgroups
    {
    }
}

