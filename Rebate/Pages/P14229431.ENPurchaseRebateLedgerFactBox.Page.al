page 14229431 "Purch Rbt Ledger FactBox ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new page


    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Rebate Ledger Entry ELA";

    layout
    {
        area(content)
        {
            field("Source Type"; "Source Type")
            {
                ApplicationArea = All;
            }
            field("Source No."; "Source No.")
            {
                ApplicationArea = All;
            }
            field("Source Line No."; "Source Line No.")
            {
                ApplicationArea = All;
            }
            field(gdecAmount; gdecAmount)
            {
                ApplicationArea = All;
                Caption = 'Amount';
            }
            field(gdecAmountInclTax; gdecAmountInclTax)
            {
                ApplicationArea = All;
                Caption = 'Amount Incl. Tax';
            }
            field(pdecRebateLCY; pdecRebateLCY)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount ($)';
            }
            field(pdecRebateRBT; pdecRebateRBT)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount (RBT)';
            }
            field(pdecRebateDOC; pdecRebateDOC)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount (DOC)';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        gdecAmount := gcduPurchRebateMgt.CalcAmount(Rec, false);
        gdecAmountInclTax := gcduPurchRebateMgt.CalcAmount(Rec, true);
        pdecRebateLCY := gcduPurchRebateMgt.CalcRebateAmount(Rec, 0);
        pdecRebateRBT := gcduPurchRebateMgt.CalcRebateAmount(Rec, 1);
        pdecRebateDOC := gcduPurchRebateMgt.CalcRebateAmount(Rec, 2);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        gdecAmount := 0;
        gdecAmountInclTax := 0;
        pdecRebateLCY := 0;
        pdecRebateRBT := 0;
        pdecRebateDOC := 0;

        exit(Find(Which));
    end;

    var
        gcduPurchRebateMgt: Codeunit "Purchase Rebate Management ELA";
        gdecAmount: Decimal;
        gdecAmountInclTax: Decimal;
        pdecRebateLCY: Decimal;
        pdecRebateRBT: Decimal;
        pdecRebateDOC: Decimal;
}

