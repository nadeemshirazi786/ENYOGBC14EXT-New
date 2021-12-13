report 51011 "Purchase Worksheet"
{
    DefaultLayout = RDLC;
    RDLCLayout = './PurchaseWorksheet.rdlc';


    dataset
    {
        dataitem("Purchase Worksheet Header"; "Purchase Worksheet Header")
        {
            DataItemTableView = SORTING ("Order Date", "Order No.");
            RequestFilterFields = "Order Date", "Vendor No.";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Purchase_Worksheet_Header__Order_Date_; "Order Date")
            {
            }
            column(Purchase_Worksheet_Header__Vendor_No__; "Vendor No.")
            {
            }
            column(Purchase_Worksheet_Header__Shipping_Agent_Code_; "Shipping Agent Code")
            {
            }
            column(Purchase_Worksheet_Header__Customer_PO_; "Customer PO")
            {
            }
            column(Purchase_Worksheet_Header__Freight_Cost_; "Freight Cost")
            {
            }
            column(Purchase_Worksheet_Header__Expected_Receipt_Date_; "Expected Receipt Date")
            {
            }
            column(Vendor_Name; Vendor.Name)
            {
            }
            column(Purchase_WorksheetCaption; Purchase_WorksheetCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Purchase_Worksheet_Header__Order_Date_Caption; FieldCaption("Order Date"))
            {
            }
            column(Purchase_Worksheet_Header__Vendor_No__Caption; FieldCaption("Vendor No."))
            {
            }
            column(Purchase_Worksheet_Header__Shipping_Agent_Code_Caption; FieldCaption("Shipping Agent Code"))
            {
            }
            column(Purchase_Worksheet_Header__Customer_PO_Caption; FieldCaption("Customer PO"))
            {
            }
            column(Purchase_Worksheet_Header__Freight_Cost_Caption; FieldCaption("Freight Cost"))
            {
            }
            column(Purchase_Worksheet_Header__Expected_Receipt_Date_Caption; FieldCaption("Expected Receipt Date"))
            {
            }
            column(Purchase_Worksheet_Line__Item_No__Caption; "Purchase Worksheet Line".FieldCaption("Item No."))
            {
            }
            column(Purchase_Worksheet_Line_QuantityCaption; "Purchase Worksheet Line".FieldCaption(Quantity))
            {
            }
            column(Purchase_Worksheet_Line__Unit_Price_Caption; "Purchase Worksheet Line".FieldCaption("Unit Price"))
            {
            }
            column(Vendor_NameCaption; Vendor_NameCaptionLbl)
            {
            }
            column(ExtPriceCaption; ExtPriceCaptionLbl)
            {
            }
            column(Purchase_Worksheet_Header_Order_No_; "Order No.")
            {
            }
            dataitem("Purchase Worksheet Line"; "Purchase Worksheet Line")
            {
                DataItemLink = "Order Date" = FIELD ("Order Date"), "Order No." = FIELD ("Order No.");
                DataItemTableView = SORTING ("Order Date", "Order No.", "Item No.");
                column(Purchase_Worksheet_Line__Item_No__; "Item No.")
                {
                }
                column(Purchase_Worksheet_Line_Quantity; Quantity)
                {
                }
                column(Purchase_Worksheet_Line__Unit_Price_; "Unit Price")
                {
                }
                column(ExtPrice; ExtPrice)
                {
                }
                column(ExtPrice_Control1000000028; ExtPrice)
                {
                }
                column(Purchase_Worksheet_Line_Order_Date; "Order Date")
                {
                }
                column(Purchase_Worksheet_Line_Order_No_; "Order No.")
                {
                }
                column(Purchase_Worksheet_Line_Variant_Code; "Variant Code")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ExtPrice := Quantity * "Unit Price";
                end;

                trigger OnPreDataItem()
                begin
                    CurrReport.CreateTotals(ExtPrice);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not Vendor.Get("Vendor No.") then
                    Clear(Vendor);
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
    }

    var
        Vendor: Record Vendor;
        ExtPrice: Decimal;
        Purchase_WorksheetCaptionLbl: Label 'Purchase Worksheet';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Vendor_NameCaptionLbl: Label 'Vendor Name';
        ExtPriceCaptionLbl: Label 'Extended Price';
}

