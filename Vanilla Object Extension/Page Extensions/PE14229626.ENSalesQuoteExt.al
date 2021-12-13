/// <summary>
/// PageExtension EN Sales Quote Ext (ID 14228857) extends Record Sales Quote.
/// </summary>
pageextension 14228857 "EN Sales Quote Ext" extends "Sales Quote"
{
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
