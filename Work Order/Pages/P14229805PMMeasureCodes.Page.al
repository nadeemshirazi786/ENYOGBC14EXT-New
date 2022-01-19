page 14229805 "PM Measure Codes"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DelayedInsert = true;
    PageType = List;
    SourceTable = Table23019255;

    layout
    {
        area(content)
        {
            repeater()
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
                    RunObject = Page 23019256;
                    RunPageLink = PM Measure Code=FIELD(Code);
                }
            }
        }
    }
}

