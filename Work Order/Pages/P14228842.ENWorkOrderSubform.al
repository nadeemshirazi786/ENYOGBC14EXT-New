page 14228842 "Work Order Subform ELA"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Work Order Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    Caption = 'Lines';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PM Step Code"; "PM Step Code")
                {
                    ApplicationArea = All;
                }
                field("PM Measure Code"; "PM Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Result Value"; gtxtValue)
                {
                    ApplicationArea = All;
                }
                field(Result; Result)
                {
                    ApplicationArea = All;
                }
                field("Test Complete"; "Test Complete")
                {
                    ApplicationArea = All;
                }
                field("Critical Control Point"; "Critical Control Point")
                {
                    ApplicationArea = All;
                }
                field("PM Unit of Measure"; "PM Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Desired Value"; gtxtDesiredValue)
                {
                    ApplicationArea = All;
                }
                field("Value Type"; "Value Type")
                {
                    ApplicationArea = All;
                }
                field("No. Results"; "No. Results")
                {
                    ApplicationArea = All;
                }
                field("Result Calc. Type"; "Result Calc. Type")
                {
                    ApplicationArea = All;
                }
                field("Decimal Min"; "Decimal Min")
                {
                    ApplicationArea = All;
                }
                field("Decimal Max"; "Decimal Max")
                {
                    ApplicationArea = All;
                }
                field("Qualification Code"; "Qualification Code")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; "Employee No.")
                {
                    ApplicationArea = All;
                }
                field("PM Measure Cost"; "PM Measure Cost")
                {
                    ApplicationArea = All;
                }
                field("Decimal Rounding Precision"; "Decimal Rounding Precision")
                {
                    ApplicationArea = All;
                }
                field("PM Work Order Faults"; "PM Work Order Faults")
                {
                    ApplicationArea = All;
                }
                field("PM Fault Possibilities"; "PM Fault Possibilities")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        gtxtValue: Text[250];
        gtxtDesiredValue: Text[250];
        gvarValue: Variant;
        gvarDesiredValue: Variant;
        "Decimal MinEditable": Boolean;
        "Decimal MaxEditable": Boolean;
        DecimalRoundingPrecisionEditab: Boolean;
}