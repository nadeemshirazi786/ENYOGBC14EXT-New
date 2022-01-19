pageextension 14229608 "EN Purchase Order" extends "Purchase Order"
{
    layout
    {
        addafter("Job Queue Status")
        {
            field("Extra Charges"; "PO for Extra Charge ELA")
            {
                ApplicationArea = All;
            }
        }
        // Add changes to page layout here
        addlast(factboxes)
        {
            part("<Purch. Document Rebate FactBox>"; "Purch Document Rbt FactBox ELA")
            {
                ApplicationArea = All;
                Caption = 'Purch. Document Rebate FactBox';
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
            }
        }
        addlast("Shipping and Payment")
        {
            field("Shipping Instructions"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Code"; "Shipping Agent Code")
            {

            }
        }
        addlast(General)
        {
            field("No. Pallets"; "No. Pallets")
            {

            }
            field("Actual Pickup/ Delivery Appointment Date:"; "Act. Delivery Appointment Date")
            {
                Caption = 'Actual Pickup Delivery Appointment Date';
            }
            field("Actual Pickup/ Delivery Appointment Time:"; "Act. Delivery Appointment Time")
            {
                Caption = 'Actual Pickup Delivery Appointment Time';
            }
            field("Expected Receipt Date:"; "Exp. Delivery Appointment Date")
            {
                Caption = 'Expected Receipt Date:';
            }
            field("Expected Receipt Time:"; "Exp. Delivery Appointment Time")
            {
                Caption = 'Expected Receipt Time:';
            }
            field("Ext Bill of Lading/Waybill No."; "Ext Bill of Lading/Waybill No.")
            {

            }

        }
    }
    actions
    {

        addlast("O&rder")
        {

            action("Extra Charge")
            {
                ApplicationArea = All;

                Caption = 'Extra Charge';
                Promoted = true;
                Image = Cost;
                PromotedCategory = Process;
                AccessByPermission = TableData "EN Extra Charge" = R;
                trigger OnAction()
                begin
                    //<<ENEC1.00
                    ShowExtraChargesELA;
                    CurrPage.PurchLines.PAGE.UpdateForm(FALSE);
                    //>>ENEC1.00    
                end;
            }

        }
        addlast("F&unctions")
        {

            action("Calculate Rebates")
            {
                ApplicationArea = All;
                Caption = 'Calculate Rebates';
                Image = CalculateDiscount;

                trigger OnAction()
                var
                    lrrfHeader: RecordRef;
                    lcduPurchRebateMgt: Codeunit "Purchase Rebate Management ELA";
                begin

                    lrrfHeader.GetTable(Rec);
                    lrrfHeader.SetView(Rec.GetView);
                    lcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, false, true);

                end;
            }

        }
    }
}