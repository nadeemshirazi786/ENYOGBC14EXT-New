page 14228911 "EN Sales Payment Card"
{
    // ENSP1.00 2020-04-14 HR
    //     Created new page

    Caption = 'Sales Payment Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Lines,Tenders';
    SourceTable = "EN Sales Payment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {

                    trigger OnAssistEdit()
                    begin
                        if AssistEditNo(xRec) then
                            CurrPage.Update;
                    end;
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {

                        trigger OnValidate()
                        begin
                            CurrPage.Update;
                        end;
                    }
                    field("Customer Name"; "Customer Name")
                    {
                    }
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field(GetCustomerBalance; GetCustomerBalance)
                {
                    Caption = 'Customer Balance ($)';
                }
                group(Control37002019)
                {
                    ShowCaption = false;
                    field(Amount; Amount)
                    {
                        DrillDown = false;
                    }
                    field("Amount Tendered"; "Amount Tendered")
                    {
                        DrillDown = false;
                    }
                    field("GetBalance(FALSE)"; GetBalance(false))
                    {
                        AutoFormatType = 1;
                        Caption = 'Balance';
                    }
                }
                field(Status; Status)
                {
                }
                field("Allow Posting w/ Balance"; "Allow Posting w/ Balance")
                {
                }
            }
            part(Lines; "EN Sales Payment Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = FIELD("No.");
                SubPageView = SORTING("Document No.", "Line No.");
            }
            part(Tenders; "EN Sales Payment Tender Subp.")
            {
                Caption = 'Tenders';
                Editable = false;
                SubPageLink = "Document No." = FIELD("No.");
                SubPageView = SORTING("Document No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Notes)
            {
            }
            systempart(Control37002007; Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            separator(Action37002013)
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
                        TestField("No.");
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
                        TestField("No.");
                        if Confirm(Text000, false, "No.") then begin
                            SalesPaymentPost.Run(Rec);
                            SalesPaymentPost.PrintAfterPosting(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("&Add Orders")
                {
                    Caption = '&Add Orders';
                    Ellipsis = true;
                    Image = AddAction;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+A';

                    trigger OnAction()
                    begin
                        AddOrders;
                    end;
                }
                action("Add &Open Entries")
                {
                    Caption = 'Add &Open Entries';
                    Ellipsis = true;
                    Image = AddAction;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+O';

                    trigger OnAction()
                    begin
                        AddOpenEntries;
                    end;
                }
                action("Fix Sales Payment")
                {
                    Caption = 'Fix Sales Payment';
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "EN Fix Sales Payment";
                }
            }
            group("P&ayments")
            {
                Caption = 'P&ayments';
                action("&Cash")
                {
                    Caption = '&Cash';
                    Ellipsis = true;
                    Image = Costs;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+C';

                    trigger OnAction()
                    begin
                        DoCashPayment;
                    end;
                }
                action("Check/&Other")
                {
                    Caption = 'Check/&Other';
                    Ellipsis = true;
                    Image = Check;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        DoNonCashPayment;
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
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;

    var
        Text000: Label 'Do you want to post Sales Payment %1?';
}

