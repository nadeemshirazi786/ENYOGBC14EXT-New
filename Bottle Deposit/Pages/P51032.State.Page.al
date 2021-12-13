page 51032 "State ELA"
{
    PageType = List;
    SourceTable = "State ELA";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'State';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(State; State)
                {
                }
                field(Name; Name)
                {
                }
                field("Bottle Deposit"; "Bottle Deposit ELA")
                {
                }
                field("Bottle Deposit Account"; "Bottle Deposit Account")
                {
                }
            }
        }
    }

    actions
    {
    }
}

