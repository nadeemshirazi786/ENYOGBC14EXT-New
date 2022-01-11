page 14228823 "Bank Deposit Worksheet ELA"
{
    AutoSplitKey = true;
    DataCaptionFields = "Bank Deposit Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Bank Deposit Wksht Entry ELA";
    UsageCategory = Tasks;
    ApplicationArea = all;
    Caption = 'Bank Deposit Worksheet';

    layout
    {
        area(content)
        {
            field(CurrentBatchName; CurrentBatchName)
            {
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord;
                    LookupName(CurrentBatchName, gtxtBankAcctName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    CheckName(CurrentBatchName, gtxtBankAcctName, Rec);
                    CurrentBatchNameOnAfterValidat;
                end;
            }
            field(gtxtBankAcctName; gtxtBankAcctName)
            {
                Caption = 'Bank Account Name';
                Editable = false;
            }
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                }
                field("Entry Type"; "Entry Type")
                {
                }
                field("Bill-To Customer No."; "Bill-To Customer No.")
                {
                }
                field("Sell-To Customer No."; "Sell-To Customer No.")
                {
                    Visible = false;
                }
                field("Ship-To Code"; "Ship-To Code")
                {
                    Visible = false;
                }
                field("Applies-To Document Type"; "Applies-To Document Type")
                {
                }
                field("Applies-To Document No."; "Applies-To Document No.")
                {
                }
                field("Due Date"; "Due Date")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field("Original Amount"; "Original Amount")
                {
                    Visible = false;
                }
                field(Amount; Amount)
                {
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                }
                field("Amount To Apply"; "Amount To Apply")
                {
                }
                field("Check No."; "Check No.")
                {
                }
                field("Check Total Amount"; "Check Total Amount")
                {
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                }
                field("Original Pmt. Disc. Possible"; "Original Pmt. Disc. Possible")
                {
                }
                field("Remaining Pmt. Disc. Possible"; "Remaining Pmt. Disc. Possible")
                {
                }
                field("Pmt. Disc. Tolerance Date"; "Pmt. Disc. Tolerance Date")
                {
                }
                field("Max. Payment Tolerance"; "Max. Payment Tolerance")
                {
                }
                field("Reason Code"; "Reason Code")
                {
                }
                field("Reference No."; "Reference No.")
                {
                }
                field("EDI Internal Doc. No."; "EDI Internal Doc. No.")
                {
                    Visible = false;
                }
                field("EDI Applies-To Document No."; "EDI Applies-To Document No.")
                {
                    Visible = false;
                }
                field("EDI Reason Code"; "EDI Reason Code")
                {
                    Visible = false;
                }
            }
            group(Control1102631056)
            {
                ShowCaption = false;
                fixed(Control1906840501)
                {
                    ShowCaption = false;
                    group(Control1902572601)
                    {
                        Caption = 'Remaining Amount';
                        field(gdecTotalRemAmount; gdecTotalRemAmount)
                        {
                            Editable = false;
                        }
                    }
                    group("Pmt. Discount Applied")
                    {
                        Caption = 'Pmt. Discount Applied';
                        field("-gdecTotalRemDiscount"; -gdecTotalRemDiscount)
                        {
                            Caption = 'Pmt. Discount Applied';
                            Editable = false;
                        }
                    }
                    group("Outstanding Amount")
                    {
                        Caption = 'Outstanding Amount';
                        field("gdecTotalRemAmount - gdecTotalRemDiscount"; gdecTotalRemAmount - gdecTotalRemDiscount)
                        {
                            Caption = 'Outstanding Amount';
                            Editable = false;
                        }
                    }
                    group("Applied Amount")
                    {
                        Caption = 'Applied Amount';
                        field(gdecTotalDeposit; gdecTotalDeposit)
                        {
                            Caption = 'Applied Amount';
                            Editable = false;
                        }
                    }
                    group("Available To Apply")
                    {
                        Caption = 'Available To Apply';
                        field("(gdecTotalRemAmount - gdecTotalRemDiscount) - gdecTotalDeposit"; (gdecTotalRemAmount - gdecTotalRemDiscount) - gdecTotalDeposit)
                        {
                            Caption = 'Available To Apply';
                            Editable = false;
                        }
                    }
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
                action("Create Bank Deposit")
                {
                    Caption = 'Create Bank Deposit';
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        lcodDepositNo: Code[20];
                    begin
                        lcodDepositNo := jfCreateBankDeposit(Rec);

                        if lcodDepositNo <> '' then
                            Message(gjfText000, lcodDepositNo);

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        jfCalcTotals;
        SetUpNewLine(xRec);
        OnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin
        jfCalcTotals;
        OpenJnl(CurrentBatchName, gtxtBankAcctName, Rec);
    end;

    var
        CurrentBatchName: Code[10];
        gdecTotalDeposit: Decimal;
        gdecTotalRemAmount: Decimal;
        gdecTotalRemDiscount: Decimal;
        gtxtBankAcctName: Text[30];
        gjfText000: Label 'Deposit No. %1 has been created.';

    [Scope('Internal')]
    procedure jfCalcTotals()
    var
        lrecDepWkshtLine: Record "Bank Deposit Wksht Entry ELA";
    begin
        gdecTotalDeposit := 0;
        gdecTotalRemAmount := 0;
        gdecTotalRemDiscount := 0;

        lrecDepWkshtLine.CopyFilters(Rec);

        if lrecDepWkshtLine.FindSet then begin
            repeat
                gdecTotalDeposit += lrecDepWkshtLine."Amount To Apply";

                lrecDepWkshtLine.CalcFields("Remaining Amount");

                gdecTotalRemAmount += lrecDepWkshtLine."Remaining Amount";

                if lrecDepWkshtLine."Posting Date" <= lrecDepWkshtLine."Pmt. Disc. Tolerance Date" then
                    gdecTotalRemDiscount += lrecDepWkshtLine."Remaining Pmt. Disc. Possible";
            until lrecDepWkshtLine.Next = 0;
        end;
    end;

    local procedure CurrentBatchNameOnAfterValidat()
    begin
        CurrPage.SaveRecord;
        SetName(CurrentBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        jfCalcTotals;
    end;

    local procedure OnBeforePutRecord()
    begin
        jfCalcTotals;
    end;
}

