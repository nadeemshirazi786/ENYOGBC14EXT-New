page 14228913 "EN Sales Payment Tender Subp."
{
    // ENSP1.00 2020-04-14 HR
    //       Created new page

    Caption = 'Sales Payment Tender Subpage';
    PageType = ListPart;
    SourceTable = "EN Sales Payment Tender Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Card/Check No."; "Card/Check No.")
                {
                }
                field(Amount; Amount)
                {
                }
                field(Result; Result)
                {
                }
                field("Cust. Ledger Entry No."; "Cust. Ledger Entry No.")
                {
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Void")
            {
                Caption = '&Void';
                Ellipsis = true;
                Enabled = VoidEnabled;
                Image = VoidCheck;
                Visible = VoidVisible;

                trigger OnAction()
                var
                    PostNonCashPage: Page "EN Sales Payments - Check";
                begin
                    PostNonCashPage.VoidNonCashEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        VoidVisible := SalesPayment.Get("Document No.");
        VoidEnabled := VoidVisible and (Result = Result::Authorized);
    end;

    var
        [InDataSet]
        VoidVisible: Boolean;
        [InDataSet]
        VoidEnabled: Boolean;
        SalesPayment: Record "EN Sales Payment Header";
}

