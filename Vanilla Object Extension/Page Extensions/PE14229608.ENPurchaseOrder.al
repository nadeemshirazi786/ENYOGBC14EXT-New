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
			field("Pickup Date"; "Pickup Date ELA")
            {
                ApplicationArea = All;
            }
            field("Your Reference"; "Your Reference")
            {

                ApplicationArea = All;
            }
            field("PO Receiving Status ELA"; "PO Receiving Status ELA")
            {
                ApplicationArea = All;
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
		addfirst(Processing)
        {
            action("Show Containers")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Resource;

                trigger OnAction()
                var
                    ContMgmt: codeunit "Container Mgmt. ELA";
                    WhseDocType: Enum "Whse. Doc. Type ELA";
                    SourceDoctypeFilter: Enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    ContMgmt.ShowContainer(SourceDoctypeFilter, '', "Location Code", "Document Type", "No.",
                     WhseDocType::Receipt, '', ActivityType, '');
                end;
            }

            action("Assign Container Contents")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Create;
                trigger OnAction()
                var
                    AssignContContents: Page "Assign Container Contents ELA";
                    WhseDocType: Enum "Whse. Doc. Type ELA";
                    ENWMSSourceDocTypeFilter: Enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    AssignContContents.SetDocumentFilters(ENWMSSourceDocTypeFilter::"Purchase Order", "Document Type", "No.", 0,
                        WhseDocType, '', ActivityType, '', 0, '', false);
                    AssignContContents.Run();
                end;
            }

            action("Create Receipt")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Receipt;

                trigger OnAction()
                var
                    WMSMgmt: Codeunit "WMS Activity Mgmt. ELA";
                begin
                    WMSMgmt.CreatePOReceipt(Rec."No.");
                end;
            }
        }
    }
	procedure SetLocFilter(LocationCode: code[10])
    begin
        CurrPage.PurchLines.Page.SetLocFilter(LocationCode);
        CurrPage.Update();
    end;
}