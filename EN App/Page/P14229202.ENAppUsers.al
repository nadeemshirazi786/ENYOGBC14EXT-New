//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile App. Users (ID 14229202).
/// </summary>
page 14229202 "App. Users ELA"
{
    ApplicationArea = All;
    Caption = 'App. Users';
    PageType = List;
    SourceTable = "Application User ELA";
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
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Default Location"; Rec."Default Location")
                {
                    ApplicationArea = All;
                }
                field("Default Role"; Rec."Default Role")
                {
                    ApplicationArea = All;
                }
                field("DSD Load Order Prefix"; Rec."DSD Load Order Prefix")
                {
                    ApplicationArea = All;
                }
                field("DSD Responsibility Center"; Rec."DSD Responsibility Center")
                {
                    ApplicationArea = All;
                }
                field("DSD Route No."; Rec."DSD Route No.")
                {
                    ApplicationArea = All;
                }
                field("DSD Transaction Prefix"; Rec."DSD Transaction Prefix")
                {
                    ApplicationArea = All;
                }
                field("Is Admin"; Rec."Is Admin")
                {
                    ApplicationArea = All;
                }
                field("PIN Code"; Rec."PIN Code")
                {
                    ApplicationArea = All;
                }
                field("Use only Default Role"; Rec."Use only Default Role")
                {
                    ApplicationArea = All;
                }

                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
