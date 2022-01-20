page 14229830 "PM Fault Codes"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Fault Code ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Fault Area"; "PM Fault Area")
                {
                }
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

