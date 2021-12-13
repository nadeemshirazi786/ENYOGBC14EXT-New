page 51003 "Banana Preference"
{
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "Banana Preference";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("Banana Color Pref. Code"; "Banana Color Pref. Code")
                {
                }
            }
        }
    }
}

