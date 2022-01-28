pageextension 14229249 "Whse. Activity Lines" extends "Warehouse Activity Lines"
{

    layout
    {
        addafter(Quantity)
        {
            field("Assigned App. Role ELA"; "Assigned App. Role ELA")
            {
                ApplicationArea = All;
            }
            field("Assigned App. User ELA"; "Assigned App. User ELA")
            {
                ApplicationArea = All;
            }
            field("Container No. ELA"; "Container No. ELA")
            {
                ApplicationArea = All;
            }
            field("Lot No."; "Lot No.")
            {
                ApplicationArea = All;
            }
        }
    }
}