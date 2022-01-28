/// <summary>
/// Page EN Warehouse Requests (ID 14229236).
/// </summary>
page 14229236 "Receiving Management ELA"
{

    ApplicationArea = Warehouse;
    Caption = 'Receiving Management';
    PageType = Worksheet;
    SourceTable = "Warehouse Request";
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Source Type", "Source No.") where(Type = const(Inbound),
        "Source Document" = filter("Purchase Order" | "Sales Return Order" | "Inbound Transfer"),
        "Document Status" = const(Released), "Completely Handled" = const(false));

    layout
    {
        area(content)
        {
            group("Filters")
            {
                field("Location Code Filter"; LocationCodeFilter)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var text: Text): Boolean
                    var
                        myInt: Integer;
                    begin
                        exit(ENWMSUtil.LookupWHEmployeeLocation(text));
                    end;
                }

                field("Receipt Date Filter"; ReceiptDateFilter)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
                field("Document Type Filter"; DocumentTypeFilter)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        ApplyFilters;
                    end;
                }
                field("Document No. Filter"; DocumentNoFilter)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        ApplyFilters();
                    end;
                }
            }
            repeater(General)
            {
                Editable = false;
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Warehouse;
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Warehouse;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = Warehouse;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = Warehouse;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    Visible = false;
                    ApplicationArea = Warehouse;
                }
                field("Trip No."; Rec."Trip No. ELA")
                {
                    ApplicationArea = Warehouse;
                }
                field("Warehouse Shipment No."; Rec."Warehouse Shipment No. ELA")
                {
                    ApplicationArea = Warehouse;
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = Warehouse;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Warehouse;
                }
            }
        }
    }

    actions
    {

        area(processing)
        {
            group("Actions")
            {
                action("Reset Filters")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    Image = Refresh;
                    Caption = '&Reset Filters';
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        ClearAll();
                        SetOpenPageFilters();
                    end;
                }

                action("Show Source Document")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    image = ViewSourceDocumentLine;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        TransferHeader: Record "Transfer Header";
                        SalesHeader: record "Sales Header";
                        PurchaseOrder: Page "Purchase Order";
                        TransferOrder: Page "Transfer Order";
                        SalesReturnOrder: Page "Sales Return Order";
                    begin
                        // Message('%1 %2', "Source Document", "Source No.");
                        // case "Source Document" of
                        // "Source Document"::"Purchase Order":
                        // begin
                        // PurchaseHeader.FilterGroup(4);
                        PurchaseHeader.get("Source Subtype", "Source No.");
                        // PurchaseHeader.FilterGroup(0);
                        PurchaseOrder.SetRecord(PurchaseHeader);
                        // PurchaseOrder.SetTableView(PurchaseHeader);
                        PurchaseOrder.Run();
                        // end;
                        // "Source Document"::"Inbound Transfer":
                        //     begin
                        //         TransferHeader.FilterGroup(4);
                        //         TransferHeader.get("Source No.");
                        //         TransferHeader.FilterGroup(0);
                        //         TransferOrder.SetTableView(TransferHeader);
                        //         TransferOrder.Run();
                        //     end;
                        // "Source Document"::"Sales Return Order":
                        //     begin
                        //         SalesHeader.FilterGroup(4);
                        //         SalesHeader.get("Source Subtype", "Source No.");
                        //         SalesHeader.FilterGroup(0);
                        //         SalesReturnOrder.SetTableView(SalesHeader);
                        //         SalesReturnOrder.Run();
                        //     end;
                        // end;
                    end;
                }

                action("Receive")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    image = ViewSourceDocumentLine;
                    PromotedCategory = Process;
                    trigger OnAction()
                    begin
                        WMSMgmt.PerformWHReceive(Rec);


                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetOpenPageFilters();


    end;

    local procedure ApplyFilters()
    var

    begin
        TextManagement.MakeDateFilter(ReceiptDateFilter);
        IF ReceiptDateFilter = '' THEN begin
            SETRANGE("Expected Receipt Date");
        end ELSE
            SETFILTER("Expected Receipt Date", ReceiptDateFilter);

        // if format(DocumentTypeFilter) = '0' then
        //     setrange("Source Document")
        // else
        //     SetFilter("Source Document", '%1', DocumentTypeFilter);

        TextManagement.MakeTextFilter(DocumentNoFilter);

        if DocumentNoFilter = '' then
            SetRange("Source No.")
        else
            SetFilter("Source No.", DocumentNoFilter);

        case DocumentTypeFilter of
            DocumentTypeFilter::PurchaseOrder:
                SetRange("Source Document", "Source Document"::"Purchase Order");
            DocumentTypeFilter::"Sales Return Order":
                SetRange("Source Document", "Source Document"::"Sales Return Order");
            DocumentTypeFilter::"Transfer Order":
                SetRange("Source Document", "Source Document"::"Inbound Transfer");
            else
                setrange("Source Document");
        end;

        FilterGroup(0);
        CurrPage.UPDATE(FALSE);
    end;

    local procedure SetOpenPageFilters()
    begin
        FilterGroup(2);
        SetFilter("Location Code", '%1', ENWMSUtil.GetWHEmployeeLocationFilter);
        LocationCodeFilter := rec.GetFilter("Location Code");
        FilterGroup(0);

        ApplyFilters;
    end;

    var
        LocationCodeFilter: Code[10];
        ReceiptDateFilter: Text[250];
        DocumentNoFilter: text[250];
        DocumentTypeFilter: ENum "Inbound Document Types ELA";
        ENWMSUtil: Codeunit "WMS Util ELA";
        TextManagement: Codeunit TextManagement;

        WMSMgmt: Codeunit "WMS Management ELA";

    // DocumentTypeFilter : option;
}
