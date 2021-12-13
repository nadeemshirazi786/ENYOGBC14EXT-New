page 51007 "DSD Route Stop Template List"
{
    CardPageID = "DSD Route Stop Template";
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "DSD Route Stop Template";

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                }
                field("Start Date"; "Start Date")
                {
                }
                field("End Date"; "End Date")
                {
                }
            }
        }
    }
}

