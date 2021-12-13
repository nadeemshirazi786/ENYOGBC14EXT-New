pageextension 14229630 "EN Customers Ext" extends "Customer List"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("Communication Group Code"; "Communication Group Code ELA")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addbefore(Sales)
        {
            action("Sales Price Calculations")
            {
                Image = CalculateCost;
                RunObject = page "EN Price List Line";
                RunPageView = SORTING("Sales Type", "Sales Code", Type, Code, "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                RunPageLink = "Sales Type" = CONST(Customer), "Sales Code" = FIELD("No.");
                Promoted = true;
            }
        }
        addlast(Creation)
        {
            action("Workwave Manifest List")
            {
                ApplicationArea = All;
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WWManList: Page "Workwave Manifest List ELA";
                begin
                    WWManList.CustFilter("No.");
                    WWManList.RUN
                end;
            }
        }
        
    }
    
}
