page 51034 "Bottle Deposit Setup ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Bottle Deposit Setup";
    Caption = 'Bottle Deposit Setup';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Bottle Deposit State"; "Bottle Deposit State")
                {
                    ApplicationArea = All;
                }
                field("Bottle Deposit Amount"; "Bottle Deposit Amount")
                {
                    ApplicationArea = All;
                }
                field("Bottle Deposit Account"; "Bottle Deposit Account")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
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