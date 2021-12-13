page 14229439 "Rebate Batches ELA"
{
    // ENRE1.00 2021-09-08 AJ

    ApplicationArea = All;
    Caption = 'Rebate Batches';
    PageType = List;
    SourceTable = "Rebate Batch ELA";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
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

