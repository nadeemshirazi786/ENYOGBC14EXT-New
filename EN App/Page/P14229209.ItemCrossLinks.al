page 14229209 "Item Cross Links ELA"
{

    ApplicationArea = All;
    Caption = 'Item Cross Links';
    PageType = List;
    SourceTable = "Item Cross Link ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {

            repeater(General)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Linked Item No."; "Linked Item No.")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Linked Item Description"; "Linked Item Description")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Use for Item Substitution"; "Use for Item Substitution")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Blocked for Item Substitution"; "Blocked for Item Substitution")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
            }
            part("Item Units of Measure"; "Item Units of Measure")
            {
                Caption = 'Item Units of Measure';
                SubPageView = SORTING("Item No.", Code) ORDER(Ascending);
                SubPageLink = "Item No." = FIELD("Linked Item No.");
                UpdatePropagation = Both;
            }


        }
    }


}
