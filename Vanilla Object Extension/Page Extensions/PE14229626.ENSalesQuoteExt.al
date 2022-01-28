/// <summary>
/// PageExtension EN Sales Quote Ext (ID 14228857) extends Record Sales Quote.
/// </summary>
pageextension 14228857 "EN Sales Quote Ext" extends "Sales Quote"
{
    layout
    {
        addlast("Work Description")
        {
            field("App. User ID"; Rec."App. User ID ELA")
            {
                ApplicationArea = All;
            }

            field("Delivery Route No."; "Route No. ELA")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action("Calc Ord Rules")
            {
                trigger OnAction()
                var
                    lcduOrderRulesMgt: Codeunit "EN Order Rule Functions";
                    lcduCalcSurcharges: Codeunit "EN Delivery Charge Mgt";

                begin
                    lcduCalcSurcharges.AddOrderSurcharges(Rec, TRUE);
                    lcduOrderRulesMgt.cbCheckOrder(Rec);
                end;

            }


        }
    }

}
