//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN WMS Setup (ID 14229220).
/// </summary>
page 14229240 "WMS Setup ELA"
{
    Caption = 'WMS Setup';
    PageType = Card;
    SourceTable = "WMS Setup ELA";
    UsageCategory = Administration;
    ApplicationArea = Warehouse;
    InsertAllowed = false;
    DeleteAllowed = false;
    AccessByPermission = TableData "WMS Setup ELA" = R;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Add Orders to Outbound Loads On Release"; Rec."Add Orders to Outb. Loads")
                {
                    ApplicationArea = All;
                    ToolTip = 'Auto Add orders on outbound load when released.';
                }

                field("Enforce Containers Use"; "Enforce Containers Use")
                {
                    ApplicationArea = All;
                }
                field("License Plate Nos."; Rec."License Plate Nos.")
                {
                    ApplicationArea = All;
                }

                field("Bill of Lading Nos."; "Bill of Lading Nos.")
                {
                    ApplicationArea = All;
                }

                field("Inbound Load Nos."; "Inbound Load Nos.")
                {
                    ApplicationArea = All;
                }

                field("Outbound Nos."; "Outbound Load Nos.")
                {
                    ApplicationArea = All;
                }

                field("Container Nos."; "Container Nos.")
                {
                    ApplicationArea = All;
                }
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
