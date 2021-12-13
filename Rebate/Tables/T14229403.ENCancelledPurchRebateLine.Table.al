table 14229403 "Cancel Purch. Rbt Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Table


    fields
    {
        field(10; "Line No."; Integer)
        {
        }
        field(20; "Purchase Rebate Code"; Code[20])
        {
            Editable = true;
            TableRelation = "Purchase Rebate Header ELA";
        }
        field(30; Source; Option)
        {
            OptionCaption = 'Item,Dimension';
            OptionMembers = Item,Dimension;
        }
        field(40; Type; Option)
        {
            OptionCaption = 'No.,Sub-type';
            OptionMembers = "No.","Sub-type";
        }
        field(50; "Sub-Type"; Option)
        {
            OptionCaption = ' ,Rebate Group,Category Code,Product Group';
            OptionMembers = " ","Rebate Group","Category Code","Product Group";

            trigger OnValidate()
            var
                lcon0001: Label 'Sub-Type must be Rebate Group, Category Code or Product Group.';
            begin
            end;
        }
        field(60; "Dimension Code"; Code[20])
        {
            TableRelation = Dimension;
        }
        field(70; Value; Code[20])
        {
        }
        field(90; Description; Text[50])
        {
            Editable = false;
        }
        field(100; Include; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Purchase Rebate Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; Source, Type, "Sub-Type", "Dimension Code", Value)
        {
        }
    }

    fieldgroups
    {
    }

    var
        grecRebateSetup: Record "Rebate Header ELA";
        grecTmpRebate: Record "Rebate Header ELA" temporary;
        grecRebateHeader: Record "Rebate Header ELA";
        gconText002: Label 'Rebate value for %1 cannot be greater than 100.';
        gconText003: Label 'Rebate Values cannot be entered at that line level when Source equals %1. Enter a Rebate Value in the header.';
        gconText004: Label 'You cannot make changes or delete this rebate since it is linked to a promotinal job.';
        gblnJobLinkSuspended: Boolean;


    procedure GetRebateHeader()
    begin
        grecRebateHeader.Get("Purchase Rebate Code");
    end;
}

