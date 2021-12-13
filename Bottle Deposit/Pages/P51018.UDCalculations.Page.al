page 51018 "UD Calculations ELA"
{
    Caption = 'User-Defined Calculations';
    PageType = List;
    SourceTable = "UD Calculation ELA";

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ShowCaption = false;
                }
                field(Description; Description)
                {
                    ShowCaption = false;
                }
                field("Table No."; "Table No.")
                {
                    LookupPageID = Objects;
                    ShowCaption = false;
                }
                field("Table Name"; "Table Name")
                {
                    ShowCaption = false;
                }
                field("Include on Calculation View"; "Include on Calculation View")
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }
}

