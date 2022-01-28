//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile User Permissions (ID 14229206).
/// </summary>
page 14229206 "App. User Permissions ELA"
{

    ApplicationArea = All;
    Caption = 'App. User Permissions';
    PageType = List;
    SourceTable = "App. User Permission ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App. Type"; Rec."App. Type")
                {
                    ApplicationArea = All;
                }
                field("App. User ID"; Rec."App. User ID")
                {
                    ApplicationArea = All;
                }
                field("Can Adjust Inventory"; Rec."Can Adjust Inventory")
                {
                    ApplicationArea = All;
                }
                field("Can Load"; Rec."Can Load")
                {
                    ApplicationArea = All;
                }
                field("Can Putaway"; Rec."Can Putaway")
                {
                    ApplicationArea = All;
                }
                field("Can Receive"; Rec."Can Receive")
                {
                    ApplicationArea = All;
                }
                field("Register Output"; Rec."Register Output")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
