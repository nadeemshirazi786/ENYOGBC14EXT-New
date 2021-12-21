page 14228812 Counties
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF02278AC
    //   20090616
    //     - new object
    // 
    //   20090622
    //     - allow edit from lookup (rely on table permissions)

    Caption = 'States';
    PageType = List;
    SourceTable = County;

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field("Country/Region Code"; "Country/Region Code")
                {
                    ShowCaption = false;
                }
                field("Code"; Code)
                {
                    ShowCaption = false;
                }
                field(Name; Name)
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

