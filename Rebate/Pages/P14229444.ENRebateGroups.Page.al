page 14229444 "Rebate Groups ELA"
{
    // ENRE1.00 2021-09-08 AJ

    Caption = 'Rebate Groups';
    PageType = List;
    SourceTable = "Rebate Group ELA";
    UsageCategory = Administration;

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

