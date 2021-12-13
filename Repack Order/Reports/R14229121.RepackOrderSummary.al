report 14229121 "EN Repack Order Summary"
{

    DefaultLayout = RDLC;
    RDLCLayout = './RepackOrderSummary.rdlc';

    Caption = 'Repack Order Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Repack Order"; "EN Repack Order")
        {
            RequestFilterFields = "No.", "Posting Date", "Item No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(RepackOrderNo; "No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderPostingDate; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(RepackOrderItemNo; "Item No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderDesc; Description)
            {
                IncludeCaption = true;
            }
            column(RepackOrderLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderQuantityProduced; "Quantity Produced")
            {
            }
            column(RepackOrderUOMCode; "Unit of Measure Code")
            {
            }
            column(LineCost; TotalCost)
            {
                AutoFormatType = 1;
            }
            column(UnitCost; UnitCost)
            {
                AutoFormatType = 2;
            }
            dataitem("Repack Order Line"; "EN Repack Order Line")
            {
                DataItemLink = "Order No." = FIELD("No.");
                DataItemTableView = SORTING("Order No.", "Line No.");
                column(RepackOrderLineType; Type)
                {
                }
                column(RepackOrderLineNo; "No.")
                {
                }
                column(RepackOrderLineDesc; Description)
                {
                }
                column(RepackOrderLineUOMCode; "Unit of Measure Code")
                {
                }
                column(RepackOrderLineQuantityConsumed; "Quantity Consumed")
                {
                }
                column(RepackOrderLineLotNo; "Lot No.")
                {
                }
                column(RepackOrderLineLineCost; LineCost)
                {
                    AutoFormatType = 1;
                }
                column(RepackOrderLineLineNo; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    LineCost := 0;
                    ItemLedger.SetRange("Order No.", "Order No.");
                    ItemLedger.SetRange("Order Line No.", "Line No.");
                    ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::"Negative Adjmt.");
                    if ItemLedger.FindFirst then begin
                        ItemLedger.CalcFields("Cost Amount (Actual)");
                        LineCost := -ItemLedger."Cost Amount (Actual)";

                    end else begin
                        ResLedger.SetRange("Order No.", "Order No.");
                        ResLedger.SetRange("Order Line No.", "Line No.");
                        if ResLedger.FindFirst then
                            LineCost := ResLedger."Total Cost";
                    end;

                end;
            }

            trigger OnAfterGetRecord()
            begin
                ItemLedger.SetRange("Order No.", "No.");
                ItemLedger.SetRange("Order Line No.");
                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::"Positive Adjmt.");
                if ItemLedger.FindFirst then begin
                    ItemLedger.CalcFields("Cost Amount (Actual)");
                    TotalCost := ItemLedger."Cost Amount (Actual)";


                    if "Quantity Produced" <> 0 then
                        UnitCost := TotalCost / "Quantity Produced"
                    else
                        UnitCost := 0;
                end else begin
                    TotalCost := 0;
                    UnitCost := 0;
                end;

            end;

            trigger OnPreDataItem()
            begin
                ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                ItemLedger.SetRange("Order Type", ItemLedger."Order Type Ext ELA"::Repack);

                ResLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                ResLedger.SetRange("Order Type", ResLedger."Order Type Ext ELA"::Repack);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        RepackOrderSummaryCaption = 'Repack Order Summary';
        PAGENOCaption = 'Page';
        QuantityProducedCaption = 'Quantity';
        UOMCodeCaption = 'Unit of Measure';
        LineCostCaption = 'Total Cost';
        UnitCostCaption = 'Unit Cost';
    }

    var
        ItemLedger: Record "Item Ledger Entry";
        ResLedger: Record "Res. Ledger Entry";
        Item: Record Item;
        LineCost: Decimal;
        TotalCost: Decimal;
        UnitCost: Decimal;
}

