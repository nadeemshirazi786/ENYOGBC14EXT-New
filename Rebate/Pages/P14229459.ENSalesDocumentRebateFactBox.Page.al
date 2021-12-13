page 14229459 "Sales Document Rbt FactBox ELA"
{

    // ENRE1.00
    //   - new factbox
    // 
    // ENRE1.00
    //   ENRE1.00 -  add field:
    //               "Sales Profit Modifier Amount"


    Caption = 'Rebates';
    PageType = CardPart;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            field("Off-Invoice Rebate (LCY)"; SalesInfoPaneMgt2.CalcRebate(Rec, 1))
            {
                ApplicationArea = All;
                AutoFormatType = 1;
                Caption = 'Off-Invoice Rebate ($)';
                DrillDown = true;
                Editable = false;

                trigger OnDrillDown()
                begin
                    SalesInfoPaneMgt2.LookupRebate(Rec, 1);
                end;
            }
            field("Other Rebate (LCY)"; SalesInfoPaneMgt2.CalcRebate(Rec, 2))
            {
                ApplicationArea = All;
                AutoFormatType = 1;
                Caption = 'Other Rebate ($)';
                DrillDown = true;
                Editable = false;

                trigger OnDrillDown()
                begin
                    SalesInfoPaneMgt2.LookupRebate(Rec, 2);
                end;
            }
            field("Sales Profit Modifier Amount"; "SalesProfit Modifier Amt ELA")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }

    var
        SalesInfoPaneMgt: Codeunit "Sales Info-Pane Management";
        SalesInfoPaneMgt2: Codeunit "Sales Info Pane Managment ELA";
}

