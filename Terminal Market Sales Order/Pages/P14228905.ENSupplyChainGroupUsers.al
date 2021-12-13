page 14228905 "EN Supply Chain Group Users"
{
    Caption = 'Supply Chain Group Users';
    PageType = List;
    SourceTable = "EN Supply Chain Group User";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                }
                field("Supply Chain Group Code"; "Supply Chain Group Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

