page 14229843 "Fin. Work Ord Stat FactBox"
{
    // Copyright Axentia Solutions Corp.  1999-2014.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF43819SHR 20141106 - add stop time

    Caption = 'Statistics';
    Editable = false;
    PageType = CardPart;
    SourceTable = Table23019270;

    layout
    {
        area(content)
        {
            field("Qty. Produced"; "Qty. Produced")
            {
            }
            field("Capacity Qty."; "Capacity Qty.")
            {
            }
            field("Stop Time"; "Stop Time")
            {
            }
            group(Results)
            {
                Caption = 'Results';
                field("Maintenance Cost"; "Maintenance Cost")
                {
                }
                field("PM WO Failure"; "PM WO Failure")
                {
                }
                field("Test Complete"; "Test Complete")
                {
                }
            }
        }
    }

    actions
    {
    }
}

