page 51016 "Additional Freight"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Additional Freight";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;

                }
                field("Freight Cost"; "Freight Cost")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; "Order Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Order No."; "Order No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
    trigger OnClosePage()
    var
        PWHead: Record "Purchase Worksheet Header";
        AdditionalFreight: Record "Additional Freight";
        PurchWskshtFreight: Decimal;
    begin
        PWHead.Reset();
        PWHead.SetRange("Order Date", Rec."Order Date");
        PWHead.SetRange("Order No.", Rec."Order No.");
        IF PWHead.FindFirst() then begin
            AdditionalFreight.Reset();
            AdditionalFreight.SetRange("Order Date", PWHead."Order Date");
            AdditionalFreight.SetRange("Order No.", PWHead."Order No.");
            IF AdditionalFreight.FindSet() then begin
                repeat
                    PurchWskshtFreight += AdditionalFreight."Freight Cost";
                until AdditionalFreight.Next() = 0;
            end;
            PWHead."Freight Cost" := PurchWskshtFreight;
            PWHead.Modify(true);
        end;
    end;
}