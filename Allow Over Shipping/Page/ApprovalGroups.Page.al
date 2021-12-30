page 50011 "Approval Groups"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    PageType = List;
    SourceTable = "Approval Group";

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Users)
            {
                Caption = 'Users';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Approval Group Users";
                RunPageLink = "Approval Group" = FIELD(Code);
            }
        }
    }
}

