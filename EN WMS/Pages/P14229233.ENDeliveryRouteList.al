//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Delivery Route List (ID 14229233).
/// </summary>
page 14229233 "Delivery Route List ELA"
{

    ApplicationArea = All;
    Caption = 'Delivery Route List';
    PageType = List;
    SourceTable = "Delivery Route ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Default Driver No."; Rec."Default Driver No.")
                {
                    ApplicationArea = All;
                }
                field("Default Truck Code"; Rec."Default Truck Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
