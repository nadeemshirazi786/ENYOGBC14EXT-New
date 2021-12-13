page 14229438 "Purch. Rbt Stat.- Ven Post ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00
    //    - New Page
    // 
    // ENRE1.00
    //    - add "Pending Accrual (LCY)" field


    Caption = 'Purchase Rebate Statistics';
    DataCaptionFields = "Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Purchase Rebate Header ELA";

    layout
    {
        area(content)
        {
            group(Control1101769000)
            {
                Editable = false;
                ShowCaption = false;
                group(Control23019000)
                {
                    ShowCaption = false;
                    field("Open (LCY)"; "Open (LCY)")
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 5;
                        Editable = false;
                    }
                    field("Registered (LCY)"; "Registered (LCY)")
                    {
                        ApplicationArea = All;
                    }
                    field("Posted (LCY)"; "Posted (LCY)")
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 5;
                    }
                    field(gdecOutstanding; gdecOutstanding)
                    {
                        ApplicationArea = All;
                        Caption = 'Outstanding ($)';
                        DecimalPlaces = 2 : 5;
                        Style = Strong;
                        StyleExpr = TRUE;
                    }
                    field("Closed (LCY)"; "Closed (LCY)")
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 5;
                    }
                    field(gdecTotalAmount; gdecTotalAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Total Amount ($)';
                        DecimalPlaces = 2 : 5;
                        Style = Strong;
                        StyleExpr = TRUE;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if PrevNo = Code then
            exit;

        PrevNo := Code;

        FilterGroup(2);
        SetRange(Code, PrevNo);
        FilterGroup(0);

        gdecOutstanding := "Open (LCY)" + "Registered (LCY)" + "Posted (LCY)";
        gdecTotalAmount := gdecOutstanding + "Closed (LCY)";
    end;

    var
        PrevNo: Code[20];
        gdecOutstanding: Decimal;
        gdecTotalAmount: Decimal;
}

