page 14228822 "Global Group Values ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF14955SHR
    //   20111012 - new form

    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Global Group Value ELA";

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

