//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Trip Loads List (ID 1422925).
/// </summary>
page 14229228 "Outbound Trip Loads List ELA"
{

    ApplicationArea = All;
    Caption = 'Outbound Trip Loads List';
    PageType = List;
    SourceTable = "Trip Load ELA";
    CardPageId = "Outbound Trip Load ELA";
    SourceTableView = sorting("No.") order(ascending) where(Direction = const(Outbound));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    Importance = Promoted;
                    ApplicationArea = All;

                }
                field("Load Date"; Rec."Load Date")
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                }
                field("Route No."; Rec."Route No.")
                {
                    Importance = Promoted;
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Door No."; Rec."Door No.")
                {
                    ApplicationArea = All;
                }
                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }
                field("Last modified By"; Rec."Last modified By")
                {
                    ApplicationArea = All;
                }
                field("Last Modified On"; Rec."Last Modified On")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
