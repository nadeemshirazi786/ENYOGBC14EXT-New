page 14229842 "PM Cycle History"
{
    PageType = List;
    SourceTable = "PM Cycle History ELA";

    layout
    {
        area(content)
        {
            repeater(General)
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

