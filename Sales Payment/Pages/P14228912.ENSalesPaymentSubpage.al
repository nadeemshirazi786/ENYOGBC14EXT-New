page 14228912 "EN Sales Payment Subpage"
{
    // ENSP1.00 2020-04-14 HR
    //       Created new page

    AutoSplitKey = true;
    Caption = 'Sales Payment Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "EN Sales Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupNo(Text));
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                }
                field(Amount; Amount)
                {
                }
                field("Allow Order Changes"; "Allow Order Changes")
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Order Shipment Status"; "Order Shipment Status")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&View Order")
            {
                Caption = '&View Order';
                Ellipsis = true;
                Enabled = IsOrder;
                Image = View;
                ShortCutKey = 'Shift+Ctrl+V';

                trigger OnAction()
                begin
                    ShowOrder(false);
                end;
            }
            action("&Edit Order")
            {
                Caption = '&Edit Order';
                Ellipsis = true;
                Enabled = IsOrder;
                Image = DocumentEdit;
                ShortCutKey = 'Shift+Ctrl+E';

                trigger OnAction()
                begin
                    ShowOrder(true);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsOrder := (Type = Type::Order) and ("No." <> '');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if (xRec.Type in [Type::Order, Type::"Open Entry"]) then
            Validate(Type, xRec.Type)
        else
            Validate(Type, Type::Order);
    end;

    var
        [InDataSet]
        IsOrder: Boolean;
}

