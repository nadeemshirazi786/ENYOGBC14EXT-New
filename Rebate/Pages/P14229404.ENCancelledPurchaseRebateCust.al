page 14229404 "Cancelled Purch Rbt Cust ELA"
{

    // ENRE1.00
    //    - new object

    Caption = 'Cancelled Purchase Rebate Customers';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Cancelled Purch. Rbt Cust. ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Cancelled Purch. Rebate Code"; "Cancelled Purch. Rebate Code")
                {
                    ApplicationArea = All;
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

