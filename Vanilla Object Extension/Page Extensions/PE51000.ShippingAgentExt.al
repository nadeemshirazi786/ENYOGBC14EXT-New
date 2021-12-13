/// <summary>
/// PageExtension ShippingAgentExt (ID 51000) extends Record Shipping Agents.
/// </summary>
pageextension 51000 ShippingAgentExt extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)
        {
            field("Vendor No."; "Vendor No.")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
    }
}