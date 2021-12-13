page 14228914 "EN Posted Sales Payment List"
{
    // ENSP1.00 2020-04-14 HR
    //       Created new page

    Caption = 'Posted Sales Payment List';
    CardPageID = "EN Posted Sales Payment Card";
    Editable = false;
    PageType = List;
    SourceTable = "EN Posted Sales Payment Header";
    UsageCategory = History;

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
                field("Amount - ""Amount Tendered"""; Amount - "Amount Tendered")
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
}

