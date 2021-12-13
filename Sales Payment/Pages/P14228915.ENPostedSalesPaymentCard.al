page 14228915 "EN Posted Sales Payment Card"
{
    // ENSP1.00 2020-04-14 HR
    //       Created new page

    Caption = 'Posted Sales Payment Card';
    Editable = false;
    PageType = Card;
    SourceTable = "EN Posted Sales Payment Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                }
                group(Control37002011)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                    }
                    field("Customer Name"; "Customer Name")
                    {
                    }
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Sales Payment No."; "Sales Payment No.")
                {
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
                    field("Amount - ""Amount Tendered"""; Amount - "Amount Tendered")
                    {
                        AutoFormatType = 1;
                        Caption = 'Balance';
                    }
                }
            }
            part(Lines; "EN Posted Sales Payment SubP.")
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
            action("Show &Invoice")
            {
                Caption = 'Show &Invoice';
                Image = Invoice;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ShowInvoice;
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
            action("&Print")
            {
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Print;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Amount, "Amount Tendered");
    end;
}

