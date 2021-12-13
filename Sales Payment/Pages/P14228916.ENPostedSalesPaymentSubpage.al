page 14228916 "EN Posted Sales Payment SubP."
{
    // ENSP1.00 2020-04-14 HR
    //     Created new page

    Caption = 'Posted Sales Payment Subpage';
    PageType = ListPart;
    SourceTable = "EN Posted Sales Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field(Description; Description)
                {
                }
                field(Amount; Amount)
                {
                }
            }
        }
    }

    actions
    {
    }
}

