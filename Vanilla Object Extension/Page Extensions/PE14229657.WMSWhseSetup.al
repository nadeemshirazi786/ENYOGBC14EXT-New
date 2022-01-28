pageextension 14229250 "WMS Whse. Setup" extends "Warehouse Setup"
{

    layout
    {
        addafter("Registered Whse. Movement Nos.")
        {
            field("WMS Item Jnl. Template ELA"; "WMS Item Jnl. Template ELA")
            {
                ApplicationArea = All;
            }
            field("WMS Item Jnl. No. ELA"; "WMS Item Jnl. No. ELA")
            {
                ApplicationArea = All;
            }
            field("Batch Post WMS Adjustment ELA"; "Batch Post WMS Adjustment ELA")
            {
                ApplicationArea = All;
            }
            field("Item Jnl Temp. for WMS Adj ELA"; "Item Jnl Temp. for WMS Adj ELA")
            {
                ApplicationArea = All;
            }
            field("WMS Phys. Jnl. Template ELA"; "WMS Phys. Jnl. Template ELA")
            {
                ApplicationArea = All;
            }
            field("WMS Phys. Jnl. Nos. ELA"; "WMS Phys. Jnl. Nos. ELA")
            {
                ApplicationArea = All;
            }
            field("Phys. Jnl Template ELA"; "Phys. Jnl Template ELA")
            {
                ApplicationArea = All;
            }
            field("Item Reclass Jnl Template ELA"; "Item Reclass Jnl Template ELA")
            {
                ApplicationArea = All;
            }
            field("Move Adjusted BOL Stock Back ELA"; "Move Adjusted Stock Back ELA")
            {
                ApplicationArea = All;
            }
        }
    }
}