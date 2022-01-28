//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Delivery Drivers List (ID 14229231).
/// </summary>
page 14229231 "Delivery Drivers List ELA"
{

    ApplicationArea = All;
    Caption = 'Delivery Driver';
    PageType = List;
    SourceTable = "Delivery Driver ELA";
    UsageCategory = Lists;
    CardPageId = "Delivery Driver Card ELA";
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
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Zip Code"; Rec."Zip Code")
                {
                    ApplicationArea = All;
                }

                field(State; Rec.State)
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

}
