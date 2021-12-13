page 14229445 "Rebate Journal ELA"
{
    // ENRE1.00 2021-09-08 AJ


    AutoSplitKey = true;
    Caption = 'Rebate Journal';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Rebate Journal Line ELA";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentBatchName; CurrentBatchName)
            {
                ApplicationArea = All;
                Caption = ' Batch Name';
                Lookup = true;
                TableRelation = "Rebate Batch ELA";

                trigger OnValidate()
                begin
                    RebateBatch.Get(CurrentBatchName);
                    CurrentBatchNameOnAfterValidat;
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Code"; "Rebate Code")
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Applies-To Source Type"; "Applies-To Source Type")
                {
                    ApplicationArea = All;
                }
                field("Applies-To Customer No."; "Applies-To Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Applies-To Source No."; "Applies-To Source No.")
                {
                    ApplicationArea = All;
                }
                field("Applies-To Source Line No."; "Applies-To Source Line No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("P&ost")
            {
                Caption = 'P&ost';
                action(Action30)
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Rebate Jnl.-Post ELA", Rec);
                        CurrentBatchName := GetRangeMax("Rebate Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine(xRec);
    end;

    trigger OnOpenPage()
    begin
        if not RebateBatch.Get(CurrentBatchName) then begin
            if not RebateBatch.Find('-') then begin
                RebateBatch.Init;
                RebateBatch.Name := 'DEFAULT';
                RebateBatch.Description := 'Default Journal';
                RebateBatch.Insert(true);
                Commit;
            end;
            CurrentBatchName := RebateBatch.Name;
        end;
        FilterGroup := 2;
        SetRange("Rebate Batch Name", CurrentBatchName);
        FilterGroup := 0;
    end;

    var
        CurrentBatchName: Code[10];
        RebateBatch: Record "Rebate Batch ELA";

    local procedure CurrentBatchNameOnAfterValidat()
    begin
        CurrPage.SaveRecord;
        FilterGroup := 2;
        SetRange("Rebate Batch Name", CurrentBatchName);
        FilterGroup := 0;
        if FindSet then;
        CurrPage.Update(false);
    end;
}

