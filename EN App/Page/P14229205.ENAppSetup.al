//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Mobile App. Setup (ID 14229205).
/// </summary>
page 14229205 "Application Setup ELA"
{

    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Application Setup';
    PageType = Card;
    SourceTable = "Application Setup ELA";
    InsertAllowed = false;
    DeleteAllowed = false;
    AccessByPermission = TableData "Application Setup ELA" = R;

    layout
    {
        area(content)
        {
            group("Warehouse App Setup")
            {
                group("Session Setup")
                {
                    field("App. Login Time Out"; Rec."App. Login Time Out")
                    {
                        ApplicationArea = All;
                    }
                    field("Clear Assignments On Logout"; Rec."Clear Assignments On Logout")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            group("Sales App Setup")
            {
                field("Enabled"; "Primary Key")
                {
                    ApplicationArea = All;

                }
            }

            group("DSD App Setup")
            {


            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

}
