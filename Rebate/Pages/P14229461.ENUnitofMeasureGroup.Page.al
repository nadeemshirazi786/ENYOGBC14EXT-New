page 14229461 "Unit of Measure Group ELA"
{
    // ENRE1.00 2021-09-08 AJ

    Caption = 'Unit of Measure Group';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Unit of Measure Group ELA";
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

