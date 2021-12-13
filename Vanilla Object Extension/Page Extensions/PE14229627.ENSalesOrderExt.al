/// <summary>
/// PageExtension EN Sales Order Ext (ID 14228858) extends Record Sales Order.
/// </summary>
pageextension 14228858 "EN Sales Order Ext" extends "Sales Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Attached Documents")
        {
            part(Control1000000000; "Sales Document Rbt FactBox ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
                Visible = true;
            }
        }
        addlast("Shipping and Billing")
        {
            field("Delivery Zone Code"; "Delivery Zone Code ELA")
            {
                ApplicationArea = All;
            }
            field("Pallet Code"; "Pallet Code ELA")
            {
                ApplicationArea = All;
            }
            field("Date Order Created"; "Date Order Created ELA")
            {
                ApplicationArea = All;
            }
            field("Standing Order Status"; "Standing Order Status")
            {
                ApplicationArea = All;
            }
            field("Order Template Location"; "Order Template Location ELA")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Logistics Route No."; "Logistics Route No. ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Instructions ELA"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }

        }
        addafter("Direct Debit Mandate ID")
        {
            field("Bypass Order Rules"; "Bypass Order Rules ELA")
            {
                ApplicationArea = All;
            }
            field("Price List Group Code"; "Price List Group Code ELA")
            {
                ApplicationArea = All;
            }
            field("Order Rule Group"; "Order Rule Group ELA")
            {
                ApplicationArea = All;
            }
            field("Lock Pricing"; "Lock Pricing ELA")
            {
                ApplicationArea = All;
            }
        }
        addafter(Status)
        {
            field("Amt. To Collect"; "Seal No. ELA")
            {
                ApplicationArea = All;
            }
            field("No. Pallets"; "No. Pallets")
            {
                Caption = 'No. Pallets';
            }
            field("Warehouse Shipment Exists"; "Warehouse Shipment Exists ELA")
            {
                ApplicationArea = All;
            }

        }
        modify("Transport Method")
        {
            Caption = 'Checker';
        }
        modify("Transaction Type")
        {
            Caption = 'Checker Findings';
        }
        moveafter("No. Pallets"; "Transport Method")
        moveafter("Transport Method"; "Transaction Type")

    }
    actions
    {
        addlast("F&unctions")
        {
            group("Order Calc(s)")
            {
                action("Calc Rebates")
                {
                    trigger OnAction()
                    var
                        ///lcduRebateMgt: Codeunit "EN Order Rule Functions";
                        lrrfHeader: RecordRef;
                    begin

                        lrrfHeader.GETTABLE(Rec);
                        lrrfHeader.SETVIEW(Rec.GETVIEW);
                        ///lcduRebateMgt.JF_CalcSalesDocRebate(lrrfHeader, FALSE, TRUE);
                    end;
                }
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

}
