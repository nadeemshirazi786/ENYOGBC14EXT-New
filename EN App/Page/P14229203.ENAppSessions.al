//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile App Sessions (ID 14229203).
/// </summary>
page 14229203 "App. Sessions ELA"
{

    ApplicationArea = All;
    Caption = 'App. Sessions';
    PageType = List;
    SourceTable = "Application Session ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App. Code"; Rec."App. Code")
                {
                    ApplicationArea = All;
                }
                field("App. User ID"; Rec."App. User ID")
                {
                    ApplicationArea = All;
                }
                field("Date Logged In"; Rec."Date Logged In")
                {
                    ApplicationArea = All;
                }
                field("Device Acct. ID"; Rec."Device Acct. ID")
                {
                    ApplicationArea = All;
                }
                field("Device Version"; Rec."Device Version")
                {
                    ApplicationArea = All;
                }
                field("Equipment Code"; Rec."Equipment Code")
                {
                    ApplicationArea = All;
                }
                field("Last Activity Time"; Rec."Last Activity Time")
                {
                    ApplicationArea = All;
                }
                field("Role Code"; Rec."Role Code")
                {
                    ApplicationArea = All;
                }
                field("Session ID"; Rec."Session ID")
                {
                    ApplicationArea = All;
                }
                field("Signed In Location"; Rec."Signed In Location")
                {
                    ApplicationArea = All;
                }
                field("Time Logged In"; Rec."Time Logged In")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
