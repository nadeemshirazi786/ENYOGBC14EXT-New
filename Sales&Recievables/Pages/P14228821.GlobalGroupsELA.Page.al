page 14228821 "Global Groups ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF14955SHR
    //   20111012 - new form

    PageType = List;
    SourceTable = "Global Group ELA";
    Caption = 'Global Groups';
    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field(Code; Code)
                {
                    ShowCaption = false;
                }
                field(Description; Description)
                {
                    ShowCaption = false;
                }
                field("Code Caption"; "Code Caption")
                {
                    ShowCaption = false;
                }
                field("Filter Caption"; "Filter Caption")
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Global Group")
            {
                Caption = '&Global Group';
                action("Global Group &Values")
                {
                    Caption = 'Global Group &Values';
                    RunObject = Page "Global Group Values ELA";
                    RunPageLink = "Master Group" = FIELD(Code);
                }
            }
        }
    }
}

