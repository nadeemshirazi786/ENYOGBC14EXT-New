page 14229427 "Properties ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00 - Label Item Property
    //   ENRE1.00 - Added fields to the tablebox:
    //              * 70            "Display In Lot Tracking"                Boolean
    // 
    // ENRE1.00
    //   ENRE1.00
    //     rem deprecated fields; add "Value Posting"
    Caption = 'Properties';

    ApplicationArea = All;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Property ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1000000000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Property Group Code"; "Property Group Code")
                {
                    ApplicationArea = All;
                }
                field("Value Type"; "Value Type")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Default Property Value"; "Default Property Value")
                {
                    ApplicationArea = All;
                }
                field("Value Posting"; "Value Posting")
                {
                    ApplicationArea = All;
                }
                field("Decimal Rounding Precision"; "Decimal Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("Rounding Method Code"; "Rounding Method Code")
                {
                    ApplicationArea = All;
                }
                field("Display In Lot Tracking"; "Display In Lot Tracking")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Properties)
            {
                Caption = 'Properties';
                action("Code Values")
                {
                    ApplicationArea = All;
                    Caption = 'Code Values';
                    Image = ElectronicNumber;

                    trigger OnAction()
                    begin
                        if "Value Type" <> "Value Type"::Code then
                            Error(JMText001);

                        grecCPV.SetRange("Property Code", Code);
                        PAGE.Run(PAGE::"Code Property Values ELA", grecCPV);
                    end;
                }
            }
        }
    }

    var
        JMText001: Label 'Type must be Code to associate Code Property Values.';
        grecCPV: Record "Code Property Value ELA";
}

