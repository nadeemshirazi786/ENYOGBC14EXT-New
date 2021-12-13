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