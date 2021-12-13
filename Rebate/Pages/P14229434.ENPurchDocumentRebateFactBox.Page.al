page 14229434 "Purch Document Rbt FactBox ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   - new factbox


    Caption = 'Rebates';
    PageType = CardPart;
    SourceTable = "Purchase Header";

    layout
    {
        area(content)
        {
            field("Off-Invoice Rebate (LCY)"; PurchInfoPaneMgt2.CalcRebate(Rec, 1))
            {
                ApplicationArea = All;
                AutoFormatType = 1;
                Caption = 'Off-Invoice Rebate ($)';
                DrillDown = true;
                Editable = false;

                trigger OnDrillDown()
                begin
                    PurchInfoPaneMgt2.LookupRebate(Rec, 1);
                end;
            }
            field("Other Rebate (LCY)"; PurchInfoPaneMgt2.CalcRebate(Rec, 2))
            {
                ApplicationArea = All;
                AutoFormatType = 1;
                Caption = 'Other Rebate ($)';
                DrillDown = true;
                Editable = false;

                trigger OnDrillDown()
                begin
                    PurchInfoPaneMgt2.LookupRebate(Rec, 2);
                end;
            }
        }
    }

    actions
    {
    }

    var
        PurchInfoPaneMgt: Codeunit "Purchases Info-Pane Management";
        PurchInfoPaneMgt2: Codeunit "Purch Info Pane Management ELA";
}

