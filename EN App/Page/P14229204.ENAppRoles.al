//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile App. Role (ID 14229204).
/// </summary>
page 14229204 "App. Roles ELA"
{

    ApplicationArea = All;
    Caption = 'App. Roles';
    PageType = List;
    SourceTable = "App. Role ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Role Code"; Rec."Role Code")
                {
                    ApplicationArea = All;
                }
                field("Role Name"; Rec."Role Name")
                {
                    ApplicationArea = All;
                }
                field("App. Code"; Rec."App. Code")
                {
                    ApplicationArea = All;
                }
                field("Auto Assign Jobs"; Rec."Auto Assign Jobs")
                {
                    ApplicationArea = All;
                }
                field("Custom Role Filter"; Rec."Custom Role Filter")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }

                field("Role Type"; Rec."Role Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
