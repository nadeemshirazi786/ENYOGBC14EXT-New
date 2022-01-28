page 14229837 "PM Work Order Matrix ELA"
{
    DataCaptionFields = Type, "No.";
    PageType = List;
    SourceTable = "PM Work Order Matrix ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field("PM Procedure"; "PM Procedure")
                {
                }
                field("Last Work Order Date"; "Last Work Order Date")
                {
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

