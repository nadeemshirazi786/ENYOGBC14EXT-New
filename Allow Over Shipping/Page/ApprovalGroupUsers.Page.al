page 50012 "Approval Group Users"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    PageType = List;
    SourceTable = "Approval Group User";

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Approval Group"; "Approval Group")
                {
                    ShowCaption = false;
                }
                field(User; User)
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

