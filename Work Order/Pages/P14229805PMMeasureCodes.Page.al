page 14229805 "PM Measure Codes"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Measure ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("Default Unit of Measure Code"; "Default Unit of Measure Code")
                {
                }
                field("Value Type"; "Value Type")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("PM Measures")
            {
                Caption = 'PM Measures';
                action("PM Measure Code Values")
                {
                    Caption = 'PM Measure Code Values';
                    Image = CodesList;
                    RunObject = Page "PM Measure Code Values";
                    RunPageLink = "PM Measure Code"=FIELD(Code);
                }
            }
        }
    }
}

