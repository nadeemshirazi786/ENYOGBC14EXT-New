page 14229430 "Purchase Rebate Customers ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new object


    Caption = 'Purchase Rebate Customers';
    PageType = List;
    SourceTable = "Purchase Rebate Customer ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Purchase Rebate Code"; "Purchase Rebate Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Rebate Start Date"; "Rebate Start Date")
                {
                    ApplicationArea = All;
                }
                field("Rebate End Date"; "Rebate End Date")
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

