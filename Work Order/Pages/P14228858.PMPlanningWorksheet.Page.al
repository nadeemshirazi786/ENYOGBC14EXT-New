page 23019267 "PM Planning Worksheet"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = Table23019267;

    layout
    {
        area(content)
        {
            field(gcodCurrBatchName; gcodCurrBatchName)
            {
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SAVERECORD;
                    gcduPMMgt.LookupName(gcodCurrBatchName, Rec);
                    CurrPage.UPDATE(FALSE);
                end;

                trigger OnValidate()
                begin
                    gcduPMMgt.CheckName(gcodCurrBatchName);
                    gcodCurrBatchNameOnAfterValida;
                end;
            }
            repeater()
            {
                field("PM Procedure Code"; "PM Procedure Code")
                {
                }
                field("Version No."; "Version No.")
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Work Order Date"; "Work Order Date")
                {
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field(Name; Name)
                {
                }
                field("Serial No."; "Serial No.")
                {
                    Visible = false;
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                }
                field("PM Work Order No. Series"; "PM Work Order No. Series")
                {
                }
                field("PM Scheduling Type"; "PM Scheduling Type")
                {
                    Editable = false;
                }
                field("Evaluation Qty."; "Evaluation Qty.")
                {
                    Editable = false;
                }
                field("Schedule at %"; "Schedule at %")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Suggest PM Work Orders")
                {
                    Caption = 'Suggest PM Work Orders';

                    trigger OnAction()
                    begin
                        REPORT.RUNMODAL(REPORT::Report23019253);
                        CurrPage.UPDATE;
                    end;
                }
                action("Create PM Work Orders")
                {
                    Caption = 'Create PM Work Orders';

                    trigger OnAction()
                    begin
                        gcduPMMgt.CreatePMWOFromWksht(Rec);
                        CurrPage.UPDATE(FALSE);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IF gcodCurrBatchName = '' THEN BEGIN
            grecPMWkshtBatch.FIND('-');
            gcodCurrBatchName := grecPMWkshtBatch.Name;
        END;
        FILTERGROUP(2);
        SETRANGE("Worksheet Batch Name", gcodCurrBatchName);
        FILTERGROUP(0);
    end;

    var
        grecPMWkshtBatch: Record "23019268";
        gcduPMMgt: Codeunit "23019250";
        gcodCurrBatchName: Code[10];

    local procedure gcodCurrBatchNameOnAfterValida()
    begin
        CurrPage.SAVERECORD;
        gcduPMMgt.SetName(gcodCurrBatchName, Rec);
        CurrPage.UPDATE(FALSE);
    end;
}

