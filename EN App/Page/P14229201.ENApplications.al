//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile Apps (ID 14229201).
/// </summary>
page 14229201 "Applicatoins ELA"
{

    ApplicationArea = All;
    Caption = 'Applications';
    PageType = List;
    SourceTable = "Application ELA";
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
                field("App. Name"; Rec."App. Name")
                {
                    ApplicationArea = All;
                }
                field("App. Type"; Rec."App. Type")
                {
                    ApplicationArea = All;
                }
                field("License Key"; Rec."License Key")
                {
                    ApplicationArea = All;
                }
                field("Use Roles"; Rec."Use Roles")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
