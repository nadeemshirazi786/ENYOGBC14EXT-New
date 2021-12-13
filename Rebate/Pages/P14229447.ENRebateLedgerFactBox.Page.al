page 14229447 "Rebate Ledger FactBox ELA"
{

    // ENRE1.00
    //   ENRE1.00 - new page


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
                Editable = false;
            }
            field(gdecAmountInclTax; gdecAmountInclTax)
            {
                ApplicationArea = All;
                Caption = 'Amount Incl. Tax';
                Editable = false;
            }
            field(pdecRebateLCY; pdecRebateLCY)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount ($)';
                Editable = false;
            }
            field(pdecRebateRBT; pdecRebateRBT)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount (RBT)';
                Editable = false;
            }
            field(pdecRebateDOC; pdecRebateDOC)
            {
                ApplicationArea = All;
                Caption = 'Rebate Amount (DOC)';
                Editable = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        gdecAmount := gcduRebateMgt.CalcAmount(Rec, false);
        gdecAmountInclTax := gcduRebateMgt.CalcAmount(Rec, true);
        pdecRebateLCY := gcduRebateMgt.CalcRebateAmount(Rec, 0);
        pdecRebateRBT := gcduRebateMgt.CalcRebateAmount(Rec, 1);
        pdecRebateDOC := gcduRebateMgt.CalcRebateAmount(Rec, 2);
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
        gcduRebateMgt: Codeunit "Rebate Management ELA";
        gdecAmount: Decimal;
        gdecAmountInclTax: Decimal;
        pdecRebateLCY: Decimal;
        pdecRebateRBT: Decimal;
        pdecRebateDOC: Decimal;
}

