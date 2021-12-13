page 51033 "User-Def. Item ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "User-Defined Fields - Item ELA";
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Pack Size"; "Pack Size")
                {
                    ApplicationArea = All;
                }
                field("Bottle Deposit - Sales"; "Bottle Deposit - Sales")
                {
                    ApplicationArea = All;
                }
                field("Bottle Deposit - Purchase"; "Bottle Deposit - Purchase")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}