page 14229244 "Route Matrix ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Route Matrix ELA";
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    Caption = 'Route Matrix';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field(Monday; Monday)
                {
                    ApplicationArea = All;
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = All;
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = All;
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = All;
                }
                field(Friday; Friday)
                {
                    ApplicationArea = All;
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = All;
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Customer Code"; "Customer Code")
                {
                    ApplicationArea = All;
                }
                field("Route Code"; "Route Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


}