page 51015 "Purchase Worksheet Items"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "Purchase Worksheet Items";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                }
                field("Item No."; "Item No.")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                }
            }
        }
    }
}

