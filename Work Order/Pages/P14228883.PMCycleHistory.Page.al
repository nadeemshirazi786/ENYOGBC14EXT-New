page 23019295 "PM Cycle History"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // CC17988DT
    //   070912012 additional fields added as per form

    PageType = List;
    SourceTable = Table23019295;

    layout
    {
        area(content)
        {
            repeater()
            {
                field(Type; Type)
                {
                    Visible = false;
                }
                field("No."; "No.")
                {
                    Visible = false;
                }
                field("Cycle Date"; "Cycle Date")
                {
                }
                field(Cycles; Cycles)
                {
                }
                field("Total Miles"; "Total Miles")
                {
                }
                field(MA; MA)
                {
                }
                field(CT; CT)
                {
                }
                field(RI; RI)
                {
                }
                field(NH; NH)
                {
                }
                field("New Mileage"; "New Mileage")
                {
                }
            }
        }
    }

    actions
    {
    }
}

