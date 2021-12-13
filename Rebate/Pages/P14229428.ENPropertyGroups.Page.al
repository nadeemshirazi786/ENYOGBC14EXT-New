page 14229428 "Property Groups ELA"
{
    // ENRE1.00 2021-09-08 AJ

    Caption = 'Property Groups';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Property Group ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

