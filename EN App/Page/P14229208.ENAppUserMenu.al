page 14229208 "App User Menus ELA"
{
    ApplicationArea = All;
    Caption = 'App. User Menus';
    PageType = List;
    SourceTable = "App. User Menu ELA";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App. User ID"; "App. User ID")
                {
                    ApplicationArea = All;
                }
                field("Menu ID"; "Menu ID")
                {
                    ApplicationArea = All;
                }
                field("Custom Filter"; "Custom Filter")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Require Special Equipment"; "Require Special Equipment")
                {
                    ApplicationArea = All;
                }

            }
        }
    }
}
