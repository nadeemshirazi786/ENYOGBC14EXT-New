page 14228910 "EN Sales Payment List"
{
    // ENSP1.00 2020-04-14 HR
    //      Created new page

    Caption = 'Sales Payment List';
    CardPageID = "EN Sales Payment Card";
    PageType = List;
    SourceTable = "EN Sales Payment Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field(Amount; Amount)
                {
                    DrillDown = false;
                }
                field("Amount Tendered"; "Amount Tendered")
                {
                    DrillDown = false;
                    Visible = false;
                }
                field("GetBalance(FALSE)"; GetBalance(false))
                {
                    AutoFormatType = 1;
                    Caption = 'Balance';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002007; Notes)
            {
            }
            systempart(Control37002005; Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Action37002017)
            {
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        SalesPaymentPost: Codeunit "EN Sales Payment-Post";
                    begin
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    var
                        SalesPaymentPost: Codeunit "EN Sales Payment-Post";
                    begin
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            SalesPaymentPost.PrintAfterPosting(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action(Receipt)
                {
                    Caption = 'Receipt';
                    Image = Receipt;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Print;
                    end;
                }
                action("Pick Tickets")
                {
                    Caption = 'Pick Tickets';
                    Image = InventoryPick;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        PrintPickTickets;
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Daily Detail")
            {
                Caption = 'Daily Detail';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "EN Sales Payment Daily Detail";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;

    var
        Text000: Label 'Do you want to post Sales Payment %1?';
}

