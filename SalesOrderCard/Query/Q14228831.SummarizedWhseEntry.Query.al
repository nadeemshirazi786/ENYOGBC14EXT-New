query 14228831 "Summarized Whse. Entry ELA"
{
    elements
    {
        dataitem(Warehouse_Entry; "Warehouse Entry")
        {
            column(Location_Code; "Location Code")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Zone_Code; "Zone Code")
            {
            }
            column(Bin_Code; "Bin Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
            }
            column(Serial_No; "Serial No.")
            {
            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            column(Sum_Qty_Base; "Qty. (Base)")
            {
                Method = Sum;
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Sum_Cubage; Cubage)
            {
                Method = Sum;
            }
            column(Sum_Weight; Weight)
            {
                Method = Sum;
            }
        }
    }
}

