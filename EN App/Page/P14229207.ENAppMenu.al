page 14229207 "App. Menus ELA"
{
    ApplicationArea = All;
    Caption = 'App. Menus';
    PageType = List;
    SourceTable = "App. Menu ELA";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Menu Code"; "Menu Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Menu Type"; "Menu Type")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
